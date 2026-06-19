#!/usr/bin/env bash
# type-ffi-bridge.sh — TYPE-004 FFI 类型桥接共享辅助

# 判断本机能否直接执行给定 shux 二进制。
type_ffi_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# 校验 mapping 表中 shu_type 在 codegen 有对应 C 类型子串。
type_ffi_mapping_in_codegen() {
  local shux="$1"
  local cty="$2"
  local cg="${3:-compiler/src/codegen/codegen.c}"
  case "$shux" in
    i32) grep -qF 'int32_t' "$cg" ;;
    u32) grep -qF 'uint32_t' "$cg" ;;
    i64) grep -qF 'int64_t' "$cg" ;;
    u64) grep -qF 'uint64_t' "$cg" ;;
    u8) grep -qF 'uint8_t' "$cg" ;;
    bool) grep -qF 'AST_TYPE_BOOL' "$cg" && grep -qF '"int"' "$cg" ;;
    f32) grep -qF 'float' "$cg" ;;
    f64) grep -qF 'double' "$cg" ;;
    usize) grep -qF 'size_t' "$cg" ;;
    isize) grep -qF 'ptrdiff_t' "$cg" ;;
    ptr_star|ptr_u8_bridge) grep -qF 'c_type_to_buf' "$cg" ;;
    slice_arr) grep -qF 'shux_slice_' "$cg" ;;
    *) grep -qF "$cty" "$cg" ;;
  esac
}
