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
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

let g_w2060_emit_let_vn: u8[256] = [];

/**
 * Emit one let init. w2060: empty [] fixed T[N] zero-fills via fixed_array path.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding emit.
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
      arr_st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, pipeline_block_let_type_ref(arena, block_ref, idx), slot_off);
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
      /* -2: METHOD_CALL/CALL — G.7 reuse struct CALL sret/dual-GP authority. */
      glue_index_assign_addr_cache_clear();
      rc = glue_emit_struct_type_let_init_elf_c(
          arena, elf_ctx, init_ref, ctx, ta, vtype_ref, slot_off);
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
