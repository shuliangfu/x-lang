// Thin pure: arr REST struct_lit_store_fixed_array_field only.
// G.7: body MUST match glue_struct_lit_store_fixed_array_field_elf_c.
// wave427: Darwin -c ~14597B; LINUX HARD BAN (Ubuntu asm empty .o RC=0).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function glue_asm_lea_rax_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rax_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx: *u8, nbytes: i32, ta: i32): i32;
export extern function glue_emit_sret_return_from_var_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, off: i32, ctx: *u8, ta: i32): i32;
export extern function glue_field_access_effective_offset_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_float_promote_src_ty_ref_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_maybe_promote_f32_to_f64_rax_elf_c(arena: *u8, elf_ctx: *u8, rty: i32, sty: i32, ta: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_pipeline_asm_al_nc_seq_take_c(): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_try_index_var_or_field_base_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_try_return_slice_escape_from_fixed_array_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_bump_next_offset_for_array_lit(arena: *u8, expr_ref: i32, ctx: *u8): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_array_lit_force_esz_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_vector_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_int64_val_at(arena: *u8, expr_ref: i32): i64;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit_expr_ref: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena: *u8, elf_ctx: *u8, array_lit_ref: i32, elem_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function asm_local_var_slot_holds_indirect_ptr(arena: *u8, var_ref: i32, mod: *u8, ctx: *u8): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, dst: *u8): void;
export extern function pipeline_module_num_funcs(mod: *u8): i32;
export extern function pipeline_module_func_param_type_ref_for_name(mod: *u8, fi: i32, name: *u8, nlen: i32): i32;
export extern function asm_ctx_scope_block_ref_at(ctx: *u8): i32;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, br: i32, name: *u8, nlen: i32): i32;
export extern function glue_type_ref_is_named_struct_layout_elf_c(arena: *u8, mod: *u8, ty_ref: i32): i32;
export extern function glue_type_is_fixed_array(arena: *u8, ty_ref: i32): i32;
export extern function glue_emit_func_param_is_indirect_array_slot_c(arena: *u8, mod: *u8, var_ref: i32): i32;
export extern function glue_call_arg_var_use_lea_not_load_elf_c(arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, leaf_esz: i32, flat_i: *i32): i32;

