// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

// PLATFORM: SHARED — all export extern "C" hoisted before first use so -E emits
// short-name prototypes matching call sites (late mid-file externs caused type-mangle
// decls vs short calls → undeclared + cc fail). Product ABI = short pipeline_* names.
/* wave232 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product hybrid full.x path owns WPO mono env gates. */
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function pipeline_expr_resolved_type_ref(arena: *u8, er: i32): i32;
export extern "C" function asm_ctx_scope_block_ref_at(asm_ctx: *u8): i32;
export extern "C" function pipeline_block_resolve_var_type_ref(arena: *u8, br: i32, vname: *u8, vlen: i32): i32;
export extern "C" function pipeline_module_num_struct_layouts_at(mod: *u8): i32;
export extern "C" function pipeline_module_struct_layout_name_len(mod: *u8, idx: i32): i32;
export extern "C" function pipeline_module_struct_layout_name_byte_at(mod: *u8, idx: i32, off: i32): u8;
export extern "C" function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
export extern "C" function pipeline_type_named_name_into(arena: *u8, tr: i32, out64: *u8): i32;
export extern "C" function pipeline_asm_module_func_param_name_len_at(mod: *u8, fi: i32, pix: i32): i32;
export extern "C" function pipeline_asm_module_func_param_name_copy32(mod: *u8, fi: i32, pix: i32, dst: *u8): void;
export extern "C" function pipeline_asm_module_func_num_params_at(mod: *u8, fi: i32): i32;
export extern "C" function pipeline_module_num_funcs(mod: *u8): i32;
export extern "C" function pipeline_asm_module_func_name_len_at(mod: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_name_copy64(mod: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_module_func_body_ref_at(mod: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_block_final_expr_ref_at(arena: *u8, body: i32): i32;
export extern "C" function pipeline_expr_unary_operand_ref_at(arena: *u8, er: i32): i32;
export extern "C" function ast_ast_block_num_expr_stmts(arena: *u8, body: i32): i32;
export extern "C" function ast_ast_block_expr_stmt_ref(arena: *u8, body: i32, ei: i32): i32;
export extern "C" function pipeline_expr_struct_lit_num_fields(arena: *u8, lit: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_name_len(arena: *u8, lit: i32, j: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_name_into(arena: *u8, lit: i32, j: i32, dst: *u8): void;
export extern "C" function pipeline_expr_kind_ord_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena: *u8, mod: *u8, er: i32): i32;
export extern "C" function pipeline_asm_var_is_emit_func_param_ptr_c(arena: *u8, mod: *u8, asm_ctx: *u8, er: i32): i32;
export extern "C" function pipeline_asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32;
export extern "C" function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit: i32): i32;
export extern "C" function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern "C" function backend_fold_func_return_operand_ref(arena: *u8, mod: *u8, fi: i32): i32;
export extern "C" function backend_enc_load_rbp_to_rax_arch(elf: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_enc_lea_rbp_to_rax_arch(elf: *u8, offset: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_load_rbp_to_rax(out: *u8, off: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_lea_rbp_to_rax(out: *u8, off: i32, ta: i32): i32;
export extern "C" function pipeline_expr_call_resolved_dep_index_at(arena: *u8, call: i32): i32;
export extern "C" function pipeline_expr_call_resolved_func_index_at(arena: *u8, call: i32): i32;
export extern "C" function pipeline_dep_ctx_arena_at(pctx: *u8, di: i32): *u8;
export extern "C" function pipeline_asm_emit_dep_pipe_c(): *u8;
export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, er: i32, idx: i32): i32;
export extern "C" function pipeline_expr_call_callee_ref_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_name_len(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_access_name_into(arena: *u8, er: i32, out: *u8): void;
export extern "C" function pipeline_expr_array_lit_num_elems_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_array_lit_elem_ref(arena: *u8, er: i32, lane: i32): i32;
export extern "C" function pipeline_expr_struct_lit_init_ref(arena: *u8, lit: i32, fj: i32): i32;
export extern "C" function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern "C" function asm_type_is_simd_vector_spelling(arena: *u8, tr: i32): i32;
export extern "C" function asm_type_is_simd_vector(arena: *u8, tr: i32): i32;
export extern "C" function pipeline_expr_binop_left_ref_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_binop_right_ref_at(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_index_base_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_expr_index_index_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_dep_ctx_ndep(pctx: *u8): i32;
export extern "C" function pipeline_dep_ctx_module_at(pctx: *u8, di: i32): *u8;
export extern "C" function pipeline_module_struct_layout_num_fields(mod: *u8, li: i32): i32;
export extern "C" function pipeline_module_struct_layout_field_name_len(mod: *u8, li: i32, j: i32): i32;
export extern "C" function pipeline_module_struct_layout_field_name_into(mod: *u8, li: i32, j: i32, dst: *u8): void;
export extern "C" function pipeline_module_struct_layout_field_offset_at(mod: *u8, li: i32, j: i32): i32;
export extern "C" function pipeline_expr_field_access_base_ref(arena: *u8, er: i32): i32;
export extern "C" function pipeline_asm_emit_func_index_c(): i32;
export extern "C" function pipeline_type_elem_ref_at(arena: *u8, tr: i32): i32;
export extern "C" function typeck_get_field_offset_from_layout_deps(mod: *u8, pctx: *u8, tname: *u8, tlen: i32, fname: *u8, flen: i32): i32;
export extern "C" function pipeline_expr_field_access_layout_offset(arena: *u8, mod: *u8, fa: i32): i32;
export extern "C" function pipeline_expr_call_num_args_at(arena: *u8, er: i32): i32;
export extern "C" function glue_with_arena_scope_active_c(): i32;
export extern "C" function glue_with_arena_scope_top_off_c(): i32;
export extern "C" function backend_enc_mov_imm64_to_rax_arch(elf: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern "C" function backend_enc_store_rax_to_rbx_offset_arch(elf: *u8, off: i32, sz: i32, ta: i32): i32;
export extern "C" function backend_enc_call_arch(elf: *u8, name: *u8, nlen: i32, ta: i32): i32;
export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf: *u8, imm: i32, ta: i32): i32;
export extern "C" function pipeline_expr_int_val_at(arena: *u8, er: i32): i32;
export extern "C" function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32;
export extern "C" function asm_ctx_local_find_offset(ctx: *u8, name: *u8, nlen: i32): i32;
export extern "C" function backend_fold_func_x_plus_k_chain(arena: *u8, mod: *u8, fi: i32, depth: i32): i32;
export extern "C" function pipeline_asm_emit_expr_elf_c(arena: *u8, elf: *u8, er: i32, ctx: *u8, ta: i32): i32;
export extern "C" function backend_enc_add_imm_to_rax_arch(elf: *u8, imm: i32, ta: i32): i32;
export extern "C" function backend_fold_func_returns_param0_single_field(arena: *u8, mod: *u8, fi: i32): i32;
export extern "C" function backend_fold_func_returns_param0_field_sum(arena: *u8, mod: *u8, fi: i32): i32;
export extern "C" function backend_enc_load_32_from_rax_arch(elf: *u8, ta: i32): i32;
export extern "C" function backend_enc_push_rax_arch(elf: *u8, ta: i32): i32;
export extern "C" function backend_enc_pop_rax_arch(elf: *u8, ta: i32): i32;
export extern "C" function backend_enc_mov_rax_to_rbx_arch(elf: *u8, ta: i32): i32;
export extern "C" function backend_enc_add_rax_rbx_arch(elf: *u8, ta: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_offset_at(a: *u8, m: *u8, er: i32, fj: i32): i32;
export extern "C" function pipeline_expr_struct_lit_field_store_sz(a: *u8, m: *u8, er: i32, fj: i32): i32;
export extern "C" function backend_enc_call_stack_cleanup_arch(elf: *u8, nbytes: i32, ta: i32): i32;
export extern "C" function glue_wpo_mono_register_thunk(name: *u8, a0: i32, a1: i32, folded: i32): void;
export extern "C" function codegen_wpo_mono_sym_format(name: *u8, nargs: i32, args: *i32, out: *u8, out_cap: i32): i32;
export extern "C" function glue_wpo_mono_register_thunk_n(name: *u8, nargs: i32, args: *i32, folded: i32): void;

/** Exported function `backend_try_inline_dispatch_x_doc_anchor`.
 * Implements `backend_try_inline_dispatch_x_doc_anchor`.
 * @return i32
 */
export function backend_try_inline_dispatch_x_doc_anchor(): i32 {
  return 0;
}

// See implementation.

// See implementation.


/* ---- G-02f-109 / G-02f-134：try_inline helpers ---- */

// glue_module_func_index_by_name: see function docblock below.
/** Exported function `glue_module_func_index_by_name`.
 * Implements `glue_module_func_index_by_name`.
 * @param mod *u8
 * @param name *u8
 * @param nlen i32
 * @return i32
 */
#[no_mangle]
export function glue_module_func_index_by_name(mod: *u8, name: *u8, nlen: i32): i32 {
  if (mod == 0) { return 0 - 1; }
  if (name == 0) { return 0 - 1; }
  if (nlen <= 0) { return 0 - 1; }
  if (nlen > 63) { return 0 - 1; }
  unsafe {
    let nfuncs: i32 = pipeline_module_num_funcs(mod);
    let fi: i32 = 0;
    while (fi < nfuncs) {
      let flen: i32 = pipeline_asm_module_func_name_len_at(mod, fi);
      if (flen == nlen) {
        let fb: u8[64] = [];
        pipeline_asm_module_func_name_copy64(mod, fi, &fb[0]);
        let k: i32 = 0;
        let ok: i32 = 1;
        while (k < nlen) {
          if (fb[k] != name[k]) { ok = 0; break; }
          k = k + 1;
        }
        if (ok != 0) { return fi; }
      }
      fi = fi + 1;
    }
  }
  return 0 - 1;
}

// glue_const_scalar_binop_eval_i32: see function docblock below.
/** Exported function `glue_const_scalar_binop_eval_i32`.
 * Implements `glue_const_scalar_binop_eval_i32`.
 * @param ko i32
 * @param a i32
 * @param b i32
 * @param out *i32
 * @return i32
 */
#[no_mangle]
export function glue_const_scalar_binop_eval_i32(ko: i32, a: i32, b: i32, out: *i32): i32 {
  if (out == 0) { return 0; }
  let wide: i64 = 0;
  if (ko == 4) {
    wide = (a as i64) + (b as i64);
  } else if (ko == 5) {
    wide = (a as i64) - (b as i64);
  } else if (ko == 6) {
    wide = (a as i64) * (b as i64);
  } else if (ko == 7) {
    if (b == 0) { return 0; }
    wide = (a as i64) / (b as i64);
  } else if (ko == 8) {
    if (b == 0) { return 0; }
    wide = (a as i64) % (b as i64);
  } else {
    return 0;
  }
  unsafe { out[0] = wide as i32; }
  return 1;
}

// glue_module_named_type_has_struct_layout: see function docblock below.
/** Exported function `glue_module_named_type_has_struct_layout`.
 * Implements `glue_module_named_type_has_struct_layout`.
 * @param mod *u8
 * @param name *u8
 * @param nlen i32
 * @return i32
 */
#[no_mangle]
export function glue_module_named_type_has_struct_layout(mod: *u8, name: *u8, nlen: i32): i32 {
  if (mod == 0) { return 0; }
  if (name == 0) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let n: i32 = pipeline_module_num_struct_layouts_at(mod);
    let k: i32 = 0;
    while (k < n) {
      let ln: i32 = pipeline_module_struct_layout_name_len(mod, k);
      if (ln == nlen) {
        if (ln > 0) {
          let j: i32 = 0;
          let ok: i32 = 1;
          while (j < nlen) {
            if (pipeline_module_struct_layout_name_byte_at(mod, k, j) != name[j]) {
              ok = 0;
              break;
            }
            j = j + 1;
          }
          if (ok != 0) { return 1; }
        }
      }
      k = k + 1;
    }
  }
  return 0;
}

// glue_type_ref_is_named_struct_layout: see function docblock below.
/** Exported function `glue_type_ref_is_named_struct_layout`.
 * Implements `glue_type_ref_is_named_struct_layout`.
 * @param arena *u8
 * @param mod *u8
 * @param ty_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_type_ref_is_named_struct_layout(arena: *u8, mod: *u8, ty_ref: i32): i32 {
  if (ty_ref <= 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    if (pipeline_type_kind_ord_at(arena, ty_ref) != 8) { return 0; }
    let nm: u8[64] = [];
    let nlen: i32 = pipeline_type_named_name_into(arena, ty_ref, &nm[0]);
    if (nlen <= 0) { return 0; }
    return glue_module_named_type_has_struct_layout(mod, &nm[0], nlen);
  }
  return 0;
}
/** Load little-endian pointer from p[off..off+8). Null p → null.
 * Used for AsmFuncCtx module_ref @16 and dep_pipe @1256 (64-bit LE).
 * Track-L: no_mangle keeps surface short name g02f_load_ptr_at.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function g02f_load_ptr_at(p: *u8, off: i32): *u8 {
  if (p == 0) { return 0 as *u8; }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = p[off] as usize;
  a = a + (p[off + 1] as usize) * m;
  a = a + (p[off + 2] as usize) * m2;
  a = a + (p[off + 3] as usize) * (m2 * m);
  a = a + (p[off + 4] as usize) * m4;
  a = a + (p[off + 5] as usize) * (m4 * m);
  a = a + (p[off + 6] as usize) * (m4 * m2);
  a = a + (p[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/** Store little-endian pointer val into p[off..off+8). Null p is a no-op.
 * Track-L: no_mangle keeps surface short name g02f_store_ptr_at.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function g02f_store_ptr_at(p: *u8, off: i32, val: *u8): void {
  if (p == 0) { return; }
  let a: usize = val as usize;
  let m: usize = 256;
  p[off + 0] = (a % m) as u8;
  a = a / m;
  p[off + 1] = (a % m) as u8;
  a = a / m;
  p[off + 2] = (a % m) as u8;
  a = a / m;
  p[off + 3] = (a % m) as u8;
  a = a / m;
  p[off + 4] = (a % m) as u8;
  a = a / m;
  p[off + 5] = (a % m) as u8;
  a = a / m;
  p[off + 6] = (a % m) as u8;
  a = a / m;
  p[off + 7] = (a % m) as u8;
}

// See implementation.
// GLUE_EXPR_VAR=3 TYPE_PTR=9 TYPE_NAMED=8
/** Exported function `asm_local_var_slot_holds_indirect_ptr`.
 * Implements `asm_local_var_slot_holds_indirect_ptr`.
 * @param arena *u8
 * @param expr_ref i32
 * @param mod *u8
 * @param asm_ctx *u8
 * @return i32
 */
#[no_mangle]
export function asm_local_var_slot_holds_indirect_ptr(arena: *u8, expr_ref: i32, mod: *u8, asm_ctx: *u8): i32 {
  if (arena == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  let has_block_decl: i32 = 0;
  let decl_ty: i32 = 0;
  let ko: i32 = 0;
  unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
  if (asm_ctx != 0) {
    if (ko == 3) {
      let vlen: i32 = 0;
      unsafe { vlen = pipeline_expr_var_name_len(arena, expr_ref); }
      if (vlen > 0) {
        if (vlen <= 63) {
          let vname: u8[64] = [];
          unsafe { pipeline_expr_var_name_into(arena, expr_ref, &vname[0]); }
          let scope_br: i32 = 0;
          unsafe { scope_br = asm_ctx_scope_block_ref_at(asm_ctx); }
          if (scope_br > 0) {
            unsafe { decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen); }
            if (decl_ty > 0) { has_block_decl = 1; }
          }
        }
      }
    }
  }
  if (has_block_decl != 0) {
    let kind: i32 = 0;
    unsafe { kind = pipeline_type_kind_ord_at(arena, decl_ty); }
    if (kind == 9) { return 1; }
    if (glue_type_ref_is_named_struct_layout(arena, mod, decl_ty) != 0) { return 0; }
    return 0;
  }
  let tr: i32 = 0;
  unsafe { tr = pipeline_expr_resolved_type_ref(arena, expr_ref); }
  if (tr <= 0) {
    unsafe {
      if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) { return 1; }
      if (mod != 0) {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) { return 1; }
      }
    }
    return 0;
  }
  let kind2: i32 = 0;
  unsafe { kind2 = pipeline_type_kind_ord_at(arena, tr); }
  if (kind2 == 9) { return 1; }
  if (glue_type_ref_is_named_struct_layout(arena, mod, tr) != 0) {
    if (mod != 0) {
      unsafe {
        if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) { return 1; }
      }
    }
    return 0;
  }
  if (kind2 == 8) { return 0; }
  unsafe {
    if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) { return 1; }
  }
  return 0;
}

/** Exported function `glue_local_var_slot_holds_indirect_ptr`.
 * Implements `glue_local_var_slot_holds_indirect_ptr`.
 * @param arena *u8
 * @param er i32
 * @param asm_ctx *u8
 * @return i32
 */
#[no_mangle]
export function glue_local_var_slot_holds_indirect_ptr(arena: *u8, er: i32, asm_ctx: *u8): i32 {
  let mod_ref: *u8 = 0 as *u8;
  if (asm_ctx != 0) {
    mod_ref = g02f_load_ptr_at(asm_ctx, 16);
  }
  return asm_local_var_slot_holds_indirect_ptr(arena, er, mod_ref, asm_ctx);
}

// glue_expr_is_func_param_at: see function docblock below.
/** Exported function `glue_expr_is_func_param_at`.
 * Implements `glue_expr_is_func_param_at`.
 * @param arena *u8
 * @param mod *u8
 * @param fi i32
 * @param er i32
 * @param pix i32
 * @return i32
 */
#[no_mangle]
export function glue_expr_is_func_param_at(arena: *u8, mod: *u8, fi: i32, er: i32, pix: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, er) != 3) { return 0; }
    let plen: i32 = pipeline_asm_module_func_param_name_len_at(mod, fi, pix);
    let vlen: i32 = pipeline_expr_var_name_len(arena, er);
    if (plen <= 0) { return 0; }
    if (plen != vlen) { return 0; }
    let pbuf: u8[32] = [];
    let vbuf: u8[64] = [];
    pipeline_asm_module_func_param_name_copy32(mod, fi, pix, &pbuf[0]);
    pipeline_expr_var_name_into(arena, er, &vbuf[0]);
    let k: i32 = 0;
    while (k < plen) {
      if (pbuf[k] != vbuf[k]) { return 0; }
      k = k + 1;
    }
    return 1;
  }
  return 0;
}
// glue_fold_func_return_operand_ref_module: see function docblock below.
/** Exported function `glue_fold_func_return_operand_ref_module`.
 * Implements `glue_fold_func_return_operand_ref_module`.
 * @param arena *u8
 * @param mod *u8
 * @param fi i32
 * @return i32
 */
