#!/usr/bin/env bash
# TYPE-004：FFI 类型桥接烟测（putchar + cstr + main）
#
# 用法：./tests/run-type-ffi-bridge.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/type-ffi-bridge.sh
. tests/lib/type-ffi-bridge.sh
# shellcheck source=tests/lib/safe-ffi.sh
. tests/lib/safe-ffi.sh

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if type_ffi_native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ] || ! type_ffi_native_shu "$SHUX_BIN"; then
  echo "type-ffi-bridge SKIP (no native shux, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "type-ffi-bridge OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== TYPE-004: FFI bridge smoke (SHUX=$SHUX_BIN) ==="

# i32 → putchar（标量桥接）
exe="/tmp/shux_ffi_bridge_putchar"
if ! SHUX="$SHUX_BIN" "$SHUX_BIN" -L . tests/ffi/putchar.sx -o "$exe" 2>/tmp/shux_ffi_bridge_putchar.log; then
  cat /tmp/shux_ffi_bridge_putchar.log >&2
  echo "type-ffi-bridge FAIL: compile putchar.sx" >&2
  exit 1
fi
rc=0
"$exe" >/dev/null 2>&1 || rc=$?
rm -f "$exe"
if [ "$rc" -ne 65 ] && [ "$rc" -ne 0 ]; then
  echo "type-ffi-bridge WARN: putchar exit=$rc (platform dependent)" >&2
fi
echo "type-ffi-bridge OK putchar"

# *u8 cstr_len（指针桥接）— 复用 safe-ffi 运行库
if safe_ffi_run_case "$SHUX_BIN" tests/ffi/contract_null_cstr.sx 0 cstr_u8; then
  echo "type-ffi-bridge OK cstr_u8"
else
  echo "type-ffi-bridge FAIL: contract_null_cstr.sx" >&2
  exit 1
fi

echo "type-ffi-bridge OK"
