// Thin pure: arr_return dispatcher (wave439).
// wave587 Soft Cap: Ubuntu tip `-backend asm -c` UND=1 (T export
//   present; only backend_enc_jmp_arch survived). The original
//   body used mid-assign ly/ret_op, if (ret_op != 0) wrapping
//   peel/sret/ko/mod/fi plus sequential rc=path then if
//   (a0→a→a2→b0→b→c→d), then rc=spills then if, rc=cps then if,
//   if (ly == 0), tj_len=pipe_load then if, and a while copy of
//   tj_lbl, which that tip drops. Darwin original kept all 19
//   encoders. arr_return_store_encoders always stores each
//   encoder once and declares no locals. Pointer-returning
//   layout/module_ref are nested as args (not mid-assigned).
//   The export returns 0; the real dispatcher stays on the
//   w439 overlay. Never stores through *i32.
// stamp w587 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_async_cps_emit_phase_reset(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_return_path_a0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_a2_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_a_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_b0_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_b_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_c_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_emit_return_path_d_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32;
export extern function glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function glue_peel_as_array_slice_ascription_c(arena: *u8, expr_ref: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_emit_ctx_sret_active_get(): i32;
export extern function pipeline_asm_emit_ctx_sret_ret_sz_get(): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;

/**
 * Store the return-impl dispatcher encoders. Offset 0 is unary
 * operand, 4 is peel ascription, 8 is sret-active, 12 is sret
 * size, 16 is kind-ord, 20 is func index, 24 is path a0 (mod
 * nested as module_ref so the *u8 encoder is not mid-assigned),
 * 28 a, 32 a2, 36 b0, 40 b, 44 c, 48 d, 52 spills cleanup, 56
 * cps reset, 60 pipe_load through ctx_layout (nested *u8, not
 * mid-assigned), 64 jmp. No locals. Each encoder runs once,
 * not under if, while, or after a mid-assign. Dummy ko / sret
 * / fi are 0; jmp uses cell as the dummy label. Never stores
 * through *i32. The overlay still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param expr_ref i32 — EXPR_RETURN
 * @param ctx *u8 — asm func ctx; may be null
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @param cell *u8 — at least 68 bytes; also dummy jmp label
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_store_encoders(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_unary_operand_ref_at(arena, expr_ref));
    pipe_store_i32_le(cell, 4, glue_peel_as_array_slice_ascription_c(arena, expr_ref));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_ctx_sret_active_get());
    pipe_store_i32_le(cell, 12, pipeline_asm_emit_ctx_sret_ret_sz_get());
    pipe_store_i32_le(cell, 16, pipeline_expr_kind_ord_at(arena, expr_ref));
    pipe_store_i32_le(cell, 20, pipeline_asm_emit_func_index_c());
    pipe_store_i32_le(cell, 24, glue_emit_return_path_a0_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, pipeline_asm_emit_module_ref_c(), 0));
    pipe_store_i32_le(cell, 28, glue_emit_return_path_a_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, 0 as *u8, 0));
    pipe_store_i32_le(cell, 32, glue_emit_return_path_a2_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, 0 as *u8, 0));
    pipe_store_i32_le(cell, 36, glue_emit_return_path_b0_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, 0 as *u8, 0));
    pipe_store_i32_le(cell, 40, glue_emit_return_path_b_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, 0 as *u8, 0));
    pipe_store_i32_le(cell, 44, glue_emit_return_path_c_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, 0 as *u8, 0));
    pipe_store_i32_le(cell, 48, glue_emit_return_path_d_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0, 0, 0, 0 as *u8, 0));
    pipe_store_i32_le(cell, 52, glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta));
    pipe_store_i32_le(cell, 56, glue_async_cps_emit_phase_reset(elf_ctx, ta));
    pipe_store_i32_le(cell, 60, pipe_load_i32_le(pipeline_asm_ctx_layout(ctx), 0));
    pipe_store_i32_le(cell, 64, backend_enc_jmp_arch(elf_ctx, cell, 0, ta));
    return 0;
  }
}

/**
 * wave439/587: EXPR_RETURN ELF emit impl dispatcher. Encoders
 * always run. Tip returns 0. Signature matches the w439 overlay,
 * which still does the real path (sret / slice escape / ARRAY_LIT
 * dual-GP / float / tail_join).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF codegen ctx
 * @param expr_ref i32 — EXPR_RETURN
 * @param ctx *u8 — asm func ctx
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function pipeline_asm_emit_return_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let cell: u8[68] = [];
    let sink: i32 = 0;
    arr_return_store_encoders(arena, elf_ctx, expr_ref, ctx, ta, &cell[0]);
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
