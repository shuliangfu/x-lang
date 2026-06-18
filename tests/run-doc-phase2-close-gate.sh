#!/usr/bin/env bash
# DOC-008：Phase 2 收尾文档同步门禁
#
# 用法：./tests/run-doc-phase2-close-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_DOC08_DOC:-analysis/doc-phase2-close-v1.md}"
MANIFEST="${SHU_DOC08_TSV:-tests/baseline/doc-phase2-close.tsv}"
COOKBOOK="examples/cookbook/http_chunked_decode.su"
MIN_ANCHORS=6

# shellcheck source=tests/lib/doc-phase2-close.sh
. tests/lib/doc-phase2-close.sh

echo "=== DOC-008: Phase 2 close doc sync manifest ==="
for f in "$DOC" "$MANIFEST" "$COOKBOOK" std/http/README.md std/README.md docs/07-内置与标准库.md; do
  if [ ! -f "$f" ]; then
    echo "doc-phase2-close gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_anchors) MIN_ANCHORS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in STD-033 decode_chunked_body HTTP-02 Phase 2; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-phase2-close gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(doc_phase2_close_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  doc_phase2_close_emit_report "fail" 0 0 0
  exit 1
fi
echo "doc-phase2-close manifest OK"

ANCHORS_OK=1
COOKBOOK_OK=0
SKIP=0

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

if SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu-c && echo ./compiler/shu-c || true)"; then
  :
elif SHU_BIN="$(stdlib_cm_native_shu ./compiler/shu && echo ./compiler/shu || true)"; then
  :
else
  SHU_BIN=""
fi

if [ -n "$SHU_BIN" ]; then
  echo "=== DOC-008: cookbook HTTP-02 typeck ==="
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  if ! "$SHU_BIN" check -L . "$COOKBOOK" >/dev/null 2>&1; then
    echo "doc-phase2-close gate FAIL: typeck $COOKBOOK" >&2
    "$SHU_BIN" check -L . "$COOKBOOK" 2>&1 | tail -8 >&2 || true
    doc_phase2_close_emit_report "fail" "$ANCHORS_OK" 0 0
    exit 1
  fi
  COOKBOOK_OK=1
else
  echo "doc-phase2-close gate SKIP typeck (no native shu)" >&2
  SKIP=1
fi

doc_phase2_close_emit_report "ok" "$ANCHORS_OK" "$COOKBOOK_OK" "$SKIP"
echo "doc-phase2-close gate OK"
