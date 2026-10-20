// Cap tip: real glue_emit_index_eff_addr_scaled_elf_c (m8 stub was hollow mov0/ret).
// Matches product leftover body: bounds_guard → base_elf → (lit add | push/idx/scale).
// knife256/10.2: Option_ptr bp[0] after dual_gp pair store SEGV'd because
// emit_index assumed addr already in x0. PLATFORM: SHARED · MACOS Cap tip.

export extern function glue_emit_index_eff_addr_base_elf_c(
    arena: *u8, elf_ctx: *u8, ix_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_index_bounds_guard_elf_c(
    arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32,
    ix_ref: i32, base_ref: i32, idx_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(
    arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_index_rax_plus_rbx_scaled_elf_c(
    elf_ctx: *u8, esz: i32, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(
    elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;

function idx_scaled_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * INDEX effective address → rax/x0 with index*esz.
 * @return i32 — 0 ok; -1 error
 * PLATFORM: SHARED · Darwin Cap tip first-win over m8 hollow.
 */
#[no_mangle]
export function glue_emit_index_eff_addr_scaled_elf_c(
    arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32,
    ctx: *u8, ta: i32, esz: i32): i32 {
  let cell: u8[8];
  let ko: i32 = 0;
  let iv: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (ix_ref < 1 || base_ref < 1 || idx_ref < 1) {
    return 0 - 1;
  }
  // knife256/10.2: slice/lit OOB must panic before address (Cap tip leftover gap).
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_emit_index_bounds_guard_elf_c(
        arena, elf_ctx, ctx, ta, ix_ref, base_ref, idx_ref));
  }
  if (idx_scaled_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_emit_index_eff_addr_base_elf_c(arena, elf_ctx, ix_ref, ctx, ta));
  }
  if (idx_scaled_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, idx_ref));
  }
  ko = idx_scaled_cell_i32(&cell[0]);
  if (ko == 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_int_val_at(arena, idx_ref));
    }
    iv = idx_scaled_cell_i32(&cell[0]);
    if (esz != 0 && iv != 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, backend_enc_add_imm_to_rax_arch(elf_ctx, iv * esz, ta));
      }
      if (idx_scaled_cell_i32(&cell[0]) != 0) {
        return 0 - 1;
      }
    }
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rax_arch(elf_ctx, ta));
  }
  if (idx_scaled_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta));
  }
  if (idx_scaled_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
  }
  if (idx_scaled_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rax_arch(elf_ctx, ta));
  }
  if (idx_scaled_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
  }
}
