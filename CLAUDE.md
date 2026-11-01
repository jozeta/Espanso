# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A collection of [Espanso](https://espanso.org/) text-expander match files for blue team
(SOC/IR/DFIR), red team/pentest and everyday productivity. There's no code: every file is
Espanso YAML, installed by copying all `.yml` files into the Espanso match directory
(`~/.config/espanso/match/` on macOS/Linux, `%APPDATA%\espanso\match\` on Windows).

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
- Keep the generic `[Placeholder]` values in `shared-vars.yml`. Never commit real names,
  emails, phone numbers or internal URLs.
- Shell-backed matches (`:defip`, `:defurl`, `:defemail`, `:genpw`, `:uuid`) have per-OS `cmd`
  lines (pbpaste/xclip/PowerShell); keep the alternatives as comments.
- `pentest.yml` and `wireless-mobile.yml` are for authorized testing only; keep `TARGET` /
  `ATTACKER_IP` placeholders and never embed real targets.
- When adding or renaming a trigger, update the README Quick Reference table.

## Checking changes

Validate YAML before committing, for example
`python3 -c "import yaml,glob;[yaml.safe_load(open(f)) for f in glob.glob('*.yml')]"`, then with
Espanso installed run `espanso restart` and `espanso log` to catch load errors.
