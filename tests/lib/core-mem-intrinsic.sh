#!/usr/bin/env bash
# core-mem-intrinsic.sh — CORE-008：core.mem intrinsic 映射与 -E 烟测辅助
#
# 用法（source 后）：
#   core_mem_intrinsic_mappings_ok CODEGEN_C TSV
#   core_mem_intrinsic_emit_ok SHU SX_FILE TSV
#   core_mem_intrinsic_emit_report status found total

CORE_MEM_INTRINSIC_PREFIX="${SHUX_CORE_MEM_INTRINSIC_PREFIX:-shux: [SHUX_CORE_MEM_INTRINSIC]}"

# 校验 codegen.c 中四条 C 符号 → intrinsic 映射；缺失数 echo 到 stdout，成功返回 0。
core_mem_intrinsic_mappings_ok() {
  local codegen="$1"
  local tsv="$2"
  local miss=0
  local c_sym intrinsic
  while IFS=$'\t' read -r item_id kind c_sym intrinsic _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      mapping)
        if ! grep -qF "\"$c_sym\"" "$codegen" 2>/dev/null; then
          echo "core-mem-intrinsic FAIL: codegen missing symbol '$c_sym'" >&2
          miss=$((miss + 1))
        elif ! grep -qF "\"$intrinsic\"" "$codegen" 2>/dev/null; then
          echo "core-mem-intrinsic FAIL: codegen missing intrinsic '$intrinsic'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 对本机 shux 跑 -o 编译（SHUX_DEBUG_C 落盘生成 C）并统计 manifest emit_grep 锚点。
# 注：有 import 时 -E 不输出 main 体，须走 -o 的 codegen_module_to_c 路径（见 RFC §3.2）。
core_mem_intrinsic_emit_ok() {
  local shux="$1"
  local su_file="$2"
  local tsv="$3"
  local gen_c="/tmp/shux_debug.c"
  local found=0
  local total=0
  local anchor
  rm -f "$gen_c"
  # 链接可能因 runtime 符号缺失失败；只要生成 C 已写入 shu_debug.c 即可验 intrinsic。
  SHUX_DEBUG_C=1 "$shux" -L . "$su_file" -o "/tmp/shux_core_mem_intrinsic_$$" >/dev/null 2>&1 || true
  if [ ! -f "$gen_c" ]; then
    echo "core-mem-intrinsic FAIL: SHUX_DEBUG_C did not write $gen_c for $su_file" >&2
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

# 输出结构化报告行。
core_mem_intrinsic_emit_report() {
  local status="$1"
  local found="$2"
  local total="$3"
  echo "${CORE_MEM_INTRINSIC_PREFIX} status=${status} emit=${found}/${total}"
}
