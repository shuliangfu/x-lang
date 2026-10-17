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
  let rc: i32 = 0;
  let ty: i32 = 0;
  unsafe {
    ty = pipeline_expr_resolved_type_ref(arena, op);
    if (ty > 0) {
      pipeline_asm_set_call_expected_ret_ty_c(ty);
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
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    pipeline_asm_emit_set_call_sret_reg_shift_c(0);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (rc != 0) {
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
  let b: u8[1] = [];
  b[0] = (v & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 1);
  }
  return 0 - 1;
}

/** Append a little-endian disp32. PLATFORM: LINUX x86_64. */
function w1521_rs_d32(elf_ctx: *u8, v: i32): i32 {
  let b: u8[4] = [];
  b[0] = (v & 255) as u8;
  b[1] = ((v >> 8) & 255) as u8;
  b[2] = ((v >> 16) & 255) as u8;
  b[3] = ((v >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
  }
  return 0 - 1;
}

/**
 * Local VAR operand frame offset (rbp-off), or -1 when the operand is not a
 * plain local. PLATFORM: LINUX x86_64.
 */
function w1521_rs_local_off(arena: *u8, ctx: *u8, op: i32): i32 {
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let off: i32 = 0 - 1;
  unsafe {
    if (pipeline_expr_kind_ord_at(arena, op) != 3) {
      return 0 - 1;
    }
    vlen = pipeline_expr_var_name_len(arena, op);
  }
  if (vlen <= 0 || vlen > 255) {
    return 0 - 1;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, op, &vname[0]);
    off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    if (off < 0) {
      off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
    }
  }
  return off;
}

/**
 * rax = source address. mov rcx,[rbp-home]; copy sz bytes rax to rcx via
 * rdx/dl; mov rax,rcx. @return 0 ok; 1 not applicable; -1 encoder fail.
 * PLATFORM: LINUX x86_64.
 */
function w1521_rs_copy_x86(elf_ctx: *u8, home: i32, sz: i32): i32 {
  let k: i32 = 0;
  if (home <= 0 || sz <= 16 || sz > 1000000) {
    return 1;
  }
  // mov rcx, [rbp - home]
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 141) != 0) { return 0 - 1; }
  if (w1521_rs_d32(elf_ctx, 0 - home) != 0) { return 0 - 1; }
  while (k + 8 <= sz) {
    // mov rdx, [rax + k] ; mov [rcx + k], rdx
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    k = k + 8;
  }
  while (k < sz) {
    // movzx edx, byte [rax + k] ; mov [rcx + k], dl
    if (w1521_rs_b(elf_ctx, 15) != 0 || w1521_rs_b(elf_ctx, 182) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 136) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    k = k + 1;
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
  let k: i32 = 0;
  let d: i32 = 0;
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
  while (k + 8 <= width) {
    d = dest_off + k;
    // mov rdx, [rax + k] ; mov [rcx + d], rdx
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 139) != 0 || w1521_rs_b(elf_ctx, 144) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, k) != 0) { return 0 - 1; }
    if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 145) != 0) { return 0 - 1; }
    if (w1521_rs_d32(elf_ctx, d) != 0) { return 0 - 1; }
    k = k + 8;
  }
  // mov rax, rcx
  if (w1521_rs_b(elf_ctx, 72) != 0 || w1521_rs_b(elf_ctx, 137) != 0 || w1521_rs_b(elf_ctx, 200) != 0) { return 0 - 1; }
  return 0;
}

/** Append one little-endian arm64 instruction word. PLATFORM: MACOS|ARM64. */
function w1521_rs_a64(elf_ctx: *u8, word: i64): i32 {
  let b: u8[4] = [];
  b[0] = (word & 255) as u8;
  b[1] = ((word >> 8) & 255) as u8;
  b[2] = ((word >> 16) & 255) as u8;
  b[3] = ((word >> 24) & 255) as u8;
  unsafe {
    return pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 4);
  }
  return 0 - 1;
}

/**
 * x0 = source address. ldr x9,[x29,#home]; copy sz bytes x0 to x9 via x10;
 * mov x0,x9. @return 0 ok; 1 not applicable; -1 encoder fail.
 * PLATFORM: MACOS|ARM64.
 */
