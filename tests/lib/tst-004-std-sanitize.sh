#!/usr/bin/env bash
# tst-004-std-sanitize.sh — TST-004: std ASAN nightly helpers (honesty soft→硬绿).
#
# Usage (source):
#   tst004_sanitize_ensure_o rel_o
#   tst004_sanitize_run_case XLANG_BIN src tag
#   tst004_sanitize_verify_manifest TSV DOC
#   tst004_sanitize_emit_report status run obs skip
# PLATFORM: LINUX ASAN primary; Darwin/Windows = skip (platform N/A).

TST004_SAN_PREFIX="${XLANG_TST004_SANITIZE_PREFIX:-xlang: [XLANG_TST004_SANITIZE]}"
TST004_DOC_DEFAULT="analysis/archive/tst/tst-004-std-sanitize-v1.md"

# shellcheck source=tests/lib/safe-leak.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/safe-leak.sh"

# Build std C .o on demand (relative to compiler/).
tst004_sanitize_ensure_o() {
  local rel="$1"
  [ -z "$rel" ] || [ "$rel" = "-" ] && return 0
  # shellcheck source=tests/lib/build-std-c-o.sh
  . "$(dirname "${BASH_SOURCE[0]:-$0}")/build-std-c-o.sh"
  ensure_std_c_o "$rel"
}

# Compile and run one .x under ASAN; success 0, failure 1.
tst004_sanitize_run_case() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-case}"
  safe_leak_run_x "$xlang" "$src" "$tag"
}

# Verify manifest files and case rows; echo miss count.
# @param tsv path
# @param doc path (archive DOC; default TST004_DOC_DEFAULT)
tst004_sanitize_verify_manifest() {
  local tsv="$1"
  local doc="${2:-$TST004_DOC_DEFAULT}"
  local miss=0
  local item_id kind anchor src needs_o
  while IFS=$'\t' read -r item_id kind anchor src needs_o _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*|min_*|lib|runner|gate) continue ;;
    esac
    case "$kind" in
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "tst-004-sanitize FAIL: doc missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      case)
        if [ ! -f "$src" ]; then
          echo "tst-004-sanitize FAIL: missing case $src" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "tst-004-sanitize FAIL: missing xref $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$src" ]; then
          echo "tst-004-sanitize FAIL: missing script $src" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Emit structured report line (honesty: run=/obs=/skip=).
tst004_sanitize_emit_report() {
  local status="$1"
  local run="${2:-0}"
  local obs="${3:-0}"
  local skip="${4:-0}"
  echo "${TST004_SAN_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip}"
}
