#!/usr/bin/env bash
# std-heap-trace.sh — STD-017：heap trace manifest 辅助
#
# 用法（source 后）：
#   std_heap_trace_symbols_ok HEAP_SU HEAP_C TSV
#   std_heap_trace_emit_report status check_ok run_ok skip

STD_HEAP_TRACE_PREFIX="${SHU_STD_HEAP_TRACE_PREFIX:-shu: [SHU_STD_HEAP_TRACE]}"

# 校验 manifest symbol 锚点；echo 缺失数。
std_heap_trace_symbols_ok() {
  local heap_su="$1"
  local heap_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      symbol)
        local target="$heap_su"
        case "$mod_path" in
          std/heap/heap.c) target="$heap_c" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-heap-trace FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_heap_trace_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_HEAP_TRACE_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
