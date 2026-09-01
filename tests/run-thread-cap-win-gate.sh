#!/usr/bin/env bash
# THREAD-CAP-WIN gate: Stage 10 (10.6.2) Windows CreateThread Cap spawn/join.
# Host-cc compile+run tests/sys/thread_cap_win_smoke.c against xlang_thread_cap.h.
# Linux/Darwin N/A (skip=1). Optional mingw cross-compile = obs when present.
#
# Usage: ./tests/run-thread-cap-win-gate.sh
# PLATFORM: WINDOWS gold when host is Win; SHARED harness skip elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="${XLANG_THREAD_CAP_WIN_PREFIX:-xlang: [XLANG_THREAD_CAP_WIN]}"
RUN_OK=0
OBS=0
SKIP=0
SMOKE_SRC="tests/sys/thread_cap_win_smoke.c"
SMOKE_EXE="/tmp/xlang_thread_cap_win_smoke.$$"
HEADER="compiler/include/xlang_thread_cap.h"

die() {
  echo "thread-cap-win gate FAIL: $*" >&2
  rm -f "$SMOKE_EXE" 2>/dev/null || true
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  rm -f "$SMOKE_EXE" 2>/dev/null || true
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== THREAD-CAP-WIN: CreateThread Cap spawn/join (10.6.2) ==="

[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"
[ -f "$HEADER" ] || die "missing $HEADER"

# Native Windows host: compile+run.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    CC_BIN="${CC:-cc}"
    rm -f "$SMOKE_EXE"
    if ! "$CC_BIN" -O0 -Wall -Wextra -Icompiler/include -o "$SMOKE_EXE" "$SMOKE_SRC" \
      2>/tmp/xlang_thread_cap_win_cc.err; then
      cat /tmp/xlang_thread_cap_win_cc.err >&2 || true
      die "host-cc compile failed"
    fi
    [ -x "$SMOKE_EXE" ] || die "missing exe $SMOKE_EXE"
    if ! "$SMOKE_EXE"; then
      die "smoke exit nonzero"
    fi
    RUN_OK=$((RUN_OK + 1))
    ok_report
    exit 0
    ;;
esac

# Optional mingw cross-compile (no run without wine) — obs only.
if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
  CROSS_EXE="/tmp/xlang_thread_cap_win_cross.$$.exe"
  if x86_64-w64-mingw32-gcc -O0 -Wall -Wextra -Icompiler/include -o "$CROSS_EXE" "$SMOKE_SRC" \
    2>/tmp/xlang_thread_cap_win_mingw.err; then
    OBS=$((OBS + 1))
    echo "thread-cap-win: mingw cross-compile OK (obs; no Win run host)"
    rm -f "$CROSS_EXE"
  else
    cat /tmp/xlang_thread_cap_win_mingw.err >&2 || true
    die "mingw cross-compile failed"
  fi
  ok_report
  exit 0
fi

SKIP=1
echo "thread-cap-win: N/A (Windows Cap; no Win host / mingw)"
ok_report
exit 0
