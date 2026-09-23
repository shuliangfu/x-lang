// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-26 / w847 / w863 / w864 / w865 / w866 / w867: alias forwards for pipeline_x lexer/typeck/codegen_x.
// w847 put the original 18 alias bodies only in this file and deleted
// their C twins and the XLANG_XFLA_ASM gate.
// w863 also places pipeline_type_kind_ord_at_u8_ptr_i32_reti32 here.
// That face forwards to pipeline_type_kind_ord_at and stays strong.
// w864 also places glue_asm_build_func_export_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_reti32
// here. That face forwards to glue_asm_build_func_export_sym_c and stays strong.
// w865 also places
// glue_asm_build_import_binding_call_sym_u8_ptr_i32_u8_ptr_i32_u8_ptr_reti32
// here. That face forwards to glue_asm_build_import_binding_call_sym and stays strong.
// w866 also places
// glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32
// here. That face forwards to glue_try_std_heap_redirect_sym_local and stays strong.
// w867 also places
// glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32
// here. That face forwards to glue_codegen_import_path_to_c_prefix_into
// and stays strong. The unsuffixed body returns void.
// w868 also places pipeline_expr_field_access_name_len_u8_ptr_i32_reti32
// here. That face forwards to pipeline_expr_field_access_name_len and
// stays weak. The unsuffixed body stays in the pipeline object.
// w869 also places pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32
// here. That face forwards to pipeline_expr_field_access_base_ref and
// stays weak. The unsuffixed body stays in the pipeline object.
// w870 also places pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32
// here. That face forwards to pipeline_expr_binop_left_ref_at and
// stays weak. The unsuffixed body stays in the pipeline object.
// w871 also places pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32
// here. That face forwards to pipeline_expr_binop_right_ref_at and
// stays weak. The unsuffixed body stays in the pipeline object.
// w872 also places pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr
// here. That face forwards to pipeline_expr_field_access_name_into and
// stays weak. The unsuffixed body returns void and stays in the pipeline
// object. This face is void with three arguments, not the i32 two-argument
// shape.
// w873 also places pipeline_dep_ctx_ndep_u8_ptr_reti32 here. That face
// forwards to pipeline_dep_ctx_ndep and stays weak. The unsuffixed body
// stays in the pipeline object. This face is i32 with one argument, not
// the void three-argument shape and not the i32 two-argument shape.
// The product installer pure-asm's this file, then cc's the seed for the
// lexer struct-return tail and the remaining XLANG_WEAK cluster.
// There is no full-seed fallback and XLANG_G05_PREFER_X_O is ignored.
// Windows takes the same path.
// Eleven faces are weakened after asm. The first five stay weak so a strong
// typeck definition wins. The sixth is the w868 field-name-length alias.
// The seventh is the w869 field-base-ref alias.
// The eighth is the w870 binop-left alias.
// The ninth is the w871 binop-right alias.
// The tenth is the w872 field-name-into alias.
// The eleventh is the w873 dependency-count alias:
// check_block_impl, check_expr_impl, find_or_alloc_ptr_type_ref,
// pipeline_typeck_set_active_ctx_c, pipeline_typeck_ptr_for_addr_of_operand_c,
// pipeline_expr_field_access_name_len_u8_ptr_i32_reti32,
// pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32,
// pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32,
// pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32,
// pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr,
// pipeline_dep_ctx_ndep_u8_ptr_reti32.
// Do not gcc -E this TU. Do not pass XLANG_XFLA_ASM.
// PLATFORM: SHARED.

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
extern "C" function pipeline_type_kind_ord_at(a: *u8, r: i32): i32;

