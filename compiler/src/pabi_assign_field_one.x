// Field assign for the Windows PE link.
// Body matches seeds/win_assign_field_override.c. The egg copy is a
// different, shorter body, so this object has to be linked ahead of it.
// runtime_pipeline_abi_assign_field_thin.x is a different dispatcher.
// Do not switch that file on. glue_emit_assign_field_scalar_elf_c is a
// different symbol. File-local helpers keep each frame under one page.
// One product function of the whole body spills a multi-page frame.
// Pipe cells hold extern results. Do not write x = extern().
// PLATFORM: WINDOWS | MSYS | MINGW. g05 rebuilds this file into
// build_asm/selfhost_pabi/assign_field_win.o. Darwin still compiles
// seeds/win_assign_field_override.c. Do not PREFER this file into
// runtime_pipeline_abi.o. Do not gcc that seed on Windows.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(
  arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32,
  ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(
  elf_ctx: *u8, elem_sz: i32, ta: i32
): i32;
export extern function pipeline_expr_field_access_load_byte_sz(
  arena: *u8, mod: *u8, expr_ref: i32
): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(
  arena: *u8, mod: *u8, fa_ref: i32
): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(
  arena: *u8, ty_ref: i32
): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(
  arena: *u8, expr_ref: i32
): i32;
export extern function glue_var_decl_type_ref_elf_c(
  arena: *u8, ctx: *u8, var_expr_ref: i32
): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(
  arena: *u8, ctx: *u8, var_expr_ref: i32
): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32,
  stack_slot_off: i32
): i32;
export extern function pipeline_asm_set_call_expected_ret_ty_c(type_ref: i32): void;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(v: i32): void;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(
  elf_ctx: *u8, k: i32, ta: i32
): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Load an i32 that was stored in a pipe cell.
 * @param base *u8 — cell base; the store wrote 4 bytes at offset 0
 * @return i32 — stored value
 * PLATFORM: WINDOWS — file-local helper, not a link export.
 */
function assign_field_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Record named-layout width and the exactly-16 pointer-base flag.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context, used for the base variable's decl type
 * @param left_ref i32 — FIELD lvalue
 * @param out_fty *u8 — i32 cell; field type ref, or 0
 * @param out_wide *u8 — i32 cell; named layout size, or 0
 * @param out_wide_local *u8 — i32 cell; 1 when kind is 8 and size > 16
 * @param out_ptr_base *u8 — i32 cell; 1 when kind is 8, size is 16, and
 *   the base variable is a pointer (type kind 9)
 * @return void
 * A non-positive field type leaves every cell at 0. PLATFORM: WINDOWS.
 */
function assign_field_one_flags(
  arena: *u8, ctx: *u8, left_ref: i32,
  out_fty: *u8, out_wide: *u8, out_wide_local: *u8, out_ptr_base: *u8
): void {
  let ftycell: u8[4] = [];
  let widecell: u8[4] = [];
  let fkcell: u8[4] = [];
  let basecell: u8[4] = [];
  let kindcell: u8[4] = [];
  let btycell: u8[4] = [];
  let rtycell: u8[4] = [];
  let fty: i32 = 0;
  let wide: i32 = 0;
  let fk: i32 = 0;
  let base: i32 = 0;
  let bk: i32 = 0;
  let bty: i32 = 0;
  let rty: i32 = 0;
  let ptr_base: i32 = 0;
  unsafe {
    pipe_store_i32_le(out_fty, 0, 0);
    pipe_store_i32_le(out_wide, 0, 0);
    pipe_store_i32_le(out_wide_local, 0, 0);
    pipe_store_i32_le(out_ptr_base, 0, 0);
    pipe_store_i32_le(&ftycell[0], 0, glue_field_access_field_type_ref_c(
      arena, pipeline_asm_emit_module_ref_c(), left_ref));
  }
  fty = assign_field_cell_i32(&ftycell[0]);
  if (fty > 0) {
    unsafe {
      pipe_store_i32_le(&widecell[0], 0, glue_type_named_layout_size_any_module_elf_c(arena, fty));
      pipe_store_i32_le(&fkcell[0], 0, pipeline_type_kind_ord_at(arena, fty));
    }
    wide = assign_field_cell_i32(&widecell[0]);
    fk = assign_field_cell_i32(&fkcell[0]);
    unsafe {
      pipe_store_i32_le(out_fty, 0, fty);
      pipe_store_i32_le(out_wide, 0, wide);
    }
  }
  // Named layout wider than one GPR. PLATFORM: WINDOWS x86_64.
  if (fk == 8 && wide > 16) {
    unsafe {
      pipe_store_i32_le(out_wide_local, 0, 1);
    }
  }
  // Exactly 16 bytes copies only when the base variable is a pointer.
  if (fk == 8 && wide == 16) {
    unsafe {
      pipe_store_i32_le(&basecell[0], 0, pipeline_expr_field_access_base_ref(arena, left_ref));
    }
    base = assign_field_cell_i32(&basecell[0]);
    if (base > 0) {
      unsafe {
        pipe_store_i32_le(&kindcell[0], 0, pipeline_expr_kind_ord_at(arena, base));
      }
      bk = assign_field_cell_i32(&kindcell[0]);
      if (bk == 3) {
        unsafe {
          pipe_store_i32_le(&btycell[0], 0, glue_var_decl_type_ref_elf_c(arena, ctx, base));
          pipe_store_i32_le(&rtycell[0], 0, pipeline_expr_resolved_type_ref(arena, base));
        }
        bty = assign_field_cell_i32(&btycell[0]);
        rty = assign_field_cell_i32(&rtycell[0]);
        if (bty > 0) {
          unsafe {
            pipe_store_i32_le(&kindcell[0], 0, pipeline_type_kind_ord_at(arena, bty));
          }
          bk = assign_field_cell_i32(&kindcell[0]);
          if (bk == 9) {
            ptr_base = 1;
          }
        }
        if (ptr_base == 0 && rty > 0) {
          unsafe {
            pipe_store_i32_le(&kindcell[0], 0, pipeline_type_kind_ord_at(arena, rty));
          }
          bk = assign_field_cell_i32(&kindcell[0]);
          if (bk == 9) {
            ptr_base = 1;
          }
        }
        if (ptr_base != 0) {
          unsafe {
            pipe_store_i32_le(out_ptr_base, 0, 1);
          }
        }
      }
    }
  }
}

