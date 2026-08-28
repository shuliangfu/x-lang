#!/usr/bin/env bash
# TOOL-005: -O 0 debug build symtab + not-stripped smoke (exit 42)
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft bootstrap-link). Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh
# shellcheck source=tests/lib/tool-debug-symbols.sh
. tests/lib/tool-debug-symbols.sh

PREFIX="${XLANG_DEBUG_SYMBOLS_PREFIX:-xlang: [DEBUG-SYMBOLS]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "debug-symbols FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== debug-symbols gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

src="tests/debug/symbols_marker.x"
[ -f "$src" ] || die "missing $src"
exe="/tmp/xlang_debug_symbols_$$"
log="/tmp/xlang_debug_symbols_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -O 0 -L . "$src" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "symbols_marker product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "symbols_marker product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi

tool_dbg_exe_has_sym "$exe" main || die "missing symbol main"
tool_dbg_exe_not_stripped "$exe" || die "expected not stripped"
RUN_OK=$((RUN_OK + 1))

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe" "$log"
if [ "$r_ec" -eq 124 ]; then
  die "symbols_marker run timeout"
elif [ "$r_ec" -ne 42 ]; then
  die "symbols_marker expected exit 42, got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))

echo "tool-debug-symbols report sym=main stripped=no o0=OK"
ok_report
echo "debug-symbols OK"
