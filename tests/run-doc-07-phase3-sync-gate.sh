#!/usr/bin/env bash
# STD-171：docs/07 + Cookbook Phase 3 同步门禁（§11 #78～#83）
#
# 用法：./tests/run-doc-07-phase3-sync-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/doc-07-phase3-sync-v1.md"
MANIFEST="tests/baseline/doc-07-phase3-sync.tsv"
DOC07="docs/07-内置与标准库.md"
COOKBOOK_DOC="analysis/doc-cookbook-expand-v1.md"
LIB="tests/lib/doc-07-phase3-sync.sh"

# shellcheck source=tests/lib/doc-07-phase3-sync.sh
. "$LIB"
# shellcheck source=tests/lib/doc-cookbook.sh
. tests/lib/doc-cookbook.sh

echo "=== STD-171: docs/07 Phase 3 sync manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DOC07" "$COOKBOOK_DOC"; do
  if [ ! -f "$f" ]; then
    echo "doc-07-phase3-sync gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-171 await_read_fd timezone_iana compress_format_brotli row_col_blob_read; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-07-phase3-sync gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "## std Phase 3 增量" "$DOC07" 2>/dev/null; then
  echo "doc-07-phase3-sync gate FAIL: docs/07 missing Phase 3 section" >&2
  exit 1
fi

sym_miss="$(doc07_phase3_symbols_ok "$DOC07" "$COOKBOOK_DOC" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  doc07_phase3_emit_report "fail" 0 0
  exit 1
fi
echo "doc-07-phase3-sync registry OK"

CHECK_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  while IFS=$'\t' read -r item_id kind anchor _t _n; do
    [ "$kind" = "recipe" ] || continue
    if doc_cb_check_recipe "$SHUX_BIN" "$anchor"; then
      echo "doc-07-phase3-sync typeck OK $anchor"
    else
      doc07_phase3_emit_report "fail" 0 0
      exit 1
    fi
  done < "$MANIFEST"
  CHECK_OK=1
else
  SKIP=1
fi

doc07_phase3_emit_report "ok" "$CHECK_OK" "$SKIP"
echo "doc-07-phase3-sync gate OK"
