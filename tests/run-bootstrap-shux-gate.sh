#!/usr/bin/env bash
# bootstrap shux（driver 链 / bootstrap-driver-seed）子集门禁：hello + while + typeck + option + import + compound-assign。
# 用于 CI 与本地快速确认 .sx pipeline 驱动编译器仍可用，不替代全量 run-all-c。
# 用法：./tests/run-bootstrap-shux-gate.sh；或 SHUX=./compiler/shux ./tests/run-bootstrap-shux-gate.sh（跳过重建）。

set -e
cd "$(dirname "$0")/.."
SHUX="${SHUX:-./compiler/shux}"

# 默认重建 bootstrap driver（.sx pipeline 链 shux）；CI 与本地门禁一致。
if [ -z "${SKIP_BOOTSTRAP_DRIVER_SEED:-}" ]; then
  make -C compiler bootstrap-driver-seed
  SHUX=./compiler/shux
fi

if [ ! -x "$SHUX" ]; then
  echo "run-bootstrap-shux-gate: $SHUX not executable after bootstrap-driver-seed" >&2
  exit 127
fi

export SHUX
# MSYS2：-o 链接一律 shux-c（seed shux -o 挂起）；子脚本内勿再 make bootstrap-driver-seed。
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/shux-c ]; then
    export SHUX_LINK_SHUX=./compiler/shux-c
  fi
fi
export SHUX_SKIP_SUBSCRIPT_MAKE=1
# 非 x86_64：可执行 -o 链接用 shux-c，seed shux 仍负责 typeck/check。
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/shux-c ]; then
      export SHUX_LINK_SHUX=./compiler/shux-c
    fi
    ;;
esac
export SHUX_RUN_ALL_BOOTSTRAP_SHUX=1
./tests/run-hello.sh
./tests/run-while.sh
./tests/run-typeck.sh
# core.option：结构体按值返回 + §11.1 布局偏移（seed asm；见 pipeline_glue / backend struct lit）
if [ -f ./tests/run-option.sh ]; then
  ./tests/run-option.sh
fi
# 扩展：import 与 compound-assign（shux_asm 用 tests/run-shux-asm-gate.sh，见 SHUX_SKIP_PARSE_SMOKE）
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
  echo "bootstrap shux gate OK (hello + while + typeck + option + import + compound-assign + multi-file + struct/return + vec/map/heap + parser/typeck dogfood)"
else
  echo "bootstrap shux gate OK (hello + while + typeck; BOOTSTRAP_GATE_MINIMAL=1)"
fi
