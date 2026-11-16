# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A collection of [Espanso](https://espanso.org/) text-expander match files for blue team
(SOC/IR/DFIR), red team/pentest and everyday productivity. The content is Espanso YAML; the only
code is `check.rb` (validation, run in CI) and `install.sh` (installer). The `.yml` files are
installed by `./install.sh`, or by copying them into the Espanso match directory
(`~/Library/Application Support/espanso/match/` on macOS, `~/.config/espanso/match/` on Linux,
`%APPDATA%\espanso\match\` on Windows; `espanso path` shows the config folder).

## Layout

One topic per file (`timestamps.yml`, `ioc.yml`, `incidents.yml`, `signatures.yml`, `cli.yml`,
`cloud.yml`, `network.yml`, `kubernetes.yml`, `secrets.yml`, `encoding.yml`, `vulnmgmt.yml`,
`compliance.yml`, `pentest.yml`, `wireless-mobile.yml`, `forensics.yml`, `ctf.yml`,
`detection.yml`, `email.yml`, `swedish.yml`, `nice-to-have.yml`). The README "Files" table and "Quick Reference" list every trigger.

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
- `swedish.yml` mirrors English templates (named in each entry's comment, e.g. `:svsig` ↔ `:sig`);
  when one side changes, update the other.
- When adding or renaming a trigger, update the README Quick Reference table (`check.rb` fails
  otherwise).
- Date variables that claim UTC must set `tz: "UTC"` (Espanso >= 2.3.0); without it Espanso
  formats local time.
- Keep `shared-vars.yml` copied, never symlinked, by `install.sh`, so personal values can't end
  up in the repo.

## Checking changes

Run `bash tests/run-all.sh` (check.rb plus the installer tests in `tests/`) before committing (plain Ruby, no gems; PyYAML isn't installed here). It
checks that every file parses, triggers start with `:` and are unique, no trigger is an unguarded
prefix of another, the README lists exactly the defined triggers, imports resolve, no real-looking
emails or public IPs slipped into templates, and the clipboard defang/refang commands give the
expected output. CI (`.github/workflows/ci.yml`) runs the suite on Ubuntu (GNU sed) plus ShellCheck on
`install.sh` and the test scripts. When you add a clipboard command or change one, add a case to `CLIP_CASES` in
`check.rb`. To try matches in Espanso, `./install.sh --link`, then `espanso restart` and
`espanso log` to catch load errors.

## App standards

This repo follows the app standards in `~/Desktop/code/tools/standards/STANDARDS.md` (rule IDs,
severities; decisions and waivers in `.claude-standards`). `claude-check --repo .` checks it.