#[no_mangle]
export function glue_fold_func_return_operand_ref_module(arena: *u8, mod: *u8, fi: i32): i32 {
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (fi < 0) { return 0; }
  unsafe {
    let body_ref: i32 = pipeline_module_func_body_ref_at(mod, fi);
    if (body_ref <= 0) { return 0; }
    let fin: i32 = pipeline_asm_block_final_expr_ref_at(arena, body_ref);
    if (fin != 0) {
      if (pipeline_expr_kind_ord_at(arena, fin) == 41) {
        let op_e: i32 = pipeline_expr_unary_operand_ref_at(arena, fin);
        if (op_e != 0) { return op_e; }
      }
      return fin;
    }
    let nes: i32 = ast_ast_block_num_expr_stmts(arena, body_ref);
    let found: i32 = 0;
    let op_ref: i32 = 0;
    let ei: i32 = 0;
    while (ei < nes) {
      let er: i32 = ast_ast_block_expr_stmt_ref(arena, body_ref, ei);
      if (er > 0) {
        if (pipeline_expr_kind_ord_at(arena, er) == 41) {
          let op_e: i32 = pipeline_expr_unary_operand_ref_at(arena, er);
          if (op_e != 0) {
            found = found + 1;
            op_ref = op_e;
          }
        }
      }
      ei = ei + 1;
    }
    if (found == 1) { return op_ref; }
  }
  return 0;
}

// glue_try_fold_func_return_operand_ref: see function docblock below.
/** Exported function `glue_try_fold_func_return_operand_ref`.
 * Implements `glue_try_fold_func_return_operand_ref`.
 * @param arena *u8
 * @param mod *u8
 * @param fi i32
 * @return i32
 */
#[no_mangle]
export function glue_try_fold_func_return_operand_ref(arena: *u8, mod: *u8, fi: i32): i32 {
  unsafe {
    let r: i32 = backend_fold_func_return_operand_ref(arena, mod, fi);
    if (r > 0) { return r; }
    return glue_fold_func_return_operand_ref_module(arena, mod, fi);
  }
  return 0;
}


// See implementation.


// See implementation.

/* ---- G-02f-110 / G-02f-136 / G-02f-138：try_inline fold/field ---- */

// See implementation.
// module_ref@16，dep_pipe@1256；FIELD_ACCESS=44，VAR=3
/** Exported function `glue_call_lookup_callee_mod_fi_arena`.
 * Implements `glue_call_lookup_callee_mod_fi_arena`.
 * @param caller_arena *u8
 * @param call_ref i32
 * @param ctx *u8
 * @param out_ca *u8
 * @param out_cm *u8
 * @param out_fi *i32
 * @return i32
 */
