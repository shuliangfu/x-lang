#!/usr/bin/env bash
# STD-151：std.ffi 结构体/回调安全封装门禁
#
# 用法：./tests/run-std-ffi-struct-callback-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-ffi-struct-callback-v1.md"
MANIFEST="tests/baseline/std-ffi-struct-callback-manifest.tsv"
MOD_SU="std/ffi/mod.sx"
FFI_C="std/ffi/ffi.c"
LIB="tests/lib/std-ffi-struct-callback.sh"
SMOKE_SU="tests/std-ffi/struct_callback.sx"
SMOKE_C="tests/std-ffi/struct_callback_ok.c"

# shellcheck source=tests/lib/std-ffi-struct-callback.sh
. "$LIB"

echo "=== STD-151: ffi struct/callback manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$FFI_C" "$SMOKE_SU" "$SMOKE_C" std/ffi/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-ffi-struct-callback gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-151 FfiPoint invoke_i32_cb FFI_ERR_TOO_SMALL; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-ffi-struct-callback gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "point_pack" std/ffi/README.md 2>/dev/null; then
  echo "std-ffi-struct-callback gate FAIL: README missing point_pack" >&2
  exit 1
fi

sym_miss="$(std_ffi_struct_callback_symbols_ok "$MOD_SU" "$FFI_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_ffi_struct_callback_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-ffi-struct-callback registry OK"

# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/ffi/ffi.o
FFI_O="$(cd compiler && pwd)/../std/ffi/ffi.o"

C_OK=0
if std_ffi_struct_callback_run_c_smoke "$FFI_C"; then
  C_OK=1
else
  std_ffi_struct_callback_emit_report "fail" 0 0 0
  exit 1
fi

SU_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-ffi-struct-callback gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_ffi_struct_callback_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_ffi_struct_callback_run_sx_smoke "$SHUX_BIN" "$SMOKE_SU" "$FFI_O"; then
    SU_OK=1
  else
    std_ffi_struct_callback_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_ffi_struct_callback_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-ffi-struct-callback gate OK"
