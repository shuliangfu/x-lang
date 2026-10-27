// Field assign for the Windows PE link.
// Body matches seeds/win_assign_field_override.c except the arm64
// arm below: a SIMD field whose RHS is unary minus or bitwise not
// uses the existing vector let-init, for 16 bytes and for a wider
// 4-byte lane. A bare FLOAT_LIT uses that fill on the 16-byte arm.
// An INT_LIT wider than 16 bytes uses that same fill.
// An if or a ternary of that same width uses that same fill.
// A
// frame-homed VAR or FIELD wider than 16 uses the existing frame
// memcpy. An ARRAY_LIT of at least 16 bytes uses that same let-init
// into the field home. That seed does not.
// The egg copy is a different, shorter body, so this object has to
// be linked ahead of it.
// runtime_pipeline_abi_assign_field_thin.x is a different dispatcher.
// Do not switch that file on. glue_emit_assign_field_scalar_elf_c is a
// different symbol. File-local helpers keep each frame under one page.
// One product function of the whole body spills a multi-page frame.
// Pipe cells hold extern results. Do not write x = extern().
// PLATFORM: WINDOWS | MSYS | MINGW | MACOS | DARWIN. Windows g05
// rebuilds this file into build_asm/selfhost_pabi/assign_field_win.o.
// Darwin g05 rebuilds it into build_asm/selfhost_pabi/assign_field_seed.o
// and weakens the pabi_weak copy. Do not PREFER this file into
// runtime_pipeline_abi.o. Do not gcc seeds/win_assign_field_override.c.

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
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32;
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
export extern function glue_emit_fixed_array_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32,
  stack_slot_off: i32
): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32,
  stack_slot_off: i32
): i32;
export extern function pipeline_asm_set_call_expected_ret_ty_c(type_ref: i32): void;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(v: i32): void;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(
  elf_ctx: *u8, off: i32, load_sz: i32, ta: i32
): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(
  arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32
): i32;
export extern function glue_vector_var_lane_stack_off_elf_c(
  arena: *u8, ctx: *u8, var_expr_ref: i32, lane: i32, esz: i32, ta: i32
): i32;
export extern function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(
  elf_ctx: *u8, k: i32, ta: i32
): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(
  elf_ctx: *u8, off: i32, ta: i32
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
  // 10.46: frame VAR → FIELD wider than 16 must take let-init even when
  // glue_var_expr_stack_off_elf_c declines (Cap tip soft returned off < 0,
  // fell through to the one-GPR store, and Trip FIELD dest kept only 8B —
  // FA exit 6). let-init resolves the VAR by right_ref; off is unused.
  // PLATFORM: SHARED — Darwin Cap soft + tip; Win PE twin.
  if (rk == 3) {
    pre = 1;
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
  // CALL (48) wider than 16 on arm64. The later block puts the dest
  // in x0 and shifts GP args. That is the Windows hidden pointer.
  // AAPCS64 wants the pointer in x8. struct let-init already does
  // that when the dest is in x19. PLATFORM: MACOS|ARM64.
  if (pre == 0 && ta == 1 && wide_local != 0 && rk == 48) {
    pre = 1;
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
 * Store a 16-byte SIMD field from the AAPCS64 pair.
 * The scalar path pushes only x0. The field address is then written
 * into x1, so the high half is gone and lanes 2 and 3 stay stale.
 * Push x0, copy x1 into x0, push that, then store [addr+8] and [addr].
 * A lane push is pre-indexed and sits below these two saves.
 * Wider than 16 with a 4-byte lane and a unary-minus RHS is not this
 * pair. The existing vector let-init writes every lane at the field
 * home (lane 0's frame offset). A negative home or a -3 decline emits
 * nothing and keeps the scalar store. -1 may already have emitted.
 * `p.v = -h.v` for i32x8 negated the address of h.v and stored that
 * pointer, so lane 0 was not -1. A bare `p.v = h.v` or `p.v = a`
 * stored that address the same way (lane 0 was not 1). When both
 * lane-0 homes are frame offsets, the existing frame memcpy copies
 * every lane. A negative home emits nothing and keeps the scalar
 * store. An ARRAY_LIT of at least 16 bytes is not a register value:
 * emit leaves the payload address in x0, and both the pair store and
 * the scalar store wrote that address, so lane 0 was not 1. The
 * existing vector let-init stores each element at the field home.
 * Other wide RHS kinds stay scalar.
 * Exactly 16 bytes still stores x0 and x1, except unary minus.
 * `neg w0` clears lane 1 and leaves lanes 2 and 3, so lane 3 of
 * `p.v = -h.v` for i32x4 stayed 4. That RHS uses the same let-init.
 * A -3 decline keeps the pair store.
 * @param arena *u8 — AST arena; null is not reached (caller checked)
 * @param elf_ctx *u8 — encoder context
 * @param left_ref i32 — FIELD lvalue
 * @param right_ref i32 — RHS. A non-minus 16-byte value is evaluated
 *   into x0:x1. Unary minus and bitwise not go to the vector
 *   let-init. An INT_LIT wider than 16 bytes uses that same let-init.
 *   An if or a ternary of that same width uses that same let-init.
 *   An ARRAY_LIT
 *   of at least 16 bytes uses that same let-init at the field home.
 *   A frame VAR or FIELD wider than 16 is copied with the existing
 *   frame memcpy.
 * @param ctx *u8 — emit context
 * @param ta i32 — 1 is arm64; any other arch returns -99 before emitting
 * @return i32 — 0 when the field is stored; -1 when an encoder step
 *   fails after emit has started; -99 when this arm does not handle it
 * PLATFORM: MACOS|ARM64. Windows (ta == 0) stays on the one-GPR store.
 */
function assign_field_one_simd16(
  arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32
): i32 {
  let cell: u8[8];
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  let fty: i32 = 0;
  let simd: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let rc: i32 = 0;
  let rk: i32 = 0;
  let home: i32 = 0;
  let src: i32 = 0;
  let unary_lane: i32 = 0;
  let if_lane: i32 = 0;
  if (ta != 1) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_field_access_field_type_ref_c(
      arena, pipeline_asm_emit_module_ref_c(), left_ref));
  }
  fty = assign_field_cell_i32(&cell[0]);
  if (fty <= 0) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, asm_type_is_simd_vector_spelling(arena, fty));
  }
  simd = assign_field_cell_i32(&cell[0]);
  if (simd == 0) {
    // A local Pair is not a vector, but it is still a 16-byte x0:x1
    // value. The one-GPR store pushes only x0 and then puts the field
    // address in x1, so b stays 0 after h.s = p. The wider-than-16
    // arm below returns -99 when lanes * esz is not 16, so this arm
    // uses a 16-by-1 shape. That skips the 4-byte lane writers and
    // reaches the pair store. Any other width keeps the one-GPR store.
    // PLATFORM: MACOS|ARM64.
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_sysv_dual_gp_byte_size_c(arena, fty));
    }
    if (assign_field_cell_i32(&cell[0]) != 16) {
      return 0 - 99;
    }
    lanes = 16;
    esz = 1;
  } else {
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_vector_type_lanes_esz_c(
      arena, fty, &lanes_s[0], &esz_s[0]));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0 || lanes_s[0] <= 0 || esz_s[0] <= 0) {
    return 0 - 99;
  }
  lanes = lanes_s[0];
  esz = esz_s[0];
  }
  // ARRAY_LIT (kind 46) leaves the payload address in x0. The 16-byte
  // pair store writes that address into x0:x1. Wider than 16 misses
  // the arms below and the scalar store writes it with str w. Lane 0
  // of `p.v = [1, 2, 3, 4]` and of `p.v = [1, 2, 3, 4, 5, 6, 7, 8]`
  // was not 1. The existing vector let-init already stores every
  // element of a 16, 32, or 64 byte literal into the slot it is given.
  // That slot is the destination field. A negative home emits nothing
  // and keeps the old store. A -3 decline does too. -1 may already
  // have emitted. Unary minus, VAR, and FIELD stay on the arms below.
  // Element size other than 4 stays on those arms. Do not pin a name.
  // PLATFORM: MACOS|ARM64.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
  }
  rk = assign_field_cell_i32(&cell[0]);
  if (rk == 46 && esz == 4 && lanes > 0 && (lanes * esz) >= 16) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
        arena, ctx, left_ref, 0, esz, ta));
    }
    home = assign_field_cell_i32(&cell[0]);
    if (home >= 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, glue_emit_vector_type_let_init_elf_c(
          arena, elf_ctx, right_ref, ctx, ta, home, fty));
      }
      rc = assign_field_cell_i32(&cell[0]);
      if (rc == 0) {
        return 0;
      }
      if (rc == (0 - 1)) {
        return 0 - 1;
      }
    }
  }
  // GPR pair is 16 bytes. A wider 4-byte-lane SIMD whose RHS is
  // unary minus (kind 22) or bitwise not (kind 23) is stored by the
  // existing per-lane writer. That writer already negates or mvn's
  // a wide FIELD, VAR, or ARRAY_LIT into the slot it is given. The
  // slot here is the destination field. Kind 23 used to miss this
  // gate, so `p.v = ~h.v` on i32x8 did one scalar mvn and lane 0
  // was not -2. A binop, CALL, METHOD, INDEX, or DEREF under the
  // minus or the not still returns -3 before emitting, and this arm
  // then keeps the scalar store. A bare VAR (kind 3) or FIELD
  // (kind 44) is not kind 22 or 23.
  // Those two already have a frame home. The let of the same value
  // copies it with lea of the source home plus the frame memcpy.
  // That memcpy parks the source with mov x1, x0 before the dest lea.
  // PLATFORM: MACOS|ARM64.
  if (lanes * esz != 16) {
    if (esz == 4 && (lanes * esz) > 16) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
      }
      rk = assign_field_cell_i32(&cell[0]);
      // Two statements. A chained comparison is not reliable here.
      // Kind 22 stays unary minus. Kind 23 is bitwise not. Both are
      // already implemented by the let-init. PLATFORM: MACOS|ARM64.
      unary_lane = 0;
      if (rk == 22) {
        unary_lane = 1;
      }
      if (rk == 23) {
        unary_lane = 1;
      }
      if (unary_lane != 0) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
            arena, ctx, left_ref, 0, esz, ta));
        }
        home = assign_field_cell_i32(&cell[0]);
        if (home >= 0) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, glue_emit_vector_type_let_init_elf_c(
              arena, elf_ctx, right_ref, ctx, ta, home, fty));
          }
          rc = assign_field_cell_i32(&cell[0]);
          if (rc == 0) {
            return 0;
          }
          if (rc == (0 - 1)) {
            return 0 - 1;
          }
        }
      }
      // Bare copy. Kind 3 is a local vector. Kind 44 is a field.
      // Both homes are rbp offsets from the same lane helper the
      // negate arm uses. A negative home means the value is not a
      // frame slot, so emit nothing and keep the scalar store.
      // Equal homes are already the destination (`p.v = p.v`);
      // memcpy of an overlapping range is not this copy. The byte
      // count is the SIMD width, which is greater than 16 here, so
      // the frame arm of the existing memcpy accepts it.
      // PLATFORM: MACOS|ARM64.
      if (rk == 3 || rk == 44) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
            arena, ctx, right_ref, 0, esz, ta));
        }
        src = assign_field_cell_i32(&cell[0]);
        if (src >= 0) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
              arena, ctx, left_ref, 0, esz, ta));
          }
          home = assign_field_cell_i32(&cell[0]);
          if (home >= 0) {
            if (src == home) {
              return 0;
            }
            unsafe {
              pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(
                elf_ctx, src, ta));
            }
            rc = assign_field_cell_i32(&cell[0]);
            if (rc != 0) {
              return 0 - 1;
            }
            unsafe {
              pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(
                elf_ctx, home, lanes * esz, ta));
            }
            rc = assign_field_cell_i32(&cell[0]);
            if (rc != 0) {
              return 0 - 1;
            }
            return 0;
          }
        }
      }
      // INT_LIT (kind 0). Wider than 16 missed the arms above and the
      // scalar store wrote one str w. Lane 0 of `h.v = 0` on Vec8i
      // became 0 and lane 7 stayed 9. `h.v = 1` on i32x8 did the same
      // with 1. The existing vector let-init splats an INT_LIT into
      // every lane of the slot it is given. That slot is the
      // destination field. A negative home emits nothing and keeps
      // the scalar store. A -3 decline does too. -1 may already have
      // emitted. Exactly 16 bytes stays on the pair store: i32x4
      // `h.v = 1` already writes every lane there. BOOL_LIT and
      // FLOAT_LIT stay on the scalar store.
      // PLATFORM: MACOS|ARM64.
      if (rk == 0) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
            arena, ctx, left_ref, 0, esz, ta));
        }
        home = assign_field_cell_i32(&cell[0]);
        if (home >= 0) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, glue_emit_vector_type_let_init_elf_c(
              arena, elf_ctx, right_ref, ctx, ta, home, fty));
          }
          rc = assign_field_cell_i32(&cell[0]);
          if (rc == 0) {
            return 0;
          }
          if (rc == (0 - 1)) {
            return 0 - 1;
          }
        }
      }
      // EXPR_IF = 25 and EXPR_TERNARY = 27. Wider than 16 missed the
      // arms above, so `h.v = if (c) { 3 } else { -3 }` and
      // `h.v = c != 0 ? 3 : -3` stored one str w. Lane 0 became 3 and
      // lane 7 stayed 0. The existing vector let-init already fills
      // both arms of a kind-13 i32 vector into the slot it is given,
      // or returns -3 before emitting. That slot is the destination
      // field. A negative home emits nothing and keeps the scalar
      // store. A -3 decline does too. -1 may already have emitted.
      // A 16-byte vector stays on the pair store. Kind 24 stays on
      // the sibling decline. PLATFORM: MACOS|ARM64.
      if_lane = 0;
      if (rk == 25) {
        if_lane = 1;
      }
      if (rk == 27) {
        if_lane = 1;
      }
      if (if_lane != 0) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
            arena, ctx, left_ref, 0, esz, ta));
        }
        home = assign_field_cell_i32(&cell[0]);
        if (home >= 0) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, glue_emit_vector_type_let_init_elf_c(
              arena, elf_ctx, right_ref, ctx, ta, home, fty));
          }
          rc = assign_field_cell_i32(&cell[0]);
          if (rc == 0) {
            return 0;
          }
          if (rc == (0 - 1)) {
            return 0 - 1;
          }
        }
      }
    }
    return 0 - 99;
  }
  // emit_expr of unary minus loads the 16-byte field, then neg w0.
  // A W write clears the top half of x0, so lane 1 becomes 0, and
  // the high pair in x1 is still lanes 2 and 3. Lane 3 of
  // `p.v = -h.v` stayed 4. Bitwise not does the same with mvn w0:
  // lane 1 of `p.v = ~h.v` was 0. A bare FLOAT_LIT (kind 1) takes
  // the same fallthrough: emit_expr writes the f64 bits
  // (1.0 is movk x0, #0x3ff0, lsl #48) and the pair store writes
  // two str x. Lane 0 of `h.v = 1.0` on Vec4f was 0. The existing
  // let-init already splats that literal, and already negates or
  // mvn's every 4-byte lane, into the slot it is given. Kind 1 is
  // not a unary. It shares this call. A negative field home, or a
  // -3 decline, emits nothing and keeps this pair store. -1 may
  // already have emitted. Wider than 16 does not take kind 1 here.
  // PLATFORM: MACOS|ARM64.
  if (esz == 4) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
    }
    rk = assign_field_cell_i32(&cell[0]);
    unary_lane = 0;
    if (rk == 22) {
      unary_lane = 1;
    }
    if (rk == 23) {
      unary_lane = 1;
    }
    if (rk == 1) {
      unary_lane = 1;
    }
    if (unary_lane != 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, glue_vector_var_lane_stack_off_elf_c(
          arena, ctx, left_ref, 0, esz, ta));
      }
      home = assign_field_cell_i32(&cell[0]);
      if (home >= 0) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, glue_emit_vector_type_let_init_elf_c(
            arena, elf_ctx, right_ref, ctx, ta, home, fty));
        }
        rc = assign_field_cell_i32(&cell[0]);
        if (rc == 0) {
          return 0;
        }
        if (rc == (0 - 1)) {
          return 0 - 1;
        }
      }
    }
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_c(
      arena, elf_ctx, right_ref, ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  // Low half first, then the high half that still sits in x1.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
      arena, elf_ctx, left_ref, ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  // High half at +8. x1 is still the field address.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_store_rax_to_rbx_offset_arch(
      elf_ctx, 8, 8, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_store_rax_to_rbx_offset_arch(
      elf_ctx, 0, 8, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Copy an ARRAY_LIT into a TYPE_ARRAY field.
 * `bag.one = [w]` used to take the one-GPR store, which writes the
 * payload pointer. Lane 0 then reads that pointer and is not 1.
 * The address of the field goes into rbx, then the same dest-in-rbx
 * fixed-array let-init as `*p = [w]` (slot -3). A -2 decline keeps
 * the scalar store. -1 is an encoder failure.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param left_ref i32 — FIELD lvalue
 * @param right_ref i32 — RHS; only kind 46 is handled
 * @param ctx *u8 — emit context
 * @param ta i32 — 0 x86-64, 1 arm64; any other returns -99
 * @return i32 — 0 when the array was stored; -1 on encoder failure;
 *   -99 when the field is not a TYPE_ARRAY or the RHS is not an ARRAY_LIT
 * PLATFORM: SHARED — Darwin leftover 10. MACOS|ARM64 · LINUX x86_64.
 */
function assign_field_one_array_lit(
  arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32
): i32 {
  let cell: u8[8];
  let fty: i32 = 0;
  let tk: i32 = 0;
  let rk: i32 = 0;
  let rc: i32 = 0;
  if (ta != 0 && ta != 1) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_field_access_field_type_ref_c(
      arena, pipeline_asm_emit_module_ref_c(), left_ref));
  }
  fty = assign_field_cell_i32(&cell[0]);
  if (fty <= 0) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, fty));
  }
  tk = assign_field_cell_i32(&cell[0]);
  if (tk != 10) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
  }
  rk = assign_field_cell_i32(&cell[0]);
  if (rk != 46) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
      arena, elf_ctx, left_ref, ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_emit_fixed_array_type_let_init_elf_c(
      arena, elf_ctx, right_ref, ctx, ta, fty, 0 - 3));
  }
  rc = assign_field_cell_i32(&cell[0]);
  if (rc == 0) {
    return 0;
  }
  if (rc == (0 - 1)) {
    return 0 - 1;
  }
  return 0 - 99;
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
 * a FIELD. On arm64 a 16-byte SIMD field stores x0 and x1, unless
 * the RHS is unary minus: that uses the existing vector let-init
 * into the field home. A wider SIMD whose lane is 4 bytes and whose
 * RHS is unary minus, bitwise not, an INT_LIT, an if, or a ternary
 * uses that same let-init. An ARRAY_LIT of at
 * least 16 bytes whose lane is 4 bytes uses that let-init too. The
 * same wider width whose RHS is a frame-homed VAR or FIELD uses the
 * existing frame memcpy.
 * Any other ta != 0 value stays on the one-GPR store. Pipe cells hold extern
 * results. PLATFORM: WINDOWS | DARWIN — one strong T. Windows links
 * this object ahead of the egg. Darwin weakens the pabi_weak copy.
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
  // A field wider than 16 bytes is the same dest-in-x19 copy the
  // x86 arm already uses. Trip and Quad are not 16-byte pairs.
  // PLATFORM: MACOS|ARM64.
  if (ek == 28 && ta == 1) {
    assign_field_one_flags(arena, ctx, left_ref, &ftycell[0], &widecell[0], &wlocell[0], &ptrcell[0]);
    fty = assign_field_cell_i32(&ftycell[0]);
    wide = assign_field_cell_i32(&widecell[0]);
    // 10.46: Cap tip field-type named size can under-report (Trip FIELD
    // dest saw wide=8 → one-GPR store → FA exit 6). When the RHS is a
    // frame VAR or FIELD, take max(wide, RHS named layout size).
    // PLATFORM: MACOS|ARM64.
    unsafe {
      pipe_store_i32_le(&ekcell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
    }
    handled = assign_field_cell_i32(&ekcell[0]);
    if (handled == 3 || handled == 44) {
      unsafe {
        pipe_store_i32_le(&rccell[0], 0, pipeline_expr_resolved_type_ref(arena, right_ref));
      }
      rc = assign_field_cell_i32(&rccell[0]);
      if (rc <= 0 && handled == 3) {
        unsafe {
          pipe_store_i32_le(&rccell[0], 0, glue_var_decl_type_ref_elf_c(arena, ctx, right_ref));
        }
        rc = assign_field_cell_i32(&rccell[0]);
      }
      if (rc > 0) {
        unsafe {
          pipe_store_i32_le(&hcell[0], 0, glue_type_named_layout_size_any_module_elf_c(arena, rc));
        }
        if (assign_field_cell_i32(&hcell[0]) > wide) {
          wide = assign_field_cell_i32(&hcell[0]);
        }
        if (fty <= 0) {
          fty = rc;
        }
      }
    }
    if (wide > 16) {
      unsafe {
        pipe_store_i32_le(&hcell[0], 0, 0);
        pipe_store_i32_le(&rccell[0], 0, assign_field_one_wide(
          arena, elf_ctx, left_ref, right_ref, ctx, ta, fty, wide, 1, 0, &hcell[0]));
      }
      handled = assign_field_cell_i32(&hcell[0]);
      rc = assign_field_cell_i32(&rccell[0]);
      if (handled != 0) {
        return rc;
      }
    }
  }
  // TYPE_ARRAY field `bag.one = [w]`. -99 keeps the one-GPR store.
  // PLATFORM: SHARED — Darwin leftover 10.
  if (ek == 28) {
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, assign_field_one_array_lit(
        arena, elf_ctx, left_ref, right_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != (0 - 99)) {
      return rc;
    }
  }
  // 16-byte SIMD on arm64. -99 keeps the one-GPR store below.
  // PLATFORM: MACOS|ARM64.
  if (ek == 28 && ta == 1) {
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, assign_field_one_simd16(
        arena, elf_ctx, left_ref, right_ref, ctx, ta));
    }
    rc = assign_field_cell_i32(&rccell[0]);
    if (rc != (0 - 99)) {
      return rc;
    }
  }
  // 10.46: never one-GPR-store a FIELD wider than 16 on arm64 (silent
  // 8B truncate → FA exit 6). Wide arms above must have handled it.
  // PLATFORM: MACOS|ARM64.
  if (ek == 28 && ta == 1 && wide > 16) {
    return 0 - 1;
  }
  unsafe {
    return assign_field_one_scalar(
      arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, ek);
  }
}
