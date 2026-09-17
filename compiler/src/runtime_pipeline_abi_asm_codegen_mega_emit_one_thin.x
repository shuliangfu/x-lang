// Thin pure: wave394 M2 — asm_codegen mega emit_one leaf.
// Export: w393_mega_emit_one (called from mega_loop_thin).
// wave394: third leaf (CG002 when emit_one+mega co-file). No local w328_*
//   (pipe_* direct; HELPERS owns w328 for ctx_reset). BAN until unlock.
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.
// wave424: LINUX product PREFER this leaf alone (helpers/loop/三叶 BAN).

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
 * wave393d: one emit-order iteration of mega LOOP.
 * Split from mega_body_c so Ubuntu tip parser/codegen does not silently drop
 * the single large mega function (num_funcs=61, no T symbol).
 * @return 0 ok (caller advances k), -1 on emit failure
 * PLATFORM: SHARED. Invoked under mega_body_c unsafe.
 */
export function w393_mega_emit_one(
    m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8,
    bctx: *u8, elfb: *u8, ta: i32, i: i32, start_skip: i32,
    fname_buf: *u8, export_sym: *u8): i32 {
  unsafe {
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

    body_ref = 0;
    frame_sz = 0;
    fname_len = 0;
    export_sym_len = 0;
    result_ref = 0;
    if (i < 0) {
      return 0;
    }
    if (i < start_skip) {
      return 0;
    }
    /* PLATFORM: SHARED — extern must stay U (text-asm path already skips). */
    if (pipeline_asm_module_func_is_extern_at(m, i) != 0) {
      return 0;
    }
    pipeline_elf_ctx_set_emit_hot(elfb, pipeline_asm_wpo_pgo_is_hot_func(m, i));
    pipeline_asm_module_func_name_copy64(m, i, fname_buf);
    fname_len = pipeline_asm_module_func_name_len_at(m, i);
    driver_diagnostic_asm_set_current_func(fname_buf, fname_len);
    pipeline_asm_emit_set_func_index(i);
    pipeline_debug_trace_named_func_bodies("mega_pre_reset" as *u8, m, a);
    /* T001: ctx_reset lives in HELPERS leaf — call via unsafe. */
    pipeline_asm_ctx_reset_for_func_c(bctx, m);
    /* Type LE: pipe_store_ptr_slot — avoid w328_store_ptr + mega co-file (w393c). */
    pipe_store_ptr_slot(bctx + (W328_CTX_DEP_PIPE as usize), 0, pipeline_ctx);
    /* wave223: sret cells pure BSS — residual writes only via pure setters. */
    pipeline_asm_emit_ctx_sret_active_set(0);
    pipeline_asm_emit_ctx_sret_home_off_set(neg1);
    pipeline_asm_emit_ctx_sret_ret_sz_set(0);
    pipeline_asm_fill_param_slots(bctx, m, i);
    pipeline_debug_trace_named_func_bodies("mega_post_param_slots" as *u8, m, a);
    /*
     * >16B return: reserve 8B to save incoming hidden dest (before top-level lets).
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8.
     */
    if (ta == 0 || ta == 1) {
      fn_ret_sz = glue_func_return_byte_size_c(m, a, i);
      if (fn_ret_sz > 16) {
        pipeline_asm_emit_ctx_sret_ret_sz_set(fn_ret_sz);
        pipeline_asm_emit_ctx_sret_active_set(1);
        pipeline_asm_emit_ctx_sret_home_off_set(pipe_load_i32_le(bctx, W328_CTX_NEXT_OFFSET) + 256);
        pipe_store_i32_le(bctx, W328_CTX_NEXT_OFFSET, pipe_load_i32_le(bctx, W328_CTX_NEXT_OFFSET) + 8);
      }
    }
    pipeline_asm_register_module_top_level_lets_c(bctx, m, a, i);
    pipeline_debug_trace_named_func_bodies("mega_post_register_top_level" as *u8, m, a);
    /* Cap 4.2.8: export_sym is u8[256]; out_cap must be 256. */
    export_sym_len = glue_asm_build_func_export_sym_c(m, a, i, export_sym, 256);
    if (export_sym_len <= 0) { return neg1; }
    if (backend_enc_label_arch(elf_ctx, export_sym, export_sym_len, 1, ta) != 0) {
      return neg1;
    }
    if (asm_skip_heavy_module_func_body(m, a, i) != 0) {
      if (backend_enc_prologue_arch(elf_ctx, 0, ta) != 0) { return neg1; }
      if (pipeline_asm_emit_skip_heavy_or_thin_stub_elf_c(elf_ctx, ta, m, i) != 0) { return neg1; }
      return 0;
    }
    body_ref = pipeline_asm_module_func_body_ref_at(m, i);
    frame_sz = 0;
    if (body_ref != 0) {
      frame_sz = pipeline_asm_compute_frame_size_c(pipeline_asm_module_func_num_params_at(m, i), a, body_ref, m, i);
      pipeline_debug_trace_named_func_bodies("mega_post_frame_size" as *u8, m, a);
      pipeline_asm_fill_local_slots(bctx, a, body_ref);
      pipeline_debug_trace_named_func_bodies("mega_post_fill_local_slots" as *u8, m, a);
    }
    if (backend_enc_prologue_arch(elf_ctx, frame_sz, ta) != 0) { return neg1; }
    /*
     * wave603: arm64 MEMORY param_home needs frame_size so incoming stack args
     * resolve at [x29+frame] (wave414 low-end prologue), not [x29+16] identity.
     */
    ly_fs = pipeline_asm_ctx_layout(bctx);
    if (ly_fs != (0 as *u8)) {
      pipe_store_i32_le(ly_fs, W328_CTX_FRAME_SIZE, frame_sz);
    }
    if (pipeline_asm_emit_param_home_elf_c(elf_ctx, bctx, m, i, ta) != 0) {
      return neg1;
    }
    /* Mutable module-level lit lets on non-hoist: seed stack slots after param home. */
    if (pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a, elf_ctx, bctx, m, i, ta) != 0) {
      return neg1;
    }
    /* COMMON BSS starts zero; non-zero modlet inits once on hoist target. */
    if (i == pipeline_asm_hoist_target_func_index(m)) {
      if (pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx, ta) != 0) {
        return neg1;
      }
    }
    if (pipeline_asm_emit_async_cps_entry_elf_c(a, elf_ctx, bctx, m, i, ta) != 0) {
      return neg1;
    }
    if (body_ref != 0) {
      pipe_store_i32_le(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN,
                 pipeline_asm_emit_next_label_c(bctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize), 64));
      if (pipeline_asm_block_num_stmt_order_at(a, body_ref) > 0) {
        pipeline_debug_trace_named_func_bodies("mega_pre_emit_block_body" as *u8, m, a);
        if (backend_emit_block_body_sync_elf(a, elf_ctx, body_ref, bctx, ta) != 0) {
          return neg1;
        }
      } else {
        slot_base = pipe_load_i32_le(bctx, W328_CTX_NUM_LOCALS) - ast_ast_block_num_consts(a, body_ref) - ast_ast_block_num_lets(a, body_ref);
        if (slot_base < 0) { return neg1; }
        if (pipeline_asm_emit_block_inits_elf_c(a, elf_ctx, body_ref, bctx, ta, slot_base) != 0) {
          return neg1;
        }
      }
      if (backend_enc_label_arch(elf_ctx, bctx + (W328_CTX_TAIL_JOIN_LABEL as usize),
                                 pipe_load_i32_le(bctx, W328_CTX_TAIL_JOIN_LABEL_LEN), 0, ta) != 0) {
        return neg1;
      }
    }
    result_ref = 0;
    if (body_ref == 0 || pipeline_asm_block_num_stmt_order_at(a, body_ref) == 0) {
      result_ref = pipeline_asm_get_return_expr_ref_at(a, m, i);
    }
    if (result_ref != 0) {
      /* POSIX product path — WIN leftover durable wrap is leftover-PE authority. */
      if (pipeline_asm_emit_expr_elf_c(a, elf_ctx, result_ref, bctx, ta) != 0) {
        return neg1;
      }
    }
    /*
     * PLATFORM: LINUX+MACOS x86_64 SysV — place scalar float return in xmm0 before epilogue.
     * PLATFORM: SHARED — Zig-like void main: process entry must exit 0 on fall-off.
     */
    rty = pipeline_module_func_return_type_at(m, i);
    if (rty > 0) {
      rkind = pipeline_type_kind_ord_at(a, rty);
    } else {
      rkind = neg1;
    }
    if (ta == 0) {
      if (rkind == W328_GLUE_TYPE_KIND_F32_ORD) {
        if (backend_enc_mov_eax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0) { return neg1; }
      } else if (rkind == W328_GLUE_TYPE_KIND_F64_ORD) {
        if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0) { return neg1; }
      }
    }
    if (rkind == W328_TYPE_KIND_VOID_ORD && i == pipeline_module_main_func_index(m)) {
      if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) { return neg1; }
    }
    if (backend_enc_epilogue_arch(elf_ctx, ta) != 0) {
      return neg1;
    }
    pipeline_asm_emit_async_cps_end_func_elf_c();
    return 0;

  }
}
