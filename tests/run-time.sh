#!/usr/bin/env bash
#
# 【文件职责】std.time 模块的回归测试脚本；编译并运行 tests/time/*.x，校验退出码。
# 【测试目的】覆盖 now_monotonic_*、now_wall_*、sleep_*、duration_ns，确保 API 行为符合预期。
# 【运行方式】在仓库根目录执行 ./tests/run-time.sh；可选环境变量 SHUX 指定编译器路径。
#
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q 2>/dev/null || make -C compiler
ensure_std_c_o ../std/time/time.o

SHUX="${SHUX:-./compiler/shux}"
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true
run_one() {
  local name="$1"
  local src="$2"
  local exe="/tmp/shux_time_$$_${name}"
  if ! $LINK_SHUX -L . "$src" -o "$exe" 2>&1; then
    echo "time test $name: compile failed"
    return 1
  fi
  local exitcode=0
  $exe >/dev/null 2>&1 || exitcode=$?
  rm -f "$exe"
  if [ "$exitcode" -ne 0 ]; then
    echo "time test $name: expected exit 0, got $exitcode"
    return 1
  fi
  return 0
}

run_one "main" "tests/time/main.x" || exit 1
run_one "bench_timer" "tests/time/bench_timer.x" || exit 1
run_one "format_timezone" "tests/time/format_timezone.x" || exit 1

echo "time test OK (all)"
rm -f /tmp/shux_time_$$_*
