// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-9：backend_call_dispatch 产品源迁 seeds/backend_call_dispatch.from_x.c。
// 本文件为语义对照 / 后续真迁 .x 锚点；分派实现仍在 seed C。
// 产品：cc seeds/backend_call_dispatch.from_x.c → src/asm/backend_call_dispatch.o

function backend_call_dispatch_x_doc_anchor(): i32 {
  return 0;
}

// G-02f-108：+ string_lit / f32 param / reg_max / import_sym 薄门闩。

extern "C" function glue_asm_string_lit_len_impl(arena: *u8, er: i32): i32;
extern "C" function glue_asm_string_lit_into_impl(arena: *u8, er: i32, out: *u8): void;
extern "C" function glue_call_param_is_f32_c_impl(arena: *u8, tr: i32): i32;
extern "C" function glue_asm_call_reg_max_impl(ta: i32): i32;
extern "C" function glue_asm_call_stack_cleanup_bytes_impl(ta: i32, nargs: i32): i32;
extern "C" function glue_codegen_import_path_to_c_prefix_into_impl(path: *u8, buf: *u8, cap: i32): void;
extern "C" function glue_asm_c_prefix_redundant_with_name_impl(pre: *u8, plen: i32, name: *u8, nlen: i32): i32;
extern "C" function glue_asm_build_import_binding_call_sym_impl(pre: *u8, plen: i32, field: *u8, flen: i32, out: *u8): i32;
extern "C" function glue_type_kind_to_suffix_c_impl(kind: i32, out: *u8, cap: i32): i32;

/* ---- G-02f-108：backend call dispatch helpers 门闩 ---- */

#[no_mangle]
function glue_asm_string_lit_len(arena: *u8, er: i32): i32 {
  unsafe { return glue_asm_string_lit_len_impl(arena, er); }
  return 0;
}

#[no_mangle]
function glue_asm_string_lit_into(arena: *u8, er: i32, out: *u8): void {
  unsafe { glue_asm_string_lit_into_impl(arena, er, out); }
}

#[no_mangle]
function glue_call_param_is_f32_c(arena: *u8, tr: i32): i32 {
  unsafe { return glue_call_param_is_f32_c_impl(arena, tr); }
  return 0;
}

#[no_mangle]
function glue_asm_call_reg_max(ta: i32): i32 {
  unsafe { return glue_asm_call_reg_max_impl(ta); }
  return 0;
}

#[no_mangle]
function glue_asm_call_stack_cleanup_bytes(ta: i32, nargs: i32): i32 {
  unsafe { return glue_asm_call_stack_cleanup_bytes_impl(ta, nargs); }
  return 0;
}

#[no_mangle]
function glue_codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, cap: i32): void {
  unsafe { glue_codegen_import_path_to_c_prefix_into_impl(path, buf, cap); }
}

#[no_mangle]
function glue_asm_c_prefix_redundant_with_name(pre: *u8, plen: i32, name: *u8, nlen: i32): i32 {
  unsafe { return glue_asm_c_prefix_redundant_with_name_impl(pre, plen, name, nlen); }
  return 0;
}

#[no_mangle]
function glue_asm_build_import_binding_call_sym(pre: *u8, plen: i32, field: *u8, flen: i32, out: *u8): i32 {
  unsafe { return glue_asm_build_import_binding_call_sym_impl(pre, plen, field, flen, out); }
  return 0;
}

#[no_mangle]
function glue_type_kind_to_suffix_c(kind: i32, out: *u8, cap: i32): i32 {
  unsafe { return glue_type_kind_to_suffix_c_impl(kind, out, cap); }
  return 0;
}
