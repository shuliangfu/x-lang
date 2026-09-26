// Thin pure: wave394/424/499 M2 — asm_codegen mega emit_one head leaf.
// Export: w393_mega_emit_one (called from mega_loop_thin).
// wave394: third leaf (CG002 when emit_one+mega co-file).
// wave424: LINUX product PREFER this leaf alone (helpers/loop BAN).
// wave499: tipU heal — monolith mid-expr starve; split into peer leaves:
//   skip_heavy / frame / body_sync / body_inits / ret_expr / epilogue.
//   Head dispatches; each peer tipU-complete in isolation.
// PLATFORM: SHARED freestanding Cap leave / LINUX gold / MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipeline_asm_wpo_pgo_is_hot_func(m: *u8, fi: i32): i32;
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
export extern function pipeline_asm_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern function pipeline_asm_block_num_stmt_order_at(a: *u8, br: i32): i32;
export extern function pipeline_asm_ctx_reset_for_func_c(ctx: *u8, mod: *u8): void;
export extern function w499_mega_emit_skip_heavy(elf_ctx: *u8, ta: i32, m: *u8, i: i32): i32;
export extern function w499_mega_try_tail_jmp(m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32, body_ref: i32): i32;
export extern function w499_mega_emit_frame(m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32, body_ref: i32): i32;
export extern function w499_mega_emit_body_sync(m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, body_ref: i32): i32;
export extern function w499_mega_emit_body_inits(m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32, body_ref: i32): i32;
export extern function w499_mega_emit_ret_expr(m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32): i32;
export extern function w499_mega_emit_epilogue(m: *u8, a: *u8, elf_ctx: *u8, ta: i32, i: i32): i32;

/**
 * Load i32 from pipe cell (unique name — avoid multi-leaf T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499h_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

const W328_CTX_NEXT_OFFSET: i32 = 4;
const W328_CTX_DEP_PIPE: i32 = 1384;

/**
 * wave393d/499/w1048: one emit-order iteration of mega LOOP (head dispatcher).
 * Peers: skip_heavy / try_tail_jmp / frame / body_sync / body_inits / ret_expr / epilogue.
 * @return 0 ok (caller advances k), -1 on emit failure
 * PLATFORM: SHARED. Invoked under mega_body_c unsafe.
 */
#[no_mangle]
export function w393_mega_emit_one(
    m: *u8, a: *u8, elf_ctx: *u8, pipeline_ctx: *u8,
    bctx: *u8, elfb: *u8, ta: i32, i: i32, start_skip: i32,
    fname_buf: *u8, export_sym: *u8): i32 {
  unsafe {
    let cell: u8[8];
    let neg1: i32 = 0 - 1;
    let v: i32 = 0;
    let body_ref: i32 = 0;
    let nso: i32 = 0;
    let tail: i32 = 0;
    if (i < 0) { return 0; }
    if (i < start_skip) { return 0; }
    /* tip drops mid `x=export_extern()`; pipe cell + local cell load. */
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_is_extern_at(m, i));
    v = w499h_c32(&cell[0]);
    if (v != 0) { return 0; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_wpo_pgo_is_hot_func(m, i));
    v = w499h_c32(&cell[0]);
    pipeline_elf_ctx_set_emit_hot(elfb, v);
    pipeline_asm_module_func_name_copy64(m, i, fname_buf);
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_name_len_at(m, i));
    v = w499h_c32(&cell[0]);
    driver_diagnostic_asm_set_current_func(fname_buf, v);
    pipeline_asm_emit_set_func_index(i);
    pipeline_debug_trace_named_func_bodies("mega_pre_reset" as *u8, m, a);
    pipeline_asm_ctx_reset_for_func_c(bctx, m);
    pipe_store_ptr_slot(bctx + (W328_CTX_DEP_PIPE as usize), 0, pipeline_ctx);
    pipeline_asm_emit_ctx_sret_active_set(0);
    pipeline_asm_emit_ctx_sret_home_off_set(neg1);
    pipeline_asm_emit_ctx_sret_ret_sz_set(0);
    pipeline_asm_fill_param_slots(bctx, m, i);
    pipeline_debug_trace_named_func_bodies("mega_post_param_slots" as *u8, m, a);
    /*
     * >16B return: mark sret active + record ret_sz. The 8B hidden-dest slot
     * itself is reserved in w499_mega_emit_frame AFTER fill_local_slots
     * (wave692) so 532-byte Type / 1224-byte Expr locals cannot overlap it.
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8.
     */
    if (ta == 0 || ta == 1) {
      pipe_store_i32_le(&cell[0], 0, glue_func_return_byte_size_c(m, a, i));
      v = w499h_c32(&cell[0]);
      if (v > 16) {
        pipeline_asm_emit_ctx_sret_ret_sz_set(v);
        pipeline_asm_emit_ctx_sret_active_set(1);
      }
    }
    pipeline_asm_register_module_top_level_lets_c(bctx, m, a, i);
    pipeline_debug_trace_named_func_bodies("mega_post_register_top_level" as *u8, m, a);
    /* Cap 4.2.8: export_sym is u8[256]; out_cap must be 256. */
    pipe_store_i32_le(&cell[0], 0, glue_asm_build_func_export_sym_c(m, a, i, export_sym, 256));
    v = w499h_c32(&cell[0]);
    if (v <= 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_label_arch(elf_ctx, export_sym, v, 1, ta));
    if (w499h_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, asm_skip_heavy_module_func_body(m, a, i));
    v = w499h_c32(&cell[0]);
    if (v != 0) {
      pipe_store_i32_le(&cell[0], 0, w499_mega_emit_skip_heavy(elf_ctx, ta, m, i));
      return w499h_c32(&cell[0]);
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_body_ref_at(m, i));
    body_ref = w499h_c32(&cell[0]);
    /*
     * w1048: pure `return callee(params)` → host-like 5-byte jmp stub.
     * Must run after label, before prologue (frame). Returns 1 = done.
     */
    pipe_store_i32_le(&cell[0], 0, w499_mega_try_tail_jmp(m, a, elf_ctx, bctx, ta, i, body_ref));
    tail = w499h_c32(&cell[0]);
    if (tail == 1) { return 0; }
    if (tail != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, w499_mega_emit_frame(m, a, elf_ctx, bctx, ta, i, body_ref));
    if (w499h_c32(&cell[0]) != 0) { return neg1; }
    if (body_ref != 0) {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_block_num_stmt_order_at(a, body_ref));
      nso = w499h_c32(&cell[0]);
      if (nso > 0) {
        pipe_store_i32_le(&cell[0], 0, w499_mega_emit_body_sync(m, a, elf_ctx, bctx, ta, body_ref));
        if (w499h_c32(&cell[0]) != 0) { return neg1; }
      } else {
        pipe_store_i32_le(&cell[0], 0, w499_mega_emit_body_inits(m, a, elf_ctx, bctx, ta, i, body_ref));
        if (w499h_c32(&cell[0]) != 0) { return neg1; }
      }
    } else {
      /* No body: still emit return expr (original monolith path). */
      pipe_store_i32_le(&cell[0], 0, w499_mega_emit_ret_expr(m, a, elf_ctx, bctx, ta, i));
      if (w499h_c32(&cell[0]) != 0) { return neg1; }
    }
    pipe_store_i32_le(&cell[0], 0, w499_mega_emit_epilogue(m, a, elf_ctx, ta, i));
    return w499h_c32(&cell[0]);
  }
}
