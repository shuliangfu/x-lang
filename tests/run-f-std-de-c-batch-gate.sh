#!/usr/bin/env bash
# F 阶段 std 去 C 聚合门禁：…/cache/url v2。
#
# 用法：./tests/run-f-std-de-c-batch-gate.sh
# 环境：SHUX_F_STD_DE_C_BATCH_FAIL=1 — 任一子 gate 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F_STD_DE_C_BATCH_FAIL:-0}
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

die() {
  echo "f-std-de-c-batch FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F std de-C batch: ${#GATES[@]} gates ==="
for g in "${GATES[@]}"; do
  if [ ! -f "tests/$g" ]; then
    die "missing tests/$g"
  fi
  chmod +x "tests/$g"
  echo "--- $g ---"
  if ! "tests/$g"; then
    die "$g failed"
  fi
done
echo "f-std-de-c-batch OK (${#GATES[@]} gates)"
