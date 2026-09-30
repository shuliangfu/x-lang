// Thin pure override of glue_slice_let_reent_deep_copy_after_dual_gp_elf_c.
// w1544: the egg body capped a CALL-returned slice at max_n elements
//   (1024 for bytes) and deep-copied only that prefix, so a callee's
//   slice longer than the cap was silently truncated (lexer saw only
//   the first 1024 source bytes when the slice came from a call used
//   directly as an argument). Now a slice longer than the cap is left
//   as-is (same aliasing as the host-C twin); only slices that fit
//   are deep-copied. Body otherwise identical to runtime_pipeline_abi.x.
// Built by g05_relink_env.sh _g05_pure_overlay on every relink.
// PLATFORM: SHARED freestanding. LINUX gold. MACOS. WINDOWS.

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
 * Deep-copy a CALL-returned slice into the caller frame, or leave it
 * aliased when the payload is longer than the cap.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer context
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch tag
 * @param home i32 — destination home slot
 * @param ty_ref i32 — slice element type ref
 * @param use_frame i32 — 1 when the dest is a frame slot
 * @return i32 — 0 on success, negative on failure
 * The filename contains "pipeline", so the entry-module prefix would emit
 * pipeline_glue_slice_let_reent_deep_copy_after_dual_gp_elf_c. The egg and
 * g05 both require the bare name.
 * PLATFORM: SHARED freestanding. LINUX gold. MACOS. WINDOWS.
 */
