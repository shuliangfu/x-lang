// One strong pipeline_asm_emit_vector_let_init_elf_c.
// Body is seeds/vector_let_init_nested_override.c.
// The mangled Cap residual name and the Darwin stubdead name are the
// same body, but each is its own object: same-.o dual T smashes i32.
// runtime_pipeline_abi.x only export-externs this short name. Do not
// fold this TU into the egg. Do not gcc the seed on Windows, Linux,
// or Darwin. PLATFORM: SHARED body.
// Linux, Darwin, and Windows relinks consume this object.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, ai: i32): i32;
export extern function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32,
  leaf_esz: i32, flat_i: *i32
): i32;
export extern function glue_array_lit_emit_scalar_elem_to_rax_elf_c(
  arena: *u8, elf_ctx: *u8, lit: i32, elem: i32, ctx: *u8, ta: i32, esz: i32
): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(
  elf_ctx: *u8, off: i32, sz: i32, ta: i32
): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit_expr_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32
): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_struct_lit_fields_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;
export extern function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function pipeline_lane_operand_emit_let_block_chain(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, budget: i32
): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(
  arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32
): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_emit_slice_from_array_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32,
  let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32
): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_module_func_body_ref_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_named_name_into(
  arena: *u8, type_ref: i32, out: *u8
): i32;
export extern function vector_let_init_array_lit_a64_vlet_f32_fill_lane(
  arena: *u8, type_ref: i32
): i32;
export extern function glue_i32_to_f32_bits(v: i32): i32;
export extern function glue_simd_emit_imm_fill_slot_c(
  elf_ctx: *u8, stack_slot_off: i32, lanes: i32, esz: i32, ta: i32, imm_bits: i32
): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;

/**
 * Splat an integer literal into one wide i32 vector array element.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param elf_ctx *u8 — object writer; caller already rejected null
 * @param elem_ref i32 — element expr; kind 0, 22, 23, or a lane binop
 * @param ctx *u8 — AsmFuncCtx; caller already rejected null
 * @param ta i32 — target arch, forwarded to the vector let-init
 * @param home i32 — frame slot of this element; caller already rejected < 0
 * @param elem_ty i32 — element type ref; <= 0 returns 1
 * @param stride i32 — array element stride in bytes; below 16 returns 1
 * @return i32 — 0 when the vector let-init filled the slot, -1 when that
 *   fill reports an encoder failure, 1 when this element stays on the
 *   scalar store
 * The scalar store writes 4 bytes. An i32x8 element is 32 bytes, so
 * lane 7 stayed 0. glue_emit_vector_type_let_init_elf_c already splats
 * an INT_LIT and a kind 22 / 23 chain of one, and already stores a
 * lane binop (kinds 4..13 and 51) into that same slot. Lane size must
 * be 4. A width below 16 stays on the scalar store. Exactly 16 is
 * i32x4: `let v: i32x4 = 3` already fills lane 3 through that let-init,
 * and the 4-byte store left `a[0][3]` at 0. glue_vector_elem_is_f32_c declines Vec4f, f32x4,
 * and a TYPE_VECTOR of f32. It does not list the f32x8 spelling. A
 * named type whose first byte is 'f' (ASCII 102) also returns 1, so
 * an f32 spelling never takes this integer splat. f32x8 literals are
 * filled by vlet_f32_elem_lit before this helper runs. Any other
 * let-init result returns 1 and emits nothing from this helper.
 * Kind 24 does not call this helper.
 * PLATFORM: SHARED. The lane loop stays in the existing let-init.
 */
