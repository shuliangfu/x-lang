#!/usr/bin/env bash
# std-backtrace-xplat.sh — STD-147 manifest + xplat quality helpers.
#
# Usage (after source):
#   std_backtrace_xplat_symbols_ok BT_RUNTIME TSV
#   std_backtrace_xplat_pick_vector VECTORS_TSV
#   std_backtrace_xplat_run_smoke   # prebuilt .o only; refuse soft auto-make
#   std_backtrace_xplat_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.
# Honesty: refuse soft auto-make / soft SKIP→OK; report run=/obs=/skip=.

STD147_PREFIX="${XLANG_STD147_BACKTRACE_XPLAT_PREFIX:-xlang: [XLANG_STD147_BACKTRACE_XPLAT]}"

# Validate manifest anchors. Echo miss count; return 0 when miss=0.
# section kind uses TSV mod_path (archive DOC); refuse fossil top-level path hardcode.
std_backtrace_xplat_symbols_ok() {
  local bt_c="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        if ! grep -qF "$anchor" "$bt_c" 2>/dev/null; then
          echo "std-backtrace-xplat FAIL: missing '$anchor' in $bt_c" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if [ ! -f "$mod_path" ] || ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-backtrace-xplat FAIL: missing section '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          echo "std-backtrace-xplat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Pick host vector row; echo "min_gold min_resolved min_total".
std_backtrace_xplat_pick_vector() {
  local tsv="$1"
  local os
  os="$(uname -s 2>/dev/null || echo Unknown)"
  while IFS=$'\t' read -r _vid pat min_gold min_resolved min_total _notes; do
    [ -z "${pat:-}" ] && continue
    case "$pat" in \#*) continue ;; esac
    case "$os" in
      Darwin)
        if [ "$pat" = "Darwin" ]; then
          echo "$min_gold $min_resolved $min_total"
          return 0
        fi
        ;;
      Linux)
        if [ "$pat" = "Linux" ]; then
          echo "$min_gold $min_resolved $min_total"
          return 0
        fi
        ;;
      MINGW*|MSYS*|CYGWIN*)
        if [[ "$pat" == *MINGW* ]] || [[ "$pat" == *MSYS* ]] || [[ "$pat" == *CYGWIN* ]] || [[ "$pat" == *Windows* ]]; then
          echo "$min_gold $min_resolved $min_total"
          return 0
        fi
        ;;
    esac
  done < "$tsv"
  echo "0 0 0"
  return 1
}

# Compile+run xplat_quality.c against prebuilt .o only.
# Refuse soft xlang_compiler_make / ensure rebuild. Return 0 on quality OK.
# PLATFORM: SHARED — Darwin export_dynamic / Linux -rdynamic -ldl / Windows Cap (no dbghelp).
std_backtrace_xplat_run_smoke() {
  local src="tests/backtrace/xplat_quality.c"
  local out="/tmp/xlang_backtrace_xplat_$$"
  local err="/tmp/xlang_backtrace_xplat_err_$$.log"
  local bt_o="std/backtrace/backtrace.o"
  local rt_o="compiler/runtime_backtrace_platform.o"
  if [ ! -f "$bt_o" ]; then
    echo "std-backtrace-xplat OBS: missing prebuilt $bt_o (refuse soft ensure)" >&2
    return 1
  fi
  if [ ! -f "$rt_o" ]; then
    echo "std-backtrace-xplat OBS: missing prebuilt $rt_o (refuse soft auto-make)" >&2
    return 1
  fi
  local extra=()
  case "$(uname -s)" in
    Linux) extra=(-rdynamic -ldl) ;;
    Darwin) extra=(-Wl,-export_dynamic) ;;
    MINGW*|MSYS*|CYGWIN*) extra=(-lkernel32) ;;
  esac
  if ! cc -std=c11 -g -O0 -fno-omit-frame-pointer -o "$out" "$src" "$bt_o" "$rt_o" "${extra[@]}" 2>/dev/null; then
    echo "std-backtrace-xplat OBS: compile/link $src (UNDEF/residual; refuse soft ensure)" >&2
    return 1
  fi
  set +e
  "$out" 2>"$err"
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-backtrace-xplat OBS: smoke exit=$ec" >&2
    return 1
  fi
  if ! grep -qF 'xlang: [XLANG_BT_XPLAT]' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-backtrace-xplat OBS: missing quality line" >&2
    return 1
  fi
  rm -f "$err"
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired quality=/host=).
std_backtrace_xplat_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD147_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