#[no_mangle]
export function glue_call_lookup_callee_mod_fi_arena(caller_arena: *u8, call_ref: i32, ctx: *u8, out_ca: *u8, out_cm: *u8, out_fi: *i32): i32 {
  if (caller_arena == 0) { return 0; }
  if (call_ref <= 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (out_ca == 0) { return 0; }
  if (out_cm == 0) { return 0; }
  if (out_fi == 0) { return 0; }
  unsafe {
    let entry_mod: *u8 = g02f_load_ptr_at(ctx, 16);
    if (entry_mod == 0) { return 0; }
    g02f_store_ptr_at(out_ca, 0, caller_arena);
    g02f_store_ptr_at(out_cm, 0, entry_mod);
    out_fi[0] = 0 - 1;
    let dep_ix: i32 = pipeline_expr_call_resolved_dep_index_at(caller_arena, call_ref);
    let func_ix: i32 = pipeline_expr_call_resolved_func_index_at(caller_arena, call_ref);
    if (func_ix >= 0) {
      out_fi[0] = func_ix;
      if (dep_ix >= 0) {
        let pctx: *u8 = g02f_load_ptr_at(ctx, 1256);
        if (pctx == 0) {
          pctx = pipeline_asm_emit_dep_pipe_c();
        }
        if (pctx == 0) { return 0; }
        let cm: *u8 = pipeline_dep_ctx_module_at(pctx, dep_ix);
        if (cm == 0) { return 0; }
        g02f_store_ptr_at(out_cm, 0, cm);
        let da: *u8 = pipeline_dep_ctx_arena_at(pctx, dep_ix);
        if (da != 0) {
          g02f_store_ptr_at(out_ca, 0, da);
        }
      }
      if (g02f_load_ptr_at(out_cm, 0) != 0) { return 1; }
      return 0;
    }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(caller_arena, call_ref);
    if (callee_ref <= 0) { return 0; }
    // import binding：FIELD_ACCESS callee
    if (pipeline_expr_kind_ord_at(caller_arena, callee_ref) == 44) {
      let field_len: i32 = pipeline_expr_field_access_name_len(caller_arena, callee_ref);
      if (field_len > 0) {
        if (field_len <= 63) {
          let field_name: u8[64] = [];
          pipeline_expr_field_access_name_into(caller_arena, callee_ref, &field_name[0]);
          let pctx2: *u8 = g02f_load_ptr_at(ctx, 1256);
          if (pctx2 == 0) {
            pctx2 = pipeline_asm_emit_dep_pipe_c();
          }
          if (pctx2 != 0) {
            let j: i32 = 0;
            let nd: i32 = pipeline_dep_ctx_ndep(pctx2);
            while (j < nd) {
              let dm: *u8 = pipeline_dep_ctx_module_at(pctx2, j);
              let da2: *u8 = pipeline_dep_ctx_arena_at(pctx2, j);
              if (dm != 0) {
                let fi2: i32 = glue_module_func_index_by_name(dm, &field_name[0], field_len);
                if (fi2 >= 0) {
                  out_fi[0] = fi2;
                  g02f_store_ptr_at(out_cm, 0, dm);
                  if (da2 != 0) {
                    g02f_store_ptr_at(out_ca, 0, da2);
                  }
                  return 1;
                }
              }
              j = j + 1;
            }
          }
        }
      }
      return 0;
    }
    if (pipeline_expr_kind_ord_at(caller_arena, callee_ref) != 3) { return 0; }
    let clen: i32 = pipeline_expr_var_name_len(caller_arena, callee_ref);
    if (clen <= 0) { return 0; }
    if (clen > 63) { return 0; }
    let cname: u8[64] = [];
    pipeline_expr_var_name_into(caller_arena, callee_ref, &cname[0]);
    let fi3: i32 = glue_module_func_index_by_name(entry_mod, &cname[0], clen);
    if (fi3 >= 0) {
      out_fi[0] = fi3;
      return 1;
    }
    let pctx3: *u8 = g02f_load_ptr_at(ctx, 1256);
    if (pctx3 == 0) {
      pctx3 = pipeline_asm_emit_dep_pipe_c();
    }
    if (pctx3 == 0) { return 0; }
    let j2: i32 = 0;
    let nd2: i32 = pipeline_dep_ctx_ndep(pctx3);
    while (j2 < nd2) {
      let dm2: *u8 = pipeline_dep_ctx_module_at(pctx3, j2);
      let da3: *u8 = pipeline_dep_ctx_arena_at(pctx3, j2);
      if (dm2 != 0) {
        let fi4: i32 = glue_module_func_index_by_name(dm2, &cname[0], clen);
        if (fi4 >= 0) {
          out_fi[0] = fi4;
          g02f_store_ptr_at(out_cm, 0, dm2);
          if (da3 != 0) {
            g02f_store_ptr_at(out_ca, 0, da3);
          }
          return 1;
        }
      }
      j2 = j2 + 1;
    }
  }
  return 0;
}

// glue_fold_func_returns_param01_scalar_binop: see function docblock below.
/** Exported function `glue_fold_func_returns_param01_scalar_binop`.
 * Implements `glue_fold_func_returns_param01_scalar_binop`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param out_binop_ko *i32
 * @return i32
 */
#[no_mangle]
export function glue_fold_func_returns_param01_scalar_binop(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32 {
  if (out_binop_ko == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  unsafe {
    if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 2) { return 0; }
    let ret_ty: i32 = pipeline_module_func_return_type_at(mod, func_idx);
    if (ret_ty > 0) {
      if (asm_type_is_simd_vector_spelling(arena, ret_ty) != 0) { return 0; }
      if (asm_type_is_simd_vector(arena, ret_ty) != 0) { return 0; }
    }
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    if (ret_ref <= 0) { return 0; }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, ret_ref);
    if (ko != 4) {
      if (ko != 5) {
        if (ko != 6) {
          if (ko != 7) {
            if (ko != 8) { return 0; }
          }
        }
      }
    }
    let al: i32 = pipeline_expr_binop_left_ref_at(arena, ret_ref);
    let ar: i32 = pipeline_expr_binop_right_ref_at(arena, ret_ref);
    if (glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) == 0) { return 0; }
    if (glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) == 0) { return 0; }
    out_binop_ko[0] = ko;
    return 1;
  }
  return 0;
}
// glue_enc_local_slot_ptr_or_addr: see function docblock below.
/** Exported function `glue_enc_local_slot_ptr_or_addr`.
 * Implements `glue_enc_local_slot_ptr_or_addr`.
 * @param arena *u8
 * @param elf *u8
 * @param arg_ref i32
 * @param slot_off i32
 * @param ta i32
 * @param asm_ctx *u8
 * @return i32
 */
#[no_mangle]
export function glue_enc_local_slot_ptr_or_addr(arena: *u8, elf: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    if (glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) != 0) {
      return backend_enc_load_rbp_to_rax_arch(elf, slot_off, ta);
    }
    return backend_enc_lea_rbp_to_rax_arch(elf, slot_off, ta);
  }
  return 0;
}

/** Exported function `glue_arch_emit_local_slot_ptr_or_addr_text`.
 * Implements `glue_arch_emit_local_slot_ptr_or_addr_text`.
 * @param arena *u8
 * @param out *u8
 * @param arg_ref i32
 * @param slot_off i32
 * @param ta i32
 * @param asm_ctx *u8
 * @return i32
 */
#[no_mangle]
export function glue_arch_emit_local_slot_ptr_or_addr_text(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  unsafe {
    if (glue_local_var_slot_holds_indirect_ptr(arena, arg_ref, asm_ctx) != 0) {
      return backend_arch_emit_load_rbp_to_rax(out, slot_off, ta);
    }
    return backend_arch_emit_lea_rbp_to_rax(out, slot_off, ta);
  }
  return 0;
}
// glue_struct_lit_field_init_param_index: see function docblock below.
/** Exported function `glue_struct_lit_field_init_param_index`.
 * Implements `glue_struct_lit_field_init_param_index`.
 * @param arena *u8
 * @param mod *u8
 * @param fi i32
 * @param lit i32
 * @param fj i32
 * @param out_pix *i32
 * @return i32
 */
#[no_mangle]
export function glue_struct_lit_field_init_param_index(arena: *u8, mod: *u8, fi: i32, lit: i32, fj: i32, out_pix: *i32): i32 {
  if (out_pix == 0) { return 0 - 1; }
  unsafe {
    let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, lit, fj);
    if (init_ref <= 0) { return 0 - 1; }
    let np: i32 = pipeline_asm_module_func_num_params_at(mod, fi);
    let pi: i32 = 0;
    while (pi < np) {
      if (glue_expr_is_func_param_at(arena, mod, fi, init_ref, pi) != 0) {
        out_pix[0] = pi;
        return 0;
      }
      pi = pi + 1;
    }
  }
  return 0 - 1;
}

// G-02f-135：return Struct{f:param…}；STRUCT_LIT=45，max fields=8
/** Exported function `glue_fold_func_returns_param_struct_lit`.
 * Implements `glue_fold_func_returns_param_struct_lit`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param out_lit_ref *i32
 * @return i32
 */
#[no_mangle]
export function glue_fold_func_returns_param_struct_lit(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32 {
  if (out_lit_ref == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    let ret_ref: i32 = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
    if (ret_ref <= 0) {
      ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
    }
    if (ret_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, ret_ref) != 45) { return 0; }
    let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
    if (nf <= 0) { return 0; }
    if (nf > 8) { return 0; }
    let fj: i32 = 0;
    while (fj < nf) {
      let pix: i32 = 0;
      if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &pix) != 0) {
        return 0;
      }
      fj = fj + 1;
    }
    out_lit_ref[0] = ret_ref;
    return 1;
  }
  return 0;
}

// glue_struct_lit_field_index_by_name: see function docblock below.
/** Exported function `glue_struct_lit_field_index_by_name`.
 * Implements `glue_struct_lit_field_index_by_name`.
 * @param arena *u8
 * @param lit_ref i32
 * @param fn *u8
 * @param fnlen i32
 * @return i32
 */
#[no_mangle]
export function glue_struct_lit_field_index_by_name(arena: *u8, lit_ref: i32, fn: *u8, fnlen: i32): i32 {
  if (arena == 0) { return 0 - 1; }
  if (fn == 0) { return 0 - 1; }
  unsafe {
    let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
    let j: i32 = 0;
    while (j < nf) {
      let slen: i32 = pipeline_expr_struct_lit_field_name_len(arena, lit_ref, j);
      if (slen == fnlen) {
        if (slen > 0) {
          if (slen <= 63) {
            let sb: u8[64] = [];
            pipeline_expr_struct_lit_field_name_into(arena, lit_ref, j, &sb[0]);
            let k: i32 = 0;
            let ok: i32 = 1;
            while (k < slen) {
              if (sb[k] != fn[k]) { ok = 0; break; }
              k = k + 1;
            }
            if (ok != 0) { return j; }
          }
        }
      }
      j = j + 1;
    }
  }
  return 0 - 1;
}
// See implementation.
// CALL=48，FIELD_ACCESS=44
/** Exported function `glue_inner_call_arg_for_field_access`.
 * Implements `glue_inner_call_arg_for_field_access`.
 * @param arena *u8
 * @param ctx *u8
 * @param inner_call_ref i32
 * @param outer_field_ref i32
 * @param out_arg_ref *i32
 * @return i32
 */