function vlet_wide_i32_splat(
  arena: *u8, elf_ctx: *u8, elem_ref: i32, ctx: *u8, ta: i32,
  home: i32, elem_ty: i32, stride: i32
): i32 {
  let rc: i32 = 0;
  let tk: i32 = 0;
  let nlen: i32 = 0;
  let lanes: i32 = 0;
  let lesz: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  let sn: u8[64] = [];
  // Below 16 bytes is still a scalar or a narrower vector. Exactly
  // 16 is i32x4. The let-init already fills that width; the scalar
  // store below this helper writes 4 bytes and leaves lane 3 at 0.
  // PLATFORM: SHARED.
  if (elem_ty <= 0 || stride < 16) {
    return 1;
  }
  unsafe {
    rc = glue_vector_elem_is_f32_c(arena, elem_ty);
  }
  if (rc != 0) {
    return 1;
  }
  // f32x8 is a named vector and is not in glue_vector_elem_is_f32_c.
  // That helper only lists f32x4 and Vec4f. A leading 'f' keeps the
  // one-word store. PLATFORM: SHARED.
  unsafe {
    tk = pipeline_type_kind_ord_at(arena, elem_ty);
  }
  if (tk == 8) {
    unsafe {
      nlen = pipeline_type_named_name_into(arena, elem_ty, &sn[0]);
    }
    if (nlen > 0) {
      if (sn[0] == 102) {
        return 1;
      }
    }
  }
  unsafe {
    rc = asm_type_is_simd_vector_spelling(arena, elem_ty);
  }
  if (rc == 0) {
    return 1;
  }
  unsafe {
    rc = glue_vector_type_lanes_esz_c(arena, elem_ty, &lanes_s[0], &esz_s[0]);
  }
  if (rc != 0) {
    return 1;
  }
  lanes = lanes_s[0];
  lesz = esz_s[0];
  if (lesz != 4 || lanes <= 0) {
    return 1;
  }
  // Same width rule as the stride check. i32x4 is 16. A wider
  // integer vector (i32x8 is 32) already took this let-init.
  // PLATFORM: SHARED.
  if ((lanes * lesz) < 16) {
    return 1;
  }
  unsafe {
    rc = glue_emit_vector_type_let_init_elf_c(
      arena, elf_ctx, elem_ref, ctx, ta, home, elem_ty);
  }
  if (rc == 0) {
    return 0;
  }
  if (rc == (0 - 1)) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Splat one f32 literal into a wide f32 array element.
 * @param arena *u8 — AST arena; null returns 1
 * @param elf_ctx *u8 — object writer; null returns 1
 * @param elem_ref i32 — element expr; not positive returns 1
 * @param ctx *u8 — AsmFuncCtx; forwarded to the float let-init
 * @param ta i32 — target arch; a value other than 1 returns 1
 * @param home i32 — frame slot of this element; below 0 returns 1
 * @param elem_ty i32 — element type; not an f32 fill target returns 1
 * @return i32 — 0 when every lane is filled, -1 when the fill reports
 *   an encoder failure, 1 when this element stays on the later path
 * vector_let_init_array_lit_a64_vlet_f32_fill_lane is the live f32x8
 * check. The linked glue_vector_elem_is_f32_c still misses that
 * spelling, and vlet_wide_i32_splat declines a leading 'f' so an
 * integer splat cannot write i32 bits into an f32 lane. Kind 1
 * (FLOAT_LIT), and a chain of only kind 22 that ends at kind 1, call
 * glue_emit_vector_type_let_init_elf_c on the original element. That
 * let-init already folds the minuses and fills f32x8. Kinds 4..13 are
 * that same call on the original element. The fill helper already
 * accepted the type, so this covers f32x8, f32x4, and Vec4f. Requiring
 * the classifier to return 0 left f32x4 and Vec4f on the 4-byte store,
 * and lane 3 was not the sum. Kind 51 is an address and does not enter.
 * A kind-22 chain in front of the binop stays on the original element,
 * and the let-init folds those minuses. Kind 0
 * (INT_LIT), and a chain of only kind 22 that ends at kind 0, converts
 * with glue_i32_to_f32_bits and fills through
 * glue_simd_emit_imm_fill_slot_c. The integer arm of the vector
 * let-init writes i32 bits, so kind 0 does not call it. An odd count
 * of kind 22 negates the integer before the conversion. Kind 23
 * anywhere in the chain returns 1. The walk is at most 32 steps. One
 * more returns 1. A lane size other than 4 returns 1. i32x4 and i32x8
 * fail the f32 check and stay on vlet_wide_i32_splat.
 * PLATFORM: SHARED.
 */
function vlet_f32_elem_lit(
  arena: *u8, elf_ctx: *u8, elem_ref: i32, ctx: *u8, ta: i32,
  home: i32, elem_ty: i32
): i32 {
  let is_f: i32 = 0;
  let ek: i32 = 0;
  let cur: i32 = 0;
  let step: i32 = 0;
  let n: i32 = 0;
  let stop: i32 = 0;
  let neg: i32 = 0;
  let imm: i32 = 0;
  let bits: i32 = 0;
  let rc: i32 = 0;
  let lanes: i32 = 0;
  let lesz: i32 = 0;
  let lanes_s: i32[1] = [];
  let esz_s: i32[1] = [];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || elem_ref <= 0) {
    return 1;
  }
  if (elem_ty <= 0 || home < 0 || ta != 1) {
    return 1;
  }
  unsafe {
    is_f = vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena, elem_ty);
  }
  if (is_f == 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, elem_ref);
  }
  // Kind 22 is unary minus. Kind 23 is bitwise not and stays off this
  // fill. The counter advances on every minus, and cur moves to the
  // operand, so the loop is not a hollow zero. Thirty-two steps match
  // the vector let-init walk. The next step returns 1.
  // PLATFORM: SHARED.
  cur = elem_ref;
  n = 0;
  stop = 0;
  neg = 0;
  while (stop == 0) {
    if (n < 32) {
      if (ek == 23) {
        return 1;
      } else {
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
            return 1;
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
      return 1;
    }
  }
  // Kinds 4..13 are a lane binop. This function already returned
  // when the f32 fill helper is 0, so the type is f32x8, f32x4, or
  // Vec4f. The classifier is 0 only for f32x8. Requiring that left
  // f32x4 and Vec4f on the 4-byte store, so lane 3 of
  // `[{ let k; k + k }]` was not the sum. The float-literal arm
  // below already calls the vector let-init. This is that same
  // call. The original element keeps a leading kind-22 chain, which
  // that let-init folds. Kind 51 is an address and stays off.
  // PLATFORM: SHARED.
  if (ek != 51) {
    unsafe {
      rc = glue_is_vector_lane_scalar_binop_ko(ek);
    }
    if (rc != 0) {
      unsafe {
        rc = glue_emit_vector_type_let_init_elf_c(
          arena, elf_ctx, elem_ref, ctx, ta, home, elem_ty);
      }
      if (rc == 0) {
        return 0;
      }
      if (rc == (0 - 1)) {
        return 0 - 1;
      }
      return 1;
    }
  }
  if (ek == 1) {
    unsafe {
      rc = glue_emit_vector_type_let_init_elf_c(
        arena, elf_ctx, elem_ref, ctx, ta, home, elem_ty);
    }
    if (rc == 0) {
      return 0;
    }
    if (rc == (0 - 1)) {
      return 0 - 1;
    }
    return 1;
  }
  if (ek != 0) {
    return 1;
  }
  unsafe {
    imm = pipeline_expr_int_val_at(arena, cur);
  }
  if (neg != 0) {
    imm = 0 - imm;
  }
  unsafe {
    bits = glue_i32_to_f32_bits(imm);
    rc = glue_vector_type_lanes_esz_c(arena, elem_ty, &lanes_s[0], &esz_s[0]);
  }
  if (rc != 0) {
    return 1;
  }
  lanes = lanes_s[0];
  lesz = esz_s[0];
  if (lesz != 4 || lanes <= 0) {
    return 1;
  }
  unsafe {
    rc = glue_simd_emit_imm_fill_slot_c(elf_ctx, home, lanes, lesz, ta, bits);
  }
  if (rc == 0) {
    return 0;
  }
  if (rc == (0 - 1)) {
    return 0 - 1;
  }
  return 1;
}

