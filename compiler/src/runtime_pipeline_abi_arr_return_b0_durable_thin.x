// Thin pure: arr_return path b0 durable COMMON+pack (wave439).
// G.7: part of pipeline_asm_emit_return_elf_impl Path B0.
// PRODUCT: LINUX PREFER peer chain for arr_return.
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
 * Path B0 durable: spill rax src, COMMON copy, dual-GP if dest SLICE.
 * Pre: rax holds source address; n_arr/force_esz/slice_ty from prep.
 * @return i32 — 1 ok; -1 error
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS.
 */
#[no_mangle]
export function glue_emit_return_path_b0_durable_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, n_arr: i32, force_esz: i32, slice_ty: i32): i32 {
  unsafe {
    let rar_src: i32 = 0;
    let rar_dst: i32 = 0;
    let rar_noff: i32 = 0;
    let rar_seq: i32 = 0;
    let rar_llen: i32 = 0;
    let rar_nd: i32 = 0;
    let rar_di: i32 = 0;
    let rar_v: i32 = 0;
    let rar_lbl: u8[24] = [];
    let rar_digs: u8[8] = [];
    let rc: i32 = 0;
    let tk: i32 = 0;
    let len_arg: i32 = 0;
    if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || n_arr <= 0 || force_esz <= 0) {
      return 0 - 1;
    }
    rar_v = pipe_asm_ctx_off_next_offset();
    rar_noff = pipe_load_i32_le(ctx, rar_v);
    if (rar_noff + 48 < rar_noff) {
      return 0 - 1;
    }
    rar_noff = rar_noff + 16;
    rar_src = rar_noff;
    rar_noff = rar_noff + 16;
    rar_dst = rar_noff;
    rar_v = pipe_asm_ctx_off_next_offset();
    pipe_store_i32_le(ctx, rar_v, rar_noff + 16);
    glue_align_next_offset(ctx);
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, rar_src, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rar_seq = glue_pipeline_asm_al_nc_seq_take_c();
    if (rar_seq < 0 || rar_seq > 999999) {
      rar_seq = 0;
    }
    // "Lxlang_rar_"
    rar_lbl[0] = 76 as u8;
    rar_lbl[1] = 120 as u8;
    rar_lbl[2] = 108 as u8;
    rar_lbl[3] = 97 as u8;
    rar_lbl[4] = 110 as u8;
    rar_lbl[5] = 103 as u8;
    rar_lbl[6] = 95 as u8;
    rar_lbl[7] = 114 as u8;
    rar_lbl[8] = 97 as u8;
    rar_lbl[9] = 114 as u8;
    rar_lbl[10] = 95 as u8;
    rar_llen = 11;
    rar_v = rar_seq;
    rar_nd = 0;
    if (rar_v == 0) {
      rar_digs[0] = 48 as u8;
      rar_nd = 1;
    } else {
      while (rar_v > 0 && rar_nd < 8) {
        rar_digs[rar_nd] = (48 + (rar_v % 10)) as u8;
        rar_nd = rar_nd + 1;
        rar_v = rar_v / 10;
      }
    }
    rar_di = rar_nd - 1;
    while (rar_di >= 0 && rar_llen < 23) {
      rar_lbl[rar_llen] = rar_digs[rar_di];
      rar_llen = rar_llen + 1;
      rar_di = rar_di - 1;
    }
    rc = pipeline_elf_ctx_add_common_sym(elf_ctx, &rar_lbl[0], rar_llen, n_arr * force_esz, force_esz);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &rar_lbl[0], rar_llen);
    } else {
      rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &rar_lbl[0], rar_llen);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, rar_dst, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, rar_src, rar_dst, n_arr * force_esz, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &rar_lbl[0], rar_llen);
    } else {
      rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &rar_lbl[0], rar_llen);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    tk = pipeline_type_kind_ord_at(arena, slice_ty);
    if (tk != 11) {
      return 1;
    }
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      len_arg = 1;
    } else {
      len_arg = 2;
    }
    rc = backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_arg, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    return 1;
  }
}