#[no_mangle]
export function glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(
    arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, home: i32, ty_ref: i32, use_frame: i32): i32 {
  unsafe {
  let max_n: i32 = 1024;
  let esz: i32 = 4;
  let nbytes: i32 = 0;
  let max_payload: i32 = 0;
  let loop_len: i32 = 0;
  let end_len: i32 = 0;
  let keep_len: i32 = 0;
  let seq: i32 = 0;
  let v: i32 = 0;
  let nd: i32 = 0;
  let di: i32 = 0;
  let llen: i32 = 0;
  let dest_off: i32 = 0 - 1;
  let src_spill: i32 = 0 - 1;
  let dst_spill: i32 = 0 - 1;
  let dest_base: i32 = 0;
  let fat_hi: i32 = 0;
  let noff: i32 = 0;
  let common_align: i32 = 0;
  let rc: i32 = 0;
  let loop_lbl: u8[32] = [];
  let end_lbl: u8[32] = [];
  let keep_lbl: u8[32] = [];
  let alias_lbl: u8[32] = [];
  let alias_len: i32 = 0;
  let q_rem: i32 = 0;
  let q_n: i32 = 0;
  let label: u8[24] = [];
  let digs: u8[8] = [];
  let pfx: u8[16] = [];
  // w1544: variable-index writes go through *u8 (no bounds-check xlang_panic_ ref).
  let label_p: *u8 = &label[0];
  let digs_p: *u8 = &digs[0];
  let pfx_p: *u8 = &pfx[0];

  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || home < 0 || ty_ref <= 0) {
    return 0 - 1;
  }
  if (ta != 0 && ta != 1) {
    return 0 - 1;
  }
  /*
   * Outer element stride of this TYPE_SLICE = index esz of ty_ref itself.
   * Peel-then-measure is wrong for [][]T: elem is TYPE_SLICE, and
   * glue_index_elem_byte_sz_from_type_ref_c peels again → sizeof(i32)=4
   * instead of fat 16 → deep-copy truncates each inner fat (asm a[0].length
   * wrong / a[0][1] panic; host-C typed E[] twin already correct).
   * G.7: reuse index_elem_byte_sz on the SLICE type (nested SLICE → 16).
   * PLATFORM: SHARED freestanding 4.2.7 nested CALL-return reent.
   */
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, ty_ref);
  if (esz <= 0) {
    esz = 4;
  }
  // wave632: esz>8 large NAMED / nested fat(16) kept; weird mid widths 3/5/6/7 fall to 4.
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8 && esz <= 8) {
    esz = 4;
  }
  // Scalar face 8KiB (wave418); large NAMED COMMON up to 64KiB (1024×64).
  // Let frame (use_frame=1) must stay ≤8KiB so arm64 prologue/sp imm stays in
  // the product encode path — nested fat esz=16 × max_n=1024 was 16KiB and
  // SEGVed on mac (4.2.7). COMMON call-arg path may use the larger ceiling.
  if (esz > 8) {
    if (use_frame != 0) {
      max_payload = 8192;
    } else {
      max_payload = 1024 * 64;
    }
  } else {
    max_payload = 8192;
  }
  // w1544: quotient by subtraction (esz is a runtime divisor; a / esz
  // would pull the divide-by-zero xlang_panic_ into this overlay).
  if (esz > 0) {
    q_rem = max_payload;
    q_n = 0;
    while (q_rem >= esz) {
      q_rem = q_rem - esz;
      q_n = q_n + 1;
    }
    if (max_n > q_n) {
      max_n = q_n;
    }
  }
  if (max_n <= 0) {
    max_n = 1;
  }
  nbytes = max_n * esz;
  if (nbytes <= 0 || nbytes > max_payload) {
    return 0 - 1;
  }

  // Cap length + park on CPU stack BEFORE allocating frame dest (wave418).
  // jge: max_n >= length → keep; else rbx=max_n. SHARED (no x86-only jle).
  unsafe {
    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, max_n, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_cmp_rax_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    keep_len = pipeline_asm_emit_next_label_c(ctx, &keep_lbl[0], 32);
  }
  if (keep_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_jge_arch(elf_ctx, &keep_lbl[0], keep_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // w1544: length > max_n → leave the fat slice as-is (no truncating copy).
  unsafe {
    alias_len = pipeline_asm_emit_next_label_c(ctx, &alias_lbl[0], 32);
  }
  if (alias_len <= 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_jmp_arch(elf_ctx, &alias_lbl[0], alias_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &keep_lbl[0], keep_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }

  if (use_frame != 0) {
    // Let path: per-frame buffer. Force dest past dual-GP fat window at home (16B).
    // PLATFORM: SHARED freestanding · LINUX|x86 high-end · MACOS|ARM64 low-end.
    noff = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
    dest_base = noff;
    if ((dest_base % 8) != 0) {
      dest_base = (dest_base + 7) / 8 * 8;
    }
    fat_hi = home + 16;
    if (dest_base < fat_hi) {
      dest_base = fat_hi;
    }
    if ((dest_base % 8) != 0) {
      dest_base = (dest_base + 7) / 8 * 8;
    }
    if (dest_base < 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      // MACOS|ARM64 low-end: byte0 @ dest_base, grows +.
      dest_off = dest_base;
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_base + nbytes);
    } else {
      // LINUX|x86 high-end: byte0 at deep end; +byteoff stays under rbp.
      dest_off = dest_base + nbytes;
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), dest_off);
    }
    if (dest_off < 0) {
      return 0 - 1;
    }
    glue_align_next_offset(ctx);
    llen = 0;
  } else {
    // Call-arg: unique COMMON per deep-copy site (dual same-call needs two buffers).
    common_align = esz;
    if (common_align > 16) {
      common_align = 16;
    }
    if (common_align < 1) {
      common_align = 1;
    }
    unsafe {
      seq = glue_pipeline_asm_al_nc_seq_take_c();
    }
    llen = 0;
    // "Lxlang_sd_"
    pfx[0] = 76 as u8;
    pfx[1] = 120 as u8;
    pfx[2] = 108 as u8;
    pfx[3] = 97 as u8;
    pfx[4] = 110 as u8;
    pfx[5] = 103 as u8;
    pfx[6] = 95 as u8;
    pfx[7] = 115 as u8;
    pfx[8] = 100 as u8;
    pfx[9] = 95 as u8;
    pfx[10] = 0 as u8;
    while (pfx_p[llen] != (0 as u8) && llen < 12) {
      label_p[llen] = pfx_p[llen];
      llen = llen + 1;
    }
    v = seq;
    nd = 0;
    if (v == 0) {
      digs[0] = 48 as u8;
      nd = 1;
    } else {
      while (v > 0 && nd < 8) {
        digs_p[nd] = (48 + (v % 10)) as u8;
        nd = nd + 1;
        v = v / 10;
      }
    }
    di = nd - 1;
    while (di >= 0 && llen < 23) {
      label_p[llen] = digs_p[di];
      llen = llen + 1;
      di = di - 1;
    }
    unsafe {
      rc = pipeline_elf_ctx_add_common_sym(elf_ctx, &label[0], llen, nbytes, common_align);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }

  // wave632: bulk esz>8 needs two pointer spills (src/dst) for chunked copy.
  if (esz > 8) {
    noff = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
    if (noff + 32 < noff) {
      return 0 - 1;
    }
    noff = noff + 16;
    src_spill = noff;
    noff = noff + 16;
    dst_spill = noff;
    pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), noff);
  }

  unsafe {
    loop_len = pipeline_asm_emit_next_label_c(ctx, &loop_lbl[0], 32);
  }
  unsafe {
    end_len = pipeline_asm_emit_next_label_c(ctx, &end_lbl[0], 32);
  }
  if (loop_len <= 0 || end_len <= 0) {
    return 0 - 1;
  }

  // ai = 0 parked on stack (zero frame growth; push/pop only).
  unsafe {
    rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &loop_lbl[0], loop_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }

  // stack invariant at loop head: [ai]; if ai >= length → end.
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_cmp_rax_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_jge_arch(elf_ctx, &end_lbl[0], end_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }

  // Body: value = *(data + ai*esz); *(dest + ai*esz) = value; ai++; jmp loop.
  // PLATFORM: SHARED — ptr + byteoff must use 64-bit ADD (scale1). arm64
  // add_rax_rbx is ADD W (u32 wrap) and truncates Darwin user pointers → SEGV
  // on sub[i] after deep-copy (mac pure-asm run-slice subslice_split_chunks).
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }

  if (esz > 8) {
    // bulk: src = data+ai*esz; dst = dest_base+ai*esz; chunked copy esz bytes.
    if (src_spill < 0 || dst_spill < 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // src = fat.data + byteoff
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // recompute byteoff from [ai]; dst = dest_base + byteoff
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (use_frame != 0) {
      unsafe {
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, dest_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    } else if (ta == 1) {
      rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
      if (rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta);
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    // scalar: byteoff = ai * esz → load elem → store to dest
    unsafe {
      rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // src load: data + byteoff
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (esz == 1) {
      unsafe {
        rc = backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
      }
    } else if (esz == 8) {
      unsafe {
        rc = backend_enc_load_64_from_rax_arch(elf_ctx, ta);
      }
    } else {
      unsafe {
        rc = backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
      }
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }

    // dest: frame or COMMON + ai*esz. Recompute byteoff from ai under value.
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // rax still = ai (push does not clobber); byteoff = ai*esz
    unsafe {
      rc = backend_enc_mov_imm32_to_rbx_arch(elf_ctx, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_imul_rbx_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // lea dest (frame or COMMON) → rbx; rbx += byteoff; pop value → store indirect
    if (use_frame != 0) {
      unsafe {
        rc = backend_enc_lea_rbp_to_rbx_arch(elf_ctx, dest_off, ta);
      }
      if (rc != 0) {
        return 0 - 1;
      }
    } else if (ta == 1) {
      rc = glue_asm_lea_rbx_common_adrp_arm64(elf_ctx, &label[0], llen);
      if (rc != 0) {
        return 0 - 1;
      }
    } else {
      rc = glue_asm_lea_rbx_common_rip_x86(elf_ctx, &label[0], llen);
      if (rc != 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    // Need dest in rbx for store_rax_to_rbx_indirect: mov rax → rbx, then pop value → rax.
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_store_rax_to_rbx_indirect_arch(elf_ctx, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }

  // ai++ ; jmp loop. stack [ai]
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_add_imm_to_rax_arch(elf_ctx, 1, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_jmp_arch(elf_ctx, &loop_lbl[0], loop_len, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }

  // end: stack still [capped_len, ai] from jge path — discard ai.
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &end_lbl[0], end_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }

  // retarget fat.data → frame dest or COMMON
  if (use_frame != 0) {
    unsafe {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, dest_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  } else if (ta == 1) {
    rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
    if (rc != 0) {
      return 0 - 1;
    }
  } else {
    rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // Restore fat.length from parked capped_len (stack: [capped_len]).
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_label_arch(elf_ctx, &alias_lbl[0], alias_len, 0, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
  }
}