/**
 * Store one element whose size is not 1, 2, 4, or 8 bytes.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param elf_ctx *u8 — object writer; caller already rejected null
 * @param elem_ref i32 — element expr ref; caller already skipped 0
 * @param ctx *u8 — AsmFuncCtx; caller already rejected null
 * @param ta i32 — 0 x86, 1 arm64; any other value returns 1 with no calls
 * @param stack_slot_off i32 — array base slot; lea uses this, not home
 * @param esz i32 — element stride in bytes
 * @param ai i32 — element index; arm64 home is base+ai*esz, x86 home is base-ai*esz
 * @param elem_ty i32 — element type ref; 0 when the caller did not load one
 * @return i32 — 0 stored, 1 not handled here, -1 error
 * STRUCT_LIT (kind 45) writes fields at home. Other kinds try struct
 * let-init at home. An f32 literal, a kind 22 chain of one, or an
 * f32 lane binop (f32x8, f32x4, or Vec4f; kinds 4..13, not kind 51)
 * then uses vlet_f32_elem_lit. An INT_LIT, a kind 22 / 23 chain, or a lane
 * binop of a wide i32 vector then uses vlet_wide_i32_splat. The binop
 * is kinds 4..13 and 51. A 4-byte scalar store left lane 0 of `a + b`
 * as the sum and lane 7 unset. When that also declines, VAR, FIELD,
 * and INDEX (kinds 3, 44, 47) copy esz bytes from the element's
 * address. The copy lea uses stack_slot_off, then adds ai*esz only
 * when ai > 0.
 * A block (kind 26) is none of those. A transparent `{ a + a }` and
 * a block that still has lets both used to reach the 4-byte store,
 * so lane 7 of `[{ let k; k + k }]` was not the sum.
 * pipeline_lane_operand_emit_let_block_chain emits each block's lets
 * and returns the value expr. Nested blocks are that one call. The
 * arms below then store that value. Kind 51 stays out of the binop
 * splat. 128 stops only a chain that does not end. Width 8 or less
 * is not peeled.
 * An if (kind 25) or a ternary (kind 27) is none of the splat or
 * copy arms. Struct let-init stores those only when the destination
 * is rbx (slot -3). A frame home returns -2 and emits nothing, so
 * the 4-byte store dropped _main for
 * `[if (c) { a } else { a + a }, a]`. The existing vector let-init
 * stores that if into home, including a nested if, a unary of a var,
 * and a call arm. A result other than 0 or -1, including -3 before
 * any store when the type is not a wide SIMD spelling, keeps the
 * later splat and the scalar store. Kind 51 is not an if. Kind 52
 * stays off this call.
 * PLATFORM: SHARED. The if store is the existing vector let-init,
 * which declines when ta is not arm64.
 */