#[no_mangle]
export function glue_inner_call_arg_for_field_access(arena: *u8, ctx: *u8, inner_call_ref: i32, outer_field_ref: i32, out_arg_ref: *i32): i32 {
  if (out_arg_ref == 0) { return 0; }
  if (inner_call_ref <= 0) { return 0; }
  if (outer_field_ref <= 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (arena == 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, inner_call_ref) != 48) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, outer_field_ref) != 44) { return 0; }
    let ca_slot: u8[8] = [];
    let cm_slot: u8[8] = [];
    let inner_fi: i32 = 0;
    if (glue_call_lookup_callee_mod_fi_arena(arena, inner_call_ref, ctx, &ca_slot[0], &cm_slot[0], &inner_fi) == 0) {
      return 0;
    }
    let callee_arena: *u8 = g02f_load_ptr_at(&ca_slot[0], 0);
    let callee_mod: *u8 = g02f_load_ptr_at(&cm_slot[0], 0);
    let lit_ref: i32 = 0;
    if (glue_fold_func_returns_param_struct_lit(callee_arena, callee_mod, inner_fi, &lit_ref) == 0) {
      return 0;
    }
    let flen: i32 = pipeline_expr_field_access_name_len(arena, outer_field_ref);
    if (flen <= 0) { return 0; }
    if (flen > 63) { return 0; }
    let fname: u8[64] = [];
    pipeline_expr_field_access_name_into(arena, outer_field_ref, &fname[0]);
    let fj: i32 = glue_struct_lit_field_index_by_name(callee_arena, lit_ref, &fname[0], flen);
    if (fj < 0) { return 0; }
    let pix: i32 = 0;
    if (glue_struct_lit_field_init_param_index(callee_arena, callee_mod, inner_fi, lit_ref, fj, &pix) != 0) {
      return 0;
    }
    let arg: i32 = pipeline_expr_call_arg_ref(arena, inner_call_ref, pix);
    out_arg_ref[0] = arg;
    if (arg > 0) { return 1; }
  }
  return 0;
}

// glue_dep_module_field_offset_by_name: see function docblock below.
/** Exported function `glue_dep_module_field_offset_by_name`.
 * Implements `glue_dep_module_field_offset_by_name`.
 * @param pctx *u8
 * @param field_name *u8
 * @param flen i32
 * @return i32
 */
#[no_mangle]
export function glue_dep_module_field_offset_by_name(pctx: *u8, field_name: *u8, flen: i32): i32 {
  if (pctx == 0) { return 0 - 1; }
  if (field_name == 0) { return 0 - 1; }
  if (flen <= 0) { return 0 - 1; }
  unsafe {
    let nd: i32 = pipeline_dep_ctx_ndep(pctx);
    let di: i32 = 0;
    while (di < nd) {
      let dm: *u8 = pipeline_dep_ctx_module_at(pctx, di);
      if (dm != 0) {
        let nlay: i32 = pipeline_module_num_struct_layouts_at(dm);
        let k: i32 = 0;
        while (k < nlay) {
          let nf: i32 = pipeline_module_struct_layout_num_fields(dm, k);
          let j: i32 = 0;
          while (j < nf) {
            let fnlen: i32 = pipeline_module_struct_layout_field_name_len(dm, k, j);
            if (fnlen == flen) {
              if (fnlen > 0) {
                if (fnlen <= 63) {
                  let fb: u8[64] = [];
                  pipeline_module_struct_layout_field_name_into(dm, k, j, &fb[0]);
                  let fi: i32 = 0;
                  let feq: i32 = 1;
                  while (fi < fnlen) {
                    if (fb[fi] != field_name[fi]) {
                      feq = 0;
                      break;
                    }
                    fi = fi + 1;
                  }
                  if (feq != 0) {
                    return pipeline_module_struct_layout_field_offset_at(dm, k, j);
                  }
                }
              }
            }
            j = j + 1;
          }
          k = k + 1;
        }
      }
      di = di + 1;
    }
  }
  return 0 - 1;
}

// glue_inline_var_field_access_offset: see function docblock below.
/** Exported function `glue_inline_var_field_access_offset`.
 * Implements `glue_inline_var_field_access_offset`.
 * @param arena *u8
 * @param mod *u8
 * @param pctx *u8
 * @param asm_ctx *u8
 * @param fa_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_inline_var_field_access_offset(arena: *u8, mod: *u8, pctx: *u8, asm_ctx: *u8, fa_ref: i32): i32 {
  if (arena == 0) { return 0 - 1; }
  if (mod == 0) { return 0 - 1; }
  if (fa_ref <= 0) { return 0 - 1; }
  unsafe {
    let base_ref: i32 = pipeline_expr_field_access_base_ref(arena, fa_ref);
    if (base_ref <= 0) { return 0 - 1; }
    // VAR=3
    if (pipeline_expr_kind_ord_at(arena, base_ref) != 3) { return 0 - 1; }
    let base_ty: i32 = pipeline_expr_resolved_type_ref(arena, base_ref);
    let scope_br: i32 = 0;
    if (asm_ctx != 0) {
      scope_br = asm_ctx_scope_block_ref_at(asm_ctx);
    }
    if (base_ty <= 0) {
      if (scope_br > 0) {
        let vlen: i32 = pipeline_expr_var_name_len(arena, base_ref);
        if (vlen > 0) {
          if (vlen <= 63) {
            let vname: u8[64] = [];
            pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
            base_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen);
          }
        }
      }
    }
    if (base_ty <= 0) {
      if (asm_ctx != 0) {
        let fi: i32 = pipeline_asm_emit_func_index_c();
        let vlen: i32 = pipeline_expr_var_name_len(arena, base_ref);
        if (fi >= 0) {
          if (fi < pipeline_module_num_funcs(mod)) {
            if (vlen > 0) {
              if (vlen <= 63) {
                let vname: u8[64] = [];
                pipeline_expr_var_name_into(arena, base_ref, &vname[0]);
                let body_ref: i32 = pipeline_module_func_body_ref_at(mod, fi);
                if (body_ref > 0) {
                  base_ty = pipeline_block_resolve_var_type_ref(arena, body_ref, &vname[0], vlen);
                }
              }
            }
          }
        }
      }
    }
    let flen: i32 = pipeline_expr_field_access_name_len(arena, fa_ref);
    if (flen <= 0) { return 0 - 1; }
    if (flen > 63) { return 0 - 1; }
    let field_name: u8[64] = [];
    pipeline_expr_field_access_name_into(arena, fa_ref, &field_name[0]);
    if (pctx != 0) {
      let off: i32 = glue_dep_module_field_offset_by_name(pctx, &field_name[0], flen);
      if (off >= 0) { return off; }
    }
    if (base_ty <= 0) { return 0 - 1; }
    let kind: i32 = pipeline_type_kind_ord_at(arena, base_ty);
    // TYPE_PTR=9
    if (kind == 9) {
      base_ty = pipeline_type_elem_ref_at(arena, base_ty);
      if (base_ty <= 0) { return 0 - 1; }
      kind = pipeline_type_kind_ord_at(arena, base_ty);
    }
    // TYPE_NAMED=8
    if (kind != 8) { return 0 - 1; }
    let struct_name: u8[64] = [];
    let nlen: i32 = pipeline_type_named_name_into(arena, base_ty, &struct_name[0]);
    if (pctx != 0) {
      let off2: i32 = typeck_get_field_offset_from_layout_deps(mod, pctx, &struct_name[0], nlen, &field_name[0], flen);
      if (off2 >= 0) { return off2; }
    }
    return pipeline_expr_field_access_layout_offset(arena, mod, fa_ref);
  }
  return 0 - 1;
}

// glue_try_array_lit_lane_const_i32: see function docblock below.
/** Exported function `glue_try_array_lit_lane_const_i32`.
 * Implements `glue_try_array_lit_lane_const_i32`.
 * @param arena *u8
 * @param arr_ref i32
 * @param lane i32
 * @param out *i32
 * @return i32
 */
#[no_mangle]
export function glue_try_array_lit_lane_const_i32(arena: *u8, arr_ref: i32, lane: i32, out: *i32): i32 {
  if (arena == 0) { return 0; }
  if (arr_ref <= 0) { return 0; }
  if (out == 0) { return 0; }
  if (lane < 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, arr_ref) != 46) { return 0; }
    if (lane >= pipeline_expr_array_lit_num_elems_at(arena, arr_ref)) { return 0; }
    let elem_ref: i32 = pipeline_expr_array_lit_elem_ref(arena, arr_ref, lane);
    return glue_try_expr_const_i32(arena, elem_ref, out);
  }
  return 0;
}

// glue_fold_func_returns_param01_vector_binop: see function docblock below.
/** Exported function `glue_fold_func_returns_param01_vector_binop`.
 * Implements `glue_fold_func_returns_param01_vector_binop`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param out_binop_ko *i32
 * @return i32
 */
#[no_mangle]
export function glue_fold_func_returns_param01_vector_binop(arena: *u8, mod: *u8, func_idx: i32, out_binop_ko: *i32): i32 {
  if (out_binop_ko == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  unsafe {
    if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 2) { return 0; }
    let ret_ty: i32 = pipeline_module_func_return_type_at(mod, func_idx);
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    if (ret_ref <= 0) { return 0; }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, ret_ref);
    if (glue_is_vector_lane_scalar_binop_ko(ko) == 0) { return 0; }
    // See implementation.
    if (ret_ty > 0) {
      if (asm_type_is_simd_vector_spelling(arena, ret_ty) == 0) {
        if (asm_type_is_simd_vector(arena, ret_ty) == 0) {
          if (ko != 51) { return 0; }
        }
      }
    }
    if (ko == 51) { ko = 4; }
    let al: i32 = pipeline_expr_binop_left_ref_at(arena, ret_ref);
    let ar: i32 = pipeline_expr_binop_right_ref_at(arena, ret_ref);
    if (glue_expr_is_func_param_at(arena, mod, func_idx, al, 0) == 0) { return 0; }
    if (glue_expr_is_func_param_at(arena, mod, func_idx, ar, 1) == 0) { return 0; }
    out_binop_ko[0] = ko;
    return 1;
  }
  return 0;
}

// glue_fold_func_returns_param0_index_const: see function docblock below.
/** Exported function `glue_fold_func_returns_param0_index_const`.
 * Implements `glue_fold_func_returns_param0_index_const`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param out_lane *i32
 * @return i32
 */
