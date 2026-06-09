#!/usr/bin/env bash
# shu_asm（B-strict）子集门禁：对齐 run-bootstrap-shu-gate（含 option + 无 -o 烟测）。
# 用法：cd repo && ./tests/run-shu-asm-gate.sh
# 或：SHU=./compiler/shu_asm ./tests/run-shu-asm-gate.sh
# 要求：compiler/shu_asm 已由 make bootstrap-driver-bstrict 或 build_shu_asm.sh 产出。

set -e
cd "$(dirname "$0")/.."
SHU="${SHU:-./compiler/shu_asm}"

if [ ! -x "$SHU" ]; then
  echo "run-shu-asm-gate: $SHU not executable (run: make -C compiler bootstrap-driver-bstrict)" >&2
  exit 127
fi

export SHU
export SHU_SKIP_PARSE_SMOKE=1
export SHULANG_BSTRICT_RUN_ALL=1
export SHULANG_SKIP_SUBSCRIPT_MAKE=1
# 子脚本 -o 链接：check/typeck 仍用 $SHU（shu_asm）；可执行链接用 shu-c（ubuntu 全链路 -o 易 SIGSEGV）。
export SHULANG_LINK_SHU=./compiler/shu-c
make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
ulimit -s 16384 2>/dev/null || true

# shellcheck source=tests/lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

echo "run-shu-asm-gate: hello (import std.io) ..."
rm -f /tmp/shu_asm_gate_hello
# -o 链接：Darwin/non-x86_64 走 RUN_SHU（shu-c）；typeck 仍由 $SHU（shu_asm）承担。
"$RUN_SHU" -L . examples/hello.su -o /tmp/shu_asm_gate_hello
/tmp/shu_asm_gate_hello | grep -q "Hello World" || {
  echo "run-shu-asm-gate: hello expected Hello World" >&2
  exit 1
}

./tests/run-while.sh
./tests/run-typeck.sh
SHU="$SHU" ./tests/run-option.sh
./tests/run-import.sh

./tests/run-compound-assign.sh
./tests/run-multi-file.sh

SHU="$SHU" ./tests/run-struct.sh
SHU="$SHU" ./tests/run-return-value.sh
SHU="$SHU" ./tests/run-return-expr.sh

SHU="$SHU" ./tests/run-pool-limits.sh

SHU="$SHU" ./tests/run-check.sh
SHU="$SHU" ./tests/run-check-compiler.sh
SHU="$SHU" ./tests/run-fmt-cmd.sh
SHU="$SHU" ./tests/run-fmt-check-cmd.sh
SHU="$SHU" ./tests/run-test-cmd.sh

echo "shu_asm gate OK (hello + while + typeck + option + import + compound + multi-file + struct/return + pool-limits + check/fmt/test cmd)"
