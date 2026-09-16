#!/usr/bin/env bash
# doc-phase2-close.sh — DOC-008 manifest helpers.
#
# Usage (after source):
#   doc_phase2_close_check MANIFEST
#   doc_phase2_close_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.

DOC_PHASE2_CLOSE_PREFIX="${XLANG_DOC08_PREFIX:-xlang: [XLANG_DOC08_PHASE2_CLOSE]}"

# Validate manifest anchors; echo miss count; return 0 when miss=0.
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

# Structured report: run=/obs=/skip= (honesty wave 2026-08-28).
doc_phase2_close_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${DOC_PHASE2_CLOSE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
