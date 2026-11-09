# Changelog

All notable changes to Espanso are listed here, newest first.

The project has no tagged releases yet, so changes are grouped by date. Entries before November 2026 were reconstructed from the commit history.

## Unreleased

- Fix `:utc` and `:iso` printing local time labelled as UTC/`Z`; they now use Espanso's `tz: "UTC"` (needs Espanso 2.3.0+)
- Fix the clipboard defang commands: `:defurl` now defangs IP-based URLs and `ftp://`, only rewrites the `http(s)://` scheme (not "http" inside paths), and `:defip`/`:defurl`/`:defemail` no longer double-bracket text that's already defanged
- Add `:refang`, which undoes `[.]`, `(.)`, `[dot]`, `[at]`, `hxxp` and `fxp` from the clipboard
- Replace `:mdeisolate` and `:mdelive`, which used Graph PowerShell cmdlets that don't exist, with calls to the Defender for Endpoint REST API; add `:mdeunisolate`
- Add `check.rb` (YAML, unique triggers, prefix overlaps, README coverage, imports, leaked emails/IPs, defang command tests) and a CI workflow that runs it plus ShellCheck
- Add `install.sh` (copy or `--link`, `--dry-run`, backs up files in the way, never overwrites or links `shared-vars.yml`)

- Fix short triggers blocking longer ones: `:d`, `:date`, `:iso`, `:time`, `:timeline`, `:sig` and `:sev` are now word triggers (type a space or punctuation after them), so `:date`, `:defip`, `:dateiso`, `:timewindow`, `:sigir` etc. can be typed again
- `:genpw` and `:uuid` now work on macOS/Linux by default (`/dev/urandom`, `uuidgen`); the PowerShell versions are kept as comments for Windows
- Fix the install paths: macOS uses `~/Library/Application Support/espanso/match/`, the stray trailing backslashes are gone, and `espanso path` is mentioned for checking
- CLAUDE.md: a YAML validation command that works without PyYAML, and a rule against prefix-overlapping triggers

## 2026-11-02

- Add security policy

## 2026-11-01

- Ignore macOS, Claude Code and secret files
- Add CLAUDE.md with project guidance for Claude Code

## 2026-09-03

- Initial commit: Espanso security/IR toolkit
