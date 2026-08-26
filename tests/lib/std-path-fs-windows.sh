#!/usr/bin/env bash
# std-path-fs-windows.sh — STD-021/022 manifest + smoke helpers (path/fs Windows align).
#
# Usage (after source):
#   std_pfw_symbols_ok PATH_X TSV
#   std_pfw_run_x_smoke XLANG_BIN SRC OUT_PREFIX EXPECT
#   std_pfw_emit_report status check_ok path_ok fs_ok skip
# 2026-08-26: report check=/path=/fs=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_PFW_PREFIX="${XLANG_STD_PATH_FS_WIN_PREFIX:-xlang: [XLANG_STD_PATH_FS_WIN]}"

# Validate manifest symbol/file/absent/section anchors.
# Echo miss count; return 0 when miss=0.
std_pfw_symbols_ok() {
  local path_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$path_x" 2>/dev/null; then
          echo "std-path-fs-windows FAIL: missing '$anchor' in $path_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script)
        if [ ! -f "$anchor" ]; then
          echo "std-path-fs-windows FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|anchor|doc)
        # DOC keyword / ## 4. Gate anchors are validated by the gate script.
        ;;
      absent)
        if [ -f "$anchor" ]; then
          echo "std-path-fs-windows FAIL: should not exist '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Build+run one .x smoke; return 0 when exit code matches expect.
# @param $1 XLANG_BIN — resolved product compiler
# @param $2 SRC — .x smoke path
# @param $3 OUT_PREFIX — /tmp prefix for binary + build log
# @param $4 EXPECT — expected process exit code (usually 0)
std_pfw_run_x_smoke() {
  local xlang_bin="$1"
  local src="$2"
  local out_prefix="$3"
  local expect="${4:-0}"
  local out="${out_prefix}"
  local log="${out_prefix}.log"
  # Prefer bootstrap-link RUN_XLANG when caller pinned XLANG_LINK_XLANG.
  # PLATFORM: SHARED — product path honesty.
  local runner="${RUN_XLANG:-}"
  if [ -z "$runner" ]; then
    runner="$xlang_bin"
  fi
  if ! $runner build -L . "$src" -o "$out" 2>"$log"; then
    echo "std-path-fs-windows FAIL: link $src" >&2
    tail -20 "$log" 2>/dev/null >&2 || true
    rm -f "$out"
    return 1
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out"
  if [ "$ec" -ne "$expect" ]; then
    echo "std-path-fs-windows FAIL: $src exit=$ec (expect $expect)" >&2
    return 1
  fi
  return 0
}

# Structured report line (check observational; path/fs runnable hard; skip only
# for manifest-only / no-binary paths).
# @param $1 status — ok|fail
# @param $2 check_ok — observational check (0/1; not hard green)
# @param $3 path_ok — windows_abs_join.x exit0 (hard green)
# @param $4 fs_ok — windows_path_smoke.x exit0 (hard green)
# @param $5 skip — 1 only for manifest-only / no-native paths
std_pfw_emit_report() {
  local status="$1"
  local check_ok="$2"
  local path_ok="$3"
  local fs_ok="$4"
  local skip="$5"
  echo "${STD_PFW_PREFIX} status=${status} check=${check_ok} path=${path_ok} fs=${fs_ok} skip=${skip}"
}
