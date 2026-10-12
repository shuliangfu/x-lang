// Thin pure: mega emit_one frame/prologue peer (wave499).
// G.7: part of w393_mega_emit_one (peer-flat under emit_one head).
// tipU: isolated leaf keeps num_params/compute_frame/fill_local/prologue.
// PRODUCT: LINUX+MACOS PREFER with emit_one head. PLATFORM: SHARED.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_debug_trace_named_func_bodies(phase: *u8, module: *u8, arena: *u8): void;
export extern function backend_enc_prologue_arch(elf_ctx: *u8, frame_sz: i32, ta: i32): i32;
export extern function pipeline_asm_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern function pipeline_asm_compute_frame_size_c(num_params: i32, arena: *u8, block_ref: i32, mod: *u8, func_index: i32): i32;
export extern function pipeline_asm_fill_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_home_off_set(off: i32): void;
export extern function pipeline_asm_emit_param_home_elf_c(elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32;
export extern function pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a: *u8, elf_ctx: *u8, ctx: *u8, m: *u8, func_index: i32, ta: i32): i32;
export extern function pipeline_asm_hoist_target_func_index(m: *u8): i32;
export extern function pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_async_cps_entry_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, mod: *u8, func_index: i32, ta: i32): i32;

/**
 * Load i32 from pipe cell (local name unique to this leaf — avoid multi-T clash).
 * @param base *u8 — cell base
 * @return i32
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499f_c32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Load *u8 from pipe ptr slot (unique name per leaf).
 * @param base *u8 — cell base
 * @return *u8
 * PLATFORM: SHARED — wave499 tipU helper.
 */
function w499f_cptr(base: *u8): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, 0);
  }
}

const W328_CTX_FRAME_SIZE: i32 = 0;
const W328_CTX_NEXT_OFFSET: i32 = 4;

/**
 * Frame size + prologue + param home + modlet seed + async cps entry.
 * @param body_ref i32 — module func body ref (0 skips frame fill)
 * @return 0 ok, -1 on emit failure
 * PLATFORM: SHARED — wave499 mega emit_one peer.
 */
#[no_mangle]
export function w499_mega_emit_frame(
    m: *u8, a: *u8, elf_ctx: *u8, bctx: *u8, ta: i32, i: i32, body_ref: i32): i32 {
  unsafe {
    let cell: u8[8];
    let pcell: u8[8];
    let neg1: i32 = 0 - 1;
    let frame_sz: i32 = 0;
    let nparams: i32 = 0;
    let ly_fs: *u8 = 0 as *u8;
    let hoist: i32 = 0;
    let z: *u8 = 0 as *u8;
    frame_sz = 0;
    if (body_ref != 0) {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_module_func_num_params_at(m, i));
      nparams = w499f_c32(&cell[0]);
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_compute_frame_size_c(nparams, a, body_ref, m, i));
      frame_sz = w499f_c32(&cell[0]);
      pipeline_debug_trace_named_func_bodies("mega_post_frame_size" as *u8, m, a);
      pipeline_asm_fill_local_slots(bctx, a, body_ref);
      pipeline_debug_trace_named_func_bodies("mega_post_fill_local_slots" as *u8, m, a);
    }
    /*
     * wave692: park the incoming sret dest pointer AFTER body locals.
     * next_offset+256 (pre-local) left a hole that 532-byte Type / 1224-byte
     * Expr locals filled, overlapping the saved pointer (force9 get_copy
     * smash). The home is the reserved slot itself; +8 is the reservation.
     * PLATFORM: LINUX+MACOS x86_64 SysV (rdi) · MACOS|ARM64 AAPCS64 x8.
     */
    if (ta == 0 || ta == 1) {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_ctx_sret_ret_sz_get());
      if (w499f_c32(&cell[0]) > 16) {
        /* fill_local_slots currently homes a >16B let at next_offset and may
         * leave next_offset at that let's START (8-byte bump only). Adding
         * ret_sz skips the under-reserved blob so the 8B dest pointer does
         * not sit inside the 532B Type / 1224B Expr local (w693 probe: both
         * at rbp-0x238, memset wiped the saved dest). Align 8. */
        pipe_store_i32_le(&cell[0], 4, pipe_load_i32_le(bctx, W328_CTX_NEXT_OFFSET) + w499f_c32(&cell[0]));
        pipe_store_i32_le(&cell[0], 4, (pipe_load_i32_le(&cell[0], 4) + 7) & (0 - 8));
        pipeline_asm_emit_ctx_sret_home_off_set(pipe_load_i32_le(&cell[0], 4));
        pipe_store_i32_le(bctx, W328_CTX_NEXT_OFFSET, pipe_load_i32_le(&cell[0], 4) + 8);
      }
    }
    pipe_store_i32_le(&cell[0], 0, backend_enc_prologue_arch(elf_ctx, frame_sz, ta));
    if (w499f_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_asm_ctx_layout(bctx));
    ly_fs = w499f_cptr(&pcell[0]);
    if (ly_fs != z) {
      pipe_store_i32_le(ly_fs, W328_CTX_FRAME_SIZE, frame_sz);
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_param_home_elf_c(elf_ctx, bctx, m, i, ta));
    if (w499f_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_module_top_level_mutable_lit_inits_elf_c(a, elf_ctx, bctx, m, i, ta));
    if (w499f_c32(&cell[0]) != 0) { return neg1; }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_hoist_target_func_index(m));
    hoist = w499f_c32(&cell[0]);
    if (i == hoist) {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_modlet_seed_nonzero_inits_elf_c(elf_ctx, ta));
      if (w499f_c32(&cell[0]) != 0) { return neg1; }
    }
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_async_cps_entry_elf_c(a, elf_ctx, bctx, m, i, ta));
    if (w499f_c32(&cell[0]) != 0) { return neg1; }
    return 0;
  }
}
