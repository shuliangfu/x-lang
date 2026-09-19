// Thin pure: wave216/348/375 for_call_args mega leave.
// wave588 Soft Cap: Ubuntu tip `-backend asm -c` wrote an empty .o
//   (rc=0). The original body used if-before-call, mid-assign of
//   ko/pty/tr/off/rc, `rc=call` then if, local `u8[256]` / `i32[1]`
//   out slots (`*i32` SEGV class), and nested while-free but still
//   branch-gated encoder calls, which that tip drops. Darwin
//   original kept all 68 encoders. for_call_args_store_encoders
//   always stores each i32 encoder once, calls each void encoder
//   once, and nests pointer-returning encoders as args (not
//   mid-assigned). The export returns 0; the real dispatcher stays
//   on the w375 overlay. Never stores through *i32.
// stamp w588 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

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
 * Store the for_call_args encoders. Void encoders run once first.
 * Pointer-returning module_ref / dep_pipe / load_ptr_slot are nested
 * as args (not mid-assigned). resolve_call_target and
 * vector_type_lanes receive 0 as *i32 so this helper never stores
 * through an *i32 param. Dummy type/offset/esz args are 0. No
 * locals. Each encoder runs once, not under if, while, or after a
 * mid-assign. The overlay still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param expr_ref i32 — CALL/METHOD argument expression
 * @param ctx *u8 — asm func ctx; may be null
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @param cell *u8 — at least 236 bytes; also dummy *u8 dest
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function for_call_args_store_encoders(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, cell: *u8): i32 {
  unsafe {
    glue_align_next_offset(ctx);
    glue_slice_dual_gp_bump_past_home_c(ctx, 0, ta);
    pipeline_asm_bump_next_offset_for_array_lit(arena, expr_ref, ctx);
    pipeline_expr_var_name_into(arena, expr_ref, cell);
    pipe_store_ptr_slot(cell, 0, pipe_load_ptr_slot(ctx, 0));
    pipe_store_i32_le(cell, 0, asm_ctx_scope_block_ref_at(ctx));
    pipe_store_i32_le(cell, 4, asm_type_is_simd_vector_spelling(arena, 0));
    pipe_store_i32_le(cell, 8, backend_enc_add_imm_to_rax_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 12, backend_enc_lea_rbp_to_rax_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 16, backend_enc_load_64_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 20, backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 24, backend_enc_load_rbp_to_rax_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 28, backend_enc_load_rbp_to_rdx_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 32, backend_enc_load_zext8_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 36, backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta));
    pipe_store_i32_le(cell, 40, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 44, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 48, backend_enc_pop_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 52, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 56, backend_enc_store_rax_to_rbp_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 60, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, 0, 0, ta));
    pipe_store_i32_le(cell, 64, backend_enc_store_rdx_to_rbp_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 68, glue_array_lit_force_esz_from_elem_type_c(arena, 0));
    pipe_store_i32_le(cell, 72, glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, expr_ref, 0, ta, ctx, 0));
    pipe_store_i32_le(cell, 76, glue_asm_resolve_call_target_module_c(arena, expr_ref, cell, 0 as *i32, 0 as *i32));
    pipe_store_i32_le(cell, 80, glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref));
    pipe_store_i32_le(cell, 84, glue_call_arg_var_use_lea_not_load_elf_c(arena, expr_ref, ctx));
    pipe_store_i32_le(cell, 88, glue_call_param_named_struct_pass_addr_elf_c(arena, 0));
    pipe_store_i32_le(cell, 92, glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, expr_ref, ta, 0, 0));
    pipe_store_i32_le(cell, 96, glue_emit_func_param_is_indirect_array_slot_c(arena, pipeline_asm_emit_module_ref_c(), expr_ref));
    pipe_store_i32_le(cell, 100, glue_emit_index_eff_addr_scaled_elf_c(arena, elf_ctx, expr_ref, expr_ref, expr_ref, ctx, ta, 0));
    pipe_store_i32_le(cell, 104, glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0));
    pipe_store_i32_le(cell, 108, glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, expr_ref, 0, ctx, ta));
    pipe_store_i32_le(cell, 112, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_dep_pipe_c(), expr_ref));
    pipe_store_i32_le(cell, 116, glue_fixed_array_total_bytes_c(arena, 0, 0));
    pipe_store_i32_le(cell, 120, glue_index_elem_byte_sz_from_type_ref_c(arena, 0));
    pipe_store_i32_le(cell, 124, glue_load_f32_var_slot_to_rax_elf_c(elf_ctx, arena, ctx, expr_ref, 0, ta));
    pipe_store_i32_le(cell, 128, glue_load_var_as_value_to_rax_rdx_elf_c(elf_ctx, arena, ctx, expr_ref, 0, ta));
    pipe_store_i32_le(cell, 132, glue_peel_as_array_slice_ascription_c(arena, expr_ref));
    pipe_store_i32_le(cell, 136, glue_slice_dual_gp_length_off_c(0, ta));
    pipe_store_i32_le(cell, 140, glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(arena, elf_ctx, ctx, ta, 0, 0, 0));
    pipe_store_i32_le(cell, 144, glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, expr_ref, ctx, ta));
    pipe_store_i32_le(cell, 148, glue_type_is_fixed_array(arena, 0));
    pipe_store_i32_le(cell, 152, glue_vector_type_lanes_esz_c(arena, 0, 0 as *i32, 0 as *i32));
    pipe_store_i32_le(cell, 156, pipe_asm_ctx_off_next_offset());
    pipe_store_i32_le(cell, 160, pipe_load_i32_le(ctx, 0));
    pipe_store_i32_le(cell, 164, pipeline_asm_abi_f32_xmm_enabled_c());
    pipe_store_i32_le(cell, 168, pipeline_asm_call_return_type_kind_ord_c(arena, expr_ref));
    pipe_store_i32_le(cell, 172, pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0));
    pipe_store_i32_le(cell, 176, pipeline_asm_emit_ctx_call_param_ty_get());
    pipe_store_i32_le(cell, 180, pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta));
    pipe_store_i32_le(cell, 184, pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta));
    pipe_store_i32_le(cell, 188, pipeline_block_resolve_var_type_ref(arena, 0, cell, 0));
    pipe_store_i32_le(cell, 192, pipeline_expr_array_lit_num_elems_at(arena, expr_ref));
    pipe_store_i32_le(cell, 196, pipeline_expr_index_base_ref(arena, expr_ref));
    pipe_store_i32_le(cell, 200, pipeline_expr_index_index_ref(arena, expr_ref));
    pipe_store_i32_le(cell, 204, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(cell, 208, pipeline_expr_resolved_type_ref(arena, expr_ref));
    pipe_store_i32_le(cell, 212, pipeline_expr_var_name_len(arena, expr_ref));
    pipe_store_i32_le(cell, 216, pipeline_module_func_return_type_at(pipeline_asm_emit_module_ref_c(), 0));
    pipe_store_i32_le(cell, 220, pipeline_type_array_size_at(arena, 0));
    pipe_store_i32_le(cell, 224, pipeline_type_elem_ref_at(arena, 0));
    pipe_store_i32_le(cell, 228, pipeline_type_kind_ord_at(arena, 0));
    pipe_store_i32_le(cell, 232, pipeline_typeck_get_dep_return_type_in_caller_arena_c(0, 0, arena, ctx));
    return 0;
  }
}

/**
 * wave216/375/588: emit one CALL/METHOD formal argument. Encoders
 * always run. Tip returns 0. Signature matches the w375 overlay,
 * which still does the real path (f32 lit / VAR array→slice fat /
 * dual-GP / INDEX / FIELD / ARRAY_LIT / rec).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param expr_ref i32 — call-arg expression ref
 * @param ctx *u8 — asm func ctx
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_expr_elf_for_call_args(
    arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let cell: u8[236] = [];
    let sink: i32 = 0;
    for_call_args_store_encoders(arena, elf_ctx, expr_ref, ctx, ta, &cell[0]);
    sink = ta + expr_ref;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (arena == (0 as *u8) && elf_ctx == (0 as *u8) && ctx == (0 as *u8)) {
      return 0;
    }
    return 0;
  }
}
