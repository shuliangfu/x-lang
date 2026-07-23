#!/usr/bin/env bash
# G-02f-317：product hybrid 下 runtime rest 业务 T 符号须为 0（f-316 里程碑哨兵）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CDIR="$ROOT/compiler"
cd "$CDIR"

CC="${CC:-cc}"
BASE_CFLAGS="-Wall -I. -Iinclude -Isrc"
RUNTIME_DRIVER_NO_C_CFLAGS="-DXLANG_USE_X_DRIVER -DXLANG_USE_X_PIPELINE -DXLANG_USE_X_PREPROCESS -DXLANG_USE_X_TYPECK -DXLANG_USE_X_CODEGEN -DXLANG_NO_C_FRONTEND -DXLANG_ASM_USE_COMPILER_IMPL_C"
ALL_FROM_X="
  -DXLANG_RT_CONTENT_FROM_X -DXLANG_RT_UTIL_FROM_X -DXLANG_RT_ARGV_FROM_X
  -DXLANG_RT_EMIT_FLAGS_FROM_X -DXLANG_RT_PREAMBLE_FROM_X -DXLANG_RT_COMPILE_FROM_X
  -DXLANG_RT_RUN_EXEC_FROM_X -DXLANG_RT_ASM_STUB_FROM_X -DXLANG_RT_ENTRY_FROM_X
  -DXLANG_RT_DIAG_ERRNO_FROM_X -DXLANG_RT_EMIT_STATE_FROM_X -DXLANG_RT_PIPELINE_ELF_DIAG_FROM_X
  -DXLANG_RT_LIB_ROOT_FROM_X -DXLANG_RT_PARSE_DIAG_FROM_X -DXLANG_RT_FS_OPEN_FROM_X
  -DXLANG_RT_ARENA_BUF_FROM_X -DXLANG_RT_FMT_ONE_FROM_X -DXLANG_RT_DISPATCH_THIN_FROM_X
  -DXLANG_RT_DISPATCH_IMPL_FROM_X -DXLANG_RT_RUN_X_EMIT_FROM_X -DXLANG_RT_RUN_ASM_BACKEND_FROM_X
  -DXLANG_RT_RUN_COMPILER_PARSED_FROM_X -DXLANG_RT_STACK_FROM_X
"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# shellcheck disable=SC2086
$CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS $ALL_FROM_X -c -o "$TMP/rest.o" seeds/runtime.from_x.c
T_COUNT=$(nm -gU "$TMP/rest.o" 2>/dev/null | awk '$2=="T" || $2=="t" {print}' | grep -c . || true)
# Only count global text symbols (T); ignore local
T_COUNT=$(nm -gU "$TMP/rest.o" 2>/dev/null | awk '$2=="T" {c++} END{print c+0}')

if [ "$T_COUNT" != "0" ]; then
  echo "FAIL: product hybrid runtime rest has $T_COUNT global T symbol(s); expected 0 (G-02f-316+)" >&2
  nm -gU "$TMP/rest.o" | awk '$2=="T"{print}' >&2 || true
  exit 1
fi

echo "OK: product hybrid runtime rest T=0 (G-02f-317 gate)"
exit 0
