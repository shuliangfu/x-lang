#!/usr/bin/env bash
# type-ffi-bridge.sh — TYPE-004 FFI type-bridge shared helpers.
#
# Honesty (2026-08-28): codegen.c / c_type_to_buf retired — live =
# codegen.x type_to_c_repr / emit_type. Mapping greps target codegen.x.
# PLATFORM: SHARED archaeology.

# Return 0 if path is a native executable for this host (Mach-O/ELF match).
type_ffi_native_xlang() {
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

# Verify mapping-table xlang_type has a corresponding C-type substring in
# live codegen.x (default). Fossil codegen.c path rejected by callers.
# PLATFORM: SHARED — single authority = type_to_c_repr / emit_type.
type_ffi_mapping_in_codegen() {
  local xlang="$1"
  local cty="$2"
  local cg="${3:-compiler/src/codegen/codegen.x}"
  [ -f "$cg" ] || return 1
  case "$xlang" in
    i32) grep -qF 'int32_t' "$cg" ;;
    u32) grep -qF 'uint32_t' "$cg" ;;
    i64) grep -qF 'int64_t' "$cg" ;;
    u64) grep -qF 'uint64_t' "$cg" ;;
    u8) grep -qF 'uint8_t' "$cg" ;;
    bool) grep -qF 'TYPE_BOOL' "$cg" ;;
    f32) grep -qF 'float' "$cg" ;;
    f64) grep -qF 'double' "$cg" ;;
    usize) grep -qF 'size_t' "$cg" ;;
    isize) grep -qF 'ptrdiff_t' "$cg" ;;
    ptr_star|ptr_u8_bridge) grep -qE 'type_to_c_repr|emit_type' "$cg" ;;
    slice_arr) grep -qF 'xlang_slice_' "$cg" ;;
    *) grep -qF "$cty" "$cg" ;;
  esac
}
