// Thin pure: wave393/394 M2 — asm_codegen mega LOOP outer leaf.
// Export: pipeline_backend_asm_codegen_ast_to_elf_mega_body_c.
// emit_one lives in runtime_pipeline_abi_asm_codegen_mega_emit_one_thin.x.
// wave394: split emit_one out — Ubuntu CG002 when both full bodies co-file.
// BAN reinject until both leaves -c green both ends + unlock try.
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
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
export extern function pipeline_asm_ctx_reset_for_func_c(ctx: *u8, mod: *u8): void;
export extern function w393_mega_emit_one(m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8, bctx: *u8, elfb: *u8, ta: i32, i: i32, start_skip: i32, fname_buf: *u8, export_sym: *u8): i32;

/** LP64 AsmFuncCtx overlay size — match pipeline_glue_AsmFuncCtxLayout. */
const W328_CTX_SZ: i32 = 1528;
/** LP64 SHARED — match pure pipe_elf_off_e_machine / reloc_type_r_pc32. */
const W328_ELF_E_MACHINE_OFF: i32 = 17432600;
const W328_ELF_RELOC_R_PC32_OFF: i32 = 17432604;

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
  unsafe {
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
  let neg1: i32 = 0 - 1;

  if (m == (0 as *u8) || a == (0 as *u8) || elf_ctx == (0 as *u8) || pipeline_ctx == (0 as *u8)) {
    return neg1;
  }
  elfb = elf_ctx;
  ta = pipeline_dep_ctx_target_arch(pipeline_ctx);
  if (ta == 1) {
    pipe_store_i32_le(elfb, W328_ELF_E_MACHINE_OFF, 183);
    pipe_store_i32_le(elfb, W328_ELF_RELOC_R_PC32_OFF, 283);
  } else if (ta == 2) {
    pipe_store_i32_le(elfb, W328_ELF_E_MACHINE_OFF, 243);
    pipe_store_i32_le(elfb, W328_ELF_RELOC_R_PC32_OFF, 32);
  } else {
    pipe_store_i32_le(elfb, W328_ELF_E_MACHINE_OFF, 62);
    pipe_store_i32_le(elfb, W328_ELF_RELOC_R_PC32_OFF, 2);
  }
  memset(&ctx[0], 0, W328_CTX_SZ as usize);
  bctx = &ctx[0];
  pipeline_asm_wpo_pgo_emit_order_prepare(m);
  start_skip = asm_diag_start_func_skip();
  emit_n = pipeline_asm_wpo_pgo_emit_order_count(m);
  /* PLATFORM: SHARED x86_64 — text-embedded module mutable lit cells once before funcs. */
  if (pipeline_asm_modlet_prepare_and_emit_elf_c(m, a, elf_ctx, ta) != 0) {
    return neg1;
  }
  k = 0;
  while (k < emit_n) {
    i = pipeline_asm_wpo_pgo_emit_order_at(m, k);
    if (w393_mega_emit_one(m, a, elf_ctx, pipeline_ctx, bctx, elfb, ta, i, start_skip, &fname_buf[0], &export_sym[0]) != 0) {
      return neg1;
    }
    k = k + 1;
  }
  return 0;
  }
}
