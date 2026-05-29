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
ulimit -s 16384 2>/dev/null || true

echo "run-shu-asm-gate: hello (import std.io) ..."
rm -f /tmp/shu_asm_gate_hello
"$SHU" -L . examples/hello.su -o /tmp/shu_asm_gate_hello
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

SHU="$SHU" ./tests/run-check.sh
SHU="$SHU" ./tests/run-check-compiler.sh
SHU="$SHU" ./tests/run-fmt-cmd.sh
SHU="$SHU" ./tests/run-fmt-check-cmd.sh
SHU="$SHU" ./tests/run-test-cmd.sh

echo "shu_asm gate OK (hello + while + typeck + option + import + compound + multi-file + struct/return + check/fmt/test cmd)"