function pabi_vector_let_init_nested_one_vlet_wide_elem(
  arena: *u8, elf_ctx: *u8, elem_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, esz: i32, ai: i32, elem_ty: i32
): i32 {
  let home: i32 = 0;
  let ek: i32 = 0;
  let st: i32 = 0;
  let rc: i32 = 0;
  let lane_bin: i32 = 0;
  let if_ek: i32 = 0;
  if (ta != 0 && ta != 1) {
    return 1;
  }
  if (ta == 1) {
    home = stack_slot_off + ai * esz;
  } else {
    home = stack_slot_off - ai * esz;
  }
  if (home < 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, elem_ref);
    lane_bin = glue_is_vector_lane_scalar_binop_ko(ek);
  }
  // Kind 26 is a block. Struct let-init returns -2 for it, and the
  // caller then stores 4 bytes, so lane 7 of
  // `[{ let k; k + k }]` and of `[{ a + a }]` is not the sum. The
  // existing lane chain emits each block's lets and returns the
  // value expr. Nested blocks are that one function. The arms below
  // store that value. Kind 51 is an address, so it stays off the
  // binop splat. Width 8 or less is not peeled. 128 stops only a
  // chain that does not end. PLATFORM: SHARED.
  if (ek == 26) {
    if (esz > 8) {
      unsafe {
        rc = pipeline_lane_operand_emit_let_block_chain(
          arena, elf_ctx, elem_ref, ctx, ta, 128);
      }
      if (rc <= 0) {
        return 0 - 1;
      }
      if (rc == elem_ref) {
        return 0 - 1;
      }
      elem_ref = rc;
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, elem_ref);
        lane_bin = glue_is_vector_lane_scalar_binop_ko(ek);
      }
      if (ek == 51) {
        lane_bin = 0;
      }
      if (ek == 26) {
        return 0 - 1;
      }
    }
  }
  if (ek == 45) {
    unsafe {
      st = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, elem_ref, ctx, ta, home);
    }
    if (st != 0) {
      return 0 - 1;
    }
    return 0;
  }
  unsafe {
    st = glue_emit_struct_type_let_init_elf_c(
      arena, elf_ctx, elem_ref, ctx, ta, elem_ty, home);
  }
  if (st == 0) {
    return 0;
  }
  if (st == (0 - 1)) {
    return 0 - 1;
  }
  // Kind 25 is IF. Kind 27 is TERNARY. Two tests, no boolean join.
  // Struct let-init just returned something other than 0 or -1, and
  // for a frame home that is -2 with no bytes emitted. The existing
  // vector let-init stores a wide SIMD if into home. 0 is stored.
  // -1 means the condition or an arm was already emitted and failed,
  // so the caller must not also scalar-store. Any other code,
  // including -3 before a store, falls through. Kind 49 is not here.
  // Kind 51 is not an if. Kind 52 stays off this call.
  // PLATFORM: SHARED.
  if (ek == 25) {
    if_ek = 1;
  }
  if (ek == 27) {
    if_ek = 1;
  }
  if (if_ek != 0) {
    unsafe {
      st = glue_emit_vector_type_let_init_elf_c(
        arena, elf_ctx, elem_ref, ctx, ta, home, elem_ty);
    }
    if (st == 0) {
      return 0;
    }
    if (st == (0 - 1)) {
      return 0 - 1;
    }
  }
  // f32x8 [1, -1] and [1.0, -1.0] used to fall through to one 4-byte
  // store. The integer splat declines a leading 'f', and a float
  // literal never entered it. vlet_f32_elem_lit fills those lanes.
  // Return 1 keeps the integer splat and the scalar store.
  // PLATFORM: SHARED.
  st = vlet_f32_elem_lit(
    arena, elf_ctx, elem_ref, ctx, ta, home, elem_ty);
  if (st != 1) {
    return st;
  }
  // Kind 0 is INT_LIT. Kinds 22 and 23 are the unary chain. lane_bin
  // is a lane binop (kinds 4..13 and 51). The scalar store below
  // writes one word at a stride of esz, so lane 7 of an i32x8 element
  // stayed 0. `-(a + b)` already reached the vector let-init through
  // the unary arm. A bare `a + b` did not, so lane 0 was the sum and
  // lane 7 stayed unset. A decline (return 1) keeps that store.
  // PLATFORM: SHARED.
  if (ek == 0 || ek == 22 || ek == 23 || lane_bin != 0) {
    st = vlet_wide_i32_splat(
      arena, elf_ctx, elem_ref, ctx, ta, home, elem_ty, esz);
    if (st != 1) {
      return st;
    }
  }
  if (ek != 3 && ek != 44 && ek != 47) {
    return 1;
  }
  unsafe {
    rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
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
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // ai == 0 does not call add. The C && short-circuit is the same.
  if (ai > 0) {
    unsafe {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
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
    rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, esz, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Return 1 when any element is itself an ARRAY_LIT.
 * @param arena *u8 — AST arena
 * @param init_ref i32 — outer ARRAY_LIT expr ref
 * @param n_arr i32 — element count; caller already checked 1..16777216
 * @return i32 — 1 if some element kind is 46, else 0
 * Stops at the first nested row, matching the C break. An element ref
 * that is not positive does not call kind.
 * PLATFORM: SHARED.
 */
function vlet_has_nested(arena: *u8, init_ref: i32, n_arr: i32): i32 {
  let ai: i32 = 0;
  let elem_ref: i32 = 0;
  let ek: i32 = 0;
  while (ai < n_arr) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    }
    if (elem_ref > 0) {
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, elem_ref);
      }
      if (ek == 46) {
        return 1;
      }
    }
    ai = ai + 1;
  }
  return 0;
}

