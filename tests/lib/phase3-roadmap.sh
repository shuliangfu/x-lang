#!/usr/bin/env bash
# phase3-roadmap.sh — PLAN-001 manifest 校验与报告
#
# 用法（source 后）：
#   phase3_roadmap_check MANIFEST NEXT_MD
#   phase3_roadmap_emit_report status tasks_ok sections_ok

PHASE3_ROADMAP_PREFIX="${SHUX_PLAN001_PREFIX:-shux: [SHUX_PLAN001_PHASE3]}"

# 校验 manifest；echo 缺失数。
phase3_roadmap_check() {
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
          echo "phase3-roadmap FAIL: $mod_path missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      task)
        if ! grep -qF "$anchor" "$next_md" 2>/dev/null; then
          echo "phase3-roadmap FAIL: $next_md missing task '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "phase3-roadmap FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "phase3-roadmap FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|script)
        if [ ! -f "$mod_path" ]; then
          echo "phase3-roadmap FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 统计 manifest 中 task 行数。
phase3_roadmap_task_count() {
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

# 输出结构化报告行。
phase3_roadmap_emit_report() {
  local status="$1"
  local tasks_ok="$2"
  local sections_ok="$3"
  echo "${PHASE3_ROADMAP_PREFIX} status=${status} tasks=${tasks_ok} sections=${sections_ok}"
}