function w1521_rs_copy_to_dest(elf_ctx: *u8, home: i32, sz: i32): i32 {
  let k: i32 = 0;
  if (home < 0 || home > 32760 || (home % 8) != 0 || sz <= 16 || sz > 32000) {
    return 1;
  }
  // ldr x9, [x29, #home]
  if (w1521_rs_a64(elf_ctx, 4181722025 + (((home / 8) as i64) << 10)) != 0) { return 0 - 1; }
  k = 0;
  while (k + 8 <= sz) {
    // ldr x10, [x0, #k] ; str x10, [x9, #k]
    if (w1521_rs_a64(elf_ctx, 4181721098 + (((k / 8) as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 4177527082 + (((k / 8) as i64) << 10)) != 0) { return 0 - 1; }
    k = k + 8;
  }
  while (k < sz) {
    // ldrb w10, [x0, #k] ; strb w10, [x9, #k]
    if (w1521_rs_a64(elf_ctx, 960495626 + ((k as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 956301610 + ((k as i64) << 10)) != 0) { return 0 - 1; }
    k = k + 1;
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
  let k: i32 = 0;
  let d: i32 = 0;
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
  k = 0;
  while (k + 8 <= width) {
    d = dest_off + k;
    // ldr x10, [x0, #k] ; str x10, [x9, #d]
    if (w1521_rs_a64(elf_ctx, 4181721098 + (((k / 8) as i64) << 10)) != 0) { return 0 - 1; }
    if (w1521_rs_a64(elf_ctx, 4177527082 + (((d / 8) as i64) << 10)) != 0) { return 0 - 1; }
    k = k + 8;
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
  let k: i32 = 0;
  let sz: i32 = 0;
  if (arena == (0 as *u8) || ty <= 0) {
    return 0;
  }
  unsafe {
    k = pipeline_type_kind_ord_at(arena, ty);
  }
  if (k != 8) {
    return 0;
  }
  unsafe {
    sz = glue_type_named_layout_size_any_module_elf_c(arena, ty);
  }
  if (sz > 8 && sz <= 16) {
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
  let ty: i32 = 0;
  let k: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let fi: i32 = 0;
  let slot: i32 = 0;
  if (arena == (0 as *u8) || op <= 0) {
    return 0;
  }
  unsafe {
    k = pipeline_expr_kind_ord_at(arena, op);
  }
  // EXPR_FIELD_ACCESS = 44. EXPR_VAR = 3. A call (48/49) is not an address.
  if (k != 44 && k != 3) {
    return 0;
  }
  if (k == 44) {
    unsafe {
      ty = pipeline_expr_resolved_type_ref(arena, op);
    }
    if (w1521_rs_ty_mid(arena, ty) != 0) {
      return 1;
    }
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      ty = glue_field_access_field_type_ref_c(arena, mod, op);
    }
    if (w1521_rs_ty_mid(arena, ty) != 0) {
      return 1;
    }
  }
  unsafe {
    mod = pipeline_asm_emit_module_ref_c();
    fi = pipeline_asm_emit_func_index_c();
  }
  if (mod == (0 as *u8) || fi < 0) {
    return 0;
  }
  unsafe {
    ty = pipeline_module_func_return_type_at(mod, fi);
  }
  if (w1521_rs_ty_mid(arena, ty) != 0) {
    return 1;
  }
  // PLATFORM: WINDOWS — latch is set only for a 9..16 named result.
  // Off Windows the slot stays negative and this arm does not fire.
  unsafe {
    slot = w1545_win_ret_slot_for_c(mod, fi);
  }
  if (slot > 0) {
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
  let k: i32 = 0;
  let ty: i32 = 0;
  let off: i32 = 0;
  if (fa <= 0) {
    return 0 - 2;
  }
  unsafe {
    k = pipeline_expr_kind_ord_at(arena, fa);
  }
  if (k != 44) {
    return 0 - 2;
  }
  unsafe {
    ty = glue_field_access_field_type_ref_c(arena, mod, fa);
  }
  if (ty > 0) {
    unsafe {
      k = pipeline_type_kind_ord_at(arena, ty);
    }
    // TYPE_POINTER = 9. Adding a byte offset to a pointer slot
    // writes the pointer variable, not the pointee.
    if (k == 9) {
      return 0 - 1;
    }
  }
  unsafe {
    off = glue_field_access_effective_offset_c(arena, mod, fa);
  }
  if (off < 0 || off > 4095) {
    return 0 - 1;
  }
  return off;
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
  let fa_nlen: i32 = 0;
  let sl_nlen: i32 = 0;
  let sl_eq: i32 = 0;
  let sl_k: i32 = 0;
  let init: i32 = 0;
  let fa_name: u8[64] = [];
  let sl_name: u8[64] = [];
  if (arena == (0 as *u8) || lit <= 0 || fa <= 0 || j < 0) {
    return 0;
  }
  unsafe {
    fa_nlen = pipeline_expr_field_access_name_len(arena, fa);
    sl_nlen = pipeline_expr_struct_lit_field_name_len(arena, lit, j);
  }
  if (fa_nlen <= 0 || fa_nlen > 63 || sl_nlen != fa_nlen) {
    return 0;
  }
  unsafe {
    pipeline_expr_field_access_name_into(arena, fa, &fa_name[0]);
    pipeline_expr_struct_lit_field_name_into(arena, lit, j, &sl_name[0]);
  }
  sl_eq = 1;
  sl_k = 0;
  while (sl_k < fa_nlen) {
    if (fa_name[sl_k] != sl_name[sl_k]) {
      sl_eq = 0;
    }
    sl_k = sl_k + 1;
  }
  if (sl_eq == 0) {
    return 0;
  }
  unsafe {
    init = pipeline_expr_struct_lit_init_ref(arena, lit, j);
  }
  if (init <= 0) {
    return 0;
  }
  return init;
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
  let n: i32 = 0;
  let init: i32 = 0;
  let j: i32 = 0;
  if (arena == (0 as *u8) || lit <= 0 || fa <= 0) {
    return 0;
  }
  unsafe {
    n = pipeline_expr_struct_lit_num_fields(arena, lit);
  }
  if (n <= 0) {
    return 0;
  }
  if (n > 64) {
    n = 64;
  }
  while (j < n) {
    if (init == 0) {
      init = w639_rs_lit_init_at(arena, lit, fa, j);
    }
    j = j + 1;
  }
  return init;
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
  let hop: i32 = 0;
  if (arena == (0 as *u8) || mod == (0 as *u8) || fa <= 0 || acc < 0) {
    return 0 - 1;
  }
  unsafe {
    hop = glue_field_access_effective_offset_c(arena, mod, fa);
  }
  if (hop < 0 || hop > 4095) {
    return 0 - 1;
  }
  if (acc > (4095 - hop)) {
    return 0 - 1;
  }
  return acc + hop;
}

/**
 * Address of a local struct used as a struct-literal field init,
 * plus the offsets of the fields inside that local.
 * f_leaf is the returned field. f_mid and f_outer are the fields
 * between that local and the leaf, or 0 when that hop is absent.
 * The field whose init is the local is not added: that offset sits
 * in the literal, not in the local. A pointer or slice local
 * returns 1 so the caller stays on emit_expr. A failed lvalue
 * returns 1. An encoder error returns -1.
 * EXPR_VAR = 3. TYPE_POINTER = 9. TYPE_SLICE = 11.
 * @param arena *u8 — AST arena; null returns 1
 * @param elf_ctx *u8 — encoder context
 * @param ctx *u8 — asm function context
 * @param ta i32 — 1 arm64
 * @param mod *u8 — module that owns the field layout; null returns 1
 * @param var_er i32 — VAR init expr; <=0 returns 1
 * @param f_leaf i32 — returned FIELD; <=0 returns 1
 * @param f_mid i32 — inner FIELD closer than the local, or 0
 * @param f_outer i32 — FIELD between f_mid and the local, or 0
 * @param f_deep i32 — FIELD between f_outer and the local, or 0
 * @return i32 — 0 address in x0; 1 decline; -1 encoder fail
 * PLATFORM: MACOS|ARM64.
 */
function w645_rs_lea_local_fields(
  arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, mod: *u8,
  var_er: i32, f_leaf: i32, f_mid: i32, f_outer: i32, f_deep: i32
): i32 {
  let off: i32 = 0;
  let ty: i32 = 0;
  let k: i32 = 0;
  let rc: i32 = 0;
  if (var_er <= 0 || f_leaf <= 0 || mod == (0 as *u8)) {
    return 1;
  }
  unsafe {
    ty = glue_var_decl_type_ref_elf_c(arena, ctx, var_er);
  }
  if (ty > 0) {
    unsafe {
      k = pipeline_type_kind_ord_at(arena, ty);
    }
    if (k == 9 || k == 11) {
      return 1;
    }
  }
  off = w645_rs_acc_field_off(arena, mod, f_leaf, 0);
  if (f_mid > 0 && off >= 0) {
    off = w645_rs_acc_field_off(arena, mod, f_mid, off);
  }
  if (f_outer > 0 && off >= 0) {
    off = w645_rs_acc_field_off(arena, mod, f_outer, off);
  }
  if (f_deep > 0 && off >= 0) {
    off = w645_rs_acc_field_off(arena, mod, f_deep, off);
  }
  if (off < 0) {
    return 1;
  }
  unsafe {
    rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, var_er, ctx, ta);
  }
  if (rc != 0) {
    return 1;
  }
  if (off != 0) {
    unsafe {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta);
    }
    if (rc != 0) {
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
 * than five fields stays on emit_expr. A FIELD whose root is a
 * STRUCT_LIT durables an ARRAY_LIT init, or takes the address of a
 * VAR init. A parent field (`return { inn: { xs: [...] } }.inn.xs`)
 * walks a STRUCT_LIT init. A parent whose init is a local struct
 * (`return { inn: src }.inn.xs`) takes that local's address plus
 * the fields inside it, not the literal's own field offset. The
 * walk is at most four parents. Any other STRUCT_LIT init stays on
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
  let ly: *u8 = 0 as *u8;
  let ret_op: i32 = 0;
  let rc: i32 = 0;
  let tj_len: i32 = 0;
  let tj_lbl: u8[256] = [];
  let ti: i32 = 0;
  let act: i32 = 0;
  let home: i32 = 0 - 1;
  let rsz: i32 = 0;
  /* 1 when a wide i32-vector array already copied each element to *x8. */
  let wide_copied: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ly = pipeline_asm_ctx_layout(ctx);
    ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (ret_op != 0) {
    let x86_off: i32 = 0 - 1;
    let x86_fwd: i32 = 0;
    let opk: i32 = 0;
    if (ta == 0) {
      unsafe {
        act = pipeline_asm_emit_ctx_sret_active_get();
        home = pipeline_asm_emit_ctx_sret_home_off_get();
        rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
        if (act != 0 && home > 0 && rsz > 16) {
          x86_off = w1521_rs_local_off(arena, ctx, ret_op);
          opk = pipeline_expr_kind_ord_at(arena, ret_op);
          if (opk == 48 || opk == 49) {
            x86_fwd = 1;
          }
        }
      }
    }
    if (x86_fwd != 0) {
      if (w1521_rs_fwd_call_x86(arena, elf_ctx, ret_op, ctx, ta, home) != 0) {
        return 0 - 1;
      }
    } else if (x86_off >= 0) {
      unsafe {
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, x86_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (w1521_rs_copy_x86(elf_ctx, home, rsz) < 0) {
        return 0 - 1;
      }
    } else if (w1521_rs_mid_named_field(arena, ret_op) != 0) {
      // Address of the field or local, then the existing 16-byte pair load.
      // A failed address falls through to the scalar expr path. Do not
      // scalar-load a successful address: that drops the high word.
      // PLATFORM: SHARED.
      unsafe {
        rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
      }
      if (rc == 0) {
        unsafe {
          rc = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        unsafe {
          rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
        }
        if (rc != 0) {
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
      let dur_ok: i32 = 0;
      let opk_d: i32 = 0;
      let mod_d: *u8 = 0 as *u8;
      let fi_d: i32 = 0;
      let rty_d: i32 = 0;
      let rk_d: i32 = 0;
      let elem_d: i32 = 0;
      let esz_d: i32 = 0;
      let peel_d: i32 = 0;
      let n_d: i32 = 0;
      let len_reg: i32 = 0;
      let win_d: i32 = 0;
      let decl_ty: i32 = 0;
      let arr_off: i32 = 0;
      let base_er: i32 = 0;
      let sl_nf: i32 = 0;
      let sl_i: i32 = 0;
      let sl_init: i32 = 0;
      let fa_nlen: i32 = 0;
      let sl_nlen: i32 = 0;
      let sl_eq: i32 = 0;
      let sl_k: i32 = 0;
      let fa_name: u8[64] = [];
      let sl_name: u8[64] = [];
      let v_slot: i32 = 0;
      let v_rc: i32 = 0;
      let v_mod: *u8 = 0 as *u8;
      let v_fi: i32 = 0;
      let v_rty: i32 = 0;
      let v_rk: i32 = 0;
      let v_elem: i32 = 0;
      let v_ek: i32 = 0;
      let v_opk: i32 = 0;
      let v_go: i32 = 0;
      let v_go8: i32 = 0;
      let v_enter: i32 = 0;
      let v_take: i32 = 0;
      let v_bin: i32 = 0;
      let v_cmp: i32 = 0;
      let vec_hit: i32 = 0;
      if (ta == 0 || ta == 1) {
        unsafe {
          opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
        }
        if (opk_d == 46) {
          unsafe {
            mod_d = pipeline_asm_emit_module_ref_c();
            fi_d = pipeline_asm_emit_func_index_c();
          }
          if (mod_d != (0 as *u8) && fi_d >= 0) {
            unsafe {
              rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
            }
            if (rty_d > 0) {
              unsafe {
                rk_d = pipeline_type_kind_ord_at(arena, rty_d);
              }
              // TYPE_ARRAY = 10. TYPE_SLICE is the arm below.
              if (rk_d == 10) {
                let wide_bytes: i32 = 0;
                let wide_n: i32 = 0;
                let wide_w: i32 = 0;
                let wide_i: i32 = 0;
                let wide_slot: i32 = 0;
                let wide_er: i32 = 0;
                let wide_rc: i32 = 0;
                let wide_off: i32 = 0;
                let wide_src: i32 = 0;
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
                  wide_bytes = glue_wide_i32_vec_array_bytes(arena, rty_d);
                }
                if (wide_bytes > 16) {
                  unsafe {
                    elem_d = pipeline_type_elem_ref_at(arena, rty_d);
                    wide_n = pipeline_type_array_size_at(arena, rty_d);
                    wide_w = glue_index_simd_elem_bytes_c(arena, elem_d);
                  }
                  if (wide_n <= 0 || wide_w <= 16 || wide_n * wide_w != wide_bytes) {
                    return 0 - 1;
                  }
                  // Same array type the frame walker reserved. Use only
                  // the base: the second element must not be slot+width.
                  unsafe {
                    wide_slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, rty_d);
                  }
                  if (wide_slot < 0) {
                    return 0 - 1;
                  }
                  if (ta == 1) {
                    unsafe {
                      act = pipeline_asm_emit_ctx_sret_active_get();
                      home = pipeline_asm_emit_ctx_sret_home_off_get();
                      rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
                    }
                  }
                  wide_i = 0;
                  while (wide_i < wide_n) {
                    unsafe {
                      wide_er = pipeline_expr_array_lit_elem_ref(arena, ret_op, wide_i);
                    }
                    if (wide_er > 0) {
                      wide_src = 0;
                      unsafe {
                        wide_rc = pipeline_expr_kind_ord_at(arena, wide_er);
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
                      if (wide_rc == 48 || wide_rc == 49) {
                        unsafe {
                          wide_rc = glue_emit_struct_type_let_init_elf_c(
                            arena, elf_ctx, wide_er, ctx, ta, elem_d, wide_slot);
                        }
                        if (wide_rc == 0) {
                          unsafe {
                            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, wide_slot, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                          wide_src = 1;
                        } else {
                          if (wide_rc == (0 - 1)) {
                            return 0 - 1;
                          }
                        }
                      } else {
                        if (wide_rc == 3 || wide_rc == 44 || wide_rc == 47 || wide_rc == 52) {
                          unsafe {
                            rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                              arena, elf_ctx, wide_er, ctx, ta);
                          }
                          if (rc == 0) {
                            wide_src = 1;
                          }
                        } else {
                          unsafe {
                            wide_rc = glue_emit_vector_type_let_init_elf_c(
                              arena, elf_ctx, wide_er, ctx, ta, wide_slot, elem_d);
                          }
                          if (wide_rc == 0) {
                            unsafe {
                              rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, wide_slot, ta);
                            }
                            if (rc != 0) {
                              return 0 - 1;
                            }
                            wide_src = 1;
                          }
                        }
                      }
                      if (wide_src == 1) {
                        wide_off = wide_i * wide_w;
                        if (ta == 1) {
                          wide_rc = w1521_rs_copy_x0_to_dest_off(elf_ctx, home, wide_off, wide_w);
                        } else {
                          wide_rc = w1521_rs_copy_x86_off(elf_ctx, home, wide_off, wide_w);
                        }
                        if (wide_rc < 0) {
                          return 0 - 1;
                        }
                      }
                    }
                    wide_i = wide_i + 1;
                  }
                  wide_copied = 1;
                  dur_ok = 1;
                } else {
                unsafe {
                  elem_d = pipeline_type_elem_ref_at(arena, rty_d);
                  esz_d = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d);
                  rc = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, esz_d, ta, ctx, elem_d);
                }
                if (rc == 0) {
                  dur_ok = 1;
                  // n * esz is the width the durable helper just wrote.
                  // 8 → one GPR. 16 → the existing pair load, except
                  // Windows (hidden pointer). Do not load a wider page:
                  // rsz > 16 still uses the sret copy below.
                  // PLATFORM: SHARED — LINUX|x86_64 · MACOS|ARM64.
                  let nbytes_d: i32 = 0;
                  let an_d: i32 = 0;
                  let win_sz: i32 = 0;
                  unsafe {
                    an_d = pipeline_type_array_size_at(arena, rty_d);
                  }
                  if (an_d > 0 && esz_d > 0) {
                    nbytes_d = an_d * esz_d;
                  }
                  if (nbytes_d == 16 && ta == 0) {
                    unsafe {
                      win_sz = link_abi_host_is_windows();
                    }
                  }
                  if (nbytes_d == 8 || (nbytes_d == 16 && win_sz == 0)) {
                    if (nbytes_d == 8) {
                      unsafe {
                        rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                      }
                    } else {
                      unsafe {
                        rc = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
                      }
                    }
                    if (rc != 0) {
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
              if (rk_d == 8) {
                let nb: u8[8] = [];
                let nl: i32 = 0;
                let hit: i32 = 0;
                unsafe {
                  nl = pipeline_type_named_name_into(arena, rty_d, &nb[0]);
                }
                if (nl == 5) {
                  if (nb[1] == 51) {
                    if (nb[2] == 50) {
                      if (nb[3] == 120) {
                        if (nb[4] == 52) {
                          if (nb[0] == 105) {
                            hit = 1;
                          }
                          if (nb[0] == 102) {
                            hit = 1;
                          }
                          if (nb[0] == 117) {
                            hit = 1;
                          }
                        }
                      }
                    }
                  }
                }
                if (hit != 0) {
                  vec_hit = 1;
                }
              }
              if (rk_d == 13) {
                let f32v: i32 = 0;
                let vsz: i32 = 0;
                unsafe {
                  f32v = glue_vector_elem_is_f32_c(arena, rty_d);
                }
                if (f32v != 0) {
                  unsafe {
                    vsz = glue_type_size_simple(mod_d, arena, rty_d, 0);
                  }
                  if (vsz == 16) {
                    vec_hit = 1;
                  }
                }
              }
              if (vec_hit != 0) {
                if (ta == 1) {
                  unsafe {
                    rc = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(
                      arena, elf_ctx, ret_op, 4, ta, ctx, 0);
                  }
                  if (rc == 0) {
                    unsafe {
                      rc = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
                    }
                    if (rc != 0) {
                      return 0 - 1;
                    }
                    dur_ok = 1;
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
      if (dur_ok == 0 && (ta == 0 || ta == 1)) {
        if (ta == 0) {
          unsafe {
            win_d = link_abi_host_is_windows();
          }
        }
        if (win_d == 0) {
          unsafe {
            peel_d = glue_peel_as_array_slice_ascription_c(arena, ret_op);
          }
          if (peel_d <= 0) {
            peel_d = ret_op;
          }
          unsafe {
            opk_d = pipeline_expr_kind_ord_at(arena, peel_d);
          }
          if (opk_d == 46) {
            unsafe {
              mod_d = pipeline_asm_emit_module_ref_c();
              fi_d = pipeline_asm_emit_func_index_c();
            }
            if (mod_d != (0 as *u8) && fi_d >= 0) {
              unsafe {
                rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
              }
              if (rty_d > 0) {
                unsafe {
                  rk_d = pipeline_type_kind_ord_at(arena, rty_d);
                }
                // TYPE_SLICE = 11. TYPE_ARRAY stays on the arm above.
                if (rk_d == 11) {
                  unsafe {
                    n_d = pipeline_expr_array_lit_num_elems_at(arena, peel_d);
                    elem_d = pipeline_type_elem_ref_at(arena, rty_d);
                    esz_d = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d);
                  }
                  if (n_d >= 0 && n_d <= 1024) {
                    unsafe {
                      rc = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, peel_d, esz_d, ta, ctx, elem_d);
                    }
                    if (rc == 0) {
                      unsafe {
                        rc = backend_enc_push_rax_arch(elf_ctx, ta);
                      }
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      unsafe {
                        rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d, 0, ta);
                      }
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      if (ta == 1) {
                        len_reg = 1;
                      } else {
                        len_reg = 2;
                      }
                      unsafe {
                        rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta);
                      }
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      unsafe {
                        rc = backend_enc_pop_rax_arch(elf_ctx, ta);
                      }
                      if (rc != 0) {
                        return 0 - 1;
                      }
                      dur_ok = 1;
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
          if (dur_ok == 0) {
            unsafe {
              opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
            }
            if (opk_d == 3) {
              unsafe {
                mod_d = pipeline_asm_emit_module_ref_c();
                fi_d = pipeline_asm_emit_func_index_c();
              }
              if (mod_d != (0 as *u8) && fi_d >= 0) {
                unsafe {
                  rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
                }
                if (rty_d > 0) {
                  unsafe {
                    rk_d = pipeline_type_kind_ord_at(arena, rty_d);
                  }
                  // TYPE_SLICE = 11. TYPE_ARRAY = 10 stays on emit_expr.
                  if (rk_d == 11) {
                    unsafe {
                      decl_ty = glue_var_decl_type_ref_elf_c(arena, ctx, ret_op);
                    }
                    if (decl_ty > 0) {
                      unsafe {
                        rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                      }
                      if (rk_d == 10) {
                        unsafe {
                          n_d = pipeline_type_array_size_at(arena, decl_ty);
                          arr_off = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op);
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
                        if (n_d >= 0 && n_d <= 1024 && arr_off >= 0) {
                          unsafe {
                            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                          unsafe {
                            peel_d = glue_emit_func_param_is_indirect_array_slot_c(arena, mod_d, ret_op);
                          }
                          if (peel_d != 0) {
                            unsafe {
                              rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                            }
                            if (rc != 0) {
                              return 0 - 1;
                            }
                          }
                          unsafe {
                            rc = backend_enc_push_rax_arch(elf_ctx, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                          unsafe {
                            rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d, 0, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                          if (ta == 1) {
                            len_reg = 1;
                          } else {
                            len_reg = 2;
                          }
                          unsafe {
                            rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                          unsafe {
                            rc = backend_enc_pop_rax_arch(elf_ctx, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                          dur_ok = 1;
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
          if (dur_ok == 0) {
            unsafe {
              opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
            }
            if (opk_d == 3) {
              unsafe {
                mod_d = pipeline_asm_emit_module_ref_c();
                fi_d = pipeline_asm_emit_func_index_c();
              }
              if (mod_d != (0 as *u8) && fi_d >= 0) {
                unsafe {
                  rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
                }
                if (rty_d > 0) {
                  unsafe {
                    rk_d = pipeline_type_kind_ord_at(arena, rty_d);
                  }
                  if (rk_d == 11) {
                    unsafe {
                      decl_ty = glue_var_decl_type_ref_elf_c(arena, ctx, ret_op);
                    }
                    if (decl_ty > 0) {
                      unsafe {
                        rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                      }
                      if (rk_d == 11) {
                        let sl_nm: u8[64] = [];
                        let sl_n: i32 = 0;
                        let sl_pty: i32 = 0;
                        unsafe {
                          sl_n = pipeline_expr_var_name_len(arena, ret_op);
                        }
                        if (sl_n > 0 && sl_n <= 63) {
                          unsafe {
                            pipeline_expr_var_name_into(arena, ret_op, &sl_nm[0]);
                          }
                          unsafe {
                            sl_pty = pipeline_module_func_param_type_ref_for_name(
                              mod_d, fi_d, &sl_nm[0], pipeline_expr_var_name_len(arena, ret_op));
                          }
                          if (sl_pty > 0) {
                            unsafe {
                              rk_d = pipeline_type_kind_ord_at(arena, sl_pty);
                            }
                            if (rk_d == 11) {
                              unsafe {
                                arr_off = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op);
                              }
                              if (arr_off >= 0) {
                                unsafe {
                                  rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc = backend_enc_push_rax_arch(elf_ctx, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc = backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                if (ta == 1) {
                                  len_reg = 1;
                                } else {
                                  len_reg = 2;
                                }
                                unsafe {
                                  rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc = backend_enc_pop_rax_arch(elf_ctx, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                unsafe {
                                  rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                dur_ok = 1;
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
          if (dur_ok == 0) {
            unsafe {
              opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
            }
            // EXPR_FIELD_ACCESS = 44.
            if (opk_d == 44) {
              unsafe {
                mod_d = pipeline_asm_emit_module_ref_c();
                fi_d = pipeline_asm_emit_func_index_c();
              }
              if (mod_d != (0 as *u8) && fi_d >= 0) {
                unsafe {
                  rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
                }
                if (rty_d > 0) {
                  unsafe {
                    rk_d = pipeline_type_kind_ord_at(arena, rty_d);
                  }
                  // TYPE_SLICE = 11. TYPE_ARRAY = 10 stays on emit_expr.
                  if (rk_d == 11) {
                    unsafe {
                      base_er = pipeline_expr_field_access_base_ref(arena, ret_op);
                    }
                    if (base_er > 0) {
                      unsafe {
                        opk_d = pipeline_expr_kind_ord_at(arena, base_er);
                      }
                      // EXPR_VAR = 3. STRUCT_LIT (45) is not this arm.
                      if (opk_d == 3) {
                        unsafe {
                          decl_ty = glue_field_access_field_type_ref_c(arena, mod_d, ret_op);
                        }
                        if (decl_ty > 0) {
                          unsafe {
                            rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                          }
                          // TYPE_ARRAY = 10. A slice field stays on emit_expr.
                          if (rk_d == 10) {
                            unsafe {
                              n_d = pipeline_type_array_size_at(arena, decl_ty);
                              arr_off = glue_var_expr_stack_off_elf_c(arena, ctx, base_er);
                              esz_d = glue_field_access_effective_offset_c(arena, mod_d, ret_op);
                            }
                            // esz_d is the field byte offset here, not an
                            // element size. Negative means the helper missed.
                            if (n_d >= 0 && n_d <= 1024 && arr_off >= 0 && esz_d >= 0) {
                              unsafe {
                                rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              if (esz_d != 0) {
                                unsafe {
                                  rc = backend_enc_add_imm_to_rax_arch(elf_ctx, esz_d, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                              }
                              unsafe {
                                rc = backend_enc_push_rax_arch(elf_ctx, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d, 0, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              if (ta == 1) {
                                len_reg = 1;
                              } else {
                                len_reg = 2;
                              }
                              unsafe {
                                rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc = backend_enc_pop_rax_arch(elf_ctx, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              dur_ok = 1;
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
                    if (dur_ok == 0 && opk_d == 45) {
                      unsafe {
                        fa_nlen = pipeline_expr_field_access_name_len(arena, ret_op);
                        sl_nf = pipeline_expr_struct_lit_num_fields(arena, base_er);
                      }
                      sl_init = 0;
                      if (fa_nlen > 0 && fa_nlen <= 63 && sl_nf > 0 && sl_nf <= 64) {
                        unsafe {
                          pipeline_expr_field_access_name_into(arena, ret_op, &fa_name[0]);
                        }
                        sl_i = 0;
                        while (sl_i < sl_nf) {
                          if (sl_init == 0) {
                            unsafe {
                              sl_nlen = pipeline_expr_struct_lit_field_name_len(arena, base_er, sl_i);
                            }
                            sl_eq = 0;
                            if (sl_nlen == fa_nlen) {
                              unsafe {
                                pipeline_expr_struct_lit_field_name_into(arena, base_er, sl_i, &sl_name[0]);
                              }
                              sl_eq = 1;
                              sl_k = 0;
                              while (sl_k < fa_nlen) {
                                if (fa_name[sl_k] != sl_name[sl_k]) {
                                  sl_eq = 0;
                                }
                                sl_k = sl_k + 1;
                              }
                            }
                            if (sl_eq != 0) {
                              unsafe {
                                sl_init = pipeline_expr_struct_lit_init_ref(arena, base_er, sl_i);
                              }
                            }
                          }
                          sl_i = sl_i + 1;
                        }
                      }
                      if (sl_init > 0) {
                        unsafe {
                          opk_d = pipeline_expr_kind_ord_at(arena, sl_init);
                        }
                        // EXPR_ARRAY_LIT = 46. The durable helper rejects
                        // every other kind, so a non-literal init falls
                        // through.
                        if (opk_d == 46) {
                          unsafe {
                            n_d = pipeline_expr_array_lit_num_elems_at(arena, sl_init);
                            elem_d = pipeline_type_elem_ref_at(arena, rty_d);
                            esz_d = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d);
                          }
                          if (n_d >= 0 && n_d <= 1024) {
                            unsafe {
                              rc = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, sl_init, esz_d, ta, ctx, elem_d);
                            }
                            if (rc == 0) {
                              unsafe {
                                rc = backend_enc_push_rax_arch(elf_ctx, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d, 0, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              if (ta == 1) {
                                len_reg = 1;
                              } else {
                                len_reg = 2;
                              }
                              unsafe {
                                rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              unsafe {
                                rc = backend_enc_pop_rax_arch(elf_ctx, ta);
                              }
                              if (rc != 0) {
                                return 0 - 1;
                              }
                              dur_ok = 1;
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
          if (dur_ok == 0) {
            unsafe {
              opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
            }
            // EXPR_INDEX = 47.
            if (opk_d == 47) {
              unsafe {
                mod_d = pipeline_asm_emit_module_ref_c();
                fi_d = pipeline_asm_emit_func_index_c();
              }
              if (mod_d != (0 as *u8) && fi_d >= 0) {
                unsafe {
                  rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
                }
                if (rty_d > 0) {
                  unsafe {
                    rk_d = pipeline_type_kind_ord_at(arena, rty_d);
                  }
                  // TYPE_SLICE = 11. TYPE_ARRAY = 10 stays on emit_expr.
                  if (rk_d == 11) {
                    unsafe {
                      base_er = pipeline_expr_index_base_ref(arena, ret_op);
                    }
                    if (base_er > 0) {
                      unsafe {
                        opk_d = pipeline_expr_kind_ord_at(arena, base_er);
                      }
                      // EXPR_VAR = 3. A field or another index stays out.
                      if (opk_d == 3) {
                        unsafe {
                          decl_ty = glue_var_decl_type_ref_elf_c(arena, ctx, base_er);
                        }
                        if (decl_ty > 0) {
                          unsafe {
                            rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                          }
                          // TYPE_ARRAY = 10. A slice variable stays on emit_expr.
                          if (rk_d == 10) {
                            unsafe {
                              elem_d = pipeline_type_elem_ref_at(arena, decl_ty);
                            }
                            if (elem_d > 0) {
                              unsafe {
                                rk_d = pipeline_type_kind_ord_at(arena, elem_d);
                              }
                              // The row itself is TYPE_ARRAY. Its size is
                              // the slice length. A scalar element is not
                              // a row and stays on emit_expr.
                              if (rk_d == 10) {
                                unsafe {
                                  n_d = pipeline_type_array_size_at(arena, elem_d);
                                }
                                if (n_d >= 0 && n_d <= 1024) {
                                  unsafe {
                                    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc = backend_enc_push_rax_arch(elf_ctx, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_d, 0, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  if (ta == 1) {
                                    len_reg = 1;
                                  } else {
                                    len_reg = 2;
                                  }
                                  unsafe {
                                    rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_reg, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  dur_ok = 1;
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
                  if (dur_ok == 0 && rk_d == 10) {
                    unsafe {
                      base_er = pipeline_expr_index_base_ref(arena, ret_op);
                    }
                    if (base_er > 0) {
                      unsafe {
                        opk_d = pipeline_expr_kind_ord_at(arena, base_er);
                      }
                      // EXPR_VAR = 3. A field or another index stays out.
                      if (opk_d == 3) {
                        unsafe {
                          decl_ty = glue_var_decl_type_ref_elf_c(arena, ctx, base_er);
                        }
                        if (decl_ty > 0) {
                          unsafe {
                            rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                          }
                          if (rk_d == 10) {
                            unsafe {
                              elem_d = pipeline_type_elem_ref_at(arena, decl_ty);
                            }
                            if (elem_d > 0) {
                              unsafe {
                                rk_d = pipeline_type_kind_ord_at(arena, elem_d);
                              }
                              if (rk_d == 10) {
                                unsafe {
                                  n_d = pipeline_type_array_size_at(arena, elem_d);
                                  elem_d = pipeline_type_elem_ref_at(arena, elem_d);
                                  esz_d = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d);
                                }
                                // 8 bytes is one GPR. Do not load a wider row.
                                if (n_d > 0 && n_d <= 1024 && esz_d > 0 && esz_d <= 16 && n_d * esz_d == 8) {
                                  unsafe {
                                    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  unsafe {
                                    rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                  dur_ok = 1;
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
       * same let-init that `let v: Vec8i = 3` uses. A lane binop
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
        if (dur_ok == 0) {
          unsafe {
            v_opk = pipeline_expr_kind_ord_at(arena, ret_op);
          }
          if (v_opk == 0) {
            v_go = 1;
            v_go8 = 1;
          }
          if (v_opk == 1) {
            v_go8 = 1;
          }
          if (v_opk == 22) {
            v_go = 1;
            v_go8 = 1;
          }
          if (v_opk == 2) {
            v_go8 = 1;
          }
          if (v_opk == 23) {
            v_go = 1;
            v_go8 = 1;
          }
          if (v_opk == 25) {
            v_go = 1;
          }
          if (v_opk == 27) {
            v_go = 1;
          }
          unsafe {
            v_bin = glue_is_vector_lane_scalar_binop_ko(v_opk);
          }
          if (v_bin != 0) {
            v_go = 1;
            v_go8 = 1;
          }
          unsafe {
            v_cmp = vlet_lane_cmp_ko(v_opk);
          }
          if (v_cmp != 0) {
            v_go = 1;
            v_go8 = 1;
          }
          if (v_go != 0) {
            v_enter = 1;
          }
          if (v_go8 != 0) {
            v_enter = 1;
          }
          if (v_enter != 0) {
            unsafe {
              v_mod = pipeline_asm_emit_module_ref_c();
              v_fi = pipeline_asm_emit_func_index_c();
            }
            if (v_mod != (0 as *u8)) {
              if (v_fi >= 0) {
                unsafe {
                  v_rty = pipeline_module_func_return_type_at(v_mod, v_fi);
                }
                if (v_rty > 0) {
                  unsafe {
                    v_rk = pipeline_type_kind_ord_at(arena, v_rty);
                  }
                  if (v_rk == 13) {
                    if (v_go != 0) {
                      unsafe {
                        v_elem = pipeline_type_elem_ref_at(arena, v_rty);
                      }
                      if (v_elem > 0) {
                        unsafe {
                          v_ek = pipeline_type_kind_ord_at(arena, v_elem);
                        }
                        if (v_ek == 0) {
                          v_take = 1;
                        }
                      }
                    }
                  }
                  if (v_rk == 8) {
                    if (v_go8 != 0) {
                      unsafe {
                        rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
                      }
                      if (rsz > 16) {
                        v_take = 1;
                      }
                    }
                  }
                  if (v_take != 0) {
                    unsafe {
                      v_slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, v_rty);
                    }
                    if (v_slot < 0) {
                      return 0 - 1;
                    }
                    unsafe {
                      v_rc = glue_emit_vector_type_let_init_elf_c(
                        arena, elf_ctx, ret_op, ctx, ta, v_slot, v_rty);
                    }
                    if (v_rc == 0) {
                      unsafe {
                        v_rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, v_slot, ta);
                      }
                      if (v_rc != 0) {
                        return 0 - 1;
                      }
                      dur_ok = 1;
                    } else {
                      if (v_rc != (0 - 3)) {
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
       * address plus the fields inside it. At most four parents.
       * A field past slot 63, a pointer element, a slice
       * element, a pointer field, or a pointer root
       * stays on emit_expr.
       * Hops are unrolled: a while that calls externs is dropped
       * by this compiler.
       * PLATFORM: MACOS|ARM64. */
      if (dur_ok == 0 && ta == 1) {
        unsafe {
          opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
        }
        if (opk_d == 44) {
          unsafe {
            mod_d = pipeline_asm_emit_module_ref_c();
            fi_d = pipeline_asm_emit_func_index_c();
          }
          if (mod_d != (0 as *u8) && fi_d >= 0) {
            unsafe {
              rty_d = pipeline_module_func_return_type_at(mod_d, fi_d);
            }
            if (rty_d > 0) {
              unsafe {
                rk_d = pipeline_type_kind_ord_at(arena, rty_d);
              }
              if (rk_d == 10) {
                unsafe {
                  base_er = pipeline_expr_field_access_base_ref(arena, ret_op);
                }
                if (base_er > 0) {
                  unsafe {
                    decl_ty = glue_field_access_field_type_ref_c(arena, mod_d, ret_op);
                  }
                  if (decl_ty > 0) {
                    unsafe {
                      rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                    }
                    if (rk_d == 10) {
                      unsafe {
                        n_d = pipeline_type_array_size_at(arena, decl_ty);
                        elem_d = pipeline_type_elem_ref_at(arena, decl_ty);
                      }
                      esz_d = 0;
                      if (elem_d > 0) {
                        unsafe {
                          esz_d = glue_type_named_layout_size_any_module_elf_c(arena, elem_d);
                        }
                        if (esz_d <= 0) {
                          unsafe {
                            esz_d = glue_array_lit_force_esz_from_elem_type_c(arena, elem_d);
                          }
                        }
                      }
                      peel_d = 0;
                      if (n_d > 0 && n_d <= 1024 && esz_d > 0 && esz_d <= 256) {
                        peel_d = n_d * esz_d;
                      }
                      if (peel_d > 16) {
                        let sum_off: i32 = 0;
                        let root_er: i32 = base_er;
                        let hop: i32 = 0;
                        let fold_ok: i32 = 1;
                        unsafe {
                          sum_off = glue_field_access_effective_offset_c(arena, mod_d, ret_op);
                        }
                        if (sum_off < 0 || sum_off > 4095) {
                          fold_ok = 0;
                        }
                        // Parent 1. -2 means the immediate base is the root.
                        if (fold_ok != 0) {
                          hop = w635_rs_fold_parent(arena, mod_d, root_er);
                          if (hop == (0 - 1)) {
                            fold_ok = 0;
                          }
                          if (hop >= 0) {
                            if (sum_off > (4095 - hop)) {
                              fold_ok = 0;
                            } else {
                              sum_off = sum_off + hop;
                              unsafe {
                                root_er = pipeline_expr_field_access_base_ref(arena, root_er);
                              }
                              hop = w635_rs_fold_parent(arena, mod_d, root_er);
                              if (hop == (0 - 1)) {
                                fold_ok = 0;
                              }
                              if (hop >= 0) {
                                if (sum_off > (4095 - hop)) {
                                  fold_ok = 0;
                                } else {
                                  sum_off = sum_off + hop;
                                  unsafe {
                                    root_er = pipeline_expr_field_access_base_ref(arena, root_er);
                                  }
                                  hop = w635_rs_fold_parent(arena, mod_d, root_er);
                                  if (hop == (0 - 1)) {
                                    fold_ok = 0;
                                  }
                                  if (hop >= 0) {
                                    if (sum_off > (4095 - hop)) {
                                      fold_ok = 0;
                                    } else {
                                      sum_off = sum_off + hop;
                                      unsafe {
                                        root_er = pipeline_expr_field_access_base_ref(arena, root_er);
                                      }
                                      hop = w635_rs_fold_parent(arena, mod_d, root_er);
                                      if (hop == (0 - 1)) {
                                        fold_ok = 0;
                                      }
                                      if (hop >= 0) {
                                        if (sum_off > (4095 - hop)) {
                                          fold_ok = 0;
                                        } else {
                                          sum_off = sum_off + hop;
                                          unsafe {
                                            root_er = pipeline_expr_field_access_base_ref(arena, root_er);
                                          }
                                          hop = w635_rs_fold_parent(arena, mod_d, root_er);
                                          if (hop != (0 - 2)) {
                                            fold_ok = 0;
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
                        if (fold_ok != 0 && root_er > 0) {
                          unsafe {
                            opk_d = pipeline_expr_kind_ord_at(arena, root_er);
                          }
                          if (opk_d == 3) {
                            // One-field `w.xs` keeps the old path. A chain
                            // refuses a pointer root (kind 9).
                            if (root_er != base_er) {
                              unsafe {
                                decl_ty = glue_var_decl_type_ref_elf_c(arena, ctx, root_er);
                              }
                              if (decl_ty > 0) {
                                unsafe {
                                  rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                                }
                                if (rk_d == 9) {
                                  fold_ok = 0;
                                }
                              }
                            }
                            if (fold_ok != 0) {
                              unsafe {
                                arr_off = glue_var_expr_stack_off_elf_c(arena, ctx, root_er);
                              }
                              if (arr_off >= 0 && sum_off >= 0 && sum_off <= 4095) {
                                unsafe {
                                  rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, arr_off, ta);
                                }
                                if (rc != 0) {
                                  return 0 - 1;
                                }
                                if (sum_off != 0) {
                                  unsafe {
                                    rc = backend_enc_add_imm_to_rax_arch(elf_ctx, sum_off, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                }
                                dur_ok = 1;
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
                          if ((opk_d == 47 || opk_d == 52) && dur_ok == 0) {
                            decl_ty = 0;
                            unsafe {
                              decl_ty = pipeline_expr_resolved_type_ref(arena, root_er);
                            }
                            rk_d = 0;
                            if (decl_ty > 0) {
                              unsafe {
                                rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                              }
                            }
                            if (rk_d != 9 && rk_d != 11) {
                              unsafe {
                                rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                                  arena, elf_ctx, root_er, ctx, ta);
                              }
                              if (rc == 0) {
                                if (sum_off != 0) {
                                  unsafe {
                                    rc = backend_enc_add_imm_to_rax_arch(elf_ctx, sum_off, ta);
                                  }
                                  if (rc != 0) {
                                    return 0 - 1;
                                  }
                                }
                                dur_ok = 1;
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
                          if (opk_d == 45 && dur_ok == 0) {
                            let fa1: i32 = 0;
                            let fa2: i32 = 0;
                            let fa3: i32 = 0;
                            let fa4: i32 = 0;
                            let nb: i32 = 0;
                            let cur: i32 = root_er;
                            let bwalk: i32 = 0;
                            let step_ok: i32 = 1;
                            /* Parents between the leaf field and the
                             * root literal. fa1 is the leaf's base.
                             * fa4 is the field directly on the root
                             * when four parents were folded.
                             * PLATFORM: MACOS|ARM64. */
                            if (base_er != root_er && base_er > 0) {
                              fa1 = base_er;
                              nb = 1;
                              unsafe {
                                bwalk = pipeline_expr_field_access_base_ref(arena, fa1);
                              }
                              if (bwalk != root_er && bwalk > 0) {
                                fa2 = bwalk;
                                nb = 2;
                                unsafe {
                                  bwalk = pipeline_expr_field_access_base_ref(arena, fa2);
                                }
                                if (bwalk != root_er && bwalk > 0) {
                                  fa3 = bwalk;
                                  nb = 3;
                                  unsafe {
                                    bwalk = pipeline_expr_field_access_base_ref(arena, fa3);
                                  }
                                  if (bwalk != root_er && bwalk > 0) {
                                    fa4 = bwalk;
                                    nb = 4;
                                  }
                                }
                              }
                            }
                            if (nb == 4) {
                              cur = w643_rs_named_init(arena, cur, fa4);
                              step_ok = 0;
                              if (cur > 0) {
                                unsafe {
                                  opk_d = pipeline_expr_kind_ord_at(arena, cur);
                                }
                                if (opk_d == 45) {
                                  step_ok = 1;
                                }
                                /* fa4's init is the local. Offsets inside
                                 * it are fa3, fa2, fa1, and the leaf.
                                 * PLATFORM: MACOS|ARM64. */
                                if (opk_d == 3 && dur_ok == 0) {
                                  unsafe {
                                    rc = w645_rs_lea_local_fields(
                                      arena, elf_ctx, ctx, ta, mod_d, cur, ret_op, fa1, fa2, fa3);
                                  }
                                  if (rc < 0) {
                                    return 0 - 1;
                                  }
                                  if (rc == 0) {
                                    dur_ok = 1;
                                  }
                                }
                              }
                            }
                            if (step_ok != 0 && nb >= 3) {
                              cur = w643_rs_named_init(arena, cur, fa3);
                              step_ok = 0;
                              if (cur > 0) {
                                unsafe {
                                  opk_d = pipeline_expr_kind_ord_at(arena, cur);
                                }
                                if (opk_d == 45) {
                                  step_ok = 1;
                                }
                                /* fa3's init is the local. Offsets inside
                                 * it are fa2, fa1, and the leaf.
                                 * PLATFORM: MACOS|ARM64. */
                                if (opk_d == 3 && dur_ok == 0) {
                                  unsafe {
                                    rc = w645_rs_lea_local_fields(
                                      arena, elf_ctx, ctx, ta, mod_d, cur, ret_op, fa1, fa2, 0);
                                  }
                                  if (rc < 0) {
                                    return 0 - 1;
                                  }
                                  if (rc == 0) {
                                    dur_ok = 1;
                                  }
                                }
                              }
                            }
                            if (step_ok != 0 && nb >= 2) {
                              cur = w643_rs_named_init(arena, cur, fa2);
                              step_ok = 0;
                              if (cur > 0) {
                                unsafe {
                                  opk_d = pipeline_expr_kind_ord_at(arena, cur);
                                }
                                if (opk_d == 45) {
                                  step_ok = 1;
                                }
                                /* fa2's init is the local. Offsets inside
                                 * it are fa1 and the leaf.
                                 * PLATFORM: MACOS|ARM64. */
                                if (opk_d == 3 && dur_ok == 0) {
                                  unsafe {
                                    rc = w645_rs_lea_local_fields(
                                      arena, elf_ctx, ctx, ta, mod_d, cur, ret_op, fa1, 0, 0);
                                  }
                                  if (rc < 0) {
                                    return 0 - 1;
                                  }
                                  if (rc == 0) {
                                    dur_ok = 1;
                                  }
                                }
                              }
                            }
                            if (step_ok != 0 && nb >= 1) {
                              cur = w643_rs_named_init(arena, cur, fa1);
                              step_ok = 0;
                              if (cur > 0) {
                                unsafe {
                                  opk_d = pipeline_expr_kind_ord_at(arena, cur);
                                }
                                if (opk_d == 45) {
                                  step_ok = 1;
                                }
                                /* fa1's init is the local. The only offset
                                 * inside it is the leaf field.
                                 * PLATFORM: MACOS|ARM64. */
                                if (opk_d == 3 && dur_ok == 0) {
                                  unsafe {
                                    rc = w645_rs_lea_local_fields(
                                      arena, elf_ctx, ctx, ta, mod_d, cur, ret_op, 0, 0, 0);
                                  }
                                  if (rc < 0) {
                                    return 0 - 1;
                                  }
                                  if (rc == 0) {
                                    dur_ok = 1;
                                  }
                                }
                              }
                            }
                            sl_init = 0;
                            if (step_ok != 0) {
                              sl_init = w643_rs_named_init(arena, cur, ret_op);
                            }
                            if (sl_init > 0) {
                              unsafe {
                                opk_d = pipeline_expr_kind_ord_at(arena, sl_init);
                              }
                              if (opk_d == 46 && esz_d > 0 && elem_d > 0) {
                                unsafe {
                                  rc = glue_asm_emit_array_lit_durable_ptr_rax_elf_c(
                                    arena, elf_ctx, sl_init, esz_d, ta, ctx, elem_d);
                                }
                                if (rc == 0) {
                                  dur_ok = 1;
                                }
                              }
                              /* Local array stored in the literal.
                               * lvalue leaves its address. A failed
                               * lvalue stays on emit_expr.
                               * PLATFORM: MACOS|ARM64. */
                              if (opk_d == 3 && dur_ok == 0) {
                                unsafe {
                                  rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                                    arena, elf_ctx, sl_init, ctx, ta);
                                }
                                if (rc == 0) {
                                  dur_ok = 1;
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
      if (dur_ok == 0 && ta == 1) {
        unsafe {
          opk_d = pipeline_expr_kind_ord_at(arena, ret_op);
        }
        if (opk_d == 44) {
          unsafe {
            rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
          }
          if (rsz > 16) {
            unsafe {
              mod_d = pipeline_asm_emit_module_ref_c();
            }
            decl_ty = 0;
            if (mod_d != (0 as *u8)) {
              unsafe {
                decl_ty = glue_field_access_field_type_ref_c(arena, mod_d, ret_op);
              }
            }
            rk_d = 0;
            if (decl_ty > 0) {
              unsafe {
                rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
              }
            }
            if (rk_d == 8) {
              unsafe {
                base_er = pipeline_expr_field_access_base_ref(arena, ret_op);
              }
              if (base_er > 0) {
                unsafe {
                  opk_d = pipeline_expr_kind_ord_at(arena, base_er);
                }
                if (opk_d == 47) {
                  decl_ty = 0;
                  unsafe {
                    decl_ty = pipeline_expr_resolved_type_ref(arena, base_er);
                  }
                  rk_d = 0;
                  if (decl_ty > 0) {
                    unsafe {
                      rk_d = pipeline_type_kind_ord_at(arena, decl_ty);
                    }
                  }
                  if (rk_d != 9 && rk_d != 11) {
                    let sum_off: i32 = 0;
                    unsafe {
                      sum_off = glue_field_access_effective_offset_c(arena, mod_d, ret_op);
                    }
                    if (sum_off >= 0 && sum_off <= 4095) {
                      unsafe {
                        rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(
                          arena, elf_ctx, base_er, ctx, ta);
                      }
                      if (rc == 0) {
                        if (sum_off != 0) {
                          unsafe {
                            rc = backend_enc_add_imm_to_rax_arch(elf_ctx, sum_off, ta);
                          }
                          if (rc != 0) {
                            return 0 - 1;
                          }
                        }
                        dur_ok = 1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (dur_ok == 0) {
        unsafe {
          rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      // w1521: Windows builds a > 16-byte STRUCT_LIT (or other aggregate
      // operand) in a frame temp and leaves its address in rax; copy it into
      // the hidden dest (Linux pabi writes the dest itself). A durable
      // TYPE_ARRAY pointer is the same source address. PLATFORM: WINDOWS.
      if (ta == 0 && act != 0 && home > 0 && rsz > 16) {
        let on_win: i32 = 0;
        unsafe {
          on_win = link_abi_host_is_windows();
        }
        if (on_win != 0) {
          if (wide_copied != 0) {
            unsafe {
              rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
          }
          if (w1521_rs_copy_x86(elf_ctx, home, rsz) < 0) {
            return 0 - 1;
          }
        }
      }
    }
    if (ta == 1) {
      // A wide fill already read home. Let-init of an element must not
      // replace that slot before the self-copy. PLATFORM: MACOS|ARM64.
      if (wide_copied == 0) {
        unsafe {
          act = pipeline_asm_emit_ctx_sret_active_get();
          home = pipeline_asm_emit_ctx_sret_home_off_get();
          rsz = pipeline_asm_emit_ctx_sret_ret_sz_get();
        }
      }
      if (act != 0 && home >= 0 && rsz > 16) {
        if (wide_copied != 0) {
          if (w1521_rs_load_dest_x0(elf_ctx, home) != 0) {
            return 0 - 1;
          }
        }
        if (w1521_rs_copy_to_dest(elf_ctx, home, rsz) < 0) {
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
    if ((ta == 0 || ta == 1) && ret_op != 0) {
      let mod_f: *u8 = 0 as *u8;
      let fi_f: i32 = 0;
      let rty_f: i32 = 0;
      let rkind_f: i32 = 0;
      unsafe {
        mod_f = pipeline_asm_emit_module_ref_c();
        fi_f = pipeline_asm_emit_func_index_c();
      }
      if (mod_f != (0 as *u8) && fi_f >= 0) {
        unsafe {
          rty_f = pipeline_module_func_return_type_at(mod_f, fi_f);
        }
        if (rty_f > 0) {
          unsafe {
            rkind_f = pipeline_type_kind_ord_at(arena, rty_f);
          }
          if (rkind_f == 15 || rkind_f == 14) {
            unsafe {
              rc = backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
          }
        }
      }
    }
  }
  unsafe {
    rc = glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_async_cps_emit_phase_reset(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (ly == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    tj_len = pipe_load_i32_le(ly, 1520);
  }
  if (tj_len <= 0) {
    return 0 - 1;
  }
  ti = 0;
  while (ti < tj_len && ti < 128) {
    unsafe {
      tj_lbl[ti] = ly[1392 + ti];
    }
    ti = ti + 1;
  }
  unsafe {
    return backend_enc_jmp_arch(elf_ctx, &tj_lbl[0], tj_len, ta);
  }
}
