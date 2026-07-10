// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-26：真迁 .x — pipeline_x 与 lexer/typeck/codegen_x 命名桥（i32/void 转发）。
// lexer 的 struct 返回值仍由 seeds 尾部 C 补（语言/ABI 限制）。
// weak 符号在 seed 中抛光 __attribute__((weak))。
// 产品：./shux-c -E → seeds/x_frontend_link_alias.from_x.c（+ C 尾段）

/* ---- typeck / pipeline ---- */
extern "C" function typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32;
extern "C" function typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32;
extern "C" function typeck_merge_dep_struct_layouts_into_entry(mod: *u8, arena: *u8, ctx: *u8): void;
extern "C" function typeck_wpo_unify_soa_layouts(entry: *u8, ctx: *u8): void;
extern "C" function pipeline_typeck_check_block_impl_c(module: *u8, arena: *u8, block_ref: i32,
                                                         return_type_ref: i32, ctx: *u8): i32;
extern "C" function pipeline_typeck_check_expr_impl_c(module: *u8, arena: *u8, expr_ref: i32,
                                                        return_type_ref: i32, ctx: *u8): i32;
extern "C" function typeck_find_or_alloc_ptr_type_ref(arena: *u8, elem_ref: i32): i32;
extern "C" function pipeline_module_num_funcs(module: *u8): i32;
extern "C" function pipeline_module_main_func_index(module: *u8): i32;
extern "C" function pipeline_module_struct_layout_set_soa(m: *u8, idx: i32, v: i32): void;
extern "C" function pipeline_module_struct_layout_soa_at(m: *u8, idx: i32): i32;
extern "C" function pipeline_module_struct_layout_packed_at(m: *u8, idx: i32): i32;
extern "C" function pipeline_module_struct_layout_field_align_at(m: *u8, li: i32, j: i32): i32;
extern "C" function pipeline_module_struct_layout_set_field_align(m: *u8, li: i32, j: i32, al: i32): void;

/* ---- codegen ---- */
extern "C" function codegen_x_ast_emit_header(out: *u8): i32;
extern "C" function codegen_x_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8, dep_index: i32): i32;

// lexer_* 含 struct 返回值 / by-value Lexer：见 seeds 尾部 C 段（语言/ABI 限制）。

#[no_mangle]
function typeck_pipeline_module_num_funcs(module: *u8): i32 {
  unsafe { let r: i32 = pipeline_module_num_funcs(module); return r; }
  return 0;
}
#[no_mangle]
function typeck_pipeline_module_main_func_index(module: *u8): i32 {
  unsafe { let r: i32 = pipeline_module_main_func_index(module); return r; }
  return 0;
}
#[no_mangle]
function typeck_typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe { let r: i32 = typeck_x_ast(module, arena, ctx); return r; }
  return 0;
}
#[no_mangle]
function typeck_typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe { let r: i32 = typeck_x_ast_library(module, arena, ctx); return r; }
  return 0;
}
#[no_mangle]
function typeck_typeck_merge_dep_struct_layouts_into_entry(mod: *u8, arena: *u8, ctx: *u8): void {
  unsafe { typeck_merge_dep_struct_layouts_into_entry(mod, arena, ctx); }
}
#[no_mangle]
function typeck_typeck_wpo_unify_soa_layouts(entry: *u8, ctx: *u8): void {
  unsafe { typeck_wpo_unify_soa_layouts(entry, ctx); }
}
#[no_mangle]
function check_block_impl(module: *u8, arena: *u8, block_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_typeck_check_block_impl_c(module, arena, block_ref, return_type_ref, ctx);
    return r;
  }
  return 0;
}
#[no_mangle]
function check_expr_impl(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
    return r;
  }
  return 0;
}
#[no_mangle]
function find_or_alloc_ptr_type_ref(arena: *u8, elem_ref: i32): i32 {
  unsafe { let r: i32 = typeck_find_or_alloc_ptr_type_ref(arena, elem_ref); return r; }
  return 0;
}
#[no_mangle]
function pipeline_typeck_set_active_ctx_c(module: *u8, ctx: *u8): void {
  // weak no-op default; ast_pool strong may override
}
#[no_mangle]
function pipeline_typeck_ptr_for_addr_of_operand_c(arena: *u8, op_ref: i32, elem_ty: i32, module: *u8,
                                                    ctx: *u8): i32 {
  return 0;
}
#[no_mangle]
function ast_pipeline_module_struct_layout_set_soa(m: *u8, idx: i32, v: i32): void {
  unsafe { pipeline_module_struct_layout_set_soa(m, idx, v); }
}
#[no_mangle]
function ast_pipeline_module_struct_layout_soa_at(m: *u8, idx: i32): i32 {
  unsafe { let r: i32 = pipeline_module_struct_layout_soa_at(m, idx); return r; }
  return 0;
}
#[no_mangle]
function ast_pipeline_module_struct_layout_packed_at(m: *u8, idx: i32): i32 {
  unsafe { let r: i32 = pipeline_module_struct_layout_packed_at(m, idx); return r; }
  return 0;
}
#[no_mangle]
function ast_pipeline_module_struct_layout_field_align_at(m: *u8, li: i32, j: i32): i32 {
  unsafe { let r: i32 = pipeline_module_struct_layout_field_align_at(m, li, j); return r; }
  return 0;
}
#[no_mangle]
function ast_pipeline_module_struct_layout_set_field_align(m: *u8, li: i32, j: i32, al: i32): void {
  unsafe { pipeline_module_struct_layout_set_field_align(m, li, j, al); }
}
#[no_mangle]
function codegen_codegen_x_ast_emit_header(out: *u8): i32 {
  unsafe { let r: i32 = codegen_x_ast_emit_header(out); return r; }
  return 0;
}
#[no_mangle]
function codegen_codegen_x_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8, dep_index: i32): i32 {
  unsafe { let r: i32 = codegen_x_ast(module, arena, out, ctx, dep_index); return r; }
  return 0;
}
