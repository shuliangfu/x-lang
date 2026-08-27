#!/usr/bin/env bash
# B-14 v1: Linux freestanding syscall invoke (read/close/exit/write) smoke.
#
# Honesty: soft XLANG_LINUX_SYSCALL_INVOKE_FAIL retired — compile/run failure
# was portable false-green (soft die→exit0). Prefer xlang_asm; pin
# XLANG_LINK_XLANG. Missing compiler is hard die (refuse soft SKIP→OK).
#
# Usage: ./tests/run-linux-syscall-invoke-gate.sh
# Report: run=/skip=
# PLATFORM: LINUX|UBUNTU gold for run; SHARED N/A elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/linux_syscall_invoke_smoke.x"
OUT="/tmp/xlang_linux_syscall_invoke.$$.out"
PREFIX="xlang: [XLANG_LINUX_SYSCALL_INVOKE]"
RUN_OK=0
SKIP=1

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "linux-syscall-invoke-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

if ! ci_is_linux; then
  echo "linux-syscall-invoke-gate: N/A (Linux freestanding only)"
  echo "${PREFIX} status=ok run=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

[ -f "$X" ] || die "missing $X"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== linux-syscall-invoke (XLANG=$XLANG_BIN; hard) ==="
rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG_BIN" -freestanding -backend asm -o "$OUT" "$X" 2>/tmp/xlang_linux_syscall_invoke.log; then
  tail -n 10 /tmp/xlang_linux_syscall_invoke.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  die "compile $X"
fi
[ -x "$OUT" ] || die "no executable $OUT"

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true
[ "$rc" -eq 0 ] || die "expected exit 0, got $rc"

RUN_OK=1
SKIP=0
echo "linux-syscall-invoke-gate OK (Linux freestanding xlang_sys_read/write; honesty)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
