// Thin pure overlay (w1521, 终局待办 10.57): EXPR_RETURN ELF impl with the
// AAPCS64 indirect-result copy. Darwin's live impl (pabi_weak strong) only
// evaluated the operand into x0 and jumped to tail_join; for a function
// returning > 16 bytes nothing ever reached the caller's x8 buffer, so the
// caller read a pointer into the dead callee frame (bus error / garbage).
// Here, after the operand (x0 = address of the value: temp slot, &local, or
// a callee's result), the value is copied into the dest pointer parked at
// the sret home (w499_mega_emit_frame) and x0 is set to that dest. Inline
// qword+byte copy through x9/x10 (no memcpy call: leaf frames, src==dst ok).
// Same exit otherwise as runtime_pipeline_abi_return_elf_impl_thin.x.
// Linked by g05_relink_env (_g05_pure_overlay return_sret) before seeds;
// pabi_weak.o _pipeline_asm_emit_return_elf_impl weakened.
// x86_64 SysV (Linux, w1521): `return v` with a > 16-byte local only did
// mov rax,[v]. The overlay takes lea rax,[rbp-off] for a local VAR operand,
// copies into the dest parked at [rbp-home] (rdi homed by the frame), and
// returns the dest in rax. Windows x64 (w1521): same copy; the hidden dest
// arrives in rcx and is homed by win_param_home_thin; rcx/rdx are volatile.
// PLATFORM: MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.

export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_module_func_param_type_ref_for_name(mod: *u8, func_index: i32, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function link_abi_host_is_windows(): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(shift: i32): void;
export extern function pipeline_asm_set_call_expected_ret_ty_c(type_ref: i32): void;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function w1545_win_ret_slot_for_c(mod: *u8, func_index: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_func_param_is_indirect_array_slot_c(arena: *u8, mod: *u8, var_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_len(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_field_name_into(arena: *u8, expr_ref: i32, j: i32, out: *u8): void;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_off: i32, type_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_wide_i32_vec_array_bytes(arena: *u8, rty: i32): i32;
export extern function glue_index_simd_elem_bytes_c(arena: *u8, ty: i32): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function vlet_lane_cmp_ko(ko: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, index: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;

/**
 * `return f(...)` forwarding a > 16-byte result: pass this function's own
 * dest ([rbp-home]) as the callee's hidden rdi (shift 1, same as the
 * let-init sret path), then rax = dest. @return 0 ok; -1 fail.
 * PLATFORM: LINUX x86_64.
 */
function w1521_rs_fwd_call_x86(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, home: i32): i32 {
  let rc_u1: i32 = 0;
  let ty_u2: i32 = 0;
  unsafe {
    ty_u2 = pipeline_expr_resolved_type_ref(arena, op);
    if (ty_u2 > 0) {
      pipeline_asm_set_call_expected_ret_ty_c(ty_u2);
    } else {
      pipeline_asm_set_call_expected_ret_ty_c(0);
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return 0 - 1;
    }
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return 0 - 1;
    }
    pipeline_asm_emit_set_call_sret_reg_shift_c(1);
    rc_u1 = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    pipeline_asm_emit_set_call_sret_reg_shift_c(0);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (rc_u1 != 0) {
      return 0 - 1;
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/** Append one byte. PLATFORM: LINUX x86_64. */
function w1521_rs_b(elf_ctx: *u8, v: i32): i32 {
  let b1_u3: u8[1] = [];
  b1_u3[0] = (v & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b1_u3[0], 1);
  }
  return 0 - 1;
}

/** Append a little-endian disp32. PLATFORM: LINUX x86_64. */
function w1521_rs_d32(elf_ctx: *u8, v: i32): i32 {
  let b2_u4: u8[4] = [];
  b2_u4[0] = (v & 255) as u8;
  b2_u4[1] = ((v >> 8) & 255) as u8;
  b2_u4[2] = ((v >> 16) & 255) as u8;
  b2_u4[3] = ((v >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b2_u4[0], 4);
  }
  return 0 - 1;
}

/**
 * Local VAR operand frame offset (rbp-off), or -1 when the operand is not a
 * plain local. PLATFORM: LINUX x86_64.
 */
function w1521_rs_local_off(arena: *u8, ctx: *u8, op: i32): i32 {
  let vname_u5: u8[256] = [];
  let vlen_u6: i32 = 0;
  let off_u7: i32 = 0 - 1;
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, op) != 3) {
      return 0 - 1;
    }
    vlen_u6 = pipeline_expr_var_name_len(arena, op);
  }
  if (vlen_u6 <= 0 || vlen_u6 > 255) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, op, &vname_u5[0]);
    off_u7 = asm_ctx_local_find_offset_scoped(ctx, arena, &vname_u5[0], vlen_u6);
    if (off_u7 < 0) {
      off_u7 = asm_ctx_local_find_offset(ctx, &vname_u5[0], vlen_u6);
    }
  }
  return off_u7;
}

/**
 * rax = source address. mov rcx,[rbp-home]; copy sz bytes rax to rcx via
 * rdx/dl; mov rax,rcx. @return 0 ok; 1 not applicable; -1 encoder fail.
 * PLATFORM: LINUX x86_64.
 */
function w1521_rs_copy_x86(elf_ctx: *u8, home: i32, sz: i32): i32 {
  let k_u8: i32 = 0;
  /* 10.46: Win64 16B Pair uses hidden dest; allow sz==16 copy. */
  if (home <= 0 || sz < 16 || sz > 1000000) {
    return 1;
  }
  // mov rcx, [rbp - home]
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 141) != 0) { return 0 - 1; }
  if (w1521_rs_d32(elf_ctx, 0 - home) != 0) { return 0 - 1; }
  while (k_u8 + 8 <= sz) {
    // mov rdx, [rax + k] ; mov [rcx + k], rdx
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k_u8) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k_u8) != 0) { return 0 - 1; }
    k_u8 = k_u8 + 8;
  }
  while (k_u8 < sz) {
    // movzx edx, byte [rax + k] ; mov [rcx + k], dl
    if (w1521_rs_b(elf_ctx, 15) != 0 || w1521_rs_b(elf_ctx, 182) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k_u8) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 136) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k_u8) != 0) { return 0 - 1; }
    k_u8 = k_u8 + 1;
  }
  // mov rax, rcx
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 200) != 0) { return 0 - 1; }
  return 0;
}

/**
 * rax holds the source. Copy `width` bytes from rax to the hidden dest
 * parked at [rbp-home], starting at dest_off, then leave that dest in rax.
 * width and dest_off are multiples of 8. A non-positive home returns 1.
 * @param elf_ctx *u8 — encoder context
 * @param home i32 — positive frame slot of the saved dest pointer
 * @param dest_off i32 — byte offset into the dest, multiple of 8
 * @param width i32 — byte count, multiple of 8
 * @return i32 — 0 ok; 1 not applicable; -1 encoder fail
 * PLATFORM: LINUX x86_64.
 */
function w1521_rs_copy_x86_off(elf_ctx: *u8, home: i32, dest_off: i32, width: i32): i32 {
  let k_u9: i32 = 0;
  let d_u10: i32 = 0;
  if (home <= 0 || dest_off < 0 || width <= 0 || width > 32000) {
    return 1;
  }
  if ((dest_off % 8) != 0 || (width % 8) != 0) {
    return 1;
  }
  if (dest_off + width > 1000000) {
    return 1;
  }
  // mov rcx, [rbp - home]
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 141) != 0) { return 0 - 1; }
  if (w1521_rs_d32(elf_ctx, 0 - home) != 0) { return 0 - 1; }
  while (k_u9 + 8 <= width) {
    d_u10 = dest_off + k_u9;
    // mov rdx, [rax + k] ; mov [rcx + d], rdx
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k_u9) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, d_u10) != 0) { return 0 - 1; }
    k_u9 = k_u9 + 8;
  }
  // mov rax, rcx
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 200) != 0) { return 0 - 1; }
  return 0;
}

/** Append one little-endian arm64 instruction word. PLATFORM: MACOS|ARM64. */
function w1521_rs_a64(elf_ctx: *u8, word: i64): i32 {
  let b3_u11: u8[4] = [];
  b3_u11[0] = (word & 255) as u8;
  b3_u11[1] = ((word >> 8) & 255) as u8;
  b3_u11[2] = ((word >> 16) & 255) as u8;
  b3_u11[3] = ((word >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b3_u11[0], 4);
  }
  return 0 - 1;
}

/**
 * x0 = source address. ldr x9,[x29,#home]; copy sz bytes x0 to x9 via x10;
 * mov x0,x9. @return 0 ok; 1 not applicable; -1 encoder fail.
 * PLATFORM: MACOS|ARM64.
 */
