#!/usr/bin/env bash
# bootstrap shu（driver 链 / bootstrap-driver-seed）子集门禁：hello + while + typeck + option + import + compound-assign。
# 用于 CI 与本地快速确认 .su pipeline 驱动编译器仍可用，不替代全量 run-all-c。
# 用法：./tests/run-bootstrap-shu-gate.sh；或 SHU=./compiler/shu ./tests/run-bootstrap-shu-gate.sh（跳过重建）。

set -e
cd "$(dirname "$0")/.."
SHU="${SHU:-./compiler/shu}"

# 默认重建 bootstrap driver（.su pipeline 链 shu）；CI 与本地门禁一致。
if [ -z "${SKIP_BOOTSTRAP_DRIVER_SEED:-}" ]; then
  make -C compiler bootstrap-driver-seed
  SHU=./compiler/shu
fi

if [ ! -x "$SHU" ]; then
  echo "run-bootstrap-shu-gate: $SHU not executable after bootstrap-driver-seed" >&2
  exit 127
fi

export SHU
./tests/run-hello.sh
./tests/run-while.sh
./tests/run-typeck.sh
# core.option：结构体按值返回 + §11.1 布局偏移（seed asm；见 pipeline_glue / backend struct lit）
if [ -f ./tests/run-option.sh ]; then
  ./tests/run-option.sh
fi
# 扩展：import 与 compound-assign（shu_asm 用 tests/run-shu-asm-gate.sh，见 SHU_SKIP_PARSE_SMOKE）
if [ -z "${BOOTSTRAP_GATE_MINIMAL:-}" ]; then
  if [ -f ./tests/run-import.sh ]; then
    ./tests/run-import.sh
  fi
  if [ -f ./tests/run-compound-assign.sh ]; then
    ./tests/run-compound-assign.sh
  fi
  if [ -f ./tests/run-multi-file.sh ]; then
    ./tests/run-multi-file.sh
  fi
  if [ -f ./tests/run-struct.sh ]; then
    ./tests/run-struct.sh
  fi
  if [ -f ./tests/run-return-value.sh ]; then
    ./tests/run-return-value.sh
  fi
  if [ -f ./tests/run-return-expr.sh ]; then
    ./tests/run-return-expr.sh
  fi
  echo "bootstrap shu gate OK (hello + while + typeck + option + import + compound-assign + multi-file + struct/return)"
else
  echo "bootstrap shu gate OK (hello + while + typeck; BOOTSTRAP_GATE_MINIMAL=1)"
fi
