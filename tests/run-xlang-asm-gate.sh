#!/usr/bin/env bash
# xlang_asm（B-strict）子集门禁：对齐 run-bootstrap-xlang-gate（含 option + 无 -o 烟测）。
# 用法：cd repo && ./tests/run-xlang-asm-gate.sh
# 或：XLANG=./compiler/xlang_asm ./tests/run-xlang-asm-gate.sh
# 要求：compiler/xlang_asm 已由 make bootstrap-driver-bstrict 或 build_xlang_asm.sh 产出。

set -e
cd "$(dirname "$0")/.."
XLANG="${XLANG:-./compiler/xlang_asm}"

if [ ! -x "$XLANG" ]; then
  echo "run-xlang-asm-gate: $XLANG build not executable (run: make -C compiler bootstrap-driver-bstrict)" >&2
  exit 127
fi

export XLANG
export XLANG_SKIP_PARSE_SMOKE=1
export XLANG_BSTRICT_RUN_ALL=1
export XLANG_SKIP_SUBSCRIPT_MAKE=1
# 子脚本 -o 链接：check/typeck 仍用 $XLANG（xlang_asm）；可执行链接用 xlang-c（ubuntu 全链路 -o 易 SIGSEGV）。
export XLANG_LINK_XLANG=./compiler/xlang-c
make -C compiler xlang-c -q 2>/dev/null || make -C compiler xlang-c 2>/dev/null || true
ulimit -s 16384 2>/dev/null || true

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

echo "run-xlang-asm-gate: hello (import std.io) ..."
rm -f /tmp/xlang_asm_gate_hello
# -o 链接：Darwin/non-x86_64 走 RUN_XLANG（xlang-c）；typeck 仍由 $XLANG（xlang_asm）承担。
"$RUN_XLANG" -L . examples/hello.x -o /tmp/xlang_asm_gate_hello
/tmp/xlang_asm_gate_hello | grep -q "Hello World" || {
  echo "run-xlang-asm-gate: hello expected Hello World" >&2
  exit 1
}

./tests/run-while.sh
./tests/run-typeck.sh
XLANG="$XLANG" ./tests/run-option.sh
./tests/run-import.sh

./tests/run-compound-assign.sh
./tests/run-multi-file.sh

XLANG="$XLANG" ./tests/run-struct.sh
XLANG="$XLANG" ./tests/run-return-value.sh
XLANG="$XLANG" ./tests/run-return-expr.sh

XLANG="$XLANG" ./tests/run-pool-limits.sh

XLANG="$XLANG" ./tests/run-check.sh
XLANG="$XLANG" ./tests/run-check-compiler.sh
XLANG="$XLANG" ./tests/run-fmt-cmd.sh
XLANG="$XLANG" ./tests/run-fmt-check-cmd.sh
XLANG="$XLANG" ./tests/run-test-cmd.sh

echo "xlang_asm gate OK (hello + while + typeck + option + import + compound + multi-file + struct/return + pool-limits + check/fmt/test cmd)"
