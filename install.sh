#!/usr/bin/env bash
# install.sh — install these match files into Espanso's match folder (macOS / Linux).
#
#   ./install.sh               copy the files (re-run after pulling to update)
#   ./install.sh --link        symlink them, so edits in this repo apply straight away
#   ./install.sh --dry-run     show what would happen, change nothing
#   ./install.sh --dir DIR     install into DIR instead of Espanso's own match folder
#   ./install.sh --no-restart  don't restart Espanso afterwards
#
# shared-vars.yml holds your personal values (name, phone, email), so it is always
# copied, never symlinked (that would put your details in the repo), and an existing
# one is never overwritten. Any other file already in the way is backed up as
# <name>.yml.bak-<timestamp>, which Espanso ignores because it doesn't end in .yml.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="copy"
dry_run=0
restart=1
dest=""

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --link) mode="link" ;;
    --dry-run) dry_run=1 ;;
    --no-restart) restart=0 ;;
    --dir)
      [ $# -ge 2 ] || { echo "--dir needs a folder" >&2; exit 2; }
      dest="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$dest" ]; then
  if ! command -v espanso >/dev/null 2>&1; then
    echo "espanso isn't on PATH. Install it (https://espanso.org) or pass --dir." >&2
    exit 1
  fi
  dest="$(espanso path config)/match"
fi

run() {
  if [ "$dry_run" -eq 1 ]; then
    printf 'would run:'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

[ -d "$dest" ] || run mkdir -p "$dest"
echo "Installing into: $dest ($mode)"

stamp="$(date +%Y%m%d-%H%M%S)"
installed=0
for src in "$repo"/*.yml; do
  name="$(basename "$src")"
  target="$dest/$name"

  if [ "$name" = "shared-vars.yml" ]; then
    if [ -e "$target" ]; then
      echo "  keep    $name (already there; your personal values are left alone)"
    else
      echo "  copy    $name (fill in your details in the installed copy, not in the repo)"
      run cp "$src" "$target"
      installed=$((installed + 1))
    fi
    continue
  fi

  # Already installed the same way: nothing to do.
  if [ "$mode" = link ] && [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
    echo "  ok      $name"
    continue
  fi
  if [ "$mode" = copy ] && [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$src" "$target"; then
    echo "  ok      $name"
    continue
  fi

  # Something else is in the way: back it up. A link of ours, or an identical copy
  # (switching between copy and link mode), is just replaced.
  if [ -e "$target" ] || [ -L "$target" ]; then
    if { [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; } ||
       { [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$src" "$target"; }; then
      run rm "$target"
    else
      echo "  backup  $name -> $name.bak-$stamp"
      run mv "$target" "$target.bak-$stamp"
    fi
  fi

  if [ "$mode" = link ]; then
    echo "  link    $name"
    run ln -s "$src" "$target"
  else
    echo "  copy    $name"
    run cp "$src" "$target"
  fi
  installed=$((installed + 1))
done

echo "Done: $installed file(s) installed or updated."

if [ "$restart" -eq 1 ] && command -v espanso >/dev/null 2>&1; then
  if espanso status 2>/dev/null | grep -q "^espanso is running"; then
    run espanso restart
  else
    echo "Espanso isn't running; start it with: espanso start"
  fi
fi
