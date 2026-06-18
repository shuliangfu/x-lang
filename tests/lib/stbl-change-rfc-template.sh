#!/usr/bin/env bash
# stbl-change-rfc-template.sh — STBL-003：RFC 模板完整性校验辅助
#
# 用法（source 后）：
#   stbl_crfc_sections_ok TEMPLATE TSV
#   stbl_crfc_examples_ok TSV
#   stbl_crfc_emit_report status sections examples

STBL_CRFC_PREFIX="${SHU_STBL_CHANGE_RFC_PREFIX:-shu: [SHU_STBL_CHANGE_RFC]}"

# 校验模板含 manifest 所列 section 锚点；echo 缺失数。
stbl_crfc_sections_ok() {
  local template="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*|min_*|template|meta_doc|example_*|lib|gate) continue ;;
    esac
    case "$kind" in
      anchor)
        if ! grep -qF "$anchor" "$template" 2>/dev/null; then
          echo "stbl-change-rfc FAIL: template missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验示例 RFC 文件存在。
stbl_crfc_examples_ok() {
  local tsv="$1"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      ref)
        if [ ! -f "$anchor" ]; then
          echo "stbl-change-rfc FAIL: missing example '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
stbl_crfc_emit_report() {
  local status="$1"
  local sections="$2"
  local examples="$3"
  echo "${STBL_CRFC_PREFIX} status=${status} sections=${sections} examples=${examples}"
}
