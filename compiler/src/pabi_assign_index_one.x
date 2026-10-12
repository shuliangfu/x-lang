// One strong glue_emit_assign_index_elf_c. Body matches
// seeds/assign_index_true_i8_override.c.
// Helpers are file-local so each frame stays under one page. One product
// function of the whole body is a multi-page frame, and the store tail
// alone lands on the smash size 0xba0.
// Do not PREFER runtime_pipeline_abi_assign_index_thin.x (different
// dispatcher, HARD BAN). Do not cc or gcc the seed on Windows, Linux,
// or Darwin. Linux, Darwin, and Windows relinks consume this file.
// PLATFORM: SHARED body.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_emit_assign_rhs_to_rax_elf_c(
  arena: *u8, elf_ctx: *u8, assign_expr_ref: i32, left_ref: i32, right_ref: i32,
  ctx: *u8, ta: i32
): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(
  arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32,
  ctx: *u8, ta: i32, esz: i32
): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(
  elf_ctx: *u8, elem_sz: i32, ta: i32
): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, word: u32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_set_call_expected_ret_ty_c(type_ref: i32): void;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(v: i32): void;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(
  elf_ctx: *u8, k: i32, ta: i32
): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Load an i32 that was stored in a pipe cell.
 * @param base *u8 — cell base; the store wrote 4 bytes at offset 0
 * @return i32 — stored value
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function assign_index_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * x86-64 whole-element copy for a plain INDEX assign wider than 8 bytes.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param left_ref i32 — INDEX lvalue
 * @param right_ref i32 — RHS expression
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch; the caller has already required 0
 * @param base_ref i32 — INDEX base expression
 * @param idx_ref i32 — INDEX index expression
 * @param sz i32 — element size in bytes, already defaulted to 8
 * @param handled *u8 — i32 cell; set to 1 when this arm returns a final rc
 * @return i32 — copy rc, 0, or -1 when handled is 1; 0 when the RHS kind
 *   is not VAR, FIELD, INDEX, or CALL
 * VAR, FIELD, and INDEX copy through glue_copy slot -3. CALL writes the
 * element via sret and clears that shift even when the call emit fails.
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function assign_index_one_wide(
  arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8,
  ta: i32, base_ref: i32, idx_ref: i32, sz: i32, handled: *u8
): i32 {
  let rkcell: u8[4] = [];
  let rccell: u8[4] = [];
  let etycell: u8[4] = [];
  let rk: i32 = 0;
  let rc: i32 = 0;
  let ety: i32 = 0;
  unsafe {
    pipe_store_i32_le(&rkcell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
  }
  rk = assign_index_cell_i32(&rkcell[0]);
  if (rk == 3 || rk == 44 || rk == 47) {
    unsafe {
      pipe_store_i32_le(handled, 0, 1);
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_lvalue_eff_addr_elf_c(
        arena, elf_ctx, right_ref, ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, glue_emit_index_eff_addr_scaled_elf_c(
        arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, sz));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      return glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, sz, ta);
    }
  }
  // CALL (48). Element address is the hidden return slot.
  // METHOD and STRUCT_LIT are not this arm. PLATFORM: WINDOWS x86_64.
  if (rk == 48) {
    unsafe {
      pipe_store_i32_le(handled, 0, 1);
      pipe_store_i32_le(&etycell[0], 0, pipeline_expr_resolved_type_ref(arena, left_ref));
    }
    ety = assign_index_cell_i32(&etycell[0]);
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, glue_emit_index_eff_addr_scaled_elf_c(
        arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, sz));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ety > 0) {
      unsafe { pipeline_asm_set_call_expected_ret_ty_c(ety); }
    } else {
      unsafe { pipeline_asm_set_call_expected_ret_ty_c(0); }
    }
    unsafe { pipeline_asm_emit_set_call_sret_reg_shift_c(1); }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_expr_elf_c(
        arena, elf_ctx, right_ref, ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    unsafe { pipeline_asm_emit_set_call_sret_reg_shift_c(0); }
    unsafe { pipeline_asm_set_call_expected_ret_ty_c(0); }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  unsafe { pipe_store_i32_le(handled, 0, 0); }
  return 0;
}

