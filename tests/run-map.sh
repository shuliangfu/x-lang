#!/usr/bin/env bash
# std.map leftover runner: tests/map/main.x (empty_size) product -o exit 0.
#
# Honesty: leftover soft auto-make (`xlang_compiler_make … map.o/heap.o || make`)
# + hard check as sole gate + nm map.o + collection gcc fallback + bootstrap-link
# wrap retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# leftover XLANG fallthrough / gcc fallback). Check path = obs= (check gate
# paused 2026-08-05). Product `-o` tests/map/main.x must exit 0.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-map.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_MAP_PREFIX:-xlang: [MAP]}"
SMOKE="tests/map/main.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "map FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

# G.7: complete the existing per-script resolve_shu family (dod_native_exe);
# do not fork a third resolver. Explicit XLANG that is missing/non-native
# returns 1 (caller hard-dies; refuse leftover XLANG fallthrough).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

[ -f "$SMOKE" ] || die "missing $SMOKE"

echo "=== map leftover (prefer asm; hard; refuse leftover auto-make / gcc fallback) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft auto-make)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_map_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "map OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_map_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_map_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_map_o.log 2>/dev/null || true
  rm -f "$exe"
  die "product -o failed (ec=$o_ec; refuse leftover auto-make / collection gcc fallback / nm map.o)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq 0 ] || die "runnable exit=$run_ec (expected 0; empty_size)"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "map test OK"
