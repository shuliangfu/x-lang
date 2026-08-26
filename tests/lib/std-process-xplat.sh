#!/usr/bin/env bash
# std-process-xplat.sh — STD-142 manifest and smoke helpers (honesty).
# PLATFORM: SHARED archaeology.

STD_PROC_XPLAT_PREFIX="${XLANG_STD142_PROCESS_XPLAT_PREFIX:-xlang: [XLANG_STD142_PROCESS_XPLAT]}"

# Validate manifest anchors; echo miss count; return 0 iff miss==0.
# Section/file rows use the TSV mod_path column (archive DOC live path).
std_process_xplat_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-process-xplat FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|file|script)
        if [ ! -f "$anchor" ]; then
          echo "std-process-xplat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local path="${mod_path:-analysis/archive/std/std-process-xplat-v1.md}"
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-process-xplat FAIL: missing section '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Validate vector TSV has at least min_rows data rows.
std_process_xplat_vectors_ok() {
  local tsv="$1"
  local min_rows="${2:-10}"
  local n=0
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
      min_*) continue ;;
    esac
    n=$((n + 1))
  done < "$tsv"
  if [ "$n" -lt "$min_rows" ]; then
    echo "std-process-xplat FAIL: vectors $n < min $min_rows" >&2
    return 1
  fi
  return 0
}

# Compile and run one .x smoke; hard-fail on non-zero exit.
std_process_xplat_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_proc_xplat_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-process-xplat FAIL: compile $src" >&2
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-process-xplat FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Emit structured report line (honesty: check=/xplat=/boundary=/skip=).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 xplat_ok — xplat_behavior.x exit0 (hard)
# @param $4 boundary_ok — boundary.x exit0 (hard)
# @param $5 skip — 1 only when no native xlang / manifest-only
std_process_xplat_emit_report() {
  local status="$1"
  local check_ok="$2"
  local xplat_ok="$3"
  local boundary_ok="$4"
  local skip="$5"
  echo "${STD_PROC_XPLAT_PREFIX} status=${status} check=${check_ok} xplat=${xplat_ok} boundary=${boundary_ok} skip=${skip}"
}
