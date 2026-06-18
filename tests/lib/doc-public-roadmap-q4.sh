#!/usr/bin/env bash
# doc-public-roadmap-q4.sh — DOC-010 Q4 刷新校验与报告
#
# 用法（source 后）：
#   doc_roadmap_q4_check MANIFEST
#   doc_roadmap_q4_emit_report status quarter roadmap_gate_ok

DOC_ROADMAP_Q4_PREFIX="${SHU_DOC010_PREFIX:-shu: [SHU_DOC010_ROADMAP_Q4]}"

# 校验 manifest 锚点与交叉引用；echo 缺失数。
doc_roadmap_q4_check() {
  local tsv="$1"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      anchor)
        if [ ! -f "$mod_path" ]; then
          echo "doc-public-roadmap-q4 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "doc-public-roadmap-q4 FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "doc-public-roadmap-q4 FAIL: $mod_path missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref|file)
        if [ ! -f "$mod_path" ]; then
          echo "doc-public-roadmap-q4 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif [ "$kind" = "cross_ref" ] && ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "doc-public-roadmap-q4 FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      hook_script|script)
        if [ ! -f "$mod_path" ]; then
          echo "doc-public-roadmap-q4 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
doc_roadmap_q4_emit_report() {
  local status="$1"
  local quarter="$2"
  local roadmap_gate_ok="$3"
  echo "${DOC_ROADMAP_Q4_PREFIX} status=${status} quarter=${quarter} roadmap_gate=${roadmap_gate_ok}"
}
