#!/usr/bin/env bash
# std-xplat-deep-boundary.sh — STD-138 three-platform deep-boundary helpers.
#
# Usage (after source):
#   xplat_deep_platform_policy linux macos windows
#   xplat_deep_verify_paths TSV MIN_ROWS
#   xplat_deep_run_smoke XLANG_BIN SRC
#   xplat_deep_emit_report status check_ok x_ok skip
# 2026-08-26: report check=/x=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_XPLAT_DEEP_PREFIX="${XLANG_STD138_XPLAT_DEEP_BOUNDARY_PREFIX:-xlang: [XLANG_STD138_XPLAT_DEEP_BOUNDARY]}"

# Return the policy column for the current host (linux/macos/windows).
# @param $1 linux policy
# @param $2 macos policy
# @param $3 windows policy
xplat_deep_platform_policy() {
  # shellcheck source=tests/lib/ci-host.sh
  . "$(dirname "${BASH_SOURCE[0]:-$0}")/ci-host.sh"
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
}

# Verify manifest paths exist; echo missing count; return 0 when miss==0.
# @param $1 tsv path
# @param $2 min_rows
xplat_deep_verify_paths() {
  local tsv="$1"
  local min_rows="$2"
  local miss=0
  local rows=0
  local item_id kind path _l _m _w _notes
  while IFS=$'\t' read -r item_id kind path _l _m _w _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    rows=$((rows + 1))
    if [ ! -f "$path" ]; then
      echo "xplat-deep FAIL: missing $path ($item_id)" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  if [ "$rows" -lt "$min_rows" ]; then
    echo "xplat-deep FAIL: rows=${rows} < min ${min_rows}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Count matrix TSV data rows (exclude # and min_*).
# @param $1 tsv path
xplat_deep_matrix_rows() {
  local tsv="$1"
  local n=0
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
      min_*) continue ;;
    esac
    n=$((n + 1))
  done < "$tsv"
  echo "$n"
}

# Build+run one .x smoke; return 0 when process exits 0.
# Prefers RUN_XLANG when caller pinned XLANG_LINK_XLANG via bootstrap-link.
# @param $1 XLANG_BIN — resolved product compiler (prefer asm)
# @param $2 SRC — .x smoke path
xplat_deep_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_xplat_deep_$$"
  local log="${exe}.log"
  # Prefer bootstrap-link RUN_XLANG when caller pinned XLANG_LINK_XLANG.
  # PLATFORM: SHARED — product path honesty.
  local runner="${RUN_XLANG:-}"
  if [ -z "$runner" ]; then
    runner="$xlang"
  fi
  if ! $runner -L . "$src" -o "$exe" 2>"$log"; then
    echo "xplat-deep FAIL: compile $src" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "xplat-deep FAIL: $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; x runnable hard; skip only
# for manifest-only paths — never soft-OK when no native compiler).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 x_ok — all must-policy smokes exit0 (hard green)
# @param $4 skip — 1 only for manifest-only
xplat_deep_emit_report() {
  local status="$1"
  local check_ok="$2"
  local x_ok="$3"
  local skip="$4"
  echo "${STD_XPLAT_DEEP_PREFIX} status=${status} check=${check_ok} x=${x_ok} skip=${skip}"
}