/**
 * STRUCT_LIT fixed TYPE_ARRAY field store / fixed-array let element-wise authority.
 * Handles ARRAY_LIT, zero LIT, VAR/FIELD, CALL/METHOD/INDEX (E* + bulk esz>8).
 * @param arena *u8 - ASTArena*
 * @param elf_ctx *u8 - ElfCodegenCtx*
 * @param init_ref i32 - field/let init expr ref
 * @param ctx *u8 - AsmFuncCtx*
 * @param ta i32 - target arch
 * @param sret_direct i32 - 0=frame mag dest; non-0=sret true address + foff
 * @param base_off i32 - Outer byte0 frame magnitude (or unused when sret)
 * @param foff i32 - field byte offset from Outer byte0
 * @param fty i32 - fixed TYPE_ARRAY type ref
 * @return i32 - 0 handled; -1 error; -2 unsupported init
 * wave146 pure: G.7 authority (was static glue_struct_lit_store_fixed_array_field_elf_c).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
#[no_mangle]
export function glue_struct_lit_store_fixed_array_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, sret_direct: i32, base_off: i32, foff: i32, fty: i32): i32 {
  unsafe {
    let iko: i32 = 0;
    let n_arr: i32 = 0;
    let esz: i32 = 0;
    let ai: i32 = 0;
    let elem_tr: i32 = 0;
    let src_off: i32 = 0;
    let field_mag: i32 = 0;
    let elem_ref: i32 = 0;
    let lit_v: i64 = 0;
    let var_base: i32 = 0;
    let var_off: i32 = 0;
    let field_off: i32 = 0;
    let is_enum: i32 = 0;
    let ko_base: i32 = 0;
    let ly: *u8 = 0 as *u8;
    let spill_off: i32 = 0;
    let emit_rc: i32 = 0;
    let next_off: i32 = 0;
    let src_spill: i32 = 0;
    let dst_spill: i32 = 0;
    let total: i32 = 0;
    let sret_home: i32 = 0;
    let mod: *u8 = 0 as *u8;
    let rc: i32 = 0;
    let store_off: i32 = 0;
    let empty_array_zero: i32 = 0;
    let lit_n: i32 = 0;
    let src: i32 = 0;
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0 || fty <= 0) {
      return 0 - 1;
    }
    unsafe {
      src = glue_peel_as_array_slice_ascription_c(arena, init_ref);
    }
    if (src <= 0) {
      src = init_ref;
    }
    unsafe {
      iko = pipeline_expr_kind_ord_at(arena, src);
      n_arr = pipeline_type_array_size_at(arena, fty);
    }
    if (n_arr <= 0 && iko == 46) {
      unsafe {
        n_arr = pipeline_expr_array_lit_num_elems_at(arena, src);
      }
    }
    // Empty ARRAY_LIT `[]` has 0 elems; type size still supplies n_arr for zero-fill.
    // Per-elem paths still cap at 1024; empty / zero-fill may be larger (skip body if huge).
    if (n_arr <= 0) {
      return 0 - 1;
    }
    unsafe {
      elem_tr = pipeline_type_elem_ref_at(arena, fty);
      /* Outer stride of dest TYPE_ARRAY = sizeof(elem). Peel-then-measure
       * via glue_index_elem_byte_sz(elem) is wrong for [K][N]T: elem is
       * TYPE_ARRAY and index-esz peels again to sizeof(leaf) (4 for i32),
       * so VAR/CALL dest memcpy copies only the first row (asm run=3;
       * named-local `let r = t` same). G.7: reuse
       * glue_array_lit_force_esz_from_elem_type (TYPE_ARRAY →
       * glue_fixed_array_total_bytes). Twin of 4.2.7 nested SLICE esz
       * (pass the compound, do not peel then measure).
       * PLATFORM: SHARED freestanding dest-ARRAY memcpy · LINUX gold. */
      esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_tr);
    }
    if (esz <= 0) {
      unsafe {
        esz = glue_index_elem_byte_sz_from_type_ref_c(arena, fty);
      }
    }
    if (esz <= 0) {
      esz = 4;
    }
    field_mag = 0;
    if (sret_direct == 0) {
      unsafe {
        field_mag = glue_struct_field_frame_mag_c(base_off, foff, ta);
      }
      if (field_mag < 0) {
        return 0 - 1;
      }
    }

    // EXPR_ARRAY_LIT = 46.
    // Empty `[]` ≡ product zero-init (host-C `{0}`) — fall through to wave363 zero path.
    // Non-empty still uses vector_let_init (caps at 1024 elems).
    // PLATFORM: SHARED freestanding — Stage 12.2.7 CG002 root (struct field `data: []`).
    if (iko == 46) {
      unsafe {
        lit_n = pipeline_expr_array_lit_num_elems_at(arena, src);
      }
      if (lit_n == 0) {
        empty_array_zero = 1;
      } else if (n_arr > 1024) {
        return 0 - 1;
      } else if (sret_direct == 0) {
        unsafe {
          return pipeline_asm_emit_vector_let_init_elf_c(arena, elf_ctx, src, ctx, ta, field_mag);
        }
      } else {
        unsafe {
          sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
        }
        ai = 0;
        while (ai < n_arr) {
          unsafe {
            elem_ref = pipeline_expr_array_lit_elem_ref(arena, src, ai);
          }
          if (elem_ref == 0) {
            ai = ai + 1;
            continue;
          }
          unsafe {
            rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
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
            rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
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
            rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          ai = ai + 1;
        }
        return 0;
      }
    }

    // wave363: let a: T[N] = 0 zero-fill (+ empty ARRAY_LIT `[]` via empty_array_zero).
    // n_arr > 1024: accept without per-elem stores (avoids multi-MiB instruction blast;
    // product multi-MiB buffers use heap ensure / uninit+assign, not STRUCT_LIT zero).
    if (iko == 0 || empty_array_zero != 0) {
      if (empty_array_zero == 0) {
        unsafe {
          lit_v = pipeline_expr_int64_val_at(arena, init_ref);
        }
        if (lit_v != (0 as i64)) {
          return 0 - 2;
        }
      }
      if (n_arr > 1024) {
        return 0;
      }
      if (sret_direct == 0) {
        unsafe {
          rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
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
          rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        ai = 0;
        while (ai < n_arr) {
          unsafe {
            rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          ai = ai + 1;
        }
        return 0;
      }
      unsafe {
        sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      }
      unsafe {
        rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      ai = 0;
      while (ai < n_arr) {
        unsafe {
          rc = backend_enc_push_rax_arch(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
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
          rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        ai = ai + 1;
      }
      return 0;
    }

    src_off = 0 - 1;
    if (iko == 3) {
      unsafe {
        src_off = glue_var_expr_stack_off_elf_c(arena, ctx, src);
      }
    } else if (iko == 44) {
      unsafe {
        is_enum = pipeline_expr_field_access_is_enum_variant(arena, src);
      }
      if (is_enum != 0) {
        return 0 - 2;
      }
      unsafe {
        var_base = pipeline_expr_field_access_base_ref(arena, src);
      }
      if (var_base <= 0) {
        return 0 - 2;
      }
      unsafe {
        ko_base = pipeline_expr_kind_ord_at(arena, var_base);
      }
      if (ko_base != 3) {
        return 0 - 2;
      }
      unsafe {
        var_off = glue_var_expr_stack_off_elf_c(arena, ctx, var_base);
      }
      if (var_off < 0) {
        return 0 - 1;
      }
      unsafe {
        mod = pipeline_asm_emit_module_ref_c();
        field_off = glue_field_access_effective_offset_c(arena, mod, src);
      }
      if (field_off < 0) {
        field_off = 0;
      }
      unsafe {
        src_off = glue_struct_field_frame_mag_c(var_off, field_off, ta);
      }
      if (src_off < 0) {
        return 0 - 1;
      }
    } else if (iko == 48 || iko == 49 || iko == 47 || iko == 52) {
      /* CALL=48 / METHOD=49 / INDEX=47 / DEREF=52: emit leaves E* (TYPE_ARRAY
       * return / subrow / emit_deref trk==10 leave-ptr). Same payload copy.
       * `unsafe { let y: [N]T = *p }` used to fall through to -2 → CG002.
       * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path. */
      unsafe {
        ly = pipeline_asm_ctx_layout(ctx);
      }
      if (ly == (0 as *u8)) {
        return 0 - 1;
      }
      unsafe {
        rc = pipe_asm_ctx_off_next_offset();
        next_off = pipe_load_i32_le(ly, rc);
      }
      if (next_off + 16 < next_off) {
        return 0 - 1;
      }
      next_off = next_off + 16;
      unsafe {
        rc = pipe_asm_ctx_off_next_offset();
        pipe_store_i32_le(ly, rc, next_off);
      }
      spill_off = next_off;
      unsafe {
        emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, src, ctx, ta);
      }
      if (emit_rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (esz > 8) {
        if (esz > 4096) {
          return 0 - 1;
        }
        total = n_arr * esz;
        if (total <= 0 || total > 4096) {
          return 0 - 1;
        }
        unsafe {
          rc = pipe_asm_ctx_off_next_offset();
          next_off = pipe_load_i32_le(ly, rc);
        }
        if (next_off + 32 < next_off) {
          return 0 - 1;
        }
        next_off = next_off + 16;
        src_spill = next_off;
        next_off = next_off + 16;
        dst_spill = next_off;
        unsafe {
          rc = pipe_asm_ctx_off_next_offset();
          pipe_store_i32_le(ly, rc, next_off);
        }
        unsafe {
          rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (sret_direct == 0) {
          unsafe {
            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        } else {
          unsafe {
        sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      }
          unsafe {
            rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, sret_home, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          if (foff != 0) {
            unsafe {
              rc = backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
          }
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, total, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        return 0;
      }
      unsafe {
        sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      }
      ai = 0;
      while (ai < n_arr) {
        unsafe {
          rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (ai * esz != 0) {
          unsafe {
            rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz == 1) {
          unsafe {
            rc = backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
          }
        } else if (esz == 8) {
          unsafe {
            rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
          }
        } else {
          unsafe {
            rc = backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
          }
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
        if (sret_direct == 0) {
          unsafe {
            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
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
        } else {
          unsafe {
            rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        unsafe {
          rc = backend_enc_pop_rax_arch(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (sret_direct == 0) {
          store_off = ai * esz;
        } else {
          store_off = foff + ai * esz;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, esz, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        ai = ai + 1;
      }
      return 0;
    }

    if (src_off >= 0) {
      if (esz > 8) {
        unsafe {
          ly = pipeline_asm_ctx_layout(ctx);
        }
        if (ly == (0 as *u8)) {
          return 0 - 1;
        }
        if (esz > 4096) {
          return 0 - 1;
        }
        total = n_arr * esz;
        if (total <= 0 || total > 4096) {
          return 0 - 1;
        }
        unsafe {
          rc = pipe_asm_ctx_off_next_offset();
          next_off = pipe_load_i32_le(ly, rc);
        }
        if (next_off + 32 < next_off) {
          return 0 - 1;
        }
        next_off = next_off + 16;
        src_spill = next_off;
        next_off = next_off + 16;
        dst_spill = next_off;
        unsafe {
          rc = pipe_asm_ctx_off_next_offset();
          pipe_store_i32_le(ly, rc, next_off);
        }
        unsafe {
          rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (sret_direct == 0) {
          unsafe {
            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        } else {
          unsafe {
        sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      }
          unsafe {
            rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, sret_home, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          if (foff != 0) {
            unsafe {
              rc = backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta);
            }
            if (rc != 0) {
              return 0 - 1;
            }
          }
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, total, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        return 0;
      }
      unsafe {
        sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      }
      ai = 0;
      while (ai < n_arr) {
        unsafe {
          rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (ai * esz != 0) {
          unsafe {
            rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        if (esz == 1) {
          unsafe {
            rc = backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
          }
        } else if (esz == 8) {
          unsafe {
            rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
          }
        } else {
          unsafe {
            rc = backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
          }
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
        if (sret_direct == 0) {
          unsafe {
            rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta);
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
        } else {
          unsafe {
            rc = backend_enc_load_rbp_to_rbx_arch(elf_ctx, sret_home, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        unsafe {
          rc = backend_enc_pop_rax_arch(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (sret_direct == 0) {
          store_off = ai * esz;
        } else {
          store_off = foff + ai * esz;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, esz, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        ai = ai + 1;
      }
      return 0;
    }

    return 0 - 2;
  }
}
