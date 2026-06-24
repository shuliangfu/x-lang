#!/usr/bin/env bash
# core-builtin-bitops.sh — CORE-009：builtin 位运算 manifest 辅助
#
# 用法（source 后）：
#   core_builtin_mappings_ok CODEGEN_C TSV
#   core_builtin_c_impl_ok BUILTIN_C TSV
#   core_builtin_emit_ok SHU SX_FILE TSV
#   core_builtin_emit_report status found total

CORE_BUILTIN_PREFIX="${SHUX_CORE_BUILTIN_BITOPS_PREFIX:-shux: [SHUX_CORE_BUILTIN_BITOPS]}"

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

# 校验 core/builtin/mod.sx 含 clz/ctz/popcount 纯 .sx 实现（G-01）。
core_builtin_sx_impl_ok() {
  local mod_sx="$1"
  local miss=0
  for sym in clz_u32 ctz_u32 popcount_u32; do
    if ! grep -qE "function ${sym}\\(" "$mod_sx" 2>/dev/null; then
      echo "core-builtin-bitops FAIL: $mod_sx missing $sym" >&2
      miss=$((miss + 1))
    fi
  done
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验 builtin.c 含 __builtin 实现（legacy；G-01 已删 C，保留供考古）。
core_builtin_c_impl_ok() {
  local builtin_c="$1"
  if [ ! -f "$builtin_c" ]; then
    echo "0"
    return 0
  fi
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

# SHUX_DEBUG_C emit 烟测。
core_builtin_emit_ok() {
  local shux="$1"
  local su_file="$2"
  local tsv="$3"
  local gen_c="/tmp/shux_debug.c"
  local found=0
  local total=0
  rm -f "$gen_c"
  SHUX_DEBUG_C=1 "$shux" -L . "$su_file" -o "/tmp/shux_core_builtin_emit_$$" >/dev/null 2>&1 || true
  if [ ! -f "$gen_c" ]; then
    echo "core-builtin-bitops FAIL: SHUX_DEBUG_C did not write $gen_c" >&2
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