/**
 * Put the assigned value in rax. Compound ops use the scalar RHS helper.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param expr_ref i32 — assignment expression
 * @param left_ref i32 — INDEX lvalue
 * @param right_ref i32 — RHS expression
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param ek i32 — assignment kind (28 plain, 29..38 compound)
 * @param sz i32 — element size in bytes
 * @return i32 — 0 when rax holds the value; -1 when a wide compound is
 *   rejected or the value emit fails
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function assign_index_one_emit(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32,
  ctx: *u8, ta: i32, ek: i32, sz: i32
): i32 {
  let rccell: u8[4] = [];
  let rc: i32 = 0;
  if (ek != 28) {
    if (sz > 8) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, glue_emit_assign_rhs_to_rax_elf_c(
        arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, pipeline_asm_emit_expr_elf_c(
      arena, elf_ctx, right_ref, ctx, ta));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Finish an arm64 9..16 byte pair: pop the high half, spill, copy, unspill.
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — arm64 (the caller already required the pair shape)
 * @param sz i32 — element size in bytes, 9..16
 * @return i32 — 0 when the copy and the stack adjust were emitted; -1 if
 *   a pop, an append, or the copy fails
 * Bytes are stp x0, x1, [sp, #-16]! ; mov x0, sp ; memcpy ; add sp, sp, #16.
 * 0xA9BF07E0, 0x910003E0, 0x910043FF.
 * PLATFORM: SHARED — file-local helper, not a link export. MACOS|ARM64.
 */
