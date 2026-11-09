# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A collection of [Espanso](https://espanso.org/) text-expander match files for blue team
(SOC/IR/DFIR), red team/pentest and everyday productivity. There's no code: every file is
Espanso YAML, installed by copying all `.yml` files into the Espanso match directory
(`~/Library/Application Support/espanso/match/` on macOS, `~/.config/espanso/match/` on Linux,
`%APPDATA%\espanso\match\` on Windows; `espanso path` shows the config folder).

## Layout

One topic per file (`timestamps.yml`, `ioc.yml`, `incidents.yml`, `signatures.yml`, `cli.yml`,
`cloud.yml`, `network.yml`, `kubernetes.yml`, `secrets.yml`, `encoding.yml`, `vulnmgmt.yml`,
`compliance.yml`, `pentest.yml`, `wireless-mobile.yml`, `forensics.yml`, `ctf.yml`,
`nice-to-have.yml`). The README "Files" table and "Quick Reference" list every trigger.

`shared-vars.yml` has no `matches:`; it only defines `global_vars` (org name, analyst
name/title/email/phone, SOC phone, legal contact, MISP URL, ticket prefix). Files that use them
start with `imports: ["shared-vars.yml"]` and reference `{{org_name}}` etc.

## Conventions

- **Every trigger starts with `:`** so it can't expand mid-word. Triggers must be unique across
  all files: Espanso loads them together, so grep all files before adding one.
- **No trigger may be a prefix of another** unless the shorter one has `word: true`; Espanso
  expands as soon as a trigger matches, so `:d` would otherwise fire before `:date` is typed.
- Keep the generic `[Placeholder]` values in `shared-vars.yml`. Never commit real names,
  emails, phone numbers or internal URLs.
- Shell-backed matches (`:defip`, `:defurl`, `:defemail`, `:genpw`, `:uuid`) have per-OS `cmd`
  lines (pbpaste/xclip/PowerShell). The active line is the macOS one; keep the alternatives as
  comments.
- `pentest.yml` and `wireless-mobile.yml` are for authorized testing only; keep `TARGET` /
  `ATTACKER_IP` placeholders and never embed real targets.
- When adding or renaming a trigger, update the README Quick Reference table.

## Checking changes

Validate YAML before committing. PyYAML isn't installed on this machine; the system Ruby works:
`ruby -ryaml -e 'Dir["*.yml"].each{|f| YAML.safe_load(File.read(f))}; puts "ok"'`
(or `python3 -c "import yaml,glob;[yaml.safe_load(open(f)) for f in glob.glob('*.yml')]"` where
PyYAML is available). Then with Espanso installed run `espanso restart` and `espanso log` to catch
load errors.

## App standards

This repo follows the app standards in `~/Desktop/code/tools/standards/STANDARDS.md` (rule IDs,
severities; decisions and waivers in `.claude-standards`). `claude-check --repo .` checks it.
