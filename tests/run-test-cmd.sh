#!/usr/bin/env bash
# shu test 子命令：跑轻量脚本（非全量 run-all，避免 CI 重复）。
set -e
cd "$(dirname "$0")/.."
SHU=${SHU:-./compiler/shu}
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHULANG_RUN_ALL_BOOTSTRAP_SHU:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  fi
fi

_test_cmd_out=$($SHU test tests/run-echo-test.sh 2>&1) || true
echo "$_test_cmd_out" | grep -q "echo test OK" || {
  echo "test cmd: expected 'echo test OK' from shu test, got: $_test_cmd_out" >&2
  exit 1
}
echo "test cmd OK"
