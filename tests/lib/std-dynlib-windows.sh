#!/usr/bin/env bash
# std-dynlib-windows.sh — STD-027：dynlib Windows/POSIX manifest 辅助
#
# 用法（source 后）：
#   std_dynlib_win_manifest_ok DOC DYNLIB_C MOD_X TSV
#   std_dynlib_win_run_c_smoke
#   std_dynlib_win_emit_report status check_ok osc_ok null_ok win_path_ok [skip]
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_DYNLIB_WIN_PREFIX="${XLANG_STD_DYNLIB_WIN_PREFIX:-xlang: [XLANG_STD_DYNLIB_WIN]}"

# 校验 manifest：C 符号、.x API、RFC 节、文件锚；echo 缺失数。
std_dynlib_win_manifest_ok() {
  local doc="$1"
  local dynlib_c="$2"
  local mod_x="$3"
  local tsv="$4"
  local miss=0
  local item_id kind doc_anchor code_anchor src _notes
  while IFS=$'\t' read -r item_id kind doc_anchor code_anchor src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      code)
        if ! grep -qF "$code_anchor" "$dynlib_c" 2>/dev/null; then
          echo "std-dynlib-windows FAIL: runtime_dynlib_os missing '$code_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qE "function ${code_anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-dynlib-windows FAIL: missing function ${code_anchor} in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # Prefer TSV doc_anchor; for Gate honesty also accept code_anchor empty.
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-dynlib-windows FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        # Prefer src full path; fall back to tests/dynlib/<basename>.
        local fp="$src"
        if [ -z "$fp" ] || [ "$fp" = "-" ]; then
          fp="tests/dynlib/${code_anchor}"
        fi
        if [ ! -f "$fp" ]; then
          echo "std-dynlib-windows FAIL: missing file '$fp' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        local sp="$src"
        if [ -z "$sp" ] || [ "$sp" = "-" ]; then
          sp="tests/${code_anchor}"
        fi
        if [ ! -f "$sp" ]; then
          echo "std-dynlib-windows FAIL: missing script '$sp' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: win_path_smoke.c + dynlib.o + runtime_dynlib_os.o.
# Not hard green — host-C archaeology; product honesty is win_path.x via asm.
# PLATFORM: SHARED archaeology.
std_dynlib_win_run_c_smoke() {
  local src="tests/dynlib/win_path_smoke.c"
  local out="/tmp/xlang_std027_dynlib_winpath_c_$$"
  local dyn_o="std/dynlib/dynlib.o"
  local rt_o="compiler/runtime_dynlib_os.o"
  local ld_extra=""
  if [ ! -f "$dyn_o" ] || [ ! -f "$rt_o" ]; then
    echo "std-dynlib-windows FAIL: missing $dyn_o or $rt_o" >&2
    return 1
  fi
  case "$(uname -s)" in
    Linux*) ld_extra="-ldl" ;;
  esac
  if ! cc -Wall -Wextra -o "$out" "$src" "$dyn_o" "$rt_o" $ld_extra 2>/dev/null; then
    echo "std-dynlib-windows FAIL: compile win_path_smoke.c" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-dynlib-windows FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report: check observational; osc/null/win_path hard; skip=0 when runnable ran.
# Accepts 5 or 6 args (legacy 4-arg callers map skip into 5th when win_path omitted — avoid).
std_dynlib_win_emit_report() {
  local status="$1"
  local check_ok="$2"
  local osc_ok="$3"
  local null_ok="$4"
  local win_path_ok="$5"
  local skip="${6:-0}"
  echo "${STD_DYNLIB_WIN_PREFIX} status=${status} check=${check_ok} osc=${osc_ok} null=${null_ok} win_path=${win_path_ok} skip=${skip}"
}