#[no_mangle]
export function glue_fold_func_returns_param0_index_const(arena: *u8, mod: *u8, func_idx: i32, out_lane: *i32): i32 {
  if (out_lane == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  if (func_idx < 0) { return 0; }
  unsafe {
    if (pipeline_asm_module_func_num_params_at(mod, func_idx) != 1) { return 0; }
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(arena, mod, func_idx);
    if (ret_ref <= 0) { return 0; }
    // GLUE_EXPR_INDEX = 47
    if (pipeline_expr_kind_ord_at(arena, ret_ref) != 47) { return 0; }
    let base_ref: i32 = pipeline_expr_index_base_ref(arena, ret_ref);
    let idx_ref: i32 = pipeline_expr_index_index_ref(arena, ret_ref);
    if (glue_expr_is_func_param_at(arena, mod, func_idx, base_ref, 0) == 0) { return 0; }
    let lane: i32 = 0;
    if (glue_try_expr_const_i32(arena, idx_ref, &lane) == 0) { return 0; }
    out_lane[0] = lane;
    return 1;
  }
  return 0;
}

// See implementation.


/* ---- G-02f-111 / G-02f-131：try_inline alloc/const-lit ---- */

// glue_call_is_zero_arg_default_alloc: see function docblock below.
/** Exported function `glue_call_is_zero_arg_default_alloc`.
 * Memory management helper `glue_call_is_zero_arg_default_alloc`.
 * @param arena *u8
 * @param call_ref i32
 * @return i32
 */
#[no_mangle]
export function glue_call_is_zero_arg_default_alloc(arena: *u8, call_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (call_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, call_ref) != 48) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 0) { return 0; }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, call_ref);
    if (callee_ref <= 0) { return 0; }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, callee_ref);
    let nm: u8[64] = [];
    if (ko == 3) {
      let nlen: i32 = pipeline_expr_var_name_len(arena, callee_ref);
      if (nlen != 13) { return 0; }
      pipeline_expr_var_name_into(arena, callee_ref, &nm[0]);
      // "default_alloc"
      if (nm[0]==100 && nm[1]==101 && nm[2]==102 && nm[3]==97 && nm[4]==117 && nm[5]==108
          && nm[6]==116 && nm[7]==95 && nm[8]==97 && nm[9]==108 && nm[10]==108 && nm[11]==111
          && nm[12]==99) {
        return 1;
      }
      return 0;
    }
    if (ko == 44) {
      let nlen: i32 = pipeline_expr_field_access_name_len(arena, callee_ref);
      if (nlen != 13) { return 0; }
      pipeline_expr_field_access_name_into(arena, callee_ref, &nm[0]);
      if (nm[0]==100 && nm[1]==101 && nm[2]==102 && nm[3]==97 && nm[4]==117 && nm[5]==108
          && nm[6]==116 && nm[7]==95 && nm[8]==97 && nm[9]==108 && nm[10]==108 && nm[11]==111
          && nm[12]==99) {
        return 1;
      }
      return 0;
    }
  }
  return 0;
}

// glue_const_struct_lit_field_can_inline: see function docblock below.
/** Exported function `glue_const_struct_lit_field_can_inline`.
 * Implements `glue_const_struct_lit_field_can_inline`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param lit_ref i32
 * @param fj i32
 * @return i32
 */
#[no_mangle]
export function glue_const_struct_lit_field_can_inline(arena: *u8, mod: *u8, func_idx: i32, lit_ref: i32, fj: i32): i32 {
  if (arena == 0) { return 0; }
  unsafe {
    let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fj);
    if (init_ref <= 0) { return 0; }
    let pix: i32 = 0;
    if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, lit_ref, fj, &pix) == 0) {
      return 0;
    }
    let ko: i32 = pipeline_expr_kind_ord_at(arena, init_ref);
    if (ko == 48) {
      return glue_call_is_zero_arg_default_alloc(arena, init_ref);
    }
    if (ko == 0) { return 1; }
    if (ko == 1) { return 1; }
    if (ko == 2) { return 1; }
  }
  return 0;
}
// See implementation.
// glue_emit_default_alloc_to_rbx_offset: see function docblock below.
/** Exported function `glue_emit_default_alloc_to_rbx_offset`.
 * Memory management helper `glue_emit_default_alloc_to_rbx_offset`.
 * @param elf_ctx *u8
 * @param foff i32
 * @param fsz i32
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function glue_emit_default_alloc_to_rbx_offset(elf_ctx: *u8, foff: i32, fsz: i32, ta: i32): i32 {
  if (elf_ctx == 0) { return 0 - 1; }
  unsafe {
    if (glue_with_arena_scope_active_c() != 0) {
      let wa_off: i32 = glue_with_arena_scope_top_off_c();
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, 1, 0, ta) != 0) { return 0 - 1; }
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, 8, ta) != 0) { return 0 - 1; }
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0) { return 0 - 1; }
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + 8, 8, ta) != 0) { return 0 - 1; }
      return 0;
    }
    // "std_heap_default_alloc"
    let da: u8[32] = [];
    da[0] = 115; da[1] = 116; da[2] = 100; da[3] = 95;
    da[4] = 104; da[5] = 101; da[6] = 97; da[7] = 112;
    da[8] = 95; da[9] = 100; da[10] = 101; da[11] = 102;
    da[12] = 97; da[13] = 117; da[14] = 108; da[15] = 116;
    da[16] = 95; da[17] = 97; da[18] = 108; da[19] = 108;
    da[20] = 111; da[21] = 99;
    if (backend_enc_call_arch(elf_ctx, &da[0], 27, ta) != 0) { return 0 - 1; }
    let sz: i32 = fsz;
    if (sz <= 0) { sz = 8; }
    if (sz > 16) { sz = 16; }
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, sz, ta) != 0) { return 0 - 1; }
    if (sz >= 16) { return 0; }
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
    return backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + 8, 8, ta);
  }
  return 0 - 1;
}

// glue_fold_func_returns_const_struct_lit: see function docblock below.
/** Exported function `glue_fold_func_returns_const_struct_lit`.
 * Implements `glue_fold_func_returns_const_struct_lit`.
 * @param arena *u8
 * @param mod *u8
 * @param func_idx i32
 * @param out_lit_ref *i32
 * @return i32
 */
#[no_mangle]
export function glue_fold_func_returns_const_struct_lit(arena: *u8, mod: *u8, func_idx: i32, out_lit_ref: *i32): i32 {
  if (out_lit_ref == 0) { return 0; }
  if (arena == 0) { return 0; }
  if (mod == 0) { return 0; }
  unsafe {
    let ret_ref: i32 = glue_fold_func_return_operand_ref_module(arena, mod, func_idx);
    if (ret_ref <= 0) {
      ret_ref = backend_fold_func_return_operand_ref(arena, mod, func_idx);
    }
    if (ret_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, ret_ref) != 45) { return 0; }
    let nf: i32 = pipeline_expr_struct_lit_num_fields(arena, ret_ref);
    if (nf <= 0) { return 0; }
    if (nf > 8) { return 0; }
    let fj: i32 = 0;
    while (fj < nf) {
      let init_ref: i32 = pipeline_expr_struct_lit_init_ref(arena, ret_ref, fj);
      if (init_ref <= 0) { return 0; }
      let pix: i32 = 0;
      // See implementation.
      if (glue_struct_lit_field_init_param_index(arena, mod, func_idx, ret_ref, fj, &pix) == 0) {
        return 0;
      }
      let ko: i32 = pipeline_expr_kind_ord_at(arena, init_ref);
      // See implementation.
      if (ko == 48) {
        if (glue_call_is_zero_arg_default_alloc(arena, init_ref) == 0) { return 0; }
      } else {
        if (ko != 0) {
          if (ko != 1) {
            if (ko != 2) { return 0; }
          }
        }
      }
      fj = fj + 1;
    }
    out_lit_ref[0] = ret_ref;
    return 1;
  }
  return 0;
}

// glue_align_up8_c: see function docblock below.

/** Exported function `glue_align_up8_c`.
 * Implements `glue_align_up8_c`.
 * @param n i32
 * @return i32
 */
#[no_mangle]
export function glue_align_up8_c(n: i32): i32 {
  let m: i32 = n % 8;
  if (m != 0) {
    n = n + (8 - m);
  }
  return n;
}

/** Exported function `glue_is_vector_lane_scalar_binop_ko`.
 * Implements `glue_is_vector_lane_scalar_binop_ko`.
 * @param ko i32
 * @return i32
 */
#[no_mangle]
export function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32 {
  if (ko == 51) {
    ko = 4;
  }
  if (ko < 4) {
    return 0;
  }
  if (ko > 13) {
    return 0;
  }
  return 1;
}

// glue_try_expr_const_i32: see function docblock below.


/** Exported function `glue_try_expr_const_i32`.
 * Implements `glue_try_expr_const_i32`.
 * @param arena *u8
 * @param er i32
 * @param out *i32
 * @return i32
 */
#[no_mangle]
export function glue_try_expr_const_i32(arena: *u8, er: i32, out: *i32): i32 {
  if (arena == 0) { return 0; }
  if (er <= 0) { return 0; }
  if (out == 0) { return 0; }
  unsafe {
    let ko: i32 = pipeline_expr_kind_ord_at(arena, er);
    // EXPR_INT / related lit kinds 0 or 2 in pipeline ord
    if (ko == 0) {
      out[0] = pipeline_expr_int_val_at(arena, er);
      return 1;
    }
    if (ko == 2) {
      out[0] = pipeline_expr_int_val_at(arena, er);
      return 1;
    }
  }
  return 0;
}

// glue_try_inline_local_slot_off: see function docblock below.


/** Exported function `glue_try_inline_local_slot_off`.
 * Implements `glue_try_inline_local_slot_off`.
 * @param ctx *u8
 * @param arena *u8
 * @param name *u8
 * @param nlen i32
 * @return i32
 */
#[no_mangle]
export function glue_try_inline_local_slot_off(ctx: *u8, arena: *u8, name: *u8, nlen: i32): i32 {
  unsafe {
    let off: i32 = asm_ctx_local_find_offset_scoped(ctx, arena, name, nlen);
    if (off < 0) {
      off = asm_ctx_local_find_offset(ctx, name, nlen);
    }
    return off;
  }
  return 0 - 1;
}

// See implementation.

