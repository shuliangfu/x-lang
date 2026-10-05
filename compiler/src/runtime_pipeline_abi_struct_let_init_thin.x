/**
 * runtime_pipeline_abi_struct_let_init_thin.x — let_init winner only (w2060 A1).
 *
 * Only glue_emit_struct_type_let_init_elf_c lives here. fields / lit /
 * struct_let_init stay in leftover pabi (extern). Their .x bodies are
 * archived under /tmp/w1004/w2061_sret/fields_frags/ for w2061 sret root-fix.
 * PLATFORM: MACOS|DARWIN, WINDOWS.
 */
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_func: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf: *u8, off: i32, ta: i32): i32;
export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_arm64_mov_x0_to_x8_elf_c(elf: *u8): i32;
export extern function glue_arm64_mov_x19_to_x0_elf_c(elf_ctx: *u8): i32;
export extern function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_call_return_byte_size_c(arena: *u8, call_expr_ref: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32): i32;
export extern function glue_emit_if_arm_dest_in_rbx_elf_c(arena: *u8, elf_ctx: *u8, arm_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, dest_spill: i32): i32;
export extern function glue_emit_match_dest_in_rbx_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, ty_ref: i32, dest_spill: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_enc_jz_after_bool_in_eax(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function glue_field_layout_offset_for_var_base_field(a: *u8, m: *u8, base_var_ref: i32, field_name: *u8, flen: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function glue_store_retval_pair_to_rbp_elf_c(m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_set(off: i32): void;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, lval_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function pipeline_asm_emit_set_call_sret_reg_shift_c(shift: i32): void;
export extern function pipeline_asm_set_call_expected_ret_ty_c(ty: i32): void;
export extern function pipeline_codegen_match_matched_ref_c(): i32;
export extern function pipeline_codegen_match_name_is_subject_field_c(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_expr_if_cond_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_else_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_if_then_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(a: *u8, er: i32): i32;
export extern function pipeline_expr_resolved_type_ref(a: *u8, er: i32): i32;
export extern function pipeline_expr_var_name_into(a: *u8, er: i32, out: *u8): void;
export extern function pipeline_expr_var_name_len(a: *u8, er: i32): i32;
export extern function try_inline_const_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function try_inline_struct_lit_return_call_to_slot_elf(arena: *u8, elf_ctx: *u8, call_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function backend_enc_add_imm_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_qword_from_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_qword_rbx8_to_rdx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function glue_arm64_add_imm_to_x19_elf_c(elf_ctx: *u8, imm: i32): i32;
export extern function glue_asm_max_struct_lit_fields(): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx: *u8, sz: i32, ta: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32, type_ref: i32): i32;
export extern function glue_struct_field_frame_mag_c(base_off: i32, foff: i32, ta: i32): i32;
export extern function glue_struct_lit_dest_in_rbx(): i32;
export extern function glue_struct_lit_field_store_sz(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function glue_struct_lit_rehome_cpu_stack(): i32;
export extern function glue_struct_lit_rehome_dest_rbx_elf_c(elf_ctx: *u8, rehome_off: i32, ta: i32): i32;
export extern function glue_struct_lit_store_fixed_array_field_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, sret_direct: i32, base_off: i32, foff: i32, fty: i32): i32;
export extern function glue_type_is_empty_struct_c(module: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_struct_lit_field_offset_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern function pipeline_expr_struct_lit_field_type_ref_at(a: *u8, m: *u8, expr_ref: i32, field_ix: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, j: i32): i32;
export extern function pipeline_expr_struct_lit_num_fields(a: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_value_bytes(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;

export extern function pipeline_asm_emit_struct_lit_fields_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;
export extern function pipeline_asm_emit_struct_lit_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_struct_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32): i32;

#[no_mangle]
export function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32 {
  // The wave713 body called externs outside unsafe (legacy pabi mode).
  unsafe {
  let ko: i32 = 0;
  let inl: i32 = 0;
  let emit_rc: i32 = 0;
  let call_ret_sz: i32 = 0;
  let let_sz: i32 = 0;
  let named_sz: i32 = 0;
  let best: i32 = 0;
  let src_off: i32 = 0;
  let ty_ref: i32 = 0;
  let dest_in_rbx: i32 = 0;
  let dest_spill: i32 = 0;
  let src_spill: i32 = 0;
  let parked: i32 = 0;
  let bind_name: u8[256] = [];
  let bind_len: i32 = 0;
  let bind_mref: i32 = 0;
  let bind_foff: i32 = 0;
  let bind_ko: i32 = 0;
  let modp: *u8 = 0 as *u8;
  let rc: i32 = 0;
  let if_cond: i32 = 0;
  let if_then: i32 = 0;
  let if_else: i32 = 0;
  let else_lbl: u8[256] = [];
  let done_lbl: u8[256] = [];
  let else_len: i32 = 0;
  let done_len: i32 = 0;
  let arm_rc: i32 = 0;
  let saved_sret_home: i32 = 0;
  if (arena == 0 as *u8 || elf_ctx == 0 as *u8 || ctx == 0 as *u8 || init_ref <= 0) {
    return 0 - 2;
  }
  // DEST_IN_RBX = -3 (same token as glue_struct_lit_dest_in_rbx).
  if (stack_slot_off == (0 - 3)) {
    dest_in_rbx = 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  // STRUCT_LIT → field write into slot
  if (ko == 45) {
    return pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  }
  /* dest-in-rbx IF / ternary (`*p = if (c) { w } else { y }`).
   * emit_expr of the then-arm VAR is 8B; dest store leftover lane2
   * (Darwin 12). Frame dest stays on emit_expr + store_retval_pair.
   * G.7: same dest-in-rbx let-init as dest-in-rbx VAR / FIELD / CALL.
   * Do not emit_if_arm (8B). Do not open the x19 prologue.
   * PLATFORM: SHARED dest-in-rbx IF · MACOS|ARM64 dest-shadow. */
  if ((ko == 25 || ko == 27) && dest_in_rbx != 0 && (ta == 0 || ta == 1)) {
    ty_ref = let_ty_ref;
    if (ty_ref <= 0) {
      unsafe {
        ty_ref = pipeline_expr_resolved_type_ref(arena, init_ref);
      }
    }
    if (ty_ref <= 0) {
      return 0 - 2;
    }
    unsafe {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, ty_ref, 0);
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
    }
    if (named_sz > let_sz) {
      let_sz = named_sz;
    }
    if (let_sz < 8) {
      return 0 - 2;
    }
    unsafe {
      if_cond = pipeline_expr_if_cond_ref_at(arena, init_ref);
      if_then = pipeline_expr_if_then_ref_at(arena, init_ref);
      if_else = pipeline_expr_if_else_ref_at(arena, init_ref);
    }
    if (if_cond <= 0 || if_then <= 0) {
      return 0 - 1;
    }
    /* Park dest before cond. dest-in-rbx STRUCT_LIT push_rbx is
     * ARM64 x1; emit_expr cond clobbers x1 (and x86 rbx). dest
     * lives in x19 after mov_rax_to_rbx. G.7: same 8B park as
     * dest-in-rbx CALL. Do not push_rbx. Do not open x19 prologue.
     * PLATFORM: SHARED dest-in-rbx IF · MACOS|ARM64 dest-shadow. */
    glue_align_next_offset(ctx);
    dest_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
    if (ta == 1) {
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill + 8);
    } else {
      dest_spill = dest_spill + 8;
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill);
    }
    if (ta == 1) {
      rc = glue_arm64_mov_x19_to_x0_elf_c(elf_ctx);
    } else {
      unsafe {
        rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dest_spill, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, if_cond, ctx, ta);
    }
    if (emit_rc != 0) {
      return 0 - 1;
    }
    unsafe {
      else_len = pipeline_asm_emit_next_label_c(ctx, &else_lbl[0], 64);
      done_len = pipeline_asm_emit_next_label_c(ctx, &done_lbl[0], 64);
    }
    if (else_len <= 0 || done_len <= 0) {
      return 0 - 1;
    }
    if (if_else != 0) {
      unsafe {
        rc = glue_enc_jz_after_bool_in_eax(elf_ctx, &else_lbl[0], else_len, ta);
      }
    } else {
      unsafe {
        rc = glue_enc_jz_after_bool_in_eax(elf_ctx, &done_lbl[0], done_len, ta);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dest_spill, ta);
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
    arm_rc = glue_emit_if_arm_dest_in_rbx_elf_c(arena, elf_ctx, if_then, ctx, ta, ty_ref, dest_spill);
    if (arm_rc != 0) {
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
    if (if_else != 0) {
      unsafe {
        rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dest_spill, ta);
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
      arm_rc = glue_emit_if_arm_dest_in_rbx_elf_c(arena, elf_ctx, if_else, ctx, ta, ty_ref, dest_spill);
      if (arm_rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = backend_enc_label_arch(elf_ctx, &done_lbl[0], done_len, 0, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  /* dest-in-rbx MATCH (`*p = match tag { 1 => w; _ => y }`) and
   * frame dest 16B MATCH field-bind (`let r: Holder = match w {
   * Wrap { h } => h }`). emit_match → emit_expr_if_arm of VAR
   * `h` is 8B (Darwin leftover 11). dest-in-rbx MATCH already
   * dest-in-rbx let-init each arm. G.7: frame dest 9B+ leas the
   * let slot into rbx/x19 then the same helper. i32 MATCH stays
   * emit_expr (let_sz < 9). Do not change emit_match.
   * PLATFORM: SHARED dest-in-rbx MATCH · MACOS|ARM64 dest-shadow. */
  if (ko == 43 && (ta == 0 || ta == 1)) {
    ty_ref = let_ty_ref;
    if (ty_ref <= 0) {
      unsafe {
        ty_ref = pipeline_expr_resolved_type_ref(arena, init_ref);
      }
    }
    if (ty_ref <= 0) {
      return 0 - 2;
    }
    unsafe {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, ty_ref, 0);
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
    }
    if (named_sz > let_sz) {
      let_sz = named_sz;
    }
    if (let_sz < 8) {
      return 0 - 2;
    }
    if (dest_in_rbx == 0) {
      if (let_sz < 9 || stack_slot_off < 0) {
        return 0 - 2;
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
    }
    glue_align_next_offset(ctx);
    dest_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
    if (ta == 1) {
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill + 8);
    } else {
      dest_spill = dest_spill + 8;
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill);
    }
    if (ta == 1) {
      rc = glue_arm64_mov_x19_to_x0_elf_c(elf_ctx);
    } else {
      unsafe {
        rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dest_spill, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return glue_emit_match_dest_in_rbx_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, ty_ref, dest_spill);
  }
  // CALL (48) or METHOD_CALL (49): try_inline param/const twins, then sret / dual-GP.
  // G.7: METHOD shares the inliner (body already accepts 49). Do not CALL-only the gate.
  if (ko == 48 || ko == 49) {
    // dest-in-rbx: try_inline would lea rbp-3. Skip; sret / dual-GP below.
    if (dest_in_rbx == 0) {
      unsafe {
        inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      }
      if (inl == 1) {
        return 0;
      }
      unsafe {
        inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      }
      if (inl == 1) {
        return 0;
      }
    }
    // Install let decl type as expected return for import overload mangle.
    if (let_ty_ref > 0) {
      unsafe {
        pipeline_asm_set_call_expected_ret_ty_c(let_ty_ref);
      }
    } else {
      unsafe {
        pipeline_asm_set_call_expected_ret_ty_c(0);
      }
    }
    unsafe {
      call_ret_sz = glue_call_return_byte_size_c(arena, init_ref);
    }
    // Prefer call return size; widen from let annotation when call ret is weak.
    // Once callee return is register class (1..16), never let named_layout push into sret (>16).
    if (call_ret_sz <= 16 && let_ty_ref > 0) {
      unsafe {
        modp = glue_emit_module_from_ctx(ctx);
        let_sz = glue_type_size_simple(modp, arena, let_ty_ref, 0);
      }
      named_sz = 0;
      if (let_sz <= 16) {
        unsafe {
          named_sz = glue_type_named_layout_size_any_module_elf_c(arena, let_ty_ref);
        }
      }
      best = let_sz;
      if (named_sz > best) {
        if (call_ret_sz > 0 && call_ret_sz <= 16 && named_sz > 16) {
          // keep best — do not false-sret over a known register-class call ret
        } else {
          if (let_sz <= 4 || call_ret_sz <= 0 || named_sz <= 16) {
            best = named_sz;
          }
        }
      }
      if (best > call_ret_sz) {
        call_ret_sz = best;
      }
    }
    // >16B struct return into let slot (callee writes; no glue_store_retval).
    // SysV: hidden dest in rdi + GP arg shift. AAPCS64: dest in x8; no GP shift.
    // dest-in-rbx: dest already computed (pointer / INDEX FIELD); do not lea rbp-3.
    if (call_ret_sz > 16 && (ta == 0 || ta == 1)) {
      if (dest_in_rbx != 0) {
        unsafe {
          rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
        }
      } else {
        unsafe {
          rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
        }
      }
      if (rc != 0) {
        unsafe {
          pipeline_asm_set_call_expected_ret_ty_c(0);
        }
        return 0 - 1;
      }
      if (ta == 0) {
        unsafe {
          rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta);
        }
        if (rc != 0) {
          unsafe {
            pipeline_asm_set_call_expected_ret_ty_c(0);
          }
          return 0 - 1;
        }
        pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      } else {
        // AAPCS64: Indirect Result Location Register x8 (pure lea_common face).
        rc = glue_arm64_mov_x0_to_x8_elf_c(elf_ctx);
        if (rc != 0) {
          unsafe {
            pipeline_asm_set_call_expected_ret_ty_c(0);
          }
          return 0 - 1;
        }
      }
      /* 10.5.1 slice1: lang SIMD i32x8 try_emit reads let sret dest via sret_home_off. */
      saved_sret_home = pipeline_asm_emit_ctx_sret_home_off_get();
      if (dest_in_rbx == 0) {
        pipeline_asm_emit_ctx_sret_home_off_set(stack_slot_off);
      }
      unsafe {
        emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
      }
      if (dest_in_rbx == 0) {
        pipeline_asm_emit_ctx_sret_home_off_set(saved_sret_home);
      }
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      unsafe {
        pipeline_asm_set_call_expected_ret_ty_c(0);
      }
      if (emit_rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    /* dest-in-rbx ≤16B CALL: park dest before emit. Generated callees
     * use x19 as dest-shadow and the ARM64 prologue does not save it,
     * so dest is garbage after CALL (Darwin leftover 20 / 10).
     * G.7: same 8B park polarity as dest-in-rbx INDEX / VECTOR CALL dest.
     * Do not push_rbx (ARM64 x1). Do not open the x19 prologue.
     * PLATFORM: SHARED dest-in-rbx CALL · MACOS|ARM64 dest-shadow. */
    if (dest_in_rbx != 0) {
      glue_align_next_offset(ctx);
      dest_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
      if (ta == 1) {
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill + 8);
      } else {
        dest_spill = dest_spill + 8;
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill);
      }
      /* ARM64 dest lives in x19 (enc_mov_rax_to_rbx). mov_rbx_to_rax
       * is mov x0,x1 — after memcpy dest-in-rbx x1 is the src temp
       * (n>1 `[make_w, make_w]` parked dest+esz as garbage).
       * G.7: park from dest-shadow. Do not change mov_rbx_to_rax.
       * PLATFORM: MACOS|ARM64 dest-shadow. */
      if (ta == 1) {
        rc = glue_arm64_mov_x19_to_x0_elf_c(elf_ctx);
      } else {
        unsafe {
          rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
        }
      }
      if (rc != 0) {
        unsafe {
          pipeline_asm_set_call_expected_ret_ty_c(0);
        }
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dest_spill, ta);
      }
      if (rc != 0) {
        unsafe {
          pipeline_asm_set_call_expected_ret_ty_c(0);
        }
        return 0 - 1;
      }
    }
    // Scalar / ≤16B import CALL/METHOD_CALL: emit then store rax[+rdx].
    unsafe {
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    }
    unsafe {
      pipeline_asm_set_call_expected_ret_ty_c(0);
    }
    if (emit_rc != 0) {
      return 0 - 1;
    }
    if (dest_in_rbx != 0) {
      /* Return is in rax[+rdx]/x0[+x1]. dest is in dest_spill (x19
       * clobbered). Store the return to a frame temp (same polarity as
       * VECTOR CALL dest), restore dest, memcpy dest-in-rbx.
       * PLATFORM: SHARED dest-in-rbx CALL ret temp. */
      named_sz = call_ret_sz;
      if (named_sz < 8) {
        named_sz = 8;
      }
      glue_align_next_offset(ctx);
      src_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
      if (ta == 1) {
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill + named_sz);
      } else {
        src_spill = src_spill + named_sz;
        pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill);
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (call_ret_sz > 8) {
        unsafe {
          rc = backend_enc_store_rdx_to_rbp_arch(
              elf_ctx, glue_slice_dual_gp_length_off_c(src_spill, ta), ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      unsafe {
        rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dest_spill, ta);
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
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_spill, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, named_sz, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      /* memcpy dest-in-rbx leaves dest in x19 and src in x1. n>1
       * dest-in-rbx ARRAY_LIT also ADD X1 — resync x1 from x19.
       * mov_rax_to_rbx writes both x1 and x19.
       * PLATFORM: MACOS|ARM64 dest-shadow. */
      if (ta == 1) {
        rc = glue_arm64_mov_x19_to_x0_elf_c(elf_ctx);
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      return 0;
    }
    unsafe {
      modp = glue_emit_module_from_ctx(ctx);
      rc = glue_store_retval_pair_to_rbp_elf_c(modp, arena, elf_ctx, let_ty_ref, stack_slot_off, ta, init_ref, ctx);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  /* EXPR_VAR (3): slot-to-slot copy of a named struct.
   * Frame dest 9–16B: lea src + deref_struct16 + store_retval_pair
   * (same as FIELD frame dest). ARRAY_LIT `[w]` of a 16B named VAR
   * used to return -2; emit_expr then dual-GP-loads the VAR (hi in x1)
   * and store_rax_to_rbx_offset hits the clobbered dest (Darwin 139).
   * Frame dest ≤8B still -2 so scalar fall-through stays. Frame dest
   * >16B and dest-in-rbx ≥8B: lea src → rax then glue_copy (same
   * memcpy as CALL/INDEX *rax → slot). dest-in-rbx cannot use
   * deref_struct16 (mov_rax_to_rbx clobbers dest / x19). Do not
   * lower the frame dest ≤16 memcpy gate. Do not change FIELD
   * emit_expr. Do not change enc_store /8.
   * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
  if (ko == 3 && (ta == 0 || ta == 1)) {
    unsafe {
      src_off = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
    }
    bind_foff = 0;
    /* dest-in-rbx MATCH field-bind: `h` in `Wrap { h } => h`
     * is not a local. dest-in-rbx VAR used to return −2
     * (Darwin CG002). G.7: same subject.field lea as
     * glue_try_emit_match_subject_field_var, then dest-in-rbx
     * / frame memcpy. Do not change that helper (8B rax).
     * PLATFORM: SHARED dest-in-rbx MATCH field-bind. */
    if (src_off < 0) {
      unsafe {
        bind_len = pipeline_expr_var_name_len(arena, init_ref);
      }
      if (bind_len <= 0 || bind_len > 255) {
        return 0 - 2;
      }
      unsafe {
        pipeline_expr_var_name_into(arena, init_ref, &bind_name[0]);
        modp = glue_emit_module_from_ctx(ctx);
      }
      if (modp == 0 as *u8) {
        return 0 - 2;
      }
      if (pipeline_codegen_match_name_is_subject_field_c(modp, arena, &bind_name[0], bind_len) == 0) {
        return 0 - 2;
      }
      bind_mref = pipeline_codegen_match_matched_ref_c();
      if (bind_mref <= 0) {
        return 0 - 2;
      }
      unsafe {
        bind_ko = pipeline_expr_kind_ord_at(arena, bind_mref);
      }
      if (bind_ko != 3) {
        return 0 - 2;
      }
      bind_foff = glue_field_layout_offset_for_var_base_field(
          arena, modp, bind_mref, &bind_name[0], bind_len);
      if (bind_foff < 0) {
        return 0 - 2;
      }
      src_off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, bind_mref);
      if (src_off < 0) {
        unsafe {
          src_off = glue_var_expr_stack_off_elf_c(arena, ctx, bind_mref);
        }
      }
      if (src_off < 0) {
        return 0 - 2;
      }
    }
    ty_ref = let_ty_ref;
    if (ty_ref <= 0) {
      unsafe {
        ty_ref = glue_var_decl_type_ref_elf_c(arena, ctx, init_ref);
      }
      if (ty_ref <= 0) {
        unsafe {
          ty_ref = pipeline_expr_resolved_type_ref(arena, init_ref);
        }
      }
    }
    if (ty_ref <= 0) {
      return 0 - 2;
    }
    unsafe {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, ty_ref, 0);
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
    }
    if (named_sz > let_sz) {
      let_sz = named_sz;
    }
    /* Frame dest <8B: scalar fall-through. dest-in-rbx ≥8B: memcpy
     * (deref_struct16 mov_rax_to_rbx clobbers dest / x19 dest-shadow).
     * 8B dest-in-rbx covers `[2]i32` ARRAY (`*p = src`); emit_expr of an
     * ARRAY VAR only loads the first elem.
     * Frame dest 9–16B: same FIELD twin (lea + deref_struct16 +
     * store_retval_pair). memcpy rejects frame dest ≤16.
     * PLATFORM: SHARED — ARRAY_LIT `[w]` Darwin 139 was dest-in-x1. */
    if (let_sz < 8) {
      return 0 - 2;
    }
    if (dest_in_rbx == 0 && src_off == stack_slot_off) {
      return 0;
    }
    if (let_sz <= 16 && dest_in_rbx == 0) {
      if (let_sz < 9) {
        return 0 - 2;
      }
      unsafe {
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      if (bind_foff != 0) {
        unsafe {
          rc = backend_enc_add_imm_to_rax_arch(elf_ctx, bind_foff, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      rc = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
      if (rc != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = glue_store_retval_pair_to_rbp_elf_c(
            modp, arena, elf_ctx, ty_ref, stack_slot_off, ta, init_ref, ctx);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (bind_foff != 0) {
      unsafe {
        rc = backend_enc_add_imm_to_rax_arch(elf_ctx, bind_foff, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, stack_slot_off, let_sz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  /* EXPR_FIELD (44) / EXPR_INDEX (47) / EXPR_DEREF (52):
   * `let h: Holder = w.h` / dest-in-rbx `*p = w.h` /
   * dest-in-rbx INDEX whole `*p = arr[i]` / dest-in-rbx DEREF
   * source `*p = *q` of a named struct (Holder / Wrap) or 8B
   * TYPE_ARRAY (`[2]i32` MATCH arm `s.a` / `rows[1]` / `*q`).
   * VAR dest-in-rbx already memcpy at let_sz >= 8 (`[2]i32`).
   * FIELD / INDEX emit_expr only loads the first 8B so that
   * fall-through leaves lanes 2–3 (Darwin 30 / 12). dest-in-rbx
   * DEREF 9–16B used to return -2; emit_deref dual-GP then dest
   * re-lea overwrites hi in x1 (Darwin leftover 30).
   * G.7: same let-init authority — lea via lvalue_eff_addr, then
   * deref_struct16 + store_retval_pair for 9–16B frame dest (memcpy
   * rejects frame ≤16). >16B frame uses the VAR memcpy twin.
   * dest-in-rbx: same VAR dest-in-rbx twin (lea src + glue_copy),
   * including 8B TYPE_ARRAY (MATCH arm FIELD used to hit let_sz < 9
   * → CG002; leftover unique leftover_emit_match_arm_result
   * rko==44/47/52 dest_tk==10 already dest-parks leftover-PE).
   * FIELD-on-VAR / DEREF-of-VAR lvalue is rax-only (dest rbx/x19
   * stays). INDEX / INDEX-base FIELD / DEREF-of-INDEX var-index
   * / slice lvalue uses rbx — park dest then src addr (VECTOR CALL
   * dest polarity) and restore dest to rbx before memcpy.
   * deref_struct16 mov_rax_to_rbx would clobber dest / x19.
   * Do not change FIELD / INDEX / DEREF emit_expr. Do not lower
   * frame dest ≤16 memcpy. Do not leftover unique leftover_emit_field
   * twin. Do not leftover rest unique rec ASSIGN second intercept.
   * PLATFORM: SHARED dest-in-rbx FIELD 8B ARRAY · LINUX gold ·
   * MACOS|ARM64 dest-shadow. */
  if ((ko == 44 || ko == 47 || ko == 52) && (ta == 0 || ta == 1)) {
    ty_ref = let_ty_ref;
    if (ty_ref <= 0) {
      unsafe {
        ty_ref = pipeline_expr_resolved_type_ref(arena, init_ref);
      }
    }
    if (ty_ref <= 0) {
      return 0 - 2;
    }
    unsafe {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, ty_ref, 0);
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, ty_ref);
    }
    if (named_sz > let_sz) {
      let_sz = named_sz;
    }
    /* dest-in-rbx 8B TYPE_ARRAY FIELD/INDEX/DEREF. VAR dest-in-rbx
     * memcpy already accepts let_sz >= 8 (`[2]i32`). FIELD/INDEX/DEREF
     * used let_sz < 9 for 9B+ named structs → MATCH arm `s.a` /
     * `rows[1]` / `*q` of `[2]i32` returned -2 (arr_asg_match_field
     * CG002). Frame dest 8B FIELD stays emit_expr fall-through.
     * PLATFORM: SHARED dest-in-rbx FIELD 8B ARRAY. */
    if (let_sz < 8) {
      return 0 - 2;
    }
    if (dest_in_rbx == 0 && let_sz < 9) {
      return 0 - 2;
    }
    /* dest-in-rbx + INDEX / INDEX-base FIELD / DEREF (`*p = arr[i]` /
     * `*p = arr[i].h` / `*p = *q`): var-index / slice / DEREF-of-INDEX
     * lvalue uses rbx. G.7: reuse binop INDEX-clobber detector and
     * VECTOR CALL dest park polarity (ARM64 home=cur, x86 home=cur+8).
     * Park dest, then src addr after lvalue, restore dest to rbx,
     * then memcpy dest-in-rbx.
     * PLATFORM: SHARED — LINUX|x86_64 rbx dest is the live 139. */
    if (dest_in_rbx != 0) {
      parked = glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, init_ref);
      if (parked != 0) {
        glue_align_next_offset(ctx);
        dest_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if (ta == 1) {
          pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill + 8);
        } else {
          dest_spill = dest_spill + 8;
          pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_spill);
        }
        unsafe {
          rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dest_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        glue_align_next_offset(ctx);
        src_spill = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
        if (ta == 1) {
          pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill + 8);
        } else {
          src_spill = src_spill + 8;
          pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), src_spill);
        }
      }
    }
    unsafe {
      emit_rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    }
    if (emit_rc != 0) {
      return 0 - 1;
    }
    /* dest-in-rbx FIELD / INDEX / DEREF (`*p = w.h` / `*p = arr[i].h` /
     * `*p = arr[i]` / `*p = *q`): memcpy dest-in-rbx. Do not
     * deref_struct16 (mov_rax_to_rbx clobbers dest / x19). If INDEX
     * / DEREF-of-INDEX parked dest, restore dest then src.
     * PLATFORM: SHARED — Darwin leftover was lane2=30 / 12. */
    if (dest_in_rbx != 0) {
      if (parked != 0) {
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, dest_spill, ta);
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
          rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, src_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      unsafe {
        rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, let_sz, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    if (let_sz > 16) {
      unsafe {
        rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, stack_slot_off, let_sz, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
      return 0;
    }
    rc = pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = glue_store_retval_pair_to_rbp_elf_c(
          modp, arena, elf_ctx, ty_ref, stack_slot_off, ta, init_ref, ctx);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    return 0;
  }
  return 0 - 2;
  }
}
