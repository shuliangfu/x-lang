#!/bin/sh
# relink_xlang_asm_bstrict_runtime_objs.sh — 更新 runtime/bootstrap/crt0 对象后快速重链 xlang_asm（B-strict nostdlib）
# 用法：cd compiler && ./scripts/relink_xlang_asm_bstrict_runtime_objs.sh
# 要求：build_asm/*.o 已由 prior build_xlang_asm / bootstrap 产出；仅重编 src/runtime*.o 与 bootstrap 桩。

set -e
cd "$(dirname "$0")/.."
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

export XLANG_ASM_EXPERIMENTAL_SKIP_GEN=1
export XLANG_ASM_BSTRICT_RELINK_ONLY=1
export XLANG_ASM_SKIP_STRICT_SMOKE=1
export XLANG_ASM_SKIP_MAIN_O_REBUILD=1
export XLANG_ASM_SKIP_WPO_DOGFOOD=1
export XLANG_ASM_SKIP_ENTRY_SMOKE=1
export XLANG="${XLANG:-./xlang_asm_stage1}"
[ -x "$XLANG" ] || XLANG=./xlang_asm
[ -x "$XLANG" ] || { echo "relink: need ./xlang_asm or ./xlang_asm_stage1" >&2; exit 1; }

exec ./scripts/build_xlang_asm.sh