/**
 * Emit the wide FIELD arms that must not fall through to a one-GPR store.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param left_ref i32 — FIELD lvalue
 * @param right_ref i32 — RHS expression
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch; the caller has already required 0
 * @param fty i32 — field type ref
 * @param wide i32 — named layout size in bytes
 * @param wide_local i32 — 1 when the layout is wider than 16
 * @param ptr_base i32 — 1 when an exactly-16 field base is a pointer
 * @param handled *u8 — i32 cell; set to 1 when this arm returns a final rc
 * @return i32 — 0, -1, or the memcpy rc when handled is 1; 0 when no arm matches
 * VAR and FIELD always take let-init slot -3. STRUCT_LIT takes that
 * let-init only when wide_local is 1. CALL places the field in rcx and
 * sets the sret shift, then clears the shift even when emit fails.
 * INDEX memcpy's wide bytes and does not call let-init. A failure after
 * the destination is written does not fall through. PLATFORM: WINDOWS.
 */
function assign_field_one_wide(
  arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8,
  ta: i32, fty: i32, wide: i32, wide_local: i32, ptr_base: i32, handled: *u8
): i32 {
  let rkcell: u8[4] = [];
  let rccell: u8[4] = [];
  let offcell: u8[4] = [];
  let rk: i32 = 0;
  let rc: i32 = 0;
  let off: i32 = 0;
  let pre: i32 = 0;
  let expect: i32 = 0;
  if (wide_local == 0 && ptr_base == 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&rkcell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
  }
  rk = assign_field_cell_i32(&rkcell[0]);
  if (rk == 3) {
    unsafe {
      pipe_store_i32_le(&offcell[0], 0, glue_var_expr_stack_off_elf_c(arena, ctx, right_ref));
    }
    off = assign_field_cell_i32(&offcell[0]);
    if (off >= 0) {
      pre = 1;
    }
  } else {
    if (rk == 44) {
      pre = 1;
    } else {
      // STRUCT_LIT (45). wide_local only. Exactly 16 stays on the GPR store.
      if (wide_local != 0 && rk == 45) {
        pre = 1;
      }
    }
  }
  if (pre != 0) {
    unsafe {
      pipe_store_i32_le(handled, 0, 1);
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
        arena, elf_ctx, left_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, glue_emit_struct_type_let_init_elf_c(
        arena, elf_ctx, right_ref, ctx, ta, fty, 0 - 3));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc == 0) {
      return 0;
    }
    return 0 - 1;
  }
  // CALL (48). Field address is the hidden return slot. wide_local only.
  if (wide_local != 0 && rk == 48) {
    unsafe {
      pipe_store_i32_le(handled, 0, 1);
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
        arena, elf_ctx, left_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    expect = 0;
    if (fty > 0) {
      expect = fty;
    }
    unsafe {
      pipeline_asm_set_call_expected_ret_ty_c(expect);
      pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_expr_elf_c(
        arena, elf_ctx, right_ref, ctx, ta));
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  // INDEX (47). Copy wide bytes. A failed lvalue does not pop. wide_local only.
  if (wide_local != 0 && rk == 47) {
    unsafe {
      pipe_store_i32_le(handled, 0, 1);
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
        arena, elf_ctx, right_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
        arena, elf_ctx, left_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta);
    }
  }
  return 0;
}

