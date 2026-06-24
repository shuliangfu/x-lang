#!/usr/bin/env bash
# asm 7.3：FIELD/INDEX 与 VAR 混合 binop 直 load（无 push/pop 保存操作数）。
# 含 struct：shux_asm 用户 -o struct emit 在 Linux 仍 SIGSEGV；-o 走 bootstrap LINK（bstrict 为 shux-c）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX=${SHUX:-./compiler/shux}
LINK_SHUX="${SHUX_LINK_SHUX:-${RUN_SHUX:-$SHUX}}"

$LINK_SHUX tests/asm/binop_field_index_fast.sx -o /tmp/shux_asm_binop_field_index 2>&1
exitcode=0
/tmp/shux_asm_binop_field_index >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 205 ] && { echo "run-asm-binop-field-index FAIL: expected exit 205, got $exitcode"; exit 1; }

if otool -tv /tmp/shux_asm_binop_field_index 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'sub.*sp, sp, #0x10'; then
  echo "run-asm-binop-field-index FAIL: main still uses stack push for binop"
  exit 1
fi

echo "asm binop field/index fast OK"
