// Thin pure: wave328/371 M2 — asm_codegen_mega_body Cap residual C→.x (was wave290 C thin).
// ctx_reset_for_func_c + backend_asm_codegen_ast_to_elf_mega_body_c.
// G.7: bodies match deleted C thin / seed WAVE290_ASM_CODEGEN_MEGA_BODY_ALWAYS.
// PRODUCT inject: PREFER try (wave371) — T001 w371_* + L2 gate.
// POSIX product path only (WIN leftover ARRAY_LIT return stays leftover-PE).
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern "C" function memset(dst: *u8, c: i32, n: usize): *u8;
export extern "C" function link_abi_getenv(name: *u8): *u8;

export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function asm_ctx_local_reset(ctx: *u8): void;
export extern function pipeline_dep_ctx_target_arch(ctx: *u8): i32;

export extern function pipeline_asm_wpo_pgo_emit_order_prepare(m: *u8): void;
export extern function pipeline_asm_wpo_pgo_emit_order_count(m: *u8): i32;
export extern function pipeline_asm_wpo_pgo_emit_order_at(m: *u8, order_index: i32): i32;
export extern function pipeline_asm_wpo_pgo_is_hot_func(m: *u8, fi: i32): i32;
export extern function asm_diag_start_func_skip(): i32;
export extern function pipeline_module_num_funcs(m: *u8): i32;
export extern function pipeline_asm_modlet_prepare_and_emit_elf_c(m: *u8, a: *u8, elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_elf_ctx_set_emit_hot(ctx_bytes: *u8, hot: i32): void;
export extern function pipeline_asm_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern function pipeline_asm_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern function pipeline_asm_module_func_is_extern_at(m: *u8, fi: i32): i32;
export extern function driver_diagnostic_asm_set_current_func(name: *u8, len: i32): void;
export extern function pipeline_asm_emit_set_func_index(func_index: i32): void;
export extern function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void;
export extern function pipeline_asm_emit_ctx_sret_active_set(v: i32): void;
export extern function pipeline_asm_emit_ctx_sret_home_off_set(off: i32): void;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_set(sz: i32): void;
export extern function pipeline_asm_fill_param_slots(ctx: *u8, mod: *u8, func_index: i32): void;
export extern function glue_func_return_byte_size_c(mod: *u8, arena: *u8, func_index: i32): i32;
export extern function pipeline_asm_register_module_top_level_lets_c(ctx: *u8, m: *u8, a: *u8, func_index: i32): void;
export extern function glue_asm_build_func_export_sym_c(m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32;
export extern function asm_skip_heavy_module_func_body(m: *u8, arena: *u8, func_index: i32): i32;
export extern function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32;
export extern function pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx: *u8, ta: i32, mod: *u8, func_index: i32): i32;
export extern function pipeline_asm_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_asm_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern function pipeline_asm_compute_frame_size_c(num_params: i32, arena: *u8, block_ref: i32, mod: *u8, func_index: i32): i32;
export extern function pipeline_asm_block_num_stmt_order_at(a: *u8, br: i32): i32;
export extern function pipeline_asm_fill_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void;
export extern function pipeline_asm_emit_param_home_elf_c(elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32;
export extern function pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a: *u8, elf_ctx: *u8, ctx: *u8, m: *u8, func_index: i32, ta: i32): i32;
export extern function pipeline_asm_hoist_target_func_index(m: *u8): i32;
export extern function pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_async_cps_entry_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function backend_emit_block_body_sync_elf(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32;
export extern function ast_ast_block_num_consts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function pipeline_asm_emit_block_inits_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32, slot_base: i32): i32;
export extern function pipeline_asm_get_return_expr_ref_at(a: *u8, m: *u8, func_index: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_module_func_return_type_at(m: *u8, fi: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_module_main_func_index(m: *u8): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_async_cps_end_func_elf_c(): void;


// wave371: T001 unsafe wrappers for PREFER try (Cap residual mega_body).
// PLATFORM: SHARED — call sites in export bodies use these helpers only.

/**
 * pipe_load_i32_le via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_pipe_load_i32_le(base: *u8, off: i32): i32 {
  unsafe {
    return pipe_load_i32_le(base, off);
  }
}

/**
 * pipe_store_i32_le via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_pipe_store_i32_le(base: *u8, off: i32, v: i32): void {
  unsafe {
    pipe_store_i32_le(base, off, v);
  }
}

/**
 * memset via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_memset(dst: *u8, c: i32, n: usize): *u8 {
  unsafe {
    return memset(dst, c, n);
  }
}

/**
 * link_abi_getenv via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_getenv(name: *u8): *u8 {
  unsafe {
    return link_abi_getenv(name);
  }
}

/**
 * pipeline_asm_ctx_layout via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ctx_layout(ctx: *u8): *u8 {
  unsafe {
    return pipeline_asm_ctx_layout(ctx);
  }
}

/**
 * asm_ctx_local_reset via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ctx_local_reset(ctx: *u8): void {
  unsafe {
    asm_ctx_local_reset(ctx);
  }
}

/**
 * pipeline_dep_ctx_target_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_deptx_target_arch(ctx: *u8): i32 {
  unsafe {
    return pipeline_dep_ctx_target_arch(ctx);
  }
}

/**
 * pipeline_asm_wpo_pgo_emit_order_prepare via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_wpo_e_order_prepare(m: *u8): void {
  unsafe {
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  }
}

/**
 * pipeline_asm_wpo_pgo_emit_order_count via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_wpo_e_orderount(m: *u8): i32 {
  unsafe {
    return pipeline_asm_wpo_pgo_emit_order_count(m);
  }
}

/**
 * pipeline_asm_wpo_pgo_emit_order_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_wpo_e_order(m: *u8, order_index: i32): i32 {
  unsafe {
    return pipeline_asm_wpo_pgo_emit_order_at(m, order_index);
  }
}

/**
 * pipeline_asm_wpo_pgo_is_hot_func via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_wpo_is_hot_func(m: *u8, fi: i32): i32 {
  unsafe {
    return pipeline_asm_wpo_pgo_is_hot_func(m, fi);
  }
}

/**
 * asm_diag_start_func_skip via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_diag_start_fn_skip(): i32 {
  unsafe {
    return asm_diag_start_func_skip();
  }
}

/**
 * pipeline_module_num_funcs via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_module_num_funcs(m: *u8): i32 {
  unsafe {
    return pipeline_module_num_funcs(m);
  }
}

/**
 * pipeline_asm_modlet_prepare_and_emit_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ml_prepare_and_e(m: *u8, a: *u8, elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_modlet_prepare_and_emit_elf_c(m, a, elf_ctx, ta);
  }
}

/**
 * pipeline_elf_ctx_set_emit_hot via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_elftx_set_e_hot(ctx_bytes: *u8, hot: i32): void {
  unsafe {
    pipeline_elf_ctx_set_emit_hot(ctx_bytes, hot);
  }
}

/**
 * pipeline_asm_module_func_name_copy64 via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mf_nameopy64(m: *u8, fi: i32, dst: *u8): void {
  unsafe {
    pipeline_asm_module_func_name_copy64(m, fi, dst);
  }
}

/**
 * pipeline_asm_module_func_name_len_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mf_name_len(m: *u8, fi: i32): i32 {
  unsafe {
    return pipeline_asm_module_func_name_len_at(m, fi);
  }
}

/**
 * pipeline_asm_module_func_is_extern_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mf_is_extern(m: *u8, fi: i32): i32 {
  unsafe {
    return pipeline_asm_module_func_is_extern_at(m, fi);
  }
}

/**
 * driver_diagnostic_asm_set_current_func via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_seturrent_func(name: *u8, len: i32): void {
  unsafe {
    driver_diagnostic_asm_set_current_func(name, len);
  }
}

/**
 * pipeline_asm_emit_set_func_index via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_set_fn_index(func_index: i32): void {
  unsafe {
    pipeline_asm_emit_set_func_index(func_index);
  }
}

/**
 * pipeline_debug_trace_named_func_bodies via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_debug_trace_named_fn_bodies(phase: *u8, module: *u8, arena: *u8): void {
  unsafe {
    pipeline_debug_trace_named_func_bodies(phase, module, arena);
  }
}

/**
 * pipeline_asm_emit_ctx_sret_active_set via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ec_sret_active_set(v: i32): void {
  unsafe {
    pipeline_asm_emit_ctx_sret_active_set(v);
  }
}

/**
 * pipeline_asm_emit_ctx_sret_home_off_set via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ec_sret_home_off_set(off: i32): void {
  unsafe {
    pipeline_asm_emit_ctx_sret_home_off_set(off);
  }
}

/**
 * pipeline_asm_emit_ctx_sret_ret_sz_set via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ec_sret_ret_sz_set(sz: i32): void {
  unsafe {
    pipeline_asm_emit_ctx_sret_ret_sz_set(sz);
  }
}

/**
 * pipeline_asm_fill_param_slots via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_fill_param_slots(ctx: *u8, mod: *u8, func_index: i32): void {
  unsafe {
    pipeline_asm_fill_param_slots(ctx, mod, func_index);
  }
}

/**
 * glue_func_return_byte_size_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_fn_ret_byte_size(mod: *u8, arena: *u8, func_index: i32): i32 {
  unsafe {
    return glue_func_return_byte_size_c(mod, arena, func_index);
  }
}

/**
 * pipeline_asm_register_module_top_level_lets_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_register_module_top_level_le(ctx: *u8, m: *u8, a: *u8, func_index: i32): void {
  unsafe {
    pipeline_asm_register_module_top_level_lets_c(ctx, m, a, func_index);
  }
}

/**
 * glue_asm_build_func_export_sym_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_build_fn_export_sym(m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32): i32 {
  unsafe {
    return glue_asm_build_func_export_sym_c(m, a, func_ix, out, out_cap);
  }
}

/**
 * backend_enc_label_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32 {
  unsafe {
    return backend_enc_label_arch(elf_ctx, name, name_len, is_global, ta);
  }
}

/**
 * asm_skip_heavy_module_func_body via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_skip_heavy_mf_body(m: *u8, arena: *u8, func_index: i32): i32 {
  unsafe {
    return asm_skip_heavy_module_func_body(m, arena, func_index);
  }
}

/**
 * backend_enc_prologue_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32 {
  unsafe {
    return backend_enc_prologue_arch(elf_ctx, frame_sz, ta);
  }
}

/**
 * pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_skip_heavy_or_thin_stub(elf_ctx: *u8, ta: i32, mod: *u8, func_index: i32): i32 {
  unsafe {
    return pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx, ta, mod, func_index);
  }
}

/**
 * pipeline_asm_module_func_body_ref_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mf_body_ref(m: *u8, fi: i32): i32 {
  unsafe {
    return pipeline_asm_module_func_body_ref_at(m, fi);
  }
}

/**
 * pipeline_asm_module_func_num_params_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mf_num_params(m: *u8, fi: i32): i32 {
  unsafe {
    return pipeline_asm_module_func_num_params_at(m, fi);
  }
}

/**
 * pipeline_asm_compute_frame_size_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_compute_frame_size(num_params: i32, arena: *u8, block_ref: i32, mod: *u8, func_index: i32): i32 {
  unsafe {
    return pipeline_asm_compute_frame_size_c(num_params, arena, block_ref, mod, func_index);
  }
}

/**
 * pipeline_asm_block_num_stmt_order_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_blk_num_stmt_order(a: *u8, br: i32): i32 {
  unsafe {
    return pipeline_asm_block_num_stmt_order_at(a, br);
  }
}

/**
 * pipeline_asm_fill_local_slots via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_fill_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void {
  unsafe {
    pipeline_asm_fill_local_slots(ctx, arena, block_ref);
  }
}

/**
 * pipeline_asm_emit_param_home_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_param_home(elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_param_home_elf_c(elf_ctx, ctx, mod, func_index, ta);
  }
}

/**
 * pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_module_top_level_mutable_l(a: *u8, elf_ctx: *u8, ctx: *u8, m: *u8, func_index: i32, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a, elf_ctx, ctx, m, func_index, ta);
  }
}

/**
 * pipeline_asm_hoist_target_func_index via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_hoist_target_fn_index(m: *u8): i32 {
  unsafe {
    return pipeline_asm_hoist_target_func_index(m);
  }
}

/**
 * pipeline_asm_modlet_seed_nonzero_inits_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_ml_seed_nonzero_inits(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx, ta);
  }
}

/**
 * pipeline_asm_emit_async_cps_entry_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_asyncps_entry(arena: *u8, elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_async_cps_entry_elf_c(arena, elf_ctx, ctx, mod, func_index, ta);
  }
}

/**
 * pipeline_asm_emit_next_label_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_next_label(ctx: *u8, buf: *u8, buf_size: i32): i32 {
  unsafe {
    return pipeline_asm_emit_next_label_c(ctx, buf, buf_size);
  }
}

/**
 * backend_emit_block_body_sync_elf via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_blk_body_sync(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
  }
}

/**
 * ast_ast_block_num_consts via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_blk_numonsts(arena: *u8, block_ref: i32): i32 {
  unsafe {
    return ast_ast_block_num_consts(arena, block_ref);
  }
}

/**
 * ast_ast_block_num_lets via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_blk_num_lets(arena: *u8, block_ref: i32): i32 {
  unsafe {
    return ast_ast_block_num_lets(arena, block_ref);
  }
}

/**
 * pipeline_asm_emit_block_inits_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_blk_inits(arena: *u8, elf_ctx: *u8, block_ref: i32, ctx: *u8, ta: i32, slot_base: i32): i32 {
  unsafe {
    return pipeline_asm_emit_block_inits_elf_c(arena, elf_ctx, block_ref, ctx, ta, slot_base);
  }
}

/**
 * pipeline_asm_get_return_expr_ref_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_get_ret_expr_ref(a: *u8, m: *u8, func_index: i32): i32 {
  unsafe {
    return pipeline_asm_get_return_expr_ref_at(a, m, func_index);
  }
}

/**
 * pipeline_asm_emit_expr_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_expr(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  }
}

/**
 * pipeline_module_func_return_type_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mf_ret_type(m: *u8, fi: i32): i32 {
  unsafe {
    return pipeline_module_func_return_type_at(m, fi);
  }
}

/**
 * pipeline_type_kind_ord_at via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_type_kind_ord(arena: *u8, ref: i32): i32 {
  unsafe {
    return pipeline_type_kind_ord_at(arena, ref);
  }
}

/**
 * pipeline_module_main_func_index via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_module_main_fn_index(m: *u8): i32 {
  unsafe {
    return pipeline_module_main_func_index(m);
  }
}

/**
 * backend_enc_mov_imm32_to_w0_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32 {
  unsafe {
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, imm, ta);
  }
}

/**
 * backend_enc_mov_eax_to_xmm_arg_reg_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mov_eax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  unsafe {
    return backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, k, ta);
  }
}

/**
 * backend_enc_mov_rax_to_xmm_arg_reg_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_mov_rax_to_xmm_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32 {
  unsafe {
    return backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, k, ta);
  }
}

/**
 * backend_enc_epilogue_arch via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_epilogue_arch(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_enc_epilogue_arch(elf_ctx, ta);
  }
}

/**
 * pipeline_asm_emit_async_cps_end_func_elf_c via unsafe (T001). PLATFORM: SHARED. wave371.
 */
function w371_e_asyncps_end_fn(): void {
  unsafe {
    pipeline_asm_emit_async_cps_end_func_elf_c();
  }
}

/** LP64 AsmFuncCtx overlay size — match pipeline_glue_AsmFuncCtxLayout. */
const W328_CTX_SZ: i32 = 1528;
const W328_CTX_FRAME_SIZE: i32 = 0;
const W328_CTX_NEXT_OFFSET: i32 = 4;
const W328_CTX_NUM_LOCALS: i32 = 8;
const W328_CTX_LABEL_COUNTER: i32 = 12;
const W328_CTX_MODULE_REF: i32 = 16;
const W328_CTX_BREAK_LEN: i32 = 1240;
const W328_CTX_CONTINUE_LEN: i32 = 1372;
const W328_CTX_LOOP_LABEL_DEPTH: i32 = 1376;
const W328_CTX_DEP_PIPE: i32 = 1384;
const W328_CTX_TAIL_JOIN_LABEL: i32 = 1392;
const W328_CTX_TAIL_JOIN_LABEL_LEN: i32 = 1520;

/** LP64 SHARED — match pure pipe_elf_off_e_machine / reloc_type_r_pc32. */
const W328_ELF_E_MACHINE_OFF: i32 = 17432600;
const W328_ELF_RELOC_R_PC32_OFF: i32 = 17432604;
const W328_GLUE_TYPE_KIND_F32_ORD: i32 = 14;
const W328_GLUE_TYPE_KIND_F64_ORD: i32 = 15;
const W328_TYPE_KIND_VOID_ORD: i32 = 16;

/**
 * Load i32 LE at byte offset.
 * PLATFORM: SHARED
 */
function w328_load(p: *u8, off: i32): i32 {
  return w371_pipe_load_i32_le(p, off);
}

/**
 * Store i32 LE at byte offset.
 * PLATFORM: SHARED
 */
function w328_store(p: *u8, off: i32, v: i32): void {
  w371_pipe_store_i32_le(p, off, v);
}

/**
 * Store pointer at byte offset (LP64).
 * PLATFORM: SHARED
 */
function w328_store_ptr(p: *u8, off: i32, v: *u8): void {
  if (p == (0 as *u8)) { return; }
  unsafe { *((p + (off as usize)) as **u8) = v; }
}

/**
 * wave153 Cap residual: reset per-func AsmFuncCtx between mega emit iterations.
 * label_counter intentionally preserved for unique .L_N across whole mega emit.
 * @param ctx layout overlay (may be null)
 * @param mod module pointer stored into module_ref (may be null)
 * PLATFORM: SHARED freestanding Cap leave (wave290/328 seed ALWAYS).
 */
export function pipeline_asm_ctx_reset_for_func_c(ctx: *u8, mod: *u8): void {
  let ly: *u8 = ctx;
  if (ly == (0 as *u8)) { return; }
  w328_store(ly, W328_CTX_FRAME_SIZE, 0);
  w328_store(ly, W328_CTX_NEXT_OFFSET, 0);
  w328_store(ly, W328_CTX_NUM_LOCALS, 0);
  w328_store_ptr(ly, W328_CTX_MODULE_REF, mod);
  w328_store(ly, W328_CTX_BREAK_LEN, 0);
  w328_store(ly, W328_CTX_CONTINUE_LEN, 0);
  w328_store(ly, W328_CTX_LOOP_LABEL_DEPTH, 0);
  w328_store_ptr(ly, W328_CTX_DEP_PIPE, 0 as *u8);
  w328_store(ly, W328_CTX_TAIL_JOIN_LABEL_LEN, 0);
  w371_ctx_local_reset(ly);
}

/**
 * Per-module asm codegen mega-body loop (WPO/PGO emit order).
 * Sets ELF e_machine / reloc defaults from DepCtx.target_arch, emits modlet
 * cells, then for each emit-order function: reset ctx, param homes, prologue,
 * block body / inits, float xmm0 placement, epilogue.
 * POSIX product path only (no WIN leftover ARRAY_LIT durable wrap).
 * @return 0 success, -1 on null/emit failure
 * PLATFORM: SHARED freestanding Cap leave (wave290/328).
 *   LINUX+MACOS x86_64 SysV float return in xmm0; arm64 sret via pure cells.
 */
export function pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8): i32 {
  let ta: i32 = 0;
  let ctx: u8[1528] = [];
  let fname_buf: u8[256] = [];
  let export_sym: u8[256] = [];
  let start_skip: i32 = 0;
  let emit_n: i32 = 0;
  let k: i32 = 0;
  let elfb: *u8 = 0 as *u8;
  let bctx: *u8 = 0 as *u8;
  let i: i32 = 0;
  let body_ref: i32 = 0;
  let frame_sz: i32 = 0;
  let fname_len: i32 = 0;
  let export_sym_len: i32 = 0;
  let result_ref: i32 = 0;
  let fn_ret_sz: i32 = 0;
  let ly_fs: *u8 = 0 as *u8;
  let slot_base: i32 = 0;
  let rty: i32 = 0;
  let rkind: i32 = 0;
  let neg1: i32 = 0 - 1;

  if (m == (0 as *u8) || a == (0 as *u8) || elf_ctx == (0 as *u8) || pipeline_ctx == (0 as *u8)) {
    return neg1;
  }
  elfb = elf_ctx;
  ta = w371_deptx_target_arch(pipeline_ctx);
  if (ta == 1) {
    w328_store(elfb, W328_ELF_E_MACHINE_OFF, 183);
    w328_store(elfb, W328_ELF_RELOC_R_PC32_OFF, 283);
  } else if (ta == 2) {
    w328_store(elfb, W328_ELF_E_MACHINE_OFF, 243);
    w328_store(elfb, W328_ELF_RELOC_R_PC32_OFF, 32);
  } else {
    w328_store(elfb, W328_ELF_E_MACHINE_OFF, 62);
    w328_store(elfb, W328_ELF_RELOC_R_PC32_OFF, 2);
  }
  unsafe { w371_memset(&ctx[0], 0, W328_CTX_SZ as usize); }
  bctx = &ctx[0];
  w371_wpo_e_order_prepare(m);
  start_skip = w371_diag_start_fn_skip();
  emit_n = w371_wpo_e_orderount(m);
  /* PLATFORM: SHARED x86_64 — text-embedded module mutable lit cells once before funcs. */
  if (w371_ml_prepare_and_e(m, a, elf_ctx, ta) != 0) {
    return neg1;
  }
  k = 0;
  while (k < emit_n) {
    i = w371_wpo_e_order(m, k);
    body_ref = 0;
    frame_sz = 0;
    fname_len = 0;
    export_sym_len = 0;
    result_ref = 0;
    if (i < 0) {
      k = k + 1;
      continue;
    }
    if (i < start_skip) {
      k = k + 1;
      continue;
    }
    /* PLATFORM: SHARED — extern must stay U (text-asm path already skips). */
    if (w371_mf_is_extern(m, i) != 0) {
      k = k + 1;
      continue;
    }
    w371_elftx_set_e_hot(elfb, w371_wpo_is_hot_func(m, i));
    w371_mf_nameopy64(m, i, &fname_buf[0]);
    fname_len = w371_mf_name_len(m, i);
    w371_seturrent_func(&fname_buf[0], fname_len);
    w371_e_set_fn_index(i);
    w371_debug_trace_named_fn_bodies("mega_pre_reset" as *u8, m, a);
    pipeline_asm_ctx_reset_for_func_c(bctx, m);
    w328_store_ptr(bctx, W328_CTX_DEP_PIPE, pipeline_ctx);
    /* wave223: sret cells pure BSS — residual writes only via pure setters. */
    w371_ec_sret_active_set(0);
    w371_ec_sret_home_off_set(neg1);
    w371_ec_sret_ret_sz_set(0);
    w371_fill_param_slots(bctx, m, i);
    w371_debug_trace_named_fn_bodies("mega_post_param_slots" as *u8, m, a);
    /*
     * >16B return: reserve 8B to save incoming hidden dest (before top-level lets).
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8.
     */
    if (ta == 0 || ta == 1) {
      fn_ret_sz = w371_fn_ret_byte_size(m, a, i);
      if (fn_ret_sz > 16) {
        w371_ec_sret_ret_sz_set(fn_ret_sz);
        w371_ec_sret_active_set(1);
        w371_ec_sret_home_off_set(w328_load(bctx, W328_CTX_NEXT_OFFSET) + 256);
        w328_store(bctx, W328_CTX_NEXT_OFFSET, w328_load(bctx, W328_CTX_NEXT_OFFSET) + 8);
      }
    }
    w371_register_module_top_level_le(bctx, m, a, i);
    w371_debug_trace_named_fn_bodies("mega_post_register_top_level" as *u8, m, a);
    /* Cap 4.2.8: export_sym is u8[256]; out_cap must be 256. */
    export_sym_len = w371_build_fn_export_sym(m, a, i, &export_sym[0], 256);
    if (export_sym_len <= 0) { return neg1; }
    if (w371_label_arch(elf_ctx, &export_sym[0], export_sym_len, 1, ta) != 0) {
      return neg1;
    }
    if (w371_skip_heavy_mf_body(m, a, i) != 0) {
      if (w371_prologue_arch(elf_ctx, 0, ta) != 0) { return neg1; }
      if (w371_e_skip_heavy_or_thin_stub(elf_ctx, ta, m, i) != 0) { return neg1; }
      k = k + 1;
      continue;
    }
    body_ref = w371_mf_body_ref(m, i);
    frame_sz = 0;
    if (body_ref != 0) {
      frame_sz = w371_compute_frame_size(w371_mf_num_params(m, i), a, body_ref, m, i);
      w371_debug_trace_named_fn_bodies("mega_post_frame_size" as *u8, m, a);
      w371_fill_local_slots(bctx, a, body_ref);
      w371_debug_trace_named_fn_bodies("mega_post_fill_local_slots" as *u8, m, a);
    }
    if (w371_prologue_arch(elf_ctx, frame_sz, ta) != 0) { return neg1; }
    /*
     * wave603: arm64 MEMORY param_home needs frame_size so incoming stack args
     * resolve at [x29+frame] (wave414 low-end prologue), not [x29+16] identity.
     */
    ly_fs = w371_ctx_layout(bctx);
    if (ly_fs != (0 as *u8)) {
      w328_store(ly_fs, W328_CTX_FRAME_SIZE, frame_sz);
    }
    if (w371_e_param_home(elf_ctx, bctx, m, i, ta) != 0) {
      return neg1;
    }
    /* Mutable module-level lit lets on non-hoist: seed stack slots after param home. */
    if (w371_e_module_top_level_mutable_l(a, elf_ctx, bctx, m, i, ta) != 0) {
      return neg1;
    }
    /* COMMON BSS starts zero; non-zero modlet inits once on hoist target. */
    if (i == w371_hoist_target_fn_index(m)) {
      if (w371_ml_seed_nonzero_inits(elf_ctx, ta) != 0) {
        return neg1;
      }
    }
    if (w371_e_asyncps_entry(a, elf_ctx, bctx, m, i, ta) != 0) {
      return neg1;
    }
    if (body_ref != 0) {
      w328_store(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN,
                 w371_e_next_label(bctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize), 64));
      if (w371_blk_num_stmt_order(a, body_ref) > 0) {
        w371_debug_trace_named_fn_bodies("mega_pre_emit_block_body" as *u8, m, a);
        if (w371_blk_body_sync(a, elf_ctx, body_ref, bctx, ta) != 0) {
          return neg1;
        }
      } else {
        slot_base = w328_load(bctx, W328_CTX_NUM_LOCALS) - w371_blk_numonsts(a, body_ref) - w371_blk_num_lets(a, body_ref);
        if (slot_base < 0) { return neg1; }
        if (w371_e_blk_inits(a, elf_ctx, body_ref, bctx, ta, slot_base) != 0) {
          return neg1;
        }
      }
      if (w371_label_arch(elf_ctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize),
                                 w328_load(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN), 0, ta) != 0) {
        return neg1;
      }
    }
    result_ref = 0;
    if (body_ref == 0 || w371_blk_num_stmt_order(a, body_ref) == 0) {
      result_ref = w371_get_ret_expr_ref(a, m, i);
    }
    if (result_ref != 0) {
      /* POSIX product path — WIN leftover durable wrap is leftover-PE authority. */
      if (w371_e_expr(a, elf_ctx, result_ref, bctx, ta) != 0) {
        return neg1;
      }
    }
    /*
     * PLATFORM: LINUX+MACOS x86_64 SysV — place scalar float return in xmm0 before epilogue.
     * PLATFORM: SHARED — Zig-like void main: process entry must exit 0 on fall-off.
     */
    rty = w371_mf_ret_type(m, i);
    if (rty > 0) {
      rkind = w371_type_kind_ord(a, rty);
    } else {
      rkind = neg1;
    }
    if (ta == 0) {
      if (rkind == W328_GLUE_TYPE_KIND_F32_ORD) {
        if (w371_mov_eax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0) { return neg1; }
      } else if (rkind == W328_GLUE_TYPE_KIND_F64_ORD) {
        if (w371_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0) { return neg1; }
      }
    }
    if (rkind == W328_TYPE_KIND_VOID_ORD && i == w371_module_main_fn_index(m)) {
      if (w371_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) { return neg1; }
    }
    if (w371_epilogue_arch(elf_ctx, ta) != 0) {
      return neg1;
    }
    w371_e_asyncps_end_fn();
    k = k + 1;
  }
  return 0;
}
