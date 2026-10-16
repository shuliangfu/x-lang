// Thin pure: pipeline_asm_emit_lvalue_eff_addr_elf_c Cap leave (knife256/10.2).
// Hollow m8 / phase1 branches to text_c → CG002 on ELF field/ptr assign.
// FIELD(44): recurse base; load a PTR base only when rax is still the slot
// address. needs_ptr_load already LDR'd a *T formal, so a second load
// stores s.field through the old field value (Set_i32.keys SEGV at 0).
// VAR(3): stack_off → glue_enc_local_slot_ptr_or_addr_elf_c (LEA/LDR).
// CALL(48) / METHOD(49): a field base such as `&pick().v` recurses here.
// The result is in x0, same as `let s = pick()`. A 9..16 byte named
// struct also returns the high half in x1. Spill those registers into
// a frame slot and leave the slot address in x0. A named struct wider
// than 16 bytes is already written through x8 into the call wrapper's
// frame temp; x0 is that address, so this arm only emits the call.
// The FIELD arm adds the field offset. Float results and SIMD names
// stay unhandled. The spill runs only for ta == 1.
// PLATFORM: SHARED freestanding · MACOS tip cold · LINUX gold.
// The call spill is MACOS|ARM64.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_field_access_layout_offset(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, stack_off: i32, ctx: *u8, ta: i32): i32;
export extern function glue_local_var_slot_needs_ptr_load_elf_c(arena: *u8, var_ref: i32, var_off: i32, ctx: *u8): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(
  arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, slot: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, slot: i32, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(
  m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;

/**
 * ELF lvalue effective address in x0.
 * FIELD recurses into the base, then adds the field offset.
 * A CALL or METHOD base spills a 1..8 byte non-float result into a
 * frame slot and returns that slot. A 9..16 byte named struct also
 * stores the x1 half. A named struct wider than 16 bytes is emitted
 * as the call: the wrapper leaves the x8 temp address in x0. Float
 * results and SIMD names return -1. x86_64 does not spill a call.
 * @param arena *u8 - AST arena; null returns -1
 * @param elf_ctx *u8 - codegen context; null returns -1
 * @param expr_ref i32 - lvalue expr; <=0 returns -1
 * @param ctx *u8 - function asm context; null returns -1
 * @param ta i32 - target arch; the call spill runs only for ta == 1
 * @return i32 - 0 when x0 holds the address; -1 on failure
 * PLATFORM: SHARED for VAR, FIELD, DEREF, and INDEX.
 * The call spill is MACOS|ARM64.
 */
#[no_mangle]
export function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8)) {
      return 0 - 1;
    }
    if (elf_ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (expr_ref <= 0) {
      return 0 - 1;
    }
    let k: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    // FIELD_ACCESS == 44 (0x2c)
    if (k == 44) {
      let base: i32 = pipeline_expr_field_access_base_ref(arena, expr_ref);
      if (base <= 0) {
        return 0 - 1;
      }
      if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base, ctx, ta) != 0) {
        return 0 - 1;
      }
      // If base yields a pointer value already in rax for nested FIELD of PTR:
      // when base itself is FIELD and resolved type PTR — load. For VAR of
      // PTR, local_slot already loaded the pointer value when needs_ptr_load.
      // Mirror restored: load when base kind is FIELD and type kind PTR(9).
      if (pipeline_expr_kind_ord_at(arena, base) == 44) {
        let rty: i32 = pipeline_expr_resolved_type_ref(arena, base);
        if (rty > 0) {
          if (pipeline_type_kind_ord_at(arena, rty) == 9) {
            if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0) {
              return 0 - 1;
            }
          }
        }
      }
      // VAR base with PTR type. local_slot LDR's when needs_ptr_load
      // (formal *T / indirect home): rax is already the struct address.
      // A second load derefs that pointer and s.field stores through null.
      // LEA (needs_ptr_load == 0) still loads: rax is the address of the slot.
      if (pipeline_expr_kind_ord_at(arena, base) == 3) {
        let rty2: i32 = pipeline_expr_resolved_type_ref(arena, base);
        if (rty2 > 0) {
          if (pipeline_type_kind_ord_at(arena, rty2) == 9) {
            let soff2: i32 = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, base);
            if (soff2 < 0) {
              soff2 = glue_var_expr_stack_off_elf_c(arena, ctx, base);
            }
            let already: i32 = 0;
            if (soff2 >= 0) {
              if (glue_local_var_slot_needs_ptr_load_elf_c(arena, base, soff2, ctx) != 0) {
                already = 1;
              }
            }
            if (already == 0) {
              if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0) {
                return 0 - 1;
              }
            }
          }
        }
      }
      let mod: *u8 = glue_emit_module_from_ctx(ctx);
      if (mod == (0 as *u8)) {
        mod = pipeline_asm_emit_module_ref_c();
      }
      let off: i32 = pipeline_expr_field_access_layout_offset(arena, mod, expr_ref);
      if (off < 0) {
        return 0 - 1;
      }
      return backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta);
    }
    // VAR == 3
    if (k == 3) {
      let soff: i32 = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
      if (soff < 0) {
        soff = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
      }
      if (soff < 0) {
        return 0 - 1;
      }
      return glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, expr_ref, soff, ctx, ta);
    }
    // DEREF / unary * == 52 (0x34) — emit operand into rax (pointer value)
    if (k == 52) {
      let op: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op <= 0) {
        return 0 - 1;
      }
      return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    }
    // INDEX == 47. `p[i].field` is FIELD whose base is INDEX. Recursing
    // the FIELD arm landed here and returned -1, so the module emitted
    // nothing (CG002). Scaling stays in glue_emit_index_eff_addr_scaled_elf_c,
    // the same helper addr-of already uses. A constant 0 index adds nothing,
    // so a *T formal `p[0].field` is the pointer value plus the field offset.
    // PLATFORM: SHARED.
    if (k == 47) {
      let ib: i32 = pipeline_expr_index_base_ref(arena, expr_ref);
      let ii: i32 = pipeline_expr_index_index_ref(arena, expr_ref);
      let esz: i32 = 0;
      if (ib <= 0) {
        return 0 - 1;
      }
      if (ii <= 0) {
        return 0 - 1;
      }
      esz = pipeline_asm_index_elem_byte_sz_c(arena, expr_ref);
      return glue_emit_index_eff_addr_scaled_elf_c(
        arena, elf_ctx, expr_ref, ib, ii, ctx, ta, esz);
    }
    // CALL = 48, METHOD = 49. `pick().v` is FIELD whose base is the
    // call. A 1..8 byte result is in x0. A 9..16 byte named struct is
    // in x0 and x1, same as `let s = pick()`. The pair store is the
    // existing retval helper. Wider than 16, the call wrapper already
    // materializes the named struct through x8 and leaves its address
    // in x0. SIMD names stay out. f32 (14) and f64 (15) are not in x0.
    // PLATFORM: MACOS|ARM64. ta != 1 returns -1.
    let call_op: i32 = 0;
    if (k == 48) {
      call_op = 1;
    }
    if (k == 49) {
      call_op = 1;
    }
    if (call_op != 0) {
      if (ta == 1) {
        let tr: i32 = pipeline_expr_resolved_type_ref(arena, expr_ref);
        let trk: i32 = 0;
        let sz: i32 = 0;
        let slot: i32 = 0;
        let gmod: *u8 = 0 as *u8;
        if (tr > 0) {
          trk = pipeline_type_kind_ord_at(arena, tr);
          gmod = glue_emit_module_from_ctx(ctx);
          if (gmod == (0 as *u8)) {
            gmod = pipeline_asm_emit_module_ref_c();
          }
          sz = glue_type_size_simple(gmod, arena, tr, 0);
        }
        if (trk == 14) {
          sz = 0;
        }
        if (trk == 15) {
          sz = 0;
        }
        if (sz > 0) {
          if (sz <= 8) {
            slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, tr);
            if (slot < 0) {
              return 0 - 1;
            }
            if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
              return 0 - 1;
            }
            if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slot, ta) != 0) {
              return 0 - 1;
            }
            return backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot, ta);
          }
        }
        // Named struct, 9..16 bytes. Not a SIMD spelling. The high
        // half is x1 at slot + 8. Wider than 16 stays -1.
        if (sz > 8) {
          if (sz <= 16) {
            if (trk == 8) {
              let simd: i32 = asm_type_is_simd_vector_spelling(arena, tr);
              if (simd == 0) {
                slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, tr);
                if (slot < 0) {
                  return 0 - 1;
                }
                if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                  return 0 - 1;
                }
                if (glue_store_retval_pair_to_rbp_elf_c(
                    gmod, arena, elf_ctx, tr, slot, ta, expr_ref, ctx) != 0) {
                  return 0 - 1;
                }
                return backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot, ta);
              }
            }
          }
        }
        // Named struct wider than 16 bytes. Not a SIMD spelling.
        // pipeline_asm_emit_call_elf_c writes x8's temp and leaves
        // that address in x0. No second copy. PLATFORM: MACOS|ARM64.
        if (sz > 16) {
          if (trk == 8) {
            let wide_simd: i32 = asm_type_is_simd_vector_spelling(arena, tr);
            if (wide_simd == 0) {
              if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
                return 0 - 1;
              }
              return 0;
            }
          }
        }
      }
      return 0 - 1;
    }
    return 0 - 1;
  }
}
