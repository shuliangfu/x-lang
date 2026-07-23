#!/usr/bin/env bash
# xlang test 子命令：跑轻量脚本（非全量 run-all，避免 CI 重复）。
set -e
cd "$(dirname "$0")/.."
XLANG=${XLANG:-./compiler/xlang}
# bootstrap xlang_asm：test 子命令走 xlang-c（与 run-check/run-fmt-cmd 一致）。
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ] && [ -x ./compiler/xlang-c ]; then
  case "$(basename "${XLANG:-./compiler/xlang}")" in
    xlang|xlang_asm) XLANG=./compiler/xlang-c ;;
  esac
fi
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" ]; then
    make -C compiler bootstrap-driver-seed -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  else
    make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
  fi
fi

_test_cmd_out=$($XLANG test tests/run-echo-test.sh 2>&1) || true
echo "$_test_cmd_out" | grep -q "echo test OK" || {
  echo "test cmd: expected 'echo test OK' from xlang test, got: $_test_cmd_out" >&2
  exit 1
}
echo "test cmd OK"
