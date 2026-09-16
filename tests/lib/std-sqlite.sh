#!/usr/bin/env bash
# std-sqlite.sh — STD-010 prereq helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_sqlite_has_api MOD_X FN
#   std_sqlite_resolve_shu
#   std_sqlite_run_smoke / std_sqlite_emit_report  (G.7: parent std-sqlite-gate.sh)
# Honesty: refuse soft auto-make / soft SKIP→OK / prefer-c; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# shellcheck source=tests/lib/dod-native-exe.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/dod-native-exe.sh"
# G.7: product -o + report live in STD-057 lib; do not fork a second run_smoke.
# shellcheck source=tests/lib/std-sqlite-gate.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/std-sqlite-gate.sh"

# Check mod.x exports the named function (live surface, not fossil aliases).
std_sqlite_has_api() {
  local mod="$1"
  local fn="$2"
  grep -qE "function ${fn}\\(" "$mod" 2>/dev/null
}

# Prefer product asm; refuse prefer-c / soft auto-make / soft SKIP→OK.
# Explicit XLANG that is missing or non-native returns 1 (caller hard-dies).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_sqlite_resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}
