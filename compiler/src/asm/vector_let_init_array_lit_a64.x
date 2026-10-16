// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Darwin body of glue_emit_vector_type_let_init_elf_c.
// Kind 46 calls the existing lane-byte writer. Kinds 4..13 (51 counts
// as add) call the existing per-lane binop writer. Kinds 14..19
// (EQ through GE) compare each lane. An i32 lane is sign-extended
// and compared with cmp x0, x1. An f32 lane uses the existing fcmp
// and the FP setcc. Both store 0 or 1. The old path compared the
// first qword once, and a wide return then loaded 0 or 1 as an
// address. A lane size other than 4 stays declined. INT_LIT (0) and
// BOOL_LIT (2) call the existing lane-imm fill. EXPR_NEG (22) over an
// INT_LIT is the parser form of `-3`: negate that literal and splat
// with the same fill. Kind 22 or 23 whose operand is itself kind 22
// or 23 of a non-null INT_LIT folds both operators into that
// immediate and uses the same fill. One more unary of that same
// literal folds the third operator too. One unary beyond that folds
// the fourth. One unary beyond that folds the fifth. One unary
// beyond that folds the sixth.
// `let v: i32x8 = -(~(~(~(~(-3)))))` wrote 3 into lane 0 and
// left lane 1 unset. The walk folds kind 22 and kind 23 through 32
// steps, inside out. Probes covered one through eight minuses and the
// seven-deep mixed chain on lane 0 and lane 7. A 33rd step stays
// declined. A nested unary
// of a VAR, a binop, a
// CALL, a METHOD, an INDEX, a DEREF, or an ARRAY_LIT stays on the
// per-lane path. Keyword null, f32, and a lane size other than 4
// stay declined. Declining that splat stored `neg w0`
// (zero-extended x0) plus the untouched x1, so lane 1 of i32x4 = -3
// was 0. EXPR_NEG of a VAR or a FIELD whose lanes already have a frame
// home negates each i32 lane with the existing neg w0. A decline of
// that form stored neg of lane 0 only, so lane 1 of `let v = -a` was 0
// and lane 1 of `let n = -h.v` was 0. The existing lane-home helper
// names that field slot. A lane binop under the minus is stored by
// the existing binop writer, then each destination lane is negated.
// A CALL or METHOD under the minus is stored by the existing struct
// let-init call arm, then each destination lane is negated. An INDEX
// under the minus uses that same let-init: above 16 bytes it memcpy's
// the whole element (Vec8i is 32). A DEREF under the minus uses that
// same let-init: it memcpy's the whole target, and the store is not
// through the pointer. CALL and METHOD wider than 16 use that same
// let-init: the callee writes the slot through sret (Vec8i is 32),
// then each lane is negated. An ARRAY_LIT
// under the minus is
// stored by the existing lane-byte writer, then each destination lane
// is negated. Declining that left lane 0 of `let n = -[1, 2, 3, 4]`
// unequal to -1. A transparent EXPR_BLOCK (26), including `unsafe { e }`,
// is peeled with the existing helper before that classification.
// Declining the block stored neg of lane 0 for `let n = unsafe { -*p }`
// and left lane 0 of `let n = unsafe { [1, 2, 3, 4] }` unequal to 1.
// Bare VAR still returns -3 after the peel. A bare DEREF, and a DEREF
// under lets, is copied by the existing struct let-init. The store is
// not through the pointer. An f32 lane
// (Vec4f / f32x4, or TYPE_VECTOR of F32) flips bit 31 with the existing
// mov of that bit into w1 and eor x0, x0, x1. neg w0 stays the i32
// path: it is two's complement, and integer negate of an f32 bit
// pattern is not an IEEE sign flip. A lane size other than 4, and a
// negative immediate with lane size 8, still return -3 (neg w0 is
// 32-bit; the fill zero-extends). f64 stays declined. EXPR_BITNOT
// (kind 23) of an i32 lane uses the same classification and emits
// mvn w0 per lane. f32 bitwise not stays declined. A FLOAT_LIT, or one
// unary minus of a FLOAT_LIT, on an f32 lane is narrowed with
// glue_ieee_f64_bits_to_f32_bits and splatted with the same imm fill.
// One more unary minus of that FLOAT_LIT cancels the sign and uses
// the same fill. One unary beyond that applies the sign once.
// One unary beyond that cancels again. One unary beyond that applies
// the sign once more. One unary beyond that cancels again. One unary
// beyond that applies the sign once more. One unary beyond that
// cancels again. One unary beyond that applies the sign once.
// One unary beyond that cancels again. One unary
// beyond that applies the sign once. One unary
// beyond that cancels again. Thirteen minuses apply
// the sign once more. Fourteen minuses cancel again.
// Fifteen minuses apply the sign once more.
// At most 32 unary minuses of that float are folded. The sign
// is the parity of the count. One more stays declined.
// A scalar mvn w0
// plus str x0 left lane 1 of `let v: i32x4 = ~a` at 0. A VAR, a FIELD,
// an ARRAY_LIT, or a lane binop under minus may be wider than 16 when
// each lane is 4 bytes. The lane home, the lane-byte writer, and the
// binop let-init already cover every lane. CALL, METHOD, INDEX, and
// DEREF under minus stay declined past 16 bytes: those writers still
// store 16 bytes. Bare CALL and VAR copy still
// return -3.
// A non-SIMD type still returns
// -3: a hollow 0 short-circuits VAR try_let (scalar i=i+1 / empty while).
// Windows keeps seeds/win_vector_type_let_init_override.c. Do not link
// that C body here.
// PLATFORM: MACOS|ARM64.

