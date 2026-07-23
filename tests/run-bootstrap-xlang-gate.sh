#!/usr/bin/env bash
# bootstrap xlang（driver 链 / bootstrap-driver-seed）子集门禁：hello + while + typeck + option + import + compound-assign。
# 用于 CI 与本地快速确认 .x pipeline 驱动编译器仍可用，不替代全量 run-all-c。
# 用法：./tests/run-bootstrap-xlang-gate.sh；或 XLANG=./compiler/xlang ./tests/run-bootstrap-xlang-gate.sh（跳过重建）。

set -e
cd "$(dirname "$0")/.."
XLANG="${XLANG:-./compiler/xlang}"

# 默认重建 bootstrap driver（.x pipeline 链 xlang）；CI 与本地门禁一致。
if [ -z "${SKIP_BOOTSTRAP_DRIVER_SEED:-}" ]; then
  make -C compiler bootstrap-driver-seed
  XLANG=./compiler/xlang
fi

if [ ! -x "$XLANG" ]; then
  echo "run-bootstrap-xlang-gate: $XLANG build not executable after bootstrap-driver-seed" >&2
  exit 127
fi

export XLANG
# MSYS2：-o 链接一律 xlang-c（seed xlang -o 挂起）；子脚本内勿再 make bootstrap-driver-seed。
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/xlang-c ]; then
    export XLANG_LINK_XLANG=./compiler/xlang-c
  fi
fi
export XLANG_SKIP_SUBSCRIPT_MAKE=1
# 非 x86_64：可执行 -o 链接用 xlang-c，seed xlang 仍负责 typeck/check。
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/xlang-c ]; then
      export XLANG_LINK_XLANG=./compiler/xlang-c
    fi
    ;;
esac
export XLANG_RUN_ALL_BOOTSTRAP_XLANG=1
./tests/run-hello.sh
./tests/run-while.sh
./tests/run-typeck.sh
# core.option：结构体按值返回 + §11.1 布局偏移（seed asm；见 pipeline_glue / backend struct lit）
if [ -f ./tests/run-option.sh ]; then
  ./tests/run-option.sh
fi
# 扩展：import 与 compound-assign（xlang_asm 用 tests/run-xlang-asm-gate.sh，见 XLANG_SKIP_PARSE_SMOKE）
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
  if [ -f ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh ]; then
    ./tests/run-bootstrap-semantic-smoke-vec-map-heap.sh
  fi
  if [ -f ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh ]; then
    ./tests/run-bootstrap-stage2-dogfood-parser-typeck.sh
  fi
  echo "bootstrap xlang gate OK (hello + while + typeck + option + import + compound-assign + multi-file + struct/return + vec/map/heap + parser/typeck dogfood)"
else
  echo "bootstrap xlang gate OK (hello + while + typeck; BOOTSTRAP_GATE_MINIMAL=1)"
fi
