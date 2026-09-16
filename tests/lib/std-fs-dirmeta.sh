#!/usr/bin/env bash
# std-fs-dirmeta.sh — STD-123 manifest + smoke helpers.
#
# Usage (after source):
#   std_fs_dirmeta_symbols_ok MOD_X FS_IMPL TSV
#   std_fs_dirmeta_run_x_smoke XLANG_BIN SRC
#   std_fs_dirmeta_run_c_smoke FS_O
#   std_fs_dirmeta_emit_report status run obs skip
# Honesty: run=/obs=/skip= (check/C = obs; prefer asm product -o hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_FS_DIRMETA_PREFIX="${XLANG_STD123_FS_DIRMETA_PREFIX:-xlang: [XLANG_STD123_FS_DIRMETA]}"

# Validate manifest api/symbol/smoke; echo miss count; return 0 iff miss==0.
std_fs_dirmeta_symbols_ok() {
  local mod_x="$1"
  local fs_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        [ "$path" = "std/fs/posix.x" ] && path="$fs_c"
        grep -qF "$anchor" "$path" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: mkdir/stat/rmdir against an existing fs object.
# Refuse soft ensure rebuild (gate never rebuilds host .o).
# PLATFORM: SHARED archaeology — host-C path is observational only.
std_fs_dirmeta_run_c_smoke() {
  local fs_o="$1"
  local out="/tmp/xlang_std_fs_dirmeta_c_$$"
  cc -std=c11 -O1 -o "$out" tests/fs/dirmeta_smoke_ok.c "$fs_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# Compile and run dirmeta smoke .x via product XLANG_BIN -L . -o; expect exit 0.
# Refuse soft RUN_XLANG remap / soft ensure rebuild (gate pins XLANG_LINK_XLANG).
# PLATFORM: SHARED archaeology — product honesty path.
std_fs_dirmeta_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_fs_dirmeta_x_$$"
  local log="/tmp/xlang_std_fs_dirmeta_x_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-fs-dirmeta FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-fs-dirmeta FAIL: compile $src" >&2
    tail -n 10 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-fs-dirmeta FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Hard-green signal is product -o dirmeta_roundtrip.x; check/C = obs.
std_fs_dirmeta_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_FS_DIRMETA_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