/**
 * Emit the one-GPR FIELD store, including compound ops of at most 8 bytes.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param expr_ref i32 — assignment expression
 * @param left_ref i32 — FIELD lvalue
 * @param right_ref i32 — RHS expression
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param ek i32 — assignment kind; 28 emits the RHS, 29..38 use rhs-to-rax
 * @return i32 — store rc, or -1 when a compound field is wider than 8
 *   or an encoder step fails
 * A non-positive load size becomes 8. The destination lvalue is emitted
 * after the RHS value has been pushed. PLATFORM: WINDOWS.
 */
function assign_field_one_scalar(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32,
  ctx: *u8, ta: i32, ek: i32
): i32 {
  let szcell: u8[4] = [];
  let rccell: u8[4] = [];
  let sz: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    pipe_store_i32_le(&szcell[0], 0, pipeline_expr_field_access_load_byte_sz(
      arena, pipeline_asm_emit_module_ref_c(), left_ref));
  }
  sz = assign_field_cell_i32(&szcell[0]);
  if (sz <= 0) {
    sz = 8;
  }
  if (ek != 28) {
    if (sz > 8) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, glue_emit_assign_rhs_to_rax_elf_c(
        arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_expr_elf_c(
        arena, elf_ctx, right_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
      arena, elf_ctx, left_ref, ctx, ta));
  }
  rc = assign_field_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
  }
}

/**
 * Emit a FIELD-lvalue assignment, including wide named layouts and compound ops.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — encoder context; null returns -1
 * @param expr_ref i32 — assignment expression (kind 28, or 29..38)
 * @param left_ref i32 — FIELD lvalue; <= 0 returns -1
 * @param right_ref i32 — RHS expression; <= 0 returns -1
 * @param ctx *u8 — emit context; null returns -1
 * @param ta i32 — target arch; 0 is x86-64. The wide gate runs only when ta is 0
 * @return i32 — 0 when the store or copy was emitted; -1 on a rejected
 *   shape or an encoder failure. A memcpy return is passed through.
 * Kinds other than 28 and 29..38 return -1. A layout wider than 16 bytes
 * on x86-64 copies a VAR, FIELD, or STRUCT_LIT through let-init slot -3,
 * a CALL through sret, and an INDEX through memcpy. Exactly 16 bytes uses
 * let-init only when the base is a pointer and the RHS is a frame VAR or
 * a FIELD. ta != 0 stays on the one-GPR store. Pipe cells hold extern
 * results. PLATFORM: WINDOWS — one strong T, linked ahead of the egg.
 */
#[no_mangle]
export function glue_emit_assign_field_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32,
  ctx: *u8, ta: i32
): i32 {
  let ekcell: u8[4] = [];
  let ftycell: u8[4] = [];
  let widecell: u8[4] = [];
  let wlocell: u8[4] = [];
  let ptrcell: u8[4] = [];
  let hcell: u8[4] = [];
  let rccell: u8[4] = [];
  let ek: i32 = 0;
  let fty: i32 = 0;
  let wide: i32 = 0;
  let wide_local: i32 = 0;
  let ptr_base: i32 = 0;
  let handled: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)
      || left_ref <= 0 || right_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&ekcell[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
  }
  ek = assign_field_cell_i32(&ekcell[0]);
  if (ek != 28 && (ek < 29 || ek > 38)) {
    return 0 - 1;
  }
  if (ek == 28 && ta == 0) {
    assign_field_one_flags(arena, ctx, left_ref, &ftycell[0], &widecell[0], &wlocell[0], &ptrcell[0]);
    fty = assign_field_cell_i32(&ftycell[0]);
    wide = assign_field_cell_i32(&widecell[0]);
    wide_local = assign_field_cell_i32(&wlocell[0]);
    ptr_base = assign_field_cell_i32(&ptrcell[0]);
    if (wide_local != 0 || ptr_base != 0) {
      unsafe {
        pipe_store_i32_le(&hcell[0], 0, 0);
        pipe_store_i32_le(&rccell[0], 0, assign_field_one_wide(
          arena, elf_ctx, left_ref, right_ref, ctx, ta, fty, wide, wide_local,
          ptr_base, &hcell[0]));
      }
      handled = assign_field_cell_i32(&hcell[0]);
      rc = assign_field_cell_i32(&rccell[0]);
      if (handled != 0) {
        return rc;
      }
    }
  }
  unsafe {
    return assign_field_one_scalar(
      arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, ek);
  }
}
