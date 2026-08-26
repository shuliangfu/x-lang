#!/usr/bin/env bash
# F-phase std de-C batch: path/uuid/…/socketio v1–v2 archaeology aggregate.
#
# Usage: ./tests/run-f-std-de-c-batch-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-std-de-c-batch-gate.sh
# 2026-08-26: Honesty — hard-fail when any child RC≠0 (no soft die→exit0).
# Soft XLANG_F_STD_DE_C_BATCH_FAIL retired. Root: soft batch swallowed syntax-
# broken children (orphan Makefile die/fi) → portable false-green. Prefer asm;
# pin XLANG_LINK_XLANG. Report ok=/fail=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

GATES=(
  run-f-path-v1-gate.sh
  run-f-uuid-v1-gate.sh
  run-f-sort-v1-gate.sh
  run-f-process-v1-gate.sh
  run-f-random-v1-gate.sh
  run-f-time-v1-gate.sh
  run-f-math-v1-gate.sh
  run-f-base64-v1-gate.sh
  run-f-string-v1-gate.sh
  run-f-encoding-v1-gate.sh
  run-f-runtime-v1-gate.sh
  run-f-ffi-v1-gate.sh
  run-f-cli-v1-gate.sh
  run-f-env-v1-gate.sh
  run-f-log-v1-gate.sh
  run-f-simd-v1-gate.sh
  run-f-security-v1-gate.sh
  run-f-context-v1-gate.sh
  run-f-context-v2-gate.sh
  run-f-trace-v1-gate.sh
  run-f-trace-v2-gate.sh
  run-f-sync-v1-gate.sh
  run-f-sync-lock-diag-v2-gate.sh
  run-f-task-v1-gate.sh
  run-f-task-v2-gate.sh
  run-f-csv-v1-gate.sh
  run-f-json-v1-gate.sh
  run-f-json-v2-gate.sh
  run-f-regex-v1-gate.sh
  run-f-regex-v2-gate.sh
  run-f-unicode-v1-gate.sh
  run-f-unicode-v2-gate.sh
  run-f-hash-v1-gate.sh
  run-f-hash-v2-gate.sh
  run-f-dynlib-v1-gate.sh
  run-f-dynlib-v2-gate.sh
  run-f-backtrace-v1-gate.sh
  run-f-backtrace-v2-gate.sh
  run-f-http-v1-gate.sh
  run-f-tar-v1-gate.sh
  run-f-tar-v2-gate.sh
  run-f-channel-v1-gate.sh
  run-f-atomic-v1-gate.sh
  run-f-crypto-v1-gate.sh
  run-f-thread-v1-gate.sh
  run-f-queue-v1-gate.sh
  run-f-queue-v2-gate.sh
  run-f-async-v1-gate.sh
  run-f-async-future-v2-gate.sh
  run-f-cache-v1-gate.sh
  run-f-cache-v2-gate.sh
  run-f-config-v1-gate.sh
  run-f-config-v2-gate.sh
  run-f-datetime-v1-gate.sh
  run-f-datetime-v2-gate.sh
  run-f-elf-v1-gate.sh
  run-f-elf-v2-gate.sh
  run-f-test-v1-gate.sh
  run-f-test-v2-gate.sh
  run-f-url-v1-gate.sh
  run-f-url-v2-gate.sh
  run-f-schema-v1-gate.sh
  run-f-schema-v2-gate.sh
  run-f-socketio-v1-gate.sh
  run-f-socketio-v2-gate.sh
)

PREFIX="xlang: [XLANG_F_STD_DE_C_BATCH]"

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
  echo "f-std-de-c-batch FAIL: $*" >&2
  echo "${PREFIX} status=fail ok=${OK:-0} fail=${FAIL_N:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

OK=0
FAIL_N=0
SKIP=1

echo "=== F std de-C batch: ${#GATES[@]} gates (honesty) ==="
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f xbuild ] || die "missing xbuild"

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

for g in "${GATES[@]}"; do
  if [ ! -f "tests/$g" ]; then
    die "missing tests/$g"
  fi
  # Catch bash syntax errors early (historical orphan Makefile die/fi).
  if ! bash -n "tests/$g" 2>/tmp/f_de_c_syn.err; then
    die "syntax error in tests/$g: $(head -1 /tmp/f_de_c_syn.err)"
  fi
  chmod +x "tests/$g"
  echo "--- $g ---"
  if "tests/$g"; then
    OK=$((OK + 1))
  else
    FAIL_N=$((FAIL_N + 1))
    die "$g failed"
  fi
done

echo "${PREFIX} status=ok ok=${OK} fail=${FAIL_N} skip=${SKIP} host=$(ci_host_summary)"
echo "f-std-de-c-batch OK (${OK}/${#GATES[@]} gates; honesty)"
