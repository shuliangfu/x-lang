#!/usr/bin/env bash
# core-builtin-bitops.sh — CORE-009：builtin 位运算 manifest 辅助
#
# 用法（source 后）：
#   core_builtin_mappings_ok CODEGEN_C TSV
#   core_builtin_c_impl_ok BUILTIN_C TSV
#   core_builtin_emit_ok SHU SU_FILE TSV
#   core_builtin_emit_report status found total

CORE_BUILTIN_PREFIX="${SHU_CORE_BUILTIN_BITOPS_PREFIX:-shu: [SHU_CORE_BUILTIN_BITOPS]}"

# 校验 codegen.c 映射；echo 缺失数。
core_builtin_mappings_ok() {
  local codegen="$1"
  local tsv="$2"
  local miss=0
  local item_id kind c_sym intrinsic
  while IFS=$'\t' read -r item_id kind c_sym intrinsic _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      mapping)
        if ! grep -qF "\"$c_sym\"" "$codegen" 2>/dev/null; then
          echo "core-builtin-bitops FAIL: codegen missing '$c_sym'" >&2
          miss=$((miss + 1))
        elif ! grep -qF "\"$intrinsic\"" "$codegen" 2>/dev/null; then
          echo "core-builtin-bitops FAIL: codegen missing '$intrinsic'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验 builtin.c 含 __builtin 实现。
core_builtin_c_impl_ok() {
  local builtin_c="$1"
  local miss=0
  for sym in __builtin_clz __builtin_ctz __builtin_popcount; do
    if ! grep -qF "$sym" "$builtin_c" 2>/dev/null; then
      echo "core-builtin-bitops FAIL: $builtin_c missing $sym" >&2
      miss=$((miss + 1))
    fi
  done
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# SHU_DEBUG_C emit 烟测。
core_builtin_emit_ok() {
  local shu="$1"
  local su_file="$2"
  local tsv="$3"
  local gen_c="/tmp/shu_debug.c"
  local found=0
  local total=0
  rm -f "$gen_c"
  SHU_DEBUG_C=1 "$shu" -L . "$su_file" -o "/tmp/shu_core_builtin_emit_$$" >/dev/null 2>&1 || true
  if [ ! -f "$gen_c" ]; then
    echo "core-builtin-bitops FAIL: SHU_DEBUG_C did not write $gen_c" >&2
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
          echo "core-builtin-bitops FAIL: generated C missing '$anchor'" >&2
        fi
        ;;
    esac
  done < "$tsv"
  echo "$found"
  [ "$found" -eq "$total" ] && [ "$total" -gt 0 ]
}

core_builtin_emit_report() {
  local status="$1"
  local found="$2"
  local total="$3"
  echo "${CORE_BUILTIN_PREFIX} status=${status} emit=${found}/${total}"
}
