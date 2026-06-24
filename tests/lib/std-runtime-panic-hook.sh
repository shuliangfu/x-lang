#!/usr/bin/env bash
# std-runtime-panic-hook.sh — STD-028：panic 钩子 manifest 辅助
#
# 用法（source 后）：
#   std_runtime_panic_manifest_ok DOC README RUNTIME_SX TSV [extra files...]
#   std_runtime_panic_emit_report status matrix_ok check_ok exc_ok skip

STD_RUNTIME_PANIC_PREFIX="${SHUX_STD_RUNTIME_PANIC_PREFIX:-shux: [SHUX_STD_RUNTIME_PANIC]}"

# 校验 manifest；echo "miss"。
std_runtime_panic_manifest_ok() {
  local doc="$1"
  local readme="$2"
  local runtime_sx="$3"
  local tsv="$4"
  shift 4
  local miss=0
  local matrix_n=0
  local min_matrix=6
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
      section|cross_ref)
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-runtime-panic FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      readme)
        if ! grep -qF "$doc_anchor" "$readme" 2>/dev/null; then
          echo "std-runtime-panic FAIL: README missing '$doc_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        matrix_n=$((matrix_n + 1))
        if ! grep -qE "function ${code_anchor}\\(" "$runtime_sx" 2>/dev/null; then
          echo "std-runtime-panic FAIL: missing ${code_anchor} in $runtime_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      code)
        matrix_n=$((matrix_n + 1))
        if [ ! -f "$src" ]; then
          echo "std-runtime-panic FAIL: missing $src ($item_id)" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$code_anchor" "$src" 2>/dev/null; then
          echo "std-runtime-panic FAIL: $src missing '$code_anchor' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|hook|script)
        if [ ! -f "$src" ]; then
          echo "std-runtime-panic FAIL: missing $src ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  if [ "$matrix_n" -lt "$min_matrix" ]; then
    echo "std-runtime-panic FAIL: anchors=${matrix_n} < min ${min_matrix}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_runtime_panic_emit_report() {
  local status="$1"
  local matrix_ok="$2"
  local check_ok="$3"
  local exc_ok="$4"
  local skip="$5"
  echo "${STD_RUNTIME_PANIC_PREFIX} status=${status} matrix=${matrix_ok} check=${check_ok} exc=${exc_ok} skip=${skip}"
}
