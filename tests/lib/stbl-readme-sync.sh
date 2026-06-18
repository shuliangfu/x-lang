#!/usr/bin/env bash
# stbl-readme-sync.sh — STBL-002：README 漂移检测辅助
#
# 用法（source 后）：
#   stbl_readme_forbidden_ok README TSV
#   stbl_readme_anchors_ok README TSV
#   stbl_readme_emit_report status forbidden_miss anchor_miss

STBL_README_PREFIX="${SHU_STBL_README_PREFIX:-shu: [SHU_STBL_README]}"

# 扫描禁止措辞；命中返回 1 并 echo 命中数。
stbl_readme_forbidden_ok() {
  local readme="$1"
  local tsv="$2"
  local miss=0
  local phrase
  while IFS=$'\t' read -r item_id kind anchor _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      forbidden)
        phrase="$anchor"
        if grep -qF "$phrase" "$readme" 2>/dev/null; then
          echo "stbl-readme FAIL: forbidden phrase '$phrase'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验必需锚点；缺失返回 1。
stbl_readme_anchors_ok() {
  local readme="$1"
  local tsv="$2"
  local miss=0
  local min=1
  while IFS=$'\t' read -r c1 c2 _rest; do
    c1="${c1#\# }"
    case "$c1" in
      min_anchors) min="$c2" ;;
    esac
  done < "$tsv"
  local anchor
  while IFS=$'\t' read -r item_id kind anchor _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      anchor)
        if ! grep -qF "$anchor" "$readme" 2>/dev/null; then
          echo "stbl-readme FAIL: missing anchor '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  local found=$((min - miss))
  [ "$found" -lt 0 ] && found=0
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
stbl_readme_emit_report() {
  local status="$1"
  local forbidden_miss="$2"
  local anchor_miss="$3"
  echo "${STBL_README_PREFIX} status=${status} forbidden=${forbidden_miss} anchors_miss=${anchor_miss}"
}
