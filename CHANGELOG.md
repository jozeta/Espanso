# Changelog

All notable changes to Espanso are listed here, newest first.

The project has no tagged releases yet, so changes are grouped by date. Entries before November 2026 were reconstructed from the commit history.

## Unreleased

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
