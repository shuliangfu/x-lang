// Thin: glue_block_body_emit_let_init (w2060 empty fixed-array [] zero-fill).
// Root: empty ARRAY_LIT on T[N] early-returned with no stores; tip stack reuse
// left func_name_len_storage stale → parse_one_function_impl skipped IDENT
// consume → TOKEN_LPAREN expect got IDENT=59 (XT001 on 2nd function).
// Fix: call glue_emit_fixed_array_type_let_init_elf_c (wave363 zero path).
// BSS vn avoids tip u8[256] smash (w1010 class). All three hosts tip-compile
// this .x. f32 stores call backend_enc_store_eax_to_rbp_arch. The Windows
// host reloads elf_ctx before the null compare, so that call is not the
// w1010 -1 path and this file does not inline the movl.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS|DARWIN · WINDOWS.

export extern function backend_asm_ctx_slot_offset(ctx: *u8, slot_idx: i32): i32;
export extern function backend_enc_store_eax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_array_temp_bytes_for_let_init(arena: *u8, let_type_ref: i32, init_ref: i32): i32;
export extern function glue_binop_var_slot_cache_kill_def_at_slot(off: i32): void;
export extern function glue_block_let_is_fixed_array_type(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function glue_block_let_is_simd_vector_type(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function glue_emit_array_let_empty_init(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_wide_i32_vec_array_bytes(arena: *u8, rty: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32): i32;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_init_is_empty_array_lit(arena: *u8, init_ref: i32): i32;
export extern function glue_live_fwd_forward_after_def(arena: *u8, ctx: *u8, def_off: i32, gen_expr: i32): void;
export extern function glue_maybe_demote_f64_to_f32_eax_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, dest_ty_ref: i32, src_expr_ref: i32, ta: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, dest_ty_ref: i32, src_ty_ref: i32, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;
export extern function glue_try_block_let_index_init_from_assign_cache_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, init_ref: i32, ta: i32): i32;
export extern function pipeline_asm_bump_next_offset_after_let_init(arena: *u8, block_ref: i32, let_idx: i32, init_ref: i32, ctx: *u8): void;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_try_emit_dyn_coerce_let(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, slot_off: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_block_let_type_ref(arena: *u8, block_ref: i32, let_idx: i32): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, block_ref: i32, name: *u8, nlen: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;

let g_w2060_emit_let_vn: u8[256] = [];

/**
 * Emit one let init. w2060: empty [] fixed T[N] zero-fills via fixed_array path.
 * A call whose type is [N] of an i32 vector wider than 16 bytes uses the
 * struct call arm (lea slot, mov x8). Every other fixed array, including
 * a -2 from the fixed-array store, keeps that store.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param block_ref i32 — enclosing block
 * @param idx i32 — let index in the block
 * @param init_ref i32 — initializer expr
 * @param slot i32 — let slot index
 * @param ctx *u8 — AsmFuncCtx
 * @param ta i32 — target arch
 * @param lnb *u8 — let name bytes; may be unused by a given arm
 * @param llen i32 — let name length
 * @return i32 — 0 ok; -1 fail
 * An integer literal under ADDR_OF is stamped as a pointer to i32.
 * A float literal under ADDR_OF is stamped as a pointer to f64.
 * A bool literal under ADDR_OF is stamped as a pointer to bool.
 * A unary minus of an integer literal under ADDR_OF is stamped
 * as a pointer to i32. Named soft equality then accepts that
 * pointer as *i32x4 or *f32x4. This emitter writes the declared
 * pointer onto that ADDR_OF before emit, so the addr peel can
 * see the SIMD pointee. The splat store stays in the addr emitter.
 * PLATFORM: SHARED freestanding emit. Darwin ARM64 measured.
 */
#[no_mangle]
export function glue_block_body_emit_let_init(arena: *u8, elf_ctx: *u8, block_ref: i32, idx: i32, init_ref: i32, slot: i32, ctx: *u8, ta: i32, lnb: *u8, llen: i32): i32 {
  let tref_empty: i32 = 0;
  let slice_st: i32 = 0;
  let arr_st: i32 = 0;
  let vst: i32 = 0;
  let st: i32 = 0;
  let ix_init: i32 = 0;
  let let_ty: i32 = 0;
  let init_ko: i32 = 0;
  let let_ty2: i32 = 0;
  let src_ty: i32 = 0;
  /* vn lives in BSS (g_w2060_emit_let_vn) — tip smash class. */
  let vn: *u8 = &g_w2060_emit_let_vn[0];
  let vl: i32 = 0;
  let bt: i32 = 0;
  let vtype_ref: i32 = 0;
  let rc: i32 = 0;
  let slot_off: i32 = 0;
  let init_f32_lit: i32 = 0;
  let addr_op: i32 = 0;
  let addr_ok: i32 = 0;
  let addr_pk: i32 = 0;
  let addr_pt: i32 = 0;
  let addr_sp: i32 = 0;
  let copy_ref: i32 = 0;
  let peel_n: i32 = 0;
  let peeled: i32 = 0;

  unsafe {
    slot_off = backend_asm_ctx_slot_offset(ctx, slot);
  }

  /* F7: TYPE_DYN let-init → 16-byte fat {data, vtable}. Authority lives in
   * backend_call_dispatch (rebuildable seed); this is the single call site.
   * PLATFORM: SHARED freestanding emit. */
  unsafe {
    rc = pipeline_asm_try_emit_dyn_coerce_let(arena, elf_ctx, block_ref, idx, init_ref, slot_off, ctx, ta);
  }
  if (rc == 1) {
    return 0;
  }
  if (rc < 0) {
    return 0 - 1;
  }

  unsafe {
    if (glue_init_is_empty_array_lit(arena, init_ref) != 0) {
      tref_empty = pipeline_block_let_type_ref(arena, block_ref, idx);
      slice_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref, tref_empty, ctx, ta, slot_off);
      if (slice_st == 1) {
        return 0;
      }
      if (slice_st < 0) {
        return 0 - 1;
      }
      if (glue_block_let_is_fixed_array_type(arena, block_ref, idx) != 0) {
        /* w2060: empty ARRAY_LIT `[]` on fixed T[N] must zero-fill the slot
         * (C `{0}` / `= {}`). Prior early-return left stack garbage; tip
         * reuse of the same frame then skipped `if (storage[0]==0)` name
         * consume in parse_one_function_impl (kind stayed IDENT=59).
         * G.7: same authority as non-empty fixed let-init.
         * PLATFORM: SHARED freestanding emit. */
        arr_st = glue_emit_fixed_array_type_let_init_elf_c(
            arena, elf_ctx, init_ref, ctx, ta, tref_empty, slot_off);
        if (arr_st == 0) {
          return 0;
        }
        return 0 - 1;
      }
      if (glue_array_temp_bytes_for_let_init(arena, tref_empty, 0) > 0) {
        rc = glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, slot_off);
        if (rc != 0) {
          return 0 - 1;
        }
        pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
      }
      return 0;
    }
  }

  unsafe {
    if (glue_block_let_is_fixed_array_type(arena, block_ref, idx) != 0) {
      let_ty2 = pipeline_block_let_type_ref(arena, block_ref, idx);
      /*
       * [N]Vec8i wider than 16 bytes is sret into this let slot.
       * The fixed-array store would keep the call's pointer. The struct
       * call arm already leas the slot and moves it to x8. A non-call,
       * and every array the helper rejects, keeps the fixed-array store.
       * PLATFORM: SHARED.
       */
      if (glue_wide_i32_vec_array_bytes(arena, let_ty2) > 16) {
        init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
        if (init_ko == 48 || init_ko == 49) {
          rc = glue_emit_struct_type_let_init_elf_c(
              arena, elf_ctx, init_ref, ctx, ta, let_ty2, slot_off);
          if (rc == 0) {
            return 0;
          }
          if (rc == 0 - 1) {
            return 0 - 1;
          }
        }
      }
      arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, let_ty2, slot_off);
      if (arr_st == 0) {
        return 0;
      }
      if (arr_st == 0 - 1) {
        return 0 - 1;
      }
      return 0 - 1;
    }
  }

  unsafe {
    if (glue_block_let_is_simd_vector_type(arena, block_ref, idx) != 0) {
      vtype_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
      vst = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, slot_off, vtype_ref);
      if (vst == 0) {
        return 0;
      }
      if (vst == 0 - 1) {
        return 0 - 1;
      }
      /* -2: METHOD_CALL/CALL — G.7 reuse struct CALL sret/dual-GP authority.
       * `let v = unsafe { *p }` is a block. The vector face peels it,
       * sees a bare DEREF, and returns -3. Passing the block into
       * struct let-init misses the DEREF and FIELD copies. A transparent
       * block (no lets or loops) is replaced by its value, at most four
       * times, and only a DEREF or a FIELD uses that value. The store
       * is not through the pointer. PLATFORM: SHARED. */
      copy_ref = init_ref;
      peel_n = 0;
      while (peel_n < 4) {
        peeled = glue_expr_block_transparent_value_ref_at(arena, copy_ref);
        if (peeled <= 0) {
          peel_n = 4;
        } else {
          if (peeled == copy_ref) {
            peel_n = 4;
          } else {
            copy_ref = peeled;
            peel_n = peel_n + 1;
          }
        }
      }
      init_ko = pipeline_expr_kind_ord_at(arena, copy_ref);
      if (init_ko != 52) {
        if (init_ko != 44) {
          copy_ref = init_ref;
        }
      }
      glue_index_assign_addr_cache_clear();
      rc = glue_emit_struct_type_let_init_elf_c(
          arena, elf_ctx, copy_ref, ctx, ta, vtype_ref, slot_off);
      if (rc == 0) {
        return 0;
      }
      if (rc == 0 - 1) {
        return 0 - 1;
      }
      rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      rc = glue_store_retval_pair_to_rbp_elf_c(
          glue_emit_module_from_ctx(ctx), arena, elf_ctx, vtype_ref, slot_off, ta, init_ref, ctx);
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
  }

  unsafe {
    slice_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref, pipeline_block_let_type_ref(arena, block_ref, idx), ctx, ta, slot_off);
  }
  if (slice_st == 1) {
    return 0;
  }
  if (slice_st < 0) {
    return 0 - 1;
  }

  unsafe {
    st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, pipeline_block_let_type_ref(arena, block_ref, idx), slot_off);
  }
  if (st == 0) {
    return 0;
  }
  if (st == 0 - 1) {
    return 0 - 1;
  }

  unsafe {
    init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  // ARRAY_LIT = 46
  if (init_ko == 46) {
    unsafe {
      glue_index_assign_addr_cache_clear();
      rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, init_ref, ctx);
    }
    return 0;
  }

  unsafe {
    ix_init = glue_try_block_let_index_init_from_assign_cache_elf_c(arena, elf_ctx, ctx, init_ref, ta);
  }
  if (ix_init < 0) {
    return 0 - 1;
  }
  if (ix_init == 0) {
    unsafe {
      glue_index_assign_addr_cache_clear();
      let_ty = pipeline_block_let_type_ref(arena, block_ref, idx);
      init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
      // GLUE_TYPE_KIND_F32_ORD = 14; EXPR_LIT = 1
      if (let_ty > 0 && pipeline_type_kind_ord_at(arena, let_ty) == 14 && init_ko == 1) {
        // Dest-typed literal emit: value already f32 bits — skip demote at store.
        init_f32_lit = 1;
        rc = glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, init_ref, ta, let_ty, 0);
      } else {
        // Kind 51 is ADDR_OF. Kind 0 is the integer literal.
        // Kind 1 is the float literal. Kind 2 is the bool literal.
        // Kind 22 is a unary minus. The operand stamp is a pointer
        // to i32, a pointer to f64, or a pointer to bool. The
        // declared pointer is the slot type when its pointee spells
        // a SIMD vector. The addr peel still accepts kind 8, and
        // kind 13 only for 4 lanes of 4 bytes. An f32 lane keeps
        // the bool integer bits. A vector unary keeps the helper
        // temp when that result is nonzero.
        // PLATFORM: SHARED.
        if (init_ko == 51) {
          addr_op = pipeline_expr_unary_operand_ref_at(arena, init_ref);
          if (addr_op > 0) {
            addr_ok = pipeline_expr_kind_ord_at(arena, addr_op);
            if (addr_ok == 0) {
              if (let_ty > 0) {
                addr_pk = pipeline_type_kind_ord_at(arena, let_ty);
                if (addr_pk == 9) {
                  addr_pt = pipeline_type_elem_ref_at(arena, let_ty);
                  if (addr_pt > 0) {
                    addr_sp = asm_type_is_simd_vector_spelling(arena, addr_pt);
                    if (addr_sp != 0) {
                      pipeline_expr_set_resolved_type_ref(arena, init_ref, let_ty);
                    }
                  }
                }
              }
            }
            if (addr_ok == 1) {
              if (let_ty > 0) {
                addr_pk = pipeline_type_kind_ord_at(arena, let_ty);
                if (addr_pk == 9) {
                  addr_pt = pipeline_type_elem_ref_at(arena, let_ty);
                  if (addr_pt > 0) {
                    addr_sp = asm_type_is_simd_vector_spelling(arena, addr_pt);
                    if (addr_sp != 0) {
                      pipeline_expr_set_resolved_type_ref(arena, init_ref, let_ty);
                    }
                  }
                }
              }
            }
            if (addr_ok == 2) {
              if (let_ty > 0) {
                addr_pk = pipeline_type_kind_ord_at(arena, let_ty);
                if (addr_pk == 9) {
                  addr_pt = pipeline_type_elem_ref_at(arena, let_ty);
                  if (addr_pt > 0) {
                    addr_sp = asm_type_is_simd_vector_spelling(arena, addr_pt);
                    if (addr_sp != 0) {
                      pipeline_expr_set_resolved_type_ref(arena, init_ref, let_ty);
                    }
                  }
                }
              }
            }
            if (addr_ok == 22) {
              if (let_ty > 0) {
                addr_pk = pipeline_type_kind_ord_at(arena, let_ty);
                if (addr_pk == 9) {
                  addr_pt = pipeline_type_elem_ref_at(arena, let_ty);
                  if (addr_pt > 0) {
                    addr_sp = asm_type_is_simd_vector_spelling(arena, addr_pt);
                    if (addr_sp != 0) {
                      pipeline_expr_set_resolved_type_ref(arena, init_ref, let_ty);
                    }
                  }
                }
              }
            }
          }
        }
        rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }

  unsafe {
    let_ty2 = pipeline_block_let_type_ref(arena, block_ref, idx);
  }
  if (let_ty2 > 0) {
    unsafe {
      if (pipeline_type_kind_ord_at(arena, let_ty2) == 14) {
        // f32 dest with f64-typed init: demote to f32 bits before the 4-byte
        // store — else the store keeps only the low 32 bits of the f64.
        // Skip when the dest-typed literal fast path already emitted f32 bits
        // or the index-cache init provided the value.
        if (ix_init == 0 && init_f32_lit == 0) {
          unsafe {
            rc = glue_maybe_demote_f64_to_f32_eax_elf_c(arena, elf_ctx, ctx, let_ty2, init_ref, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        rc = backend_enc_store_eax_to_rbp_arch(elf_ctx, slot_off, ta);
        if (rc != 0) {
          return 0 - 1;
        }
        glue_binop_var_slot_cache_kill_def_at_slot(slot_off);
        glue_live_fwd_forward_after_def(arena, ctx, slot_off, init_ref);
        return 0;
      }
    }
  }

  unsafe {
    src_ty = glue_float_promote_src_ty_ref_c(arena, init_ref);
    if (pipeline_expr_kind_ord_at(arena, init_ref) == 3) {
      vl = pipeline_expr_var_name_len(arena, init_ref);
      if (vl > 0 && vl <= 63) {
        pipeline_expr_var_name_into(arena, init_ref, vn);
        bt = pipeline_block_resolve_var_type_ref(arena, block_ref, vn, vl);
        if (bt > 0) {
          src_ty = bt;
        }
      }
    }
    rc = glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, let_ty2, src_ty, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, let_ty2, slot_off, ta, init_ref, ctx);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    glue_binop_var_slot_cache_kill_def_at_slot(slot_off);
    glue_live_fwd_forward_after_def(arena, ctx, slot_off, init_ref);
  }
  return 0;
}
