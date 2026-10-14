// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Darwin body of glue_emit_vector_type_let_init_elf_c.
// Kind 46 calls the existing lane-byte writer. Kinds 4..13 (51 counts
// as add) call the existing per-lane binop writer. INT_LIT (0) and
// BOOL_LIT (2) call the existing lane-imm fill. EXPR_NEG (22) over an
// INT_LIT is the parser form of `-3`: negate that literal and splat
// with the same fill. Kind 22 or 23 whose operand is itself kind 22
// or 23 of a non-null INT_LIT folds both operators into that
// immediate and uses the same fill. `let v: i32x8 = ~(-3)` wrote 2
// into lane 0 and left lane 7. A nested unary of a VAR, a binop, a
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
// under the minus uses that same let-init: it already copies the
// indexed 16-byte value into the destination. A DEREF under the minus
// uses that same let-init: it already copies the 16-byte target into
// the destination, and the store is not through the pointer. A decline
// of that form stored neg of lane 0 only, so lane 1 of
// `let n = -id(a)` was 0, lane 1 of `let n = -arr[1]` was 0, and lane 1
// of `n = -*p` was 0. An ARRAY_LIT under the minus is
// stored by the existing lane-byte writer, then each destination lane
// is negated. Declining that left lane 0 of `let n = -[1, 2, 3, 4]`
// unequal to -1. A transparent EXPR_BLOCK (26), including `unsafe { e }`,
// is peeled with the existing helper before that classification.
// Declining the block stored neg of lane 0 for `let n = unsafe { -*p }`
// and left lane 0 of `let n = unsafe { [1, 2, 3, 4] }` unequal to 1.
// Bare VAR and bare DEREF still return -3 after the peel. An f32 lane
// (Vec4f / f32x4, or TYPE_VECTOR of F32) flips bit 31 with the existing
// mov of that bit into w1 and eor x0, x0, x1. neg w0 stays the i32
// path: it is two's complement, and integer negate of an f32 bit
// pattern is not an IEEE sign flip. A lane size other than 4, and a
// negative immediate with lane size 8, still return -3 (neg w0 is
// 32-bit; the fill zero-extends). f64 stays declined. EXPR_BITNOT
// (kind 23) of an i32 lane uses the same classification and emits
// mvn w0 per lane. f32 bitwise not stays declined. A scalar mvn w0
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
export extern function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function pipeline_asm_emit_vector_binop_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  let_ty_ref: i32, stack_slot_off: i32
): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_is_null_keyword_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(
  arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32
): i32;
export extern function glue_simd_emit_imm_fill_slot_c(
  elf_ctx: *u8, stack_slot_off: i32, lanes: i32, esz: i32, ta: i32, imm_bits: i32
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
export extern function backend_enc_lea_rbp_to_rbx_arch(
  elf_ctx: *u8, offset: i32, ta: i32
): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(
  elf_ctx: *u8, offset: i32, sz: i32, ta: i32
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
 * @return i32 — 0 when kind 46, a lane binop, a scalar lit, unary-minus
 *   of an integer lit, a VAR, a FIELD, a lane binop, a CALL, a METHOD,
 *   an INDEX, a DEREF, or an ARRAY_LIT is stored; -1 when that store fails;
 *   -3 when this face does not handle the expr
 * Kind 46 (ARRAY_LIT) calls pipeline_asm_emit_vector_let_init_elf_c.
 * Kinds 4..13 call pipeline_asm_emit_vector_binop_let_init_elf_c
 * (kind 51 is add). Kind 0 (INT_LIT) and kind 2 (BOOL_LIT) call
 * glue_simd_emit_imm_fill_slot_c. Kind 22 (EXPR_NEG) of an INT_LIT
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
 * at most four times. Kind 22 of an ARRAY_LIT (kind 46) stores that literal
 * with pipeline_asm_emit_vector_let_init_elf_c, then negates each
 * destination lane in place. Kind 23 (EXPR_BITNOT) uses that same
 * classification and emits mvn w0 on each i32 lane. f32 bitwise not
 * returns -3. An i32 immediate not is `-imm - 1` splatted by the
 * existing fill. Kind 22 or 23 of another kind 22 or 23 whose
 * operand is a non-null INT_LIT folds both operators into that
 * immediate and calls the same fill. Keyword null, an f32 element,
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
 * A lane binop, CALL, METHOD, INDEX, and DEREF stay declined past 16
 * bytes: those writers store 16 bytes.
 * Bare CALL and VAR copy stay declined.
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
  let peeled: i32 = 0;
  let peel_n: i32 = 0;
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
  // Bare VAR and bare DEREF still return -3 so the caller keeps those
  // copies. PLATFORM: MACOS|ARM64.
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
  // EXPR_NEG = 22 over an INT_LIT is the parser form of `-3`. Negate
  // that literal and splat with the same fill. A decline stores
  // zero-extended `neg w0` plus untouched x1, so lane 1 of i32x4 = -3
  // is 0. FLOAT_LIT stays declined.
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
    // Nested unary of a non-null INT_LIT. `~(-3)` and `-(~1)` are
    // kind 23 of kind 22, or kind 22 of kind 23. The operand is not
    // kind 0, so the arm below used to return -3 and the caller stored
    // one lane: lane 0 of `let v: i32x8 = ~(-3)` was 2 and lane 7 was
    // not. Fold the inner operator, then the outer one, and splat with
    // the existing fill. A VAR, a binop, CALL, METHOD, INDEX, DEREF,
    // or ARRAY_LIT under the inner unary is not kind 0 and stays on
    // that arm. Keyword null stays declined. f32 is not an i32 not.
    // Lane size other than 4 stays declined. ta other than 1 stays
    // declined. Two statements for each not: `~x` is `-x - 1`.
    // PLATFORM: MACOS|ARM64.
    nested_u = 0;
    if (op_ko == 22) {
      nested_u = 1;
    }
    if (op_ko == 23) {
      nested_u = 1;
    }
    if (nested_u != 0) {
      unsafe {
        inner_ref = pipeline_expr_unary_operand_ref_at(arena, lit_ref);
      }
      if (inner_ref > 0) {
        unsafe {
          inner_ko = pipeline_expr_kind_ord_at(arena, inner_ref);
        }
        if (inner_ko == 0) {
          unsafe {
            rc = pipeline_expr_is_null_keyword_c(arena, inner_ref);
          }
          if (rc == 0) {
            if (ta == 1) {
              unsafe {
                rc = glue_vector_elem_is_f32_c(arena, type_ref);
              }
              if (rc == 0) {
                unsafe {
                  imm = pipeline_expr_int_val_at(arena, inner_ref);
                  rc = glue_vector_type_lanes_esz_c(
                    arena, type_ref, &lanes_s[0], &esz_s[0]);
                }
                if (rc == 0) {
                  if (esz_s[0] == 4) {
                    if (lanes_s[0] > 0) {
                      if (op_ko == 22) {
                        imm = 0 - imm;
                      }
                      if (op_ko == 23) {
                        imm = 0 - imm;
                        imm = imm - 1;
                      }
                      if (lane_not != 0) {
                        imm = 0 - imm;
                        imm = imm - 1;
                      }
                      if (lane_not == 0) {
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
      // emits nothing. Bare CALL and DEREF stay declined. ta != 1
      // stays declined.
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
              return 0 - 3;
            }
          }
        }
      }
      unsafe {
        rc = glue_vector_elem_is_f32_c(arena, type_ref);
      }
      // Nonzero means Vec4f, the f32x4 spelling, or TYPE_VECTOR of F32.
      // Unary minus stays in this function and xors bit 31. Bitwise
      // not of an f32 lane is not that flip, so kind 23 returns -3.
      // esz other than 4 still returns -3 below. PLATFORM: MACOS|ARM64.
      if (lane_not != 0) {
        if (rc != 0) {
          return 0 - 3;
        }
      } else {
        if (rc != 0) {
          lane_f32 = 1;
        }
      }
      unsafe {
        rc = glue_vector_type_lanes_esz_c(arena, type_ref, &lanes_s[0], &esz_s[0]);
      }
      // Lane size other than 4 stays declined: neg w0 is 32-bit.
      // CALL, METHOD, INDEX, and DEREF (from_dest 2) still store 16
      // bytes, so a wider vector would negate lanes past that store.
      // A lane binop (from_dest 1) uses the existing binop let-init.
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
      if ((lanes_s[0] * esz_s[0]) > 16) {
        if (from_dest == 2) {
          return 0 - 3;
        }
      }
      if (from_dest == 1) {
        unsafe {
          rc = pipeline_asm_emit_vector_binop_let_init_elf_c(
            arena, elf_ctx, lit_ref, ctx, ta, stack_slot_off, type_ref);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      } else {
        if (from_dest == 2) {
          // CALL and METHOD set the expected return type, emit, and
          // store both halves. INDEX and DEREF use the same let-init:
          // lvalue address, 16-byte load, then the pair store into the
          // destination slot. A hand-rolled emit keeps 8 bytes. This
          // does not assign through the pointer. Non-zero may already
          // have emitted, so do not fall through to scalar neg.
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
        if (lane_f32 != 0) {
          // Load already left the lane in x0 (LDR w0, zero-extended).
          // MOVZ/MOVK w1 of the sign bit, then eor x0, x0, x1.
          // lea below clobbers x1, so the eor stays before that lea.
          // PLATFORM: MACOS|ARM64.
          unsafe {
            rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, sign_bit, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_xor_rbx_rax_arch(elf_ctx, ta);
          }
        } else {
          if (lane_not != 0) {
            // mvn w0, w0. The 4-byte load is LDR w0, so only this
            // lane's bits flip. neg w0 stays unary minus.
            // PLATFORM: MACOS|ARM64.
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
    unsafe {
      rc = glue_simd_emit_imm_fill_slot_c(
        elf_ctx, stack_slot_off, lanes_s[0], esz_s[0], ta, imm);
    }
    return rc;
  }
  return 0 - 3;
}
