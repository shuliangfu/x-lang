#!/usr/bin/env bash
# std-strview-zc4.sh — STD-016: StrView/ZC-4 manifest helpers
#
# Usage (after source):
#   std_sv_zc4_manifest_ok STRING_X DOC TSV
#   std_sv_zc4_run_smoke XLANG_BIN smoke_x tag
#   std_sv_zc4_emit_report status check_ok life_ok sub_ok arena_ok sso_ok zc4_ok skip
# 2026-08-26: report check=/life=/sub=/arena=/sso=/zc4=/skip=
# (honesty; prefer asm runnable hard; check+zc4 observational).
# PLATFORM: SHARED archaeology.

STD_SV_ZC4_PREFIX="${XLANG_STD_STRVIEW_ZC4_PREFIX:-xlang: [XLANG_STD_STRVIEW_ZC4]}"

# Validate manifest symbol/anchor/file; echo miss count; return 0 iff miss==0.
std_sv_zc4_manifest_ok() {
  local string_x="$1"
  local doc="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$string_x" 2>/dev/null; then
          echo "std-strview-zc4 FAIL: missing symbol '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      anchor|section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-strview-zc4 FAIL: doc missing anchor '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$anchor" ]; then
          echo "std-strview-zc4 FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
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
std_sv_zc4_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_sv_zc4_${tag}_$$"
  local log="/tmp/xlang_std_sv_zc4_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-strview-zc4 FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-strview-zc4 FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-strview-zc4 FAIL: compile $src" >&2
      tail -12 "$log" 2>/dev/null >&2 || true
      rm -f "$exe" "$log"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-strview-zc4 FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/life=/sub=/arena=/sso=/zc4=/skip=).
std_sv_zc4_emit_report() {
  local status="$1"
  local check_ok="$2"
  local life_ok="$3"
  local sub_ok="$4"
  local arena_ok="$5"
  local sso_ok="$6"
  local zc4_ok="$7"
  local skip="$8"
  echo "${STD_SV_ZC4_PREFIX} status=${status} check=${check_ok} life=${life_ok} sub=${sub_ok} arena=${arena_ok} sso=${sso_ok} zc4=${zc4_ok} skip=${skip}"
}
