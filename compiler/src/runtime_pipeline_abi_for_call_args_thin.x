// Thin authority for pipeline_asm_emit_expr_elf_for_call_args.
// Body is the wave216 freestanding CALL-arg packer, restored into this
// thin after wave711 left only export extern in the mega. The whole body
// sits in one unsafe block because each callee is export extern.
// Locals, the while copy, and the (n + 7) / 8 alignment stay as that body
// wrote them. Do not gcc -E this file. Do not PREFER the object into
// runtime_pipeline_abi.o.
// PLATFORM: SHARED freestanding. LINUX gold. MACOS.

export extern function asm_ctx_scope_block_ref_at(ctx: *u8): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rdx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32;
export extern function glue_asm_resolve_call_target_module_c(arena: *u8, call_expr_ref: i32, mod_out: *u8, func_ix_out: *i32, dep_ix_out: *i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_call_arg_var_use_lea_not_load_elf_c(arena: *u8, expr_ref: i32, ctx: *u8): i32;
export extern function glue_call_param_named_struct_pass_addr_elf_c(arena: *u8, pty: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function glue_emit_func_param_is_indirect_array_slot_c(arena: *u8, mod: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, var_off: i32, ctx: *u8, ta: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_load_f32_var_slot_to_rax_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, var_expr_ref: i32, off: i32, ta: i32): i32;
export extern function glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, var_expr_ref: i32, off: i32, ta: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_slice_dual_gp_bump_past_home_c(ctx: *u8, data_home: i32, ta: i32): void;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, home: i32, ty_ref: i32, use_frame: i32): i32;
export extern function glue_try_index_var_or_field_base_to_rax_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_type_is_fixed_array(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipeline_asm_abi_f32_xmm_enabled_c(): i32;
export extern function pipeline_asm_bump_next_offset_for_array_lit(arena: *u8, expr_ref: i32, ctx: *u8): void;
export extern function pipeline_asm_call_return_type_kind_ord_c(arena: *u8, call_expr_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_force_esz_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function pipeline_asm_emit_ctx_call_param_ty_get(): i32;
export extern function pipeline_asm_emit_dep_pipe_c(): *u8;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_block_resolve_var_type_ref(arena: *u8, block_ref: i32, vname: *u8, vlen: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out64: *u8): void;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_module_func_return_type_at(mod: *u8, fi: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_typeck_get_dep_return_type_in_caller_arena_c(from_dep_index: i32, dep_return_type_ref: i32, caller_arena: *u8, ctx: *u8): i32;

/**
 * Emit one CALL/METHOD formal argument into rax (or dual-GP / lea fat*).
 *
 * Routes by expr kind + formal (call_param_ty) vs resolved type:
 * f32 lit; VAR fixed-array→slice fat; VAR lea vs dual-GP load; FIELD
 * array→slice / array formal / named-struct pass-addr; INDEX of
 * `[K][N]T` / `[][N]T` → slice fat (scaled lea + length N); ARRAY_LIT→slice;
 * ARRAY_LIT→SIMD ≤16B (i32x4 / f32x4) dual-GP; CALL/METHOD returning
 * array or slice as slice* formal; identity ARRAY/SLICE ascription peel;
 * else rec.
 *
 * @param arena *u8 — ASTArena*; null skips typed routes (rec may still run)
 * @param elf_ctx *u8 — ElfCodegenCtx*; null → -1 on routes that encode
 * @param expr_ref i32 — call-arg expression ref
 * @param ctx *u8 — AsmFuncCtx*; null skips stack-home routes
 * @param ta i32 — 0=x86_64 SysV high-end; 1=arm64 AAPCS64 low-end
 * @return i32 — 0 success; -1 enc / gate fail
 *
 * wave216 pure: G.7 authority (was Cap residual call_args mega entry).
 * PLATFORM: SHARED freestanding · LINUX gold + MACOS|ARM64 co-path.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_for_call_args(
    arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
  let pty: i32 = 0;
  let call_abi_widen_f64: i32 = 1;
  let tr: i32 = 0;
  let ko: i32 = 0;
  let off: i32 = 0;
  let vlen: i32 = 0;
  let vname: u8[256] = [];
  let want_slice: i32 = 0;
  let arg_ty: i32 = 0;
  let decl_ty: i32 = 0;
  let arr_sz: i32 = 0;
  let scope_br: i32 = 0;
  let home: i32 = 0;
  let base_off: i32 = 0;
  let rc: i32 = 0;
  let emit_mod: *u8 = 0 as *u8;
  let fty: i32 = 0;
  let rty: i32 = 0;
  let want_arr: i32 = 0;
  let is_arr: i32 = 0;
  let br: i32 = 0;
  let use_lea: i32 = 0;
  let slice_ty: i32 = 0;
  let n_arr: i32 = 0;
  let force_esz: i32 = 0;
  let durable: i32 = 0;
  let esz: i32 = 4;
  let payload_bytes: i32 = 0;
  let past: i32 = 0;
  let ret_kind: i32 = 0 - 1;
  let rmod: *u8 = 0 as *u8;
  let rfi: i32 = 0 - 1;
  let rdep: i32 = 0 - 1;
  let rrty: i32 = 0;
  let mapped: i32 = 0;
  let mod_slot: u8[8] = [];
  let fi_slot: i32[1] = [];
  let dep_slot: i32[1] = [];
  let dep_pipe: *u8 = 0 as *u8;
  let spill_off: i32 = 0;
  let payload_off: i32 = 0;
  let ai: i32 = 0;
  let elem_tr: i32 = 0;
  let simd_ty: i32 = 0;
  let lanes: i32 = 0;
  let vec_nbytes: i32 = 0;
  let vec_reserve: i32 = 0;
  // Kind ords (ast_ExprKind / TypeKind single authority).
  let kind_int_lit: i32 = 1;
  let kind_var: i32 = 3;
  let kind_field: i32 = 44;
  let kind_array_lit: i32 = 46;
  let kind_index: i32 = 47;
  let kind_call: i32 = 48;
  let kind_method: i32 = 49;
  let type_array: i32 = 10;
  let type_slice: i32 = 11;
  let type_f32: i32 = 14; // GLUE_TYPE_KIND_F32_ORD
  let array_lit_max: i32 = 1024;

  // XLANG_ABI_F32_XMM=1 → native f32 bits; else legacy f64 widen via gp.
  {
    let f32_xmm: i32 = 0;
    unsafe { f32_xmm = pipeline_asm_abi_f32_xmm_enabled_c(); }
    if (f32_xmm != 0) {
      call_abi_widen_f64 = 0;
    } else {
      call_abi_widen_f64 = 1;
    }
  }

  // --- f32 INT_LIT / float lit as f32 formal ---
  if (arena != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_int_lit) {
      unsafe { tr = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (tr > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, tr); }
        if (rc == type_f32) {
          return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, tr, call_abi_widen_f64);
        }
      }
      unsafe { pty = pipeline_asm_emit_ctx_call_param_ty_get(); }
      if (pty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_f32) {
          return glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, pty, call_abi_widen_f64);
        }
      }
    }
  }

  unsafe { pty = pipeline_asm_emit_ctx_call_param_ty_get(); }

  // Identity ARRAY/SLICE ascription: take(a as [2]i32) must see VAR/INDEX.
  // G.7 reuse glue_peel. Scalar 5 as i32 stays wrapped.
  // PLATFORM: SHARED freestanding.
  if (arena != (0 as *u8) && expr_ref > 0) {
    unsafe { br = glue_peel_as_array_slice_ascription_c(arena, expr_ref); }
    if (br > 0) {
      expr_ref = br;
    }
  }

  // --- VAR local stack home packing ---
  if (arena != (0 as *u8) && ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_var) {
      off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
      if (off >= 0) {
        unsafe { vlen = pipeline_expr_var_name_len(arena, expr_ref); }
        if (vlen > 0 && vlen <= 63) {
          unsafe { pipeline_expr_var_name_into(arena, expr_ref, &vname[0]); }
          // wave395: fixed TYPE_ARRAY local as TYPE_SLICE formal → dual-GP fat + lea.
          want_slice = 0;
          if (pty > 0) {
            unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
            if (rc == type_slice) { want_slice = 1; }
          }
          unsafe { arg_ty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
          decl_ty = 0;
          unsafe { scope_br = asm_ctx_scope_block_ref_at(ctx); }
          if (scope_br > 0) {
            unsafe { decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, &vname[0], vlen); }
          }
          if (decl_ty <= 0) { decl_ty = arg_ty; }
          arr_sz = 0;
          if (decl_ty > 0 && glue_type_is_fixed_array(arena, decl_ty) != 0) {
            unsafe { arr_sz = pipeline_type_array_size_at(arena, decl_ty); }
          }
          if (arr_sz <= 0 && arg_ty > 0) {
            unsafe { rc = pipeline_type_kind_ord_at(arena, arg_ty); }
            if (rc == type_array) {
              unsafe { arr_sz = pipeline_type_array_size_at(arena, arg_ty); }
            }
          }
          if (want_slice != 0 && arr_sz > 0) {
            if (elf_ctx == (0 as *u8)) { return 0 - 1; }
            base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
            home = base_off + 16;
            if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
            else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
            glue_align_next_offset(ctx);
            unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            return 0;
          }
          if (glue_call_arg_var_use_lea_not_load_elf_c(arena, expr_ref, ctx) != 0) {
            unsafe { return backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta); }
          }
          if (pty > 0) {
            unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
            if (rc == type_f32) {
              return glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
            }
          }
          // wave417: T[N] formal home is E* — load pointer only.
          emit_mod = pipeline_asm_emit_module_ref_c();
          if (emit_mod != (0 as *u8) && glue_emit_func_param_is_indirect_array_slot_c(arena, emit_mod, expr_ref) != 0) {
            unsafe { return backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta); }
          }
          // TYPE_SLICE formal: fat* via local_slot ptr-or-addr (wave401).
          {
            let tk_pty: i32 = 0;
            let tk_arg: i32 = 0;
            if (pty > 0) {
              unsafe { tk_pty = pipeline_type_kind_ord_at(arena, pty); }
            }
            if (arg_ty > 0) {
              unsafe { tk_arg = pipeline_type_kind_ord_at(arena, arg_ty); }
            }
            if (tk_pty == type_slice || tk_arg == type_slice) {
              return glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, expr_ref, off, ctx, ta);
            }
          }
          return glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx, arena, ctx, expr_ref, off, ta);
        }
      }
    }
  }

  // --- FIELD_ACCESS fixed TYPE_ARRAY as TYPE_SLICE formal (wave396/649) ---
  if (arena != (0 as *u8) && ctx != (0 as *u8) && elf_ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      want_slice = 0;
      if (pty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { want_slice = 1; }
      }
      if (want_slice != 0) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        arr_sz = 0;
        if (fty > 0 && glue_type_is_fixed_array(arena, fty) != 0) {
          unsafe { arr_sz = pipeline_type_array_size_at(arena, fty); }
        }
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (arr_sz <= 0 && rty > 0) {
          unsafe { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) {
            unsafe { arr_sz = pipeline_type_array_size_at(arena, rty); }
          }
        }
        if (arr_sz > 0) {
          base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
          if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
          home = base_off + 16;
          if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
          else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
          glue_align_next_offset(ctx);
          br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
          if (br != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
          if (rc != 0) { return 0 - 1; }
          return 0;
        }
      }
    }
  }

  // --- INDEX of [K][N]T / [][N]T as TYPE_SLICE formal ---
  // take(a[i]): N+esz from INDEX resolved TYPE_ARRAY, else base elem.
  // lea via scaled (do not emit_index — dest-SLICE stamp would load a 16B fat).
  // Caller-frame fat* in rax. PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
  if (arena != (0 as *u8) && ctx != (0 as *u8) && elf_ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_index) {
      want_slice = 0;
      if (pty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { want_slice = 1; }
      }
      if (want_slice != 0) {
        arr_sz = 0;
        force_esz = 0;
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (rty > 0) {
          unsafe { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) {
            unsafe { arr_sz = pipeline_type_array_size_at(arena, rty); }
            force_esz = glue_fixed_array_total_bytes_c(arena, rty, 0);
          }
        }
        if (arr_sz <= 0 || force_esz <= 0) {
          unsafe { br = pipeline_expr_index_base_ref(arena, expr_ref); }
          if (br > 0) {
            unsafe { fty = pipeline_expr_resolved_type_ref(arena, br); }
            if (fty > 0) {
              unsafe { rc = pipeline_type_kind_ord_at(arena, fty); }
              if (rc == type_array || rc == type_slice) {
                unsafe { fty = pipeline_type_elem_ref_at(arena, fty); }
                if (fty > 0) {
                  unsafe { rc = pipeline_type_kind_ord_at(arena, fty); }
                  if (rc == type_array) {
                    unsafe { arr_sz = pipeline_type_array_size_at(arena, fty); }
                    force_esz = glue_fixed_array_total_bytes_c(arena, fty, 0);
                  }
                }
              }
            }
          }
        }
        if (arr_sz > 0 && force_esz > 0) {
          unsafe { br = pipeline_expr_index_base_ref(arena, expr_ref); }
          unsafe { n_arr = pipeline_expr_index_index_ref(arena, expr_ref); }
          if (br > 0 && n_arr > 0) {
            base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
            if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
            home = base_off + 16;
            if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
            else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
            glue_align_next_offset(ctx);
            unsafe {
              rc = glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, br, n_arr, ctx, ta, force_esz);
            }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
            if (rc != 0) { return 0 - 1; }
            unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
            return 0;
          }
        }
      }
    }
  }

  // --- FIELD_ACCESS fixed TYPE_ARRAY as TYPE_ARRAY formal E* (wave610/651) ---
  if (arena != (0 as *u8) && ctx != (0 as *u8) && elf_ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      want_arr = 0;
      if (pty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_array || glue_type_is_fixed_array(arena, pty) != 0) { want_arr = 1; }
      }
      if (want_arr != 0) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        is_arr = 0;
        if (fty > 0 && glue_type_is_fixed_array(arena, fty) != 0) { is_arr = 1; }
        unsafe { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
        if (is_arr == 0 && rty > 0) {
          unsafe { rc = pipeline_type_kind_ord_at(arena, rty); }
          if (rc == type_array) { is_arr = 1; }
        }
        if (is_arr != 0) {
          br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
          if (br == 0) { return 0; }
          if (br == (0 - 1)) { return 0 - 1; }
          // -2: fall through
        }
      }
    }
  }

  // --- FIELD_ACCESS named struct pass-by-addr (>16B MEMORY) ---
  if (arena != (0 as *u8) && ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_field) {
      use_lea = 0;
      if (pty > 0 && glue_call_param_named_struct_pass_addr_elf_c(arena, pty) != 0) { use_lea = 1; }
      if (use_lea == 0) {
        emit_mod = pipeline_asm_emit_module_ref_c();
        fty = glue_field_access_field_type_ref_c(arena, emit_mod, expr_ref);
        if (fty > 0 && glue_call_param_named_struct_pass_addr_elf_c(arena, fty) != 0) { use_lea = 1; }
      }
      if (use_lea != 0) {
        return pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      }
    }
  }

  // --- ARRAY_LIT as TYPE_SLICE formal (wave332/622/625) ---
  if (arena != (0 as *u8) && ctx != (0 as *u8) && elf_ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_array_lit) {
      slice_ty = 0;
      if (pty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { slice_ty = pty; }
      }
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (slice_ty == 0 && rty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, rty); }
        if (rc == type_slice) { slice_ty = rty; }
      }
      if (slice_ty > 0) {
        let et: i32 = 0;
        unsafe { n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref); }
        if (n_arr < 0 || n_arr > array_lit_max) { return 0 - 1; }
        unsafe { et = pipeline_type_elem_ref_at(arena, slice_ty); }
        force_esz = glue_array_lit_force_esz_from_elem_type_c(arena, et);
        base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
        home = base_off + 16;
        esz = 4;
        if (force_esz > 0) { esz = force_esz; }
        if (ta == 1) { past = home + 16; } else { past = home + 8; }
        payload_bytes = n_arr * esz;
        if (payload_bytes < 0) { payload_bytes = 0; }
        if (payload_bytes > 0 && home + payload_bytes > past) { past = home + payload_bytes; }
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), past);
        glue_align_next_offset(ctx);
        durable = 0;
        if ((ta == 0 || ta == 1) && glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, expr_ref, force_esz, ta, ctx, et) == 0) {
          durable = 1;
        } else {
          if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, expr_ref, ctx, ta, force_esz) != 0) {
            return 0 - 1;
          }
        }
        unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
        if (rc != 0) { return 0 - 1; }
        if (durable == 0 && n_arr > 0) {
          pipeline_asm_bump_next_offset_for_array_lit(arena, expr_ref, ctx);
        }
        glue_slice_dual_gp_bump_past_home_c(ctx, home, ta);
        unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        return 0;
      }
      /*
       * ARRAY_LIT as SIMD/VECTOR formal (i32x4 / f32x4 / NAMED spelling).
       * G.7 complete of this function's ARRAY_LIT family: slice route is
       * above; rec would lea a stack array (pointer in rax) while the
       * callee expects 9–16B INTEGER dual-GP (same as VAR i32x4).
       * Reuse glue_emit_vector_type_let_init (let `a: i32x4 = [lit]`).
       * METHOD receiver also enters here with pty often unset — also
       * accept resolved SIMD stamp. >16B (i32x8) stays rec / MEMORY.
       * PLATFORM: SHARED freestanding · LINUX+MACOS x86 high-end ·
       * MACOS|ARM64 AAPCS64 low-end (same polarity as vector let-init).
       */
      simd_ty = 0;
      if (pty > 0) {
        unsafe { rc = asm_type_is_simd_vector_spelling(arena, pty); }
        if (rc != 0) { simd_ty = pty; }
      }
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (simd_ty == 0 && rty > 0) {
        unsafe { rc = asm_type_is_simd_vector_spelling(arena, rty); }
        if (rc != 0) { simd_ty = rty; }
      }
      if (simd_ty > 0) {
        lanes = 0;
        esz = 0;
        if (glue_vector_type_lanes_esz_c(arena, simd_ty, &lanes, &esz) != 0) {
          return 0 - 1;
        }
        if (lanes <= 0 || esz <= 0) { return 0 - 1; }
        vec_nbytes = lanes * esz;
        if (vec_nbytes > 0 && vec_nbytes <= 16) {
          vec_reserve = (vec_nbytes + 7) & (0 - 8);
          if (vec_reserve < 8) { vec_reserve = 8; }
          base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
          if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
          if (ta == 1) {
            home = base_off;
            pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), base_off + vec_reserve);
          } else {
            home = base_off + vec_reserve;
            pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home);
          }
          glue_align_next_offset(ctx);
          if (glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, expr_ref, ctx, ta, home, simd_ty) != 0) {
            return 0 - 1;
          }
          if (vec_nbytes > 8) {
            if (ta == 1) {
              unsafe { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home + 8, ta); }
              if (rc != 0) { return 0 - 1; }
              unsafe { rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta); }
              if (rc != 0) { return 0 - 1; }
              unsafe { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta); }
              if (rc != 0) { return 0 - 1; }
            } else {
              unsafe { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta); }
              if (rc != 0) { return 0 - 1; }
              unsafe { rc = backend_enc_load_rbp_to_rdx_arch(elf_ctx, home - 8, ta); }
              if (rc != 0) { return 0 - 1; }
            }
          } else {
            unsafe { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta); }
            if (rc != 0) { return 0 - 1; }
          }
          return 0;
        }
      }
    }
  }

  // --- CALL/METHOD returning slice or fixed array as slice* formal ---
  if (arena != (0 as *u8) && ctx != (0 as *u8) && elf_ctx != (0 as *u8)) {
    unsafe { ko = pipeline_expr_kind_ord_at(arena, expr_ref); }
    if (ko == kind_call || ko == kind_method) {
      slice_ty = 0;
      if (pty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, pty); }
        if (rc == type_slice) { slice_ty = pty; }
      }
      unsafe { rty = pipeline_expr_resolved_type_ref(arena, expr_ref); }
      if (slice_ty == 0 && rty > 0) {
        unsafe { rc = pipeline_type_kind_ord_at(arena, rty); }
        if (rc == type_slice) { slice_ty = rty; }
      }
      arr_sz = 0;
      ret_kind = 0 - 1;
      if (rty > 0 && glue_type_is_fixed_array(arena, rty) != 0) {
        unsafe { arr_sz = pipeline_type_array_size_at(arena, rty); }
        ret_kind = type_array;
      }
      if (arr_sz <= 0 && slice_ty > 0) {
        // Resolve callee return type (may be TYPE_ARRAY while resolved is PTR).
        fi_slot[0] = 0 - 1;
        dep_slot[0] = 0 - 1;
        pipe_store_ptr_slot(&mod_slot[0], 0, 0 as *u8);
        if (glue_asm_resolve_call_target_module_c(arena, expr_ref, &mod_slot[0], &fi_slot[0], &dep_slot[0]) == 0) {
          rmod = pipe_load_ptr_slot(&mod_slot[0], 0);
          rfi = fi_slot[0];
          rdep = dep_slot[0];
          if (rmod != (0 as *u8) && rfi >= 0) {
            unsafe { rrty = pipeline_module_func_return_type_at(rmod, rfi); }
            if (rrty > 0 && rdep >= 0) {
              dep_pipe = pipeline_asm_emit_dep_pipe_c();
              if (dep_pipe != (0 as *u8)) {
                unsafe { mapped = pipeline_typeck_get_dep_return_type_in_caller_arena_c(rdep, rrty, arena, dep_pipe); }
                if (mapped > 0) { rrty = mapped; }
              }
            }
            if (rrty > 0) {
              {
                let tk_rr: i32 = 0;
                unsafe { tk_rr = pipeline_type_kind_ord_at(arena, rrty); }
                if (glue_type_is_fixed_array(arena, rrty) != 0 || tk_rr == type_array) {
                unsafe { arr_sz = pipeline_type_array_size_at(arena, rrty); }
                ret_kind = type_array;
                if (rty <= 0 || glue_type_is_fixed_array(arena, rty) == 0) { rty = rrty; }
                } else {
                unsafe { ret_kind = pipeline_type_kind_ord_at(arena, rrty); }
                }
              }
            }
          }
        }
      }
      if (ret_kind < 0 && rty > 0) {
        unsafe { ret_kind = pipeline_type_kind_ord_at(arena, rty); }
      }
      if (ret_kind < 0) {
        ret_kind = pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref);
      }
      // wave404: TYPE_ARRAY return → slice* formal with caller-frame payload copy.
      if (slice_ty > 0 && arr_sz > 0) {
        esz = 4;
        if (rty > 0) {
          unsafe { elem_tr = pipeline_type_elem_ref_at(arena, rty); }
          if (elem_tr > 0) {
            esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
            if (esz <= 0) { esz = 4; }
          }
        }
        base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
        spill_off = base_off + 8;
        home = spill_off + 16;
        if (ta == 1) {
          payload_off = home + 16;
          past = payload_off + arr_sz * esz;
        } else {
          payload_off = home + arr_sz * esz;
          if (payload_off < home + 8) { payload_off = home + 8; }
          if ((payload_off % 8) != 0) { payload_off = (payload_off + 7) / 8 * 8; }
          past = payload_off;
          if (past < home + 8) { past = home + 8; }
        }
        if (past < payload_off || past < home) { return 0 - 1; }
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), past);
        glue_align_next_offset(ctx);
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta); }
        if (rc != 0) { return 0 - 1; }
        ai = 0;
        while (ai < arr_sz) {
          unsafe { rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta); }
          if (rc != 0) { return 0 - 1; }
          if (ai * esz != 0) {
            unsafe { rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta); }
            if (rc != 0) { return 0 - 1; }
          }
          if (esz == 1) {
            unsafe { rc = backend_enc_load_zext8_from_rax_arch(elf_ctx, ta); }
          } else {
            if (esz == 8) {
              unsafe { rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta); }
            } else {
              unsafe { rc = backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta); }
            }
          }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_push_rax_arch(elf_ctx, ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, payload_off, ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_pop_rax_arch(elf_ctx, ta); }
          if (rc != 0) { return 0 - 1; }
          unsafe { rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta); }
          if (rc != 0) { return 0 - 1; }
          ai = ai + 1;
        }
        unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, payload_off, ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        return 0;
      }
      // True TYPE_SLICE return → dual-GP fat + reent deep-copy (use_frame=0 COMMON).
      if (slice_ty > 0) {
        base_off = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if ((base_off % 8) != 0) { base_off = (base_off + 7) / 8 * 8; }
        home = base_off + 16;
        if (ta == 1) { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 16); }
        else { pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), home + 8); }
        glue_align_next_offset(ctx);
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        unsafe { rc = backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta); }
        if (rc != 0) { return 0 - 1; }
        if (glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(arena, elf_ctx, ctx, ta, home, slice_ty, 0) != 0) {
          return 0 - 1;
        }
        unsafe { rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta); }
        if (rc != 0) { return 0 - 1; }
        return 0;
      }
    }
  }

  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
