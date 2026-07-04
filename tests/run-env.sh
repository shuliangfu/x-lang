#!/usr/bin/env bash
#
# 【文件职责】std.env 模块的回归测试脚本；编译并运行 tests/env/*.x，校验退出码。
# 【测试目的】覆盖 getenv、setenv、env_iter、args_iter 等 API。
# 【运行方式】在仓库根目录执行 bash tests/run-env.sh 或 ./tests/run-env.sh
#
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler -q ../std/env/env.o 2>/dev/null || make -C compiler ../std/env/env.o
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

run_one() {
  local src="$1"
  local label="$2"
  local exe="/tmp/shux_env_$$_${label}"
  if ! $RUN_SHUX -L . "$src" -o "$exe" 2>&1; then
    echo "env test ($label): compile failed"
    rm -f "$exe"
    exit 1
  fi
  local exitcode=0
  $exe 2>/dev/null || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "env test ($label): expected exit 0, got $exitcode"
    exit 1
  fi
  echo "env test OK ($label)"
}

run_one tests/env/main.x main
run_one tests/env/env_iter.x env_iter
run_one tests/env/platform_encoding.x platform_encoding
echo "env test OK (all)"
rm -f /tmp/shux_env_$$_*