function w1521_rs_copy_to_dest(elf_ctx: *u8, home: i32, sz: i32): i32 {
  let k_u12: i32 = 0;
  if (home < 0 || home > 32760 || (home % 8) != 0 || sz <= 16 || sz > 32000) {
    return 1;
  }
  // ldr x9, [x29, #home]
  if (w1521_rs_a64(elf_ctx, 4181722025 + (((home / 8) as i64) << 10)) != 0) { return 0 - 1; }
  k_u12 = 0;
  while (k_u12 + 8 <= sz) {
    // ldr x10, [x0, #k] ; str x10, [x9, #k]
    if (w1521_rs_a64(elf_ctx, 4181721098 + (((k_u12 / 8) as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 4177527082 + (((k_u12 / 8) as i64) << 10)) != 0) { return 0 - 1; }
    k_u12 = k_u12 + 8;
  }
  while (k_u12 < sz) {
    // ldrb w10, [x0, #k] ; strb w10, [x9, #k]
    if (w1521_rs_a64(elf_ctx, 960495626 + ((k_u12 as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 956301610 + ((k_u12 as i64) << 10)) != 0) { return 0 - 1; }
    k_u12 = k_u12 + 1;
  }
  // mov x0, x9
  if (w1521_rs_a64(elf_ctx, 2852717536) != 0) { return 0 - 1; }
  return 0;
}

/**
 * x0 holds one element's address. Copy `width` bytes from x0 onto the
 * sret dest saved at [x29,#home], at byte dest_off, then leave that dest
 * pointer in x0. The frame slot itself stays one element wide: the next
 * element reuses it. width and dest_off are multiples of 8.
 * @param elf_ctx *u8 — encoder context
 * @param home i32 — nonnegative 8-byte-aligned slot of the saved x8
 * @param dest_off i32 — byte offset into the dest, multiple of 8
 * @param width i32 — byte count, multiple of 8
 * @return i32 — 0 copied; 1 home or size not applicable; -1 encoder fail
 * PLATFORM: MACOS|ARM64.
 */
function w1521_rs_copy_x0_to_dest_off(elf_ctx: *u8, home: i32, dest_off: i32, width: i32): i32 {
  let k_u13: i32 = 0;
  let d_u14: i32 = 0;
  if (home < 0 || home > 32760 || (home % 8) != 0) {
    return 1;
  }
  if (dest_off < 0 || width <= 0 || (dest_off % 8) != 0 || (width % 8) != 0) {
    return 1;
  }
  if (dest_off + width > 32760) {
    return 1;
  }
  // ldr x9, [x29, #home]
  if (w1521_rs_a64(elf_ctx, 4181722025 + (((home / 8) as i64) << 10)) != 0) { return 0 - 1; }
  k_u13 = 0;
  while (k_u13 + 8 <= width) {
    d_u14 = dest_off + k_u13;
    // ldr x10, [x0, #k] ; str x10, [x9, #d]
    if (w1521_rs_a64(elf_ctx, 4181721098 + (((k_u13 / 8) as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 4177527082 + (((d_u14 / 8) as i64) << 10)) != 0) { return 0 - 1; }
    k_u13 = k_u13 + 8;
  }
  // mov x0, x9
  if (w1521_rs_a64(elf_ctx, 2852717536) != 0) { return 0 - 1; }
  return 0;
}

/**
 * ldr x0, [x29, #home]. Reloads the sret dest so a later full-size copy
 * reads the dest itself. @param elf_ctx *u8 — encoder context.
 * @param home i32 — nonnegative 8-byte-aligned slot of the saved x8.
 * @return i32 — 0 loaded; 1 bad home; -1 encoder fail.
 * PLATFORM: MACOS|ARM64.
 */
function w1521_rs_load_dest_x0(elf_ctx: *u8, home: i32): i32 {
  if (home < 0 || home > 32760 || (home % 8) != 0) {
    return 1;
  }
  // ldr x0, [x29, #home]
  if (w1521_rs_a64(elf_ctx, 4181722016 + (((home / 8) as i64) << 10)) != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * 1 when ty is a named layout of 9 to 16 bytes.
 * That value travels in rax and rdx. Layouts of at most 8 bytes, and
 * any type whose layout size is not in that range, return 0 so the
 * scalar load stays in place.
 * @param arena *u8 — AST arena; null returns 0
 * @param ty i32 — type ref; <=0 returns 0
 * @return i32 — 1 when both words must be loaded, else 0
 * PLATFORM: SHARED — same pair on Windows, Linux, and macOS.
 */
function w1521_rs_ty_mid(arena: *u8, ty: i32): i32 {
  let k_u15: i32 = 0;
  let sz_u16: i32 = 0;
  if (arena == (0 as *u8) || ty <= 0) {
    return 0;
  }
  unsafe {
    k_u15 = pipeline_type_kind_ord_at(arena, ty);
  }
  if (k_u15 != 8) {
    return 0;
  }
  unsafe {
    sz_u16 = glue_type_named_layout_size_any_module_elf_c(arena, ty);
  }
  if (sz_u16 > 8 && sz_u16 <= 16) {
    return 1;
  }
  return 0;
}

/**
 * A FIELD or VAR return operand of a named layout of 9..16 bytes.
 * That value travels in rax and rdx. The scalar load keeps the low word
 * and leaves rdx holding the incoming argument pointer, so the Windows
 * epilogue stores that pointer as the high half. A call operand stays
 * on the ordinary expr path: the callee writes the pair. Layouts of at
 * most 8 bytes stay on the scalar load. Layouts above 16 stay on the
 * hidden-buffer copy.
 * The field's resolved type is checked first, then the struct-layout
 * field type. When neither is a 9..16 byte named layout, the function
 * return type is checked. On Windows the w1545 hidden-pointer latch is
 * the same fact the epilogue already trusts, so a latched slot also
 * selects the pair.
 * @param arena *u8 — AST arena; null returns 0
 * @param op i32 — return operand; not a field or local, or <=0, returns 0
 * @return i32 — 1 when the operand must be loaded as a 9..16 byte pair, else 0
 * PLATFORM: SHARED — Windows stores the pair through the hidden pointer;
 * Linux and macOS return the same pair in rax:rdx or x0:x1.
 */
function w1521_rs_mid_named_field(arena: *u8, op: i32): i32 {
  let ty_u17: i32 = 0;
  let k_u18: i32 = 0;
  let mod_u19: *u8 = 0 as *u8;
  let fi_u20: i32 = 0;
  let slot_u21: i32 = 0;
  if (arena == (0 as *u8) || op <= 0) {
    return 0;
  }
  unsafe {
    k_u18 = pipeline_expr_kind_ord_at(arena, op);
  }
  // EXPR_FIELD_ACCESS = 44. EXPR_VAR = 3. A call (48/49) is not an address.
  if (k_u18 != 44 && k_u18 != 3) {
    return 0;
  }
  if (k_u18 == 44) {
    unsafe {
      ty_u17 = pipeline_expr_resolved_type_ref(arena, op);
    }
    if (w1521_rs_ty_mid(arena, ty_u17) != 0) {
      return 1;
    }
    unsafe {
      mod_u19 = pipeline_asm_emit_module_ref_c();
      ty_u17 = glue_field_access_field_type_ref_c(arena, mod_u19, op);
    }
    if (w1521_rs_ty_mid(arena, ty_u17) != 0) {
      return 1;
    }
  }
  unsafe {
    mod_u19 = pipeline_asm_emit_module_ref_c();
    fi_u20 = pipeline_asm_emit_func_index_c();
  }
  if (mod_u19 == (0 as *u8) || fi_u20 < 0) {
    return 0;
  }
  unsafe {
    ty_u17 = pipeline_module_func_return_type_at(mod_u19, fi_u20);
  }
  if (w1521_rs_ty_mid(arena, ty_u17) != 0) {
    return 1;
  }
  // PLATFORM: WINDOWS — latch is set only for a 9..16 named result.
  // Off Windows the slot stays negative and this arm does not fire.
  unsafe {
    slot_u21 = w1545_win_ret_slot_for_c(mod_u19, fi_u20);
  }
  if (slot_u21 > 0) {
    return 1;
  }
  return 0;
}

/**
 * Byte offset of one parent FIELD on a wide-array return chain.
 * A non-FIELD expr returns -2: the caller treats it as the root.
 * A pointer field (type kind 9) returns -1 so the caller leaves the
 * chain on emit_expr. A missing offset, or an offset above 4095,
 * returns -1. The add-immediate that consumes the sum is 12 bits.
 * @param arena *u8 — AST arena; null is not valid
 * @param mod *u8 — module that owns the field layout
 * @param fa i32 — candidate parent expr; <=0 returns -2
 * @return i32 — 0..4095 offset, -2 stop, -1 reject
 * PLATFORM: MACOS|ARM64.
 */
function w635_rs_fold_parent(arena: *u8, mod: *u8, fa: i32): i32 {
  let k_u22: i32 = 0;
  let ty_u23: i32 = 0;
  let off_u24: i32 = 0;
  if (fa <= 0) {
    return 0 - 2;
  }
  unsafe {
    k_u22 = pipeline_expr_kind_ord_at(arena, fa);
  }
  if (k_u22 != 44) {
    return 0 - 2;
  }
  unsafe {
    ty_u23 = glue_field_access_field_type_ref_c(arena, mod, fa);
  }
  if (ty_u23 > 0) {
    unsafe {
      k_u22 = pipeline_type_kind_ord_at(arena, ty_u23);
    }
    // TYPE_POINTER = 9. Adding a byte offset to a pointer slot
    // writes the pointer variable, not the pointee.
    if (k_u22 == 9) {
      return 0 - 1;
    }
  }
  unsafe {
    off_u24 = glue_field_access_effective_offset_c(arena, mod, fa);
  }
  if (off_u24 < 0 || off_u24 > 4095) {
    return 0 - 1;
  }
  return off_u24;
}

/**
 * Base expr of a field access. A non-positive field returns 0.
 * The parent walk calls this from a while. Extern stays here:
 * this compiler drops an extern call written directly in a while.
 * @param arena *u8 — AST arena; null returns 0
 * @param fa i32 — FIELD expr; <=0 returns 0
 * @return i32 — base expr ref, or 0
 * PLATFORM: MACOS|ARM64.
 */
function w648_rs_base(arena: *u8, fa: i32): i32 {
  let nxt_u25: i32 = 0;
  if (arena == (0 as *u8) || fa <= 0) {
    return 0;
  }
  unsafe {
    nxt_u25 = pipeline_expr_field_access_base_ref(arena, fa);
  }
  return nxt_u25;
}

/**
 * Expr kind ordinal. The parent walk calls this from a while.
 * Extern stays here.
 * @param arena *u8 — AST arena; null returns 0
 * @param er i32 — expr ref; <=0 returns 0
 * @return i32 — kind ordinal, or 0
 * PLATFORM: MACOS|ARM64.
 */
function w648_rs_kind(arena: *u8, er: i32): i32 {
  let k_u26: i32 = 0;
  if (arena == (0 as *u8) || er <= 0) {
    return 0;
  }
  unsafe {
    k_u26 = pipeline_expr_kind_ord_at(arena, er);
  }
  return k_u26;
}

/**
 * Init expr of struct-literal field j when its name equals field fa.
 * A length mismatch or a different name returns 0. The byte compare
 * does not call out: this compiler drops extern calls inside while.
 * @param arena *u8 — AST arena; null returns 0
 * @param lit i32 — STRUCT_LIT expr; <=0 returns 0
 * @param fa i32 — FIELD expr whose name is compared; <=0 returns 0
 * @param j i32 — field index on the literal; <0 returns 0
 * @return i32 — init expr ref, or 0 when this slot is not fa
 * PLATFORM: MACOS|ARM64.
 */
function w639_rs_lit_init_at(arena: *u8, lit: i32, fa: i32, j: i32): i32 {
  let fa_nlen_u27: i32 = 0;
  let sl_nlen_u28: i32 = 0;
  let sl_eq_u29: i32 = 0;
  let sl_k_u30: i32 = 0;
  let init_u31: i32 = 0;
  let fa_name_u32: u8[256] = [];
  let sl_name_u33: u8[256] = [];
  if (arena == (0 as *u8) || lit <= 0 || fa <= 0 || j < 0) {
    return 0;
  }
  unsafe {
    fa_nlen_u27 = pipeline_expr_field_access_name_len(arena, fa);
    sl_nlen_u28 = pipeline_expr_struct_lit_field_name_len(arena, lit, j);
  }
  if (fa_nlen_u27 <= 0 || fa_nlen_u27 > 255 || sl_nlen_u28 != fa_nlen_u27) {
    return 0;
  }
  unsafe {
    pipeline_expr_field_access_name_into(arena, fa, &fa_name_u32[0]);
    pipeline_expr_struct_lit_field_name_into(arena, lit, j, &sl_name_u33[0]);
  }
  sl_eq_u29 = 1;
  sl_k_u30 = 0;
  while (sl_k_u30 < fa_nlen_u27) {
    if (fa_name_u32[sl_k_u30] != sl_name_u33[sl_k_u30]) {
      sl_eq_u29 = 0;
    }
    sl_k_u30 = sl_k_u30 + 1;
  }
  if (sl_eq_u29 == 0) {
    return 0;
  }
  unsafe {
    init_u31 = pipeline_expr_struct_lit_init_ref(arena, lit, j);
  }
  if (init_u31 <= 0) {
    return 0;
  }
  return init_u31;
}

/**
 * Init expr of the struct-literal field whose name equals fa.
 * Scans at most 64 fields. The loop calls the one-slot helper.
 * Extern stays in that helper: this compiler drops an extern call
 * written directly in a while. A match past slot 63 returns 0, and
 * the caller stays on emit_expr. A null arena, a non-positive
 * literal, or a non-positive field returns 0.
 * @param arena *u8 — AST arena; null returns 0
 * @param lit i32 — STRUCT_LIT expr; <=0 returns 0
 * @param fa i32 — FIELD expr whose name is compared; <=0 returns 0
 * @return i32 — init expr ref, or 0 when no scanned slot matches
 * PLATFORM: MACOS|ARM64.
 */
function w643_rs_named_init(arena: *u8, lit: i32, fa: i32): i32 {
  let n_u34: i32 = 0;
  let init_u35: i32 = 0;
  let j_u36: i32 = 0;
  if (arena == (0 as *u8) || lit <= 0 || fa <= 0) {
    return 0;
  }
  unsafe {
    n_u34 = pipeline_expr_struct_lit_num_fields(arena, lit);
  }
  if (n_u34 <= 0) {
    return 0;
  }
  if (n_u34 > 64) {
    n_u34 = 64;
  }
  while (j_u36 < n_u34) {
    if (init_u35 == 0) {
      init_u35 = w639_rs_lit_init_at(arena, lit, fa, j_u36);
    }
    j_u36 = j_u36 + 1;
  }
  return init_u35;
}

/**
 * Add one field's byte offset onto acc.
 * A missing offset, a negative offset, or a sum above 4095 returns
 * -1. The add-immediate that consumes the sum is 12 bits. A
 * non-positive field returns -1. Does not emit.
 * @param arena *u8 — AST arena; null returns -1
 * @param mod *u8 — module that owns the field layout; null returns -1
 * @param fa i32 — FIELD expr; <=0 returns -1
 * @param acc i32 — offset so far; negative returns -1
 * @return i32 — acc + field offset, or -1
 * PLATFORM: MACOS|ARM64.
 */
function w645_rs_acc_field_off(arena: *u8, mod: *u8, fa: i32, acc: i32): i32 {
  let hop_u37: i32 = 0;
  if (arena == (0 as *u8) || mod == (0 as *u8) || fa <= 0 || acc < 0) {
    return 0 - 1;
  }
  unsafe {
    hop_u37 = glue_field_access_effective_offset_c(arena, mod, fa);
  }
  if (hop_u37 < 0 || hop_u37 > 4095) {
    return 0 - 1;
  }
  if (acc > (4095 - hop_u37)) {
    return 0 - 1;
  }
  return acc + hop_u37;
}

/**
 * Address of a local struct used as a struct-literal field init,
 * plus the offsets of the fields inside that local.
 * f_leaf is the returned field. inner[0 .. n_inner) are the fields
 * between that local and the leaf, closest to the leaf first.
 * The field whose init is the local is not included: that offset
 * sits in the literal, not in the local. A pointer or slice local
 * returns 1 so the caller stays on emit_expr. A failed lvalue
 * returns 1. An encoder error returns -1. n_inner above 4096 is
 * declined. The offset loop calls the one-field helper.
 * EXPR_VAR = 3. TYPE_POINTER = 9. TYPE_SLICE = 11.
 * @param arena *u8 — AST arena; null returns 1
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — asm function context
 * @param ta i32 — 1 arm64
 * @param mod *u8 — module that owns the field layout; null returns 1
 * @param var_er i32 — VAR init expr; <=0 returns 1
 * @param f_leaf i32 — returned FIELD; <=0 returns 1
 * @param inner *i32 — closer FIELD refs; null is allowed when n_inner is 0
 * @param n_inner i32 — how many closer fields to add; negative returns 1
 * @return i32 — 0 address in x0; 1 decline; -1 encoder fail
 * PLATFORM: MACOS|ARM64.
 */
function w648_rs_lea_chain(
  arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, mod: *u8,
  var_er: i32, f_leaf: i32, inner: *i32, n_inner: i32
): i32 {
  let off_u38: i32 = 0;
  let ty_u39: i32 = 0;
  let k_u40: i32 = 0;
  let rc_u41: i32 = 0;
  let i_u42: i32 = 0;
  if (var_er <= 0 || f_leaf <= 0 || mod == (0 as *u8) || n_inner < 0 || n_inner > 4096) {
    return 1;
  }
  if (n_inner > 0 && inner == (0 as *i32)) {
    return 1;
  }
  unsafe {
    ty_u39 = glue_var_decl_type_ref_elf_c(arena, ctx, var_er);
  }
  if (ty_u39 > 0) {
    unsafe {
      k_u40 = pipeline_type_kind_ord_at(arena, ty_u39);
    }
    if (k_u40 == 9 || k_u40 == 11) {
      return 1;
    }
  }
  off_u38 = w645_rs_acc_field_off(arena, mod, f_leaf, 0);
  while (i_u42 < n_inner && off_u38 >= 0) {
    off_u38 = w645_rs_acc_field_off(arena, mod, inner[i_u42], off_u38);
    i_u42 = i_u42 + 1;
  }
  if (off_u38 < 0) {
    return 1;
  }
  unsafe {
    rc_u41 = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, var_er, ctx, ta);
  }
  if (rc_u41 != 0) {
    return 1;
  }
  if (off_u38 != 0) {
    unsafe {
      rc_u41 = backend_enc_add_imm_to_rax_arch(elf_ctx, off_u38, ta);
    }
    if (rc_u41 != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * EXPR_RETURN ELF emit: operand into rax/x0, arm64 sret copy, then jmp
 * function tail_join (AsmFuncCtxLayout name at 1392, length at 1520).
 * A 9..16 byte named field is loaded with pipeline_asm_deref_struct16
 * so both words are in rax and rdx before the epilogue.
 * An ARRAY_LIT operand whose function return type is TYPE_ARRAY calls
 * glue_asm_emit_array_lit_durable_ptr_rax_elf_c first. Success leaves a
 * durable element pointer in rax/x0 and skips emit_expr. When that array's
 * element is a TYPE_VECTOR of i32 wider than 16 bytes, each element is
 * filled by glue_emit_vector_type_let_init_elf_c into one element slot
 * and copied to the sret dest at i * width. A VAR or FIELD element is
 * not that fill: vector let-init returns -3 and emits nothing. The
 * address of the local, the field, the indexed element, or the
 * pointee of a DEREF is copied the same width. A lane index is i32
 * and does not enter this arm. A DEREF element (*Vec8i) copies the
 * pointee address that lvalue leaves in x0. It does not store through
 * the pointer. Vector let-init still declines a DEREF wider than 16
 * bytes. A CALL or METHOD element is filled by
 * glue_emit_struct_type_let_init_elf_c into that same one-vector
 * slot, then copied the same width. Vector let-init still declines
 * a CALL or METHOD wider than 16 bytes.
 * The slot stays one element wide. A miss leaves that element and
 * still returns the dest. An encoder miss returns -1. It does not
 * fall through to the 8-byte load.
 * Any other result falls through to emit_expr. A VAR return of a small array is unchanged
 * when the function return type is TYPE_ARRAY (the value stays in rax/x0).
 * A VAR whose declared type is TYPE_ARRAY, returned as TYPE_SLICE, leas
 * that slot and moves the element count into x1 (arm64) or rdx (SysV).
 * An indirect parameter slot holds the caller's pointer, so that
 * pointer is loaded before the length move. A local slot is not loaded.
 * A FIELD whose base is a VAR, whose field type is TYPE_ARRAY, and whose
 * function returns TYPE_SLICE leas the struct slot plus the field
 * offset and then moves the element count into x1 (arm64) or rdx
 * (SysV). emit_expr of an 8-byte field loads the value, and the caller
 * then reads that value as a pointer. The same FIELD, when the function
 * returns a TYPE_ARRAY wider than 16 bytes, leas that address into x0
 * and skips emit_expr. A local VAR of that array already leaves its
 * address there. emit_expr of the field loads the first qword, and
 * `return w.xs` of [2]S24 hands the caller 5 and 6 as a pointer (SIGBUS).
 * A payload of 16 bytes or less stays on emit_expr. A chain of value
 * fields (`return o.inn.xs`) adds each field offset onto that same
 * local slot. A pointer field, a pointer root, or a chain longer
 * than four thousand ninety-six parents stays on emit_expr. A FIELD whose root is a
 * STRUCT_LIT durables an ARRAY_LIT init, or takes the address of a
 * VAR init. A parent field (`return { inn: { xs: [...] } }.inn.xs`)
 * walks a STRUCT_LIT init. A parent whose init is a local struct
 * (`return { inn: src }.inn.xs`) takes that local's address plus
 * the fields inside it, not the literal's own field offset. The
 * walk is at most four thousand ninety-six parents. Any other STRUCT_LIT init stays on
 * emit_expr.
 * A FIELD whose type is TYPE_NAMED, whose return is wider than 16
 * bytes, and whose base is INDEX (`return a[1].s`) leas that element
 * and adds the field offset. A local `return w.s` already leaves the
 * address. A pointer or slice element stays on emit_expr.
 * An INDEX of a VAR whose declared type is TYPE_ARRAY, whose element
 * type is also TYPE_ARRAY, and whose function returns TYPE_SLICE calls
 * emit_expr once (that already leaves the row address in rax/x0) and
 * then moves that row's element count into x1 (arm64) or rdx (SysV).
 * The same INDEX, when the function returns an 8-byte TYPE_ARRAY,
 * loads that qword into rax/x0. The caller stores x0 as the value.
 * A wider TYPE_ARRAY stays on emit_expr. A non-VAR index base, or an
 * element that is not TYPE_ARRAY, stays on emit_expr.
 * An ARRAY_LIT whose return type is TYPE_SLICE, after the existing
 * ARRAY/SLICE ascription peel, uses that same helper and then moves the
 * element count into x1 (arm64) or rdx (SysV). Windows keeps emit_expr.
 * A length-register failure after a successful durable emit returns -1.
 * A named i32x4, f32x4, or u32x4 ARRAY_LIT is kind 8, so it misses
 * the kind-10 arm. User u32x4 is that kind-8 name. The same durable
 * helper writes 4-byte lanes. Float literals pack as f32 bits in
 * that helper when the element kind is not f32 or f64. The 16-byte
 * pair load then leaves the payload in x0 and x1. User f32x4 and
 * Vec4f are kind 13 of f32 and size 16, so they use the same helper.
 * A lane binop does not enter. A name ending in 8 stays on emit_expr.
 * Darwin sret of a named SIMD (kind 8) wider than 16 bytes, whose
 * operand is an INT_LIT, a FLOAT_LIT, a BOOL_LIT, a kind-22 chain,
 * a kind-23 chain, or a lane binop, fills that value with
 * glue_emit_vector_type_let_init_elf_c into a temp and leas the temp
 * into x0 before the copy. A kind-13 i32 vector uses that same fill
 * for a lane binop. A 16-byte return does not enter. Kind-13 f32
 * elements do not enter. Let-init -3 falls through. BOOL_LIT and
 * kind 23 on an f32 fill stay integer bits.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — ELF codegen context; null returns -1
 * @param expr_ref i32 — EXPR_RETURN; <=0 returns -1
 * @param ctx *u8 — AsmFuncCtx; null returns -1
 * @param ta i32 — target arch token
 * @return i32 — 0 ok; -1 encoder, null, or missing tail_join
 * PLATFORM: MACOS|ARM64 · LINUX x86_64 · WINDOWS x86_64.
 */
#[no_mangle]
export function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let ly_u43: *u8 = 0 as *u8;
  let ret_op_u44: i32 = 0;
  let rc_u45: i32 = 0;
  let tj_len_u46: i32 = 0;
  let tj_lbl_u47: u8[256] = [];
  let ti_u48: i32 = 0;
  let act_u49: i32 = 0;
  let home_u50: i32 = 0 - 1;
  let rsz_u51: i32 = 0;
  /* 1 when a wide i32-vector array already copied each element to *x8. */
  let wide_copied_u52: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ly_u43 = pipeline_asm_ctx_layout(ctx);
    ret_op_u44 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (ret_op_u44 != 0) {
    let x86_off_u53: i32 = 0 - 1;
    let x86_fwd_u54: i32 = 0;
    let opk_u55: i32 = 0;
    let win_forced_u56: i32 = 0;
    if (ta == 0) {
      unsafe {
        act_u49 = pipeline_asm_emit_ctx_sret_active_get();
        home_u50 = pipeline_asm_emit_ctx_sret_home_off_get();
        rsz_u51 = pipeline_asm_emit_ctx_sret_ret_sz_get();
        if (act_u49 != 0 && home_u50 > 0 && rsz_u51 >= 16) {
          x86_off_u53 = w1521_rs_local_off(arena, ctx, ret_op_u44);
          opk_u55 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
          if (opk_u55 == 48 || opk_u55 == 49) {
            x86_fwd_u54 = 1;
          }
        }
      }
      /* w1046 (10.46): Win64 >=16B return of VAR(3)/FIELD(44) must memcpy
       * into the hidden *rcx home_u50. Force lvalue + rs_copy before mid/else.
       * PLATFORM: WINDOWS. */
      if (act_u49 != 0 && home_u50 > 0 && rsz_u51 >= 16 && x86_fwd_u54 == 0) {
        let on_win_a_u57: i32 = 0;
        unsafe {
          on_win_a_u57 = link_abi_host_is_windows();
        }
        if (on_win_a_u57 != 0) {
          if (opk_u55 == 0) {
            unsafe {
              opk_u55 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
            }
          }
          if (opk_u55 == 3 || opk_u55 == 44) {
            unsafe {
              rc_u45 = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, ret_op_u44, ctx, ta);
            }
            if (rc_u45 == 0) {
              if (w1521_rs_copy_x86(elf_ctx, home_u50, rsz_u51) < 0) {
                return 0 - 1;
              }
              win_forced_u56 = 1;
            }
          }
        }
      }
    }
    if (win_forced_u56 != 0) {
      rc_u45 = 0;
    } else if (x86_fwd_u54 != 0) {
      if (w1521_rs_fwd_call_x86(arena, elf_ctx, ret_op_u44, ctx, ta, home_u50) != 0) {
        return 0 - 1;
      }
    } else if (x86_off_u53 >= 0) {
      unsafe {
        rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, x86_off_u53, ta);
      }
      if (rc_u45 != 0) {
        return 0 - 1;
      }
      if (w1521_rs_copy_x86(elf_ctx, home_u50, rsz_u51) < 0) {
        return 0 - 1;
      }
    } else if (w1521_rs_mid_named_field(arena, ret_op_u44) != 0) {
      // Address of the field or local, then the existing 16-byte pair load.
      // A failed address falls through to the scalar expr path. Do not
      // scalar-load a successful address: that drops the high word.
      // PLATFORM: SHARED.
      unsafe {
        rc_u45 = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, ret_op_u44, ctx, ta);
      }
      if (rc_u45 == 0) {
        unsafe {
          rc_u45 = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
        }
        if (rc_u45 != 0) {
          return 0 - 1;
        }
      } else {
        unsafe {
          rc_u45 = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op_u44, ctx, ta);
        }
        if (rc_u45 != 0) {
          return 0 - 1;
        }
      }
    } else {
      // ARRAY_LIT returned as TYPE_ARRAY is packed by the durable helper
      // so the bytes are not a callee frame slot. An 8-byte aggregate
      // (and a 16-byte pair on SysV / AAPCS64) is then loaded back into
      // the return registers: that is the same value ABI as `return t`
      // of a local array. A slice cell copies those register bytes into
      // its own COMMON. Larger returns stay the durable pointer for the
      // sret copy below. Windows keeps a 16-byte aggregate as the pointer
      // (hidden dest). A non-zero durable result falls through to emit_expr.
      // A VAR whose function return type is TYPE_ARRAY stays on the value
      // path. A VAR whose declared type is TYPE_ARRAY and whose function
      // returns TYPE_SLICE is the arm below the ARRAY_LIT slice arm.
      // PLATFORM: SHARED — LINUX|x86_64 · MACOS|ARM64 · WINDOWS 8-byte
      // value, 16-byte pointer.
      let dur_ok_u58: i32 = 0;
      let opk_d_u59: i32 = 0;
      let mod_d_u60: *u8 = 0 as *u8;
      let fi_d_u61: i32 = 0;
      let rty_d_u62: i32 = 0;
      let rk_d_u63: i32 = 0;
      let elem_d_u64: i32 = 0;
      let esz_d_u65: i32 = 0;
      let peel_d_u66: i32 = 0;
      let n_d_u67: i32 = 0;
      let len_reg_u68: i32 = 0;
      let win_d_u69: i32 = 0;
      let decl_ty_u70: i32 = 0;
      let arr_off_u71: i32 = 0;
      let base_er_u72: i32 = 0;
      let sl_nf_u73: i32 = 0;
      let sl_i_u74: i32 = 0;
      let sl_init_u75: i32 = 0;
      let fa_nlen_u76: i32 = 0;
      let sl_nlen_u77: i32 = 0;
      let sl_eq_u78: i32 = 0;
      let sl_k_u79: i32 = 0;
      let fa_name_u80: u8[256] = [];
      let sl_name_u81: u8[256] = [];
      let v_slot_u82: i32 = 0;
      let v_rc_u83: i32 = 0;
      let v_mod_u84: *u8 = 0 as *u8;
      let v_fi_u85: i32 = 0;
      let v_rty_u86: i32 = 0;
      let v_rk_u87: i32 = 0;
      let v_elem_u88: i32 = 0;
      let v_ek_u89: i32 = 0;
      let v_opk_u90: i32 = 0;
      let v_go_u91: i32 = 0;
      let v_go8_u92: i32 = 0;
      let v_enter_u93: i32 = 0;
      let v_take_u94: i32 = 0;
      let v_bin_u95: i32 = 0;
      let v_cmp_u96: i32 = 0;
      let vec_hit_u97: i32 = 0;
      if (ta == 0 || ta == 1) {
        unsafe {
          opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
        }
        if (opk_d_u59 == 46) {
          unsafe {
            mod_d_u60 = pipeline_asm_emit_module_ref_c();
            fi_d_u61 = pipeline_asm_emit_func_index_c();
          }
          if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
            unsafe {
              rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
            }
            if (rty_d_u62 > 0) {
              unsafe {
                rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
              }
              // TYPE_ARRAY = 10. TYPE_SLICE is the arm below.
              if (rk_d_u63 == 10) {
                let wide_bytes_u98: i32 = 0;
                let wide_n_u99: i32 = 0;
                let wide_w_u100: i32 = 0;
                let wide_i_u101: i32 = 0;
                let wide_slot_u102: i32 = 0;
                let wide_er_u103: i32 = 0;
                let wide_rc_u104: i32 = 0;
                let wide_off_u105: i32 = 0;
                let wide_src_u106: i32 = 0;
                /*
                 * [N]Vec8i is wider than 16 bytes. The frame temp is one
                 * vector. Fill that slot, take a VAR, FIELD, INDEX, or
                 * DEREF address, or let a CALL or METHOD write the slot,
                 * then copy width bytes to the sret dest at i * width.
                 * The index is one element of this array, not one lane.
                 * A *Vec8i deref copies that whole pointee. It does not
                 * store through the pointer. A miss leaves that element.
                 * Do not fall through to the 8-byte load.
                 * PLATFORM: SHARED. The copy encoding is MACOS|ARM64
                 * or LINUX x86_64.
                 */
                unsafe {
                  wide_bytes_u98 = glue_wide_i32_vec_array_bytes(arena, rty_d_u62);
                }
                if (wide_bytes_u98 > 16) {
                  unsafe {
                    elem_d_u64 = pipeline_type_elem_ref_at(arena, rty_d_u62);
                    wide_n_u99 = pipeline_type_array_size_at(arena, rty_d_u62);
                    wide_w_u100 = glue_index_simd_elem_bytes_c(arena, elem_d_u64);
                  }
                  if (wide_n_u99 <= 0 || wide_w_u100 <= 16 || wide_n_u99 * wide_w_u100 != wide_bytes_u98) {
                    return 0 - 1;
                  }
                  // Same array type the frame walker reserved. Use only
                  // the base: the second element must not be slot+width.
                  unsafe {
                    wide_slot_u102 = glue_simd_alloc_vector_temp_slot_c(arena, ctx, rty_d_u62);
                  }
                  if (wide_slot_u102 < 0) {
                    return 0 - 1;
                  }
                  if (ta == 1) {
                    unsafe {
                      act_u49 = pipeline_asm_emit_ctx_sret_active_get();
                      home_u50 = pipeline_asm_emit_ctx_sret_home_off_get();
                      rsz_u51 = pipeline_asm_emit_ctx_sret_ret_sz_get();
                    }
                  }
                  wide_i_u101 = 0;
                  while (wide_i_u101 < wide_n_u99) {
                    unsafe {
                      wide_er_u103 = pipeline_expr_array_lit_elem_ref(arena, ret_op_u44, wide_i_u101);
                    }
                    if (wide_er_u103 > 0) {
                      wide_src_u106 = 0;
                      unsafe {
                        wide_rc_u104 = pipeline_expr_kind_ord_at(arena, wide_er_u103);
                      }
                      // EXPR_VAR = 3. EXPR_FIELD = 44. EXPR_INDEX = 47.
                      // EXPR_DEREF = 52. EXPR_CALL = 48. EXPR_METHOD = 49.
                      // Vector let-init returns -3 for a bare VAR and for
                      // a CALL, METHOD, or DEREF wider than 16 bytes, and
                      // emits nothing. VAR, FIELD, INDEX, and DEREF copy
                      // from the address lvalue leaves in x0. A *Vec8i
                      // deref is that pointee address, not a store through
                      // the pointer. CALL and METHOD reuse the struct
                      // let-init that already fills one vector slot for an
                      // array let. A lane index is i32 and is rejected
                      // before emit. PLATFORM: SHARED.
                      if (wide_rc_u104 == 48 || wide_rc_u104 == 49) {
                        unsafe {
                          wide_rc_u104 = glue_emit_struct_type_let_init_elf_c(
                            arena, elf_ctx, wide_er_u103, ctx, ta, elem_d_u64, wide_slot_u102);
                        }
                        if (wide_rc_u104 == 0) {
                          unsafe {
                            rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, wide_slot_u102, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                          wide_src_u106 = 1;
                        } else {
                          if (wide_rc_u104 == (0 - 1)) {
                            return 0 - 1;
                          }
                        }
                      } else {
                        if (wide_rc_u104 == 3 || wide_rc_u104 == 44 || wide_rc_u104 == 47 || wide_rc_u104 == 52) {
                          unsafe {
                            rc_u45 = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                              arena, elf_ctx, wide_er_u103, ctx, ta);
                          }
                          if (rc_u45 == 0) {
                            wide_src_u106 = 1;
                          }
                        } else {
                          unsafe {
                            wide_rc_u104 = glue_emit_vector_type_let_init_elf_c(
                              arena, elf_ctx, wide_er_u103, ctx, ta, wide_slot_u102, elem_d_u64);
                          }
                          if (wide_rc_u104 == 0) {
                            unsafe {
                              rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, wide_slot_u102, ta);
                            }
                            if (rc_u45 != 0) {
                              return 0 - 1;
                            }
                            wide_src_u106 = 1;
                          }
                        }
                      }
                      if (wide_src_u106 == 1) {
                        wide_off_u105 = wide_i_u101 * wide_w_u100;
                        if (ta == 1) {
                          wide_rc_u104 = w1521_rs_copy_x0_to_dest_off(elf_ctx, home_u50, wide_off_u105, wide_w_u100);
                        } else {
                          wide_rc_u104 = w1521_rs_copy_x86_off(elf_ctx, home_u50, wide_off_u105, wide_w_u100);
                        }
                        if (wide_rc_u104 < 0) {
                          return 0 - 1;
                        }
                      }
                    }
                    wide_i_u101 = wide_i_u101 + 1;
                  }
                  wide_copied_u52 = 1;
                  dur_ok_u58 = 1;
                } else {
                unsafe {
                  elem_d_u64 = pipeline_type_elem_ref_at(arena, rty_d_u62);
                  esz_d_u65 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d_u64);
                  rc_u45 = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op_u44, esz_d_u65, ta, ctx, elem_d_u64);
                }
                if (rc_u45 == 0) {
                  dur_ok_u58 = 1;
                  // n * esz is the width the durable helper just wrote.
                  // 8 → one GPR. 16 → the existing pair load, except
                  // Windows (hidden pointer). Do not load a wider page:
                  // rsz >= 16 still uses the sret copy below.
                  // PLATFORM: SHARED — LINUX|x86_64 · MACOS|ARM64.
                  let nbytes_d_u107: i32 = 0;
                  let an_d_u108: i32 = 0;
                  let win_sz_u109: i32 = 0;
                  unsafe {
                    an_d_u108 = pipeline_type_array_size_at(arena, rty_d_u62);
                  }
                  if (an_d_u108 > 0 && esz_d_u65 > 0) {
                    nbytes_d_u107 = an_d_u108 * esz_d_u65;
                  }
                  if (nbytes_d_u107 == 16 && ta == 0) {
                    unsafe {
                      win_sz_u109 = link_abi_host_is_windows();
                    }
                  }
                  if (nbytes_d_u107 == 8 || (nbytes_d_u107 == 16 && win_sz_u109 == 0)) {
                    if (nbytes_d_u107 == 8) {
                      unsafe {
                        rc_u45 = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                      }
                    } else {
                      unsafe {
                        rc_u45 = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
                      }
                    }
                    if (rc_u45 != 0) {
                      return 0 - 1;
                    }
                  }
                }
                }
              }
              // Named i32x4, f32x4, or u32x4, or a 16-byte TYPE_VECTOR
              // whose element is f32. Kind 10 already loads a 16-byte
              // array into x0 and x1. A named spelling is kind 8, so
              // it missed that arm. User u32x4 is that kind-8 name.
              // User f32x4 is kind 13 of f32, so the name test missed
              // it too. Same durable helper (4-byte lanes), then the
              // same pair load, while the slot is live. A lane binop
              // does not enter. A name ending in 8 is wider than 16.
              // Kind-13 integer vectors stay on emit_expr.
              // PLATFORM: MACOS|ARM64.
              if (rk_d_u63 == 8) {
                let nb_u110: u8[8] = [];
                let nl_u111: i32 = 0;
                let hit_u112: i32 = 0;
                unsafe {
                  nl_u111 = pipeline_type_named_name_into(arena, rty_d_u62, &nb_u110[0]);
                }
                if (nl_u111 == 5) {
                  if (nb_u110[1] == 51) {
                    if (nb_u110[2] == 50) {
                      if (nb_u110[3] == 120) {
                        if (nb_u110[4] == 52) {
                          if (nb_u110[0] == 105) {
                            hit_u112 = 1;
                          }
                          if (nb_u110[0] == 102) {
                            hit_u112 = 1;
                          }
                          if (nb_u110[0] == 117) {
                            hit_u112 = 1;
                          }
                        }
                      }
                    }
                  }
                }
                if (hit_u112 != 0) {
                  vec_hit_u97 = 1;
                }
              }
              if (rk_d_u63 == 13) {
                let f32v_u113: i32 = 0;
                let vsz_u114: i32 = 0;
                unsafe {
                  f32v_u113 = glue_vector_elem_is_f32_c(arena, rty_d_u62);
                }
                if (f32v_u113 != 0) {
                  unsafe {
                    vsz_u114 = glue_type_size_simple(mod_d_u60, arena, rty_d_u62, 0);
                  }
                  if (vsz_u114 == 16) {
                    vec_hit_u97 = 1;
                  }
                }
              }
              if (vec_hit_u97 != 0) {
                if (ta == 1) {
                  unsafe {
                    rc_u45 = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(
                      arena, elf_ctx, ret_op_u44, 4, ta, ctx, 0);
                  }
                  if (rc_u45 == 0) {
                    unsafe {
                      rc_u45 = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
                    }
                    if (rc_u45 != 0) {
                      return 0 - 1;
                    }
                    dur_ok_u58 = 1;
                  }
                }
              }
            }
          }
        }
      }
      // TYPE_SLICE return of an ARRAY_LIT (bare or `as []T`) must leave
      // the durable data pointer in rax/x0 and the element count in x1
      // (arm64) or rdx (SysV arg reg 2). emit_expr of the ascription
      // writes the ints over the callee frame and returns that address
      // with no length, so the caller copies a dead slot (SIGSEGV).
      // Peel is the existing helper. Windows 16-byte returns stay on
      // emit_expr. PLATFORM: MACOS|ARM64 · LINUX x86_64.
      if (dur_ok_u58 == 0 && (ta == 0 || ta == 1)) {
        if (ta == 0) {
          unsafe {
            win_d_u69 = link_abi_host_is_windows();
          }
        }
        if (win_d_u69 == 0) {
          unsafe {
            peel_d_u66 = glue_peel_as_array_slice_ascription_c(arena, ret_op_u44);
          }
          if (peel_d_u66 <= 0) {
            peel_d_u66 = ret_op_u44;
          }
          unsafe {
            opk_d_u59 = pipeline_expr_kind_ord_at(arena, peel_d_u66);
          }
          if (opk_d_u59 == 46) {
            unsafe {
              mod_d_u60 = pipeline_asm_emit_module_ref_c();
              fi_d_u61 = pipeline_asm_emit_func_index_c();
            }
            if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
              unsafe {
                rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
              }
              if (rty_d_u62 > 0) {
                unsafe {
                  rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
                }
                // TYPE_SLICE = 11. TYPE_ARRAY stays on the arm above.
                if (rk_d_u63 == 11) {
                  unsafe {
                    n_d_u67 = pipeline_expr_array_lit_num_elems_at(arena, peel_d_u66);
                    elem_d_u64 = pipeline_type_elem_ref_at(arena, rty_d_u62);
                    esz_d_u65 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d_u64);
                  }
                  if (n_d_u67 >= 0 && n_d_u67 <= 1024) {
                    unsafe {
                      rc_u45 = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, peel_d_u66, esz_d_u65, ta, ctx, elem_d_u64);
                    }
                    if (rc_u45 == 0) {
                      unsafe {
                        rc_u45 = backend_enc_push_rax_arch(elf_ctx, ta);
                      }
                      if (rc_u45 != 0) {
                        return 0 - 1;
                      }
                      unsafe {
                        rc_u45 = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d_u67, 0, ta);
                      }
                      if (rc_u45 != 0) {
                        return 0 - 1;
                      }
                      if (ta == 1) {
                        len_reg_u68 = 1;
                      } else {
                        len_reg_u68 = 2;
                      }
                      unsafe {
                        rc_u45 = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg_u68, ta);
                      }
                      if (rc_u45 != 0) {
                        return 0 - 1;
                      }
                      unsafe {
                        rc_u45 = backend_enc_pop_rax_arch(elf_ctx, ta);
                      }
                      if (rc_u45 != 0) {
                        return 0 - 1;
                      }
                      dur_ok_u58 = 1;
                    }
                  }
                }
              }
            }
          }
          // VAR of a local TYPE_ARRAY returned as TYPE_SLICE. emit_expr
          // loads the inline bytes into x0, which is the value ABI of a
          // [N]T return, and leaves x1 holding the address used to store
          // those bytes. The caller reads x1 as the slice length, so
          // ret_array_as_slice returns 1. Lea the slot and put N in x1
          // (arm64) or rdx (SysV). The caller's stack-escape copier
          // mallocs when that pointer is below sp. A TYPE_ARRAY return
          // stays on the value path. A slice variable stays on emit_expr.
          // A field whose base is a VAR is the next arm. A STRUCT_LIT
          // field stays on emit_expr. Windows stays on emit_expr.
          // PLATFORM: MACOS|ARM64 · LINUX x86_64.
          if (dur_ok_u58 == 0) {
            unsafe {
              opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
            }
            if (opk_d_u59 == 3) {
              unsafe {
                mod_d_u60 = pipeline_asm_emit_module_ref_c();
                fi_d_u61 = pipeline_asm_emit_func_index_c();
              }
              if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
                unsafe {
                  rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
                }
                if (rty_d_u62 > 0) {
                  unsafe {
                    rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
                  }
                  // TYPE_SLICE = 11. TYPE_ARRAY = 10 stays on emit_expr.
                  if (rk_d_u63 == 11) {
                    unsafe {
                      decl_ty_u70 = glue_var_decl_type_ref_elf_c(arena, ctx, ret_op_u44);
                    }
                    if (decl_ty_u70 > 0) {
                      unsafe {
                        rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                      }
                      if (rk_d_u63 == 10) {
                        unsafe {
                          n_d_u67 = pipeline_type_array_size_at(arena, decl_ty_u70);
                          arr_off_u71 = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op_u44);
                        }
                        // Negative offsets are the x86 "not this slot"
                        // miss used by the sret local arm. Darwin locals
                        // are a non-negative addend from x29.
                        // A parameter [N]T is an indirect slot: the slot
                        // holds the caller's pointer, so lea would make
                        // the slice view the pointer bits (`as_slc` then
                        // sees v[0] != 10). Load that pointer. A local
                        // slot holds the elements, so lea stays.
                        // PLATFORM: MACOS|ARM64 · LINUX x86_64.
                        if (n_d_u67 >= 0 && n_d_u67 <= 1024 && arr_off_u71 >= 0) {
                          unsafe {
                            rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off_u71, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                          unsafe {
                            peel_d_u66 = glue_emit_func_param_is_indirect_array_slot_c(arena, mod_d_u60, ret_op_u44);
                          }
                          if (peel_d_u66 != 0) {
                            unsafe {
                              rc_u45 = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                            }
                            if (rc_u45 != 0) {
                              return 0 - 1;
                            }
                          }
                          unsafe {
                            rc_u45 = backend_enc_push_rax_arch(elf_ctx, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                          unsafe {
                            rc_u45 = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d_u67, 0, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                          if (ta == 1) {
                            len_reg_u68 = 1;
                          } else {
                            len_reg_u68 = 2;
                          }
                          unsafe {
                            rc_u45 = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg_u68, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                          unsafe {
                            rc_u45 = backend_enc_pop_rax_arch(elf_ctx, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                          dur_ok_u58 = 1;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          // VAR of a slice parameter. The slot holds the caller's
          // pointer to {data, len}. emit_expr returns that pointer and
          // leaves x1 stale, so the caller stores the wrong length.
          // Load both words through the pointer. A local slice is
          // already the fat pair and stays on emit_expr.
          // PLATFORM: MACOS|ARM64 · LINUX x86_64.
          if (dur_ok_u58 == 0) {
            unsafe {
              opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
            }
            if (opk_d_u59 == 3) {
              unsafe {
                mod_d_u60 = pipeline_asm_emit_module_ref_c();
                fi_d_u61 = pipeline_asm_emit_func_index_c();
              }
              if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
                unsafe {
                  rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
                }
                if (rty_d_u62 > 0) {
                  unsafe {
                    rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
                  }
                  if (rk_d_u63 == 11) {
                    unsafe {
                      decl_ty_u70 = glue_var_decl_type_ref_elf_c(arena, ctx, ret_op_u44);
                    }
                    if (decl_ty_u70 > 0) {
                      unsafe {
                        rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                      }
                      if (rk_d_u63 == 11) {
                        let sl_nm_u115: u8[256] = [];
                        let sl_n_u116: i32 = 0;
                        let sl_pty_u117: i32 = 0;
                        unsafe {
                          sl_n_u116 = pipeline_expr_var_name_len(arena, ret_op_u44);
                        }
                        if (sl_n_u116 > 0 && sl_n_u116 <= 255) {
                          unsafe {
                            pipeline_expr_var_name_into(arena, ret_op_u44, &sl_nm_u115[0]);
                          }
                          unsafe {
                            sl_pty_u117 = pipeline_module_func_param_type_ref_for_name(
                              mod_d_u60, fi_d_u61, &sl_nm_u115[0], pipeline_expr_var_name_len(arena, ret_op_u44));
                          }
                          if (sl_pty_u117 > 0) {
                            unsafe {
                              rk_d_u63 = pipeline_type_kind_ord_at(arena, sl_pty_u117);
                            }
                            if (rk_d_u63 == 11) {
                              unsafe {
                                arr_off_u71 = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op_u44);
                              }
                              if (arr_off_u71 >= 0) {
                                unsafe {
                                  rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off_u71, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_push_rax_arch(elf_ctx, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                if (ta == 1) {
                                  len_reg_u68 = 1;
                                } else {
                                  len_reg_u68 = 2;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg_u68, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_pop_rax_arch(elf_ctx, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc_u45 = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                dur_ok_u58 = 1;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          // FIELD of a VAR whose field type is TYPE_ARRAY, returned as
          // TYPE_SLICE. The let that filled the struct already stored the
          // bytes. emit_expr of an 8-byte field then loads that qword into
          // x0, so the caller treats 10 and 32 packed together as a pointer
          // (from_field SIGBUS at 0x200000000a). Lea the struct slot plus
          // the field offset and put N in x1 (arm64) or rdx (SysV). The
          // caller's stack-escape copier mallocs when that pointer is
          // below sp. A missing slot or offset stays on emit_expr. A
          // STRUCT_LIT base whose init is an ARRAY_LIT is the next arm.
          // A TYPE_ARRAY function return stays on the value path. Windows
          // stays on emit_expr.
          // PLATFORM: MACOS|ARM64 · LINUX x86_64.
          if (dur_ok_u58 == 0) {
            unsafe {
              opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
            }
            // EXPR_FIELD_ACCESS = 44.
            if (opk_d_u59 == 44) {
              unsafe {
                mod_d_u60 = pipeline_asm_emit_module_ref_c();
                fi_d_u61 = pipeline_asm_emit_func_index_c();
              }
              if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
                unsafe {
                  rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
                }
                if (rty_d_u62 > 0) {
                  unsafe {
                    rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
                  }
                  // TYPE_SLICE = 11. TYPE_ARRAY = 10 stays on emit_expr.
                  if (rk_d_u63 == 11) {
                    unsafe {
                      base_er_u72 = pipeline_expr_field_access_base_ref(arena, ret_op_u44);
                    }
                    if (base_er_u72 > 0) {
                      unsafe {
                        opk_d_u59 = pipeline_expr_kind_ord_at(arena, base_er_u72);
                      }
                      // EXPR_VAR = 3. STRUCT_LIT (45) is not this arm.
                      if (opk_d_u59 == 3) {
                        unsafe {
                          decl_ty_u70 = glue_field_access_field_type_ref_c(arena, mod_d_u60, ret_op_u44);
                        }
                        if (decl_ty_u70 > 0) {
                          unsafe {
                            rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                          }
                          // TYPE_ARRAY = 10. A slice field stays on emit_expr.
                          if (rk_d_u63 == 10) {
                            unsafe {
                              n_d_u67 = pipeline_type_array_size_at(arena, decl_ty_u70);
                              arr_off_u71 = glue_var_expr_stack_off_elf_c(arena, ctx, base_er_u72);
                              esz_d_u65 = glue_field_access_effective_offset_c(arena, mod_d_u60, ret_op_u44);
                            }
                            // esz_d is the field byte offset here, not an
                            // element size. Negative means the helper missed.
                            if (n_d_u67 >= 0 && n_d_u67 <= 1024 && arr_off_u71 >= 0 && esz_d_u65 >= 0) {
                              unsafe {
                                rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off_u71, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              if (esz_d_u65 != 0) {
                                unsafe {
                                  rc_u45 = backend_enc_add_imm_to_rax_arch(elf_ctx, esz_d_u65, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                              }
                              unsafe {
                                rc_u45 = backend_enc_push_rax_arch(elf_ctx, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc_u45 = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d_u67, 0, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              if (ta == 1) {
                                len_reg_u68 = 1;
                              } else {
                                len_reg_u68 = 2;
                              }
                              unsafe {
                                rc_u45 = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg_u68, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc_u45 = backend_enc_pop_rax_arch(elf_ctx, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              dur_ok_u58 = 1;
                            }
                          }
                        }
                      }
                    }
                    // FIELD of a STRUCT_LIT, same slice return. emit_expr
                    // writes no payload, so x0/x1 stay whatever the caller
                    // left and the length check fails. When the named
                    // field's init is an ARRAY_LIT, durable that literal
                    // (the existing helper rejects every other kind) and
                    // put its element count in x1 (arm64) or rdx (SysV).
                    // A VAR init, a nested literal, or a failed durable
                    // emit stays on emit_expr. Do not pack a count onto
                    // an address this arm did not emit. Windows stays on
                    // emit_expr. PLATFORM: MACOS|ARM64 · LINUX x86_64.
                    if (dur_ok_u58 == 0 && opk_d_u59 == 45) {
                      unsafe {
                        fa_nlen_u76 = pipeline_expr_field_access_name_len(arena, ret_op_u44);
                        sl_nf_u73 = pipeline_expr_struct_lit_num_fields(arena, base_er_u72);
                      }
                      sl_init_u75 = 0;
                      if (fa_nlen_u76 > 0 && fa_nlen_u76 <= 255 && sl_nf_u73 > 0 && sl_nf_u73 <= 64) {
                        unsafe {
                          pipeline_expr_field_access_name_into(arena, ret_op_u44, &fa_name_u80[0]);
                        }
                        sl_i_u74 = 0;
                        while (sl_i_u74 < sl_nf_u73) {
                          if (sl_init_u75 == 0) {
                            unsafe {
                              sl_nlen_u77 = pipeline_expr_struct_lit_field_name_len(arena, base_er_u72, sl_i_u74);
                            }
                            sl_eq_u78 = 0;
                            if (sl_nlen_u77 == fa_nlen_u76) {
                              unsafe {
                                pipeline_expr_struct_lit_field_name_into(arena, base_er_u72, sl_i_u74, &sl_name_u81[0]);
                              }
                              sl_eq_u78 = 1;
                              sl_k_u79 = 0;
                              while (sl_k_u79 < fa_nlen_u76) {
                                if (fa_name_u80[sl_k_u79] != sl_name_u81[sl_k_u79]) {
                                  sl_eq_u78 = 0;
                                }
                                sl_k_u79 = sl_k_u79 + 1;
                              }
                            }
                            if (sl_eq_u78 != 0) {
                              unsafe {
                                sl_init_u75 = pipeline_expr_struct_lit_init_ref(arena, base_er_u72, sl_i_u74);
                              }
                            }
                          }
                          sl_i_u74 = sl_i_u74 + 1;
                        }
                      }
                      if (sl_init_u75 > 0) {
                        unsafe {
                          opk_d_u59 = pipeline_expr_kind_ord_at(arena, sl_init_u75);
                        }
                        // EXPR_ARRAY_LIT = 46. The durable helper rejects
                        // every other kind, so a non-literal init falls
                        // through.
                        if (opk_d_u59 == 46) {
                          unsafe {
                            n_d_u67 = pipeline_expr_array_lit_num_elems_at(arena, sl_init_u75);
                            elem_d_u64 = pipeline_type_elem_ref_at(arena, rty_d_u62);
                            esz_d_u65 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d_u64);
                          }
                          if (n_d_u67 >= 0 && n_d_u67 <= 1024) {
                            unsafe {
                              rc_u45 = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, sl_init_u75, esz_d_u65, ta, ctx, elem_d_u64);
                            }
                            if (rc_u45 == 0) {
                              unsafe {
                                rc_u45 = backend_enc_push_rax_arch(elf_ctx, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc_u45 = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d_u67, 0, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              if (ta == 1) {
                                len_reg_u68 = 1;
                              } else {
                                len_reg_u68 = 2;
                              }
                              unsafe {
                                rc_u45 = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg_u68, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc_u45 = backend_enc_pop_rax_arch(elf_ctx, ta);
                              }
                              if (rc_u45 != 0) {
                                return 0 - 1;
                              }
                              dur_ok_u58 = 1;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          // INDEX of a VAR whose element type is TYPE_ARRAY, returned as
          // TYPE_SLICE. emit_expr already leaves the row address in x0:
          // a[0] is the base pointer and a[1] is that pointer plus the
          // row stride. x1 is still whatever the caller left, and the
          // caller reads x1 as the slice length, so row0_slc returns 1.
          // Push that address, move the row's element count into x1
          // (arm64) or rdx (SysV), and pop. Do not lea a second time.
          // When the function returns an 8-byte TYPE_ARRAY, the caller
          // stores x0 as the value, so load the qword at that address
          // (row1_arr). A wider array stays on emit_expr. A non-VAR
          // base stays on emit_expr. An element that is not TYPE_ARRAY
          // stays on emit_expr: a slice element is already a fat
          // pointer, and packing an array count onto it would drop
          // that length. Windows stays on emit_expr because this arm
          // sits inside win_d == 0.
          // PLATFORM: MACOS|ARM64 · LINUX x86_64.
          if (dur_ok_u58 == 0) {
            unsafe {
              opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
            }
            // EXPR_INDEX = 47.
            if (opk_d_u59 == 47) {
              unsafe {
                mod_d_u60 = pipeline_asm_emit_module_ref_c();
                fi_d_u61 = pipeline_asm_emit_func_index_c();
              }
              if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
                unsafe {
                  rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
                }
                if (rty_d_u62 > 0) {
                  unsafe {
                    rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
                  }
                  // TYPE_SLICE = 11. TYPE_ARRAY = 10 stays on emit_expr.
                  if (rk_d_u63 == 11) {
                    unsafe {
                      base_er_u72 = pipeline_expr_index_base_ref(arena, ret_op_u44);
                    }
                    if (base_er_u72 > 0) {
                      unsafe {
                        opk_d_u59 = pipeline_expr_kind_ord_at(arena, base_er_u72);
                      }
                      // EXPR_VAR = 3. A field or another index stays out.
                      if (opk_d_u59 == 3) {
                        unsafe {
                          decl_ty_u70 = glue_var_decl_type_ref_elf_c(arena, ctx, base_er_u72);
                        }
                        if (decl_ty_u70 > 0) {
                          unsafe {
                            rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                          }
                          // TYPE_ARRAY = 10. A slice variable stays on emit_expr.
                          if (rk_d_u63 == 10) {
                            unsafe {
                              elem_d_u64 = pipeline_type_elem_ref_at(arena, decl_ty_u70);
                            }
                            if (elem_d_u64 > 0) {
                              unsafe {
                                rk_d_u63 = pipeline_type_kind_ord_at(arena, elem_d_u64);
                              }
                              // The row itself is TYPE_ARRAY. Its size is
                              // the slice length. A scalar element is not
                              // a row and stays on emit_expr.
                              if (rk_d_u63 == 10) {
                                unsafe {
                                  n_d_u67 = pipeline_type_array_size_at(arena, elem_d_u64);
                                }
                                if (n_d_u67 >= 0 && n_d_u67 <= 1024) {
                                  unsafe {
                                    rc_u45 = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op_u44, ctx, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc_u45 = backend_enc_push_rax_arch(elf_ctx, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc_u45 = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d_u67, 0, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  if (ta == 1) {
                                    len_reg_u68 = 1;
                                  } else {
                                    len_reg_u68 = 2;
                                  }
                                  unsafe {
                                    rc_u45 = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg_u68, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc_u45 = backend_enc_pop_rax_arch(elf_ctx, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  dur_ok_u58 = 1;
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  // TYPE_ARRAY = 10, 8-byte row only. emit_expr left the
                  // row address. The caller stores x0 as the [2]i32
                  // value, so load that qword. n * esz == 16 is the pair
                  // load used by ARRAY_LIT and is not this test. A wider
                  // row stays on emit_expr. PLATFORM: MACOS|ARM64 · LINUX x86_64.
                  if (dur_ok_u58 == 0 && rk_d_u63 == 10) {
                    unsafe {
                      base_er_u72 = pipeline_expr_index_base_ref(arena, ret_op_u44);
                    }
                    if (base_er_u72 > 0) {
                      unsafe {
                        opk_d_u59 = pipeline_expr_kind_ord_at(arena, base_er_u72);
                      }
                      // EXPR_VAR = 3. A field or another index stays out.
                      if (opk_d_u59 == 3) {
                        unsafe {
                          decl_ty_u70 = glue_var_decl_type_ref_elf_c(arena, ctx, base_er_u72);
                        }
                        if (decl_ty_u70 > 0) {
                          unsafe {
                            rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                          }
                          if (rk_d_u63 == 10) {
                            unsafe {
                              elem_d_u64 = pipeline_type_elem_ref_at(arena, decl_ty_u70);
                            }
                            if (elem_d_u64 > 0) {
                              unsafe {
                                rk_d_u63 = pipeline_type_kind_ord_at(arena, elem_d_u64);
                              }
                              if (rk_d_u63 == 10) {
                                unsafe {
                                  n_d_u67 = pipeline_type_array_size_at(arena, elem_d_u64);
                                  elem_d_u64 = pipeline_type_elem_ref_at(arena, elem_d_u64);
                                  esz_d_u65 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d_u64);
                                }
                                // 8 bytes is one GPR. Do not load a wider row.
                                if (n_d_u67 > 0 && n_d_u67 <= 1024 && esz_d_u65 > 0 && esz_d_u65 <= 16 && n_d_u67 * esz_d_u65 == 8) {
                                  unsafe {
                                    rc_u45 = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op_u44, ctx, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc_u45 = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                  dur_ok_u58 = 1;
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      /*
       * Darwin sret copies [x0] into the hidden dest. emit_expr of a
       * scalar literal leaves that scalar in x0, and the copy then
       * reads it as an address (SIGSEGV). A TYPE_VECTOR (kind 13) of
       * i32 whose operand is a bare INT_LIT, a kind-22 / kind-23
       * chain, or an if / ternary (kind 25 / 27) is filled by the
       * same let-init that `let v_u118: Vec8i = 3` uses. A lane binop
       * (the existing glue_is_vector_lane_scalar_binop_ko set) is
       * the same fill: emit_expr subtracted the first qword and the
       * copy read that integer as an address. A relational compare
       * (vlet_lane_cmp_ko, kinds 14..19) is the same fill: emit_expr
       * compared the first qword and the copy read that 0 or 1 as an
       * address. A named SIMD (kind 8)
       * whose sret size is above 16 bytes uses that same let-init
       * for an INT_LIT, a FLOAT_LIT (kind 1), a BOOL_LIT (kind 2),
       * a kind-22 chain, a kind-23 chain, a lane binop, or a
       * relational compare (kinds 14..19).
       * `return ~1` and `return true` of f32x8 keep the integer bits
       * the let-init already stores. A 16-byte return does not enter
       * the kind-8 arm, so f32x4 and i32x4 stay out. Vec4f is kind 13
       * with an f32 element, so it stays out. A VAR operand (kind 3)
       * stays on emit_expr: that path already leaves the local
       * address. Let-init -3 falls through. Any other failure
       * returns -1. Kind-13 f32 element kinds do not enter.
       * PLATFORM: MACOS|ARM64.
       */
      if (ta == 1) {
        if (dur_ok_u58 == 0) {
          unsafe {
            v_opk_u90 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
          }
          if (v_opk_u90 == 0) {
            v_go_u91 = 1;
            v_go8_u92 = 1;
          }
          if (v_opk_u90 == 1) {
            v_go8_u92 = 1;
          }
          if (v_opk_u90 == 22) {
            v_go_u91 = 1;
            v_go8_u92 = 1;
          }
          if (v_opk_u90 == 2) {
            v_go8_u92 = 1;
          }
          if (v_opk_u90 == 23) {
            v_go_u91 = 1;
            v_go8_u92 = 1;
          }
          if (v_opk_u90 == 25) {
            v_go_u91 = 1;
          }
          if (v_opk_u90 == 27) {
            v_go_u91 = 1;
          }
          unsafe {
            v_bin_u95 = glue_is_vector_lane_scalar_binop_ko(v_opk_u90);
          }
          if (v_bin_u95 != 0) {
            v_go_u91 = 1;
            v_go8_u92 = 1;
          }
          unsafe {
            v_cmp_u96 = vlet_lane_cmp_ko(v_opk_u90);
          }
          if (v_cmp_u96 != 0) {
            v_go_u91 = 1;
            v_go8_u92 = 1;
          }
          if (v_go_u91 != 0) {
            v_enter_u93 = 1;
          }
          if (v_go8_u92 != 0) {
            v_enter_u93 = 1;
          }
          if (v_enter_u93 != 0) {
            unsafe {
              v_mod_u84 = pipeline_asm_emit_module_ref_c();
              v_fi_u85 = pipeline_asm_emit_func_index_c();
            }
            if (v_mod_u84 != (0 as *u8)) {
              if (v_fi_u85 >= 0) {
                unsafe {
                  v_rty_u86 = pipeline_module_func_return_type_at(v_mod_u84, v_fi_u85);
                }
                if (v_rty_u86 > 0) {
                  unsafe {
                    v_rk_u87 = pipeline_type_kind_ord_at(arena, v_rty_u86);
                  }
                  if (v_rk_u87 == 13) {
                    if (v_go_u91 != 0) {
                      unsafe {
                        v_elem_u88 = pipeline_type_elem_ref_at(arena, v_rty_u86);
                      }
                      if (v_elem_u88 > 0) {
                        unsafe {
                          v_ek_u89 = pipeline_type_kind_ord_at(arena, v_elem_u88);
                        }
                        if (v_ek_u89 == 0) {
                          v_take_u94 = 1;
                        }
                      }
                    }
                  }
                  if (v_rk_u87 == 8) {
                    if (v_go8_u92 != 0) {
                      unsafe {
                        rsz_u51 = pipeline_asm_emit_ctx_sret_ret_sz_get();
                      }
                      if (rsz_u51 >= 16) {
                        v_take_u94 = 1;
                      }
                    }
                  }
                  if (v_take_u94 != 0) {
                    unsafe {
                      v_slot_u82 = glue_simd_alloc_vector_temp_slot_c(arena, ctx, v_rty_u86);
                    }
                    if (v_slot_u82 < 0) {
                      return 0 - 1;
                    }
                    unsafe {
                      v_rc_u83 = glue_emit_vector_type_let_init_elf_c(
                        arena, elf_ctx, ret_op_u44, ctx, ta, v_slot_u82, v_rty_u86);
                    }
                    if (v_rc_u83 == 0) {
                      unsafe {
                        v_rc_u83 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, v_slot_u82, ta);
                      }
                      if (v_rc_u83 != 0) {
                        return 0 - 1;
                      }
                      dur_ok_u58 = 1;
                    } else {
                      if (v_rc_u83 != (0 - 3)) {
                        return 0 - 1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      /* FIELD whose leaf is TYPE_ARRAY, returned as a TYPE_ARRAY
       * wider than 16 bytes. A local VAR of that array leaves its
       * address in x0 (`return s`). emit_expr of the field loads
       * the first qword, so `return w.xs` of [2]S24 returns 5 and
       * 6 packed together and the caller SIGBUS. Lea the root VAR
       * slot plus each value-field offset. `return w.xs` is one
       * offset. `return o.inn.xs` adds the parent offset too.
       * Element width is the named layout, then the array-literal
       * stride. 16 bytes or less stays on emit_expr (value or
       * pair). A slice return is the arm above. An INDEX base
       * (`return a[0].xs`) and a DEREF base (`return (*p).xs`) use
       * that root's lvalue, then the same field offset. A STRUCT_LIT
       * root durables an ARRAY_LIT init, or takes a VAR init's
       * address. A parent field
       * (`return { inn: { xs: [...] } }.inn.xs`) walks that init
       * when it is also a STRUCT_LIT. A parent init that is a local
       * struct (`return { inn: src }.inn.xs`) takes that local's
       * address plus the fields inside it. At most four thousand ninety-six parents.
       * A field past slot 63, a pointer element, a slice
       * element, a pointer field, or a pointer root
       * stays on emit_expr.
       * Parent hops call helpers. An extern written directly in a
       * while is dropped by this compiler.
       * PLATFORM: MACOS|ARM64. */
      if (dur_ok_u58 == 0 && ta == 1) {
        unsafe {
          opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
        }
        if (opk_d_u59 == 44) {
          unsafe {
            mod_d_u60 = pipeline_asm_emit_module_ref_c();
            fi_d_u61 = pipeline_asm_emit_func_index_c();
          }
          if (mod_d_u60 != (0 as *u8) && fi_d_u61 >= 0) {
            unsafe {
              rty_d_u62 = pipeline_module_func_return_type_at(mod_d_u60, fi_d_u61);
            }
            if (rty_d_u62 > 0) {
              unsafe {
                rk_d_u63 = pipeline_type_kind_ord_at(arena, rty_d_u62);
              }
              if (rk_d_u63 == 10) {
                unsafe {
                  base_er_u72 = pipeline_expr_field_access_base_ref(arena, ret_op_u44);
                }
                if (base_er_u72 > 0) {
                  unsafe {
                    decl_ty_u70 = glue_field_access_field_type_ref_c(arena, mod_d_u60, ret_op_u44);
                  }
                  if (decl_ty_u70 > 0) {
                    unsafe {
                      rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                    }
                    if (rk_d_u63 == 10) {
                      unsafe {
                        n_d_u67 = pipeline_type_array_size_at(arena, decl_ty_u70);
                        elem_d_u64 = pipeline_type_elem_ref_at(arena, decl_ty_u70);
                      }
                      esz_d_u65 = 0;
                      if (elem_d_u64 > 0) {
                        unsafe {
                          esz_d_u65 = glue_type_named_layout_size_any_module_elf_c(arena, elem_d_u64);
                        }
                        if (esz_d_u65 <= 0) {
                          unsafe {
                            esz_d_u65 = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d_u64);
                          }
                        }
                      }
                      peel_d_u66 = 0;
                      if (n_d_u67 > 0 && n_d_u67 <= 1024 && esz_d_u65 > 0 && esz_d_u65 <= 256) {
                        peel_d_u66 = n_d_u67 * esz_d_u65;
                      }
                      if (peel_d_u66 > 16) {
                        let sum_off_u119: i32 = 0;
                        let root_er_u120: i32 = base_er_u72;
                        let hop_u121: i32 = 0;
                        let fold_ok_u122: i32 = 1;
                        let hops_u123: i32 = 0;
                        unsafe {
                          sum_off_u119 = glue_field_access_effective_offset_c(arena, mod_d_u60, ret_op_u44);
                        }
                        if (sum_off_u119 < 0 || sum_off_u119 > 4095) {
                          fold_ok_u122 = 0;
                        }
                        /* Up to four thousand ninety-six parent fields. -2 means
                         * this expr is the root. The loop calls helpers.
                         * Extern stays inside them. A four thousand
                         * ninety-seventh parent stays on emit_expr.
                         * PLATFORM: MACOS|ARM64. */
                        if (fold_ok_u122 != 0) {
                          hop_u121 = w635_rs_fold_parent(arena, mod_d_u60, root_er_u120);
                          while (fold_ok_u122 != 0 && hop_u121 >= 0 && hops_u123 < 4096) {
                            if (sum_off_u119 > (4095 - hop_u121)) {
                              fold_ok_u122 = 0;
                            } else {
                              sum_off_u119 = sum_off_u119 + hop_u121;
                              root_er_u120 = w648_rs_base(arena, root_er_u120);
                              hops_u123 = hops_u123 + 1;
                              hop_u121 = w635_rs_fold_parent(arena, mod_d_u60, root_er_u120);
                            }
                          }
                          if (hop_u121 != (0 - 2)) {
                            fold_ok_u122 = 0;
                          }
                        }
                        if (fold_ok_u122 != 0 && root_er_u120 > 0) {
                          unsafe {
                            opk_d_u59 = pipeline_expr_kind_ord_at(arena, root_er_u120);
                          }
                          if (opk_d_u59 == 3) {
                            // One-field `w.xs` keeps the old path. A chain
                            // refuses a pointer root (kind 9).
                            if (root_er_u120 != base_er_u72) {
                              unsafe {
                                decl_ty_u70 = glue_var_decl_type_ref_elf_c(arena, ctx, root_er_u120);
                              }
                              if (decl_ty_u70 > 0) {
                                unsafe {
                                  rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                                }
                                if (rk_d_u63 == 9) {
                                  fold_ok_u122 = 0;
                                }
                              }
                            }
                            if (fold_ok_u122 != 0) {
                              unsafe {
                                arr_off_u71 = glue_var_expr_stack_off_elf_c(arena, ctx, root_er_u120);
                              }
                              if (arr_off_u71 >= 0 && sum_off_u119 >= 0 && sum_off_u119 <= 4095) {
                                unsafe {
                                  rc_u45 = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off_u71, ta);
                                }
                                if (rc_u45 != 0) {
                                  return 0 - 1;
                                }
                                if (sum_off_u119 != 0) {
                                  unsafe {
                                    rc_u45 = backend_enc_add_imm_to_rax_arch(elf_ctx, sum_off_u119, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                }
                                dur_ok_u58 = 1;
                              }
                            }
                          }
                          /* INDEX base (`return a[0].xs`) or DEREF base
                           * (`return (*p).xs`). emit_expr of either loads
                           * the first word. The lvalue is the element
                           * address, or the pointer value for a deref.
                           * The field offset is the same sum the VAR path
                           * adds. A pointer or slice element stays on
                           * emit_expr. A failed lvalue stays on emit_expr.
                           * EXPR_INDEX = 47. EXPR_DEREF = 52.
                           * PLATFORM: MACOS|ARM64. */
                          if ((opk_d_u59 == 47 || opk_d_u59 == 52) && dur_ok_u58 == 0) {
                            decl_ty_u70 = 0;
                            unsafe {
                              decl_ty_u70 = pipeline_expr_resolved_type_ref(arena, root_er_u120);
                            }
                            rk_d_u63 = 0;
                            if (decl_ty_u70 > 0) {
                              unsafe {
                                rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                              }
                            }
                            if (rk_d_u63 != 9 && rk_d_u63 != 11) {
                              unsafe {
                                rc_u45 = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                                  arena, elf_ctx, root_er_u120, ctx, ta);
                              }
                              if (rc_u45 == 0) {
                                if (sum_off_u119 != 0) {
                                  unsafe {
                                    rc_u45 = backend_enc_add_imm_to_rax_arch(elf_ctx, sum_off_u119, ta);
                                  }
                                  if (rc_u45 != 0) {
                                    return 0 - 1;
                                  }
                                }
                                dur_ok_u58 = 1;
                              }
                            }
                          }
                          /* STRUCT_LIT root (`return { xs: [...] }.xs`, or
                           * `return { inn: { xs: [...] } }.inn.xs`).
                           * The array is the leaf field init, not a byte
                           * offset into a slot. A STRUCT_LIT parent is
                           * walked. A VAR parent
                           * (`return { inn: src }.inn.xs`) is that local
                           * plus the fields inside it, not the literal
                           * field's own offset. Durable an ARRAY_LIT
                           * leaf. A VAR leaf is that local array's
                           * address. A field past slot 63 stays
                           * on emit_expr.
                           * EXPR_STRUCT_LIT = 45. EXPR_ARRAY_LIT = 46.
                           * EXPR_VAR = 3. PLATFORM: MACOS|ARM64. */
                          if (opk_d_u59 == 45 && dur_ok_u58 == 0) {
                            let fas_u124: i32[4096] = [];
                            let nb_u125: i32 = 0;
                            let cur_u126: i32 = root_er_u120;
                            let walk_u127: i32 = base_er_u72;
                            let idx_u128: i32 = 0;
                            let step_ok_u129: i32 = 1;
                            /* Parents between the leaf and the root.
                             * fas_u124[0] is the leaf's base. fas_u124[nb_u125 - 1] is
                             * the field on the root. At most four thousand ninety-six.
                             * The loop calls helpers. Extern stays
                             * inside them. PLATFORM: MACOS|ARM64. */
                            while (walk_u127 != root_er_u120 && walk_u127 > 0 && nb_u125 < 4096) {
                              fas_u124[nb_u125] = walk_u127;
                              nb_u125 = nb_u125 + 1;
                              walk_u127 = w648_rs_base(arena, walk_u127);
                            }
                            idx_u128 = nb_u125;
                            while (step_ok_u129 != 0 && idx_u128 > 0) {
                              idx_u128 = idx_u128 - 1;
                              cur_u126 = w643_rs_named_init(arena, cur_u126, fas_u124[idx_u128]);
                              step_ok_u129 = 0;
                              if (cur_u126 > 0) {
                                opk_d_u59 = w648_rs_kind(arena, cur_u126);
                                if (opk_d_u59 == 45) {
                                  step_ok_u129 = 1;
                                }
                                /* This init is the local. idx_u128 is how
                                 * many closer fields sit inside it.
                                 * PLATFORM: MACOS|ARM64. */
                                if (opk_d_u59 == 3 && dur_ok_u58 == 0) {
                                  unsafe {
                                    rc_u45 = w648_rs_lea_chain(
                                      arena, elf_ctx, ctx, ta, mod_d_u60, cur_u126, ret_op_u44, &fas_u124[0], idx_u128);
                                  }
                                  if (rc_u45 < 0) {
                                    return 0 - 1;
                                  }
                                  if (rc_u45 == 0) {
                                    dur_ok_u58 = 1;
                                  }
                                }
                              }
                            }
                            sl_init_u75 = 0;
                            if (step_ok_u129 != 0) {
                              sl_init_u75 = w643_rs_named_init(arena, cur_u126, ret_op_u44);
                            }
                            if (sl_init_u75 > 0) {
                              unsafe {
                                opk_d_u59 = pipeline_expr_kind_ord_at(arena, sl_init_u75);
                              }
                              if (opk_d_u59 == 46 && esz_d_u65 > 0 && elem_d_u64 > 0) {
                                unsafe {
                                  rc_u45 = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(
                                    arena, elf_ctx, sl_init_u75, esz_d_u65, ta, ctx, elem_d_u64);
                                }
                                if (rc_u45 == 0) {
                                  dur_ok_u58 = 1;
                                }
                              }
                              /* Local array stored in the literal.
                               * lvalue leaves its address. A failed
                               * lvalue stays on emit_expr.
                               * PLATFORM: MACOS|ARM64. */
                              if (opk_d_u59 == 3 && dur_ok_u58 == 0) {
                                unsafe {
                                  rc_u45 = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                                    arena, elf_ctx, sl_init_u75, ctx, ta);
                                }
                                if (rc_u45 == 0) {
                                  dur_ok_u58 = 1;
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      /* FIELD of a named struct wider than 16 bytes, base is INDEX
       * (`return a[1].s`). emit_expr loads the first word. The sret
       * copy then reads that word as an address (SIGBUS). A local
       * `return w.s` already leaves the slot address and stays on
       * emit_expr. Lea the element, then add the field offset. A
       * pointer or slice element stays on emit_expr. A failed lvalue
       * stays on emit_expr. TYPE_NAMED = 8. EXPR_INDEX = 47.
       * EXPR_FIELD = 44. PLATFORM: MACOS|ARM64. */
      if (dur_ok_u58 == 0 && ta == 1) {
        unsafe {
          opk_d_u59 = pipeline_expr_kind_ord_at(arena, ret_op_u44);
        }
        if (opk_d_u59 == 44) {
          unsafe {
            rsz_u51 = pipeline_asm_emit_ctx_sret_ret_sz_get();
          }
          if (rsz_u51 >= 16) {
            unsafe {
              mod_d_u60 = pipeline_asm_emit_module_ref_c();
            }
            decl_ty_u70 = 0;
            if (mod_d_u60 != (0 as *u8)) {
              unsafe {
                decl_ty_u70 = glue_field_access_field_type_ref_c(arena, mod_d_u60, ret_op_u44);
              }
            }
            rk_d_u63 = 0;
            if (decl_ty_u70 > 0) {
              unsafe {
                rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
              }
            }
            if (rk_d_u63 == 8) {
              unsafe {
                base_er_u72 = pipeline_expr_field_access_base_ref(arena, ret_op_u44);
              }
              if (base_er_u72 > 0) {
                unsafe {
                  opk_d_u59 = pipeline_expr_kind_ord_at(arena, base_er_u72);
                }
                if (opk_d_u59 == 47) {
                  decl_ty_u70 = 0;
                  unsafe {
                    decl_ty_u70 = pipeline_expr_resolved_type_ref(arena, base_er_u72);
                  }
                  rk_d_u63 = 0;
                  if (decl_ty_u70 > 0) {
                    unsafe {
                      rk_d_u63 = pipeline_type_kind_ord_at(arena, decl_ty_u70);
                    }
                  }
                  if (rk_d_u63 != 9 && rk_d_u63 != 11) {
                    let sum_off_u130: i32 = 0;
                    unsafe {
                      sum_off_u130 = glue_field_access_effective_offset_c(arena, mod_d_u60, ret_op_u44);
                    }
                    if (sum_off_u130 >= 0 && sum_off_u130 <= 4095) {
                      unsafe {
                        rc_u45 = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                          arena, elf_ctx, base_er_u72, ctx, ta);
                      }
                      if (rc_u45 == 0) {
                        if (sum_off_u130 != 0) {
                          unsafe {
                            rc_u45 = backend_enc_add_imm_to_rax_arch(elf_ctx, sum_off_u130, ta);
                          }
                          if (rc_u45 != 0) {
                            return 0 - 1;
                          }
                        }
                        dur_ok_u58 = 1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (dur_ok_u58 == 0) {
        unsafe {
          rc_u45 = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op_u44, ctx, ta);
        }
        if (rc_u45 != 0) {
          return 0 - 1;
        }
      }
      // w1521: Windows builds a > 16-byte STRUCT_LIT (or other aggregate
      // operand) in a frame temp and leaves its address in rax; copy it into
      // the hidden dest (Linux pabi writes the dest itself). A durable
      // TYPE_ARRAY pointer is the same source address. PLATFORM: WINDOWS.
      if (ta == 0 && act_u49 != 0 && home_u50 > 0 && rsz_u51 >= 16) {
        let on_win_u131: i32 = 0;
        unsafe {
          on_win_u131 = link_abi_host_is_windows();
        }
        if (on_win_u131 != 0) {
          if (wide_copied_u52 != 0) {
            unsafe {
              rc_u45 = backend_enc_load_rbp_to_rax_arch(elf_ctx, home_u50, ta);
            }
            if (rc_u45 != 0) {
              return 0 - 1;
            }
          }
          if (w1521_rs_copy_x86(elf_ctx, home_u50, rsz_u51) < 0) {
            return 0 - 1;
          }
        }
      }
    }
    if (ta == 1) {
      // A wide fill already read home. Let-init of an element must not
      // replace that slot before the self-copy. PLATFORM: MACOS|ARM64.
      if (wide_copied_u52 == 0) {
        unsafe {
          act_u49 = pipeline_asm_emit_ctx_sret_active_get();
          home_u50 = pipeline_asm_emit_ctx_sret_home_off_get();
          rsz_u51 = pipeline_asm_emit_ctx_sret_ret_sz_get();
        }
      }
      if (act_u49 != 0 && home_u50 >= 0 && rsz_u51 >= 16) {
        if (wide_copied_u52 != 0) {
          if (w1521_rs_load_dest_x0(elf_ctx, home_u50) != 0) {
            return 0 - 1;
          }
        }
        if (w1521_rs_copy_to_dest(elf_ctx, home_u50, rsz_u51) < 0) {
          return 0 - 1;
        }
      }
    }
    /* 记213: f64 return — bits sit in rax/x0; place in xmm0/d0 before
     * jmp tail_join. Without this, only leftover FP from a prior f64
     * callee works (math.floor) while lit/local/out-pointer f64 returns
     * fail (math.pi). Integer returns ignore the FP reg.
     * 记226: same for F32(14) — vec3f_soa_get_x left bits in x0; C read s0
     * (saw pointer junk). fmov d0,x0 covers both (s0 is low of d0).
     * Literal 14/15 avoid named-const adrp miss. PLATFORM: SHARED. */
    if ((ta == 0 || ta == 1) && ret_op_u44 != 0) {
      let mod_f_u132: *u8 = 0 as *u8;
      let fi_f_u133: i32 = 0;
      let rty_f_u134: i32 = 0;
      let rkind_f_u135: i32 = 0;
      unsafe {
        mod_f_u132 = pipeline_asm_emit_module_ref_c();
        fi_f_u133 = pipeline_asm_emit_func_index_c();
      }
      if (mod_f_u132 != (0 as *u8) && fi_f_u133 >= 0) {
        unsafe {
          rty_f_u134 = pipeline_module_func_return_type_at(mod_f_u132, fi_f_u133);
        }
        if (rty_f_u134 > 0) {
          unsafe {
            rkind_f_u135 = pipeline_type_kind_ord_at(arena, rty_f_u134);
          }
          if (rkind_f_u135 == 15 || rkind_f_u135 == 14) {
            unsafe {
              rc_u45 = backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta);
            }
            if (rc_u45 != 0) {
              return 0 - 1;
            }
          }
        }
      }
    }
  }
  unsafe {
    rc_u45 = glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  }
  if (rc_u45 != 0) {
    return 0 - 1;
  }
  unsafe {
    rc_u45 = glue_async_cps_emit_phase_reset(elf_ctx, ta);
  }
  if (rc_u45 != 0) {
    return 0 - 1;
  }
  if (ly_u43 == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    tj_len_u46 = pipe_load_i32_le(ly_u43, 1520);
  }
  if (tj_len_u46 <= 0) {
    return 0 - 1;
  }
  ti_u48 = 0;
  while (ti_u48 < tj_len_u46 && ti_u48 < 128) {
    unsafe {
      tj_lbl_u47[ti_u48] = ly_u43[1392 + ti_u48];
    }
    ti_u48 = ti_u48 + 1;
  }
  unsafe {
    return backend_enc_jmp_arch(elf_ctx, &tj_lbl_u47[0], tj_len_u46, ta);
  }
}
