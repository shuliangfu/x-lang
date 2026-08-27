#!/usr/bin/env bash
# core-mem-intrinsic.sh — CORE-008：core.mem intrinsic 映射与 -E 烟测辅助
#
# 用法（source 后）：
#   core_mem_intrinsic_mappings_ok CODEGEN_C TSV
#   core_mem_intrinsic_emit_ok XLANG X_FILE TSV
#   core_mem_intrinsic_emit_report status run obs skip
#
# Honesty soft→硬绿 (2026-08-28): prefer asm at gate; missing native = hard die;
# __builtin_* emit undercount = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology.

CORE_MEM_INTRINSIC_PREFIX="${XLANG_CORE_MEM_INTRINSIC_PREFIX:-xlang: [XLANG_CORE_MEM_INTRINSIC]}"

# Live authority = core/mem/mod.x (pure .x loops; codegen.c intrinsic table retired).
# Mapping rows: c_sym like core_mem_mem_copy → require function mem_copy( in mod.x.
# Arg1 kept for call-site compat (ignored); Arg2 = TSV; optional Arg3 = mod.x.
core_mem_intrinsic_mappings_ok() {
  local _codegen_unused="$1"
  local tsv="$2"
  local mod_x="${3:-core/mem/mod.x}"
  local miss=0
  local c_sym intrinsic short
  while IFS=$'\t' read -r item_id kind c_sym intrinsic _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      mapping)
        short="$c_sym"
        case "$c_sym" in
          core_mem_*) short="${c_sym#core_mem_}" ;;
        esac
        if ! grep -qE "function ${short}\\(" "$mod_x" 2>/dev/null; then
          echo "core-mem-intrinsic FAIL: $mod_x missing function $short (from $c_sym)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 对本机 xlang 跑 -o 编译（XLANG_DEBUG_C 落盘生成 C）并统计 manifest emit_grep 锚点。
# 注：有 import 时 -E 不输出 main 体，须走 -o 的 codegen_module_to_c 路径（见 RFC §3.2）。
core_mem_intrinsic_emit_ok() {
  local xlang="$1"
  local su_file="$2"
  local tsv="$3"
  local gen_c="/tmp/xlang_debug.c"
  local found=0
  local total=0
  local anchor
  rm -f "$gen_c"
  # 链接可能因 runtime 符号缺失失败；只要生成 C 已写入 xlang_debug.c 即可验 intrinsic。
  XLANG_DEBUG_C=1 "$xlang" -L . "$su_file" -o "/tmp/xlang_core_mem_intrinsic_$$" >/dev/null 2>&1 || true
  if [ ! -f "$gen_c" ]; then
    echo "core-mem-intrinsic FAIL: XLANG_DEBUG_C did not write $gen_c for $su_file" >&2
    echo 0
    return 1
  fi
  while IFS=$'\t' read -r item_id kind anchor _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      emit_grep)
        total=$((total + 1))
        if grep -qF "$anchor" "$gen_c" 2>/dev/null; then
          found=$((found + 1))
        else
          echo "core-mem-intrinsic FAIL: generated C missing '$anchor'" >&2
        fi
        ;;
    esac
  done < "$tsv"
  echo "$found"
  [ "$found" -eq "$total" ] && [ "$total" -gt 0 ]
}

# Emit structured honesty report line (run=/obs=/skip=).
core_mem_intrinsic_emit_report() {
  local status="${1:-ok}"
  local run="${2:-0}"
  local obs="${3:-0}"
  local skip="${4:-0}"
  echo "${CORE_MEM_INTRINSIC_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip}"
}
