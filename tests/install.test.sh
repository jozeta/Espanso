#!/usr/bin/env bash
# Tests for install.sh. Everything installs into a temp dir via --dir, with --no-restart and a
# PATH that has no espanso, so the real Espanso folder is never read or written.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(dirname "$here")"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
pass=0; failed=0

ok()   { pass=$((pass + 1)); echo "  ok   $1"; }
bad()  { failed=$((failed + 1)); echo "  FAIL $1"; }
check() { # check <name> <command...>
  local name=$1; shift
  if "$@"; then ok "$name"; else bad "$name"; fi
}
inst() { PATH="/usr/bin:/bin" "$repo/install.sh" --no-restart "$@"; }
count() { echo "$#"; }   # count <glob...>
nfiles=$(count "$repo"/*.yml)

# --version prints VERSION
check "--version prints VERSION" test "$(inst --version)" = "$(cat "$repo/VERSION")"

# unknown option and missing --dir argument fail with status 2
inst --bogus >/dev/null 2>&1; check "unknown option exits 2" test $? -eq 2
inst --dir >/dev/null 2>&1; check "--dir without a folder exits 2" test $? -eq 2

# no espanso and no --dir: refuses instead of guessing a folder
PATH="/usr/bin:/bin" "$repo/install.sh" --no-restart >/dev/null 2>&1
check "no espanso and no --dir exits 1" test $? -eq 1

# --dry-run changes nothing, even when the folder does not exist yet
d1="$tmp/dry/match"
out="$(inst --dry-run --dir "$d1")"
check "--dry-run creates nothing" test ! -e "$d1"
check "--dry-run lists what it would do" grep -q "would run: cp" <<<"$out"

# copy install
d2="$tmp/copy"; mkdir "$d2"
inst --dir "$d2" >/dev/null
check "copy installs every .yml" test "$(count "$d2"/*.yml)" -eq "$nfiles"
check "copied file matches the repo" cmp -s "$repo/ioc.yml" "$d2/ioc.yml"
check "copied files are not symlinks" test ! -L "$d2/ioc.yml"

# re-run: idempotent, personal shared-vars.yml is never overwritten
echo "# my personal values" >> "$d2/shared-vars.yml"
out="$(inst --dir "$d2")"
check "re-run installs nothing new" grep -q "Done: 0 file" <<<"$out"
check "shared-vars.yml is left alone" grep -q "my personal values" "$d2/shared-vars.yml"

# a different file in the way is backed up, not lost
echo "# local edit" > "$d2/ioc.yml"
inst --dir "$d2" >/dev/null
check "changed file is restored from the repo" cmp -s "$repo/ioc.yml" "$d2/ioc.yml"
check "changed file is backed up" test "$(count "$d2"/ioc.yml.bak-*)" -eq 1

# link install: symlinks, except shared-vars.yml which is always a copy
d3="$tmp/link"; mkdir "$d3"
inst --link --dir "$d3" >/dev/null
check "--link symlinks match files" test -L "$d3/ioc.yml"
check "--link points into the repo" test "$(readlink "$d3/ioc.yml")" = "$repo/ioc.yml"
check "--link still copies shared-vars.yml" test -f "$d3/shared-vars.yml" -a ! -L "$d3/shared-vars.yml"

echo "install.sh: $pass passed, $failed failed"
[ "$failed" -eq 0 ]
