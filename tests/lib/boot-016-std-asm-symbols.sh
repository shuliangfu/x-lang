#!/usr/bin/env bash
# boot-016-std-asm-symbols.sh — BOOT-016：xlang_asm Top-N std .o 符号完整性辅助
#
# 用法（source 后）：
#   boot016_nm_has_symbol OBJ SYM
#   boot016_verify_runtime_paths RUNTIME_FILES TSV
#   boot016_emit_report status obj_ok sym_miss runtime_miss skip
#
# wave honesty (2026-08-24): RUNTIME_FILES is a space-separated live seed set
# (labi_std_list + labi_ondemand_list). Monofile seeds/runtime.from_x.c retired
# wave321; get_*_o_path getters retired (E-04). Path string literals are the
# contract — getter column may be "-".
# PLATFORM: SHARED archaeology.

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
BOOT016_PREFIX="${XLANG_BOOT016_PREFIX:-xlang: [XLANG_BOOT016]}"

# 判断 .o 中是否已定义符号 sym（兼容 macOS `_` 前缀与 GNU nm）。
boot016_nm_has_symbol() {
  local obj="$1"
  local sym="$2"
  if [ ! -f "$obj" ]; then
    return 1
  fi
  if ! command -v nm >/dev/null 2>&1; then
    return 1
  fi
  nm -g --defined-only "$obj" 2>/dev/null | awk '{print $NF}' | grep -qE "^_?${sym}$"
}

# 构建单个 std .o（相对仓库根路径）。
boot016_ensure_obj() {
  local obj_rel="$1"
  local mk_target="../${obj_rel}"
  if [ ! -f "$obj_rel" ]; then
    xlang_compiler_make -q "$mk_target" 2>/dev/null || xlang_compiler_make "$mk_target" >/dev/null 2>&1
  fi
  [ -f "$obj_rel" ]
}

# Return 0 if needle appears in any file listed in space-separated haystack.
boot016_any_file_has() {
  local needle="$1"
  local hay="$2"
  local f
  for f in $hay; do
    if [ -f "$f" ] && grep -qF "$needle" "$f" 2>/dev/null; then
      return 0
    fi
  done
  return 1
}

# Verify live link-path seeds contain each std_obj path (and optional getter).
# RUNTIME_FILES: space-separated seed paths. Echo miss count; return 0 iff miss=0.
boot016_verify_runtime_paths() {
  local rt_files="$1"
  local tsv="$2"
  local miss=0
  local item_id kind obj_rel anchor getter _notes
  while IFS=$'\t' read -r item_id kind obj_rel anchor getter _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$kind" in
      std_obj)
        if [ -n "$getter" ] && [ "$getter" != "-" ]; then
          if ! boot016_any_file_has "$getter" "$rt_files"; then
            echo "boot-016 FAIL: live seeds missing getter $getter ($item_id)" >&2
            miss=$((miss + 1))
          fi
        fi
        if ! boot016_any_file_has "$obj_rel" "$rt_files"; then
          echo "boot-016 FAIL: live seeds missing obj path $obj_rel ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
boot016_emit_report() {
  local status="$1"
  local obj_ok="$2"
  local sym_miss="$3"
  local runtime_miss="$4"
  local skip="$5"
  echo "${BOOT016_PREFIX} status=${status} obj_ok=${obj_ok} sym_miss=${sym_miss} runtime_miss=${runtime_miss} skip=${skip}"
}
