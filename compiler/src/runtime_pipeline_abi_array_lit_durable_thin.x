// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
// 10.22 Linux tip peel: strong glue_asm_emit_array_lit_durable_ptr_rax_elf_c
// (pabi_alias only has hollow W). Extracted from runtime_pipeline_abi.x.
// PLATFORM: SHARED — LINUX x86_64 tip · MACOS Cap tip already strong via mega.


export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, ai: i32): i32;
export extern function pipeline_expr_int_val_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_mov_imm64_to_rax_arch(elf_ctx: *u8, lo: i32, hi: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function glue_align_next_offset(ctx: *u8): void;
export extern function pipeline_elf_ctx_emit_bytes(elf_ctx: *u8, bytes: *u8, n: i32): i32;
export extern function pipeline_elf_ctx_text_size(elf_ctx: *u8): i32;
export extern function pipeline_elf_ctx_add_label(elf_ctx: *u8, name: *u8, nlen: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, tr: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function pipe_modlet_bake_array_lit_elems_to_data(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8): i32;
export extern function pipeline_expr_float_bits_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_elf_ctx_emit_u8(elf_ctx: *u8, b: i32): i32;
export extern function pipeline_elf_ctx_emit_u32(elf_ctx: *u8, v: i32): i32;
export extern function pipeline_elf_ctx_current_text_off(elf_ctx: *u8): i32;
export extern function backend_enc_emit_raw_bytes_arch(elf_ctx: *u8, bytes: *u8, n: i32, ta: i32): i32;



export extern function pipeline_elf_ctx_append_bytes(ctx_bytes: *u8, ptr: *u8, n: i32): i32;
export extern function pipeline_elf_ctx_add_common_sym(ctx_bytes: *u8, name: *u8, name_len: i32, sym_size: i32, sym_align: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit_expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_pipeline_asm_al_nc_seq_take_c(): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena: *u8, elf_ctx: *u8, array_lit_ref: i32, elem_ref: i32, ctx: *u8, ta: i32, force_esz: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx: *u8, src_spill: i32, dst_spill: i32, esz: i32, ta: i32): i32;
export extern function glue_emit_fixed_array_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32, stack_slot_off: i32): i32;
export extern function glue_emit_slice_from_array_let_init_elf_c(arena: *u8, elf_ctx: *u8, block_ref: i32, let_idx: i32, init_ref: i32, let_type_ref: i32, ctx: *u8, ta: i32, slice_slot_off: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;
export extern function glue_asm_lea_rax_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rax_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rbx_common_adrp_arm64(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_lea_rbx_common_rip_x86(elf_ctx: *u8, name: *u8, name_len: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, slot_off: i32, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;

#[no_mangle]
export function glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, force_esz: i32, ta: i32, ctx: *u8, dest_elem_ty: i32): i32 {
  unsafe {
  let n_arr: i32 = 0;
  let esz: i32 = 0;
  let ai: i32 = 0;
  let nbytes: i32 = 0;
  let bi: i32 = 0;
  let elem_ref: i32 = 0;
  let eko: i32 = 0;
  let all_const: i32 = 1;
  let v64_lo: i32 = 0;
  let v64_hi: i32 = 0;
  let payload: u8[4096] = [];
  let jmp_near: u8[5] = [];
  let jmp_short: u8[2] = [];
  let lea7: u8[7] = [];
  let disp32: i32 = 0;
  let rel32: i32 = 0;
  let label: u8[24] = [];
  let llen: i32 = 0;
  let seq: i32 = 0;
  let v: i32 = 0;
  let nd: i32 = 0;
  let di: i32 = 0;
  let digs: u8[8] = [];
  let pfx: u8[12] = [];
  let rc: i32 = 0;
  let ko: i32 = 0;
  let common_align: i32 = 0;
  let elem_ty: i32 = 0;
  let src_spill: i32 = 0;
  let dst_spill: i32 = 0;
  let temp_home: i32 = 0;
  let elem_reserve: i32 = 0;
  let st: i32 = 0;
  let noff: i32 = 0;
  let data_spill: i32 = 0;
  let len_spill: i32 = 0;
  let etk: i32 = 0;
  let b: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || expr_ref <= 0 || (ta != 0 && ta != 1)) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 46) {
    return 0 - 1;
  }
  unsafe {
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
  }
  if (n_arr < 0 || n_arr > 1024) {
    return 0 - 1;
  }
  if (n_arr == 0) {
    unsafe {
      rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
      if (rc < 0) {
        return 0 - 1;
      }
      return 0;
    }
  }
  esz = force_esz;
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    if (force_esz > 8) {
      esz = force_esz;
    } else {
      if (force_esz > 0) {
        return 0 - 1;
      } else {
        esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, expr_ref);
      }
    }
  }
  if (esz <= 0) {
    return 0 - 1;
  }
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8 && esz <= 8) {
    return 0 - 1;
  }
  // GLUE_ARRAY_LIT_MAX_PAYLOAD = 4096
  if (n_arr > 4096 / esz) {
    return 0 - 1;
  }
  nbytes = n_arr * esz;
  if (nbytes <= 0 || nbytes > 4096) {
    return 0 - 1;
  }
  all_const = 1;
  ai = 0;
  while (ai < n_arr) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    }
    if (elem_ref <= 0) {
      return 0 - 1;
    }
    unsafe {
      eko = pipeline_expr_kind_ord_at(arena, elem_ref);
    }
    if (eko != 0 && eko != 2) {
      all_const = 0;
    }
    ai = ai + 1;
  }
  // PLATFORM: LINUX+MACOS x86_64 — jmp-over text-embed + lea [rip] (const scalar only).
  if (all_const != 0 && ta == 0 && (esz == 1 || esz == 2 || esz == 4 || esz == 8)) {
    ai = 0;
    while (ai < n_arr) {
      unsafe {
        elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
        v64_lo = pipeline_expr_int_val_at(arena, elem_ref);
      }
      v64_hi = 0;
      // sign-extend high for negative i32 when packing 8B
      if (v64_lo < 0) {
        v64_hi = 0 - 1;
      }
      bi = ai * esz;
      if (esz == 1) {
        payload[bi] = (v64_lo & 255) as u8;
      } else {
        if (esz == 2) {
          payload[bi] = (v64_lo & 255) as u8;
          payload[bi + 1] = ((v64_lo >> 8) & 255) as u8;
        } else {
          if (esz == 4) {
            payload[bi] = (v64_lo & 255) as u8;
            payload[bi + 1] = ((v64_lo >> 8) & 255) as u8;
            payload[bi + 2] = ((v64_lo >> 16) & 255) as u8;
            payload[bi + 3] = ((v64_lo >> 24) & 255) as u8;
          } else {
            payload[bi] = (v64_lo & 255) as u8;
            payload[bi + 1] = ((v64_lo >> 8) & 255) as u8;
            payload[bi + 2] = ((v64_lo >> 16) & 255) as u8;
            payload[bi + 3] = ((v64_lo >> 24) & 255) as u8;
            payload[bi + 4] = (v64_hi & 255) as u8;
            payload[bi + 5] = ((v64_hi >> 8) & 255) as u8;
            payload[bi + 6] = ((v64_hi >> 16) & 255) as u8;
            payload[bi + 7] = ((v64_hi >> 24) & 255) as u8;
          }
        }
      }
      ai = ai + 1;
    }
    if (nbytes <= 127) {
      jmp_short[0] = 235 as u8; // 0xeb
      jmp_short[1] = nbytes as u8;
      unsafe {
        rc = pipeline_elf_ctx_append_bytes(elf_ctx, &jmp_short[0], 2);
      }
      if (rc < 0) {
        return 0 - 1;
      }
    } else {
      rel32 = nbytes;
      jmp_near[0] = 233 as u8; // 0xe9
      jmp_near[1] = (rel32 & 255) as u8;
      jmp_near[2] = ((rel32 >> 8) & 255) as u8;
      jmp_near[3] = ((rel32 >> 16) & 255) as u8;
      jmp_near[4] = ((rel32 >> 24) & 255) as u8;
      unsafe {
        rc = pipeline_elf_ctx_append_bytes(elf_ctx, &jmp_near[0], 5);
      }
      if (rc < 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = pipeline_elf_ctx_append_bytes(elf_ctx, &payload[0], nbytes);
    }
    if (rc < 0) {
      return 0 - 1;
    }
    disp32 = 0 - nbytes - 7;
    lea7[0] = 72 as u8; // 0x48
    lea7[1] = 141 as u8; // 0x8d
    lea7[2] = 5 as u8; // rax
    lea7[3] = (disp32 & 255) as u8;
    lea7[4] = ((disp32 >> 8) & 255) as u8;
    lea7[5] = ((disp32 >> 16) & 255) as u8;
    lea7[6] = ((disp32 >> 24) & 255) as u8;
    unsafe {
      rc = pipeline_elf_ctx_append_bytes(elf_ctx, &lea7[0], 7);
      if (rc < 0) {
        return 0 - 1;
      }
      return 0;
    }
  }
  // COMMON path needs ctx for non-const / large-NAMED
  if ((all_const == 0 || esz > 8) && ctx == (0 as *u8)) {
    return 0 - 1;
  }
  unsafe {
    seq = glue_pipeline_asm_al_nc_seq_take_c();
  }
  llen = 0;
  // "Lxlang_al_"
  pfx[0] = 76 as u8; pfx[1] = 120 as u8; pfx[2] = 108 as u8; pfx[3] = 97 as u8;
  pfx[4] = 110 as u8; pfx[5] = 103 as u8; pfx[6] = 95 as u8; pfx[7] = 97 as u8;
  pfx[8] = 108 as u8; pfx[9] = 95 as u8; pfx[10] = 0 as u8;
  while (pfx[llen] != (0 as u8) && llen < 12) {
    label[llen] = pfx[llen];
    llen = llen + 1;
  }
  v = seq;
  nd = 0;
  if (v == 0) {
    digs[0] = 48 as u8; // '0'
    nd = 1;
  } else {
    while (v > 0 && nd < 8) {
      digs[nd] = (48 + (v % 10)) as u8;
      nd = nd + 1;
      v = v / 10;
    }
  }
  di = nd - 1;
  while (di >= 0 && llen < 23) {
    label[llen] = digs[di];
    llen = llen + 1;
    di = di - 1;
  }
  common_align = esz;
  if (common_align > 16) {
    common_align = 16;
  }
  if (common_align < 1) {
    common_align = 1;
  }
  unsafe {
    rc = pipeline_elf_ctx_add_common_sym(elf_ctx, &label[0], llen, nbytes, common_align);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // large NAMED / esz>8 / TYPE_ARRAY row bulk into COMMON.
  // `[][2]i32` has esz==8 (sizeof([2]i32)); the old `esz > 8` gate fell
  // through to scalar store and wrote a pointer per row. INDEX then
  // leave-addr + load read pointer bits (exit 240..255). G.7: same
  // memcpy-row path as >8B NAMED, but TYPE_ARRAY rows go through
  // glue_emit_fixed_array_type_let_init (ARRAY_LIT flatten / VAR copy).
  // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
  // Dest elem wins over an unstamped / inferred ARRAY_LIT type. Module
  // dest-SLICE `[][]T` has no check_block coerce; dest elem is TYPE_SLICE.
  // PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
  if (dest_elem_ty > 0) {
    elem_ty = dest_elem_ty;
  }
  if (elem_ty > 0) {
    unsafe {
      etk = pipeline_type_kind_ord_at(arena, elem_ty);
    }
  } else {
    etk = 0;
  }
  if (esz > 8 || etk == 10 || (etk == 11 && esz == 16)) {
    if (ctx == (0 as *u8)) {
      return 0 - 1;
    }
    // TYPE_SLICE fat elements (esz==16)
    if (elem_ty > 0 && etk == 11 && esz == 16) {
      noff = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
      if (noff + 48 < noff) {
        return 0 - 1;
      }
      noff = noff + 16;
      data_spill = noff;
      noff = noff + 16;
      len_spill = noff;
      noff = noff + 16;
      src_spill = noff;
      noff = noff + 16;
      dst_spill = noff;
      temp_home = noff + 16;
      pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), temp_home + 16);
      glue_align_next_offset(ctx);
      ai = 0;
      while (ai < n_arr) {
        unsafe {
          elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
        }
        if (elem_ref <= 0) {
          return 0 - 1;
        }
        // ARRAY_LIT row: write fat into temp_home via dest-SLICE authority,
        // then memcpy 16B into COMMON. emit_expr+rdx left garbage length
        // (nslidx 32/134 flake). G.7: same helper as [N][]T let-init.
        // PLATFORM: SHARED freestanding.
        st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, 0, 0, elem_ref, elem_ty, ctx, ta, temp_home);
        if (st == 0 - 1) {
          return 0 - 1;
        }
        if (st == 0) {
          unsafe {
            rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, data_spill, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_store_rdx_to_rbp_arch(elf_ctx, len_spill, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, data_spill, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, temp_home, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, len_spill, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
          unsafe {
            rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(temp_home, ta), ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        unsafe {
          rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta);
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
        if (ta == 1) {
          unsafe {
            rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
          }
        } else {
          unsafe {
            rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
          }
        }
        if (rc != 0) {
          return 0 - 1;
        }
        if (ai * esz != 0) {
          unsafe {
            rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
          }
          if (rc != 0) {
            return 0 - 1;
          }
        }
        unsafe {
          rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        unsafe {
          rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, 16, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
        ai = ai + 1;
      }
      if (ta == 1) {
        unsafe {
          rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
          if (rc < 0) {
            return 0 - 1;
          }
          return 0;
        }
      }
      unsafe {
        rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
        if (rc < 0) {
          return 0 - 1;
        }
        return 0;
      }
    }
    // large NAMED bulk
    noff = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
    if (noff + 32 < noff) {
      return 0 - 1;
    }
    noff = noff + 16;
    src_spill = noff;
    noff = noff + 16;
    dst_spill = noff;
    pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), noff);
    elem_reserve = (esz + 7) & (0 - 8);
    if (elem_reserve < 8) {
      elem_reserve = 8;
    }
    noff = pipe_load_i32_le(ctx, pipe_asm_ctx_off_next_offset());
    if (noff + elem_reserve < noff) {
      return 0 - 1;
    }
    noff = noff + elem_reserve;
    pipe_store_i32_le(ctx, pipe_asm_ctx_off_next_offset(), noff);
    temp_home = noff;
    ai = 0;
    while (ai < n_arr) {
      unsafe {
        elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
      }
      if (elem_ref <= 0) {
        return 0 - 1;
      }
      unsafe {
        if (etk == 10 && elem_ty > 0) {
          // TYPE_ARRAY row: flatten ARRAY_LIT / copy VAR into temp, then memcpy.
          st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, elem_ty, temp_home);
        } else if (elem_ty > 0) {
          st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, elem_ty, temp_home);
        } else {
          st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, 0, temp_home);
        }
      }
      if (st != 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta);
      }
      if (rc < 0) {
        return 0 - 1;
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
      }
      if (rc < 0) {
        return 0 - 1;
      }
      if (ta == 1) {
        unsafe {
          rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
        }
      } else {
        unsafe {
          rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
        }
      }
      if (rc < 0) {
        return 0 - 1;
      }
      if (ai * esz != 0) {
        unsafe {
          rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
        }
        if (rc != 0) {
          return 0 - 1;
        }
      }
      unsafe {
        rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
      }
      if (rc < 0) {
        return 0 - 1;
      }
      unsafe {
        rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta);
      }
      if (rc < 0) {
        return 0 - 1;
      }
      ai = ai + 1;
    }
    if (ta == 1) {
      unsafe {
        rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
        if (rc < 0) {
          return 0 - 1;
        }
        return 0;
      }
    }
    unsafe {
      rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
      if (rc < 0) {
        return 0 - 1;
      }
      return 0;
    }
  }
  // scalar COMMON fill
  ai = 0;
  while (ai < n_arr) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    }
    if (elem_ref <= 0) {
      return 0 - 1;
    }
    if (all_const != 0) {
      unsafe {
        v64_lo = pipeline_expr_int_val_at(arena, elem_ref);
      }
      v64_hi = 0;
      if (v64_lo < 0) {
        v64_hi = 0 - 1;
      }
      unsafe {
        rc = backend_enc_mov_imm64_to_rax_arch(elf_ctx, v64_lo, v64_hi, ta);
      }
      if (rc < 0) {
        return 0 - 1;
      }
    } else {
      unsafe {
        rc = glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, expr_ref, elem_ref, ctx, ta, force_esz);
      }
      if (rc < 0) {
        return 0 - 1;
      }
    }
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    if (ta == 1) {
      unsafe {
        rc = glue_asm_lea_rbx_common_adrp_arm64(elf_ctx, &label[0], llen);
      }
    } else {
      unsafe {
        rc = glue_asm_lea_rbx_common_rip_x86(elf_ctx, &label[0], llen);
      }
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
      rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    ai = ai + 1;
  }
  if (ta == 1) {
    unsafe {
      rc = glue_asm_lea_rax_common_adrp_arm64(elf_ctx, &label[0], llen);
      if (rc < 0) {
        return 0 - 1;
      }
      return 0;
    }
  }
  unsafe {
    rc = glue_asm_lea_rax_common_rip_x86(elf_ctx, &label[0], llen);
    if (rc < 0) {
      return 0 - 1;
    }
    return 0;
  }
  }
}
