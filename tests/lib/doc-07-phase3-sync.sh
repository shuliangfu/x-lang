#!/usr/bin/env bash
# doc-07-phase3-sync.sh — STD-171 manifest 与食谱 typeck 辅助

STD171_PREFIX="${SHUX_STD171_DOC07_PHASE3_SYNC_PREFIX:-shux: [SHUX_STD171_DOC07_PHASE3_SYNC]}"

# 校验 manifest 条目；echo 缺失数。
doc07_phase3_symbols_ok() {
  local doc07="$1"
  local cookbook_doc="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor target
  while IFS=$'\t' read -r item_id kind anchor target _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      section)
        local f="analysis/doc-07-phase3-sync-v1.md"
        if ! grep -qF "$anchor" "$f" 2>/dev/null; then
          echo "doc-07-phase3-sync FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      keyword)
        if ! grep -qF "$anchor" "$doc07" 2>/dev/null; then
          echo "doc-07-phase3-sync FAIL: docs/07 missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      recipe)
        if [ ! -f "$anchor" ]; then
          echo "doc-07-phase3-sync FAIL: missing recipe $anchor" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$cookbook_doc" 2>/dev/null; then
          echo "doc-07-phase3-sync FAIL: cookbook doc missing $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "doc-07-phase3-sync FAIL: missing file $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "tests/$anchor" ]; then
          echo "doc-07-phase3-sync FAIL: missing script tests/$anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出门禁报告行。
doc07_phase3_emit_report() {
  local status="$1"
  local check_ok="$2"
  local skip="$3"
  echo "${STD171_PREFIX} status=${status} check=${check_ok} skip=${skip}"
}