function assign_index_one_pair_finish(elf_ctx: *u8, ta: i32, sz: i32): i32 {
  let rccell: u8[4] = [];
  let rc: i32 = 0;
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_append_u32_le_c(
      elf_ctx, 2847868896 as u32));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_append_u32_le_c(
      elf_ctx, 2432697312 as u32));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(
      elf_ctx, 0 - 3, sz, ta));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_append_u32_le_c(
      elf_ctx, 2432713727 as u32));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Store rax into the INDEX element. arm64 saves a 9..16 byte pair first.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param left_ref i32 — INDEX lvalue
 * @param right_ref i32 — RHS expression, read only for its kind
 * @param ctx *u8 — emit context
 * @param ta i32 — 0 x86-64, 1 arm64
 * @param base_ref i32 — INDEX base expression
 * @param idx_ref i32 — INDEX index expression
 * @param sz i32 — element size in bytes
 * @return i32 — 0 after a pair copy; otherwise the copy rc or the store rc
 * A 9..16 byte VAR, FIELD, STRUCT_LIT, INDEX, CALL, or METHOD on arm64
 * spills the high half, then copies sz bytes. A larger element of those
 * kinds is a memcpy. ARRAY_LIT stays on the one-qword store.
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function assign_index_one_tail(
  arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8,
  ta: i32, base_ref: i32, idx_ref: i32, sz: i32
): i32 {
  let rkcell: u8[4] = [];
  let rccell: u8[4] = [];
  let rk: i32 = 0;
  let rc: i32 = 0;
  let pair: i32 = 0;
  if (ta == 1 && sz > 8 && sz <= 16) {
    unsafe {
      pipe_store_i32_le(&rkcell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
    }
    rk = assign_index_cell_i32(&rkcell[0]);
    if (rk == 3 || rk == 44 || rk == 45 || rk == 47 || rk == 48 || rk == 49) {
      pair = 1;
    }
  }
  if (pair != 0) {
    unsafe {
      pipe_store_i32_le(&rccell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
    }
    rc = assign_index_cell_i32(&rccell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, glue_emit_index_eff_addr_scaled_elf_c(
      arena, elf_ctx, left_ref, base_ref, idx_ref, ctx, ta, sz));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  if (pair != 0) {
    unsafe {
      return assign_index_one_pair_finish(elf_ctx, ta, sz);
    }
  }
  if (ta == 1 && sz > 16) {
    unsafe {
      pipe_store_i32_le(&rkcell[0], 0, pipeline_expr_kind_ord_at(arena, right_ref));
    }
    rk = assign_index_cell_i32(&rkcell[0]);
    if (rk == 3 || rk == 44 || rk == 45 || rk == 47 || rk == 48 || rk == 49) {
      unsafe {
        return glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, sz, ta);
      }
    }
  }
  unsafe {
    return backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, sz, ta);
  }
}

/**
 * Emit an INDEX-lvalue assignment, including compound ops and wide copies.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — encoder context; null returns -1
 * @param expr_ref i32 — assignment expression (kind 28, or 29..38)
 * @param left_ref i32 — INDEX lvalue (kind 47); <= 0 returns -1
 * @param right_ref i32 — RHS expression; <= 0 returns -1
 * @param ctx *u8 — emit context; null returns -1
 * @param ta i32 — target arch; 0 is x86-64, 1 is arm64
 * @return i32 — 0 when the store or copy was emitted; -1 on a rejected shape
 *   or an encoder failure. A copy or store return is passed through.
 * x86-64 copies a >8 byte VAR, FIELD, or INDEX with glue_copy slot -3, and
 * emits a CALL into that element via sret. arm64 spills a 9..16 byte pair
 * and copies a >16 byte lvalue instead of one qword store.
 * Pipe cells hold extern results. Do not write `x = extern()`.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function glue_emit_assign_index_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, left_ref: i32, right_ref: i32,
  ctx: *u8, ta: i32
): i32 {
  let ekcell: u8[4] = [];
  let lkcell: u8[4] = [];
  let bcell: u8[4] = [];
  let icell: u8[4] = [];
  let szcell: u8[4] = [];
  let rccell: u8[4] = [];
  let hcell: u8[4] = [];
  let ek: i32 = 0;
  let lk: i32 = 0;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let sz: i32 = 0;
  let rc: i32 = 0;
  let handled: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)
      || left_ref <= 0 || right_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&ekcell[0], 0, pipeline_expr_kind_ord_at(arena, expr_ref));
  }
  ek = assign_index_cell_i32(&ekcell[0]);
  if (ek != 28 && (ek < 29 || ek > 38)) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&lkcell[0], 0, pipeline_expr_kind_ord_at(arena, left_ref));
  }
  lk = assign_index_cell_i32(&lkcell[0]);
  if (lk != 47) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&bcell[0], 0, pipeline_expr_index_base_ref(arena, left_ref));
  }
  base_ref = assign_index_cell_i32(&bcell[0]);
  unsafe {
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_index_index_ref(arena, left_ref));
  }
  idx_ref = assign_index_cell_i32(&icell[0]);
  if (base_ref <= 0 || idx_ref <= 0) {
    return 0 - 1;
  }
  // Tip INDEX stride. A non-positive size is the 8-byte default.
  unsafe {
    pipe_store_i32_le(&szcell[0], 0, pipeline_asm_index_elem_byte_sz_c(arena, left_ref));
  }
  sz = assign_index_cell_i32(&szcell[0]);
  if (sz <= 0) {
    sz = 8;
  }
  // w1512: x86-64 whole-element copy. PLATFORM: LINUX|WINDOWS.
  if (ek == 28 && ta == 0 && sz > 8) {
    unsafe {
      pipe_store_i32_le(&hcell[0], 0, 0);
      pipe_store_i32_le(&rccell[0], 0, assign_index_one_wide(
        arena, elf_ctx, left_ref, right_ref, ctx, ta, base_ref, idx_ref, sz, &hcell[0]));
    }
    handled = assign_index_cell_i32(&hcell[0]);
    rc = assign_index_cell_i32(&rccell[0]);
    if (handled != 0) {
      return rc;
    }
  }
  unsafe {
    pipe_store_i32_le(&rccell[0], 0, assign_index_one_emit(
      arena, elf_ctx, expr_ref, left_ref, right_ref, ctx, ta, ek, sz));
  }
  rc = assign_index_cell_i32(&rccell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    return assign_index_one_tail(
      arena, elf_ctx, left_ref, right_ref, ctx, ta, base_ref, idx_ref, sz);
  }
}
