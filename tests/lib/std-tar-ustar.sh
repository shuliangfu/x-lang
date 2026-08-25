#!/usr/bin/env bash
# std-tar-ustar.sh — STD-038 manifest + smoke helpers
#
# Usage (after source):
#   std_tar_ustar_symbols_ok MOD_X TAR_X TSV
#   std_tar_ustar_run_smoke XLANG_BIN X TAG
#   std_tar_ustar_emit_report status check_ok rt_ok main_ok skip
# 2026-08-26: report check=/rt=/main=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_TAR_USTAR_PREFIX="${XLANG_STD_TAR_USTAR_PREFIX:-xlang: [XLANG_STD_TAR_USTAR]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_tar_ustar_symbols_ok() {
  local mod_x="$1"
  local tar_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-tar-ustar FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/tar/tar.x) mod_path="$tar_x" ;;
          std/tar/tar_glue.c) mod_path="$tar_x" ;;
          *) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-tar-ustar FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-tar-ustar FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script)
        # DOC ## 5. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_tar_ustar_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_tar_ustar_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-tar-ustar FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-tar-ustar FAIL: compile $src" >&2
      $RUN_XLANG build -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-tar-ustar FAIL: compile $src" >&2
      "$xlang" -L . "$src" 2>&1 | tail -8 >&2 || true
      rm -f "$exe"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-tar-ustar FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/rt=/main=/skip=).
# Hard-green signal = rt= + main=; check observational.
std_tar_ustar_emit_report() {
  local status="$1"
  local check_ok="$2"
  local rt_ok="$3"
  local main_ok="$4"
  local skip="$5"
  echo "${STD_TAR_USTAR_PREFIX} status=${status} check=${check_ok} rt=${rt_ok} main=${main_ok} skip=${skip}"
}
