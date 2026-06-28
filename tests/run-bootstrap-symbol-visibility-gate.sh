#!/usr/bin/env bash
# V7 §7.2：bootstrap 符号可见性门禁（partial seed + import_alias 严格；stage1 审计）
#
# 用法：./tests/run-bootstrap-symbol-visibility-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "${SHUX_BOOTSTRAP_SYM_VIS_SKIP:-0}" = "1" ]; then
  echo "bootstrap-symbol-visibility-gate: SKIP"
  exit 0
fi

# shellcheck source=tests/lib/bootstrap-symbol-visibility.sh
source tests/lib/bootstrap-symbol-visibility.sh

echo "bootstrap-symbol-visibility-gate: partial + alias ..."
FAIL=0

PARTIAL="compiler/seeds/asm_backend_partial.linux.x86_64.o"
if ! bootstrap_symbol_visibility_check_partial "$PARTIAL"; then
  FAIL=$((FAIL + 1))
fi

if ! bootstrap_symbol_visibility_check_import_alias "std/ffi/ffi_import_alias.c"; then
  FAIL=$((FAIL + 1))
fi

bootstrap_symbol_visibility_audit_binary "compiler/shux_asm_stage1" || FAIL=$((FAIL + 1))
bootstrap_symbol_visibility_audit_binary "compiler/shux_asm" || FAIL=$((FAIL + 1))

if [ "$FAIL" -gt 0 ]; then
  echo "bootstrap-symbol-visibility-gate FAIL: ${FAIL} check(s)" >&2
  exit 1
fi
echo "bootstrap-symbol-visibility-gate OK"
