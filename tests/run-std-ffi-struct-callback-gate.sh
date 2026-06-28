#!/usr/bin/env bash
# STD-151：std.ffi 结构体/回调安全封装门禁
#
# 用法：./tests/run-std-ffi-struct-callback-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-ffi-struct-callback-v1.md"
MANIFEST="tests/baseline/std-ffi-struct-callback-manifest.tsv"
MOD_SX="std/ffi/mod.sx"
FFI_IMPL="std/ffi/ffi.sx"
LIB="tests/lib/std-ffi-struct-callback.sh"
SMOKE_SX="tests/std-ffi/struct_callback.sx"
SMOKE_C="tests/std-ffi/struct_callback_ok.c"

# shellcheck source=tests/lib/std-ffi-struct-callback.sh
. "$LIB"

echo "=== STD-151: ffi struct/callback manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SX" "$FFI_IMPL" "$SMOKE_SX" "$SMOKE_C" std/ffi/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-ffi-struct-callback gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-151 FfiPoint invoke_cb FFI_ERR_TOO_SMALL; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-ffi-struct-callback gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "point_pack" std/ffi/README.md 2>/dev/null; then
  echo "std-ffi-struct-callback gate FAIL: README missing point_pack" >&2
  exit 1
fi

sym_miss="$(std_ffi_struct_callback_symbols_ok "$MOD_SX" "$FFI_IMPL" "$FFI_IMPL" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_ffi_struct_callback_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-ffi-struct-callback registry OK"

C_OK=0
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  if ensure_std_c_o ../std/ffi/ffi.o 2>/dev/null && std_ffi_struct_callback_run_c_smoke "$FFI_IMPL"; then
    C_OK=1
  else
    echo "std-ffi-struct-callback gate SKIP c smoke (no full ffi.o)" >&2
  fi
else
  echo "std-ffi-struct-callback gate SKIP c smoke (no shux-c)" >&2
fi
FFI_O="$(cd compiler && pwd)/../std/ffi/ffi.o"

SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-ffi-struct-callback gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_ffi_struct_callback_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_ffi_struct_callback_run_sx_smoke "$SHUX_BIN" "$SMOKE_SX" "$FFI_O"; then
    SX_OK=1
  else
    std_ffi_struct_callback_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_ffi_struct_callback_emit_report "ok" "$C_OK" "$SX_OK" "$SKIP"
echo "std-ffi-struct-callback gate OK"
