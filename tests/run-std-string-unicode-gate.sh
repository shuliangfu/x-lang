#!/usr/bin/env bash
# STD-160: std.string Unicode bridge — honesty leftover wrap dead source →硬绿.
#
# Honesty: leftover bootstrap-link wrap sourced unused (no RUN_XLANG) + unused
# compiler-make.sh retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover wrap dead
# source / unused compiler-make / soft SKIP→OK / prefer-c). Product
# unicode_bridge.x -o exit0 = hard run (run=1). check = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh. PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-string-unicode-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

MOD_X="std/string/mod.x"
SMOKE="tests/string/unicode_bridge.x"
PREFIX="xlang: [XLANG_STD160_STRING_UNICODE]"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-string-unicode gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

resolve_shu() {
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== STD-160: string-unicode manifest ==="
# Refuse resurrected top-level DOC if ever archived later.
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-string-unicode-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$MOD_X" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
# Product surface anchors (drop fossil unicode_case_fold_buf_c).
# PLATFORM: SHARED — API authenticity; gate must match live export names.
for sym in string_view_case_fold string_view_is_valid_utf8; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "missing api $sym"
done
echo "std-string-unicode manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-160: smoke (XLANG=$XLANG_BIN; check obs; unicode_bridge product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std160_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-string-unicode OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse leftover wrap dead source / unused compiler-make.sh
# (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

exe="/tmp/xlang_std160_string_unicode_$$"
LOG="/tmp/xlang_std160_string_unicode_build_$$.log"
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  echo "std-string-unicode FAIL: compile $SMOKE" >&2
  tail -20 "$LOG" 2>/dev/null >&2 || true
  rm -f "$exe"
  die "unicode_bridge.x compile failed (refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
ec=$?
set -e
rm -f "$exe" "$LOG"
[ "$ec" -eq 0 ] || die "unicode_bridge.x exit=$ec (refuse soft SKIP→OK)"
RUN_OK=$((RUN_OK + 1))
echo "std-string-unicode OK: unicode_bridge"

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
echo "std-string-unicode gate OK"
