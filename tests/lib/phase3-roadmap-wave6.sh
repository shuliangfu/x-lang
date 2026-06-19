#!/usr/bin/env bash
# phase3-roadmap-wave6.sh — PLAN-006 第六批路线图 manifest 校验与报告
#
# 用法（source 后）：
#   phase3_roadmap_wave6_check MANIFEST NEXT_MD
#   phase3_roadmap_wave6_task_count MANIFEST
#   phase3_roadmap_wave6_done_count NEXT_MD
#   phase3_roadmap_wave6_emit_report status tasks_ok sections_ok done_ok

PHASE3_WAVE6_PREFIX="${SHUX_PLAN006_PREFIX:-shux: [SHUX_PLAN006_PHASE3_W6]}"

# 校验 manifest；echo 缺失数。
phase3_roadmap_wave6_check() {
  local tsv="$1"
  local next_md="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      section)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "phase3-roadmap-wave6 FAIL: $mod_path missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      task)
        if ! grep -qF "$anchor" "$next_md" 2>/dev/null; then
          echo "phase3-roadmap-wave6 FAIL: $next_md missing task '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      gate_ref)
        if [ ! -f "$mod_path" ]; then
          echo "phase3-roadmap-wave6 FAIL: missing gate $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "phase3-roadmap-wave6 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "phase3-roadmap-wave6 FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|script)
        if [ ! -f "$mod_path" ]; then
          echo "phase3-roadmap-wave6 FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 统计 manifest 中 task 行数。
phase3_roadmap_wave6_task_count() {
  local tsv="$1"
  local n=0
  local item_id kind
  while IFS=$'\t' read -r item_id kind _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    [ "$kind" = "task" ] && n=$((n + 1))
  done < "$tsv"
  echo "$n"
}

# 统计 §2.17 表中已标 ✅ 的 wave6 task 数。
phase3_roadmap_wave6_done_count() {
  local next_md="$1"
  local n=0
  local tid
  for tid in BOOT-025 COMP-019 STD-067 PLAN-006; do
    if grep -F "| ${tid} |" "$next_md" 2>/dev/null | grep -qF '| ✅ |'; then
      n=$((n + 1))
    fi
  done
  echo "$n"
}

# 输出结构化报告行。
phase3_roadmap_wave6_emit_report() {
  local status="$1"
  local tasks_ok="$2"
  local sections_ok="$3"
  local done_ok="$4"
  echo "${PHASE3_WAVE6_PREFIX} status=${status} tasks=${tasks_ok} sections=${sections_ok} done=${done_ok}"
}