export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_lane_operand_emit_let_block_chain(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, budget: i32
): i32;
export extern function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function pipeline_asm_emit_vector_binop_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32;
export extern function glue_lane_f32_lit_dest_set(v: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  let_ty_ref: i32, stack_slot_off: i32
): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, ai: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(
  arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32
): i32;
export extern function glue_simd_emit_imm_fill_slot_c(
  elf_ctx: *u8, stack_slot_off: i32, lanes: i32, esz: i32, ta: i32, imm_bits: i32
): i32;
export extern function glue_i32_to_f32_bits(v: i32): i32;
export extern function pipeline_expr_float_bits_lo_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_float_bits_hi_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_ieee_f64_bits_to_f32_bits(lo: i32, hi: i32): i32;
export extern function pipe_modlet_float_expr_trunc_i32(
  arena: *u8, eref: i32, out_val: *i32
): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_var_lane_stack_off_elf_c(
  arena: *u8, ctx: *u8, var_expr_ref: i32, lane: i32, esz: i32, ta: i32
): i32;
export extern function backend_enc_load_rbp_lane_to_rax_arch(
  elf_ctx: *u8, offset: i32, esz: i32, ta: i32
): i32;
export extern function backend_enc_neg_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_not_eax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(
  elf_ctx: *u8, imm32: i32, ta: i32
): i32;
export extern function backend_enc_xor_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_and_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_or_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rbx_arch(
  elf_ctx: *u8, offset: i32, ta: i32
): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(
  elf_ctx: *u8, offset: i32, sz: i32, ta: i32
): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_vector_operand_lane_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cset_w0_from_cc_arch(elf_ctx: *u8, cc: i32, ta: i32): i32;
export extern function backend_enc_ucomiss_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx: *u8, cc: i32, ta: i32): i32;
export extern function pipeline_asm_cmp_cc_for_expr_kind_ord(kind_ord: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_store_retval_pair_to_rbp_elf_c(
  m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32,
  init_ref: i32, ctx: *u8
): i32;
export extern function pipeline_asm_emit_next_label_c(
  ctx: *u8, buf: *u8, buf_size: i32
): i32;
export extern function glue_enc_jz_after_bool_in_eax(
  elf_ctx: *u8, label: *u8, label_len: i32, ta: i32
): i32;
export extern function backend_enc_jmp_arch(
  elf_ctx: *u8, label: *u8, label_len: i32, ta: i32
): i32;
export extern function backend_enc_label_arch(
  elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32
): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(
  elf_ctx: *u8, offset: i32, ta: i32
): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;

/* BSS name scratch. A stack u8[64] is the cap-tip smash class. */
let g_vlet_f32_name: u8[64] = [];

/**
 * True when the float-literal fill should splat this vector.
 * glue_vector_elem_is_f32_c accepts f32x4, f32x8, Vec4f, and a
 * TYPE_VECTOR of f32. The cap-tip object of that function was emitted
 * before f32x8 was added, so `let v: f32x8 = 1.0` fell through to one
 * str x of the f64 bits and lane 0 read as 0. f32x8 is kind 8, five
 * bytes, f 3 2 x 8. f32x16 is kind 8, six bytes, f 3 2 x 1 6. The
 * linked classifier returns 0 for that name too, so an f32x16 add
 * stored integer add of the lane bits and lane 0 compared as 0.
 * When the classifier already returns 1 this name check is not
 * reached. The existing fill still takes the lane count from
 * glue_vector_type_lanes_esz_c. An integer spelling, including
 * i32x16 and u32x16, returns 0. An integer literal does not call
 * this helper.
 * @param arena *u8 — AST arena
 * @param type_ref i32 — let type; not positive returns 0
 * @return i32 — 1 when the f32 fill should run; 0 otherwise
 * PLATFORM: SHARED.
 */
function vlet_f32_fill_lane(arena: *u8, type_ref: i32): i32 {
  let rc: i32 = 0;
  let tk: i32 = 0;
  let nlen: i32 = 0;
  if (arena == (0 as *u8) || type_ref <= 0) {
    return 0;
  }
  unsafe {
    rc = glue_vector_elem_is_f32_c(arena, type_ref);
  }
  if (rc != 0) {
    return 1;
  }
  unsafe {
    tk = pipeline_type_kind_ord_at(arena, type_ref);
  }
  if (tk != 8) {
    return 0;
  }
  unsafe {
    nlen = pipeline_type_named_name_into(arena, type_ref, &g_vlet_f32_name[0]);
  }
  /* ASCII f 3 2 x 8. Five compares, no second name table. */
  if (nlen == 5) {
    if (g_vlet_f32_name[0] != 102) {
      return 0;
    }
    if (g_vlet_f32_name[1] != 51) {
      return 0;
    }
    if (g_vlet_f32_name[2] != 50) {
      return 0;
    }
    if (g_vlet_f32_name[3] != 120) {
      return 0;
    }
    if (g_vlet_f32_name[4] != 56) {
      return 0;
    }
    return 1;
  }
  /* ASCII f 3 2 x 1 6. Same helper, six compares. i32x16 starts
     with i (105) and returns 0 on the first byte. PLATFORM: SHARED. */
  if (nlen != 6) {
    return 0;
  }
  if (g_vlet_f32_name[0] != 102) {
    return 0;
  }
  if (g_vlet_f32_name[1] != 51) {
    return 0;
  }
  if (g_vlet_f32_name[2] != 50) {
    return 0;
  }
  if (g_vlet_f32_name[3] != 120) {
    return 0;
  }
  if (g_vlet_f32_name[4] != 49) {
    return 0;
  }
  if (g_vlet_f32_name[5] != 54) {
    return 0;
  }
  return 1;
}

/**
 * True for a relational lane compare.
 * EXPR_EQ is 14 and EXPR_GE is 19. Kinds 4..13 stay on the existing
 * lane binop writer. This predicate does not include kind 51.
 * @param ko i32 — expression kind ordinal
 * @return i32 — 1 for EQ through GE; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function vlet_lane_cmp_ko(ko: i32): i32 {
  if (ko < 14) {
    return 0;
  }
  if (ko > 19) {
    return 0;
  }
  return 1;
}

/**
 * Leave one lane of a relational compare in x0 as 0 or 1.
 * Does not store. The caller stores at lane times esz.
 * An i32 lane is sign-extended, compared with cmp x0, x1, then
 * cset. Left is x0 and right is x1, so LT means left < right.
 * An f32 lane loads the right bits, pushes, loads the left bits
 * into rbx, pops the right bits into rax, then ucomiss and the
 * existing FP setcc. A missing operand or cc < 0 returns -1.
 * An encoder failure returns -1.
 * @param arena *u8 - AST arena; null returns -1
 * @param elf_ctx *u8 - emit context; null returns -1
 * @param cmp_ref i32 - compare expr; not positive returns -1
 * @param lane i32 - lane index passed to the operand helper
 * @param esz i32 - lane size in bytes; the caller has checked 4
 * @param ctx *u8 - emit ctx; null returns -1
 * @param ta i32 - 1 is Darwin ARM64
 * @param lane_f32 i32 - non-zero selects fcmp; 0 selects cmp
 * @return i32 - 0 when x0 holds 0 or 1; -1 on failure
 * PLATFORM: MACOS|ARM64.
 */
function vlet_lane_cmp_one(
  arena: *u8, elf_ctx: *u8, cmp_ref: i32, lane: i32,
  esz: i32, ctx: *u8, ta: i32, lane_f32: i32
): i32 {
  let rc: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  let cc: i32 = 0;
  let ko: i32 = 0;
  if (arena == (0 as *u8)) {
    return 0 - 1;
  }
  if (elf_ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 1;
  }
  if (cmp_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, cmp_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, cmp_ref);
    ko = pipeline_expr_kind_ord_at(arena, cmp_ref);
  }
  unsafe {
    cc = pipeline_asm_cmp_cc_for_expr_kind_ord(ko);
  }
  if (left_ref <= 0) {
    return 0 - 1;
  }
  if (right_ref <= 0) {
    return 0 - 1;
  }
  if (cc < 0) {
    return 0 - 1;
  }
  if (lane_f32 != 0) {
    unsafe {
      rc = glue_emit_vector_operand_lane_elf_c(
        arena, elf_ctx, right_ref, lane, esz, ctx, ta);
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
      rc = glue_emit_vector_operand_lane_elf_c(
        arena, elf_ctx, left_ref, lane, esz, ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
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
      rc = backend_enc_ucomiss_rbx_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_fp_cmp_setcc_movzbl_arch(elf_ctx, cc, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  unsafe {
    rc = glue_emit_vector_operand_lane_elf_c(
      arena, elf_ctx, left_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
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
    rc = glue_emit_vector_operand_lane_elf_c(
      arena, elf_ctx, right_ref, lane, esz, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
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
    rc = backend_enc_cmp_rax_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_cset_w0_from_cc_arch(elf_ctx, cc, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Store one 0-or-1 result in each lane of a relational compare.
 * The linked lane-binop set stops at kind 13, so `a == b` compared
 * the first qword and wrote one cset. A wide return then loaded that
 * 0 or 1 as an address. Each lane is loaded with the existing operand
 * helper. An i32 lane is sign-extended with the existing sxtw, then
 * compared with cmp x0, x1 and the integer cset. Left is x0 and right
 * is x1, so LT means left < right. An f32 lane, including f32x8 where
 * the linked classifier returns 0, uses the existing fcmp. That
 * compare wants the left bits in rbx and the right bits in rax, then
 * the existing FP setcc. Integer compare of the bits treats -0.0 and
 * 0.0 as different and treats a NaN as equal to itself. The stored
 * value is 0 or 1, not an all-ones mask and not the f32 bits of 1.0.
 * A lane size other than 4, and ta other than 1, return -3 before any
 * store. A lanes-helper failure returns -3. A missing operand or an
 * encoder failure returns -1. The 0 or 1 in x0 is vlet_lane_cmp_one.
 * This loop only stores that word.
 * @param arena *u8 — AST arena; null returns -3
 * @param elf_ctx *u8 — emit context; null returns -3
 * @param init_ref i32 — compare expr; not positive returns -3
 * @param ctx *u8 — emit ctx; null returns -3
 * @param ta i32 — 1 is Darwin ARM64; any other returns -3
 * @param stack_slot_off i32 — destination frame slot
 * @param type_ref i32 — vector type; f32 fill selects fcmp
 * @return i32 — 0 when every lane is stored; -3 decline; -1 failure
 * PLATFORM: MACOS|ARM64.
 */
function vlet_emit_i32_lane_cmp(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let rc: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let li: i32 = 0;
  let lane_f32: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 3;
  }
  if (ta != 1) {
    return 0 - 3;
  }
  rc = vlet_f32_fill_lane(arena, type_ref);
  if (rc != 0) {
    lane_f32 = 1;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
  }
  if (rc != 0) {
    return 0 - 3;
  }
  lanes = lanes_s[0];
  esz = esz_s[0];
  if (esz != 4) {
    return 0 - 3;
  }
  if (lanes <= 0) {
    return 0 - 3;
  }
  li = 0;
  while (li < lanes) {
    rc = vlet_lane_cmp_one(
      arena, elf_ctx, init_ref, li, esz, ctx, ta, lane_f32);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    li = li + 1;
  }
  return 0;
}

/**
 * Classify one f32x8 lane literal.
 * @param arena *u8 — AST arena; null returns -1
 * @param elem_ref i32 — lane expr; not positive returns -1
 * @return i32 — 0 for an INT_LIT chain of only kind 22, 1 for a
 *   FLOAT_LIT chain of only kind 22, -1 otherwise
 * Kind 23 returns -1 so bitwise not stays on the integer lane store.
 * Kind 2 returns -1. More than 32 minuses returns -1. A null keyword
 * returns -1. The walk advances the expr and the step count.
 * PLATFORM: MACOS|ARM64.
 */
function vlet_f32_lane_class(arena: *u8, elem_ref: i32): i32 {
  let ek: i32 = 0;
  let cur: i32 = 0;
  let step: i32 = 0;
  let n: i32 = 0;
  let stop: i32 = 0;
  let is_null: i32 = 0;
  if (arena == (0 as *u8) || elem_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, elem_ref);
  }
  cur = elem_ref;
  while (stop == 0) {
    if (n < 32) {
      if (ek == 23) {
        return 0 - 1;
      } else {
        if (ek == 22) {
          n = n + 1;
          unsafe {
            step = pipeline_expr_unary_operand_ref_at(arena, cur);
          }
          if (step <= 0) {
            return 0 - 1;
          }
          cur = step;
          unsafe {
            ek = pipeline_expr_kind_ord_at(arena, cur);
          }
        } else {
          stop = 1;
        }
      }
    } else {
      return 0 - 1;
    }
  }
  if (ek == 0) {
    unsafe {
      is_null = pipeline_expr_is_null_keyword_c(arena, cur);
    }
    if (is_null != 0) {
      return 0 - 1;
    }
    return 0;
  }
  if (ek == 1) {
    return 1;
  }
  return 0 - 1;
}

/**
 * Store one f32x8 lane from an integer or float literal chain.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param elem_ref i32 — lane expr already accepted by vlet_f32_lane_class
 * @param ta i32 — arm64
 * @param slot i32 — frame offset of this lane; below 0 returns -1
 * @return i32 — 0 stored, -1 when the literal or the fill fails
 * An odd count of kind 22 negates the integer or flips the f64 sign
 * bit before glue_ieee_f64_bits_to_f32_bits. The existing one-lane
 * imm fill writes those f32 bits. PLATFORM: MACOS|ARM64.
 */
function vlet_f32_store_lane(
  arena: *u8, elf_ctx: *u8, elem_ref: i32, ta: i32, slot: i32
): i32 {
  let ek: i32 = 0;
  let cur: i32 = 0;
  let step: i32 = 0;
  let n: i32 = 0;
  let stop: i32 = 0;
  let neg: i32 = 0;
  let imm: i32 = 0;
  let bits: i32 = 0;
  let lo: i32 = 0;
  let hi: i32 = 0;
  let sign: i32 = 0;
  let rc: i32 = 0;
  if (slot < 0) {
    return 0 - 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, elem_ref);
  }
  cur = elem_ref;
  while (stop == 0) {
    if (n < 32) {
      if (ek == 22) {
        if (neg == 0) {
          neg = 1;
        } else {
          neg = 0;
        }
        n = n + 1;
        unsafe {
          step = pipeline_expr_unary_operand_ref_at(arena, cur);
        }
        if (step <= 0) {
          return 0 - 1;
        }
        cur = step;
        unsafe {
          ek = pipeline_expr_kind_ord_at(arena, cur);
        }
      } else {
        stop = 1;
      }
    } else {
      return 0 - 1;
    }
  }
  if (ek == 0) {
    unsafe {
      imm = pipeline_expr_int_val_at(arena, cur);
    }
    if (neg != 0) {
      imm = 0 - imm;
    }
    unsafe {
      bits = glue_i32_to_f32_bits(imm);
    }
  } else {
    if (ek != 1) {
      return 0 - 1;
    }
    unsafe {
      lo = pipeline_expr_float_bits_lo_at(arena, cur);
      hi = pipeline_expr_float_bits_hi_at(arena, cur);
    }
    if (neg != 0) {
      sign = 0 - 2147483647;
      sign = sign - 1;
      hi = hi ^ sign;
    }
    unsafe {
      bits = glue_ieee_f64_bits_to_f32_bits(lo, hi);
    }
  }
  unsafe {
    rc = glue_simd_emit_imm_fill_slot_c(elf_ctx, slot, 1, 4, ta, bits);
  }
  return rc;
}

/**
 * Store f32 lanes of an all-literal ARRAY_LIT.
 * @param arena *u8 - AST arena
 * @param elf_ctx *u8 - object writer
 * @param init_ref i32 - kind 46 expr
 * @param ctx *u8 - AsmFuncCtx; unused, the lane fill does not need it
 * @param ta i32 - a value other than 1 returns 1
 * @param stack_slot_off i32 - lane 0 slot
 * @param type_ref i32 - let type
 * @return i32 - 0 when every lane is stored, -1 on an encoder
 *   failure after the lane list was accepted, 1 when the typeless
 *   lane store should run
 * Lane size must be 4. Lane count must be 4, 8, or 16: f32x4,
 * Vec4f, f32x8, f32x16. The element count must equal that lane
 * count. An unstamped lit under address-of keeps integer bits in
 * the typeless store, so those counts are stored here from the
 * destination type. A non-literal lane returns 1 before any byte
 * is emitted. An integer spelling returns 1 from vlet_f32_fill_lane.
 * PLATFORM: MACOS|ARM64.
 */
function vlet_f32_array_lanes(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let is_f: i32 = 0;
  let n: i32 = 0;
  let ai: i32 = 0;
  let elem: i32 = 0;
  let cls: i32 = 0;
  let slot: i32 = 0;
  let rc: i32 = 0;
  let lanes: i32 = 0;
  let lesz: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  if (ta != 1 || type_ref <= 0 || stack_slot_off < 0) {
    return 1;
  }
  unsafe {
    is_f = vlet_f32_fill_lane(arena, type_ref);
  }
  if (is_f == 0) {
    return 1;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
  }
  if (rc != 0) {
    return 1;
  }
  lanes = lanes_s[0];
  lesz = esz_s[0];
  if (lesz != 4) {
    return 1;
  }
  // Four, eight, and sixteen lanes only. f32x8 already stored here.
  // f32x4, Vec4f, and f32x16 used to fall through. Any other count
  // still returns 1 before a store. PLATFORM: MACOS|ARM64.
  if (lanes != 4) {
    if (lanes != 8) {
      if (lanes != 16) {
        return 1;
      }
    }
  }
  unsafe {
    n = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  if (n != lanes) {
    return 1;
  }
  ai = 0;
  while (ai < n) {
    unsafe {
      elem = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    }
    cls = vlet_f32_lane_class(arena, elem);
    if (cls < 0) {
      return 1;
    }
    ai = ai + 1;
  }
  ai = 0;
  while (ai < n) {
    unsafe {
      elem = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    }
    slot = stack_slot_off + ai * 4;
    rc = vlet_f32_store_lane(arena, elf_ctx, elem, ta, slot);
    if (rc != 0) {
      return 0 - 1;
    }
    ai = ai + 1;
  }
  return 0;
}

/**
 * Leave one lane of a compare or a logical binop in x0 as 0 or 1.
 * Kinds 14..19 call vlet_lane_cmp_one. Kind 20 combines the two
 * child lanes with and x0, x0, x1. Kind 21 combines them with
 * orr x0, x0, x1. Kind 24 evaluates its unary operand with this
 * same function, then eor x0, x0, x1 with 1 in x1, so 0 and 1
 * swap. A child is this same function. Depth above 32
 * returns -3 before any encode. Any other kind returns -3.
 * This function does not store and does not allocate a temp.
 * @param arena *u8 - AST arena; null returns -3
 * @param elf_ctx *u8 - emit context; null returns -3
 * @param expr_ref i32 - compare or logical expr; not positive returns -3
 * @param lane i32 - lane index
 * @param esz i32 - lane size; the caller has checked 4
 * @param ctx *u8 - emit ctx; null returns -3
 * @param ta i32 - 1 is Darwin ARM64
 * @param lane_f32 i32 - non-zero selects fcmp inside the compare
 * @param depth i32 - nesting depth; above 32 returns -3
 * @return i32 - 0 when x0 holds 0 or 1; -3 decline; -1 failure
 * PLATFORM: MACOS|ARM64.
 */
function vlet_lane_log_one(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, lane: i32, esz: i32,
  ctx: *u8, ta: i32, lane_f32: i32, depth: i32
): i32 {
  let rc: i32 = 0;
  let pr: i32 = 0;
  let ko: i32 = 0;
  let is_log: i32 = 0;
  let left_ref: i32 = 0;
  let right_ref: i32 = 0;
  if (depth > 32) {
    return 0 - 3;
  }
  if (arena == (0 as *u8)) {
    return 0 - 3;
  }
  if (elf_ctx == (0 as *u8)) {
    return 0 - 3;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 3;
  }
  if (expr_ref <= 0) {
    return 0 - 3;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (vlet_lane_cmp_ko(ko) != 0) {
    return vlet_lane_cmp_one(
      arena, elf_ctx, expr_ref, lane, esz, ctx, ta, lane_f32);
  }
  if (ko == 24) {
    unsafe {
      left_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    if (left_ref <= 0) {
      return 0 - 1;
    }
    rc = vlet_lane_log_one(
      arena, elf_ctx, left_ref, lane, esz, ctx, ta, lane_f32, depth + 1);
    if (rc != 0) {
      return rc;
    }
    unsafe {
      rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 1, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  if (ko == 20) {
    is_log = 1;
  }
  if (ko == 21) {
    is_log = 1;
  }
  if (is_log == 0) {
    return 0 - 3;
  }
  unsafe {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  }
  if (left_ref <= 0) {
    return 0 - 1;
  }
  if (right_ref <= 0) {
    return 0 - 1;
  }
  rc = vlet_lane_log_one(
    arena, elf_ctx, left_ref, lane, esz, ctx, ta, lane_f32, depth + 1);
  if (rc != 0) {
    return rc;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  rc = vlet_lane_log_one(
    arena, elf_ctx, right_ref, lane, esz, ctx, ta, lane_f32, depth + 1);
  if (rc != 0) {
    unsafe {
      pr = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    return rc;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
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
  if (ko == 20) {
    unsafe {
      rc = backend_enc_and_rbx_rax_arch(elf_ctx, ta);
    }
  } else {
    unsafe {
      rc = backend_enc_or_rbx_rax_arch(elf_ctx, ta);
    }
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Store each lane of a logical and (kind 20), a logical or (kind 21),
 * or a logical not (kind 24). The 0 or 1 in x0 is vlet_lane_log_one.
 * This loop only stores that word at lane times esz. A lane size
 * other than 4, and ta other than 1, return -3 before any store.
 * A child that is not a compare, not kind 20, not kind 21, and not
 * kind 24 returns -3. No second vector temp is allocated.
 * @param arena *u8 - AST arena; null returns -3
 * @param elf_ctx *u8 - emit context; null returns -3
 * @param init_ref i32 - logical expr; not positive returns -3
 * @param ctx *u8 - emit ctx; null returns -3
 * @param ta i32 - 1 is Darwin ARM64; any other returns -3
 * @param stack_slot_off i32 - destination frame slot
 * @param type_ref i32 - vector type; f32 fill selects fcmp
 * @return i32 - 0 when every lane is stored; -3 decline; -1 failure
 * PLATFORM: MACOS|ARM64.
 */
function vlet_emit_lane_log(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let rc: i32 = 0;
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let li: i32 = 0;
  let lane_f32: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  if (arena == (0 as *u8)) {
    return 0 - 3;
  }
  if (elf_ctx == (0 as *u8)) {
    return 0 - 3;
  }
  if (ctx == (0 as *u8)) {
    return 0 - 3;
  }
  if (init_ref <= 0) {
    return 0 - 3;
  }
  if (ta != 1) {
    return 0 - 3;
  }
  rc = vlet_f32_fill_lane(arena, type_ref);
  if (rc != 0) {
    lane_f32 = 1;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
  }
  if (rc != 0) {
    return 0 - 3;
  }
  lanes = lanes_s[0];
  esz = esz_s[0];
  if (esz != 4) {
    return 0 - 3;
  }
  if (lanes <= 0) {
    return 0 - 3;
  }
  li = 0;
  while (li < lanes) {
    rc = vlet_lane_log_one(
      arena, elf_ctx, init_ref, li, esz, ctx, ta, lane_f32, 0);
    if (rc != 0) {
      return rc;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, li * esz, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    li = li + 1;
  }
  return 0;
}

/**
 * Store SIMD ARRAY_LIT lanes, a lane binop, or a scalar lit splat.
 * @param arena *u8 — AST arena; null returns -3
 * @param elf_ctx *u8 — object writer; null returns -3
 * @param init_ref i32 — initializer expr; not positive returns -3
 * @param ctx *u8 — AsmFuncCtx; null returns -3
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of lane 0
 * @param type_ref i32 — let type; not a SIMD vector spelling returns -3
 * @return i32 — 0 when kind 46, a lane binop, a scalar lit, unary-minus
 *   of an integer lit, a VAR, a FIELD, a lane binop, a CALL, a METHOD,
 *   an INDEX, a DEREF, or an ARRAY_LIT is stored; -1 when that store fails;
 *   -3 when this face does not handle the expr
 * Kind 46 (ARRAY_LIT) calls pipeline_asm_emit_vector_let_init_elf_c.
 * Kinds 4..13 call pipeline_asm_emit_vector_binop_let_init_elf_c
 * (kind 51 is add). Kinds 20 and 21 call vlet_emit_lane_log.
 * Each lane is 0 or 1 from vlet_lane_cmp_one, combined with and
 * or with orr. Kind 24 calls that same emitter and inverts each
 * lane. Kind 0 (INT_LIT)
 * and kind 2 (BOOL_LIT) call
 * glue_simd_emit_imm_fill_slot_c. On an f32 fill target the kind 0
 * value is converted with glue_i32_to_f32_bits first. Kind 23 in that
 * chain keeps the integer bits. Kind 2 is not converted. Kind 22
 * (EXPR_NEG) of an INT_LIT
 * negates that value and calls the same fill. Kind 22 of a VAR (kind
 * 3) or a FIELD (kind 44) with a frame home negates each i32 lane via
 * neg w0. An f32 lane flips bit 31 instead: the existing mov writes
 * the sign bit into w1, then eor x0, x0, x1. A 4-byte lane load is
 * LDR w0, so that 64-bit eor touches only bit 31, including -0 and a
 * NaN payload. The destination lea runs after the eor because it
 * clobbers x1. The home comes from glue_vector_var_lane_stack_off_elf_c.
 * A negative home declines before any emit. Kind 22 of a lane binop
 * (kinds 4..13 and 51) stores that binop with
 * pipeline_asm_emit_vector_binop_let_init_elf_c, then negates each
 * destination lane in place. Kind 22 of a CALL (kind 48) or a METHOD
 * (kind 49), an INDEX (kind 47), or a DEREF (kind 52) stores that
 * value with glue_emit_struct_type_let_init_elf_c, then negates each destination
 * lane in place. A transparent EXPR_BLOCK (kind 26) is replaced by
 * its value expr first, using glue_expr_block_transparent_value_ref_at,
 * at most four times. Kind 25 (IF) and kind 27 (TERNARY) call
 * glue_emit_vector_if_let_init_elf_c. Wider than 16 bytes fills
 * every lane. 16 bytes uses the retval pair, except an ARRAY_LIT
 * arm, which uses the existing lane writer.
 * Named i32x8 is the wide spelling. That sibling returns -3 with no bytes
 * emitted when an arm is not a literal chain, a VAR, a FIELD with a
 * lane-0 home, an ARRAY_LIT, a lane binop, a block that still has
 * lets, a nested if or ternary, a unary whose innermost expr is a
 * VAR, a FIELD, an INDEX, a CALL, a METHOD, a lane binop
 * (kinds 4..13), an ARRAY_LIT, a block that still has lets, or a
 * DEREF, a bare INDEX, or a bare DEREF.
 * That unary is the existing vector let-init, which already applies
 * the chain on every lane. A unary of an INDEX is that let-init's
 * existing copy, then the chain. A unary of a CALL or a METHOD is
 * that let-init's existing sret, then the chain. A unary of a lane
 * binop is that let-init's existing binop writer, then the chain.
 * A unary of an ARRAY_LIT is that let-init's existing lane-byte
 * writer, then the chain. A unary of a block that still has lets is
 * that let-init's existing lane chain, then this chain. The block is
 * not made transparent. A unary of a DEREF is that let-init's existing
 * struct let-init copy of the target, then the chain. The store is
 * not through the pointer. Kind 51 is excluded before the classifier
 * because it remaps 51 to add. A bare deref is not that unary walk.
 * It is that let-init's existing struct let-init copy of the target.
 * The store is not through the pointer. A deref under lets is that
 * same struct let-init copy. The store is not through the pointer.
 * A bare FIELD is the same large copy as a VAR. A CALL, a METHOD,
 * an INDEX, or a bare DEREF is that let-init's existing struct let-init.
 * A nested if is that same call. Kind 51 stays out.
 * Vec4f stays declined because it is
 * 16 bytes. Kind 22 of an ARRAY_LIT (kind 46) stores that literal
 * with pipeline_asm_emit_vector_let_init_elf_c, then negates each
 * destination lane in place. Kind 23 (EXPR_BITNOT) uses that same
 * classification and emits mvn w0 on each i32 lane. f32 bitwise not
 * returns -3. An i32 immediate not is `-imm - 1` splatted by the
 * existing fill. Kind 24 of a BOOL_LIT is not the lane-log loop.
 * true is 1 and false is 0. This fill splats 1 minus that value
 * and keeps the integer bits. Kind 24 of a compare stays on the
 * lane loop. A chain of kind 22 and kind 23 whose innermost
 * expr is a non-null INT_LIT is one walk, at most 32 steps, applied
 * inside out, then the same fill. Probes covered one through eight
 * minuses and the seven-deep mixed chain on lane 0 and lane 7.
 * The same walk, when the innermost expr is a VAR, FIELD, lane binop,
 * CALL, METHOD, INDEX, DEREF, or ARRAY_LIT, materializes that expr
 * once and applies the chain inside out on each lane. `-(~id(z))`
 * of 3 is 4 on lane 0 and lane 7. A 33rd step stays declined.
 * A FLOAT_LIT, or one unary minus of a FLOAT_LIT,
 * on an f32 lane is narrowed with glue_ieee_f64_bits_to_f32_bits and
 * splatted before that integer fold. On a 4-byte integer lane that
 * same literal is truncated toward zero by
 * pipe_modlet_float_expr_trunc_i32 and splatted as that i32. An f32
 * lane still narrows. A lane whose size is not 4 stays declined.
 * One more unary minus of that
 * FLOAT_LIT cancels the sign and uses the same fill. One unary
 * beyond that applies the sign once and uses the same fill. One unary
 * beyond that cancels again. One unary beyond that applies the sign
 * once more. One unary beyond that cancels again. One unary beyond
 * that applies the sign once more. One unary beyond that cancels
 * again. One unary beyond that applies the sign once.
 * One unary beyond that cancels again. One unary
 * beyond that applies the sign once. One unary
 * beyond that cancels again. Thirteen minuses apply
 * the sign once more. Fourteen minuses cancel again.
 * Fifteen minuses apply the sign once more.
 * At most 32 unary minuses of that float are folded.
 * One more stays declined. Keyword null,
 * an f32 element of the integer fold,
 * ta other than 1, and a lane size other than 4 stay on the decline
 * below. Lane size 8 of that pattern stays declined.
 * A lane size other than 4, and a
 * negative pattern whose lane is 8 bytes, stay declined: neg w0 is
 * 32-bit and the fill zero-extends. f64 stays declined. f32 with a
 * 4-byte lane uses the sign-bit eor above, on the same loop that
 * covers VAR, FIELD, a lane binop, CALL, METHOD, INDEX, DEREF, and
 * ARRAY_LIT. A VAR, a FIELD, or an ARRAY_LIT
 * whose lanes are 4 bytes may be wider than 16. The FIELD home is the
 * same slot plus lane times 4, and that helper does not stop at 16.
 * A lane binop stores both halves. CALL and METHOD of a let wider
 * than 16 write the slot through sret. INDEX and DEREF memcpy let_sz.
 * A bare DEREF with no lets is that struct let-init copy. The store
 * is not through the pointer. A deref under lets is that same copy.
 * Bare VAR copy stays declined.
 * A block that still has lets is not one of those four transparent
 * peels. pipeline_lane_operand_emit_let_block_chain emits each
 * block's lets and returns the value expr. Nested blocks are that
 * one call. This function then classifies the value. A unary whose
 * operand is such a block uses that same call inside the existing
 * unary walk. A VAR, FIELD, INDEX, CALL, METHOD, or DEREF value under
 * those lets uses the existing struct let-init. The deref store is
 * not through the pointer. A decline returns -1 so the block is not
 * emitted again.
 * 128 stops only a chain that does not end.
 * A match (kind 43) is the existing struct let-init dest-in-rbx
 * match. Kind 43 is not sent to the if let-init. A decline other
 * than -1 still returns -3, and that path has not stored.
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
  let saw_f: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  let lit_ref: i32 = 0;
  let op_ko: i32 = 0;
  let neg_lit: i32 = 0;
  let not_lit: i32 = 0;
  let lane_not: i32 = 0;
  let enter_unary: i32 = 0;
  let lane_i: i32 = 0;
  let src_off: i32 = 0;
  let from_dest: i32 = 0;
  let lane_f32: i32 = 0;
  let sign_bit: i32 = 0;
  let inner_ref: i32 = 0;
  let inner_ko: i32 = 0;
  let nested_u: i32 = 0;
  let lit_src: i32 = 0;
  let apply_wrap: i32 = 0;
  let deep_ref: i32 = 0;
  let deep_ko: i32 = 0;
  let third_u: i32 = 0;
  let fourth_u: i32 = 0;
  let quad_ref: i32 = 0;
  let quad_ko: i32 = 0;
  let apply_deep: i32 = 0;
  let fifth_u: i32 = 0;
  let pent_ref: i32 = 0;
  let pent_ko: i32 = 0;
  let apply_quad: i32 = 0;
  let sixth_u: i32 = 0;
  let hex_ref: i32 = 0;
  let hex_ko: i32 = 0;
  let apply_pent: i32 = 0;
  let u_knd: i32[32] = [];
  let u_n: i32 = 0;
  let u_cur: i32 = 0;
  let u_kk: i32 = 0;
  let u_stop: i32 = 0;
  let u_i: i32 = 0;
  let u_step: i32 = 0;
  let peeled: i32 = 0;
  let peel_n: i32 = 0;
  let saw_lets: i32 = 0;
  let store_go: i32 = 0;
  let f_ref: i32 = 0;
  let f_ko: i32 = 0;
  let f_lo: i32 = 0;
  let f_hi: i32 = 0;
  let f_bits: i32 = 0;
  let f_iv: i32[1] = [];
  let f_neg: i32 = 0;
  let f_sign: i32 = 0;
  let f_in: i32 = 0;
  let f_in_k: i32 = 0;
  let f_deep: i32 = 0;
  let f_deep_k: i32 = 0;
  let f_quad: i32 = 0;
  let f_quad_k: i32 = 0;
  let f_pent: i32 = 0;
  let f_pent_k: i32 = 0;
  let f_hex: i32 = 0;
  let f_hex_k: i32 = 0;
  let f_sept: i32 = 0;
  let f_sept_k: i32 = 0;
  let f_oct: i32 = 0;
  let f_oct_k: i32 = 0;
  let f_nona: i32 = 0;
  let f_nona_k: i32 = 0;
  let f_deca: i32 = 0;
  let f_deca_k: i32 = 0;
  let f_undeca: i32 = 0;
  let f_undeca_k: i32 = 0;
  let f_duodeca: i32 = 0;
  let f_duodeca_k: i32 = 0;
  let f_tredeca: i32 = 0;
  let f_tredeca_k: i32 = 0;
  let f_quattuordeca: i32 = 0;
  let f_quattuordeca_k: i32 = 0;
  let f_quindecim: i32 = 0;
  let f_quindecim_k: i32 = 0;
  let lit_gate: i32 = 0;
  let lit_prev: i32 = 0;
  let log_k: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 3;
  }
  unsafe {
    simd = asm_type_is_simd_vector_spelling(arena, type_ref);
  }
  if (simd == 0) {
    return 0 - 3;
  }
  // EXPR_BLOCK = 26. `unsafe { e }` and `{ e }` with one value and no
  // lets or loops are not the initializer. The existing peel returns
  // that value. Leaving the block in place declined into one neg w0
  // (`let n = unsafe { -*p }`, lane 1 was 0) or stored the array
  // pointer (`let n = unsafe { [1, 2, 3, 4] }`, lane 0 was not 1).
  // A peel that is not positive, or that returns the same ref, stops.
  // Bare VAR still returns -3 so the caller keeps that copy. A bare
  // DEREF is stored below. The store is not through the pointer.
  // PLATFORM: MACOS|ARM64.
  peel_n = 0;
  while (peel_n < 4) {
    peeled = 0;
    unsafe {
      peeled = glue_expr_block_transparent_value_ref_at(arena, init_ref);
    }
    if (peeled <= 0) {
      peel_n = 4;
    } else {
      if (peeled == init_ref) {
        peel_n = 4;
      } else {
        init_ref = peeled;
        peel_n = peel_n + 1;
      }
    }
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  // A block that still has lets is not transparent. Returning -3
  // here made the caller store at most 16 bytes, so lane 7 of
  // `let n = { let k; k + k }` was not the sum. The existing lane
  // chain emits each block's lets and returns the value expr.
  // Nested blocks are that one function. The arms below classify
  // the value. A VAR, FIELD, INDEX, CALL, METHOD, or DEREF value
  // uses the struct let-init copy at the end of this function. The
  // deref store is not through the pointer. 128 stops only a chain
  // that does not end. PLATFORM: MACOS|ARM64.
  if (ko == 26) {
    unsafe {
      peeled = pipeline_lane_operand_emit_let_block_chain(
        arena, elf_ctx, init_ref, ctx, ta, 128);
    }
    if (peeled <= 0) {
      return 0 - 1;
    }
    if (peeled == init_ref) {
      return 0 - 1;
    }
    init_ref = peeled;
    saw_lets = 1;
    unsafe {
      ko = pipeline_expr_kind_ord_at(arena, init_ref);
    }
    if (ko == 26) {
      return 0 - 1;
    }
  }
  /*
   * EXPR_IF = 25 and EXPR_TERNARY = 27. A frame Vec8i let of
   * `if (c) { 3 } else { -3 }` or of two Vec8i vars used to fall
   * through to a 16-byte pair store. The sibling fills every lane
   * when the spelling is wider than 16 bytes. A 16-byte spelling
   * is stored there by emit_expr and the existing retval pair.
   * Other declines return -3 before emitting. Slot -3 is dest-in-rbx
   * and stays on that decline. PLATFORM: MACOS|ARM64.
   */
  if (ko == 25) {
    unsafe {
      rc = glue_emit_vector_if_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    }
    return rc;
  }
  if (ko == 27) {
    unsafe {
      rc = glue_emit_vector_if_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    }
    return rc;
  }
  // EXPR_MATCH = 43. The value form already stores each arm through
  // struct let-init. That copy is the full spelling, including a
  // vector wider than 16 bytes. Returning -3 here made an address
  // of the match fail before that store. A code other than 0 or -1
  // has not committed a store, so the caller still falls through.
  // Do not send kind 43 into the if let-init. PLATFORM: MACOS|ARM64.
  if (ko == 43) {
    unsafe {
      rc = glue_emit_struct_type_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, type_ref, stack_slot_off);
    }
    if (rc == 0) {
      return 0;
    }
    if (rc == (0 - 1)) {
      return 0 - 1;
    }
    return 0 - 3;
  }
  // EXPR_ARRAY_LIT = 46. Store the lane bytes, not the buffer address.
  // f32x8 used to store each lane as a 4-byte scalar. `1` stayed the
  // integer 1. `-1.0` was the low half of the f64 bits, so lane 1 read
  // as 0. Four, eight, and sixteen f32 lanes are stored here from the
  // destination type. An integer spelling keeps the typeless lane
  // store. PLATFORM: MACOS|ARM64.
  if (ko == 46) {
    rc = vlet_f32_array_lanes(
      arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (rc != 1) {
      return rc;
    }
    unsafe {
      rc = pipeline_asm_emit_vector_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
    }
    return rc;
  }
  // EXPR_EQ..GE are 14..19. The lane-binop set stops at 13, so the
  // first qword was compared once. An i32 lane uses sxtw, cmp, and
  // cset. An f32 lane uses the existing fcmp and FP setcc. Both store
  // 0 or 1. A FLOAT_LIT still arrived as f64 bits, so 1.0 and 2.0
  // both had a zero low half and compared equal. The same gate as
  // add/sub/mul/div narrows that literal before fcmp. i32 does not
  // set it. PLATFORM: MACOS|ARM64. The gate symbol is SHARED.
  if (vlet_lane_cmp_ko(ko) != 0) {
    lit_gate = 0;
    lit_prev = 0;
    if (vlet_f32_fill_lane(arena, type_ref) != 0) {
      unsafe {
        lit_prev = glue_lane_f32_lit_dest_set(1);
      }
      lit_gate = 1;
    }
    rc = vlet_emit_i32_lane_cmp(
      arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (lit_gate != 0) {
      unsafe {
        lit_prev = glue_lane_f32_lit_dest_set(lit_prev);
      }
    }
    return rc;
  }
  // Kind 20 is logical and. Kind 21 is logical or. Kind 24 is
  // logical not. Each lane stores 0 or 1 from vlet_lane_cmp_one.
  // Kind 20 and kind 21 combine with and or with orr. Kind 24
  // inverts that bit when the operand is not a BOOL_LIT. A
  // BOOL_LIT is 1 or 0. The lane-log child declines it, so that
  // operand stays for the imm fill, which splats 1 minus the
  // value. The f32 literal gate matches the compare
  // arm. A child that is not a compare, not kind 20, not kind 21,
  // and not kind 24 returns -3. No second temp.
  // PLATFORM: MACOS|ARM64.
  log_k = 0;
  if (ko == 20) {
    log_k = 1;
  }
  if (ko == 21) {
    log_k = 1;
  }
  if (ko == 24) {
    // BOOL_LIT (kind 2) falls through. Any other operand, including
    // a compare, stays on the lane loop above. lit_ref is cleared
    // when this is not that literal, so the splat below does not
    // see a variable. PLATFORM: MACOS|ARM64.
    unsafe {
      lit_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
    }
    op_ko = 0;
    if (lit_ref > 0) {
      unsafe {
        op_ko = pipeline_expr_kind_ord_at(arena, lit_ref);
      }
    }
    if (op_ko != 2) {
      lit_ref = 0;
      log_k = 1;
    }
  }
  if (log_k != 0) {
    lit_gate = 0;
    lit_prev = 0;
    if (vlet_f32_fill_lane(arena, type_ref) != 0) {
      unsafe {
        lit_prev = glue_lane_f32_lit_dest_set(1);
      }
      lit_gate = 1;
    }
    rc = vlet_emit_lane_log(
      arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    if (lit_gate != 0) {
      unsafe {
        lit_prev = glue_lane_f32_lit_dest_set(lit_prev);
      }
    }
    return rc;
  }
  // Lane binop. Do not decline into the dual-GP pair store.
  // Add, sub, mul, and div of an f32 vector set the literal gate so a
  // FLOAT_LIT operand is f32 bits and takes divss, not integer div of
  // the f64 low half. i32x8 does not set it. The previous gate is
  // restored before return. PLATFORM: MACOS|ARM64. The gate symbol is SHARED.
  unsafe {
    rc = glue_is_vector_lane_scalar_binop_ko(ko);
  }
  if (rc != 0) {
    lit_gate = 0;
    lit_prev = 0;
    if (ko == 4 || ko == 5 || ko == 6 || ko == 7) {
      if (vlet_f32_fill_lane(arena, type_ref) != 0) {
        unsafe {
          lit_prev = glue_lane_f32_lit_dest_set(1);
        }
        lit_gate = 1;
      }
    }
    unsafe {
      rc = pipeline_asm_emit_vector_binop_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, type_ref);
    }
    if (lit_gate != 0) {
      unsafe {
        lit_prev = glue_lane_f32_lit_dest_set(lit_prev);
      }
    }
    return rc;
  }
  // FLOAT_LIT = 1, one EXPR_NEG of a FLOAT_LIT (`-1.0`), one more
  // EXPR_NEG of that (`-(-1.0)`), one unary beyond that
  // (`-(-(-1.0))`), one unary beyond that (`-(-(-(-1.0)))`), or one
  // unary beyond that (`-(-(-(-(-1.0))))`). The parser stores the
  // magnitude as f64 bits. The existing glue_ieee_f64_bits_to_f32_bits
  // narrows those bits. The existing glue_simd_emit_imm_fill_slot_c
  // splats the f32 pattern. Two minuses cancel, so that unary does
  // not xor the sign bit. Three minuses apply the sign once. Four
  // minuses cancel again. Five minuses apply the sign once more. Six
  // minuses cancel again. Seven minuses apply the sign once more.
  // Eight minuses cancel again. Nine minuses apply the sign once.
  // Ten minuses cancel again. Eleven minuses apply the sign once.
  // Twelve minuses cancel again. Thirteen minuses apply the sign
  // once more. Fourteen minuses cancel again. Fifteen minuses apply
  // the sign once more. At most 32 minuses are folded. One more
  // stays on the decline below. Bitwise not
  // of a float stays declined. An f32 lane narrows. A 4-byte
  // integer lane truncates toward zero. The lane size is 4 and
  // ta is 1. An f64 lane stays declined.
  // The sign bit is two statements (0x80000000), xored into the f64
  // high half before the narrow. PLATFORM: MACOS|ARM64.
  f_ref = 0;
  f_ko = 0;
  f_neg = 0;
  f_in = 0;
  f_in_k = 0;
  f_deep = 0;
  f_deep_k = 0;
  f_quad = 0;
  f_quad_k = 0;
  f_pent = 0;
  f_pent_k = 0;
  f_hex = 0;
  f_hex_k = 0;
  f_sept = 0;
  f_sept_k = 0;
  f_oct = 0;
  f_oct_k = 0;
  f_nona = 0;
  f_nona_k = 0;
  if (ko == 1) {
    f_ref = init_ref;
    f_ko = 1;
    f_neg = 0;
  }
  /*
   * Walk EXPR_NEG (kind 22) until the operand is not another
   * minus. The innermost must be a FLOAT_LIT (kind 1).
   * An odd count applies the sign once in the emitter. An
   * even count cancels. Stop at 32 steps so a corrupt kind-22
   * cycle cannot hang the compile. One more minus stays
   * declined. Kind 23 and kind 24 do not enter. This is a
   * loop, not a recursive call: the frame is already near the
   * cap-tip stack budget. The bound is its own compare. A
   * chained && clobbers a register in the bootstrap image.
   * PLATFORM: MACOS|ARM64.
   */
  if (ko == 22) {
    f_in = init_ref;
    f_deep = 0;
    f_in_k = 22;
    f_neg = 0;
    while (f_in_k == 22) {
      if (f_deep < 32) {
        f_quad = 0;
        unsafe {
          f_quad = pipeline_expr_unary_operand_ref_at(arena, f_in);
        }
        if (f_quad <= 0) {
          f_in_k = 0;
        } else {
          f_in = f_quad;
          f_deep = f_deep + 1;
          if (f_neg == 0) {
            f_neg = 1;
          } else {
            f_neg = 0;
          }
          unsafe {
            f_in_k = pipeline_expr_kind_ord_at(arena, f_in);
          }
        }
      } else {
        f_in_k = 0;
      }
    }
    if (f_in_k == 1) {
      if (f_deep > 0) {
        f_ref = f_in;
        f_ko = 1;
      }
    }
    if (f_in_k != 1) {
      f_neg = 0;
    }
  }

  if (f_ko == 1) {
    if (f_ref > 0) {
      if (ta == 1) {
        unsafe {
          rc = vlet_f32_fill_lane(arena, type_ref);
        }
        if (rc != 0) {
          unsafe {
            rc = glue_vector_type_lanes_esz_c(
              arena, type_ref, &lanes_s[0], &esz_s[0]);
          }
          if (rc == 0) {
            if (esz_s[0] == 4) {
              if (lanes_s[0] > 0) {
                unsafe {
                  f_lo = pipeline_expr_float_bits_lo_at(arena, f_ref);
                  f_hi = pipeline_expr_float_bits_hi_at(arena, f_ref);
                }
                if (f_neg != 0) {
                  f_sign = 0 - 2147483647;
                  f_sign = f_sign - 1;
                  f_hi = f_hi ^ f_sign;
                }
                unsafe {
                  f_bits = glue_ieee_f64_bits_to_f32_bits(f_lo, f_hi);
                  rc = glue_simd_emit_imm_fill_slot_c(
                    elf_ctx, stack_slot_off, lanes_s[0], esz_s[0], ta, f_bits);
                }
                return rc;
              }
            }
          }
        }
        // vlet_f32_fill_lane returned 0: this spelling is not f32.
        // A 4-byte integer lane truncates the f64 literal toward zero
        // and splats that i32. The walk owns the exponent loop.
        // f_neg is the minus parity already counted above; the inner
        // literal keeps its own sign. A return other than 1 has not
        // stored. An f64 lane stays declined. PLATFORM: MACOS|ARM64.
        if (rc == 0) {
          unsafe {
            rc = glue_vector_type_lanes_esz_c(
              arena, type_ref, &lanes_s[0], &esz_s[0]);
          }
          if (rc == 0) {
            if (esz_s[0] == 4) {
              if (lanes_s[0] > 0) {
                f_iv[0] = 0;
                unsafe {
                  rc = pipe_modlet_float_expr_trunc_i32(
                    arena, f_ref, &f_iv[0]);
                }
                if (rc == 1) {
                  imm = f_iv[0];
                  if (f_neg != 0) {
                    imm = 0 - imm;
                  }
                  unsafe {
                    rc = glue_simd_emit_imm_fill_slot_c(
                      elf_ctx, stack_slot_off, lanes_s[0], esz_s[0], ta, imm);
                  }
                  return rc;
                }
              }
            }
          }
        }
      }
    }
  }
  // EXPR_INT_LIT = 0, EXPR_BOOL_LIT = 2. Splat the i32 into every lane.
  // EXPR_NEG = 22 over an INT_LIT is the parser form of `-3`. Negate
  // that literal and splat with the same fill. A decline stores
  // zero-extended `neg w0` plus untouched x1, so lane 1 of i32x4 = -3
  // is 0. An f32 FLOAT_LIT is the arm above. A 4-byte integer lane
  // of an f64 literal is that same arm. Any other f64 literal stays
  // declined.
  // Lane size 8 of a negative pattern stays declined: the fill
  // zero-extends the 32-bit immediate, which is not a negative i64.
  // EXPR_BITNOT = 23 shares this operand split. mvn w0 is per i32
  // lane. f32 bitwise not returns -3 inside the non-literal arm.
  // PLATFORM: MACOS|ARM64.
  if (ko == 0 || ko == 2) {
    lit_ref = init_ref;
  }
  if (ko == 22) {
    enter_unary = 1;
  }
  if (ko == 23) {
    enter_unary = 1;
    lane_not = 1;
  }
  if (enter_unary != 0) {
    unsafe {
      lit_ref = pipeline_expr_unary_operand_ref_at(arena, init_ref);
    }
    if (lit_ref <= 0) {
      return 0 - 3;
    }
    unsafe {
      op_ko = pipeline_expr_kind_ord_at(arena, lit_ref);
    }
    // Walk kind 22 and kind 23, at most 32 steps, outermost first.
    // An innermost non-null INT_LIT is the stamp below. Apply from the
    // inside out: kind 22 negates, kind 23 is `-imm - 1`. Kind 24 does
    // not enter. A VAR, a binop, CALL, METHOD, INDEX, DEREF, or
    // ARRAY_LIT is classified below, and the same chain is applied
    // inside out on each lane. Keyword null stays declined.
    // Lane size other than 4, ta other than 1, and an f32 element stay
    // declined. One more than 32 steps stays declined.
    // PLATFORM: MACOS|ARM64.
    u_n = 0;
    u_cur = init_ref;
    u_kk = ko;
    u_stop = 0;
    while (u_stop == 0) {
      if (u_n < 32) {
        if (u_kk == 22) {
          u_knd[u_n] = 22;
          u_n = u_n + 1;
          unsafe {
            u_step = pipeline_expr_unary_operand_ref_at(arena, u_cur);
          }
          if (u_step <= 0) {
            u_kk = -1;
            u_stop = 1;
          } else {
            u_cur = u_step;
            unsafe {
              u_kk = pipeline_expr_kind_ord_at(arena, u_cur);
            }
          }
        } else {
          if (u_kk == 23) {
            u_knd[u_n] = 23;
            u_n = u_n + 1;
            unsafe {
              u_step = pipeline_expr_unary_operand_ref_at(arena, u_cur);
            }
            if (u_step <= 0) {
              u_kk = -1;
              u_stop = 1;
            } else {
              u_cur = u_step;
              unsafe {
                u_kk = pipeline_expr_kind_ord_at(arena, u_cur);
              }
            }
          } else {
            // The operand under the unary is a block with lets.
            // Declining it stored one scalar complement, so lane 7
            // of `~{ let k; k + k }` was not that complement. The
            // existing lane chain emits each block's lets and
            // returns the value. Nested blocks are that one
            // function. This walk then records a unary value.
            // 128 stops only a chain that does not end.
            // PLATFORM: MACOS|ARM64.
            if (u_kk == 26) {
              unsafe {
                u_step = pipeline_lane_operand_emit_let_block_chain(
                  arena, elf_ctx, u_cur, ctx, ta, 128);
              }
              if (u_step <= 0) {
                return 0 - 1;
              }
              if (u_step == u_cur) {
                return 0 - 1;
              }
              u_cur = u_step;
              saw_lets = 1;
              unsafe {
                u_kk = pipeline_expr_kind_ord_at(arena, u_cur);
              }
              if (u_kk == 26) {
                return 0 - 1;
              }
            } else {
              u_stop = 1;
            }
          }
        }
      } else {
        // Kind 0 is INT_LIT. A 33rd step must fall through, not fill.
        u_kk = -1;
        u_stop = 1;
      }
    }
    if (u_kk == 0) {
      if (u_n > 0) {
        unsafe {
          rc = pipeline_expr_is_null_keyword_c(arena, u_cur);
        }
        if (rc == 0) {
          if (ta == 1) {
            unsafe {
              rc = glue_vector_elem_is_f32_c(arena, type_ref);
            }
            if (rc == 0) {
              unsafe {
                imm = pipeline_expr_int_val_at(arena, u_cur);
                rc = glue_vector_type_lanes_esz_c(
                  arena, type_ref, &lanes_s[0], &esz_s[0]);
              }
              if (rc == 0) {
                if (esz_s[0] == 4) {
                  if (lanes_s[0] > 0) {
                    u_i = u_n;
                    saw_f = 0;
                    while (u_i > 0) {
                      u_i = u_i - 1;
                      if (u_knd[u_i] == 22) {
                        imm = 0 - imm;
                      }
                      if (u_knd[u_i] == 23) {
                        saw_f = 1;
                        imm = 0 - imm;
                        imm = imm - 1;
                      }
                    }
                    // The linked classifier misses f32x8, so `let v = -1`
                    // splatted the i32 bits and lane 0 was not -1.0.
                    // Convert only when no kind 23 was applied. f32
                    // bitwise not keeps those integer bits.
                    // PLATFORM: MACOS|ARM64.
                    unsafe {
                      rc = vlet_f32_fill_lane(arena, type_ref);
                    }
                    if (rc != 0) {
                      if (saw_f == 0) {
                        unsafe {
                          imm = glue_i32_to_f32_bits(imm);
                        }
                      }
                    }
                    unsafe {
                      rc = glue_simd_emit_imm_fill_slot_c(
                        elf_ctx, stack_slot_off, lanes_s[0], esz_s[0], ta, imm);
                    }
                    return rc;
                  }
                }
              }
            }
          }
        }
      }
    }
    // The first operand of `-(~id(z))` is still kind 23. The walk
    // already stopped on the call. Classify that innermost expr.
    // The stamp above returned when it is an INT_LIT. Kind -1 is the
    // cap or a broken operand and stays declined. Kind 0 stays on the
    // literal fallback below. PLATFORM: MACOS|ARM64.
    if (u_n > 0) {
      if (u_kk > 0) {
        lit_ref = u_cur;
        op_ko = u_kk;
      } else {
        if (u_kk < 0) {
          return 0 - 3;
        }
      }
    }
    if (op_ko != 0) {
      // Non-literal NEG. A VAR (kind 3) or a FIELD (kind 44) is
      // lane-addressable here. A lane binop (kinds 4..13 and 51) is
      // stored into the destination by the existing binop writer, then
      // each of those lanes is negated in place. A CALL (kind 48) or a
      // METHOD (kind 49), an INDEX (kind 47), or a DEREF (kind 52) is
      // stored by the existing struct let-init, then negated the same
      // way. The deref store lands in the destination slot, not through
      // the pointer. Declining
      // this stored neg of lane 0 only: lane 1 of `let v = -a` was 0,
      // lane 1 of `let n = -h.v` was 0, lane 1 of `let n = -(a + b)`
      // was 0, lane 1 of `let n = -id(a)` was 0, and lane 1 of
      // `let n = -arr[1]` was 0, and lane 1 of `n = -*p` was 0. An
      // ARRAY_LIT (kind 46) is stored by
      // the existing lane-byte writer, then negated the same way.
      // Declining that left lane 0 of `let n = -[1, 2, 3, 4]` unequal
      // to -1. The width gate runs before that store, so a decline
      // emits nothing. INDEX, DEREF, CALL, and METHOD wider than 16
      // copy or sret the whole value, then the chain runs inside out.
      // A bare CALL or a bare DEREF is not this unary. A bare DEREF
      // with no lets is stored below. ta != 1 stays declined.
      // PLATFORM: MACOS|ARM64.
      if (ta != 1) {
        return 0 - 3;
      }
      from_dest = 0;
      unsafe {
        rc = glue_is_vector_lane_scalar_binop_ko(op_ko);
      }
      if (rc != 0) {
        from_dest = 1;
      } else {
        if (op_ko == 48 || op_ko == 49 || op_ko == 47 || op_ko == 52) {
          from_dest = 2;
        } else {
          if (op_ko == 46) {
            from_dest = 3;
          } else {
            if (op_ko != 3 && op_ko != 44) {
              if (saw_lets != 0) {
                return 0 - 1;
              }
              return 0 - 3;
            }
          }
        }
      }
      unsafe {
        rc = glue_vector_elem_is_f32_c(arena, type_ref);
      }
      // Nonzero means Vec4f or the f32x4 spelling. The linked
      // classifier does not accept f32x8. Unary minus of an f32x8
      // VAR then did neg w0 on the lane bits, so 1.0 (0x3f800000)
      // became 0xC0800000 instead of -1.0. When the chain has no
      // kind 23, ask the existing f32 fill helper and xor bit 31.
      // A kind 23 in the chain stays the integer not: f32x8 ~1 and
      // ~a keep those bits. Vec4f and f32x4 already take the
      // classifier arm. An f32 lane with kind 23 still returns -3
      // when the classifier is nonzero. esz other than 4 still
      // returns -3 below. PLATFORM: MACOS|ARM64.
      nested_u = 0;
      u_i = 0;
      while (u_i < u_n) {
        if (u_knd[u_i] == 23) {
          nested_u = 1;
        }
        u_i = u_i + 1;
      }
      if (nested_u != 0) {
        if (rc != 0) {
          return 0 - 3;
        }
      } else {
        if (rc != 0) {
          lane_f32 = 1;
        } else {
          unsafe {
            rc = vlet_f32_fill_lane(arena, type_ref);
          }
          if (rc != 0) {
            lane_f32 = 1;
          }
        }
      }
      unsafe {
        rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
      }
      // Lane size other than 4 stays declined: neg w0 is 32-bit.
      // INDEX and DEREF memcpy let_sz when it is above 16. CALL and
      // METHOD of a let type above 16 take the sret arm: the callee
      // writes this slot, which `let v = id(z)` already fills through
      // lane 7. The negate loop then sees every lane. A 16-byte store
      // would leave lane 7 unset, so this gate used to decline kinds
      // 48 and 49. That store is no longer 16 bytes. The deref store
      // is not through the pointer. A lane binop (from_dest 1) uses
      // the existing binop let-init.
      // On arm64 that writer stores both 128-bit halves of an i32x8
      // add: ld1.4s, add.4s, st1.4s at +0 and at +16. The scalar
      // fallback loops every lane. Declining the binop left
      // `let v: i32x8 = -(a + b)` as add w0, neg w0, and one str x0,
      // so lane 0 was -11 and lane 7 was never stored. VAR and FIELD
      // use the existing lane home (slot + lane * 4). That home has
      // no 16-byte cap. The field slot already holds every lane.
      // ARRAY_LIT uses the existing lane-byte writer, which already
      // stores every element. from_dest 0 is only VAR (kind 3) or
      // FIELD (kind 44).
      // PLATFORM: MACOS|ARM64.
      if (rc != 0 || esz_s[0] != 4 || lanes_s[0] <= 0) {
        return 0 - 3;
      }
      if (from_dest == 1) {
        // -(4.0 / 2.0) called this writer with the literal gate clear.
        // 4.0 and 2.0 then took integer div of the f64 low halves, both
        // 0, and the sign xor below did not store -2.0. Kinds 4..7 of
        // an f32 dest use the same gate as a bare lane binop. Kinds
        // 8..13 do not. i32 leaves lane_f32 at 0. Restore the previous
        // gate before that xor. PLATFORM: MACOS|ARM64. The gate symbol
        // is SHARED.
        lit_gate = 0;
        lit_prev = 0;
        if (lane_f32 != 0) {
          if (op_ko == 4 || op_ko == 5 || op_ko == 6 || op_ko == 7) {
            unsafe {
              lit_prev = glue_lane_f32_lit_dest_set(1);
            }
            lit_gate = 1;
          }
        }
        unsafe {
          rc = pipeline_asm_emit_vector_binop_let_init_elf_c(
            arena, elf_ctx, lit_ref, ctx, ta, stack_slot_off, type_ref);
        }
        if (lit_gate != 0) {
          unsafe {
            lit_prev = glue_lane_f32_lit_dest_set(lit_prev);
          }
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        if (from_dest == 2) {
          // CALL and METHOD set the expected return type. Above 16 bytes
          // the callee writes this slot through sret and returns
          // before the pair store. INDEX and DEREF lea the lvalue and
          // memcpy let_sz bytes into this slot. Above 16 that count is
          // the whole value (Vec8i is 32), not a 16-byte pair. A
          // hand-rolled emit keeps 8 bytes. This does not assign
          // through the pointer. Non-zero may already have emitted,
          // so do not fall through to scalar neg.
          // PLATFORM: MACOS|ARM64.
          unsafe {
            rc = glue_emit_struct_type_let_init_elf_c(
              arena, elf_ctx, lit_ref, ctx, ta, type_ref, stack_slot_off);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        } else {
          if (from_dest == 3) {
            // The lane-byte writer stores the positive literal. The
            // shared neg loop then flips each destination lane. A
            // scalar neg of this literal leaves a pointer, so lane 0
            // is not -1. Non-zero may already have emitted.
            // PLATFORM: MACOS|ARM64.
            unsafe {
              rc = pipeline_asm_emit_vector_let_init_elf_c(
                arena, elf_ctx, lit_ref, ctx, ta, stack_slot_off);
            }
            if (rc != 0) {
              return 0 - 1;
            }
          } else {
            lane_i = 0;
            while (lane_i < lanes_s[0]) {
              unsafe {
                src_off = glue_vector_var_lane_stack_off_elf_c(
                  arena, ctx, lit_ref, lane_i, esz_s[0], ta);
              }
              if (src_off < 0) {
                return 0 - 3;
              }
              lane_i = lane_i + 1;
            }
          }
        }
      }
      // Sign bit of f32 is bit 31. Two statements: a chained
      // `0 - 2147483647 - 1` is not reliable here. 0 - 2147483647 is
      // -2147483647; minus 1 is the i32 bit pattern 0x80000000.
      // The value is passed to the existing mov-imm. It is not a
      // shift emitted into the user program. i32 leaves sign_bit at 0
      // and still emits neg w0. PLATFORM: MACOS|ARM64.
      if (lane_f32 != 0) {
        sign_bit = 0 - 2147483647;
        sign_bit = sign_bit - 1;
      }
      lane_i = 0;
      while (lane_i < lanes_s[0]) {
        if (from_dest != 0) {
          src_off = stack_slot_off + (lane_i * esz_s[0]);
        } else {
          unsafe {
            src_off = glue_vector_var_lane_stack_off_elf_c(
              arena, ctx, lit_ref, lane_i, esz_s[0], ta);
          }
        }
        unsafe {
          rc = backend_enc_load_rbp_lane_to_rax_arch(elf_ctx, src_off, esz_s[0], ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        // u_knd is outermost first. Apply from the inside out, the same
        // order as the integer stamp. Kind 23 is mvn w0. Kind 22 is
        // neg w0, or one sign-bit xor when the lane is f32. A bitnot
        // of f32 already returned. Two xors cancel. lea below clobbers
        // x1, so every xor stays before that lea.
        // PLATFORM: MACOS|ARM64.
        u_i = u_n;
        while (u_i > 0) {
          u_i = u_i - 1;
          if (lane_f32 != 0) {
            unsafe {
              rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, sign_bit, ta);
            }
            if (rc == 0) {
              unsafe {
                rc = backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
              }
            }
          } else {
            if (u_knd[u_i] == 23) {
              unsafe {
                rc = backend_enc_not_eax_arch(elf_ctx, ta);
              }
            } else {
              unsafe {
                rc = backend_enc_neg_eax_arch(elf_ctx, ta);
              }
            }
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        unsafe {
          rc = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, stack_slot_off, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbx_offset_arch(
            elf_ctx, lane_i * esz_s[0], esz_s[0], ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        lane_i = lane_i + 1;
      }
      return 0;
    }
    if (lane_not != 0) {
      not_lit = 1;
    } else {
      neg_lit = 1;
    }
  }
  if (lit_ref > 0) {
    unsafe {
      imm = pipeline_expr_int_val_at(arena, lit_ref);
      rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
    }
    if (rc != 0 || lanes_s[0] <= 0) {
      return 0 - 1;
    }
    if (neg_lit != 0) {
      imm = 0 - imm;
      if (esz_s[0] == 8 && imm < 0) {
        return 0 - 3;
      }
    }
    if (not_lit != 0) {
      // ~x is -x - 1 in two's complement. Two statements. An 8-byte
      // lane would zero-extend this 32-bit pattern, which is not an
      // i64 not. PLATFORM: MACOS|ARM64.
      imm = 0 - imm;
      imm = imm - 1;
      if (esz_s[0] == 8) {
        return 0 - 3;
      }
    }
    if (ko == 24) {
      // Logical not of a BOOL_LIT. true is 1 and false is 0.
      // One subtraction flips that bit. This is not a bitwise not.
      // The f32 arm below sees kind 2 and keeps these integer bits.
      // PLATFORM: MACOS|ARM64.
      imm = 1 - imm;
    }
    // Kind 0 on an f32 fill target was stored as i32 bits. `let v:
    // f32x8 = 1` wrote 1 into every lane, and the 1.0 compare failed.
    // Kind 2 (BOOL_LIT) stays on the integer bits. Kind 23 (not_lit)
    // stays on the integer bits. Kind 24 of that BOOL_LIT stays on
    // the integer bits too. PLATFORM: MACOS|ARM64.
    unsafe {
      rc = vlet_f32_fill_lane(arena, type_ref);
    }
    if (rc != 0) {
      unsafe {
        rc = pipeline_expr_kind_ord_at(arena, lit_ref);
      }
      if (rc == 0) {
        if (not_lit == 0) {
          if (esz_s[0] == 4) {
            unsafe {
              imm = glue_i32_to_f32_bits(imm);
            }
          }
        }
      }
    }
    unsafe {
      rc = glue_simd_emit_imm_fill_slot_c(
        elf_ctx, stack_slot_off, lanes_s[0], esz_s[0], ta, imm);
    }
    return rc;
  }
  // Lets were already written. VAR and FIELD already copy through
  // struct let-init, so lane 7 of `{ let k; k }` is that value.
  // CALL, METHOD, and INDEX used to fall out here and return -1, so
  // `{ let k; id(k) }` and `{ let t; t[i] }` were CG002. Those kinds
  // are the same struct let-init. A DEREF under those lets is that
  // same copy of the target. The store is not through the pointer.
  // A decline still returns -1: the caller must not emit this block a
  // second time. A bare CALL, METHOD, INDEX, or DEREF is stored
  // below. Another bare initializer still returns -3.
  // PLATFORM: MACOS|ARM64.
  if (saw_lets != 0) {
    store_go = 0;
    if (ko == 3) {
      store_go = 1;
    }
    if (ko == 44) {
      store_go = 1;
    }
    if (ko == 47) {
      store_go = 1;
    }
    if (ko == 48) {
      store_go = 1;
    }
    if (ko == 49) {
      store_go = 1;
    }
    if (ko == 52) {
      store_go = 1;
    }
    if (store_go != 0) {
      unsafe {
        rc = glue_emit_struct_type_let_init_elf_c(
          arena, elf_ctx, init_ref, ctx, ta, type_ref, stack_slot_off);
      }
      if (rc == 0) {
        return 0;
      }
      if (rc == (0 - 1)) {
        return 0 - 1;
      }
    }
    return 0 - 1;
  }
  // A bare CALL, METHOD, or INDEX has no lets, so the block above
  // does not run. The block-body let stores those kinds with struct
  // let-init only after this function returns -3. An if arm has no
  // second chance: its fill turns -3 into -1 after the branch is
  // already emitted. Call that same struct let-init here for kind
  // 48, kind 49, kind 47, and kind 52. A return wider than 16
  // bytes is sret into this slot. An INDEX or a DEREF wider than 16
  // bytes is that writer's existing copy. The deref store is not
  // through the pointer. Kind 51 is not one of these kinds. A deref
  // under lets is the with-lets copy above. Another return code has
  // not committed a store, so the old -3 fallback still runs.
  // PLATFORM: MACOS|ARM64.
  store_go = 0;
  if (ko == 48) {
    store_go = 1;
  }
  if (ko == 49) {
    store_go = 1;
  }
  if (ko == 47) {
    store_go = 1;
  }
  if (ko == 52) {
    store_go = 1;
  }
  if (store_go != 0) {
    unsafe {
      rc = glue_emit_struct_type_let_init_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, type_ref, stack_slot_off);
    }
    if (rc == 0) {
      return 0;
    }
    if (rc == (0 - 1)) {
      return 0 - 1;
    }
  }
  return 0 - 3;
}

/**
 * Peel a transparent block, then accept a Vec8i if-arm.
 * @param arena *u8 — AST arena; null returns 0
 * @param ctx *u8 — AsmFuncCtx; null returns 0
 * @param arm_ref i32 — then or else expr; <= 0 returns 0
 * @param esz i32 — lane size in bytes; not 4 returns 0
 * @param ta i32 — 1 is arm64. Other values return 0
 * @return i32 — peeled expr ref when the arm is a non-null INT_LIT,
 *   a kind-22 / kind-23 chain of one, that same chain whose innermost
 *   expr is a VAR or a FIELD with a lane-0 home, an INDEX, a CALL,
 *   a METHOD, a lane binop (kinds 4..13), an ARRAY_LIT, a block
 *   that still has lets, or a DEREF, a VAR or a FIELD with a frame
 *   home, an ARRAY_LIT, a lane binop (kinds 4..13), a block that
 *   still has lets, a nested if
 *   (kind 25) or ternary (kind 27), a CALL (kind 48), a METHOD
 *   (kind 49), an INDEX (kind 47), a DEREF (kind 52), a FLOAT_LIT
 *   (kind 1), a BOOL_LIT (kind 2), a lane compare (kinds 14..19),
 *   or a kind-22 chain whose innermost expr is a FLOAT_LIT and which
 *   contains no kind 23. 0 means decline this if before any branch
 *   is emitted.
 * A unary of a VAR, a FIELD, an INDEX, a CALL, a METHOD, a lane
 * binop (kinds 4..13), an ARRAY_LIT, a block that still has lets,
 * or a DEREF is the whole chain. The fill passes it to the existing
 * vector let-init, which already applies kind 22 and kind 23 inside
 * out on every lane. A VAR or a FIELD needs a lane-0 home. An INDEX
 * does not: that let-init copies it with struct let-init, then applies
 * the chain. A CALL or a METHOD does not: that let-init srets a return
 * wider than 16 bytes, then applies the chain. A lane binop does not:
 * that let-init writes the binop into the slot, then applies the
 * chain. An ARRAY_LIT does not: that let-init writes the literal with
 * the lane-byte writer, then applies the chain. A block that still
 * has lets does not: that let-init emits the lets through the lane
 * chain, stores the value, then applies this chain. The block is not
 * made transparent. A DEREF does not: that let-init copies the target
 * with struct let-init, then applies the chain. The store is not
 * through the pointer. Kind 51 is excluded before the classifier
 * because it remaps 51 to add. A bare deref is not this unary walk.
 * It is that let-init's struct let-init copy of the target. The store
 * is not through the pointer. A deref under lets is that same copy
 * on the with-lets path.
 * A FLOAT_LIT is that let-init's existing f32 narrow-and-splat.
 * A kind-22 chain of a FLOAT_LIT is that same splat: an odd count
 * applies the sign once. A kind 23 in that chain stays declined.
 * A BOOL_LIT is that let-init's existing integer 0-or-1 splat.
 * An f32 lane keeps those integer bits. A unary of a bool stays
 * declined: that let-init does not splat it.
 * A lane compare (kinds 14..19, EQ through GE) is that let-init's
 * existing per-lane store of integer 0 or 1. Kind 51 is outside
 * that range. A unary of a compare stays declined.
 * A bare FIELD is copied like a VAR: lane 0 from
 * glue_vector_var_lane_stack_off_elf_c is the start of the vector.
 * A CALL, a METHOD, an INDEX, or a bare DEREF is that let-init's
 * struct let-init. Kind 51 is an address.
 * The lane-binop predicate remaps 51 to add, so it is excluded before
 * that call. Kind 24 does not enter.
 * The walk stops at 32 steps and sets the cursor kind to -1, because
 * kind 0 is INT_LIT. Depth 32 was not probed. PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function glue_vec_if_arm_take_c(
  arena: *u8, ctx: *u8, arm_ref: i32, esz: i32, ta: i32
): i32 {
  let cur: i32 = 0;
  let peeled: i32 = 0;
  let peel_n: i32 = 0;
  let ko: i32 = 0;
  let op_ref: i32 = 0;
  let op_k: i32 = 0;
  let inner_ref: i32 = 0;
  let deep: i32 = 0;
  let stop: i32 = 0;
  let step: i32 = 0;
  let go: i32 = 0;
  let src_off: i32 = 0;
  let is_null: i32 = 0;
  let saw_not: i32 = 0;
  if (arena == (0 as *u8) || ctx == (0 as *u8) || arm_ref <= 0) {
    return 0;
  }
  if (esz != 4) {
    return 0;
  }
  if (ta != 1) {
    return 0;
  }
  cur = arm_ref;
  peel_n = 0;
  while (peel_n < 4) {
    peeled = 0;
    unsafe {
      peeled = glue_expr_block_transparent_value_ref_at(arena, cur);
    }
    if (peeled <= 0) {
      peel_n = 4;
    } else {
      if (peeled == cur) {
        peel_n = 4;
      } else {
        cur = peeled;
        peel_n = peel_n + 1;
      }
    }
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, cur);
  }
  if (ko == 0) {
    unsafe {
      is_null = pipeline_expr_is_null_keyword_c(arena, cur);
    }
    if (is_null != 0) {
      return 0;
    }
    return cur;
  }
  // A BOOL_LIT is not an INT_LIT. true is 1 and false is 0. The fill
  // passes it to the existing vector let-init, which splats those
  // integer bits on every lane. An f32 lane keeps the integer bits.
  // A unary of a bool stays on the walk below and is declined.
  // PLATFORM: MACOS|ARM64.
  if (ko == 2) {
    return cur;
  }
  // A VAR or a FIELD already lives in one frame slot. Lane 0 of that
  // home is the start of the vector. The fill copies nbytes from
  // there. A missing home declines before any branch. Nested fields
  // are the existing home walk. Kind 51 is not kind 3 or kind 44.
  // PLATFORM: MACOS|ARM64.
  go = 0;
  if (ko == 3) {
    go = 1;
  }
  if (ko == 44) {
    go = 1;
  }
  if (go != 0) {
    src_off = 0;
    unsafe {
      src_off = glue_vector_var_lane_stack_off_elf_c(arena, ctx, cur, 0, esz, ta);
    }
    if (src_off < 0) {
      return 0;
    }
    return cur;
  }
  if (ko == 46) {
    return cur;
  }
  // Lane binop. The fill stores this arm with the existing vector
  // let-init. Kind 51 is an address; the classifier remaps it to add.
  // PLATFORM: MACOS|ARM64.
  if (ko != 51) {
    unsafe {
      go = glue_is_vector_lane_scalar_binop_ko(ko);
    }
  }
  if (go != 0) {
    return cur;
  }
  // A lane compare is not a lane binop. Kinds 14..19 are EQ through
  // GE. The fill passes this arm to the existing vector let-init,
  // which stores integer 0 or 1 on every lane. Kind 51 is outside
  // this range. A unary of a compare stays on the walk below and
  // is declined. PLATFORM: MACOS|ARM64.
  go = vlet_lane_cmp_ko(ko);
  if (go != 0) {
    return cur;
  }
  // A block that still has lets is not transparent. The fill stores
  // it with the existing vector let-init, which emits those lets
  // through the lane chain and then stores the value. Nested blocks
  // are that one call. 128 stops a chain that does not end.
  // PLATFORM: MACOS|ARM64.
  if (ko == 26) {
    return cur;
  }
  // A nested if or ternary is this same emitter. The fill passes the
  // arm to the existing vector let-init, which calls
  // glue_emit_vector_if_let_init_elf_c again. One recursion covers
  // every depth. PLATFORM: MACOS|ARM64.
  if (ko == 25) {
    return cur;
  }
  if (ko == 27) {
    return cur;
  }
  // A call or a method is not a VAR. The fill passes it to the
  // existing vector let-init, which stores it with the existing
  // struct let-init. That writer puts a return wider than 16 bytes
  // into this slot through sret. Kind 51 is not a call.
  // PLATFORM: MACOS|ARM64.
  if (ko == 48) {
    return cur;
  }
  if (ko == 49) {
    return cur;
  }
  // An index is not a call. The fill passes it to the existing
  // vector let-init, which stores it with the existing struct
  // let-init. That writer copies a value wider than 16 bytes into
  // this slot. Kind 51 is not an index. A unary of an index is
  // kind 22 or kind 23. The walk below returns that chain.
  // PLATFORM: MACOS|ARM64.
  if (ko == 47) {
    return cur;
  }
  // A deref is not an index. The fill passes it to the existing
  // vector let-init, which stores it with the existing struct
  // let-init. That writer copies the target into this slot. The
  // store is not through the pointer. Kind 51 is an address. A
  // unary of a deref is kind 22 or kind 23. The walk below returns
  // that chain. A deref under lets is the with-lets struct let-init
  // copy. The store is not through the pointer.
  // PLATFORM: MACOS|ARM64.
  if (ko == 52) {
    return cur;
  }
  // A FLOAT_LIT is not a deref. The fill passes it to the existing
  // vector let-init, which narrows the f64 bits and splats them on
  // an f32 lane. An i32 INT_LIT is kind 0 and stays on the arm above.
  // PLATFORM: MACOS|ARM64.
  if (ko == 1) {
    return cur;
  }
  if (ko == 22) {
    go = 1;
  }
  if (ko == 23) {
    go = 1;
  }
  if (go == 0) {
    return 0;
  }
  op_ref = cur;
  op_k = ko;
  deep = 0;
  stop = 0;
  while (stop == 0) {
    step = 0;
    if (op_k == 22) {
      step = 1;
    }
    if (op_k == 23) {
      step = 1;
      saw_not = 1;
    }
    if (step == 0) {
      stop = 1;
    } else {
      if (deep < 32) {
        inner_ref = 0;
        unsafe {
          inner_ref = pipeline_expr_unary_operand_ref_at(arena, op_ref);
        }
        if (inner_ref <= 0) {
          op_k = 0 - 1;
          stop = 1;
        } else {
          op_ref = inner_ref;
          deep = deep + 1;
          unsafe {
            op_k = pipeline_expr_kind_ord_at(arena, op_ref);
          }
        }
      } else {
        op_k = 0 - 1;
        stop = 1;
      }
    }
  }
  // Innermost VAR or FIELD: return the whole unary. The fill stores
  // it with the existing vector let-init, which loads each lane from
  // that home and applies this chain. Nested unaries are that one
  // walk, already capped at 32. A missing lane-0 home declines before
  // any branch. Kind 51 is not kind 3 or kind 44, so an address stays
  // out. PLATFORM: MACOS|ARM64.
  go = 0;
  if (op_k == 3) {
    go = 1;
  }
  if (op_k == 44) {
    go = 1;
  }
  if (go != 0) {
    src_off = 0;
    unsafe {
      src_off = glue_vector_var_lane_stack_off_elf_c(arena, ctx, op_ref, 0, esz, ta);
    }
    if (src_off < 0) {
      return 0;
    }
    return cur;
  }
  // Innermost INDEX: return the whole unary. The lane-home helper
  // does not address an index. The fill stores this chain with the
  // existing vector let-init, which copies the index through struct
  // let-init and applies the chain on every destination lane.
  // Nested unaries stay that one walk.
  // PLATFORM: MACOS|ARM64.
  if (op_k == 47) {
    return cur;
  }
  // Innermost CALL: return the whole unary. The lane-home helper
  // does not address a call. The fill stores this chain with the
  // existing vector let-init, which srets a return wider than 16
  // bytes into the slot and applies the chain on every lane.
  // Nested unaries stay that one walk.
  // PLATFORM: MACOS|ARM64.
  if (op_k == 48) {
    return cur;
  }
  // Innermost METHOD: return the whole unary. The lane-home helper
  // does not address a method. The fill stores this chain with the
  // existing vector let-init, which srets a return wider than 16
  // bytes into the slot and applies the chain on every lane.
  // Nested unaries stay that one walk.
  // PLATFORM: MACOS|ARM64.
  if (op_k == 49) {
    return cur;
  }
  // Innermost lane binop: return the whole unary. Kind 51 is an
  // address; the classifier remaps it to add, so it is excluded
  // before that call. The fill stores this chain with the existing
  // vector let-init, which writes the binop into the slot and applies
  // the chain on every lane. Nested unaries stay that one walk.
  // PLATFORM: MACOS|ARM64.
  go = 0;
  if (op_k != 51) {
    unsafe {
      go = glue_is_vector_lane_scalar_binop_ko(op_k);
    }
  }
  if (go != 0) {
    return cur;
  }
  // Innermost ARRAY_LIT: return the whole unary. The lane-home
  // helper does not address a literal. The fill stores this chain
  // with the existing vector let-init, which writes the literal with
  // the lane-byte writer and applies the chain on every lane. Nested
  // unaries stay that one walk.
  // PLATFORM: MACOS|ARM64.
  if (op_k == 46) {
    return cur;
  }
  // Innermost block: return the whole unary. A block that still has
  // lets is not transparent. The lane-home helper does not address
  // it. The fill stores this chain with the existing vector let-init,
  // which emits those lets through the lane chain, stores the value,
  // and applies this chain on every lane. Nested blocks are that one
  // call. 128 stops a chain that does not end. Nested unaries stay
  // this walk, capped at 32.
  // PLATFORM: MACOS|ARM64.
  if (op_k == 26) {
    return cur;
  }
  // Innermost DEREF: return the whole unary. The lane-home helper
  // does not address a deref. The fill stores this chain with the
  // existing vector let-init, which copies the target with struct
  // let-init and applies the chain on every lane. The store is not
  // through the pointer. Nested unaries stay this walk, capped at 32.
  // A bare deref is not this chain. PLATFORM: MACOS|ARM64.
  if (op_k == 52) {
    return cur;
  }
  // Innermost FLOAT_LIT under only kind 22. The fill passes this
  // chain to the existing vector let-init, which narrows the f64
  // bits and splats them. An odd count of minuses applies the sign
  // once. A kind 23 anywhere in the chain stays declined: that
  // let-init does not splat a bitwise not of an f32 literal.
  // Nested minuses stay this one walk, capped at 32.
  // PLATFORM: MACOS|ARM64.
  if (op_k == 1) {
    if (saw_not == 0) {
      return cur;
    }
  }
  if (op_k != 0) {
    return 0;
  }
  unsafe {
    is_null = pipeline_expr_is_null_keyword_c(arena, op_ref);
  }
  if (is_null != 0) {
    return 0;
  }
  return cur;
}

/**
 * Fill one accepted Vec8i if-arm into the let slot.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param arm_ref i32 — peeled arm from glue_vec_if_arm_take_c
 * @param ctx *u8 — AsmFuncCtx
 * @param ta i32 — 1 is arm64
 * @param stack_slot_off i32 — destination slot of lane 0. Not -3.
 * @param type_ref i32 — Vec8i type passed to the vector let-init
 * @param nbytes i32 - lane count times 4. Wider than 16 uses the
 *   large copy for a VAR. 16 bytes uses the retval pair for a VAR.
 * @return i32 — 0 when the slot holds every lane; -1 on encode failure
 * A VAR or a FIELD is copied with glue_vector_var_lane_stack_off_elf_c
 * and glue_copy_large_struct_from_rax_ptr_elf_c. Lane 0 is the start
 * of that vector. A literal chain, an ARRAY_LIT, a lane binop, a
 * block that still has lets, a nested if or ternary, a unary whose
 * innermost expr is a VAR, a FIELD, an INDEX, a CALL, a METHOD, a
 * lane binop (kinds 4..13), an ARRAY_LIT, a block that still has
 * lets, or a DEREF, or a bare INDEX, or a bare DEREF, call glue_emit_vector_type_let_init_elf_c.
 * That block is not made transparent.
 * That call is one extra frame, not a second splat. An f32 binop uses
 * that let-init's own fill, not an i32 splat. PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function glue_vec_if_arm_fill_c(
  arena: *u8, elf_ctx: *u8, arm_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32, nbytes: i32
): i32 {
  let ko: i32 = 0;
  let src_off: i32 = 0;
  let rc: i32 = 0;
  let go: i32 = 0;
  let modp: *u8 = 0 as *u8;
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, arm_ref);
  }
  // Same home and the same large copy for a VAR and a FIELD. Lane 0
  // is the start of the vector. Kind 51 is not either kind. Kind 52
  // stays off this copy and uses the vector let-init below.
  // PLATFORM: MACOS|ARM64.
  if (ko == 3) {
    go = 1;
  }
  if (ko == 44) {
    go = 1;
  }
  if (go != 0) {
    // 16 bytes is the retval pair. The large copy is for a payload
    // wider than 16. A VAR arm of that pair is emitted as a value
    // and stored with the existing pair store. An ARRAY_LIT arm is
    // not this kind.
    // PLATFORM: MACOS|ARM64.
    if (nbytes <= 16) {
      unsafe {
        rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, arm_ref, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        modp = glue_emit_module_from_ctx(ctx);
      }
      unsafe {
        rc = glue_store_retval_pair_to_rbp_elf_c(
          modp, arena, elf_ctx, type_ref, stack_slot_off, ta, arm_ref, ctx);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    unsafe {
      src_off = glue_vector_var_lane_stack_off_elf_c(arena, ctx, arm_ref, 0, 4, ta);
    }
    if (src_off < 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = glue_copy_large_struct_from_rax_ptr_elf_c(
        elf_ctx, stack_slot_off, nbytes, ta);
    }
    return rc;
  }
  unsafe {
    rc = glue_emit_vector_type_let_init_elf_c(
      arena, elf_ctx, arm_ref, ctx, ta, stack_slot_off, type_ref);
  }
  if (rc == 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Emit a Vec8i if or ternary into the let slot.
 * @param arena *u8 — AST arena; null returns -3
 * @param elf_ctx *u8 — object writer; null returns -3
 * @param init_ref i32 — EXPR_IF or EXPR_TERNARY
 * @param ctx *u8 — AsmFuncCtx; null returns -3
 * @param ta i32 — only 1 (Darwin arm64) enters
 * @param stack_slot_off i32 — destination slot. -3 returns -3
 * @param type_ref i32 — declared vector type
 * @return i32 — 0 when both arms filled the slot; -1 after a branch
 *   was emitted and a fill failed; -3 when this face declines and
 *   has emitted nothing
 * Both arms are required. Each arm is accepted only by
 * glue_vec_if_arm_take_c before the condition is emitted. A nested if
 * or ternary arm is this function again, through the vector let-init.
 * A unary of a VAR, a FIELD, an INDEX, a CALL, a METHOD, a lane
 * binop (kinds 4..13), an ARRAY_LIT, a block that still has lets,
 * or a DEREF is that let-init's existing per-lane chain. An INDEX is
 * copied first. A CALL or a METHOD is sret first. A lane binop is that
 * let-init's existing binop writer first. An ARRAY_LIT is that
 * let-init's existing lane-byte writer first. A block emits its lets
 * through the lane chain first. The block is not made transparent.
 * A DEREF copies the target with struct let-init first. The store is
 * not through the pointer. Then the chain runs. Kind 51 is excluded
 * before the classifier because it remaps 51 to add. A bare deref
 * is that same struct let-init copy, not that unary walk. The store
 * is not through the pointer. A deref under lets is that same copy.
 * A bare FIELD is the same large copy as a VAR.
 * A CALL, METHOD, or INDEX arm is that let-init's existing struct let-init.
 * The condition uses the existing bool-in-eax jump. A SIMD spelling wider
 * than 16 bytes enters, including named i32x8 and f32x8. The lane
 * count comes from glue_vector_type_lanes_esz_c. A vector of 16 bytes
 * or fewer is not the wide copy. emit_expr of a VAR leaves that
 * value in x0 and x1, and glue_store_retval_pair_to_rbp_elf_c
 * writes the slot. An ARRAY_LIT arm uses the existing lane writer.
 * A spelling the gate above rejects still returns -3. Kind 24 is
 * not a SIMD spelling and stays declined. PLATFORM: MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_vector_if_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32 {
  let simd: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  let rc: i32 = 0;
  let nbytes: i32 = 0;
  let ni: i32 = 0;
  let if_cond: i32 = 0;
  let if_then: i32 = 0;
  let if_else: i32 = 0;
  let then_arm: i32 = 0;
  let else_arm: i32 = 0;
  let else_lbl: u8[64] = [];
  let done_lbl: u8[64] = [];
  let else_len: i32 = 0;
  let done_len: i32 = 0;
  let modp: *u8 = 0 as *u8;
  let saw_arr: i32 = 0;
  let arm_ko: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)) {
    return 0 - 3;
  }
  if (init_ref <= 0) {
    return 0 - 3;
  }
  if (ta != 1) {
    return 0 - 3;
  }
  if (stack_slot_off == (0 - 3)) {
    return 0 - 3;
  }
  // Named i32x8 is kind 8, not TYPE_VECTOR 13. The spelling authority
  // already accepts it. A 16-byte spelling uses the frame pair below.
  // f32x8 is 32 bytes; a non-VAR arm is stored by the existing
  // let-init, which already fills f32 lanes. PLATFORM: MACOS|ARM64.
  unsafe {
    simd = asm_type_is_simd_vector_spelling(arena, type_ref);
  }
  if (simd == 0) {
    return 0 - 3;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
  }
  if (rc != 0) {
    return 0 - 3;
  }
  if (esz_s[0] != 4) {
    return 0 - 3;
  }
  if (lanes_s[0] <= 0) {
    return 0 - 3;
  }
  nbytes = 0;
  ni = 0;
  while (ni < lanes_s[0]) {
    nbytes = nbytes + esz_s[0];
    ni = ni + 1;
  }
  // 16 bytes is the frame pair. The wide copy is for a payload
  // wider than 16. emit_expr of a VAR leaves the value in x0 and
  // x1, and the existing pair store writes the slot. An ARRAY_LIT
  // arm leaves a temp address, not that pair. The existing lane
  // writer already stores a direct array literal of this type.
  // When either peeled arm is an ARRAY_LIT, use that writer and
  // keep the pair store for a VAR arm. Otherwise the whole if is
  // still one pair store. Nothing is emitted before the decision.
  // PLATFORM: MACOS|ARM64.
  if (nbytes <= 16) {
    unsafe {
      if_then = pipeline_expr_if_then_ref_at(arena, init_ref);
      if_else = pipeline_expr_if_else_ref_at(arena, init_ref);
    }
    then_arm = glue_vec_if_arm_take_c(arena, ctx, if_then, esz_s[0], ta);
    else_arm = glue_vec_if_arm_take_c(arena, ctx, if_else, esz_s[0], ta);
    arm_ko = 0;
    if (then_arm > 0) {
      unsafe {
        arm_ko = pipeline_expr_kind_ord_at(arena, then_arm);
      }
    }
    if (arm_ko == 46) {
      saw_arr = 1;
    }
    arm_ko = 0;
    if (else_arm > 0) {
      unsafe {
        arm_ko = pipeline_expr_kind_ord_at(arena, else_arm);
      }
    }
    if (arm_ko == 46) {
      saw_arr = 1;
    }
    if (saw_arr == 0) {
      unsafe {
        rc = pipeline_asm_emit_expr_elf_c(
          arena, elf_ctx, init_ref, ctx, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        modp = glue_emit_module_from_ctx(ctx);
      }
      unsafe {
        rc = glue_store_retval_pair_to_rbp_elf_c(
          modp, arena, elf_ctx, type_ref, stack_slot_off, ta, init_ref, ctx);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
  }
  unsafe {
    if_cond = pipeline_expr_if_cond_ref_at(arena, init_ref);
    if_then = pipeline_expr_if_then_ref_at(arena, init_ref);
    if_else = pipeline_expr_if_else_ref_at(arena, init_ref);
  }
  if (if_cond <= 0) {
    return 0 - 3;
  }
  if (if_then <= 0) {
    return 0 - 3;
  }
  if (if_else <= 0) {
    return 0 - 3;
  }
  then_arm = glue_vec_if_arm_take_c(arena, ctx, if_then, esz_s[0], ta);
  if (then_arm <= 0) {
    return 0 - 3;
  }
  else_arm = glue_vec_if_arm_take_c(arena, ctx, if_else, esz_s[0], ta);
  if (else_arm <= 0) {
    return 0 - 3;
  }
  unsafe {
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, if_cond, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    else_len = pipeline_asm_emit_next_label_c(ctx, &else_lbl[0], 64);
    done_len = pipeline_asm_emit_next_label_c(ctx, &done_lbl[0], 64);
  }
  if (else_len <= 0) {
    return 0 - 1;
  }
  if (done_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_enc_jz_after_bool_in_eax(elf_ctx, &else_lbl[0], else_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  rc = glue_vec_if_arm_fill_c(
    arena, elf_ctx, then_arm, ctx, ta, stack_slot_off, type_ref, nbytes);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_jmp_arch(elf_ctx, &done_lbl[0], done_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &else_lbl[0], else_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  rc = glue_vec_if_arm_fill_c(
    arena, elf_ctx, else_arm, ctx, ta, stack_slot_off, type_ref, nbytes);
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &done_lbl[0], done_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}
