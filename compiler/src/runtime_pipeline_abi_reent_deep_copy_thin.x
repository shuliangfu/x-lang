// Thin pure override 4.2.7 nested reent deep-copy esz.
// wave589 Soft Cap: Ubuntu tip `-backend asm -c` wrote an empty .o
//   (rc=0). The original body used if-before-call, mid-assign of
//   esz/rc/noff/v/llen, `rc=call` then if, nested while (COMMON
//   digit fill), local `u8[32]`/`u8[24]`/`u8[8]`/`u8[16]` label
//   buffers, and branch-gated encoder calls (use_frame / esz>8 /
//   ta==1), which that tip drops. Darwin original kept all 36
//   encoders. reent_deep_copy_store_encoders always stores each
//   i32 encoder once and calls each void encoder once. The export
//   returns 0; the real dispatcher stays on the w410 overlay.
//   Never stores through *i32.
// stamp w589 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, buf_size: i32): i32;
export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function glue_pipeline_asm_al_nc_seq_take_c(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32;
export extern function glue_asm_lea_rax_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rax_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rbx_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rbx_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rbx_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cmp_rax_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_jge_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_label_arch(elf_ctx: *u8, name: *u8, name_len: i32, is_global: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rbx_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_jmp_arch(elf_ctx: *u8, label: *u8, label_len: i32, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_imul_rbx_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_rax_plus_rbx_scale1_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx: *u8, elem_sz: i32, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;

/**
 * Store the reent deep-copy encoders. Void glue_align_next_offset
 * runs once first. Each i32 encoder is pipe_store_i32_le'd once.
 * Dummy label/name dest is cell (not a local u8[N] buffer). Dummy
 * type/offset/esz/spill args are 0 or the overlay params. No
 * locals. Each encoder runs once, not under if, while, or after a
 * mid-assign. The overlay still does the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ctx *u8 — asm func ctx; may be null
 * @param ta i32 — 0 x86_64 SysV / 1 arm64 AAPCS64
 * @param home i32 — fat data home (rbp-relative); dummy offset
 * @param ty_ref i32 — TYPE_SLICE type_ref; dummy type
 * @param use_frame i32 — 1 frame / 0 COMMON; dummy imm
 * @param cell *u8 — at least 136 bytes; also dummy *u8 dest
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function reent_deep_copy_store_encoders(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, home: i32, ty_ref: i32, use_frame: i32, cell: *u8): i32 {
  unsafe {
    glue_align_next_offset(ctx);
    pipe_store_i32_le(cell, 0, glue_index_elem_byte_sz_from_type_ref_c(arena, ty_ref));
    pipe_store_i32_le(cell, 4, glue_slice_dual_gp_length_off_c(home, ta));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_next_label_c(ctx, cell, 32));
    pipe_store_i32_le(cell, 12, glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, 0, 0, 0, ta));
    pipe_store_i32_le(cell, 16, glue_pipeline_asm_al_nc_seq_take_c());
    pipe_store_i32_le(cell, 20, pipe_load_i32_le(ctx, 0));
    pipe_store_i32_le(cell, 24, pipe_asm_ctx_off_next_offset());
    pipe_store_i32_le(cell, 28, pipeline_elf_ctx_add_common_sym(elf_ctx, cell, 0, 0, 0));
    pipe_store_i32_le(cell, 32, glue_asm_lea_rax_common_adrp_arm64(elf_ctx, cell, 0));
    pipe_store_i32_le(cell, 36, glue_asm_lea_rax_common_rip_x86(elf_ctx, cell, 0));
    pipe_store_i32_le(cell, 40, glue_asm_lea_rbx_common_adrp_arm64(elf_ctx, cell, 0));
    pipe_store_i32_le(cell, 44, glue_asm_lea_rbx_common_rip_x86(elf_ctx, cell, 0));
    pipe_store_i32_le(cell, 48, backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta));
    pipe_store_i32_le(cell, 52, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 56, backend_enc_pop_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 60, backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta));
    pipe_store_i32_le(cell, 64, backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta));
    pipe_store_i32_le(cell, 68, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 72, backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 76, backend_enc_cmp_rax_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 80, backend_enc_jge_arch(elf_ctx, cell, 0, ta));
    pipe_store_i32_le(cell, 84, backend_enc_label_arch(elf_ctx, cell, 0, 0, ta));
    pipe_store_i32_le(cell, 88, backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta));
    pipe_store_i32_le(cell, 92, backend_enc_lea_rbp_to_rbx_arch(elf_ctx, home, ta));
    pipe_store_i32_le(cell, 96, backend_enc_jmp_arch(elf_ctx, cell, 0, ta));
    pipe_store_i32_le(cell, 100, backend_enc_push_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 104, backend_enc_mov_imm32_to_rbx_arch(elf_ctx, use_frame, ta));
    pipe_store_i32_le(cell, 108, backend_enc_imul_rbx_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 112, backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 116, backend_enc_load_64_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 120, backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 124, backend_enc_load_zext8_from_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 128, backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 132, backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta));
    return 0;
  }
}

/**
 * Deep-copy TYPE_SLICE payload after dual-GP is stored at home, then retarget
 * fat.data to the new buffer (frame or SHN_COMMON).
 *
 * wave589 tip: encoders always run. Returns 0. Signature matches the
 * w410 overlay, which still does the real path (cap length, frame or
 * COMMON dest, scalar/bulk copy loop, retarget fat.data).
 *
 * @param arena *u8 — ASTArena*; null accepted on this tip
 * @param elf_ctx *u8 — ElfCodegenCtx*; null accepted on this tip
 * @param ctx *u8 — AsmFuncCtx*; null accepted on this tip
 * @param ta i32 — 0=x86_64 SysV high-end; 1=arm64 AAPCS64 low-end
 * @param home i32 — fat data home (rbp-relative)
 * @param ty_ref i32 — TYPE_SLICE type_ref
 * @param use_frame i32 — 1 = frame buffer (let recursion); 0 = SHN_COMMON
 * @return i32 — 0 on this tip; overlay returns 0 / -1
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(
    arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, home: i32, ty_ref: i32, use_frame: i32): i32 {
  unsafe {
    let cell: u8[136] = [];
    let sink: i32 = 0;
    reent_deep_copy_store_encoders(arena, elf_ctx, ctx, ta, home, ty_ref, use_frame, &cell[0]);
    sink = ta + home + ty_ref + use_frame;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (arena == (0 as *u8) && elf_ctx == (0 as *u8) && ctx == (0 as *u8)) {
      return 0;
    }
    return 0;
  }
}
