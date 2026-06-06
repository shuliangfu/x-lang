#!/usr/bin/env bash
# S5：build_asm/backend_wpo.o WPO 生产链硬门禁（WPO 压缩 backend.su dogfood）。
# strict 链仍用全量 build_asm/backend.o；本门禁仅验 backend_wpo.o。
# 用法：
#   ./tests/run-wpo-backend-o-gate.sh
#   ./tests/run-wpo-backend-o-gate.sh compiler/build_asm/backend_wpo.o
#   SHU_WPO_BACKEND_O_FAIL=1 ./tests/run-wpo-backend-o-gate.sh
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-ab-proxy.sh
. tests/lib/wpo-ab-proxy.sh

BACKEND_O="${1:-compiler/build_asm/backend_wpo.o}"
BASELINE="${SHU_WPO_BACKEND_O_BASELINE:-tests/baseline/wpo-backend-o.tsv}"
MAX_TEXT=$(awk -F'\t' '$1=="backend_wpo_max_text_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MAX_TEXT=${MAX_TEXT:-4096}
MIN_SAVE=$(awk -F'\t' '$1=="backend_wpo_min_save_bytes" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_SAVE=${MIN_SAVE:-2000}
OFF_PROXY=$(awk -F'\t' '$1=="backend_dce_off_text" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
OFF_PROXY=${OFF_PROXY:-4677}
FAIL=${SHU_WPO_BACKEND_O_FAIL:-1}

if [ ! -f "$BACKEND_O" ]; then
  echo "run-wpo-backend-o-gate FAIL: missing $BACKEND_O" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TXT=$(wpo_ab_text_bytes "$BACKEND_O") || {
  echo "run-wpo-backend-o-gate FAIL: cannot read .text from $BACKEND_O" >&2
  exit 1
}

if ! nm "$BACKEND_O" 2>/dev/null | grep -q 'asm_codegen_ast'; then
  echo "run-wpo-backend-o-gate FAIL: $BACKEND_O missing asm_codegen_ast" >&2
  exit 1
fi

SAVE=$((OFF_PROXY - TXT))
echo "wpo backend_wpo.o gate: $BACKEND_O __text=${TXT}B (max=${MAX_TEXT}B, save=${SAVE}B vs proxy off=${OFF_PROXY}B)"

if [ "$TXT" -gt "$MAX_TEXT" ] 2>/dev/null; then
  echo "run-wpo-backend-o-gate WARN: __text ${TXT}B > cap ${MAX_TEXT}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi
if [ "$SAVE" -lt "$MIN_SAVE" ] 2>/dev/null; then
  echo "run-wpo-backend-o-gate FAIL: save ${SAVE}B < min ${MIN_SAVE}B" >&2
  [ "$FAIL" = "1" ] && exit 1
fi

echo "wpo backend_wpo.o gate OK (__text=${TXT}B <= ${MAX_TEXT}B, save=${SAVE}B, asm_codegen_ast present)"
