#!/usr/bin/env bash
# SYNC-CAP-RAW gate: Stage 10 (10.6.3) Linux futex mutex/condvar Cap.
# Host-cc compile+run tests/sys/sync_cap_raw_smoke.c against xlang_sync_cap.h.
# No libpthread. Darwin N/A (skip=1).
#
# Usage: ./tests/run-sync-cap-raw-gate.sh
# PLATFORM: LINUX|UBUNTU gold; SHARED harness skip elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

PREFIX="${XLANG_SYNC_CAP_RAW_PREFIX:-xlang: [XLANG_SYNC_CAP_RAW]}"
RUN_OK=0
OBS=0
SKIP=0
SMOKE_SRC="tests/sys/sync_cap_raw_smoke.c"
SMOKE_EXE="/tmp/xlang_sync_cap_raw_smoke.$$"
HEADER="compiler/include/xlang_sync_cap.h"

die() {
  echo "sync-cap-raw gate FAIL: $*" >&2
  rm -f "$SMOKE_EXE" 2>/dev/null || true
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  rm -f "$SMOKE_EXE" 2>/dev/null || true
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== SYNC-CAP-RAW: futex mutex/condvar Cap (10.6.3) ==="

if ! ci_is_linux; then
  SKIP=1
  echo "sync-cap-raw: N/A (Linux Cap only)"
  ok_report
  exit 0
fi

[ -f "$SMOKE_SRC" ] || die "missing $SMOKE_SRC"
[ -f "$HEADER" ] || die "missing $HEADER"
[ -f "compiler/include/xlang_thread_cap.h" ] || die "missing xlang_thread_cap.h"

CC_BIN="${CC:-cc}"
rm -f "$SMOKE_EXE"
if ! "$CC_BIN" -O0 -Wall -Wextra -Icompiler/include -o "$SMOKE_EXE" "$SMOKE_SRC" 2>/tmp/xlang_sync_cap_raw_cc.err; then
  cat /tmp/xlang_sync_cap_raw_cc.err >&2 || true
  die "host-cc compile failed"
fi
[ -x "$SMOKE_EXE" ] || die "missing exe $SMOKE_EXE"

if command -v nm >/dev/null 2>&1; then
  if nm -u "$SMOKE_EXE" 2>/dev/null | grep -E 'pthread_' >/dev/null 2>&1; then
    nm -u "$SMOKE_EXE" 2>/dev/null | grep -E 'pthread_' >&2 || true
    die "unexpected pthread UNDEF in Cap smoke"
  fi
fi

if ! "$SMOKE_EXE"; then
  die "smoke exit nonzero"
fi
RUN_OK=$((RUN_OK + 1))

ok_report
