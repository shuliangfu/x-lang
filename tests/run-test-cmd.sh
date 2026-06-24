#!/usr/bin/env bash
# shux test 子命令：跑轻量脚本（非全量 run-all，避免 CI 重复）。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}
# bootstrap shux_asm：test 子命令走 shux-c（与 run-check/run-fmt-cmd 一致）。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] && [ -x ./compiler/shux-c ]; then
  case "$(basename "${SHUX:-./compiler/shux}")" in
    shux|shux_asm) SHUX=./compiler/shux-c ;;
  esac
fi
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  fi
fi

_test_cmd_out=$($SHUX test tests/run-echo-test.sh 2>&1) || true
echo "$_test_cmd_out" | grep -q "echo test OK" || {
  echo "test cmd: expected 'echo test OK' from shux test, got: $_test_cmd_out" >&2
  exit 1
}
echo "test cmd OK"
