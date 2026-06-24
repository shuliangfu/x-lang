#!/usr/bin/env bash
# std-dynlib-windows.sh — STD-027：dynlib Windows/POSIX manifest 辅助
#
# 用法（source 后）：
#   std_dynlib_win_manifest_ok DOC DYNLIB_C MOD_SX TSV
#   std_dynlib_win_emit_report status check_ok run_ok skip

STD_DYNLIB_WIN_PREFIX="${SHUX_STD_DYNLIB_WIN_PREFIX:-shux: [SHUX_STD_DYNLIB_WIN]}"

# 校验 manifest：C 符号、.sx API、RFC 节；echo 缺失数。
std_dynlib_win_manifest_ok() {
  local doc="$1"
  local dynlib_c="$2"
  local mod_sx="$3"
  local tsv="$4"
  local miss=0
  local item_id kind doc_anchor code_anchor src _notes
  while IFS=$'\t' read -r item_id kind doc_anchor code_anchor src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*) continue ;; esac
    case "$kind" in
      code)
        if ! grep -qF "$code_anchor" "$dynlib_c" 2>/dev/null; then
          echo "std-dynlib-windows FAIL: runtime_dynlib_os.c missing '$code_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qE "function ${code_anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-dynlib-windows FAIL: missing function ${code_anchor} in $mod_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-dynlib-windows FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_dynlib_win_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_DYNLIB_WIN_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