/* ---- codegen ---- */
extern "C" function codegen_x_ast_emit_header(out: *u8): i32;
extern "C" function codegen_x_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8, dep_index: i32): i32;
extern "C" function glue_asm_build_func_export_sym_c(a: *u8, b: *u8, c: i32, d: *u8, e: i32): i32;
extern "C" function glue_asm_build_import_binding_call_sym(a: *u8, b: i32, c: *u8, d: i32, e: *u8): i32;
extern "C" function glue_try_std_heap_redirect_sym_local(name: *u8, nlen: i32, out: *u8, cap: i32): i32;
extern "C" function glue_codegen_import_path_to_c_prefix_into(path: *u8, buf: *u8, buf_cap: i32): void;
extern "C" function pipeline_expr_field_access_name_len(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_base_ref(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_binop_left_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_binop_right_ref_at(a: *u8, er: i32): i32;
extern "C" function pipeline_expr_field_access_name_into(a: *u8, er: i32, dst: *u8): void;
extern "C" function pipeline_dep_ctx_ndep(ctx: *u8): i32;

// lexer_*  struct  / by-value Lexer： seeds  C （/ABI ）。

/** Function `typeck_pipeline_module_num_funcs`.
 * Purpose: implements `typeck_pipeline_module_num_funcs`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_pipeline_module_num_funcs(module: *u8): i32 {
  unsafe { let r: i32 = pipeline_module_num_funcs(module); return r; }
  return 0;
}
/** Function `typeck_pipeline_module_main_func_index`.
 * Purpose: implements `typeck_pipeline_module_main_func_index`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_pipeline_module_main_func_index(module: *u8): i32 {
  unsafe { let r: i32 = pipeline_module_main_func_index(module); return r; }
  return 0;
}
/** Function `typeck_typeck_x_ast`.
 * Purpose: implements `typeck_typeck_x_ast`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_typeck_x_ast(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe { let r: i32 = typeck_x_ast(module, arena, ctx); return r; }
  return 0;
}
/** Function `typeck_typeck_x_ast_library`.
 * Purpose: implements `typeck_typeck_x_ast_library`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_typeck_x_ast_library(module: *u8, arena: *u8, ctx: *u8): i32 {
  unsafe { let r: i32 = typeck_x_ast_library(module, arena, ctx); return r; }
  return 0;
}
/** Function `typeck_typeck_merge_dep_struct_layouts_into_entry`.
 * Purpose: implements `typeck_typeck_merge_dep_struct_layouts_into_entry`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_typeck_merge_dep_struct_layouts_into_entry(mod: *u8, arena: *u8, ctx: *u8): void {
  unsafe { typeck_merge_dep_struct_layouts_into_entry(mod, arena, ctx); }
}
/** Function `typeck_typeck_wpo_unify_soa_layouts`.
 * Purpose: implements `typeck_typeck_wpo_unify_soa_layouts`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function typeck_typeck_wpo_unify_soa_layouts(entry: *u8, ctx: *u8): void {
  unsafe { typeck_wpo_unify_soa_layouts(entry, ctx); }
}
/** Function `check_block_impl`.
 * Purpose: implements `check_block_impl`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function check_block_impl(module: *u8, arena: *u8, block_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_typeck_check_block_impl_c(module, arena, block_ref, return_type_ref, ctx);
    return r;
  }
  return 0;
}
/** Function `check_expr_impl`.
 * Purpose: implements `check_expr_impl`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function check_expr_impl(module: *u8, arena: *u8, expr_ref: i32, return_type_ref: i32, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
    return r;
  }
  return 0;
}
/** Function `find_or_alloc_ptr_type_ref`.
 * Purpose: implements `find_or_alloc_ptr_type_ref`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function find_or_alloc_ptr_type_ref(arena: *u8, elem_ref: i32): i32 {
  unsafe { let r: i32 = typeck_find_or_alloc_ptr_type_ref(arena, elem_ref); return r; }
  return 0;
}
/** Function `pipeline_typeck_set_active_ctx_c`.
 * Purpose: implements `pipeline_typeck_set_active_ctx_c`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function pipeline_typeck_set_active_ctx_c(module: *u8, ctx: *u8): void {
  // weak no-op default; ast_pool strong may override
}
/** Function `pipeline_typeck_ptr_for_addr_of_operand_c`.
 * Purpose: implements `pipeline_typeck_ptr_for_addr_of_operand_c`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function pipeline_typeck_ptr_for_addr_of_operand_c(arena: *u8, op_ref: i32, elem_ty: i32, module: *u8,
                                                    ctx: *u8): i32 {
  return 0;
}
/** Function `ast_pipeline_module_struct_layout_set_soa`.
 * Purpose: implements `ast_pipeline_module_struct_layout_set_soa`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_pipeline_module_struct_layout_set_soa(m: *u8, idx: i32, v: i32): void {
  unsafe { pipeline_module_struct_layout_set_soa(m, idx, v); }
}
/** Function `ast_pipeline_module_struct_layout_soa_at`.
 * Purpose: implements `ast_pipeline_module_struct_layout_soa_at`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_pipeline_module_struct_layout_soa_at(m: *u8, idx: i32): i32 {
  unsafe { let r: i32 = pipeline_module_struct_layout_soa_at(m, idx); return r; }
  return 0;
}
/** Function `ast_pipeline_module_struct_layout_packed_at`.
 * Purpose: implements `ast_pipeline_module_struct_layout_packed_at`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_pipeline_module_struct_layout_packed_at(m: *u8, idx: i32): i32 {
  unsafe { let r: i32 = pipeline_module_struct_layout_packed_at(m, idx); return r; }
  return 0;
}
/** Function `ast_pipeline_module_struct_layout_field_align_at`.
 * Purpose: implements `ast_pipeline_module_struct_layout_field_align_at`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_pipeline_module_struct_layout_field_align_at(m: *u8, li: i32, j: i32): i32 {
  unsafe { let r: i32 = pipeline_module_struct_layout_field_align_at(m, li, j); return r; }
  return 0;
}
/** Function `ast_pipeline_module_struct_layout_set_field_align`.
 * Purpose: implements `ast_pipeline_module_struct_layout_set_field_align`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function ast_pipeline_module_struct_layout_set_field_align(m: *u8, li: i32, j: i32, al: i32): void {
  unsafe { pipeline_module_struct_layout_set_field_align(m, li, j, al); }
}
/** Function `codegen_codegen_x_ast_emit_header`.
 * Purpose: implements `codegen_codegen_x_ast_emit_header`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function codegen_codegen_x_ast_emit_header(out: *u8): i32 {
  unsafe { let r: i32 = codegen_x_ast_emit_header(out); return r; }
  return 0;
}
/** Function `codegen_codegen_x_ast`.
 * Purpose: implements `codegen_codegen_x_ast`; params/returns as declared.
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
function codegen_codegen_x_ast(module: *u8, arena: *u8, out: *u8, ctx: *u8, dep_index: i32): i32 {
  unsafe { let r: i32 = codegen_x_ast(module, arena, out, ctx, dep_index); return r; }
  return 0;
}
/**
 * X-ABI mangled face of pipeline_type_kind_ord_at.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object. This face only forwards.
 * @param a *u8 — type-table base; null is forwarded, not checked here
 * @param r i32 — row index forwarded unchanged
 * @return i32 — the value pipeline_type_kind_ord_at returns
 * #[no_mangle] keeps the signature-suffixed link name. The symbol stays strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail stays in the C seed.
 */
#[no_mangle]
function pipeline_type_kind_ord_at_u8_ptr_i32_reti32(a: *u8, r: i32): i32 {
  unsafe { let v: i32 = pipeline_type_kind_ord_at(a, r); return v; }
  return 0;
}
/**
 * X-ABI mangled face of glue_asm_build_func_export_sym_c.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in backend_call_dispatch. This face only forwards.
 * @param a *u8 — first pointer argument; null is forwarded, not checked here
 * @param b *u8 — second pointer argument; null is forwarded, not checked here
 * @param c i32 — integer argument forwarded unchanged
 * @param d *u8 — fourth pointer argument; null is forwarded, not checked here
 * @param e i32 — integer argument forwarded unchanged
 * @return i32 — the value glue_asm_build_func_export_sym_c returns
 * #[no_mangle] keeps the signature-suffixed link name. The symbol stays strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail stays in the C seed.
 */
#[no_mangle]
function glue_asm_build_func_export_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_reti32(a: *u8, b: *u8, c: i32, d: *u8, e: i32): i32 {
  unsafe { let v: i32 = glue_asm_build_func_export_sym_c(a, b, c, d, e); return v; }
  return 0;
}
/**
 * X-ABI mangled face of glue_asm_build_import_binding_call_sym.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in backend_call_dispatch. This face only forwards.
 * @param a *u8 — prefix buffer; null is forwarded, not checked here
 * @param b i32 — prefix length forwarded unchanged
 * @param c *u8 — field or c-name buffer; null is forwarded, not checked here
 * @param d i32 — field length forwarded unchanged
 * @param e *u8 — output buffer; null is forwarded, not checked here
 * @return i32 — the value glue_asm_build_import_binding_call_sym returns
 * #[no_mangle] keeps the signature-suffixed link name. The symbol stays strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail stays in the C seed.
 */
#[no_mangle]
function glue_asm_build_import_binding_call_sym_u8_ptr_i32_u8_ptr_i32_u8_ptr_reti32(a: *u8, b: i32, c: *u8, d: i32, e: *u8): i32 {
  unsafe { let v: i32 = glue_asm_build_import_binding_call_sym(a, b, c, d, e); return v; }
  return 0;
}
/**
 * X-ABI mangled face of glue_try_std_heap_redirect_sym_local.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in backend_call_dispatch. This face only forwards.
 * @param name *u8 — symbol name bytes; null is forwarded, not checked here
 * @param nlen i32 — name length forwarded unchanged
 * @param out *u8 — output buffer; null is forwarded, not checked here
 * @param cap i32 — output capacity forwarded unchanged
 * @return i32 — the value glue_try_std_heap_redirect_sym_local returns
 * #[no_mangle] keeps the signature-suffixed link name. The symbol stays strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail stays in the C seed.
 */
#[no_mangle]
function glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32(name: *u8, nlen: i32, out: *u8, cap: i32): i32 {
  unsafe { let v: i32 = glue_try_std_heap_redirect_sym_local(name, nlen, out, cap); return v; }
  return 0;
}
/**
 * X-ABI mangled face of glue_codegen_import_path_to_c_prefix_into.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in backend_call_dispatch and returns void.
 * This face only forwards. It does not check null or capacity.
 * @param path *u8 — import path bytes; null is forwarded, not checked here
 * @param buf *u8 — prefix output buffer; null is forwarded, not checked here
 * @param buf_cap i32 — output capacity forwarded unchanged
 * @return void — the callee writes the C prefix into buf
 * #[no_mangle] keeps the signature-suffixed link name. The symbol stays strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32(path: *u8, buf: *u8, buf_cap: i32): void {
  unsafe { glue_codegen_import_path_to_c_prefix_into(path, buf, buf_cap); }
}
/**
 * X-ABI mangled face of pipeline_expr_field_access_name_len.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object. This face only forwards.
 * It does not check null. The symbol stays weak so another definition can win.
 * @param a *u8 — arena or expression table; null is forwarded, not checked here
 * @param er i32 — expression row forwarded unchanged
 * @return i32 — the value pipeline_expr_field_access_name_len returns
 * #[no_mangle] keeps the signature-suffixed link name.
 * The installer weakens this symbol by name. Do not make it strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * remaining XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(a: *u8, er: i32): i32 {
  unsafe { let v: i32 = pipeline_expr_field_access_name_len(a, er); return v; }
  return 0;
}
/**
 * X-ABI mangled face of pipeline_expr_field_access_base_ref.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object. This face only forwards.
 * It does not check null. The symbol stays weak so another definition can win.
 * @param a *u8 — arena or expression table; null is forwarded, not checked here
 * @param er i32 — expression row forwarded unchanged
 * @return i32 — the value pipeline_expr_field_access_base_ref returns
 * #[no_mangle] keeps the signature-suffixed link name.
 * The installer weakens this symbol by name. Do not make it strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * remaining XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(a: *u8, er: i32): i32 {
  unsafe { let v: i32 = pipeline_expr_field_access_base_ref(a, er); return v; }
  return 0;
}
/**
 * X-ABI mangled face of pipeline_expr_binop_left_ref_at.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object. This face only forwards.
 * It does not check null. The symbol stays weak so another definition can win.
 * @param a *u8 — arena or expression table; null is forwarded, not checked here
 * @param er i32 — expression row forwarded unchanged
 * @return i32 — the value pipeline_expr_binop_left_ref_at returns
 * #[no_mangle] keeps the signature-suffixed link name.
 * The installer weakens this symbol by name. Do not make it strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * remaining XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(a: *u8, er: i32): i32 {
  unsafe { let v: i32 = pipeline_expr_binop_left_ref_at(a, er); return v; }
  return 0;
}
/**
 * X-ABI mangled face of pipeline_expr_binop_right_ref_at.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object. This face only forwards.
 * It does not check null. The symbol stays weak so another definition can win.
 * @param a *u8 — arena or expression table; null is forwarded, not checked here
 * @param er i32 — expression row forwarded unchanged
 * @return i32 — the value pipeline_expr_binop_right_ref_at returns
 * #[no_mangle] keeps the signature-suffixed link name.
 * The installer weakens this symbol by name. Do not make it strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * remaining XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(a: *u8, er: i32): i32 {
  unsafe { let v: i32 = pipeline_expr_binop_right_ref_at(a, er); return v; }
  return 0;
}
/**
 * X-ABI mangled face of pipeline_expr_field_access_name_into.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object and returns void.
 * This face only forwards. It does not check null or write dst itself.
 * The symbol stays weak so another definition can win.
 * This is a void three-argument face, not the i32 two-argument forwarder.
 * @param a *u8 — arena or expression table; null is forwarded, not checked here
 * @param er i32 — expression row forwarded unchanged
 * @param dst *u8 — destination name buffer; null is forwarded, not checked here
 * @return void — the callee writes the field name into dst
 * #[no_mangle] keeps the signature-suffixed link name.
 * The installer weakens this symbol by name. Do not make it strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * remaining XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(a: *u8, er: i32, dst: *u8): void {
  unsafe { pipeline_expr_field_access_name_into(a, er, dst); }
}
/**
 * X-ABI mangled face of pipeline_dep_ctx_ndep.
 * Callers that were emitted with the signature suffix resolve this symbol.
 * The unsuffixed body stays in the pipeline object. This face only forwards.
 * It does not check null. The symbol stays weak so another definition can win.
 * This is an i32 one-argument face, not the void three-argument forwarder
 * and not the i32 two-argument forwarder.
 * @param ctx *u8 — dependency context; null is forwarded, not checked here
 * @return i32 — the value pipeline_dep_ctx_ndep returns
 * #[no_mangle] keeps the signature-suffixed link name.
 * The installer weakens this symbol by name. Do not make it strong.
 * PLATFORM: SHARED — pure asm. The lexer struct-return tail and the
 * remaining XLANG_WEAK cluster stay in the C seed.
 */
#[no_mangle]
function pipeline_dep_ctx_ndep_u8_ptr_reti32(ctx: *u8): i32 {
  unsafe { let v: i32 = pipeline_dep_ctx_ndep(ctx); return v; }
  return 0;
}
