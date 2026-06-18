#!/usr/bin/env bash
# STBL-003：模块变更 RFC 模板门禁
#
# 验收：analysis/std-change-rfc-template.md 含 API/ABI/ZC/错误码等必填 §。
#
# 用法：./tests/run-stbl-003-change-rfc-template-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STBL_CRFC_DOC:-analysis/stbl-change-rfc-template-v1.md}"
TEMPLATE="${SHU_STBL_CRFC_TEMPLATE:-analysis/std-change-rfc-template.md}"
MANIFEST="${SHU_STBL_CRFC_TSV:-tests/baseline/stbl-change-rfc-template.tsv}"
LIB="tests/lib/stbl-change-rfc-template.sh"
MIN_SEC=7

# shellcheck source=tests/lib/stbl-change-rfc-template.sh
. "$LIB"

echo "=== STBL-003: change RFC template manifest ==="
for f in "$DOC" "$TEMPLATE" "$MANIFEST" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "stbl-change-rfc gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STBL-003 std-change-rfc-template API ABI ZC 错误码; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "stbl-change-rfc gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_sections) MIN_SEC="$c2" ;; esac
done < "$MANIFEST"

sec_miss="$(stbl_crfc_sections_ok "$TEMPLATE" "$MANIFEST" || true)"
ex_miss="$(stbl_crfc_examples_ok "$MANIFEST" || true)"
if [ "${sec_miss:-0}" -gt 0 ] || [ "${ex_miss:-0}" -gt 0 ]; then
  stbl_crfc_emit_report "fail" "$sec_miss" "$ex_miss"
  echo "stbl-change-rfc gate FAIL: sec_miss=${sec_miss} ex_miss=${ex_miss}" >&2
  exit 1
fi

# 模板关键字：四大维度 + manifest/gate 占位
for kw in manifest gate error_base_ 零拷贝 runtime.c; do
  if ! grep -qF "$kw" "$TEMPLATE" 2>/dev/null; then
    echo "stbl-change-rfc gate FAIL: template missing '$kw'" >&2
    stbl_crfc_emit_report "fail" 0 0
    exit 1
  fi
done

SECTIONS=$((MIN_SEC - sec_miss))
stbl_crfc_emit_report "ok" "$MIN_SEC" "$((2 - ex_miss))"
echo "stbl-change-rfc-template gate OK"
