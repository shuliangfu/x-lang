#!/usr/bin/env bash
# shux_asm（B-strict）子集门禁：对齐 run-bootstrap-shux-gate（含 option + 无 -o 烟测）。
# 用法：cd repo && ./tests/run-shux-asm-gate.sh
# 或：SHUX=./compiler/shux_asm ./tests/run-shux-asm-gate.sh
# 要求：compiler/shux_asm 已由 make bootstrap-driver-bstrict 或 build_shux_asm.sh 产出。

set -e
cd "$(dirname "$0")/.."
SHUX="${SHUX:-./compiler/shux_asm}"

if [ ! -x "$SHUX" ]; then
  echo "run-shux-asm-gate: $SHUX not executable (run: make -C compiler bootstrap-driver-bstrict)" >&2
  exit 127
fi

export SHUX
export SHUX_SKIP_PARSE_SMOKE=1
export SHUX_BSTRICT_RUN_ALL=1
export SHUX_SKIP_SUBSCRIPT_MAKE=1
# 子脚本 -o 链接：check/typeck 仍用 $SHUX（shux_asm）；可执行链接用 shux-c（ubuntu 全链路 -o 易 SIGSEGV）。
export SHUX_LINK_SHUX=./compiler/shux-c
make -C compiler shux-c -q 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
ulimit -s 16384 2>/dev/null || true

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

echo "run-shux-asm-gate: hello (import std.io) ..."
rm -f /tmp/shux_asm_gate_hello
# -o 链接：Darwin/non-x86_64 走 RUN_SHUX（shux-c）；typeck 仍由 $SHUX（shux_asm）承担。
"$RUN_SHUX" -L . examples/hello.x -o /tmp/shux_asm_gate_hello
/tmp/shux_asm_gate_hello | grep -q "Hello World" || {
  echo "run-shux-asm-gate: hello expected Hello World" >&2
  exit 1
}

./tests/run-while.sh
./tests/run-typeck.sh
SHUX="$SHUX" ./tests/run-option.sh
./tests/run-import.sh

./tests/run-compound-assign.sh
./tests/run-multi-file.sh

SHUX="$SHUX" ./tests/run-struct.sh
SHUX="$SHUX" ./tests/run-return-value.sh
SHUX="$SHUX" ./tests/run-return-expr.sh

SHUX="$SHUX" ./tests/run-pool-limits.sh

SHUX="$SHUX" ./tests/run-check.sh
SHUX="$SHUX" ./tests/run-check-compiler.sh
SHUX="$SHUX" ./tests/run-fmt-cmd.sh
SHUX="$SHUX" ./tests/run-fmt-check-cmd.sh
SHUX="$SHUX" ./tests/run-test-cmd.sh

echo "shux_asm gate OK (hello + while + typeck + option + import + compound + multi-file + struct/return + pool-limits + check/fmt/test cmd)"
