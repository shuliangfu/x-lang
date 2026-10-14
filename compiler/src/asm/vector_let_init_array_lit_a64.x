// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Darwin body of glue_emit_vector_type_let_init_elf_c.
// Kind 46 calls the existing lane-byte writer. Kinds 4..13 (51 counts
// as add) call the existing per-lane binop writer. INT_LIT (0) and
// BOOL_LIT (2) call the existing lane-imm fill. Declining a scalar lit
// made the caller store x0 and the untouched x1 as a 16-byte pair, so
// lanes past the first 8 bytes stayed garbage. VAR copy and
// CALL/METHOD still return -3. A non-SIMD type still returns -3: a
// hollow 0 short-circuits VAR try_let (scalar i=i+1 / empty while).
// Windows keeps seeds/win_vector_type_let_init_override.c. Do not link
// that C body here.
// PLATFORM: MACOS|ARM64.

export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function pipeline_asm_emit_vector_binop_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(
  arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32
): i32;
export extern function glue_simd_emit_imm_fill_slot_c(
  elf_ctx: *u8, stack_slot_off: i32, lanes: i32, esz: i32, ta: i32, imm_bits: i32
): i32;

/**
 * Store SIMD ARRAY_LIT lanes, a lane binop, or a scalar lit splat.
 * @param arena *u8 — AST arena; null returns -3
 * @param elf_ctx *u8 — object writer; null returns -3
 * @param init_ref i32 — initializer expr; not positive returns -3
 * @param ctx *u8 — AsmFuncCtx; null returns -3
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of lane 0
 * @param type_ref i32 — let type; not a SIMD vector spelling returns -3
 * @return i32 — 0 when kind 46, a lane binop, or a scalar lit is
 *   stored; -1 when that store fails; -3 when this face does not
 *   handle the expr
 * Kind 46 (ARRAY_LIT) calls pipeline_asm_emit_vector_let_init_elf_c.
 * Kinds 4..13 call pipeline_asm_emit_vector_binop_let_init_elf_c
 * (kind 51 is add). Kind 0 (INT_LIT) and kind 2 (BOOL_LIT) call
 * glue_simd_emit_imm_fill_slot_c. VAR copy and CALL/METHOD stay declined.
 * PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let ko: i32 = 0;
  let simd: i32 = 0;
  let rc: i32 = 0;
  let imm: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 3;
  }
  unsafe {
    simd = asm_type_is_simd_vector_spelling(arena, type_ref);
  }
  if (simd == 0) {
    return 0 - 3;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  // EXPR_ARRAY_LIT = 46. Store the lane bytes, not the buffer address.
  if (ko == 46) {
    unsafe {
      rc = pipeline_asm_emit_vector_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
    }
    return rc;
  }
  // Lane binop. Do not decline into the dual-GP pair store.
  unsafe {
    rc = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (rc != 0) {
    unsafe {
      rc = pipeline_asm_emit_vector_binop_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    }
    return rc;
  }
  // EXPR_INT_LIT = 0, EXPR_BOOL_LIT = 2. Splat the i32 into every lane.
  // A decline stores x0 plus untouched x1 (16 bytes). Lane 2 of i32x4 = 0
  // is then garbage. FLOAT_LIT stays declined.
  if (ko == 0 || ko == 2) {
    unsafe {
      imm = pipeline_expr_int_val_at(arena, init_ref);
      rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
    }
    if (rc != 0 || lanes_s[0] <= 0) {
      return 0 - 1;
    }
    unsafe {
      rc = glue_simd_emit_imm_fill_slot_c(
        elf_ctx, stack_slot_off, lanes_s[0], esz_s[0], ta, imm);
    }
    return rc;
  }
  return 0 - 3;
}