/**
 * Emit one scalar element into the slot after a declined wide store.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param init_ref i32 — outer ARRAY_LIT expr ref
 * @param elem_ref i32 — element expr ref; not zero
 * @param ctx *u8 — AsmFuncCtx
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — array base slot
 * @param esz i32 — element stride passed to the scalar emitter
 * @param ai i32 — element index; store offset is ai*esz
 * @param store_sz i32 — 1, 2, 4, or 8; may differ from esz
 * @return i32 — 0 stored, -1 when any encode or the scalar emit fails
 * may_clobber is sampled before the scalar emit and applied after it.
 * PLATFORM: SHARED.
 */
function vlet_scalar_one(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ref: i32, ctx: *u8,
  ta: i32, stack_slot_off: i32, esz: i32, ai: i32, store_sz: i32
): i32 {
  let may_clobber: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
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
    may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
  }
  unsafe {
    rc = glue_array_lit_emit_scalar_elem_to_rax_elf_c(
      arena, elf_ctx, init_ref, elem_ref, ctx, ta, esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (may_clobber != 0) {
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
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
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, store_sz, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * ARRAY_LIT into a stack slot. Nested rows flatten. A flat row stores
 * one element at a time.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — object writer; null returns -1
 * @param init_ref i32 — expr ref; not positive, or not kind 46, returns -1
 * @param ctx *u8 — AsmFuncCtx; null returns -1
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of element 0
 * @return i32 — 0 when every element is stored, -1 on a hard failure
 * Count must be in 1..16777216. A nested element uses the leaf stride
 * (default 4) and array_lit_flat. Otherwise the element stride
 * (default 4) is clamped to a store width of 1, 2, 4, or 8. A wider
 * element tries pabi_vector_let_init_nested_one_vlet_wide_elem first. Element ref 0 is skipped.
 * PLATFORM: SHARED.
 */
function vlet_nested_body(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  let n_arr: i32 = 0;
  let esz: i32 = 0;
  let store_sz: i32 = 0;
  let ai: i32 = 0;
  let elem_ref: i32 = 0;
  let has_nested: i32 = 0;
  let flat_i: i32 = 0;
  let elem_ty: i32 = 0;
  let wide: i32 = 0;
  let rc: i32 = 0;
  let ek: i32 = 0;
  let body_br: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let fi: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (ek != 46) {
    return 0 - 1;
  }
  unsafe {
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  /* `*p = [1025]i64` fills this slot one element at a time. 1024
   * used to return -1. The byte ceiling stays in the rbx copy.
   * PLATFORM: SHARED. Mac product mov w0, #16777216 at file 0xf225c. */
  if (n_arr <= 0 || n_arr > 16777216) {
    return 0 - 1;
  }
  has_nested = vlet_has_nested(arena, init_ref, n_arr);
  if (has_nested != 0) {
    unsafe {
      esz = pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena, init_ref);
    }
    if (esz <= 0) {
      esz = 4;
    }
    flat_i = 0;
    unsafe {
      rc = pipeline_asm_emit_array_lit_flat_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, esz, &flat_i);
    }
    return rc;
  }
  unsafe {
    esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, init_ref);
  }
  if (esz <= 0) {
    esz = 4;
  }
  // `[a]` where the cell is `[]i32` and `a` is `[2]i32`. The cell
  // stride is 16. emit_expr loads `a` as a fat slice, so the length
  // becomes the next local (0x200000001) and ss[0].length != 2.
  // The slice writer recovers N from the function-body const.
  // PLATFORM: SHARED.
  if (esz == 16) {
    unsafe {
      elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
    }
    if (elem_ty > 0) {
      unsafe {
        ek = pipeline_type_kind_ord_at(arena, elem_ty);
      }
    }
    if (ek == 11) {
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
        fi = pipeline_asm_emit_func_index_c();
      }
      if (mod != (0 as *u8) && fi >= 0) {
        unsafe {
          body_br = pipeline_module_func_body_ref_at(mod, fi);
        }
      }
      if (body_br < 0) {
        body_br = 0;
      }
      ai = 0;
      while (ai < n_arr) {
        unsafe {
          elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
        }
        if (elem_ref > 0) {
          if (ta == 1) {
            rc = stack_slot_off + ai * esz;
          } else {
            rc = stack_slot_off - ai * esz;
          }
          if (rc < 0) {
            return 0 - 1;
          }
          unsafe {
            wide = glue_emit_slice_from_array_let_init_elf_c(
              arena, elf_ctx, body_br, 0, elem_ref, elem_ty, ctx, ta, rc);
          }
          if (wide < 0) {
            return 0 - 1;
          }
          if (wide != 1) {
            return 0 - 1;
          }
        }
        ai = ai + 1;
      }
      return 0;
    }
  }
  store_sz = esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8) {
    store_sz = 4;
  }
  elem_ty = 0;
  if (store_sz != esz) {
    unsafe {
      elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
    }
  }
  while (ai < n_arr) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    }
    if (elem_ref != 0) {
      if (store_sz != esz) {
        wide = pabi_vector_let_init_nested_one_vlet_wide_elem(
          arena, elf_ctx, elem_ref, ctx, ta, stack_slot_off, esz, ai, elem_ty);
        if (wide < 0) {
          return 0 - 1;
        }
        if (wide != 0) {
          rc = vlet_scalar_one(
            arena, elf_ctx, init_ref, elem_ref, ctx, ta, stack_slot_off, esz, ai, store_sz);
          if (rc != 0) {
            return 0 - 1;
          }
        }
      } else {
        rc = vlet_scalar_one(
          arena, elf_ctx, init_ref, elem_ref, ctx, ta, stack_slot_off, esz, ai, store_sz);
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
    ai = ai + 1;
  }
  return 0;
}

/**
 * Short name. Thin callers and the egg call this.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — object writer; null returns -1
 * @param init_ref i32 — ARRAY_LIT expr ref; not positive returns -1
 * @param ctx *u8 — AsmFuncCtx; null returns -1
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of element 0
 * @return i32 — 0 stored, -1 hard failure or not an ARRAY_LIT
 * The mangled name and stubdead live in their own objects and call
 * this symbol. They are not defined here.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  return vlet_nested_body(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}
