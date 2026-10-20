// Cap tip: glue_emit_index_bounds_guard_elf_c — restore slice lo/hi runtime panic.
// knife256/10.2: Cap tip scaled thin omitted leftover gcc guard → bounds_slice
// OOB could exit 0 (L4@c7df00da3 run-ub FAIL). Fixed-array non-lit still skipped
// (Stage 12.0.5); lit OOB + slice dynamic keep panic.
// PLATFORM: SHARED · MACOS Cap tip first-win.

export extern function pipeline_expr_index_proven_in_bounds_at(arena: *u8, ix_ref: i32): i32;
export extern function pipeline_expr_index_base_is_slice_at(arena: *u8, ix_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, cap: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(
    arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_slice_length_to_rbx_elf_c(
    arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, base_ref: i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cmp_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_jge_arch(elf_ctx: *u8, lbl: *u8, lbl_len: i32, ta: i32): i32;
export extern function backend_enc_label_arch(
    elf_ctx: *u8, lbl: *u8, lbl_len: i32, is_func: i32, ta: i32): i32;
export extern function backend_enc_add_imm_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;

function bg_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * INDEX bounds: slice lo/hi → xlang_panic_; fixed lit OOB → panic;
 * fixed non-lit → skip (Stage 12.0.5 freestanding).
 * @return i32 — 0 ok/skipped; -1 error
 * PLATFORM: SHARED · Cap tip authority (was leftover gcc W 0x90f).
 */
#[no_mangle]
export function glue_emit_index_bounds_guard_elf_c(
    arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32,
    ix_ref: i32, base_ref: i32, idx_ref: i32): i32 {
  let cell: u8[8];
  let base_ty: i32 = 0;
  let bt_kind: i32 = 0;
  let is_slice: i32 = 0;
  let lit_idx: i32 = 0;
  let array_sz: i32 = 0;
  let ok_lo: u8[128];
  let ok_hi: u8[128];
  let ok_lo_len: i32 = 0;
  let ok_hi_len: i32 = 0;
  let ko: i32 = 0;

  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0;
  }
  if (base_ref <= 0 || idx_ref <= 0) {
    return 0;
  }

  if (ix_ref > 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_index_proven_in_bounds_at(arena, ix_ref));
    }
    if (bg_cell_i32(&cell[0]) != 0) {
      return 0;
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_index_base_is_slice_at(arena, ix_ref));
    }
    if (bg_cell_i32(&cell[0]) != 0) {
      is_slice = 1;
    }
  }

  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_resolved_type_ref(arena, base_ref));
  }
  base_ty = bg_cell_i32(&cell[0]);
  if (base_ty <= 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, base_ty));
  }
  bt_kind = bg_cell_i32(&cell[0]);
  // TYPE_SLICE=11, TYPE_ARRAY=10
  if (is_slice == 0 && bt_kind == 11) {
    is_slice = 1;
  }
  if (is_slice == 0 && bt_kind != 10) {
    return 0;
  }

  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, idx_ref));
  }
  ko = bg_cell_i32(&cell[0]);
  if (ko == 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_int_val_at(arena, idx_ref));
    }
    lit_idx = bg_cell_i32(&cell[0]);
    if (lit_idx < 0) {
      unsafe {
        return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
      }
    }
    if (is_slice == 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_type_array_size_at(arena, base_ty));
      }
      array_sz = bg_cell_i32(&cell[0]);
      if (array_sz > 0 && lit_idx >= array_sz) {
        unsafe {
          return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
        }
      }
      return 0;
    }
  }

  // Stage 12.0.5: fixed-array non-lit — no runtime panic.
  if (is_slice == 0) {
    return 0;
  }

  unsafe {
    ok_lo_len = pipeline_asm_emit_next_label_c(ctx, &ok_lo[0], 64);
    ok_hi_len = pipeline_asm_emit_next_label_c(ctx, &ok_hi[0], 64);
  }
  if (ok_lo_len <= 0 || ok_hi_len <= 0) {
    return 0 - 1;
  }

  // idx < 0 → panic
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_cmp_rax_rbx_arch(elf_ctx, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_jge_arch(elf_ctx, &ok_lo[0], ok_lo_len, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_label_arch(elf_ctx, &ok_lo[0], ok_lo_len, 0, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }

  // idx > len-1 → panic
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_emit_slice_length_to_rbx_elf_c(arena, elf_ctx, ctx, ta, base_ref));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_add_imm_to_rbx_arch(elf_ctx, 0 - 1, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_cmp_rbx_rax_arch(elf_ctx, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_jge_arch(elf_ctx, &ok_hi[0], ok_hi_len, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_label_arch(elf_ctx, &ok_hi[0], ok_hi_len, 0, ta));
  }
  if (bg_cell_i32(&cell[0]) != 0) {
    return 0 - 1;
  }
  return 0;
}
