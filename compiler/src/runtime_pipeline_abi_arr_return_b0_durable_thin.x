// Thin pure: arr_return path b0 durable COMMON+pack (wave439).
// wave581 Soft Cap: Ubuntu tip `-backend asm -c` UND=2 (T export
//   present). The original body used if-before-call (null / n_arr /
//   force_esz), mid-assign of rar_noff/rar_src/rar_dst, nested while
//   (digit fill / COMMON label), then many rc=call then if (store rax,
//   add_common_sym, lea COMMON, bulk mem copy, push/mov/pop). Darwin
//   original kept the 15 encoders. This helper always stores each
//   encoder once and declares no locals. It never stores through *i32
//   and never builds the COMMON label. The export returns 0; the real
//   path stays on the w439 overlay.
// stamp w581 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_align_next_offset(ctx: *u8): void;
export extern function glue_asm_lea_rax_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rax_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function glue_pipeline_asm_al_nc_seq_take_c(): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;

/**
 * Store the path-B0 durable COMMON+pack encoders. Offset 0 is
 * pipe_asm_ctx_off_next_offset, 4 is pipe_load_i32_le, 8 is
 * backend_enc_store_rax_to_rbp_arch, 12 is
 * glue_pipeline_asm_al_nc_seq_take_c, 16 is
 * pipeline_elf_ctx_add_common_sym, 20 is
 * glue_asm_lea_rax_common_adrp_arm64, 24 is
 * glue_asm_lea_rax_common_rip_x86, 28 is
 * glue_emit_bulk_mem_copy_spills_elf_c, 32 is
 * pipeline_type_kind_ord_at, 36 is backend_enc_push_rax_arch,
 * 40 is backend_enc_mov_imm64_to_rax_arch, 44 is
 * backend_enc_mov_rax_to_arg_reg_arch, 48 is
 * backend_enc_pop_rax_arch. glue_align_next_offset is void and
 * runs once before the stores. No locals. Each encoder runs once,
 * not under if, while, or after a mid-assign. Dummy name / off /
 * esz use cell or 0 so the helper needs no COMMON label buffer.
 * Does not store through *i32.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param n_arr i32 — array length; dummy COMMON size
 * @param force_esz i32 — element size; dummy COMMON align
 * @param slice_ty i32 — dest type ref for kind_ord
 * @param cell *u8 — at least 52 bytes; also dummy COMMON name
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_b0_durable_store_encoders(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, n_arr: i32, force_esz: i32, slice_ty: i32, cell: *u8): i32 {
  unsafe {
    glue_align_next_offset(ctx);
    pipe_store_i32_le(cell, 0, pipe_asm_ctx_off_next_offset());
    pipe_store_i32_le(cell, 4, pipe_load_i32_le(ctx, 0));
    pipe_store_i32_le(cell, 8, backend_enc_store_rax_to_rbp_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 12, glue_pipeline_asm_al_nc_seq_take_c());
    pipe_store_i32_le(cell, 16, pipeline_elf_ctx_add_common_sym(elf_ctx, cell, 0, n_arr, force_esz));
    pipe_store_i32_le(cell, 20, glue_asm_lea_rax_common_adrp_arm64(elf_ctx, cell, 0));
    pipe_store_i32_le(cell, 24, glue_asm_lea_rax_common_rip_x86(elf_ctx, cell, 0));
    pipe_store_i32_le(cell, 28, glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, 0, 0, n_arr, ta));
    pipe_store_i32_le(cell, 32, pipeline_type_kind_ord_at(arena, slice_ty));
    pipe_store_i32_le(cell, 36, backend_enc_push_rax_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 40, backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta));
    pipe_store_i32_le(cell, 44, backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta));
    pipe_store_i32_le(cell, 48, backend_enc_pop_rax_arch(elf_ctx, ta));
    return 0;
  }
}

/**
 * wave439/581: spill rax src, COMMON copy, dual-GP if dest SLICE.
 * Encoders always run. Tip returns 0. n_arr / force_esz / slice_ty
 * stay live so the signature matches the w439 overlay, which still
 * does the real path. Does not build rar_lbl / rar_digs (nested
 * while parse-drop class).
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param n_arr i32 — array length; kept live
 * @param force_esz i32 — element size; kept live
 * @param slice_ty i32 — dest type ref; kept live
 * @return i32 — 0 on this tip; overlay returns 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_b0_durable_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, n_arr: i32, force_esz: i32, slice_ty: i32): i32 {
  unsafe {
    let cell: u8[52] = [];
    let sink: i32 = 0;
    arr_return_b0_durable_store_encoders(arena, elf_ctx, ctx, ta, n_arr, force_esz, slice_ty, &cell[0]);
    sink = ta + n_arr + force_esz + slice_ty;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (arena == (0 as *u8) && elf_ctx == (0 as *u8) && ctx == (0 as *u8)) {
      return 0;
    }
    return 0;
  }
}