// try_inline_x_plus_k_call_elf: see function docblock below.
/** Exported function `try_inline_x_plus_k_call_elf`.
 * Implements `try_inline_x_plus_k_call_elf`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param expr_ref i32
 * @param ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function try_inline_x_plus_k_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let mod_ref: *u8 = g02f_load_ptr_at(ctx, 16);
    if (mod_ref == 0) { return 0; }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, callee_ref) != 3) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1) { return 0; }
    let clen: i32 = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen <= 0) { return 0; }
    if (clen > 63) { return 0; }
    let cname: u8[64] = [];
    pipeline_expr_var_name_into(arena, callee_ref, &cname[0]);
    /* See implementation. */
    let fi: i32 = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    if (fi < 0) {
      fi = glue_module_func_index_by_name(mod_ref, &cname[0], clen);
    }
    if (fi < 0) { return 0; }
    let k: i32 = backend_fold_func_x_plus_k_chain(arena, mod_ref, fi, 0);
    if (k < 0) { return 0; }
    // See implementation.
    if (k == 0) {
      let ret_ref: i32 = glue_fold_func_return_operand_ref_module(arena, mod_ref, fi);
      if (ret_ref <= 0) {
        ret_ref = backend_fold_func_return_operand_ref(arena, mod_ref, fi);
      }
      if (ret_ref <= 0) { return 0; }
      if (pipeline_expr_kind_ord_at(arena, ret_ref) != 3) { return 0; }
      let plen: i32 = pipeline_asm_module_func_param_name_len_at(mod_ref, fi, 0);
      let rlen: i32 = pipeline_expr_var_name_len(arena, ret_ref);
      if (plen <= 0) { return 0; }
      if (plen > 63) { return 0; }
      if (rlen != plen) { return 0; }
      let pname: u8[64] = [];
      let rname: u8[64] = [];
      pipeline_asm_module_func_param_name_copy32(mod_ref, fi, 0, &pname[0]);
      pipeline_expr_var_name_into(arena, ret_ref, &rname[0]);
      let pi: i32 = 0;
      while (pi < plen) {
        if (pname[pi] != rname[pi]) { return 0; }
        pi = pi + 1;
      }
    }
    let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if (arg_ref <= 0) { return 0 - 1; }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) != 0) { return 0 - 1; }
    if (k != 0) {
      if (backend_enc_add_imm_to_rax_arch(elf_ctx, k, ta) != 0) { return 0 - 1; }
    }
    return 1;
  }
  return 0;
}

// try_inline_param0_single_field_call_elf: see function docblock below.
/** Exported function `try_inline_param0_single_field_call_elf`.
 * Implements `try_inline_param0_single_field_call_elf`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param expr_ref i32
 * @param ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function try_inline_param0_single_field_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1) { return 0; }
    let ca_slot: u8[8] = [];
    let cm_slot: u8[8] = [];
    let fi: i32 = 0;
    if (glue_call_lookup_callee_mod_fi_arena(arena, expr_ref, ctx, &ca_slot[0], &cm_slot[0], &fi) == 0) {
      return 0;
    }
    let callee_arena: *u8 = g02f_load_ptr_at(&ca_slot[0], 0);
    let callee_mod: *u8 = g02f_load_ptr_at(&cm_slot[0], 0);
    if (callee_arena == 0) { return 0; }
    if (callee_mod == 0) { return 0; }
    if (backend_fold_func_returns_param0_single_field(callee_arena, callee_mod, fi) == 0) { return 0; }
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(callee_arena, callee_mod, fi);
    if (ret_ref <= 0) { return 0; }
    let off: i32 = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, ret_ref);
    let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if (arg_ref <= 0) { return 0 - 1; }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) == 48) {
      let inner_arg: i32 = 0;
      if (glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, ret_ref, &inner_arg) == 0) {
        return 0;
      }
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, inner_arg, ctx, ta) != 0) { return 0 - 1; }
      return 1;
    }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) != 3) { return 0; }
    let vlen: i32 = pipeline_expr_var_name_len(arena, arg_ref);
    if (vlen <= 0) { return 0; }
    let vname: u8[64] = [];
    pipeline_expr_var_name_into(arena, arg_ref, &vname[0]);
    let slot_off: i32 = glue_try_inline_local_slot_off(ctx, arena, &vname[0], vlen);
    if (slot_off < 0) { return 0; }
    if (glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, ctx) != 0) {
      return 0 - 1;
    }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) != 0) { return 0 - 1; }
    if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

// try_inline_param0_field_sum_call_elf: see function docblock below.
/** Exported function `try_inline_param0_field_sum_call_elf`.
 * Implements `try_inline_param0_field_sum_call_elf`.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param expr_ref i32
 * @param ctx *u8
 * @param ta i32
 * @return i32
 */
#[no_mangle]
export function try_inline_param0_field_sum_call_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1) { return 0; }
    let ca_slot: u8[8] = [];
    let cm_slot: u8[8] = [];
    let fi: i32 = 0;
    if (glue_call_lookup_callee_mod_fi_arena(arena, expr_ref, ctx, &ca_slot[0], &cm_slot[0], &fi) == 0) {
      return 0;
    }
    let callee_arena: *u8 = g02f_load_ptr_at(&ca_slot[0], 0);
    let callee_mod: *u8 = g02f_load_ptr_at(&cm_slot[0], 0);
    if (callee_arena == 0) { return 0; }
    if (callee_mod == 0) { return 0; }
    if (backend_fold_func_returns_param0_field_sum(callee_arena, callee_mod, fi) == 0) { return 0; }
    let ret_ref: i32 = glue_try_fold_func_return_operand_ref(callee_arena, callee_mod, fi);
    if (ret_ref <= 0) { return 0; }
    let al: i32 = pipeline_expr_binop_left_ref_at(callee_arena, ret_ref);
    let ar: i32 = pipeline_expr_binop_right_ref_at(callee_arena, ret_ref);
    let off_a: i32 = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, al);
    let off_b: i32 = pipeline_expr_field_access_layout_offset(callee_arena, callee_mod, ar);
    let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if (arg_ref <= 0) { return 0 - 1; }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) == 48) {
      let inner_arg_a: i32 = 0;
      let inner_arg_b: i32 = 0;
      if (glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, al, &inner_arg_a) == 0) { return 0; }
      if (glue_inner_call_arg_for_field_access(arena, ctx, arg_ref, ar, &inner_arg_b) == 0) { return 0; }
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, inner_arg_a, ctx, ta) != 0) { return 0 - 1; }
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, inner_arg_b, ctx, ta) != 0) { return 0 - 1; }
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
      if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
      return 1;
    }
    if (pipeline_expr_kind_ord_at(arena, arg_ref) != 3) { return 0; }
    let vlen: i32 = pipeline_expr_var_name_len(arena, arg_ref);
    if (vlen <= 0) { return 0; }
    let vname: u8[64] = [];
    pipeline_expr_var_name_into(arena, arg_ref, &vname[0]);
    let slot_off: i32 = glue_try_inline_local_slot_off(ctx, arena, &vname[0], vlen);
    if (slot_off < 0) { return 0; }
    if (glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, arg_ref, slot_off, ta, ctx) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_a, ta) != 0) { return 0 - 1; }
    if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_b, ta) != 0) { return 0 - 1; }
    if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

