// Thin overlay of pipeline_asm_emit_addr_of_elf_c.
// The frozen pabi body handles VAR, INDEX, FIELD, DEREF, and ARRAY_LIT.
// A CALL or METHOD operand is not spilled here. The lvalue emitter
// already stores a 1..8 byte integer, a 9..16 byte named struct, a
// wider named-struct address left in x0 by the x8 wrapper, and an f32
// word harvested from s0. This overlay forwards that operand.
// An f64 result is harvested from d0 by that function. A 16-byte
// i32, f32, or u32 vector, including a 16-byte f32 TYPE_VECTOR, is
// stored from x0 and x1 by that function.
// A named SIMD wider than 16 bytes is that same x8 address.
// A kind-13 vector wider than 16 stays its failure. A second spill here
// would be a second authority for the same address.
// A lane binop (kinds 4..13), a unary minus (kind 22), a bitwise
// not (kind 23), and a lane compare (kinds 14..19) are not calls
// and are not in x0:x1. On arm64 this overlay stores each with the
// existing vector let-init and leaves that temp address in x0.
// The compare predicate is vlet_lane_cmp_ko. Kind 51 is the
// classifier's remap and stays -99. A kind-13 vector stays -99.
// Kind 24 stays -99.
// Linked before pabi_weak. That copy of this symbol is weakened.
// PLATFORM: MACOS|DARWIN link. The forward runs only for ta == 1.
// x86_64 keeps the old -99 for a call operand, a lane binop, a
// unary minus, a bitwise not, and a lane compare.

export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, er: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, er: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx: *u8, m: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(
  arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32
): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_array_lit_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function vlet_lane_cmp_ko(ko: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_off: i32, type_ref: i32): i32;

/**
 * Type of the arm64 temp for an address-of lane value.
 * A lane binop, a unary minus, or a bitwise not already carries
 * the named SIMD type on the operand. A lane compare is stamped
 * bool, and the lane store uses the left operand's type, the same
 * type a vector let passes to let-init. Kind 51 and a kind-13
 * vector return 0. Kind 24 returns 0.
 * @param arena *u8 - AST arena
 * @param op i32 - ADDR_OF operand; values <= 0 return 0
 * @return i32 - named SIMD type ref, or 0 when this operand
 *   allocates no temp
 * PLATFORM: SHARED. The caller allocates only for ta == 1.
 */
#[no_mangle]
export function glue_addr_simd_lane_type_c(arena: *u8, op: i32): i32 {
  let opk: i32 = 0;
  let lane: i32 = 0;
  let cmp: i32 = 0;
  let vty: i32 = 0;
  let vtk: i32 = 0;
  let spell: i32 = 0;
  let left: i32 = 0;
  if (op <= 0) {
    return 0;
  }
  unsafe {
    opk = pipeline_expr_kind_ord_at(arena, op);
  }
  if (opk == 51) {
    return 0;
  }
  if (opk == 22) {
    lane = 1;
  }
  if (opk == 23) {
    lane = 1;
  }
  if (lane == 0) {
    unsafe {
      lane = vlet_lane_cmp_ko(opk);
    }
    if (lane != 0) {
      cmp = 1;
    }
  }
  if (lane == 0) {
    unsafe {
      lane = glue_is_vector_lane_scalar_binop_ko(opk);
    }
  }
  if (lane == 0) {
    return 0;
  }
  unsafe {
    vty = pipeline_expr_resolved_type_ref(arena, op);
  }
  if (vty > 0) {
    unsafe {
      vtk = pipeline_type_kind_ord_at(arena, vty);
    }
  }
  // Bool stamp on a lane compare. The vector type is the left
  // operand. A binop, a unary minus, or a bitwise not keeps its
  // own type.
  if (vtk != 8) {
    if (cmp != 0) {
      unsafe {
        left = pipeline_expr_binop_left_ref_at(arena, op);
      }
      if (left > 0) {
        unsafe {
          vty = pipeline_expr_resolved_type_ref(arena, left);
        }
        if (vty > 0) {
          unsafe {
            vtk = pipeline_type_kind_ord_at(arena, vty);
          }
        }
      }
    }
  }
  if (vtk != 8) {
    return 0;
  }
  unsafe {
    spell = asm_type_is_simd_vector_spelling(arena, vty);
  }
  if (spell == 0) {
    return 0;
  }
  return vty;
}

