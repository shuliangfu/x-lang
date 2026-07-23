#!/usr/bin/env bash
#
# 【文件职责】std.sync 模块的回归测试脚本；编译并运行 tests/sync/main.x，校验退出码。
# 【测试目的】覆盖 mutex_new、mutex_lock、mutex_try_lock、mutex_unlock、mutex_free，确保 API 行为符合预期。
# 【运行方式】在仓库根目录执行 bash tests/run-sync.sh 或 ./tests/run-sync.sh；可选环境变量 XLANG 指定编译器路径。
#
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
# 确保 compiler 与 std/sync/sync.o 已构建（链接阶段需要 sync.o）
make -C compiler -q 2>/dev/null || make -C compiler
# W3 gold best-effort：跳过 ensure_std_c_o（make+seed xlang 易挂起/进程风暴）。
if [ -z "${XLANG_W3_SKIP_STD_ENSURE:-}" ]; then
  ensure_std_c_o ../std/sync/sync.o
fi

XLANG="${XLANG:-./compiler/xlang}"
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
LINK_XLANG="$RUN_XLANG"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
exe="/tmp/xlang_sync_$$_main"
if ! $LINK_XLANG build -L . tests/sync/main.x -o "$exe" 2>&1; then
  echo "sync test: compile failed"
  rm -f "$exe"
  exit 1
fi
exitcode=0; $exe 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  echo "sync test: expected exit 0, got $exitcode"
  exit 1
fi
echo "sync test OK (all)"
rm -f /tmp/xlang_sync_$$_*
