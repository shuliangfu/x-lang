// Thin overlay of pipeline_asm_emit_addr_of_elf_c.
// The frozen pabi body handles VAR, INDEX, FIELD, DEREF, and ARRAY_LIT.
// A CALL or METHOD operand fell through to -99, which is CG002
// (Darwin `&pick()` where pick returns i32). This overlay is that same
// body, plus a frame slot for a register-sized call result: emit the
// call, store x0 into the slot, then lea the slot into x0. The slot
// comes from the existing next_offset allocator, so it stays live for
// the function. Float results stay in the SIMD register and still
// return -99. A result wider than 8 bytes still returns -99.
// Linked before pabi_weak. That copy of this symbol is weakened.
// PLATFORM: MACOS|DARWIN link. The spill runs only for ta == 1.
// x86_64 keeps the old -99 for a call operand.

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
export extern function pipeline_asm_emit_expr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Emit ADDR_OF into x0.
 * VAR is the local slot or the module-let cell. INDEX is the scaled
 * element address. FIELD and DEREF use the lvalue address. ARRAY_LIT
 * dest-stamps into a temp and leaves that address in x0.
 * CALL (48) and METHOD (49) on arm64: when the result is an integer
 * or pointer of 1 to 8 bytes, it is stored into a frame slot allocated
 * from next_offset and x0 becomes that slot. emit_expr left the bits
 * in x0, and there was no address to take (Darwin `&pick()` CG002).
 * f32 and f64 stay -99. Wider than 8 bytes stays -99.
 * @param arena *u8 - AST arena; null is not expected
 * @param elf_ctx *u8 - encoder context
 * @param expr_ref i32 - ADDR_OF expression
 * @param ctx *u8 - asm function context; null is not expected
 * @param ta i32 - 0 x86_64, 1 arm64
 * @return i32 - 0 when x0 holds the address; -1 on encode failure;
 *   -99 when the operand kind is still unhandled
 * PLATFORM: SHARED body for the kinds the pabi already handled.
 * The call-result slot is ta == 1 only. Darwin ARM64 measured `&pick()`.
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
  let tr: i32 = 0;
  let trk: i32 = 0;
  let sz: i32 = 0;
  let slot: i32 = 0;
  let call_op: i32 = 0;
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
  // CALL = 48, METHOD = 49. Materialize a 1..8 byte integer or pointer
  // result into a frame slot, then take that address. f32 (14) and f64
  // (15) are not in x0. Wider results stay unhandled.
  // PLATFORM: MACOS|ARM64. ta != 1 keeps -99.
  if (ok == 48) {
    call_op = 1;
  }
  if (ok == 49) {
    call_op = 1;
  }
  if (call_op != 0) {
    if (ta == 1) {
      unsafe {
        tr = pipeline_expr_resolved_type_ref(arena, op);
      }
      if (tr > 0) {
        unsafe {
          trk = pipeline_type_kind_ord_at(arena, tr);
          gmod = pipeline_asm_emit_module_ref_c();
          sz = glue_type_size_simple(gmod, arena, tr, 0);
        }
      }
      if (trk == 14) {
        sz = 0;
      }
      if (trk == 15) {
        sz = 0;
      }
      if (sz > 0) {
        if (sz <= 8) {
          unsafe {
            slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, tr);
          }
          if (slot < 0) {
            return 0 - 1;
          }
          unsafe {
            rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, slot, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot, ta);
          }
          return rc;
        }
      }
    }
    return 0 - 99;
  }
  return 0 - 99;
}
