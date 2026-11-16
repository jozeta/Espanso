#!/usr/bin/env bash
# Runs the whole test suite: the match-file validator (check.rb) and the installer tests.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(dirname "$here")"
fail=0

echo "== check.rb (match files: YAML, triggers, README, placeholders, defang commands)"
ruby "$repo/check.rb" || fail=1

echo "== install.test.sh (install.sh in a temp dir; the real Espanso folder is never touched)"
bash "$here/install.test.sh" || fail=1

if [ "$fail" -ne 0 ]; then echo "FAILED"; exit 1; fi
echo "All tests passed."
