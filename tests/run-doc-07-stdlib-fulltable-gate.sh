#!/usr/bin/env bash
# DOC-007：docs/07 标准库全表与 STBL-002 同步门禁
#
# 用法：./tests/run-doc-07-stdlib-fulltable-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_DOC07_DOC:-analysis/doc-07-stdlib-fulltable-v1.md}"
MANIFEST="${SHU_DOC07_TSV:-tests/baseline/doc-07-stdlib-fulltable.tsv}"
README="std/README.md"
DOC07="docs/07-内置与标准库.md"
MIN_README=43
MIN_DOC=43

# shellcheck source=tests/lib/doc-07-stdlib-fulltable.sh
. tests/lib/doc-07-stdlib-fulltable.sh

echo "=== DOC-007: docs/07 std fulltable manifest ==="
for f in "$DOC" "$MANIFEST" "$README" "$DOC07"; do
  if [ ! -f "$f" ]; then
    echo "doc-07-stdlib-fulltable gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_readme_anchors) MIN_README="$c2" ;;
    min_doc_anchors) MIN_DOC="$c2" ;;
  esac
done < "$MANIFEST"

for kw in STBL-002 DOC-007 scheduler.c spawn_simple; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-07-stdlib-fulltable gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

forbid_miss="$(doc07_forbidden_ok "$README" "$DOC07" "$MANIFEST" || true)"
sect_miss="$(doc07_sections_ok "$DOC07" "$MANIFEST" || true)"
split="$(doc07_anchor_miss_split "$README" "$DOC07" "$MANIFEST")"
readme_miss="${split%% *}"
doc_miss="${split#* }"

# 统计锚点数以满足 min 阈值
readme_cnt=0
doc_cnt=0
while IFS=$'\t' read -r item_id kind anchor target _notes; do
  [ "$kind" = "anchor" ] || continue
  case "$target" in
    readme|both)
      if grep -qF "$anchor" "$README" 2>/dev/null; then
        readme_cnt=$((readme_cnt + 1))
      fi
      ;;
  esac
  case "$target" in
    docs07|both)
      if grep -qF "$anchor" "$DOC07" 2>/dev/null; then
        doc_cnt=$((doc_cnt + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$readme_cnt" -lt "$MIN_README" ]; then
  echo "doc-07-stdlib-fulltable gate FAIL: readme anchors=${readme_cnt} < min ${MIN_README}" >&2
  exit 1
fi
if [ "$doc_cnt" -lt "$MIN_DOC" ]; then
  echo "doc-07-stdlib-fulltable gate FAIL: docs/07 anchors=${doc_cnt} < min ${MIN_DOC}" >&2
  exit 1
fi

if [ "${forbid_miss:-0}" -gt 0 ] || [ "${sect_miss:-0}" -gt 0 ] || [ "${readme_miss:-0}" -gt 0 ] || [ "${doc_miss:-0}" -gt 0 ]; then
  doc07_emit_report "fail" "${forbid_miss:-0}" "$readme_miss" "$doc_miss"
  echo "doc-07-stdlib-fulltable gate FAIL" >&2
  exit 1
fi

doc07_emit_report "ok" 0 0 0
echo "doc-07-stdlib-fulltable manifest OK (readme_anchors=${readme_cnt} doc_anchors=${doc_cnt})"
echo "doc-07-stdlib-fulltable gate OK"
