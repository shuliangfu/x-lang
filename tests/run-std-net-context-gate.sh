#!/usr/bin/env bash
# STD-092: std.net ↔ std.context connect gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft ensure_std_c_o / soft auto-make + check=/run=/skip= retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft ensure).
# Product context_connect.x -o exit0 = hard run (run=1). check = obs. Existing
# glue .o may be passed if present (no soft rebuild). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-net-context-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

MOD_X="std/net/mod.x"
SMOKE="tests/net/context_connect.x"
PREFIX="xlang: [XLANG_STD092_NET_CTX]"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "net-context gate FAIL: $*" >&2
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

echo "=== STD-092: net-context manifest ==="
for f in "$MOD_X" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
for sym in connect_ctx_fd accept_ctx_fd connect_ipv6_ctx_fd read_ctx write_ctx; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "missing api $sym"
done
grep -qF 'function net_err_timeout()' std/error/mod.x 2>/dev/null || die "missing net_err_timeout in std.error"
grep -qF 'function net_err_cancelled()' std/error/mod.x 2>/dev/null || die "missing net_err_cancelled in std.error"
echo "net-context manifest OK"

if [ "${XLANG_STD_NET_CONTEXT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  echo "std-net-context gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-092: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std092_net_ctx_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "net-context OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft ensure_std_c_o / soft auto-make. Product -o is the hard path.
# Existing glue .o archaeology is observational only (never soft rebuild).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for o in compiler/runtime_atomic_glue.o compiler/runtime_time_os.o; do
  if [ ! -f "$o" ]; then
    echo "net-context OBS missing glue $o (no soft ensure; product -o still hard)" >&2
    OBS=$((OBS + 1))
  fi
done

exe="/tmp/xlang_std092_net_ctx_$$"
log="/tmp/xlang_std092_net_ctx_$$.log"
rm -f "$exe" "$log"
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  echo "net-context FAIL: compile $SMOKE" >&2
  tail -n 20 "$log" 2>/dev/null >&2 || true
  rm -f "$exe" "$log"
  die "product -o failed (refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
ec=$?
set -e
rm -f "$exe" "$log"
[ "$ec" -eq 0 ] || die "run exit=$ec (refuse soft SKIP→OK)"
RUN_OK=$((RUN_OK + 1))
echo "net-context OK: product -o"

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
echo "std-net-context gate OK"