// See implementation.
/** Function `try_inline_var_field_sum_binop_elf`.
 * Purpose: implements `try_inline_var_field_sum_binop_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function try_inline_var_field_sum_binop_elf(
  arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32
): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (left_ref <= 0) { return 0; }
  if (right_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, left_ref) != 44) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, right_ref) != 44) { return 0; }
    let base_l: i32 = pipeline_expr_field_access_base_ref(arena, left_ref);
    let base_r: i32 = pipeline_expr_field_access_base_ref(arena, right_ref);
    if (base_l <= 0) { return 0; }
    if (base_r != base_l) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, base_l) != 3) { return 0; }
    let pctx: *u8 = g02f_load_ptr_at(ctx, 1256);
    if (pctx == 0) {
      pctx = pipeline_asm_emit_dep_pipe_c();
    }
    if (pctx == 0) { return 0; }
    let off_a: i32 = 0 - 1;
    let off_b: i32 = 0 - 1;
    let nd: i32 = pipeline_dep_ctx_ndep(pctx);
    let di: i32 = 0;
    while (di < nd) {
      if (off_a >= 0) {
        if (off_b >= 0) { break; }
      }
      let dm: *u8 = pipeline_dep_ctx_module_at(pctx, di);
      if (dm != 0) {
        if (off_a < 0) {
          off_a = pipeline_expr_field_access_layout_offset(arena, dm, left_ref);
        }
        if (off_b < 0) {
          off_b = pipeline_expr_field_access_layout_offset(arena, dm, right_ref);
        }
      }
      di = di + 1;
    }
    if (off_a < 0) {
      let flen_a: i32 = pipeline_expr_field_access_name_len(arena, left_ref);
      if (flen_a > 0) {
        if (flen_a <= 63) {
          let fname_a: u8[64] = [];
          pipeline_expr_field_access_name_into(arena, left_ref, &fname_a[0]);
          off_a = glue_dep_module_field_offset_by_name(pctx, &fname_a[0], flen_a);
        }
      }
    }
    if (off_b < 0) {
      let flen_b: i32 = pipeline_expr_field_access_name_len(arena, right_ref);
      if (flen_b > 0) {
        if (flen_b <= 63) {
          let fname_b: u8[64] = [];
          pipeline_expr_field_access_name_into(arena, right_ref, &fname_b[0]);
          off_b = glue_dep_module_field_offset_by_name(pctx, &fname_b[0], flen_b);
        }
      }
    }
    if (off_a < 0) { return 0; }
    if (off_b < 0) { return 0; }
    let vlen: i32 = pipeline_expr_var_name_len(arena, base_l);
    if (vlen <= 0) { return 0; }
    let vname: u8[64] = [];
    pipeline_expr_var_name_into(arena, base_l, &vname[0]);
    let slot_off: i32 = glue_try_inline_local_slot_off(ctx, arena, &vname[0], vlen);
    if (slot_off < 0) { return 0; }
    if (glue_enc_local_slot_ptr_or_addr(arena, elf_ctx, base_l, slot_off, ta, ctx) != 0) {
      return 0 - 1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_a, ta) != 0) { return 0 - 1; }
    if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, off_b, ta) != 0) { return 0 - 1; }
    if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    if (backend_enc_add_rax_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

// See implementation.
// See implementation.

// See implementation.
/** Function `try_inline_wpo_const_scalar_binop_call_elf`.
 * Purpose: implements `try_inline_wpo_const_scalar_binop_call_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function try_inline_wpo_const_scalar_binop_call_elf(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 48) { return 0; }
    let mod_ref: *u8 = g02f_load_ptr_at(ctx, 16);
    if (mod_ref == 0) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 2) { return 0; }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, callee_ref) != 3) { return 0; }
    let clen: i32 = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen <= 0) { return 0; }
    if (clen > 63) { return 0; }
    let cname: u8[64] = [];
    pipeline_expr_var_name_into(arena, callee_ref, &cname[0]);
    let fi: i32 = glue_module_func_index_by_name(mod_ref, &cname[0], clen);
    if (fi < 0) { return 0; }
    let binop_ko: i32 = 0;
    if (glue_fold_func_returns_param01_scalar_binop(arena, mod_ref, fi, &binop_ko) == 0) { return 0; }
    let arg0: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    let arg1: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 1);
    if (arg0 <= 0) { return 0; }
    if (arg1 <= 0) { return 0; }
    let av0: i32 = 0;
    let av1: i32 = 0;
    if (glue_try_expr_const_i32(arena, arg0, &av0) == 0) { return 0; }
    if (glue_try_expr_const_i32(arena, arg1, &av1) == 0) { return 0; }
    let folded: i32 = 0;
    if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0) { return 0; }
    let hi: i32 = 0;
    if (folded < 0) { hi = 0 - 1; }
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, folded, hi, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

// See implementation.
/** Function `try_inline_wpo_const_vector_lane_of_binop_call_elf`.
 * Purpose: implements `try_inline_wpo_const_vector_lane_of_binop_call_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function try_inline_wpo_const_vector_lane_of_binop_call_elf(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 48) { return 0; }
    let mod_ref: *u8 = g02f_load_ptr_at(ctx, 16);
    if (mod_ref == 0) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1) { return 0; }
    let outer_callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (outer_callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, outer_callee_ref) != 3) { return 0; }
    let olen: i32 = pipeline_expr_var_name_len(arena, outer_callee_ref);
    if (olen <= 0) { return 0; }
    if (olen > 63) { return 0; }
    let outer_name: u8[64] = [];
    pipeline_expr_var_name_into(arena, outer_callee_ref, &outer_name[0]);
    let outer_fi: i32 = glue_module_func_index_by_name(mod_ref, &outer_name[0], olen);
    if (outer_fi < 0) { return 0; }
    let lane: i32 = 0;
    if (glue_fold_func_returns_param0_index_const(arena, mod_ref, outer_fi, &lane) == 0) { return 0; }
    let inner_call_ref: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if (inner_call_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, inner_call_ref) != 48) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, inner_call_ref) != 2) { return 0; }
    let inner_callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, inner_call_ref);
    if (inner_callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, inner_callee_ref) != 3) { return 0; }
    let ilen: i32 = pipeline_expr_var_name_len(arena, inner_callee_ref);
    if (ilen <= 0) { return 0; }
    if (ilen > 63) { return 0; }
    let inner_name: u8[64] = [];
    pipeline_expr_var_name_into(arena, inner_callee_ref, &inner_name[0]);
    let inner_fi: i32 = glue_module_func_index_by_name(mod_ref, &inner_name[0], ilen);
    if (inner_fi < 0) { return 0; }
    let binop_ko: i32 = 0;
    if (glue_fold_func_returns_param01_vector_binop(arena, mod_ref, inner_fi, &binop_ko) == 0) { return 0; }
    let arg0: i32 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 0);
    let arg1: i32 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 1);
    if (arg0 <= 0) { return 0; }
    if (arg1 <= 0) { return 0; }
    let av0: i32 = 0;
    let av1: i32 = 0;
    if (glue_try_array_lit_lane_const_i32(arena, arg0, lane, &av0) == 0) { return 0; }
    if (glue_try_array_lit_lane_const_i32(arena, arg1, lane, &av1) == 0) { return 0; }
    let folded: i32 = 0;
    if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0) { return 0; }
    let hi: i32 = 0;
    if (folded < 0) { hi = 0 - 1; }
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, folded, hi, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

/**
 * Try WPO mono symbol emit for a 2-arg call when XLANG_WPO_MONO is set.
 * wave232 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * @param arena *u8 — AST arena; null → return 0
 * @param elf_ctx *u8 — ELF/codegen context; null → return 0
 * @param expr_ref i32 — call expr ref; must be > 0
 * @param ctx *u8 — AsmFuncCtx; null → return 0
 * @param ta i32 — target arch token
 * @return i32 — 1 if mono path handled, 0 if skipped, -1 on encode failure
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function try_call_wpo_mono_symbol_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let kmono: u8[16] = [];
    kmono[0] = 83; kmono[1] = 72; kmono[2] = 85; kmono[3] = 88; kmono[4] = 95;
    kmono[5] = 87; kmono[6] = 80; kmono[7] = 79; kmono[8] = 95;
    kmono[9] = 77; kmono[10] = 79; kmono[11] = 78; kmono[12] = 79; kmono[13] = 0;
    // wave232 G.7: XLANG_WPO_MONO via link_abi_getenv (not raw getenv).
    if (link_abi_getenv(&kmono[0]) == 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 48) { return 0; }
    let mod_ref: *u8 = g02f_load_ptr_at(ctx, 16);
    if (mod_ref == 0) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 2) { return 0; }
    let callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, callee_ref) != 3) { return 0; }
    let clen: i32 = pipeline_expr_var_name_len(arena, callee_ref);
    if (clen <= 0) { return 0; }
    if (clen > 63) { return 0; }
    let cname: u8[64] = [];
    pipeline_expr_var_name_into(arena, callee_ref, &cname[0]);
    cname[clen] = 0;
    let fi: i32 = glue_module_func_index_by_name(mod_ref, &cname[0], clen);
    if (fi < 0) { return 0; }
    let binop_ko: i32 = 0;
    if (glue_fold_func_returns_param01_scalar_binop(arena, mod_ref, fi, &binop_ko) == 0) { return 0; }
    let arg0: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    let arg1: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 1);
    if (arg0 <= 0) { return 0; }
    if (arg1 <= 0) { return 0; }
    let av0: i32 = 0;
    let av1: i32 = 0;
    if (glue_try_expr_const_i32(arena, arg0, &av0) == 0) { return 0; }
    if (glue_try_expr_const_i32(arena, arg1, &av1) == 0) { return 0; }
    let folded: i32 = 0;
    if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0) { return 0; }
    glue_wpo_mono_register_thunk(&cname[0], av0, av1, folded);
    let args: i32[2] = [];
    args[0] = av0;
    args[1] = av1;
    let sym: u8[128] = [];
    let sym_len: i32 = codegen_wpo_mono_sym_format(&cname[0], 2, &args[0], &sym[0], 128);
    if (sym_len <= 0) { return 0 - 1; }
    if (backend_enc_call_arch(elf_ctx, &sym[0], sym_len, ta) != 0) { return 0 - 1; }
    if (backend_enc_call_stack_cleanup_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

// See implementation.
/** Function `try_inline_const_struct_lit_return_call_to_slot_elf`.
 * Purpose: implements `try_inline_const_struct_lit_return_call_to_slot_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function try_inline_const_struct_lit_return_call_to_slot_elf(
  arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (call_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, call_ref) != 48) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, call_ref) != 0) { return 0; }
    let ca_slot: u8[8] = [];
    let cm_slot: u8[8] = [];
    let fi: i32 = 0;
    if (glue_call_lookup_callee_mod_fi_arena(arena, call_ref, ctx, &ca_slot[0], &cm_slot[0], &fi) == 0) {
      return 0;
    }
    let callee_arena: *u8 = g02f_load_ptr_at(&ca_slot[0], 0);
    let callee_mod: *u8 = g02f_load_ptr_at(&cm_slot[0], 0);
    if (callee_arena == 0) { return 0; }
    if (callee_mod == 0) { return 0; }
    let lit_ref: i32 = 0;
    if (glue_fold_func_returns_const_struct_lit(callee_arena, callee_mod, fi, &lit_ref) == 0) { return 0; }
    let nf: i32 = pipeline_expr_struct_lit_num_fields(callee_arena, lit_ref);
    let fj: i32 = 0;
    while (fj < nf) {
      if (glue_const_struct_lit_field_can_inline(callee_arena, callee_mod, fi, lit_ref, fj) == 0) {
        return 0;
      }
      fj = fj + 1;
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) { return 0 - 1; }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    fj = 0;
    while (fj < nf) {
      let init_ref: i32 = pipeline_expr_struct_lit_init_ref(callee_arena, lit_ref, fj);
      let foff: i32 = pipeline_expr_struct_lit_field_offset_at(callee_arena, callee_mod, lit_ref, fj);
      let fsz: i32 = pipeline_expr_struct_lit_field_store_sz(callee_arena, callee_mod, lit_ref, fj);
      if (pipeline_expr_kind_ord_at(callee_arena, init_ref) == 48) {
        if (glue_call_is_zero_arg_default_alloc(callee_arena, init_ref) == 0) { return 0; }
        if (glue_emit_default_alloc_to_rbx_offset(elf_ctx, foff, fsz, ta) != 0) { return 0 - 1; }
      } else {
        if (pipeline_asm_emit_expr_elf_c(callee_arena, elf_ctx, init_ref, ctx, ta) != 0) { return 0 - 1; }
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0) { return 0 - 1; }
      }
      fj = fj + 1;
    }
    return 1;
  }
  return 0;
}

// See implementation.
/** Function `try_inline_struct_lit_return_call_to_slot_elf`.
 * Purpose: implements `try_inline_struct_lit_return_call_to_slot_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function try_inline_struct_lit_return_call_to_slot_elf(
  arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (call_ref <= 0) { return 0; }
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, call_ref) != 48) { return 0; }
    let ca_slot: u8[8] = [];
    let cm_slot: u8[8] = [];
    let fi: i32 = 0;
    if (glue_call_lookup_callee_mod_fi_arena(arena, call_ref, ctx, &ca_slot[0], &cm_slot[0], &fi) == 0) {
      return 0;
    }
    let callee_arena: *u8 = g02f_load_ptr_at(&ca_slot[0], 0);
    let callee_mod: *u8 = g02f_load_ptr_at(&cm_slot[0], 0);
    if (callee_arena == 0) { return 0; }
    if (callee_mod == 0) { return 0; }
    let lit_ref: i32 = 0;
    if (glue_fold_func_returns_param_struct_lit(callee_arena, callee_mod, fi, &lit_ref) == 0) { return 0; }
    let nf: i32 = pipeline_expr_struct_lit_num_fields(callee_arena, lit_ref);
    if (nf <= 0) { return 0; }
    if (nf > 8) { return 0; }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) { return 0 - 1; }
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) { return 0 - 1; }
    let fj: i32 = 0;
    while (fj < nf) {
      let pix: i32 = 0;
      if (glue_struct_lit_field_init_param_index(callee_arena, callee_mod, fi, lit_ref, fj, &pix) != 0) {
        return 0 - 1;
      }
      let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, call_ref, pix);
      if (arg_ref <= 0) { return 0 - 1; }
      let foff: i32 = pipeline_expr_struct_lit_field_offset_at(callee_arena, callee_mod, lit_ref, fj);
      let fsz: i32 = pipeline_expr_struct_lit_field_store_sz(callee_arena, callee_mod, lit_ref, fj);
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) != 0) { return 0 - 1; }
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff, fsz, ta) != 0) { return 0 - 1; }
      fj = fj + 1;
    }
    return 1;
  }
  return 0;
}

// See implementation.

/**
 * Try WPO mono vector-lane-of-binop call emit when XLANG_WPO_MONO is set.
 * wave232 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * @param arena *u8 — AST arena; null → return 0
 * @param elf_ctx *u8 — ELF/codegen context; null → return 0
 * @param expr_ref i32 — outer call expr ref; must be > 0
 * @param ctx *u8 — AsmFuncCtx; null → return 0
 * @param ta i32 — target arch token
 * @return i32 — 1 if mono path handled, 0 if skipped, -1 on encode failure
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function try_call_wpo_mono_vector_lane_of_binop_call_elf(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  if (arena == 0) { return 0; }
  if (elf_ctx == 0) { return 0; }
  if (ctx == 0) { return 0; }
  if (expr_ref <= 0) { return 0; }
  unsafe {
    let kmono: u8[16] = [];
    kmono[0] = 83; kmono[1] = 72; kmono[2] = 85; kmono[3] = 88; kmono[4] = 95;
    kmono[5] = 87; kmono[6] = 80; kmono[7] = 79; kmono[8] = 95;
    kmono[9] = 77; kmono[10] = 79; kmono[11] = 78; kmono[12] = 79; kmono[13] = 0;
    // wave232 G.7: XLANG_WPO_MONO via link_abi_getenv (not raw getenv).
    if (link_abi_getenv(&kmono[0]) == 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) != 48) { return 0; }
    let mod_ref: *u8 = g02f_load_ptr_at(ctx, 16);
    if (mod_ref == 0) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, expr_ref) != 1) { return 0; }
    let outer_callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    if (outer_callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, outer_callee_ref) != 3) { return 0; }
    let olen: i32 = pipeline_expr_var_name_len(arena, outer_callee_ref);
    if (olen <= 0) { return 0; }
    if (olen > 63) { return 0; }
    let outer_name: u8[64] = [];
    pipeline_expr_var_name_into(arena, outer_callee_ref, &outer_name[0]);
    outer_name[olen] = 0;
    let outer_fi: i32 = glue_module_func_index_by_name(mod_ref, &outer_name[0], olen);
    if (outer_fi < 0) { return 0; }
    let lane: i32 = 0;
    if (glue_fold_func_returns_param0_index_const(arena, mod_ref, outer_fi, &lane) == 0) { return 0; }
    let inner_call_ref: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, 0);
    if (inner_call_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, inner_call_ref) != 48) { return 0; }
    if (pipeline_expr_call_num_args_at(arena, inner_call_ref) != 2) { return 0; }
    let inner_callee_ref: i32 = pipeline_expr_call_callee_ref_at(arena, inner_call_ref);
    if (inner_callee_ref <= 0) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, inner_callee_ref) != 3) { return 0; }
    let ilen: i32 = pipeline_expr_var_name_len(arena, inner_callee_ref);
    if (ilen <= 0) { return 0; }
    if (ilen > 63) { return 0; }
    let inner_name: u8[64] = [];
    pipeline_expr_var_name_into(arena, inner_callee_ref, &inner_name[0]);
    let inner_fi: i32 = glue_module_func_index_by_name(mod_ref, &inner_name[0], ilen);
    if (inner_fi < 0) { return 0; }
    let binop_ko: i32 = 0;
    if (glue_fold_func_returns_param01_vector_binop(arena, mod_ref, inner_fi, &binop_ko) == 0) { return 0; }
    let arg0: i32 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 0);
    let arg1: i32 = pipeline_expr_call_arg_ref(arena, inner_call_ref, 1);
    if (arg0 <= 0) { return 0; }
    if (arg1 <= 0) { return 0; }
    // ARRAY_LIT=46
    if (pipeline_expr_kind_ord_at(arena, arg0) != 46) { return 0; }
    if (pipeline_expr_kind_ord_at(arena, arg1) != 46) { return 0; }
    let nargs: i32 = pipeline_expr_array_lit_num_elems_at(arena, arg0);
    if (nargs <= 0) { return 0; }
    if (nargs != pipeline_expr_array_lit_num_elems_at(arena, arg1)) { return 0; }
    // See implementation.
    if (nargs > 4) { return 0; }
    let mono_args: i32[8] = [];
    let li: i32 = 0;
    while (li < nargs) {
      let e0: i32 = 0;
      let e1: i32 = 0;
      if (glue_try_array_lit_lane_const_i32(arena, arg0, li, &e0) == 0) { return 0; }
      if (glue_try_array_lit_lane_const_i32(arena, arg1, li, &e1) == 0) { return 0; }
      mono_args[li] = e0;
      mono_args[nargs + li] = e1;
      li = li + 1;
    }
    let av0: i32 = 0;
    let av1: i32 = 0;
    if (glue_try_array_lit_lane_const_i32(arena, arg0, lane, &av0) == 0) { return 0; }
    if (glue_try_array_lit_lane_const_i32(arena, arg1, lane, &av1) == 0) { return 0; }
    let folded: i32 = 0;
    if (glue_const_scalar_binop_eval_i32(binop_ko, av0, av1, &folded) == 0) { return 0; }
    glue_wpo_mono_register_thunk_n(&outer_name[0], nargs * 2, &mono_args[0], folded);
    let sym: u8[128] = [];
    let sym_len: i32 = codegen_wpo_mono_sym_format(&outer_name[0], nargs * 2, &mono_args[0], &sym[0], 128);
    if (sym_len <= 0) { return 0 - 1; }
    if (backend_enc_call_arch(elf_ctx, &sym[0], sym_len, ta) != 0) { return 0 - 1; }
    if (backend_enc_call_stack_cleanup_arch(elf_ctx, 0, ta) != 0) { return 0 - 1; }
    return 1;
  }
  return 0;
}

// See implementation.
// See implementation.
// EXPR_ARRAY_LIT=46 STRUCT_LIT=45

/** Exported function `asm_array_lit_elem_byte_sz`.
 * Implements `asm_array_lit_elem_byte_sz`.
 * @param arena *u8
 * @param array_lit_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_array_lit_elem_byte_sz(arena: *u8, array_lit_ref: i32): i32 {
  if (arena == 0) { return 4; }
  if (array_lit_ref <= 0) { return 4; }
  let elem_ty: i32 = 0;
  unsafe { elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, array_lit_ref); }
  if (elem_ty <= 0) { return 4; }
  let kind_ord: i32 = 0;
  unsafe { kind_ord = pipeline_type_kind_ord_at(arena, elem_ty); }
  if (kind_ord == 2) { return 1; }
  if (kind_ord == 1) { return 1; }
  if (kind_ord == 0) { return 4; }
  if (kind_ord == 3) { return 4; }
  if (kind_ord == 13) { return 4; }
  return 8;
}

/** Exported function `pipeline_asm_array_lit_elem_byte_sz_c`.
 * Implements `pipeline_asm_array_lit_elem_byte_sz_c`.
 * @param arena *u8
 * @param array_lit_ref i32
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, array_lit_ref: i32): i32 {
  return asm_array_lit_elem_byte_sz(arena, array_lit_ref);
}

/** Exported function `asm_array_lit_reserve_stack_bytes`.
 * Implements `asm_array_lit_reserve_stack_bytes`.
 * @param arena *u8
 * @param init_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_array_lit_reserve_stack_bytes(arena: *u8, init_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (init_ref <= 0) { return 0; }
  let ko: i32 = 0;
  unsafe { ko = pipeline_expr_kind_ord_at(arena, init_ref); }
  if (ko != 46) { return 0; }
  let n: i32 = 0;
  unsafe { n = pipeline_expr_array_lit_num_elems_at(arena, init_ref); }
  if (n <= 0) { return 0; }
  let esz: i32 = asm_array_lit_elem_byte_sz(arena, init_ref);
  return glue_align_up8_c(n * esz);
}

/** Exported function `pipeline_asm_array_lit_reserve_stack_bytes_c`.
 * Implements `pipeline_asm_array_lit_reserve_stack_bytes_c`.
 * @param arena *u8
 * @param init_ref i32
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_array_lit_reserve_stack_bytes_c(arena: *u8, init_ref: i32): i32 {
  return asm_array_lit_reserve_stack_bytes(arena, init_ref);
}

/** Exported function `asm_struct_lit_reserve_stack_bytes`.
 * Implements `asm_struct_lit_reserve_stack_bytes`.
 * @param arena *u8
 * @param init_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_struct_lit_reserve_stack_bytes(arena: *u8, init_ref: i32): i32 {
  if (arena == 0) { return 0; }
  if (init_ref <= 0) { return 0; }
  let ko: i32 = 0;
  unsafe { ko = pipeline_expr_kind_ord_at(arena, init_ref); }
  if (ko != 45) { return 0; }
  let nf: i32 = 0;
  unsafe { nf = pipeline_expr_struct_lit_num_fields(arena, init_ref); }
  if (nf <= 0) { return 0; }
  return glue_align_up8_c(nf * 8);
}

/** Exported function `pipeline_asm_struct_lit_reserve_stack_bytes_c`.
 * Implements `pipeline_asm_struct_lit_reserve_stack_bytes_c`.
 * @param arena *u8
 * @param init_ref i32
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_struct_lit_reserve_stack_bytes_c(arena: *u8, init_ref: i32): i32 {
  return asm_struct_lit_reserve_stack_bytes(arena, init_ref);
}

// asm_index_elem_byte_sz: see function docblock below.
/** Exported function `asm_index_elem_byte_sz`.
 * Implements `asm_index_elem_byte_sz`.
 * @param arena *u8
 * @param index_expr_ref i32
 * @return i32
 */
