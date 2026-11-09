#!/usr/bin/env ruby
# frozen_string_literal: true
#
# check.rb — validates the Espanso match files in this repo.
#
#   ruby check.rb          (from the repo root; exits non-zero on any error)
#
# Uses only the Ruby standard library (Ruby ships with macOS and GitHub's runners),
# so it needs no PyYAML or gems. Checks:
#   1. every *.yml parses as YAML
#   2. every match file has a `matches:` list and every trigger starts with ':'
#   3. triggers are unique across all files
#   4. no trigger is a prefix of another unless the shorter one has `word: true`
#      (Espanso expands as soon as a trigger matches, so `:d` would block `:date`)
#   5. README.md lists every trigger, and every trigger it lists exists
#   6. `imports:` point at existing files, and files using shared vars import them
#   7. no real-looking emails or public IPs leak into the templates
#   8. the clipboard defang/refang commands give the expected output for sample input
#      (pbpaste is swapped for printf, so this runs on Linux CI with GNU sed too)

require "yaml"
require "ipaddr"
require "open3"

Dir.chdir(File.expand_path(__dir__))

SHARED = "shared-vars.yml"
EMAIL_OK = /@(example\.(com|org|net)|domain\.com|organisation\.com|organization\.com)\z/i
IP_OK = %w[
  0.0.0.0/8 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16
  192.0.2.0/24 198.51.100.0/24 203.0.113.0/24
  1.1.1.1/32 1.0.0.1/32 8.8.8.8/32 8.8.4.4/32 9.9.9.9/32
].map { |c| IPAddr.new(c) }

errors = []
err = ->(msg) { errors << msg }

files = Dir["*.yml"].sort
docs = {}
files.each do |f|
  begin
    docs[f] = YAML.safe_load(File.read(f)) || {}
  rescue Psych::Exception => e
    err.call("#{f}: YAML parse error: #{e.message}")
  end
end

# --- 1/2: structure and collect triggers -----------------------------------------
triggers = {} # trigger => [file, word?]
shared_vars = []
if docs[SHARED]
  shared_vars = (docs[SHARED]["global_vars"] || []).map { |v| v["name"] }
  err.call("#{SHARED}: should only hold global_vars, not matches") if docs[SHARED]["matches"]
end

docs.each do |f, doc|
  next if f == SHARED
  matches = doc["matches"]
  unless matches.is_a?(Array)
    err.call("#{f}: no `matches:` list")
    next
  end
  matches.each_with_index do |m, i|
    trigs = Array(m["trigger"]) + Array(m["triggers"])
    err.call("#{f}: match ##{i + 1} has no trigger") if trigs.empty?
    trigs.each do |t|
      err.call("#{f}: trigger #{t.inspect} does not start with ':'") unless t.to_s.start_with?(":")
      if triggers.key?(t)
        err.call("#{f}: duplicate trigger #{t} (also in #{triggers[t][0]})")
      else
        triggers[t] = [f, m["word"] == true]
      end
    end
  end
end

# --- 4: prefix overlap ------------------------------------------------------------
sorted = triggers.keys.sort
sorted.each do |short|
  longer = sorted.select { |t| t != short && t.start_with?(short) }
  next if longer.empty? || triggers[short][1]
  err.call("#{triggers[short][0]}: #{short} is a prefix of #{longer.first(3).join(', ')}" \
           "#{longer.size > 3 ? ' …' : ''}; add `word: true` to #{short} or rename it")
end

# --- 5: README coverage -----------------------------------------------------------
readme = File.exist?("README.md") ? File.read("README.md") : ""
readme_triggers = readme.scan(/`(:[A-Za-z0-9_-]+)`/).flatten.uniq
(triggers.keys - readme_triggers).sort.each do |t|
  err.call("README.md: trigger #{t} (#{triggers[t][0]}) is missing from the Quick Reference")
end
(readme_triggers - triggers.keys).sort.each do |t|
  err.call("README.md: lists #{t}, which no match file defines")
end

# --- 6: imports and shared vars ---------------------------------------------------
docs.each do |f, doc|
  imports = Array(doc["imports"])
  imports.each { |i| err.call("#{f}: imports missing file #{i}") unless File.exist?(i) }
  next if f == SHARED
  used = File.read(f).scan(/\{\{(\w+)\}\}/).flatten.uniq & shared_vars
  next if used.empty? || imports.include?(SHARED)
  err.call("#{f}: uses #{used.join(', ')} from #{SHARED} but doesn't import it")
end

# --- 7: leaked emails / public IPs ------------------------------------------------
files.each do |f|
  File.foreach(f).with_index(1) do |line, n|
    next if line.include?("secret-scan:allow")
    line.scan(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/).each do |e|
      err.call("#{f}:#{n}: email #{e} isn't a placeholder domain") unless e =~ EMAIL_OK
    end
    line.scan(/(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?![\d.])/).each do |ip|
      addr = (IPAddr.new(ip) rescue nil)
      next if addr.nil? || IP_OK.any? { |r| r.include?(addr) }
      err.call("#{f}:#{n}: public IP #{ip}; use a private or documentation range (192.0.2.0/24)")
    end
  end
end

# --- 8: clipboard commands --------------------------------------------------------
CLIP_CASES = {
  ":defip"    => [["192.168.1.10", "192[.]168[.]1[.]10"],
                  ["192[.]168[.]1[.]10", "192[.]168[.]1[.]10"]],
  ":defurl"   => [["http://1.2.3.4/x", "hxxp://1[.]2[.]3[.]4/x"],
                  ["https://evil.example.com/http-path/a.exe", "hxxps://evil[.]example[.]com/http-path/a[.]exe"],
                  ["hxxps://evil[.]example[.]com", "hxxps://evil[.]example[.]com"],
                  ["ftp://files.example.org/a.zip", "fxp://files[.]example[.]org/a[.]zip"]],
  ":defemail" => [["first.last@mail.example.com", "first[.]last[at]mail[.]example[.]com"],
                  ["user[at]example[.]com", "user[at]example[.]com"]],
  ":refang"   => [["hxxps://evil[.]example[.]com/a[.]exe", "https://evil.example.com/a.exe"],
                  ["evil(.)example[dot]com user[at]example[.]com fxp://x[.]org", "evil.example.com user@example.com ftp://x.org"]],
}.freeze

clip_cmds = {}
docs.each_value do |doc|
  Array(doc["matches"]).each do |m|
    Array(m["vars"]).each do |v|
      cmd = v.dig("params", "cmd").to_s
      clip_cmds[m["trigger"]] = cmd if cmd.start_with?("pbpaste")
    end
  end
end
CLIP_CASES.each do |trig, cases|
  cmd = clip_cmds[trig]
  if cmd.nil?
    err.call("#{trig}: no pbpaste-based cmd found to test")
    next
  end
  cases.each do |input, want|
    got, status = Open3.capture2({ "CLIP" => input }, "sh", "-c",
                                 cmd.sub("pbpaste", 'printf "%s\n" "$CLIP"'))
    got = got.chomp
    next if status.success? && got == want
    err.call("#{trig}: #{input.inspect} gave #{got.inspect}, expected #{want.inspect}")
  end
end

# --- report -----------------------------------------------------------------------
if errors.empty?
  puts "ok: #{files.size} files, #{triggers.size} triggers"
else
  puts errors
  puts "\n#{errors.size} problem(s)"
  exit 1
end
