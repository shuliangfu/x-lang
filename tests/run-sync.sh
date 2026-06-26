#!/usr/bin/env bash
#
# 【文件职责】std.sync 模块的回归测试脚本；编译并运行 tests/sync/main.sx，校验退出码。
# 【测试目的】覆盖 mutex_new、mutex_lock、mutex_try_lock、mutex_unlock、mutex_free，确保 API 行为符合预期。
# 【运行方式】在仓库根目录执行 bash tests/run-sync.sh 或 ./tests/run-sync.sh；可选环境变量 SHUX 指定编译器路径。
#
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
# 确保 compiler 与 std/sync/sync.o 已构建（链接阶段需要 sync.o）
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/sync/sync.o

SHUX="${SHUX:-./compiler/shux}"
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
exe="/tmp/shux_sync_$$_main"
if ! $LINK_SHUX -L . tests/sync/main.sx -o "$exe" 2>&1; then
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
rm -f /tmp/shux_sync_$$_*