/**
 * Emit ADDR_OF into x0.
 * VAR is the local slot or the module-let cell. INDEX is the scaled
 * element address. FIELD and DEREF use the lvalue address. ARRAY_LIT
 * dest-stamps into a temp and leaves that address in x0.
 * CALL (48) and METHOD (49) on arm64 forward the operand to
 * pipeline_asm_emit_lvalue_eff_addr_elf_c. That function stores a
 * 1..8 byte integer, a 9..16 byte named struct, a wider named-struct
 * address, an f32 word from s0, an f64 word from d0, or a 16-byte
 * i32, f32, or u32 vector, including a 16-byte f32 TYPE_VECTOR,
 * from x0 and x1, and leaves the address in x0.
 * A named SIMD wider than 16 bytes is that same x8 address.
 * A kind-13 vector wider than 16 stays that function's failure.
 * A lane binop (kinds 4..13), a unary minus (kind 22), a bitwise
 * not (kind 23), or a lane compare (kinds 14..19) on arm64, whose
 * resolved type is a named SIMD spelling (kind 8), is stored by
 * glue_emit_vector_type_let_init_elf_c into a temp from
 * glue_simd_alloc_vector_temp_slot_c. x0 is then that slot.
 * The compare predicate is vlet_lane_cmp_ko. It stores 0 or 1 per
 * lane. A compare node is stamped bool, so the slot type is the
 * left operand's named SIMD type, from glue_addr_simd_lane_type_c.
 * A bitwise not uses that same helper. Let-init already applies
 * mvn on each i32 lane. Kind 51 is not that binop. A kind-13
 * vector stays -99. Kind 24 stays -99.
 * ta != 1 stays -99.
 * @param arena *u8 - AST arena; null is not expected
 * @param elf_ctx *u8 - encoder context
 * @param expr_ref i32 - ADDR_OF expression
 * @param ctx *u8 - asm function context; null is not expected
 * @param ta i32 - 0 x86_64, 1 arm64
 * @return i32 - 0 when x0 holds the address; the lvalue status for a
 *   call operand on arm64; the let-init status for a named SIMD lane
 *   binop, unary minus, bitwise not, or lane compare on arm64; -1
 *   on encode failure; -99 when the operand kind is still unhandled,
 *   including a call, a lane binop, a unary minus, a bitwise not, or
 *   a lane compare when ta != 1
 * PLATFORM: SHARED body for the kinds the pabi already handled.
 * The call forward and the lane temp are ta == 1 only.
 * Darwin ARM64 measured `&pick()`, `&(a + b)`, `&(-a)`,
 * `&(a == b)`, and `&(~a)`. A compare lane holds 0 or 1. A
 * bitwise-not lane holds the integer complement.
 */
#[no_mangle]
export function pipeline_asm_emit_addr_of_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let op: i32 = 0;
  let ok: i32 = 0;
  let vname: u8[256] = [];
  let vlen: i32 = 0;
  let off: i32 = 0;
  let rc: i32 = 0;
  let gmod: *u8 = 0 as *u8;
  let base_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let esz: i32 = 0;
  let call_op: i32 = 0;
  let vty: i32 = 0;
  let vslot: i32 = 0;
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  }
  if (op <= 0) {
    return 0 - 1;
  }
  unsafe {
    ok = pipeline_expr_kind_ord_at(arena, op);
  }
  if (ok == 3) {
    unsafe {
      vlen = pipeline_expr_var_name_len(arena, op);
    }
    if (vlen <= 0) {
      return 0 - 1;
    }
    if (vlen > 255) {
      return 0 - 1;
    }
    unsafe {
      pipeline_expr_var_name_into(arena, op, &vname[0]);
      off = asm_ctx_local_find_offset_scoped(ctx, arena, &vname[0], vlen);
    }
    if (off < 0) {
      unsafe {
        off = asm_ctx_local_find_offset(ctx, &vname[0], vlen);
      }
    }
    if (off < 0) {
      // Non-local binding: module-let cell or a same-module function.
      // -99 only when the name is neither.
      unsafe {
        gmod = pipeline_asm_emit_module_ref_c();
      }
      if (gmod != (0 as *u8)) {
        unsafe {
          rc = pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx, gmod, &vname[0], vlen, ta);
        }
        if (rc == 0) {
          return 0;
        }
      }
      return 0 - 99;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
    }
    return rc;
  }
  if (ok == 47) {
    unsafe {
      base_ref = pipeline_expr_index_base_ref(arena, op);
      idx_ref = pipeline_expr_index_index_ref(arena, op);
    }
    if (base_ref <= 0) {
      return 0 - 99;
    }
    if (idx_ref <= 0) {
      return 0 - 99;
    }
    unsafe {
      esz = pipeline_asm_index_elem_byte_sz_c(arena, op);
    }
    unsafe {
      rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, op, base_ref, idx_ref, ctx, ta, esz);
    }
    return rc;
  }
  if (ok == 44) {
    unsafe {
      rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
    }
    return rc;
  }
  if (ok == 52) {
    unsafe {
      rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
    }
    return rc;
  }
  // ARRAY_LIT = 46. The array emitter leaves the temp address in x0.
  if (ok == 46) {
    unsafe {
      rc = pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, op, ctx, ta);
    }
    return rc;
  }
  // CALL = 48, METHOD = 49. One forward to the lvalue emitter.
  // That function owns the integer spill, the pair store, the wide
  // x8 address, the f32 word from s0, and the f64 word from d0.
  // Copying any of those here would split the authority. Pass the
  // call, not this ADDR_OF. SIMD names stay the lvalue failure.
  // PLATFORM: MACOS|ARM64.
  // ta != 1 keeps -99.
  if (ok == 48) {
    call_op = 1;
  }
  if (ok == 49) {
    call_op = 1;
  }
  if (call_op != 0) {
    if (ta == 1) {
      unsafe {
        rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, op, ctx, ta);
      }
      return rc;
    }
    return 0 - 99;
  }
  // Lane binop, unary minus, bitwise not, or lane compare. The
  // value is not in x0:x1. glue_addr_simd_lane_type_c is the one
  // type decision: a compare node is bool, so the slot uses the
  // operand vector. A bitwise not keeps its own named SIMD type.
  // Store through the existing vector let-init, then LEA the temp.
  // A kind-13 vector stays 0 from that helper, then -99 here.
  // Kind 24 stays 0, then -99.
  // PLATFORM: MACOS|ARM64. ta != 1 keeps -99.
  if (ta == 1) {
    unsafe {
      vty = glue_addr_simd_lane_type_c(arena, op);
    }
    if (vty != 0) {
      unsafe {
        vslot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, vty);
      }
      if (vslot < 0) {
        return 0 - 1;
      }
      unsafe {
        rc = glue_emit_vector_type_let_init_elf_c(
          arena, elf_ctx, op, ctx, ta, vslot, vty);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, vslot, ta);
      }
      return rc;
    }
  }
  return 0 - 99;
}
