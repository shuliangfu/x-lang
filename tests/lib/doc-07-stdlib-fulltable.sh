#!/usr/bin/env bash
# doc-07-stdlib-fulltable.sh — DOC-007：std/README 与 docs/07 漂移检测辅助
#
# 用法（source 后）：
#   doc07_forbidden_ok README DOC07 TSV
#   doc07_sections_ok DOC07 TSV
#   doc07_anchor_miss_split README DOC07 TSV
#   doc07_emit_report status forbidden_miss readme_miss doc_miss

DOC07_PREFIX="${SHU_DOC07_PREFIX:-shu: [SHU_DOC07]}"

# 按 target 列扫描禁止措辞；echo 命中数。
doc07_forbidden_ok() {
  local readme="$1"
  local doc07="$2"
  local tsv="$3"
  local miss=0
  local phrase target f
  while IFS=$'\t' read -r item_id kind anchor target _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      forbidden)
        phrase="$anchor"
        case "$target" in
          readme) f="$readme" ;;
          docs07) f="$doc07" ;;
          *) continue ;;
        esac
        if grep -qF "$phrase" "$f" 2>/dev/null; then
          echo "doc-07 FAIL: forbidden '$phrase' in $f" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验 docs/07 必需章节；echo 缺失数。
doc07_sections_ok() {
  local doc07="$1"
  local tsv="$2"
  local miss=0
  local anchor
  while IFS=$'\t' read -r item_id kind anchor target _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      section)
        case "$target" in
          docs07)
            if ! grep -qF "$anchor" "$doc07" 2>/dev/null; then
              echo "doc-07 FAIL: docs/07 missing section '$anchor'" >&2
              miss=$((miss + 1))
            fi
            ;;
        esac
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 分别统计 README 与 docs/07 锚点缺失（用于报告细分）。
doc07_anchor_miss_split() {
  local readme="$1"
  local doc07="$2"
  local tsv="$3"
  local readme_miss=0
  local doc_miss=0
  local anchor target
  while IFS=$'\t' read -r item_id kind anchor target _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      anchor)
        case "$target" in
          readme|both)
            if ! grep -qF "$anchor" "$readme" 2>/dev/null; then
              readme_miss=$((readme_miss + 1))
            fi
            ;;
        esac
        case "$target" in
          docs07|both)
            if ! grep -qF "$anchor" "$doc07" 2>/dev/null; then
              doc_miss=$((doc_miss + 1))
            fi
            ;;
        esac
        ;;
    esac
  done < "$tsv"
  echo "$readme_miss $doc_miss"
}

# 输出结构化报告行。
doc07_emit_report() {
  local status="$1"
  local forbidden_miss="$2"
  local readme_miss="$3"
  local doc_miss="$4"
  echo "${DOC07_PREFIX} status=${status} forbidden=${forbidden_miss} readme_miss=${readme_miss} doc_miss=${doc_miss}"
}
