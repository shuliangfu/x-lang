#!/usr/bin/env bash
# SAFE-007：崩溃证据包回归 runner
#
# 用法：SHU_CRASH_EVIDENCE=1 ./tests/run-safe-crash-evidence.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/safe-crash.sh
. tests/lib/safe-crash.sh
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh

OUT_DIR="${SHU_CRASH_EVIDENCE_DIR:-/tmp/shu_crash_evidence_$$}"
mkdir -p "$OUT_DIR"
export SHU_CRASH_EVIDENCE="${SHU_CRASH_EVIDENCE:-1}"
export SHU_CRASH_EVIDENCE_DIR="$OUT_DIR"

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

SHU_BIN="${SHU:-./compiler/shu}"
if ! native_shu "$SHU_BIN"; then
  echo "safe-crash-evidence SKIP: no native shu"
  safe_crash_emit_report skip "" 0
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/backtrace/backtrace.o
make -C compiler runtime_panic.o -q 2>/dev/null || make -C compiler runtime_panic.o

echo "=== SAFE-007: manual evidence ==="
EXE="/tmp/shu_crash_manual_$$"
LOG="/tmp/shu_crash_manual_$$.log"
if ! "$SHU_BIN" -L . tests/crash/evidence_manual.su -o "$EXE" >/dev/null 2>&1; then
  echo "safe-crash-evidence FAIL: compile evidence_manual" >&2
  exit 1
fi
"$EXE" 2>"$LOG" || true
if ! safe_crash_grep_evidence "$LOG"; then
  cat "$LOG" >&2
  echo "safe-crash-evidence FAIL: missing SHU_CRASH_EVIDENCE in manual run" >&2
  exit 1
fi
BUNDLE=$(grep -F 'bundle=' "$LOG" 2>/dev/null | tail -1 | sed 's/.*bundle=//')
if [ -n "$BUNDLE" ] && [ ! -f "$BUNDLE" ]; then
  echo "safe-crash-evidence FAIL: bundle file missing $BUNDLE" >&2
  exit 1
fi
echo "safe-crash-evidence manual OK"

echo "=== SAFE-007: panic evidence (div_zero) ==="
PLOG="/tmp/shu_crash_panic_$$.log"
PEX="/tmp/shu_crash_panic_$$"
if ! "$SHU_BIN" -L . tests/ub/div_zero.su -o "$PEX" >/dev/null 2>&1; then
  echo "safe-crash-evidence FAIL: compile div_zero" >&2
  exit 1
fi
set +e
"$PEX" 2>"$PLOG"
PR=$?
set -e
if ! safe_crash_grep_evidence "$PLOG"; then
  cat "$PLOG" >&2
  echo "safe-crash-evidence FAIL: panic path missing SHU_CRASH_EVIDENCE (rc=$PR)" >&2
  exit 1
fi
echo "safe-crash-evidence panic OK (rc=$PR)"

FRAMES=$(grep -F 'frames=' "$PLOG" 2>/dev/null | head -1 | sed -n 's/.*frames=\([0-9]*\).*/\1/p')
safe_crash_emit_report ok "${BUNDLE:-}" "${FRAMES:-0}"
echo "safe-crash-evidence OK"