#[no_mangle]
export function asm_index_elem_byte_sz(arena: *u8, index_expr_ref: i32): i32 {
  unsafe {
    return pipeline_asm_index_elem_byte_sz(arena, index_expr_ref);
  }
  return 0;
}

// pipeline_asm_enc_local_slot_ptr_or_addr_elf_c: see function docblock below.
/** Exported function `pipeline_asm_enc_local_slot_ptr_or_addr_elf_c`.
 * Implements `pipeline_asm_enc_local_slot_ptr_or_addr_elf_c`.
 * @param arena *u8
 * @param elf *u8
 * @param arg_ref i32
 * @param slot_off i32
 * @param ta i32
 * @param asm_ctx *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  return glue_enc_local_slot_ptr_or_addr(arena, elf, arg_ref, slot_off, ta, asm_ctx);
}

/** Exported function `pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c`.
 * Implements `pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c`.
 * @param arena *u8
 * @param out *u8
 * @param arg_ref i32
 * @param slot_off i32
 * @param ta i32
 * @param asm_ctx *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_asm_arch_emit_local_slot_ptr_or_addr_text_c(arena: *u8, out: *u8, arg_ref: i32, slot_off: i32, ta: i32, asm_ctx: *u8): i32 {
  return glue_arch_emit_local_slot_ptr_or_addr_text(arena, out, arg_ref, slot_off, ta, asm_ctx);
}

