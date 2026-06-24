#!/usr/bin/env bash
# std-io-fallback.sh — STD-026：三平台 read/write 回退矩阵 manifest 辅助
#
# 用法（source 后）：
#   std_io_fallback_manifest_ok DOC README IO_C MOD_SX TSV
#   std_io_fallback_emit_report status matrix_ok code_ok readme_ok check_ok skip

STD_IO_FALLBACK_PREFIX="${SHUX_STD_IO_FALLBACK_PREFIX:-shux: [SHUX_STD_IO_FALLBACK]}"

# 校验 manifest：矩阵行 doc+code 锚点、README、符号；echo "matrix_miss code_miss"。
std_io_fallback_manifest_ok() {
  local doc="$1"
  local readme="$2"
  local io_c="$3"
  local mod_sx="$4"
  local tsv="$5"
  local matrix_miss=0
  local code_miss=0
  local matrix_n=0
  local min_matrix=12
  local item_id kind doc_anchor code_anchor src _notes
  while IFS=$'\t' read -r item_id kind doc_anchor code_anchor src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
      min_matrix_rows)
        if [ -n "${doc_anchor:-}" ]; then
          min_matrix="$doc_anchor"
        fi
        continue
        ;;
    esac
    case "$kind" in
      section)
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-io-fallback FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        ;;
      readme)
        if ! grep -qF "$doc_anchor" "$readme" 2>/dev/null; then
          echo "std-io-fallback FAIL: README missing '$doc_anchor' ($item_id)" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        ;;
      code)
        if ! grep -qF "$code_anchor" "$io_c" 2>/dev/null; then
          echo "std-io-fallback FAIL: io.c missing '$code_anchor' ($item_id)" >&2
          code_miss=$((code_miss + 1))
        fi
        ;;
      matrix)
        matrix_n=$((matrix_n + 1))
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-io-fallback FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        if ! grep -qF "$code_anchor" "$io_c" 2>/dev/null; then
          echo "std-io-fallback FAIL: io.c missing '$code_anchor' ($item_id)" >&2
          code_miss=$((code_miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qE "function ${code_anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-io-fallback FAIL: missing function ${code_anchor} in $mod_sx" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  if [ "$matrix_n" -lt "$min_matrix" ]; then
    echo "std-io-fallback FAIL: matrix_rows=${matrix_n} < min ${min_matrix}" >&2
    matrix_miss=$((matrix_miss + 1))
  fi
  echo "${matrix_miss} ${code_miss}"
  [ "$matrix_miss" -eq 0 ] && [ "$code_miss" -eq 0 ]
}

# 输出结构化报告行。
std_io_fallback_emit_report() {
  local status="$1"
  local matrix_ok="$2"
  local code_ok="$3"
  local readme_ok="$4"
  local check_ok="$5"
  local skip="$6"
  echo "${STD_IO_FALLBACK_PREFIX} status=${status} matrix=${matrix_ok} code=${code_ok} readme=${readme_ok} check=${check_ok} skip=${skip}"
}
