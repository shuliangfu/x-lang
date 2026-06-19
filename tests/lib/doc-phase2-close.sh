#!/usr/bin/env bash
# doc-phase2-close.sh — DOC-008 manifest 校验与报告
#
# 用法（source 后）：
#   doc_phase2_close_check MANIFEST
#   doc_phase2_close_emit_report status anchors_ok cookbook_ok skip

DOC_PHASE2_CLOSE_PREFIX="${SHUX_DOC08_PREFIX:-shux: [SHUX_DOC08_PHASE2_CLOSE]}"

# 校验 manifest 锚点；echo 缺失数。
doc_phase2_close_check() {
  local tsv="$1"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|anchor)
        local target="${mod_path:-$anchor}"
        if [ ! -f "$target" ]; then
          echo "doc-phase2-close FAIL: missing file $target" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "doc-phase2-close FAIL: $target missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      recipe|file)
        if [ ! -f "$anchor" ]; then
          echo "doc-phase2-close FAIL: missing $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "doc-phase2-close FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "doc-phase2-close FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "doc-phase2-close FAIL: $mod_path missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$mod_path" ]; then
          echo "doc-phase2-close FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
doc_phase2_close_emit_report() {
  local status="$1"
  local anchors_ok="$2"
  local cookbook_ok="$3"
  local skip="$4"
  echo "${DOC_PHASE2_CLOSE_PREFIX} status=${status} anchors=${anchors_ok} cookbook=${cookbook_ok} skip=${skip}"
}
