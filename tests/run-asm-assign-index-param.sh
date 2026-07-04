#!/usr/bin/env bash
# asm 7.3：*i32 形参与 struct 字段数组 INDEX assign，helper 内无 mov x2。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"

run_one() {
  local src="$1"
  local out="$2"
  local fn="$3"
  local want="$4"
  local comp="$5"
  "$comp" "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -ne "$want" ] && {
    echo "run-asm-assign-index-param FAIL: $src expected exit $want, got $exitcode"
    exit 1
  }
  if otool -tv "$out" 2>/dev/null | sed -n "/^_${fn}:/,/^_[a-z]/p" | grep -q 'mov x2'; then
    echo "run-asm-assign-index-param FAIL: $src ${fn} still uses mov x2"
    exit 1
  fi
}

# 无 struct：仍用 shux_asm 验 asm INDEX assign scratch。
run_one tests/asm/assign_index_ptr_param.x /tmp/shux_asm_assign_index_ptr_param set_at 99 "$SHUX"
# struct 字段数组：-o 走 shux-c（与 run-struct / run-vector 一致）。
run_one tests/asm/assign_index_struct_field.x /tmp/shux_asm_assign_index_struct_field set_in 99 "$LINK_SHUX"

echo "asm assign index param OK"
