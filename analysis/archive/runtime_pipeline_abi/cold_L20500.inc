/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* forward within cold twin set (rest of wave143; leftover rest still closed) */
int32_t glue_fixed_array_temp_bytes(void *arena, int32_t type_ref);
int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                                     int32_t ta, int32_t force_esz);

int32_t glue_init_is_empty_array_lit(void *arena, int32_t init_ref) {
  if (init_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return 0;
  return pipeline_expr_array_lit_num_elems_at(arena, init_ref) == 0 ? 1 : 0;
}

int32_t glue_array_lit_force_esz_from_elem_type_c(void *arena, int32_t et) {
  int32_t ek;
  if (!arena || et <= 0)
    return 0;
  ek = pipeline_type_kind_ord_at(arena, et);
  if (ek == 2 || ek == 1)
    return 1;
  if (ek == 0 || ek == 3 || ek == 13 || ek == 14)
    return 4;
  /* Twin living/runtime_pipeline_abi.x 10.3.1 slice13: TYPE_FN=18 → 8 (Cap ABI). */
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9 || ek == 18)
    return 8;
  if (ek == 8) {
    void *mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      int32_t ssz = glue_type_size_simple(mod, arena, et, 0);
      if (ssz > 0)
        return ssz;
    }
  }
  /* TYPE_ARRAY=10: row stride = sizeof([N]T). `[][2]i32` must not fall through
   * to 0 — durable would store each nested ARRAY_LIT as a pointer.
   * PLATFORM: SHARED freestanding. Cold twin of runtime_pipeline_abi.x. */
  if (ek == 10) {
    int32_t asz = glue_fixed_array_total_bytes_c(arena, et, 0);
    if (asz > 0)
      return asz;
  }
  if (ek == GLUE_TYPE_KIND_SLICE)
    return 16;
  return 0;
}

int32_t glue_fixed_array_temp_bytes(void *arena, int32_t type_ref) {
  int32_t elem_ref;
  int32_t esz;
  int32_t bytes;
  int32_t arr_sz;
  int32_t nt;
  if (!arena || type_ref <= 0)
    return 0;
  nt = pipeline_arena_num_types(arena);
  if (type_ref > nt)
    return 0;
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  if (arr_sz <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, type_ref) == 10) {
    bytes = glue_type_size_simple(pipeline_asm_emit_module_ref_c(), arena, type_ref, 0);
    if (bytes > 0)
      return bytes;
  }
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    int32_t etk = pipeline_type_kind_ord_at(arena, elem_ref);
    if (etk == 2)
      esz = 1;
    else if (etk == 8 || etk == 4 || etk == 5 || etk == 6 || etk == 7 || etk == 9
             || etk == 14 || etk == 15 || etk == 18)
      esz = 8;
    else
      esz = 4;
  }
  bytes = arr_sz * esz;
  return bytes > 0 ? bytes : 0;
}

int32_t glue_array_temp_bytes_for_let_init(void *arena, int32_t let_type_ref, int32_t init_ref) {
  int32_t bytes;
  bytes = glue_fixed_array_temp_bytes(arena, let_type_ref);
  if (bytes > 0)
    return bytes;
  if (init_ref > 0) {
    int32_t rt = pipeline_expr_resolved_type_ref(arena, init_ref);
    bytes = glue_fixed_array_temp_bytes(arena, rt);
    if (bytes > 0)
      return bytes;
    if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
      int32_t ne = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
      if (ne > 0) {
        int32_t esz = 4;
        int32_t inner = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
        if (inner > 0 && pipeline_type_kind_ord_at(arena, inner) == 2)
          esz = 1;
        else if (inner > 0 && (pipeline_type_kind_ord_at(arena, inner) == 8 ||
                               pipeline_type_kind_ord_at(arena, inner) == 4))
          esz = 8;
        bytes = ne * esz;
        if (bytes > 0)
          return bytes;
      }
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                                     int32_t ta, int32_t force_esz) {
  int32_t n_arr;
  int32_t esz;
  int32_t ai;
  int32_t temp_base;
  int32_t elem_ref;
  int32_t elem_ty;
  int32_t nbytes;
  int32_t has_nested;
  int32_t *ly_next;
  if (!ctx)
    return -1;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
  if (n_arr == 0) {
    temp_base = *ly_next;
    return backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_base, ta);
  }
  if (n_arr <= 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
  has_nested = 0;
  for (ai = 0; ai < n_arr && ai < GLUE_ARRAY_LIT_MAX_ELEMS; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    if (elem_ref > 0 && pipeline_expr_kind_ord_at(arena, elem_ref) == 46) {
      has_nested = 1;
      break;
    }
  }
  esz = force_esz > 0 ? force_esz : pipeline_asm_array_lit_elem_byte_sz_c(arena, expr_ref);
  if (esz <= 0)
    esz = 4;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
  nbytes = n_arr * esz;
  {
    int32_t reserve = (nbytes + 7) & ~7;
    if (reserve < 8)
      reserve = 8;
    if (ta == 1) {
      temp_base = *ly_next;
      if ((temp_base % 8) != 0)
        temp_base = (temp_base + 7) / 8 * 8;
      *ly_next = temp_base + reserve;
    } else {
      temp_base = *ly_next;
      if ((temp_base % 8) != 0)
        temp_base = (temp_base + 7) / 8 * 8;
      temp_base = temp_base + reserve;
      *ly_next = temp_base;
    }
  }
  if (has_nested != 0) {
    int32_t leaf_esz = pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena, expr_ref);
    int32_t flat_i = 0;
    if (leaf_esz <= 0)
      leaf_esz = 4;
    if (pipeline_asm_emit_array_lit_flat_elf_c(arena, elf_ctx, expr_ref, ctx, ta, temp_base, leaf_esz,
                                                &flat_i) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_base, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    return backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
  }
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_base, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  for (ai = 0; ai < n_arr && ai < GLUE_ARRAY_LIT_MAX_ELEMS; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    if (elem_ref != 0) {
      if (esz == 16 && elem_ty > 0 &&
          pipeline_type_kind_ord_at(arena, elem_ty) == GLUE_TYPE_KIND_SLICE) {
        int32_t elem_home;
        int32_t len_spill;
        elem_home = (ta == 1) ? (temp_base + ai * esz) : (temp_base - ai * esz);
        if (elem_home < 0)
          return -1;
        if (*ly_next + 16 < *ly_next)
          return -1;
        *ly_next += 16;
        len_spill = *ly_next;
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, elem_home, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(elem_home, ta), ta) != 0)
          return -1;
        continue;
      }
      /* SIMD named elem (`[z, z]` of [2]i32x4): scalar emit_expr dual-GP
       * clobbers dest-in-x1 then str [x1] (Darwin 139). G.7: vector
       * let-init into the real frame home (same as FIELD dest VECTOR CALL).
       * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
      {
        int32_t elem_home;
        int32_t st;
        extern int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                            void *ctx, int32_t ta, int32_t off, int32_t ty);
        elem_home = (ta == 1) ? (temp_base + ai * esz) : (temp_base - ai * esz);
        if (elem_home < 0)
          return -1;
        {
          int32_t vty = elem_ty;
          if (vty <= 0)
            vty = pipeline_expr_resolved_type_ref(arena, elem_ref);
          if (vty > 0) {
            st = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, elem_home, vty);
            if (st == 0)
              continue;
            if (st == -1)
              return -1;
          }
        }
        if (esz > 8 || pipeline_expr_kind_ord_at(arena, elem_ref) == 45) {
          st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                     elem_ty > 0 ? elem_ty : 0, elem_home);
          if (st == 0)
            continue;
          if (st == -1)
            return -1;
        }
      }
      {
        int32_t may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
        int32_t store_sz = esz;
        if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
          store_sz = 4;
        if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, expr_ref, elem_ref, ctx, ta,
                                                          force_esz) != 0)
          return -1;
        if (may_clobber != 0) {
          if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
            return -1;
          if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_base, ta) != 0)
            return -1;
          if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
            return -1;
          if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
            return -1;
        }
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, store_sz, ta) != 0)
          return -1;
      }
    }
  }
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_base, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta);
}

int32_t pipeline_asm_emit_array_lit_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  return pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0);
}

int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                       int32_t force_esz, int32_t ta, void *ctx,
                                                       int32_t dest_elem_ty) {
  int32_t n_arr;
  int32_t esz;
  int32_t ai;
  int32_t nbytes;
  int32_t bi;
  int32_t elem_ref;
  int32_t eko;
  int32_t all_const;
  int64_t v64;
  uint8_t payload[GLUE_ARRAY_LIT_MAX_PAYLOAD];
  uint8_t jmp_near[5];
  uint8_t jmp_short[2];
  uint8_t lea7[7];
  int32_t disp32;
  int32_t rel32;
  uint8_t label[24];
  int32_t llen;
  int32_t seq;
  int32_t v;
  int32_t nd;
  int32_t di;
  uint8_t digs[8];
  const char *pfx;
  int32_t *ly_next;
  if (!arena || !elf_ctx || expr_ref <= 0 || (ta != 0 && ta != 1))
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
  if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
  if (n_arr == 0)
    return backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
  esz = force_esz;
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    if (force_esz > 8)
      esz = force_esz;
    else if (force_esz > 0)
      return -1;
    else
      esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, expr_ref);
  }
  if (esz <= 0)
    return -1;
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8 && esz <= 8)
    return -1;
  if (n_arr > GLUE_ARRAY_LIT_MAX_PAYLOAD / esz)
    return -1;
  nbytes = n_arr * esz;
  if (nbytes <= 0 || nbytes > GLUE_ARRAY_LIT_MAX_PAYLOAD)
    return -1;
  all_const = 1;
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    if (elem_ref <= 0)
      return -1;
    eko = pipeline_expr_kind_ord_at(arena, elem_ref);
    if (eko != 0 && eko != 2)
      all_const = 0;
  }
  if (all_const != 0 && ta == 0 && (esz == 1 || esz == 2 || esz == 4 || esz == 8)) {
    for (ai = 0; ai < n_arr; ai++) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
      v64 = (int64_t)pipeline_expr_int_val_at(arena, elem_ref);
      bi = ai * esz;
      if (esz == 1) {
        payload[bi] = (uint8_t)(v64 & 0xff);
      } else if (esz == 2) {
        payload[bi] = (uint8_t)(v64 & 0xff);
        payload[bi + 1] = (uint8_t)((v64 >> 8) & 0xff);
      } else if (esz == 4) {
        payload[bi] = (uint8_t)(v64 & 0xff);
        payload[bi + 1] = (uint8_t)((v64 >> 8) & 0xff);
        payload[bi + 2] = (uint8_t)((v64 >> 16) & 0xff);
        payload[bi + 3] = (uint8_t)((v64 >> 24) & 0xff);
      } else {
        payload[bi] = (uint8_t)(v64 & 0xff);
        payload[bi + 1] = (uint8_t)((v64 >> 8) & 0xff);
        payload[bi + 2] = (uint8_t)((v64 >> 16) & 0xff);
        payload[bi + 3] = (uint8_t)((v64 >> 24) & 0xff);
        payload[bi + 4] = (uint8_t)((v64 >> 32) & 0xff);
        payload[bi + 5] = (uint8_t)((v64 >> 40) & 0xff);
        payload[bi + 6] = (uint8_t)((v64 >> 48) & 0xff);
        payload[bi + 7] = (uint8_t)((v64 >> 56) & 0xff);
      }
    }
    if (nbytes <= 127) {
      jmp_short[0] = 0xeb;
      jmp_short[1] = (uint8_t)nbytes;
      if (pipeline_elf_ctx_append_bytes(elf_ctx, jmp_short, 2) != 0)
        return -1;
    } else {
      rel32 = nbytes;
      jmp_near[0] = 0xe9;
      jmp_near[1] = (uint8_t)(rel32 & 0xff);
      jmp_near[2] = (uint8_t)((rel32 >> 8) & 0xff);
      jmp_near[3] = (uint8_t)((rel32 >> 16) & 0xff);
      jmp_near[4] = (uint8_t)((rel32 >> 24) & 0xff);
      if (pipeline_elf_ctx_append_bytes(elf_ctx, jmp_near, 5) != 0)
        return -1;
    }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, payload, nbytes) != 0)
      return -1;
    disp32 = -nbytes - 7;
    lea7[0] = 0x48;
    lea7[1] = 0x8d;
    lea7[2] = 0x05;
    lea7[3] = (uint8_t)(disp32 & 0xff);
    lea7[4] = (uint8_t)((disp32 >> 8) & 0xff);
    lea7[5] = (uint8_t)((disp32 >> 16) & 0xff);
    lea7[6] = (uint8_t)((disp32 >> 24) & 0xff);
    return pipeline_elf_ctx_append_bytes(elf_ctx, lea7, 7);
  }
  if ((all_const == 0 || esz > 8) && !ctx)
    return -1;
  seq = glue_pipeline_asm_al_nc_seq_take_c();
  llen = 0;
  pfx = "Lxlang_al_";
  while (pfx[llen] != 0 && llen < 12) {
    label[llen] = (uint8_t)pfx[llen];
    llen++;
  }
  v = seq;
  nd = 0;
  if (v == 0) {
    digs[0] = (uint8_t)'0';
    nd = 1;
  } else {
    while (v > 0 && nd < 8) {
      digs[nd++] = (uint8_t)('0' + (v % 10));
      v /= 10;
    }
  }
  for (di = nd - 1; di >= 0 && llen < 23; di--)
    label[llen++] = digs[di];
  {
    int32_t common_align = esz;
    if (common_align > 16)
      common_align = 16;
    if (common_align < 1)
      common_align = 1;
    if (pipeline_elf_ctx_add_common_sym(elf_ctx, label, llen, nbytes, common_align) != 0)
      return -1;
  }
  {
    int32_t elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
    int32_t etk;
    /* Dest elem wins over an unstamped module ARRAY_LIT (no check_block).
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64. Cold twin. */
    if (dest_elem_ty > 0)
      elem_ty = dest_elem_ty;
    etk = elem_ty > 0 ? pipeline_type_kind_ord_at(arena, elem_ty) : 0;
    int32_t src_spill;
    int32_t dst_spill;
    int32_t temp_home;
    int32_t elem_reserve;
    int32_t st;
    /* TYPE_ARRAY row (incl. [][2]i32 esz==8): memcpy the row, never store a
     * pointer. Same bulk path as esz>8 NAMED. PLATFORM: SHARED freestanding. */
    if (esz > 8 || etk == 10 || (etk == GLUE_TYPE_KIND_SLICE && esz == 16)) {
    ly_next = (int32_t *)((uint8_t *)ctx + 4);
    if (elem_ty > 0 && etk == GLUE_TYPE_KIND_SLICE && esz == 16) {
      int32_t data_spill;
      int32_t len_spill;
      if (*ly_next + 48 < *ly_next)
        return -1;
      *ly_next += 16;
      data_spill = *ly_next;
      *ly_next += 16;
      len_spill = *ly_next;
      *ly_next += 16;
      src_spill = *ly_next;
      *ly_next += 16;
      dst_spill = *ly_next;
      temp_home = *ly_next + 16;
      *ly_next = temp_home + 16;
      glue_align_next_offset(ctx);
      for (ai = 0; ai < n_arr; ai++) {
        elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
        if (elem_ref <= 0)
          return -1;
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, data_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, data_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, temp_home, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(temp_home, ta), ta) != 0)
          return -1;
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
          return -1;
        if (ta == 1) {
          if (glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen) != 0)
            return -1;
        } else if (glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen) != 0) {
          return -1;
        }
        if (ai * esz != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
          return -1;
        if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, 16, ta) != 0)
          return -1;
      }
      if (ta == 1)
        return glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen);
      return glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen);
    }
    if (*ly_next + 32 < *ly_next)
      return -1;
    *ly_next += 16;
    src_spill = *ly_next;
    *ly_next += 16;
    dst_spill = *ly_next;
    elem_reserve = (esz + 7) & ~7;
    if (elem_reserve < 8)
      elem_reserve = 8;
    if (*ly_next + elem_reserve < *ly_next)
      return -1;
    *ly_next += elem_reserve;
    temp_home = *ly_next;
    for (ai = 0; ai < n_arr; ai++) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
      if (elem_ref <= 0)
        return -1;
      if (etk == 10 && elem_ty > 0)
        st = glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                       elem_ty, temp_home);
      else
        st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                   elem_ty > 0 ? elem_ty : 0, temp_home);
      if (st != 0)
        return -1;
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
        return -1;
      if (ta == 1) {
        if (glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen) != 0)
          return -1;
      } else if (glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen) != 0) {
        return -1;
      }
      if (ai * esz != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
        return -1;
      if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, esz, ta) != 0)
        return -1;
    }
    if (ta == 1)
      return glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen);
    return glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen);
    }
  }
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    if (elem_ref <= 0)
      return -1;
    if (all_const != 0) {
      v64 = (int64_t)pipeline_expr_int_val_at(arena, elem_ref);
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, (int32_t)(v64 & 0xffffffff),
                                             (int32_t)((v64 >> 32) & 0xffffffff), ta) != 0)
        return -1;
    } else {
      if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, expr_ref, elem_ref, ctx, ta,
                                                        force_esz) != 0)
        return -1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (ta == 1) {
      if (glue_asm_lea_rbx_common_adrp_arm64(elf_ctx, label, llen) != 0)
        return -1;
    } else if (glue_asm_lea_rbx_common_rip_x86(elf_ctx, label, llen) != 0) {
      return -1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta) != 0)
      return -1;
  }
  if (ta == 1)
    return glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen);
  return glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen);
}





/* ========================================================================== *
 * wave144: pipeline_asm_emit_return pure-owned leave cold twins.
 * PLATFORM: SHARED freestanding · continues same #ifndef FROM_X as wave143.
 * Live product path = runtime_pipeline_abi.x (pure); this block only when
 * XLANG_RUNTIME_PIPELINE_ABI_FROM_X is unset (cold seed / no pure .o).
 * ========================================================================== */

/* Opaque structs — Cap residual / pool faces provided by product link. */
struct ast_ASTArena;
struct platform_elf_ElfCodegenCtx;
struct backend_AsmFuncCtx;
struct ast_Module;
struct ast_Func;
struct ast_Block;
struct ast_Expr;

#define GLUE_SLICE_ESC_WALK_DEPTH_MAX 256
#define GLUE_SLICE_ESC_WALK_VISIT_MAX 4096
#ifndef GLUE_ARRAY_LIT_MAX_ELEMS
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#endif
#ifndef GLUE_ARRAY_LIT_MAX_PAYLOAD
#define GLUE_ARRAY_LIT_MAX_PAYLOAD 4096
#endif

/* Cap residual / pool / enc externs (product residual or pure elsewhere). */
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t tr);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *a, int32_t tr);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t tr);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t er);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t er, uint8_t *out64);
extern int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t fi, uint8_t *n, int32_t nl);
extern int32_t pipeline_module_num_funcs(struct ast_Module *m);
extern struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_block_num_labeled_stmts(struct ast_ASTArena *a, int32_t br);
extern int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t br, uint8_t *n, int32_t nl);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_asm_emit_ctx_sret_active_get(void);
extern int32_t pipeline_asm_emit_ctx_sret_home_off_get(void);
extern int32_t pipeline_asm_emit_ctx_sret_ret_sz_get(void);
extern int32_t pipeline_asm_emit_ctx_scope_block_get(void);
extern int32_t glue_pipeline_asm_al_nc_seq_take_c(void);
extern int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *a, struct backend_AsmFuncCtx *ctx, int32_t er);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(struct ast_ASTArena *a, int32_t tr);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t pipeline_elf_ctx_add_common_sym(struct platform_elf_ElfCodegenCtx *ctx, uint8_t *name, int32_t name_len, int32_t sz, int32_t al);
extern int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t glue_asm_lea_rbx_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl);
extern int32_t glue_asm_lea_rbx_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl);
extern int32_t glue_asm_lea_rax_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl);
extern int32_t glue_asm_lea_rax_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t er);
extern int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t tr, int32_t depth);
extern int32_t glue_enc_local_slot_ptr_or_addr_rbx_elf_c(struct ast_ASTArena *a, struct platform_elf_ElfCodegenCtx *elf, int32_t er, int32_t off, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t asm_ctx_local_find_offset_scoped(uint8_t *ctx, struct ast_ASTArena *a, uint8_t *n, int32_t nl);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *n, int32_t nl);
extern int32_t pipeline_typeck_float_widen_ok_c(int32_t dk, int32_t sk);
extern int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c(struct ast_ASTArena *a, struct platform_elf_ElfCodegenCtx *elf, int32_t er, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t glue_array_lit_force_esz_from_elem_type_c(struct ast_ASTArena *a, int32_t et);
extern int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(struct ast_ASTArena *a, struct platform_elf_ElfCodegenCtx *elf, int32_t er, int32_t force_esz, int32_t ta, struct backend_AsmFuncCtx *ctx, int32_t dest_elem_ty);
extern int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(struct ast_ASTArena *a, struct platform_elf_ElfCodegenCtx *elf, int32_t er, struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t force_esz);
extern void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *a, int32_t er, struct backend_AsmFuncCtx *ctx);
extern int32_t glue_index_scratch_spills_cleanup_all_elf_c(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t glue_async_cps_emit_phase_reset(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern void *pipeline_asm_ctx_layout(struct backend_AsmFuncCtx *ctx);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_push_rbx_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_cmp_rax_rbx_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_jge_arch(struct platform_elf_ElfCodegenCtx *elf, uint8_t *lbl, int32_t llen, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_label_arch(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl, int32_t is_g, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_push_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl, int32_t ta);
extern int32_t backend_enc_jmp_arch(struct platform_elf_ElfCodegenCtx *elf, uint8_t *n, int32_t nl, int32_t ta);

/* TYPE / EXPR ordinals matching pure (ast.x enum). */
enum {
  W144_TYPE_ARRAY = 10,
  W144_TYPE_SLICE = 11,
  W144_TYPE_F32 = 14,
  W144_TYPE_F64 = 15,
  W144_EXPR_LIT = 0,
  W144_EXPR_BOOL = 2,
  W144_EXPR_VAR = 3,
  W144_EXPR_BLOCK = 26,
  W144_EXPR_RETURN = 41,
  W144_EXPR_FIELD = 44,
  W144_EXPR_ARRAY_LIT = 46
};

/* Layout offsets LP64 (pure twins). */
enum {
  W144_FUNC_BODY_REF_OFF = 148,
  W144_ARENA_NUM_EXPRS_OFF = 4,
  W144_ARENA_NUM_BLOCKS_OFF = 8,
  W144_LY_TAIL_JOIN_LBL = 1392,
  W144_LY_TAIL_JOIN_LEN = 1520
};

static int32_t w144_load_i32(const void *p, int32_t off) {
  const uint8_t *b = (const uint8_t *)p + off;
  return (int32_t)((uint32_t)b[0] | ((uint32_t)b[1] << 8) | ((uint32_t)b[2] << 16) | ((uint32_t)b[3] << 24));
}

int32_t glue_match_slice_escape_lets_in_block_c(struct ast_ASTArena *arena, int32_t block_ref,
                                                      const uint8_t *vname, int32_t vlen, int32_t *out_arr_sz,
                                                      int32_t *out_elem_tr, int32_t *out_arr_init_ref) {
  int32_t nlet;
  int32_t li;
  if (!arena || block_ref <= 0 || !vname || vlen <= 0 || !out_arr_sz || !out_elem_tr)
    return 0;
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (li = 0; li < nlet; li++) {
    int32_t nlen = pipeline_block_let_name_len(arena, block_ref, li);
    int32_t match = 1;
    int32_t ci;
    uint8_t nb[256];
    int32_t tr;
    int32_t init_ref;
    int32_t lj;
    int32_t arr_sz = 0;
    int32_t arr_ty = 0;
    int32_t init_ko;
    if (nlen != vlen || nlen <= 0)
      continue;
    pipeline_block_let_name_copy64(arena, block_ref, li, nb);
    for (ci = 0; ci < nlen; ci++) {
      if (nb[ci] != vname[ci]) {
        match = 0;
        break;
      }
    }
    if (match == 0)
      continue;
    tr = pipeline_block_let_type_ref(arena, block_ref, li);
    if (tr <= 0 || pipeline_type_kind_ord_at(arena, tr) != W144_TYPE_SLICE)
      continue;
    init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
    if (init_ref <= 0)
      continue;
    init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
    /* Prefer resolved TYPE_ARRAY on init (VAR or FIELD_ACCESS). */
    {
      int32_t irty = pipeline_expr_resolved_type_ref(arena, init_ref);
      if (irty > 0 && pipeline_type_kind_ord_at(arena, irty) == W144_TYPE_ARRAY) {
        arr_sz = pipeline_type_array_size_at(arena, irty);
        arr_ty = irty;
      }
    }
    if (arr_sz <= 0 && init_ko == 3) {
      int32_t avlen = pipeline_expr_var_name_len(arena, init_ref);
      uint8_t aname[256];
      if (avlen <= 0 || avlen > 255)
        continue;
      pipeline_expr_var_name_into(arena, init_ref, aname);
      for (lj = 0; lj < nlet; lj++) {
        int32_t alen = pipeline_block_let_name_len(arena, block_ref, lj);
        int32_t am = 1;
        int32_t ac;
        uint8_t ab[256];
        int32_t atr;
        if (alen != avlen || alen <= 0)
          continue;
        pipeline_block_let_name_copy64(arena, block_ref, lj, ab);
        for (ac = 0; ac < alen; ac++) {
          if (ab[ac] != aname[ac]) {
            am = 0;
            break;
          }
        }
        if (am == 0)
          continue;
        atr = pipeline_block_let_type_ref(arena, block_ref, lj);
        if (atr > 0 && pipeline_type_kind_ord_at(arena, atr) == W144_TYPE_ARRAY) {
          arr_sz = pipeline_type_array_size_at(arena, atr);
          arr_ty = atr;
          break;
        }
      }
    }
    /*
     * wave348 FIELD: typeck may leave FA resolved unset/non-ARRAY while let is TYPE_SLICE.
     * Escape only needs a capacity upper bound + elem type (copy uses min(s.length, N)).
     * Prefer resolved TYPE_ARRAY; else slice-let elem + N=256 (matches host sizeof idiom).
     */
    if (arr_sz <= 0 && init_ko == 44) {
      int32_t elem = pipeline_type_elem_ref_at(arena, tr);
      if (elem > 0) {
        /* Soft capacity when FA TYPE_ARRAY not stamped; wave344 copy uses min(len,N). */
        arr_sz = 64;
        *out_arr_sz = arr_sz;
        *out_elem_tr = elem;
        if (out_arr_init_ref)
          *out_arr_init_ref = init_ref;
        return 1;
      }
    }
    if (arr_sz > 0 && arr_ty > 0 && (init_ko == 3 || init_ko == 44)) {
      *out_arr_sz = arr_sz;
      *out_elem_tr = pipeline_type_elem_ref_at(arena, arr_ty);
      if (out_arr_init_ref)
        *out_arr_init_ref = init_ref;
      return 1;
    }
  }
  return 0;
}

/**
 * DFS from body_ref: match slice escape lets in body and nested blocks.
 * Nested sources: if/while/for/region bodies + EXPR_BLOCK (kind 26) in expr_stmts/final.
 * @return 1 found; 0 not found.
 * PLATFORM: SHARED.
 */
int32_t pipeline_find_fixed_array_slice_escape(struct ast_ASTArena *arena, int32_t body_ref, uint8_t *vname,
                                              int32_t vlen, int32_t *out_arr_sz, int32_t *out_elem_tr,
                                              int32_t *out_arr_init_ref) {
  int32_t stack[GLUE_SLICE_ESC_WALK_DEPTH_MAX];
  int32_t sp = 0;
  int32_t seen = 0;
  if (!arena || body_ref <= 0 || !vname || vlen <= 0 || !out_arr_sz || !out_elem_tr)
    return 0;
  *out_arr_sz = 0;
  *out_elem_tr = 0;
  if (out_arr_init_ref)
    *out_arr_init_ref = 0;
  stack[sp++] = body_ref;
  while (sp > 0 && seen < GLUE_SLICE_ESC_WALK_VISIT_MAX) {
    int32_t cur;
    int32_t i;
    int32_t n;
    int32_t ch;
    int32_t er;
    int32_t fin;
    seen++;
    cur = stack[--sp];
    if (cur <= 0)
      continue;
    if (glue_match_slice_escape_lets_in_block_c(arena, cur, vname, vlen, out_arr_sz, out_elem_tr,
                                               out_arr_init_ref))
      return 1;
    /* EXPR_BLOCK children in expr_stmts + final_expr (nested `{ … }` body). */
    n = ast_ast_block_num_expr_stmts(arena, cur);
    for (i = 0; i < n; i++) {
      er = ast_pipeline_block_expr_stmt_ref(arena, cur, i);
      if (er > 0 && pipeline_expr_kind_ord_at(arena, er) == 26) {
        ch = pipeline_expr_block_ref_at(arena, er);
        if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
          stack[sp++] = ch;
      }
    }
    fin = ast_ast_block_final_expr_ref(arena, cur);
    if (fin > 0 && pipeline_expr_kind_ord_at(arena, fin) == 26) {
      ch = pipeline_expr_block_ref_at(arena, fin);
      if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
        stack[sp++] = ch;
    }
    n = ast_ast_block_num_if_stmts(arena, cur);
    for (i = 0; i < n; i++) {
      ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
      if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
        stack[sp++] = ch;
      ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
      if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
        stack[sp++] = ch;
    }
    n = ast_ast_block_num_loops(arena, cur);
    for (i = 0; i < n; i++) {
      ch = pipeline_block_while_body_ref(arena, cur, i);
      if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
        stack[sp++] = ch;
    }
    n = ast_ast_block_num_for_loops(arena, cur);
    for (i = 0; i < n; i++) {
      ch = pipeline_block_for_body_ref(arena, cur, i);
      if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
        stack[sp++] = ch;
    }
    n = ast_ast_block_num_regions(arena, cur);
    for (i = 0; i < n; i++) {
      ch = pipeline_block_region_body_ref(arena, cur, i);
      if (ch > 0 && sp < GLUE_SLICE_ESC_WALK_DEPTH_MAX)
        stack[sp++] = ch;
    }
  }
  return 0;
}


/**
 * wave342–344 Cap residual pure: freestanding `return s` where
 *   `let a: T[N] = …; let s: T[] = a; …; return s` (body-top or nested block)
 * Root: try_emit_slice_init_from_array_var / glue_emit_slice_from_array_let_init VAR path
 * write `{.data=a,.length=N}` (stack view). Local aliasing is correct (s shares a);
 * escape via return dual-GP leaves a dangling data pointer (Ubuntu/host run=1 vs 60).
 * G.7: durable SHN_COMMON BSS sized to N (finder max), copy from **current** s dual-GP
 * (`s.data` / `min(s.length, N)`), then return data@rax length@rdx.
 * wave343: finder walks nested blocks (pipeline_find_fixed_array_slice_escape).
 * wave344: reassign residual — prior copied fixed-array stack with compile-time N only
 * (host: memcpy sizeof N + length=N; fs: load a slots). After `s = [40,50]` / `s = t`
 * content/length must follow s (probe length*100+t0 → 240 not 340).
 * Soft leave-off: untyped-let; reentrancy last-wins static/COMMON (no heap yet).
 * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 SysV (ta==0).
 *
 * @return 1 handled; 0 not applicable; -1 hard fail.
 */
int32_t glue_try_return_slice_escape_from_fixed_array_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ret_op,
    struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t body_ref;
  int32_t vlen;
  int32_t arr_sz = 0;
  int32_t arr_init_ref = 0;
  int32_t s_off;
  int32_t esz;
  int32_t nbytes;
  int32_t ai;
  int32_t elem_tr = 0;
  int32_t seq;
  int32_t v;
  int32_t nd;
  int32_t di;
  int32_t llen;
  int32_t end_len;
  uint8_t vname[256];
  uint8_t label[24];
  uint8_t end_lbl[32];
  uint8_t digs[8];
  const char *pfx;
  int32_t rty;
  int32_t sty;
  int32_t slice_ret = 0;

  /*
   * wave418: accept ta==0 (x86) and ta==1 (arm64). Prior `ta != 0` early-out left
   * MACOS|ARM64 fixed→slice return as stack view (length/data soft after callee ret);
   * host-C and LINUX x86 used durable COMMON. G.7: one escape face, SHARED encoders.
   * PLATFORM: SHARED freestanding · LINUX|x86_64 · MACOS|ARM64.
   */
  if (!arena || !elf_ctx || !ctx || ret_op <= 0 || (ta != 0 && ta != 1))
    return 0;
  if (!((struct ast_Module *)pipeline_asm_emit_module_ref_c()) || pipeline_asm_emit_func_index_c() < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, ret_op) != 3) /* EXPR_VAR */
    return 0;
  rty = pipeline_module_func_return_type_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()), pipeline_asm_emit_func_index_c());
  sty = pipeline_expr_resolved_type_ref(arena, ret_op);
  if (rty > 0 && pipeline_type_kind_ord_at(arena, rty) == W144_TYPE_SLICE)
    slice_ret = 1;
  else if (sty > 0 && pipeline_type_kind_ord_at(arena, sty) == W144_TYPE_SLICE)
    slice_ret = 1;
  if (slice_ret == 0)
    return 0;

  vlen = pipeline_expr_var_name_len(arena, ret_op);
  if (vlen <= 0 || vlen > 255)
    return 0;
  pipeline_expr_var_name_into(arena, ret_op, vname);
  body_ref = pipeline_module_func_body_ref_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()), pipeline_asm_emit_func_index_c());
  if (body_ref <= 0)
    return 0;
  if (pipeline_find_fixed_array_slice_escape(arena, body_ref, vname, vlen, &arr_sz, &elem_tr, &arr_init_ref) == 0)
    return 0;
  /* arr_init_ref proves fixed→slice init existed; capacity N from finder. */
  if (arr_sz <= 0 || arr_sz > GLUE_ARRAY_LIT_MAX_ELEMS || arr_init_ref <= 0 || elem_tr <= 0)
    return 0;

  /* Current s dual-GP home (data@off + arch-aware length half) — not the original fixed a. */
  s_off = glue_var_expr_stack_off_elf_c(arena, ctx, ret_op);
  if (s_off < 0)
    return -1;
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8)
    esz = 4;
  /* wave415: twin durable payload face (was hard 2048). */
  if (arr_sz > GLUE_ARRAY_LIT_MAX_PAYLOAD / esz)
    return -1;
  nbytes = arr_sz * esz;
  if (nbytes <= 0 || nbytes > GLUE_ARRAY_LIT_MAX_PAYLOAD)
    return -1;

  /* SHN_COMMON BSS label Lxlang_esc_<seq> (writable; never RX .text). */
  seq = glue_pipeline_asm_al_nc_seq_take_c();
  if (seq < 0 || seq > 999999)
    seq = 0;
  llen = 0;
  pfx = "Lxlang_esc_";
  while (pfx[llen] != 0 && llen < 12) {
    label[llen] = (uint8_t)pfx[llen];
    llen++;
  }
  v = seq;
  nd = 0;
  if (v == 0) {
    digs[0] = (uint8_t)'0';
    nd = 1;
  } else {
    while (v > 0 && nd < 8) {
      digs[nd++] = (uint8_t)('0' + (v % 10));
      v /= 10;
    }
  }
  for (di = nd - 1; di >= 0 && llen < 23; di--)
    label[llen++] = digs[di];
  if (pipeline_elf_ctx_add_common_sym((uint8_t *)elf_ctx, label, llen, nbytes, esz) != 0)
    return -1;

  end_len = pipeline_asm_emit_next_label_c(ctx, end_lbl, 32);
  if (end_len <= 0)
    return -1;

  /*
   * wave344: for i in 0..N-1: if min(s.length,N) <= i → done;
   * else load s.data[i] → COMMON[i]. Return length = min(s.length, N).
   */
  for (ai = 0; ai < arr_sz; ai++) {
    /*
     * Cap length to N; then if ai >= length → end.
     * wave418: use SHARED jge (arm64 has no jle). N >= length → keep; else length=N.
     * ai >= length → end (cmp ai,length; jge end).
     */
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, arr_sz, ta) != 0)
      return -1;
    if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0) /* park N */
      return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(s_off, ta), ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = length */
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = N */
      return -1;
    if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    {
      uint8_t keep_lbl[32];
      int32_t keep_len = pipeline_asm_emit_next_label_c(ctx, keep_lbl, 32);
      if (keep_len <= 0)
        return -1;
      if (backend_enc_jge_arch(elf_ctx, keep_lbl, keep_len, ta) != 0) /* N >= length → keep */
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = N */
        return -1;
      if (backend_enc_label_arch(elf_ctx, keep_lbl, keep_len, 0, ta) != 0)
        return -1;
    }
    /* rbx = capped length; if ai >= length → end */
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, ai, 0, ta) != 0)
      return -1;
    if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, end_lbl, end_len, ta) != 0) /* ai >= length → end */
      return -1;
    /* rax = s.data + ai*esz; load elem */
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, s_off, ta) != 0)
      return -1;
    if (ai * esz != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
      return -1;
    if (esz == 1) {
      if (backend_enc_load_zext8_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (esz == 8) {
      if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else if (esz == 4) {
      if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
    } else {
      /* esz==2: load 32 and rely on store width (caller cap is rare for i16). */
      if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
        return -1;
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    /* wave418: arm64 ADRP+PAGEOFF twin of x86 rip-relative COMMON lea. */
    if (ta == 1) {
      if (glue_asm_lea_rbx_common_adrp_arm64(elf_ctx, label, llen) != 0)
        return -1;
    } else if (glue_asm_lea_rbx_common_rip_x86(elf_ctx, label, llen) != 0) {
      return -1;
    }
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta) != 0)
      return -1;
  }
  if (backend_enc_label_arch(elf_ctx, end_lbl, end_len, 0, ta) != 0)
    return -1;

  /* length = min(s.length, N); data@rax = COMMON. wave418: jge SHARED (no jle). */
  if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, arr_sz, ta) != 0)
    return -1;
  if (backend_enc_push_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(s_off, ta), ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) /* rbx = length */
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0) /* rax = N */
    return -1;
  if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  {
    uint8_t keep2[32];
    int32_t k2 = pipeline_asm_emit_next_label_c(ctx, keep2, 32);
    if (k2 <= 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, keep2, k2, ta) != 0) /* N >= length → keep */
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, keep2, k2, 0, ta) != 0)
      return -1;
  }
  /* rbx = min length → rax for dual-GP length half */
  if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
    return -1;
  /* length@rdx (x86) / @x1 (arm64) — same dual-GP return map as ARRAY_LIT return. */
  {
    int32_t len_arg = (ta == 1) ? 1 : 2;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_arg, ta) != 0)
      return -1;
  }
  if (ta == 1) {
    if (glue_asm_lea_rax_common_adrp_arm64(elf_ctx, label, llen) != 0)
      return -1;
  } else if (glue_asm_lea_rax_common_rip_x86(elf_ctx, label, llen) != 0) {
    return -1;
  }
  return 1;
}

/* Forward decl: fmov d0, x0 return-face convert dispatcher (defined in the
 * backend_enc_dispatch leaf; extern decl there sits later in this TU). */
extern int32_t backend_enc_mov_rax_to_xmm_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);

int32_t pipeline_asm_emit_return_elf_impl(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  uint8_t *ly;
  int32_t ret_op;
  int32_t tj_len;
  int32_t ti;
  uint8_t tj_lbl[128];
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (ret_op != 0) {
    /* PLATFORM: x86_64 SysV + arm64 AAPCS64 sret — return local_var of >16B struct. */
    if (pipeline_asm_emit_ctx_sret_active_get() && pipeline_asm_emit_ctx_sret_ret_sz_get() > 16 &&
        (ta == 0 || ta == 1) && pipeline_expr_kind_ord_at(arena, ret_op) == 3) {
      if (glue_emit_sret_return_from_var_elf_c(arena, elf_ctx, ret_op, ctx, ta) != 0)
        return -1;
    } else if (arena && ctx && elf_ctx && (ta == 0 || ta == 1) &&
               pipeline_expr_kind_ord_at(arena, ret_op) == 3 &&
               ((struct ast_Module *)pipeline_asm_emit_module_ref_c()) && pipeline_asm_emit_func_index_c() >= 0) {
      /*
       * wave342/418: return TYPE_SLICE VAR that views a fixed TYPE_ARRAY local → durable
       * COMMON copy (kill owned-buffer escape). wave418: arm64 too (was ta==0 only).
       * Falls through on 0 (not applicable).
       */
      int32_t esc = glue_try_return_slice_escape_from_fixed_array_elf_c(arena, elf_ctx, ret_op, ctx, ta);
      if (esc < 0)
        return -1;
      if (esc == 0) {
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta) != 0)
          return -1;
        if (((struct ast_Module *)pipeline_asm_emit_module_ref_c()) && pipeline_asm_emit_func_index_c() >= 0) {
          int32_t rty = pipeline_module_func_return_type_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()),
                                                            pipeline_asm_emit_func_index_c());
          int32_t sty = glue_float_promote_src_ty_ref_c(arena, ret_op);
          if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta) != 0)
            return -1;
        }
      }
    } else if (arena && ctx && elf_ctx && (ta == 0 || ta == 1) &&
               pipeline_expr_kind_ord_at(arena, ret_op) == W144_EXPR_ARRAY_LIT &&
               ((struct ast_Module *)pipeline_asm_emit_module_ref_c()) && pipeline_asm_emit_func_index_c() >= 0) {
      /*
       * wave333+335 Cap residual pure: freestanding `return [1,2,3]` for TYPE_SLICE.
       * SysV dual-GP: data@rax length@rdx (arm64: data@x0 length@x1).
       * wave335: prefer durable text-embed payload (kill post-return INDEX dangle).
       * wave339: `return a` for const ARRAY_LIT let-init is durable via let-init embed
       * (G.7 reuse glue_emit_slice_from_array_let_init; host already static).
       * wave341: non-const ARRAY_LIT also durable (COMMON BSS fill; host static stores).
       * wave342: non-ARRAY_LIT fixed→slice return escape (COMMON copy) is handled above.
       * wave408: open ta==1 (arm64); durable COMMON+ADRP; dual-GP via arg_reg 2.
       * Fallback: stack emit_array_lit only if durable pack fails.
       * PLATFORM: SHARED freestanding · LINUX|x86_64 SysV · MACOS|ARM64 AAPCS.
       * Soft residual: untyped-let (docs 禁推断); reentrancy last-wins static/COMMON.
       * wave343: nested-block fixed→slice escape; wave344: reassign uses runtime s.length.
       */
      int32_t rty = pipeline_module_func_return_type_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()),
                                                        pipeline_asm_emit_func_index_c());
      int32_t sty = pipeline_expr_resolved_type_ref(arena, ret_op);
      int32_t slice_ty = 0;
      if (rty > 0 && pipeline_type_kind_ord_at(arena, rty) == W144_TYPE_SLICE)
        slice_ty = rty;
      else if (sty > 0 && pipeline_type_kind_ord_at(arena, sty) == W144_TYPE_SLICE)
        slice_ty = sty;
      /*
       * wave417: return ARRAY_LIT → TYPE_ARRAY also durable E* (host __xlang_ar twin).
       * Prior only TYPE_SLICE took durable; TYPE_ARRAY fell to stack emit → dangle.
       */
      if (slice_ty == 0 && rty > 0 &&
          pipeline_type_kind_ord_at(arena, rty) == W144_TYPE_ARRAY) {
        int32_t n_arr = pipeline_expr_array_lit_num_elems_at(arena, ret_op);
        /* wave625: G.7 force_esz includes TYPE_NAMED (was scalar-only). */
        int32_t force_esz = glue_array_lit_force_esz_from_elem_type_c(
            arena, pipeline_type_elem_ref_at(arena, rty));
        if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
          return -1;
        if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, force_esz, ta, ctx, pipeline_type_elem_ref_at(arena, rty)) != 0) {
          if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, ret_op, ctx, ta, force_esz) != 0)
            return -1;
          if (n_arr > 0)
            pipeline_asm_bump_next_offset_for_array_lit(arena, ret_op, ctx);
        }
        /* E* only in rax — no length half (TYPE_ARRAY return ABI). */
      } else if (slice_ty > 0) {
        int32_t n_arr = pipeline_expr_array_lit_num_elems_at(arena, ret_op);
        int32_t durable = 0;
        /* wave625: G.7 force_esz includes TYPE_NAMED (was scalar-only). */
        int32_t force_esz = glue_array_lit_force_esz_from_elem_type_c(
            arena, pipeline_type_elem_ref_at(arena, slice_ty));
        if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
          return -1;
        if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, force_esz, ta, ctx, pipeline_type_elem_ref_at(arena, slice_ty)) == 0) {
          durable = 1;
        } else if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, ret_op, ctx, ta,
                                                                force_esz) != 0) {
          return -1;
        }
        /*
         * Dual-GP return: data@rax + length@rdx (x86) / @x1 (arm64).
         * wave408: cannot park data in rbx on arm64 — rbx maps to x1 which is also
         * the length return half (overwrote data with length → pure0 crash).
         * G.7: push/pop park works on both arches; len_arg is arch-aware.
         * PLATFORM: SHARED freestanding · LINUX|x86_64 SysV · MACOS|ARM64 AAPCS.
         */
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
          return -1;
        {
          int32_t len_arg = (ta == 1) ? 1 : 2;
          if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, len_arg, ta) != 0)
            return -1;
        }
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (durable == 0 && n_arr > 0)
          pipeline_asm_bump_next_offset_for_array_lit(arena, ret_op, ctx);
      } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta) != 0) {
        return -1;
      } else if (((struct ast_Module *)pipeline_asm_emit_module_ref_c()) && pipeline_asm_emit_func_index_c() >= 0) {
        int32_t rty2 = pipeline_module_func_return_type_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()),
                                                           pipeline_asm_emit_func_index_c());
        int32_t sty2 = glue_float_promote_src_ty_ref_c(arena, ret_op);
        if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty2, sty2, ta) != 0)
          return -1;
      }
    } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta) != 0) {
      return -1;
    } else if (((struct ast_Module *)pipeline_asm_emit_module_ref_c()) && pipeline_asm_emit_func_index_c() >= 0) {
      /* wave314: return f32 value from f64 function — cvtss2sd. */
      int32_t rty = pipeline_module_func_return_type_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()),
                                                        pipeline_asm_emit_func_index_c());
      int32_t sty = glue_float_promote_src_ty_ref_c(arena, ret_op);
      if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta) != 0)
        return -1;
    }
  }
  /* AAPCS64 f64 boundary: the scalar return value leaves in d0 (call site
   * harvests with fmov x0,d0). The internal representation stays rax-bits;
   * this single exit-point convert covers every value path above. sret
   * struct returns cannot be f64, so the kind check excludes them; bare
   * `return;` has no value (ret_op == 0).
   * Twin of the .x authority pipeline_asm_emit_return_elf_impl common tail.
   * PLATFORM: MACOS|ARM64 AAPCS64. */
  if (ta == 1 && ret_op != 0 && ((struct ast_Module *)pipeline_asm_emit_module_ref_c()) &&
      pipeline_asm_emit_func_index_c() >= 0) {
    int32_t rty_tail = pipeline_module_func_return_type_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()),
                                                           pipeline_asm_emit_func_index_c());
    if (rty_tail > 0 && pipeline_type_kind_ord_at(arena, rty_tail) == W144_TYPE_F64) {
      if (backend_enc_mov_rax_to_xmm_arg_reg_arch(elf_ctx, 0, ta) != 0)
        return -1;
    }
  }
  if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_emit_phase_reset(elf_ctx, ta) != 0)
    return -1;
  if (!ly)
    return -1;
  tj_len = w144_load_i32(ly, W144_LY_TAIL_JOIN_LEN);
  if (tj_len <= 0)
    return -1;
  for (ti = 0; ti < tj_len && ti < 128; ti++)
    tj_lbl[ti] = ly[W144_LY_TAIL_JOIN_LBL + ti];
  return backend_enc_jmp_arch(elf_ctx, tj_lbl, tj_len, ta);
}


/**
 * EXPR_RETURN ELF face (X emit_expr_elf single-line delegate).
 * wave1014 G.7: folded from pipeline_glue residual next to static impl.
 * PLATFORM: SHARED — product residual C; same TU as return_elf_impl.
 */
int32_t pipeline_asm_emit_return_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                       int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_return_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
}

/* ========================================================================
 * wave1025 G.7 fold: sret return path helpers
 * (from pipeline_glue residual after this #include). Same-TU static.
 * Callers: this leaf (return_elf_impl); struct_lit leaf (sret_memcpy);
 * struct_let leaf (copy_large_struct via store_retval_pair).
 * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64.
 * ======================================================================== */

/**
 * sret write-back: rbx = source struct base; memcpy into caller dest saved at
 * pipeline_asm_emit_ctx_sret_home_off_get().
 * PLATFORM: LINUX+MACOS x86_64 SysV — dest@rdi src@rsi n@rdx (rax scratch; arg regs distinct).
 * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — dest@x0 src@x1 n@x2.
 *   arm64 cannot reuse the x86 push/pop sequence: mov_rax_to_arg_reg(0) is a no-op
 *   (arg0≡x0), so pop would clobber dest. Order: keep src in x1 (rbx), size→x2 first,
 *   then load dest into x0.
 */
int32_t glue_emit_sret_memcpy_rbx_to_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t sz,
                                                       int32_t ta) {
  static const uint8_t memcpy_sym[] = "memcpy";
  if ((ta != 0 && ta != 1) || !elf_ctx || sz <= 16 || pipeline_asm_emit_ctx_sret_home_off_get() < 0)
    return -1;
  if (ta == 1) {
    /* src already in x1 (=rbx); set n@x2 then dest@x0 (load must not clobber x1/x2). */
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
      return -1;
    /* x0=dest, x1=src, x2=n */
    return backend_enc_call_arch(elf_ctx, (uint8_t *)memcpy_sym, (int32_t)(sizeof(memcpy_sym) - 1), ta);
  }
  /* x86 SysV: rax scratch, rdi/rsi/rdx hold args. */
  if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)memcpy_sym, (int32_t)(sizeof(memcpy_sym) - 1), ta);
}

/**
 * sret 返回路径：`return local_var` 时把按值局部 struct 拷到 caller hidden dest。
 */
int32_t glue_emit_sret_return_from_var_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t var_expr_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta) {
  uint8_t vname[256];
  int32_t vlen;
  int32_t off;
  int32_t tr;
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || var_expr_ref <= 0 || !pipeline_asm_emit_ctx_sret_active_get())
    return -1;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 255)
    return -1;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
  if (off < 0)
    off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
  if (off < 0)
    return -1;
  tr = glue_var_decl_type_ref_elf_c(arena, ctx, var_expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
  sz = glue_type_size_simple(((struct ast_Module *)pipeline_asm_emit_module_ref_c()), arena, tr, 0);
  if (sz <= 16)
    return -1;
  if (glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, var_expr_ref, off, ctx, ta) != 0)
    return -1;
  return glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx, sz, ta);
}

/* wave1064 G.7: glue_copy_large_struct_from_rax_ptr_elf_c migrated to
 * pipeline_asm_emit_call_args.c (colocated with wave1058 store_retval_pair
 * sole caller). Static same-TU visibility via #include order (return.c L1957
 * < call_args.c L2395). Dependencies: backend_enc_*_arch (global extern). */

/* ============================================================
 * wave1130-1131 G.7: float promote pair (migrated from glue.c L8111-8169).
 *
 * Why here: both helpers are consumed by pipeline_asm_emit_return_elf_impl
 * (L542/543/630/631/640/641 above) to perform f32→f64 widen on the return
 * value before storing to the return slot. Same-TU visibility: callers in
 * pipeline_asm_emit_assign.c / pipeline_asm_emit_block_inits.c /
 * pipeline_asm_emit_block_body.c / pipeline_glue.c (L5553-5554) see these
 * definitions via the #include of this leaf at glue.c L1913.
 *
 * Invariant: definitions placed at EOF AFTER all callsites in this file;
 * forward decls at L58-62 above keep L542/543/630/631/640/641 visible.
 * pipeline_typeck_float_widen_ok_c fwd decl at L62 above — its definition
 * is in pipeline_typeck_coerce_init.c (#include @ glue.c L11099, after
 * this leaf's #include @ L1913); the fwd decl keeps this leaf compiling
 * standalone within the larger TU.
 *
 * PLATFORM: SHARED — typeck gate is platform-agnostic; encoder dispatch
 * (backend_enc_cvtss2sd_rax_from_f32_bits_arch) handles LINUX+MACOS
 * x86_64|arm64 via arch helper. No Windows-specific path here.
 * ============================================================ */

/**
 * wave314 freestanding emit: if dest is f64 and src value in eax is f32 bits,
 * promote via backend_enc_cvtss2sd_rax_from_f32_bits_arch (G.7 reuse wave293
 * encoder; no parallel path).
 *
 * Contract:
 *   - arena / elf_ctx non-NULL; dest_ty_ref / src_ty_ref > 0; else no-op return 0.
 *   - Calls pipeline_typeck_float_widen_ok_c (defined in coerce_init.c, late
 *     in TU) — forward decl at L62 above resolves the implicit-decl risk.
 *   - backend_enc_cvtss2sd_rax_from_f32_bits_arch returns 0 OK / -1 fail.
 *
 * @return 0 OK or no-op (not f32→f64); -1 encode fail.
 *
 * PLATFORM: SHARED typeck gate / LINUX+MACOS x86_64|arm64 encode via arch helper.
 */
int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                       int32_t dest_ty_ref, int32_t src_ty_ref, int32_t ta) {
  int32_t dk;
  int32_t sk;
  if (!arena || !elf_ctx || dest_ty_ref <= 0 || src_ty_ref <= 0)
    return 0;
  dk = pipeline_type_kind_ord_at(arena, dest_ty_ref);
  sk = pipeline_type_kind_ord_at(arena, src_ty_ref);
  if (!pipeline_typeck_float_widen_ok_c(dk, sk))
    return 0;
  /* Only true widen f32→f64 needs convert (identity no-op). */
  if (dk == W144_TYPE_F64 && sk == W144_TYPE_F32)
    return backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta);
  return 0;
}

/**
 * glue_maybe_demote_f64_to_f32_eax_elf_c — symmetric counterpart of the
 * promote above. f32-dest store sites (let-init / assign) must call this
 * BEFORE the 4-byte store whenever the init expr is f64-valued: without it
 * the store keeps only the low 32 bits of the f64 (both x86_64 and arm64
 * truncated; wave616 fixed only the `as f32` cast path).
 *
 * Source f64-ness uses glue_binop_operand_is_scalar_f64_elf_c — the same
 * classifier the cmp/binop emitters trust — because a binop init usually has
 * no resolved type stamp at emit time.
 *
 * Contract:
 *   - arena / elf_ctx non-NULL; dest_ty_ref / src_expr_ref > 0; else no-op 0.
 *   - dest f32 (kind 14) + f64-valued src expr → cvtsd2ss demote; else no-op.
 *   - backend_enc_cvtsd2ss_eax_from_f64_bits_arch: 0 OK / -1 encode fail.
 *
 * @return 0 OK or no-op (not f64→f32); -1 encode fail.
 *
 * PLATFORM: SHARED type gate / LINUX+MACOS x86_64|arm64 encode via arch helper.
 */
int32_t glue_maybe_demote_f64_to_f32_eax_elf_c(struct ast_ASTArena *arena,
                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               void *ctx, int32_t dest_ty_ref, int32_t src_expr_ref,
                                               int32_t ta) {
  int32_t dk;
  int32_t is_f64_src;
  if (!arena || !elf_ctx || dest_ty_ref <= 0 || src_expr_ref <= 0)
    return 0;
  dk = pipeline_type_kind_ord_at(arena, dest_ty_ref);
  is_f64_src = glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, src_expr_ref);
  /* f32 dest with f64-valued source: typeck already permits the narrowing
   * init/assign; the bit-level convert is owned here (G.7 single authority —
   * same encoder the `as f32` cast path uses). */
  if (dk == W144_TYPE_F32 && is_f64_src)
    return backend_enc_cvtsd2ss_eax_from_f64_bits_arch(elf_ctx, ta);
  return 0;
}

/**
 * Resolve source type for float promote.
 *
 * Why prefer VAR declaration type over resolved_type_ref: typeck may stamp the
 * VAR expr as f64 under f64 let context (init_ctx=decl), which would skip
 * cvtss2sd and zero-extend f32 bits (Ubuntu wave314 run=0 regression).
 *
 * Lookup order (last-wins precedence):
 *   1. func param type_ref_for_name (param decl)
 *   2. scope_block var type_ref (current block)
 *   3. func body_ref block var type_ref (outer func body)
 *   4. fallback expr resolved_type_ref (post-typeck stamp)
 *
 * Contract:
 *   - arena non-NULL; expr_ref > 0; else return 0.
 *   - vname buffer 128 bytes; vlen ≤ 63 (truncates longer names safely).
 *   - Global state read: pipeline_asm_emit_func_index_c(),
 *     ((struct ast_Module *)pipeline_asm_emit_module_ref_c()), pipeline_asm_emit_ctx_scope_block_get().
 *
 * @return type_ref > 0 if resolved; 0 if not found.
 *
 * PLATFORM: SHARED — pure typeck resolver; no platform ABI dependency.
 */
int32_t glue_float_promote_src_ty_ref_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t tr;
  uint8_t vname[256];
  int32_t vlen;
  if (!arena || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) == 3 /* GLUE_EXPR_KIND_VAR, macro defined in glue.c L2085 */) {
    /* Decl / param first — true storage type before any widen stamp. */
    vlen = pipeline_expr_var_name_len(arena, expr_ref);
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(arena, expr_ref, vname);
      if (pipeline_asm_emit_func_index_c() >= 0 && ((struct ast_Module *)pipeline_asm_emit_module_ref_c())) {
        tr = pipeline_module_func_param_type_ref_for_name(((struct ast_Module *)pipeline_asm_emit_module_ref_c()),
                                                         pipeline_asm_emit_func_index_c(), vname, vlen);
        if (tr > 0)
          return tr;
      }
      if (pipeline_asm_emit_ctx_scope_block_get() > 0) {
        tr = pipeline_block_resolve_var_type_ref(arena, pipeline_asm_emit_ctx_scope_block_get(), vname, vlen);
        if (tr > 0)
          return tr;
      }
      if (pipeline_asm_emit_func_index_c() >= 0 && ((struct ast_Module *)pipeline_asm_emit_module_ref_c())) {
        int32_t body_ref =
            pipeline_module_func_body_ref_at(((struct ast_Module *)pipeline_asm_emit_module_ref_c()), pipeline_asm_emit_func_index_c());
        if (body_ref > 0) {
          tr = pipeline_block_resolve_var_type_ref(arena, body_ref, vname, vlen);
          if (tr > 0)
            return tr;
        }
      }
    }
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  return tr > 0 ? tr : 0;
}


/* wave144 cold: return-expr ref cluster (pool accessors + layout offsets). */

int32_t pipeline_backend_get_return_expr_ref(struct ast_ASTArena *a, struct ast_Func *f) {
  int32_t body_ref;
  int32_t nblocks;
  int32_t nexprs;
  int32_t j;
  int32_t nlab;
  int32_t ret_ref;
  int32_t fin;
  int32_t ei;
  int32_t nstmt;
  int32_t ers;
  int32_t ko;
  int32_t op;
  if (!a || !f)
    return 0;
  body_ref = w144_load_i32(f, W144_FUNC_BODY_REF_OFF);
  nblocks = w144_load_i32(a, W144_ARENA_NUM_BLOCKS_OFF);
  nexprs = w144_load_i32(a, W144_ARENA_NUM_EXPRS_OFF);
  if (body_ref <= 0 || body_ref > nblocks)
    return 0;
  nlab = pipeline_block_num_labeled_stmts(a, body_ref);
  j = 0;
  while (j < nlab) {
    ret_ref = pipeline_block_labeled_return_expr_ref(a, body_ref, j);
    if (ret_ref != 0)
      return ret_ref;
    j++;
  }
  fin = ast_ast_block_final_expr_ref(a, body_ref);
  if (fin != 0) {
    if (fin <= 0 || fin > nexprs)
      return fin;
    ko = pipeline_expr_kind_ord_at(a, fin);
    op = pipeline_expr_unary_operand_ref_at(a, fin);
    if (ko == W144_EXPR_RETURN && op != 0)
      return op;
    return fin;
  }
  /*
   * Fallback when stmt_order is empty: walk expr_stmts for EXPR_RETURN.
   * Historical `return 0` on RETURN assumed emit_block (stmt_order>0) already
   * emitted the return — but PE multi-def / empty stmt_order left both paths
   * silent (prologue+epilogue only, no mov imm). Mirror final_expr: return the
   * operand so mega's get_return → emit_expr path loads rax/w0.
   * PLATFORM: SHARED (Windows leftover empty-.text was the discoverer).
   */
  nstmt = ast_ast_block_num_expr_stmts(a, body_ref);
  ei = nstmt - 1;
  while (ei >= 0) {
    ers = ast_pipeline_block_expr_stmt_ref(a, body_ref, ei);
    if (ers != 0 && ers > 0 && ers <= nexprs) {
      ko = pipeline_expr_kind_ord_at(a, ers);
      if (ko == W144_EXPR_RETURN) {
        op = pipeline_expr_unary_operand_ref_at(a, ers);
        if (op != 0)
          return op;
        return ers;
      }
    }
    ei--;
  }
  return 0;
}

int32_t pipeline_backend_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!a || !m || func_index < 0 || func_index >= pipeline_module_num_funcs(m))
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return 0;
  return pipeline_backend_get_return_expr_ref(a, f);
}

int32_t pipeline_arm64_get_return_lit_ref(struct ast_ASTArena *a, struct ast_Func *f) {
  int32_t body_ref;
  int32_t nblocks;
  int32_t nexprs;
  int32_t fin;
  int32_t ko;
  int32_t op;
  int32_t iko;
  if (!a || !f)
    return 0;
  body_ref = w144_load_i32(f, W144_FUNC_BODY_REF_OFF);
  nblocks = w144_load_i32(a, W144_ARENA_NUM_BLOCKS_OFF);
  nexprs = w144_load_i32(a, W144_ARENA_NUM_EXPRS_OFF);
  if (body_ref <= 0 || body_ref > nblocks)
    return 0;
  fin = ast_ast_block_final_expr_ref(a, body_ref);
  if (fin <= 0 || fin > nexprs)
    return 0;
  ko = pipeline_expr_kind_ord_at(a, fin);
  if (ko == W144_EXPR_LIT || ko == W144_EXPR_BOOL)
    return fin;
  if (ko == W144_EXPR_RETURN) {
    op = pipeline_expr_unary_operand_ref_at(a, fin);
    if (op != 0) {
      if (op <= 0 || op > nexprs)
        return 0;
      iko = pipeline_expr_kind_ord_at(a, op);
      if (iko == W144_EXPR_LIT || iko == W144_EXPR_BOOL)
        return op;
    }
  }
  return 0;
}

int32_t pipeline_arm64_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!a || !m || func_index < 0 || func_index >= pipeline_module_num_funcs(m))
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return 0;
  return pipeline_arm64_get_return_lit_ref(a, f);
}

int32_t pipeline_backend_type_kind_ord_at(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_type_kind_ord_at(a, ref);
}

int32_t pipeline_asm_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_index) {
  return pipeline_backend_get_return_expr_ref_at(a, m, func_index);
}

int32_t pipeline_asm_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_index) {
  return pipeline_arm64_get_return_lit_ref_at(a, m, func_index);
}

int32_t arch_arm64_pipeline_asm_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_get_return_lit_ref_at(a, m, func_index);
}

/* ========================================================================== *
 * wave145: pipeline_asm_emit_block_inits pure-owned leave cold twins.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave144 leave twins.
 * Product authority lives in runtime_pipeline_abi.x; these C bodies link only
 * when FROM_X is unset (cold bootstrap / seed path).
 * Cap residual externs: vector_simd/vector_let/binop/index_helpers/pool/enc.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 * ========================================================================== */

/* Cap residual / pool / enc faces (host residual or pure elsewhere). */
extern void *pipeline_asm_ctx_layout(void *ctx);
extern void glue_align_next_offset(void *ctx);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t ref);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t ref);
extern int32_t glue_array_lit_force_esz_from_elem_type_c(struct ast_ASTArena *a, int32_t et);
extern int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(struct ast_ASTArena *a, void *elf, int32_t er, int32_t force_esz, int32_t ta, void *ctx, int32_t dest_elem_ty);
extern int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(struct ast_ASTArena *a, void *elf, int32_t er, void *ctx, int32_t ta, int32_t force_esz);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf, int32_t lo, int32_t hi, int32_t ta);
extern void pipeline_asm_bump_next_offset_for_array_lit(struct ast_ASTArena *a, int32_t er, void *ctx);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t er);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t er, uint8_t *dst);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *a, int32_t ref);
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t er);
extern int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *a, void *ctx, int32_t er);
extern int32_t glue_enc_local_slot_ptr_or_addr_elf_c(struct ast_ASTArena *a, void *elf, int32_t er, int32_t off, void *ctx, int32_t ta);
extern int32_t pipeline_asm_modlet_load_to_rax_elf_c(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t pipeline_module_top_level_let_name_len(void *m, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(void *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_type_ref(void *m, int32_t idx);
extern int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t er);
extern int32_t glue_field_access_field_type_ref_c(struct ast_ASTArena *a, void *mod, int32_t fa);
extern int32_t glue_try_index_var_or_field_base_to_rax_elf_c(struct ast_ASTArena *a, void *elf, int32_t er, void *ctx, int32_t ta);
extern struct ast_Module *g_pipeline_asm_emit_module;
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t i);
extern int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t i);
extern int32_t glue_init_is_empty_array_lit(struct ast_ASTArena *a, int32_t init_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(struct ast_ASTArena *a, void *elf, int32_t er, void *ctx, int32_t ta);
extern int32_t backend_asm_ctx_slot_offset(void *ctx, int32_t slot_idx);
extern int32_t glue_lazy_append_block_let_local(struct ast_ASTArena *a, void *ctx, int32_t br, int32_t li, uint8_t *nm, int32_t nlen);
extern int32_t glue_block_let_is_simd_vector_type(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t glue_emit_vector_type_let_init_elf_c(struct ast_ASTArena *a, void *elf, int32_t init, void *ctx, int32_t ta, int32_t off, int32_t ty);
extern int32_t glue_block_let_is_fixed_array_type(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t glue_emit_fixed_array_type_let_init_elf_c(struct ast_ASTArena *a, void *elf, int32_t init, void *ctx, int32_t ta, int32_t ty, int32_t off);
extern int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *a, void *elf, int32_t init, void *ctx, int32_t ta, int32_t ty, int32_t off);
extern void pipeline_asm_bump_next_offset_after_let_init(struct ast_ASTArena *a, int32_t br, int32_t li, int32_t init, void *ctx);
extern int32_t glue_type_ref_is_scalar_f64_c(void *a, int32_t ty);
extern int32_t glue_binop_operand_is_scalar_f32_elf_c(struct ast_ASTArena *a, void *ctx, int32_t er);
extern int32_t backend_enc_cvtss2sd_rax_from_f32_bits_arch(void *elf, int32_t ta);
extern int32_t glue_float_promote_src_ty_ref_c(struct ast_ASTArena *a, int32_t er);
extern int32_t glue_maybe_promote_f32_to_f64_rax_elf_c(struct ast_ASTArena *a, void *elf, int32_t dty, int32_t sty, int32_t ta);
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t er, int32_t ty);
extern int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t er);
extern struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t fi, int32_t pi);
extern void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t fi, int32_t pi, uint8_t *dst);
extern int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t fi, int32_t pi);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t fi);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void asm_ctx_fill_locals_block_tree(uint8_t *ctx, struct ast_ASTArena *a, int32_t br, int32_t *off, int32_t *nl);
extern int32_t asm_array_lit_reserve_stack_bytes(struct ast_ASTArena *a, int32_t init_ref);
extern int32_t asm_struct_lit_reserve_stack_bytes(struct ast_ASTArena *a, int32_t init_ref);
extern int32_t glue_vector_let_init_uses_direct_slot(struct ast_ASTArena *a, int32_t ty, int32_t init);
extern int32_t glue_fixed_array_let_init_uses_direct_slot(struct ast_ASTArena *a, int32_t ty, int32_t init);
extern char *link_abi_getenv(const char *name);

#ifndef GLUE_ARRAY_LIT_MAX_ELEMS
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#endif
#ifndef GLUE_TYPE_KIND_ARRAY
#define GLUE_TYPE_KIND_ARRAY 10
#endif
#ifndef GLUE_TYPE_KIND_SLICE
#define GLUE_TYPE_KIND_SLICE 11
#endif
#ifndef GLUE_EXPR_KIND_VAR
#define GLUE_EXPR_KIND_VAR 3
#endif

/* Opaque layout view used by residual C (same as pipeline_glue_AsmFuncCtxLayout). */
#ifndef PIPELINE_GLUE_ASM_FUNC_CTX_LAYOUT_SEED_T
#define PIPELINE_GLUE_ASM_FUNC_CTX_LAYOUT_SEED_T
typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
} pipeline_glue_AsmFuncCtxLayout;
#endif


int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta) {
  if (ta == 1)
    return data_home + 8;
  return data_home - 8;
}

/**
 * Advance next_offset past both dual-GP halves of a TYPE_SLICE home.
 * x86: highest product offset used is data_home; arm64 also uses data_home+8.
 */
void glue_slice_dual_gp_bump_past_home_c(struct backend_AsmFuncCtx *ctx, int32_t data_home,
                                               int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t past;
  if (!ctx)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  past = (ta == 1) ? (data_home + 16) : (data_home + 8);
  if (ly->next_offset < past)
    ly->next_offset = past;
  glue_align_next_offset(ctx);
}

/**
 * let s: T[] = arr / let s: T[] = [..]：asm 栈槽写入 { .data = ptr, .length = N }.
 * - VAR path: arr is a prior fixed TYPE_ARRAY local (codegen_try_emit_slice_init_from_array_var).
 * - ARRAY_LIT path (wave329/wave330/wave339): dual-GP fat {data, length=num_elems}.
 *   Host-C already uses durable static compound
 *   `({ static E __xlang_al[]=…; slice{.data=__xlang_al,.length=N} })` so `return a` is safe.
 *   Freestanding used stack emit_array_lit only → `return a` dual-GP dangles after clobber
 *   (Ubuntu trash probe: expect 60, got 84). wave339: prefer durable text-embed (G.7 reuse
 *   glue_asm_emit_array_lit_durable_ptr_rax_elf_c). wave341: non-const also durable via
 *   SHN_COMMON BSS + runtime stores (ctx required). wave330: empty `[]` still writes
 *   {data, length=0}; do not rely on prologue zeroing.
 *
 * PLATFORM: SHARED freestanding dual-GP. Length half offset is arch-aware
 * (glue_slice_dual_gp_length_off_c — wave394); memory order always C fat.
 *
 * @return 1 已写入；0 不适用；-1 失败。
 */
int32_t glue_emit_slice_from_array_let_init_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t block_ref, int32_t let_idx, int32_t init_ref,
                                                         int32_t let_type_ref, struct backend_AsmFuncCtx *ctx,
                                                         int32_t ta, int32_t slice_slot_off) {
  int32_t arr_sz = 0;
  int32_t li;
  int32_t vlen;
  int32_t arr_off;
  int32_t init_ko;
  uint8_t vname[256];

  if (!arena || !elf_ctx || !ctx || block_ref <= 0 || let_type_ref <= 0 || init_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, let_type_ref) != GLUE_TYPE_KIND_SLICE)
    return 0;
  init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
  /*
   * wave329 Cap residual pure: TYPE_SLICE + EXPR_ARRAY_LIT (`let a: i32[] = [1,2,3]`).
   * wave330: empty `[]` (n_arr==0) dual-GP length=0.
   * wave339: prefer durable text-embed payload (match host static / kill return-VAR dangle).
   * G.7: single authority for ARRAY_LIT→slice dual-GP; callers must route empty TYPE_SLICE here.
   */
  if (init_ko == 46) {
    int32_t n_arr;
    int32_t durable = 0;
    int32_t force_esz = 0;
    int32_t et;
    pipeline_glue_AsmFuncCtxLayout *ly;
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
    if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
      return -1;
    /* wave625: G.7 force_esz authority (scalar + TYPE_NAMED layout size). */
    et = pipeline_type_elem_ref_at(arena, let_type_ref);
    force_esz = glue_array_lit_force_esz_from_elem_type_c(arena, et);
    /*
     * Prefer durable (wave335/wave341 helper): const text-embed or non-const COMMON BSS.
     * wave408: arm64 durable COMMON+ADRP (ta==1) same authority.
     * Fallback: stack emit_array_lit only if durable pack fails (cap/ta/etc).
     * PLATFORM: SHARED freestanding · LINUX|x86_64 · MACOS|ARM64.
     */
    if ((ta == 0 || ta == 1) &&
        glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, init_ref, force_esz, ta, ctx, et) == 0) {
      durable = 1;
    } else if (pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                             force_esz) != 0) {
      /* wave631: stack fallback must keep force_esz (S24[] lit esz>8 rejects durable). */
      return -1;
    }
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slice_slot_off, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, n_arr, 0, ta) != 0)
      return -1;
    /* wave394: arch-aware length half (C fat memory order). */
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(slice_slot_off, ta),
                                         ta) != 0)
      return -1;
    /*
     * wave331: empty ARRAY_LIT does not bump next_offset (0 temp bytes), and lea(temp)
     * may equal the dual-GP home. Advance past home so a later `a = [..]` assign does
     * not write payload into the fat slot (Ubuntu: empty→lit index garbage).
     * Non-empty stack path: also bump payload size (direct emit_array_lit skips slow-path bump).
     * Durable path: no stack payload — skip array_lit bump (payload lives in text).
     * wave394: arm64 length@home+8 must also be past next_offset.
     * PLATFORM: SHARED freestanding stack temp discipline.
     */
    if (durable == 0 && n_arr > 0)
      pipeline_asm_bump_next_offset_for_array_lit(arena, init_ref, ctx);
    glue_slice_dual_gp_bump_past_home_c(ctx, slice_slot_off, ta);
    return 1;
  }
  /*
   * VAR path: prior fixed TYPE_ARRAY local.
   * wave348 FIELD path: `let s: T[] = b.a` — lea base+field_off → data, length=N.
   * G.7: same dual-GP store authority; reuse INDEX field base lea (TYPE_ARRAY no load).
   * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 SysV.
   */
  if (init_ko == GLUE_EXPR_KIND_VAR) {
    vlen = pipeline_expr_var_name_len(arena, init_ref);
    if (vlen <= 0 || vlen > 255)
      return 0;
    pipeline_expr_var_name_into(arena, init_ref, vname);
    for (li = 0; li < let_idx; li++) {
      int32_t nlen = pipeline_block_let_name_len(arena, block_ref, li);
      if (nlen == vlen && nlen > 0) {
        int32_t match = 1;
        int32_t ci;
        uint8_t nb[256];
        pipeline_block_let_name_copy64(arena, block_ref, li, nb);
        for (ci = 0; ci < nlen; ci++) {
          if (nb[ci] != vname[ci]) {
            match = 0;
            break;
          }
        }
        if (match) {
          int32_t tr = pipeline_block_let_type_ref(arena, block_ref, li);
          if (pipeline_type_kind_ord_at(arena, tr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
            arr_sz = pipeline_type_array_size_at(arena, tr);
          if (arr_sz > 0)
            break;
        }
      }
    }
    if (arr_sz <= 0) {
      int32_t init_tr = pipeline_expr_resolved_type_ref(arena, init_ref);
      if (init_tr > 0 && pipeline_type_kind_ord_at(arena, init_tr) == 10)
        arr_sz = pipeline_type_array_size_at(arena, init_tr);
    }
    /* dest-SLICE stamps VAR to TYPE_SLICE. Mutable module TYPE_ARRAY is
     * COMMON (not hoisted) — recover N from the module table.
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64. */
    if (arr_sz <= 0 && g_pipeline_asm_emit_module) {
      int32_t ntl = cold_mod_num_top_level_lets(g_pipeline_asm_emit_module);
      int32_t tl;
      for (tl = 0; tl < ntl && arr_sz <= 0; tl++) {
        int32_t nlen = pipeline_module_top_level_let_name_len(g_pipeline_asm_emit_module, tl);
        int32_t match = 1;
        int32_t ci;
        if (nlen != vlen || nlen <= 0)
          continue;
        for (ci = 0; ci < nlen; ci++) {
          if (pipeline_module_top_level_let_name_byte_at(g_pipeline_asm_emit_module, tl, ci) != vname[ci]) {
            match = 0;
            break;
          }
        }
        if (match) {
          int32_t tr = pipeline_module_top_level_let_type_ref(g_pipeline_asm_emit_module, tl);
          if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 10)
            arr_sz = pipeline_type_array_size_at(arena, tr);
        }
      }
    }
    if (arr_sz <= 0)
      return 0;
    /* Prefer COMMON LEA when the name is a mutable module TYPE_ARRAY.
     * stack_off can false-hit a frame slot and poison dest-SLICE .data. */
    if (pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, vname, vlen, ta) != 0) {
      arr_off = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
      if (arr_off < 0)
        return -1;
      if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, init_ref, arr_off, ctx, ta) != 0)
        return -1;
    }
  } else if (init_ko == 44) {
    /* EXPR_FIELD_ACCESS: fixed TYPE_ARRAY field of VAR base. */
    int32_t init_tr;
    int32_t ftr;
    int32_t lea_rc;
    if (pipeline_expr_field_access_is_enum_variant(arena, init_ref) != 0)
      return 0;
    init_tr = pipeline_expr_resolved_type_ref(arena, init_ref);
    if (init_tr > 0 && pipeline_type_kind_ord_at(arena, init_tr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
      arr_sz = pipeline_type_array_size_at(arena, init_tr);
    if (arr_sz <= 0) {
      ftr = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, init_ref);
      if (ftr > 0 && pipeline_type_kind_ord_at(arena, ftr) == (int32_t)ast_TypeKind_TYPE_ARRAY)
        arr_sz = pipeline_type_array_size_at(arena, ftr);
    }
    if (arr_sz <= 0)
      return 0;
    /* lea &b.a into rax (TYPE_ARRAY field: no ptr load). */
    lea_rc = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    if (lea_rc != 0)
      return lea_rc < 0 ? -1 : 0;
  } else {
    return 0;
  }
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slice_slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, arr_sz, 0, ta) != 0)
    return -1;
  /* wave394: arch-aware length half (C fat memory order; arm64 home+8). */
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(slice_slot_off, ta),
                                       ta) != 0)
    return -1;
  glue_slice_dual_gp_bump_past_home_c(ctx, slice_slot_off, ta);
  return 1;
}

/**
 * ELF 路径：块的 const/let 初始化（C 实现）；TYPE_VECTOR+ARRAY_LIT 直写栈槽，避免 8B 指针 + 重叠 temp。
 */
int32_t pipeline_asm_emit_block_inits_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta,
                                            int32_t slot_base) {
  int32_t nconst;
  int32_t nlet;
  int32_t idx;
  int32_t i;
  pipeline_glue_AsmFuncCtxLayout *ly;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  idx = 0;
  /* Const aggregate: G.7 reuse let slice/fixed-array helpers (peel lives there).
   * Prior: emit_expr + store_rax wrote a payload pointer into the fat / [N]T slot.
   * PLATFORM: SHARED freestanding emit — cold twin of runtime_pipeline_abi.x. */
  for (i = 0; i < nconst && (slot_base + idx) < ly->num_locals; i++) {
    int32_t init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, i);
    int32_t type_ref = pipeline_block_const_type_ref(arena, block_ref, i);
    int32_t slot_off = backend_asm_ctx_slot_offset(ctx, slot_base + idx);
    int32_t empty = glue_init_is_empty_array_lit(arena, init_ref);
    int32_t done = 0;
    if (init_ref != 0 && type_ref > 0) {
      int32_t slice_st = glue_emit_slice_from_array_let_init_elf_c(
          arena, elf_ctx, block_ref, i, init_ref, type_ref, ctx, ta, slot_off);
      if (slice_st == 1)
        done = 1;
      else if (slice_st < 0)
        return -1;
    }
    if (!done && init_ref != 0 && type_ref > 0) {
      int32_t arr_st = glue_emit_fixed_array_type_let_init_elf_c(
          arena, elf_ctx, init_ref, ctx, ta, type_ref, slot_off);
      if (arr_st == 0)
        done = 1;
      else if (arr_st == -1)
        return -1;
    }
    if (!done && init_ref != 0 && !empty) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta) != 0)
        return -1;
    }
    idx++;
  }
  for (i = 0; i < nlet && (slot_base + idx) < ly->num_locals; i++) {
    int32_t init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, i);
    int32_t slot = slot_base + idx;
    int32_t type_ref;
    uint8_t lnb[256];
    int32_t llen;
    if (init_ref == 0) {
      idx++;
      continue;
    }
    /**
     * wave330: empty `[]` for TYPE_SLICE must write dual-GP {data,length=0} (G.7 authority
     * glue_emit_slice_from_array_let_init_elf_c). Fixed/pointer empties may still skip.
     * PLATFORM: SHARED freestanding emit.
     */
    if (glue_init_is_empty_array_lit(arena, init_ref)) {
      llen = pipeline_block_let_name_len(arena, block_ref, i);
      if (llen > 0) {
        pipeline_block_let_name_copy64(arena, block_ref, i, lnb);
        if (glue_lazy_append_block_let_local(arena, ctx, block_ref, i, lnb, llen) != 0)
          return -1;
      }
      type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
      {
        int32_t slice_st =
            glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, i, init_ref, type_ref, ctx, ta,
                                                      backend_asm_ctx_slot_offset(ctx, slot));
        if (slice_st < 0)
          return -1;
      }
      idx++;
      continue;
    }
    /** stmt_order==0 路径：fill_local_slots 可能因 block_ref 碰撞跳过，懒登记真实栈偏移。 */
    llen = pipeline_block_let_name_len(arena, block_ref, i);
    if (llen > 0) {
      pipeline_block_let_name_copy64(arena, block_ref, i, lnb);
      if (glue_lazy_append_block_let_local(arena, ctx, block_ref, i, lnb, llen) != 0)
        return -1;
    }
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    if (glue_block_let_is_simd_vector_type(arena, block_ref, i)) {
      int32_t vst = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                         backend_asm_ctx_slot_offset(ctx, slot), type_ref);
      if (vst == 0) {
        /* 向量 ARRAY_LIT / VAR 拷贝 / 逐 lane binop 已直写 let 槽 */
      } else if (vst == -1) {
        return -1;
      } else {
        /* METHOD_CALL/CALL: G.7 reuse struct CALL sret/dual-GP (Vec8i sret). */
        int32_t st = glue_emit_struct_type_let_init_elf_c(
            arena, elf_ctx, init_ref, ctx, ta, type_ref,
            backend_asm_ctx_slot_offset(ctx, slot));
        if (st == 0) {
          /* handled */
        } else if (st == -1) {
          return -1;
        } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0) {
          return -1;
        } else if (glue_store_retval_pair_to_rbp_elf_c(
                       glue_emit_module_from_ctx(ctx), arena, elf_ctx, type_ref,
                       backend_asm_ctx_slot_offset(ctx, slot), ta, init_ref, ctx) != 0) {
          return -1;
        }
      }
    } else if (glue_block_let_is_fixed_array_type(arena, block_ref, i)) {
      /**
       * wave354: T[N] = [..] / VAR / FIELD / CALL — element-wise into let slot.
       * G.7: glue_emit_fixed_array_type_let_init_elf_c (reuses STRUCT_LIT field store).
       * Prior: only ARRAY_LIT; FIELD fell through to 8B pointer store (Ubuntu fs wrong sum).
       */
      int32_t arr_st =
          glue_emit_fixed_array_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, type_ref,
                                                    backend_asm_ctx_slot_offset(ctx, slot));
      if (arr_st == 0) {
        /* fixed array payload written */
      } else if (arr_st == -1) {
        return -1;
      } else {
        /* -2 unsupported fixed-array init — do not store pointer into array slot. */
        /* Class AW: Cap XLANG_ASM_DEBUG note retired. */
        return -1;
      }
    } else {
      int32_t slice_st = glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, i, init_ref,
                                                                   type_ref, ctx, ta,
                                                                   backend_asm_ctx_slot_offset(ctx, slot));
      if (slice_st == 1) {
        /* slice from array var 已写入 { data, length } */
      } else if (slice_st < 0) {
        return -1;
      } else {
      int32_t st =
          glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, type_ref,
                                               backend_asm_ctx_slot_offset(ctx, slot));
      if (st == 0) {
        /* struct 字面量或 mk(...) 内联已写入 let 槽 */
      } else if (st == -1) {
        return -1;
      } else if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
        return -1;
      pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, i, init_ref, ctx);
      } else {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      /* wave314: f32 init → f64 let: use scalar-f32 classifier (decl/resolved/index). */
      {
        int32_t dty = type_ref > 0 ? type_ref : pipeline_block_let_type_ref(arena, block_ref, i);
        if (glue_type_ref_is_scalar_f64_c(arena, dty) &&
            glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, init_ref)) {
          if (backend_enc_cvtss2sd_rax_from_f32_bits_arch(elf_ctx, ta) != 0)
            return -1;
        } else {
          int32_t src_ty = glue_float_promote_src_ty_ref_c(arena, init_ref);
          if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, dty, src_ty, ta) != 0)
            return -1;
        }
      }
      /* Prefer dual-GP store_retval (Option_ptr rdx half) over bare store_rax.
       * PLATFORM: WINDOWS leftover-PE. */
      if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx,
              type_ref > 0 ? type_ref : pipeline_block_let_type_ref(arena, block_ref, i),
              backend_asm_ctx_slot_offset(ctx, slot), ta, init_ref, ctx) != 0)
        return -1;
      }
      }
    }
    idx++;
  }
  return 0;
}

/**
 * Check whether a block-internal let name matches an EXPR_VAR (length + bytes).
 *
 * Why: glue_fill_var_types_from_lets_in_block and glue_fill_array_lit_types_in_
 * block iterate block lets and match them against EXPR_VAR refs to propagate
 * resolved_type from let init to var usage. This helper centralizes the
 * name comparison so callers don't repeat kind_ord + name_len + memcmp.
 *
 * Invariant: returns 0 for NULL arena/let_nm, invalid expr_ref, let_nlen <= 0,
 * or non-VAR (kind_ord != 3); returns 1 iff var name length and bytes match
 * let_nm exactly.
 *
 * Asm/Perf: O(n) — one name read + one byte loop. Cold path — called per
 * let × per expr in glue_fill_var_types_from_lets_in_block (glue.c:8985) and
 * glue_fill_array_lit_types_in_block (glue.c:9015).
 *
 * PLATFORM: SHARED — name comparison is platform-independent.
 *
 * wave1084 G.7: migrated from glue.c:8914 (body 19 LOC). Static (non-extern):
 * same-TU — block_inits.c #include at L3830 < def EOF < all callsites
 * (glue.c:8985/9015). Dependencies: pipeline_expr_kind_ord_at /
 * pipeline_expr_var_name_len / pipeline_expr_var_name_into (all extern).
 */
int glue_let_name_matches_var(struct ast_ASTArena *arena, int32_t expr_ref, const uint8_t *let_nm,
                                   int32_t let_nlen) {
  uint8_t vn[256];
  int32_t vlen;
  int32_t j;
  if (!arena || !let_nm || let_nlen <= 0 || expr_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, expr_ref);
  if (vlen != let_nlen)
    return 0;
  pipeline_expr_var_name_into(arena, expr_ref, vn);
  for (j = 0; j < let_nlen; j++) {
    if (vn[j] != let_nm[j])
      return 0;
  }
  return 1;
}

/* ─────────────────────────────────────────────────────────────────────────── */
/* wave1118-1123 G.7: skipped-typeck array-lit/var type backfill domain (5 fns)
 * migrated from pipeline_glue.c L6729-6851. These form a tight interdependent
 * cluster: glue_fill_array_lit_types_in_block orchestrates over the other
 * four, and glue_fill_var_types_from_params_for_func / _from_lets_in_block
 * both consume glue_expr_in_scope_block_c + glue_let_name_matches_var
 * (defined above in this file). Co-located with the block-init domain.
 * Static (non-extern): same-TU visibility via #include order — block_inits.c
 * #include at glue.c L3689 < all callsites (L8981+ public skipped-typeck
 * path). Zero fwd decls required. PLATFORM: SHARED. */

/**
 * Backfill a let/const declaration type T[N] into the ARRAY_LIT init's
 * resolved_type_ref (mirrors typeck_coerce_init_expr_to_decl).
 *
 * Why: when the asm emitter skips .x typeck (skip-heavy C-only modules),
 * ARRAY_LIT inits have resolved_type_ref=0; the asm array_lit path needs
 * the element count from the declared array type to size the memcpy.
 *
 * Contract: no-op if arena/decl_ty_ref/init_ref invalid, decl_ty_ref is
 * not TYPE_ARRAY (kind ord 10), or init_ref is not EXPR_ARRAY_LIT (kind 46).
 *
 * PLATFORM: SHARED — pure type_ref stamp, no arch dependency.
 */
void glue_fill_array_lit_from_decl(struct ast_ASTArena *arena, int32_t decl_ty_ref, int32_t init_ref) {
  struct ast_Expr *init_ex;
  if (!arena || decl_ty_ref <= 0 || decl_ty_ref > arena->num_types || init_ref <= 0 ||
      init_ref > arena->num_exprs)
    return;
  if (pipeline_type_kind_ord_at(arena, decl_ty_ref) != GLUE_TYPE_KIND_ARRAY)
    return;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return;
  init_ex = pipeline_arena_expr_ptr(arena, init_ref);
  if (!init_ex)
    return;
  init_ex->resolved_type_ref = decl_ty_ref;
}

/**
 * Return 1 if expr_ref lives in scope_block_ref or any of its child blocks.
 * Prevents cross-function / cross-sibling-block name collisions from
 * polluting resolved_type_ref during the skip-typeck backfill.
 *
 * Why: the asm skip-typeck path scans all exprs for name matches; without
 * this scope gate, `v` in func A would inherit the type of `v` in func B.
 *
 * Contract: returns 0 for invalid arena/refs. Depth-limited to 128 to
 * prevent infinite loops on cyclic block graphs (should not happen).
 *
 * PLATFORM: SHARED — pure block-tree walk, no arch dependency.
 */
int32_t glue_expr_in_scope_block_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t scope_block_ref) {
  int32_t cur;
  int32_t depth;
  if (!arena || expr_ref <= 0 || scope_block_ref <= 0 || scope_block_ref > arena->num_blocks)
    return 0;
  cur = pipeline_expr_block_ref_at(arena, expr_ref);
  if (cur == scope_block_ref)
    return 1;
  depth = 0;
  while (cur > 0 && cur <= arena->num_blocks && depth < 128) {
    struct ast_Block *b = pipeline_arena_block_ptr(arena, cur);
    if (!b)
      break;
    cur = b->parent_block_ref;
    if (cur == scope_block_ref)
      return 1;
    depth++;
  }
  return 0;
}

/**
 * Backfill resolved_type_ref for EXPR_VAR nodes that match a function
 * parameter name (skip .x typeck path; SoA `arr[i].field` needs T[N]).
 * Only writes when resolved_type_ref is still 0, so multiple functions
 * with same-named params (e.g. `v`) do not overwrite each other.
 *
 * Why: the asm emitter dereferences INDEX/METHOD_CALL base VARs whose
 * resolved_type_ref was never set by the skipped typeck pass.
 *
 * Contract: no-op if m/arena/func_index invalid or func has no body.
 * Iterates all exprs (O(E×P)) — cold path, only called when typeck
 * is skipped.
 *
 * PLATFORM: SHARED — pure type_ref propagation, no arch dependency.
 * Link surface: non-static so typeck_soa_fill_field_access_for_asm_emit
 * (typeck_x.o) can call after 8.3.3 R2 migration.
 */
/* Stage12 mega emit wall: module-level fill memo (align pure .x).
 * First typeck_soa per-func call fills whole module; later calls no-op. */
static struct ast_ASTArena *g_fill_var_memo_arena;
static int32_t g_fill_var_memo_nexprs;
static int g_fill_var_lets_done;
static int g_fill_var_params_done;
static struct ast_Module *g_fill_var_params_mod;

static void glue_fill_var_memo_touch(struct ast_ASTArena *arena) {
  if (!arena)
    return;
  if (g_fill_var_memo_arena != arena || g_fill_var_memo_nexprs != arena->num_exprs) {
    g_fill_var_memo_arena = arena;
    g_fill_var_memo_nexprs = arena->num_exprs;
    g_fill_var_lets_done = 0;
    g_fill_var_params_done = 0;
    g_fill_var_params_mod = NULL;
  }
}

void glue_fill_var_types_from_params_for_func(struct ast_Module *m, struct ast_ASTArena *arena,
                                              int32_t func_index) {
  int32_t fi;
  int32_t ei;
  int32_t *owner;
  int32_t nblocks;
  /* Module-level once: body owner map + single VAR pass.
   * PLATFORM: SHARED — align runtime_pipeline_abi.x. */
  if (!m || !arena || func_index < 0 || func_index >= (int32_t)m->num_funcs)
    return;
  glue_fill_var_memo_touch(arena);
  if (g_fill_var_params_done && g_fill_var_params_mod == m)
    return;
  nblocks = arena->num_blocks;
  if (nblocks <= 0 || arena->num_exprs <= 0) {
    g_fill_var_params_done = 1;
    g_fill_var_params_mod = m;
    return;
  }
  owner = (int32_t *)calloc((size_t)nblocks + 1, sizeof(int32_t));
  if (!owner)
    return; /* rare OOM — leave unfilled; typeck path still has types */
  for (fi = 0; fi < (int32_t)m->num_funcs; fi++) {
    int32_t br;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    br = pipeline_module_func_body_ref_at(m, fi);
    if (br > 0 && br <= nblocks)
      owner[br] = fi + 1;
  }
  for (ei = 1; ei <= arena->num_exprs; ei++) {
    int32_t cur;
    int32_t depth;
    if (pipeline_expr_kind_ord_at(arena, ei) != 3)
      continue;
    if (pipeline_expr_resolved_type_ref(arena, ei) > 0)
      continue;
    cur = pipeline_expr_block_ref_at(arena, ei);
    depth = 0;
    while (cur > 0 && cur <= nblocks && depth < 128) {
      int32_t own = owner[cur];
      if (own > 0) {
        int32_t f = own - 1;
        int32_t np = pipeline_module_func_num_params_at(m, f);
        int32_t pi;
        for (pi = 0; pi < np; pi++) {
          uint8_t nm[256];
          int32_t nlen = pipeline_module_func_param_name_len_at(m, f, pi);
          int32_t tref;
          if (nlen <= 0 || nlen > 255)
            continue;
          pipeline_module_func_param_name_copy32(m, f, pi, nm);
          tref = pipeline_module_func_param_type_ref_at(m, f, pi);
          if (tref > 0 && glue_let_name_matches_var(arena, ei, nm, nlen)) {
            pipeline_expr_set_resolved_type_ref(arena, ei, tref);
            break;
          }
        }
        break;
      }
      {
        W277_Block *b = w277_block_at(arena, cur);
        if (!b)
          break;
        cur = b->parent_block_ref;
        depth++;
      }
    }
  }
  free(owner);
  g_fill_var_params_done = 1;
  g_fill_var_params_mod = m;
}

/**
 * Backfill resolved_type_ref for EXPR_VAR nodes that match block let names.
 * Module-level once (BSS memo): single VAR pass, ancestor lets, nearest wins.
 * PLATFORM: SHARED — align pure .x mega emit wall fix.
 */
void glue_fill_var_types_from_lets_in_block(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t ei;
  if (!arena || block_ref <= 0 || block_ref > arena->num_blocks)
    return;
  glue_fill_var_memo_touch(arena);
  if (g_fill_var_lets_done)
    return;
  for (ei = 1; ei <= arena->num_exprs; ei++) {
    struct ast_Expr *ex;
    int32_t cur;
    int32_t depth;
    if (pipeline_expr_kind_ord_at(arena, ei) != 3)
      continue;
    ex = pipeline_arena_expr_ptr(arena, ei);
    if (!ex || ex->resolved_type_ref > 0)
      continue;
    cur = pipeline_expr_block_ref_at(arena, ei);
    depth = 0;
    while (cur > 0 && cur <= arena->num_blocks && depth < 128) {
      int32_t nlet = ast_ast_block_num_lets(arena, cur);
      int32_t li;
      int found = 0;
      for (li = 0; li < nlet; li++) {
        int32_t tref = pipeline_block_let_type_ref(arena, cur, li);
        uint8_t nm[256];
        int32_t nlen;
        if (tref <= 0)
          continue;
        nlen = pipeline_block_let_name_len(arena, cur, li);
        if (nlen <= 0 || nlen > 255)
          continue;
        pipeline_block_let_name_copy64(arena, cur, li, nm);
        if (glue_let_name_matches_var(arena, ei, nm, nlen)) {
          ex->resolved_type_ref = tref;
          found = 1;
          break;
        }
      }
      if (found)
        break;
      {
        W277_Block *b = w277_block_at(arena, cur);
        if (!b)
          break;
        cur = b->parent_block_ref;
        depth++;
      }
    }
  }
  g_fill_var_lets_done = 1;
}

/**
 * Walk block-internal lets and backfill ARRAY_LIT init types for the
 * skip-typeck asm path (e.g. `let buf: u8[12] = [0;12]` in hello.x).
 *
 * Why: stamps ARRAY_LIT resolved_type_ref from the declared let type (via
 * glue_fill_array_lit_from_decl). VAR let-type prop is G.7-owned by
 * typeck_soa_fill_field_access / glue_fill_var_types_from_lets_in_block
 * (called once there — not duplicated here).
 *
 * Contract: no-op if arena/block_ref invalid.
 *
 * PLATFORM: SHARED — pure orchestration, no arch dependency.
 */
void glue_fill_array_lit_types_in_block(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nlet;
  int32_t i;
  if (!arena || block_ref <= 0 || block_ref > arena->num_blocks)
    return;
  nlet = ast_ast_block_num_lets(arena, block_ref);
  for (i = 0; i < nlet; i++) {
    glue_fill_array_lit_from_decl(arena, pipeline_block_let_type_ref(arena, block_ref, i),
                                ast_pipeline_block_let_init_ref(arena, block_ref, i));
  }
}

/* ============================================================
 * wave1229 G.7: public skipped-typeck ARRAY_LIT fill entry
 * (migrated from pipeline_glue.c; colocated with glue_fill_array_lit_types_in_block).
 *
 * Why here: sole non-trivial callee is glue_fill_array_lit_types_in_block
 * (static above). Public entry walks module funcs and fills each body block
 * so asm emit can resolve ARRAY_LIT elem stride when .x typeck was skipped.
 *
 * Callers (cross-TU / same-TU after this #include):
 *  - ast_pool.c (extern decl + call on skip-typeck path)
 *  - runtime_pipeline_abi.x / seeds (export / surface)
 *  - runtime_driver_strict_glue_stubs.from_x.c (XLANG_WEAK cold stub)
 *
 * Deps: pipeline_debug_trace_named_func_bodies / pipeline_asm_module_func_is_extern_at /
 *       pipeline_module_func_body_ref_at — declared in pipeline_glue.c before this
 *       file's #include, so same-TU visible without local fwd decl.
 *
 * PLATFORM: SHARED — pure orchestration, no arch dependency.
 * ============================================================ */

/**
 * Backfill ARRAY_LIT resolved_type_ref for all non-extern function bodies when
 * C precheck skipped .x typeck (e.g. `let buf: u8[N] = [..]` in hello.x).
 *
 * Why: pipeline_asm_array_lit_elem_type_ref needs stamped elem type so emit
 * uses the correct lane stride (avoid Hello packing as H\\0e\\0…).
 *
 * Contract:
 *  - NULL module or arena → no-op.
 *  - Skips extern func slots (EMIT_HEAVY declarations without body; walking
 *    them would SIGSEGV).
 *  - body_ref <= 0 → skip that func.
 *
 * Invariant: for each walked body, delegates to glue_fill_array_lit_types_in_block
 * (let→VAR type prop + ARRAY_LIT stamp from decl type).
 *
 * PLATFORM: SHARED.
 */
void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena) {
  int32_t fi;
  int32_t nf;
  if (!m || !arena)
    return;
  pipeline_debug_trace_named_func_bodies("fill_array_pre", m, arena);
  nf = m->num_funcs;
  for (fi = 0; fi < nf; fi++) {
    int32_t br;
    /* parser EMIT_HEAVY: extern bl→glue declarations occupy func slots without
     * a body; walking them would SIGSEGV. */
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    br = pipeline_module_func_body_ref_at(m, fi);
    if (br <= 0)
      continue;
    glue_fill_array_lit_types_in_block(arena, br);
  }
  pipeline_debug_trace_named_func_bodies("fill_array_post", m, arena);
}

/* ============================================================
 * wave1149 G.7: block locals tree fill + init reserve bytes pair
 * (migrated from pipeline_glue.c L1583-1604 + L1679-1690).
 *
 * Why here: pipeline_asm_fill_block_locals_tree walks a block_ref
 * subtree and registers all const/let into the AsmFuncCtx sidecar
 * (via asm_ctx_fill_locals_block_tree). It is the entry-point for
 * block-level local slot allocation — colocated with the block
 * const/let init emit domain already in this file.
 *
 * glue_asm_init_expr_reserve_stack_bytes is the companion helper
 * that computes extra temp bytes for ARRAY_LIT/STRUCT_LIT let
 * initializers (used by pipeline_asm_let_init_stack_reserve_bytes
 * in glue.c). Colocating both keeps block-local allocation logic
 * in one file.
 *
 * Dependencies (visible via earlier decls in the TU):
 *   - pipeline_asm_ctx_layout (static, defined at glue.c L86,
 *     before this file's #include at L3617)
 *   - pipeline_glue_AsmFuncCtxLayout (struct, defined at glue.c L84)
 *   - asm_ctx_fill_locals_block_tree (extern, declared at glue.c L1557)
 *   - asm_array_lit_reserve_stack_bytes / asm_struct_lit_reserve_stack_bytes
 *     (extern, declared at glue.c L1676-1677)
 *   - pipeline_asm_emit_set_module (extern, defined at glue.c L4247,
 *     AFTER this file's #include at L3617 — extern fwd decl below)
 *
 * Globals: pipeline_asm_fill_block_locals_tree previously wrote to
 *   glue.c-local static g_pipeline_asm_emit_module; replaced with
 *   the public setter pipeline_asm_emit_set_module (G.7 single
 *   authority for the active emit module global).
 *
 * Callers (all AFTER this file's #include at L3617):
 *   - pipeline_asm_emit_block_body.c:297 (via #include at L3632)
 *   - pipeline_asm_emit_block_if_stmt.c:73,90 (via #include at L3635)
 *   - glue.c L5230 (pipeline_asm_emit_block_body_sync_elf caller)
 *   - glue.c L2113 calls glue_asm_init_expr_reserve_stack_bytes
 *     (BEFORE this file's #include at L3617 — static fwd decl added
 *     at glue.c before L2106)
 *
 * PLATFORM: SHARED — pure block-local slot allocation; no platform ABI dep.
 * ============================================================ */

/* extern fwd decl: pipeline_asm_emit_set_module is defined at glue.c L4247
 * (AFTER this file's #include at L3617). Sole use is the side-effect write
 * in pipeline_asm_fill_block_locals_tree (replacing direct global write). */

/**
 * Register all const/let within a block_ref subtree into AsmFuncCtx sidecar.
 * Side effect: sets the active emit module from ctx prefix (offset 16) via
 * the public setter pipeline_asm_emit_set_module (G.7 single authority for
 * g_pipeline_asm_emit_module; was a direct static-global write before wave1149).
 */
/* wave129 Cap residual: pure block_if leave (was static same-TU). PLATFORM: SHARED. */
void pipeline_asm_fill_block_locals_tree(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena,
                                         int32_t block_ref) {
  struct ast_Module *mod_ref;
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t off;
  int32_t nl;
  if (!ctx || !arena || block_ref <= 0)
    return;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return;
  /* module_ref at AsmFuncCtx prefix offset 16; feeds asm_local_slot_bytes
   * struct layout queries via the active emit module global. */
  mod_ref = *(struct ast_Module **)((uint8_t *)ctx + 16);
  if (mod_ref)
    pipeline_asm_emit_set_module(mod_ref);
  off = ly->next_offset;
  nl = ly->num_locals;
  asm_ctx_fill_locals_block_tree((uint8_t *)ctx, arena, block_ref, &off, &nl);
  ly->next_offset = off;
  ly->num_locals = nl;
}

/**
 * Extra temp stack bytes reserved for ARRAY_LIT/STRUCT_LIT let/const
 * initializers (beyond the pointer slot). Returns 0 for non-aggregate inits.
 */
int32_t glue_asm_init_expr_reserve_stack_bytes(struct ast_ASTArena *arena, int32_t init_ref) {
  int32_t n;
  if (init_ref <= 0)
    return 0;
  n = asm_array_lit_reserve_stack_bytes(arena, init_ref);
  if (n > 0)
    return n;
  return asm_struct_lit_reserve_stack_bytes(arena, init_ref);
}

/* ========================================================================== *
 * wave1204 G.7: pipeline_asm_let_init_stack_reserve_bytes migrated from
 * pipeline_glue.c L1498-1506. Colocated with glue_asm_init_expr_reserve_
 * stack_bytes (L723 above) — its sole static callee returning non-zero
 * fallback. Two other static callees (glue_vector_let_init_uses_direct_slot
 * in vector_simd.c L2218 + glue_fixed_array_let_init_uses_direct_slot in
 * vector_let.c L2063) are visible here via same-TU #include order:
 *   vector_let.c   #include at glue.c L2063  (before this file at L2404)
 *   vector_simd.c  #include at glue.c L2218  (before this file at L2404)
 * Root: original glue.c L1498 definition preceded those #includes —
 * glue_fixed_array_let_init_uses_direct_slot had NO fwd decl, relying on
 * C implicit declaration. Migrating here fixes that latent issue.
 *
 * Members (1 fn):
 *  - pipeline_asm_let_init_stack_reserve_bytes (extern; 3 static callees)
 *
 * Callers (4 sites, all via same-TU #include after L2404 OR via extern):
 *  - pipeline_asm_emit_context.c L724/739 (#include at L2564, after L2404)
 *  - ast_pool.c L8497/8511 (#include at L3186, after L2404; extern decl L8080)
 *  - ast_pool_top_level.c L323 (via extern decl at L285)
 *  - pipeline_asm_emit_modlet.c L530 (#include at L1543, BEFORE L2404 —
 *    needs extern fwd decl added at modlet.c L331)
 *
 * Cleaned up in glue.c:
 *  - static fwd decl for glue_asm_init_expr_reserve_stack_bytes (L1081)
 *  - static fwd decl for glue_vector_let_init_uses_direct_slot (L1467)
 * Both had pipeline_asm_let_init_stack_reserve_bytes as sole caller.
 *
 * PLATFORM: SHARED — pure stack byte arithmetic, no arch dependency.
 * ========================================================================== */

/**
 * Extra stack bytes reserved for a let/const initializer beyond its type slot.
 *
 * Why: VECTOR and fixed TYPE_ARRAY let-inits that emit via ARRAY_LIT direct
 *      slot writes need 0 extra bytes (pointer slot suffices). All other
 *      aggregate initializers (STRUCT_LIT, nested ARRAY_LIT) need temp space
 *      for the init expression — delegated to glue_asm_init_expr_reserve_
 *      stack_bytes above (which checks asm_array_lit_reserve_stack_bytes
 *      then asm_struct_lit_reserve_stack_bytes).
 * Contract: NULL arena -> 0; type_ref<=0 or init_ref<=0 -> 0 (via callee).
 * Invariant: returns 0 for direct-slot inits (VECTOR/fixed-array);
 *            returns glue_asm_init_expr_reserve_stack_bytes result otherwise.
 * Asm/Perf: O(1) — 2 boolean checks + 1 tail call. Cold path (fill_local_slots).
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_let_init_stack_reserve_bytes(struct ast_ASTArena *arena, int32_t type_ref, int32_t init_ref) {
  if (!arena)
    return 0;
  if (glue_vector_let_init_uses_direct_slot(arena, type_ref, init_ref))
    return 0;
  if (glue_fixed_array_let_init_uses_direct_slot(arena, type_ref, init_ref))
    return 0;
  return glue_asm_init_expr_reserve_stack_bytes(arena, init_ref);
}



/* ========================================================================== *
 * wave146: pipeline_asm_emit_vector_let pure-owned leave cold twins.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave145 leave twins.
 * Product authority lives in runtime_pipeline_abi.x; these C bodies link only
 * when FROM_X is unset (cold bootstrap / seed path).
 * Cap residual externs: emit_expr_elf_rec / enc / may_clobber / var_stack /
 *   field_offset / index_elem / bulk_mem / type/pool faces.
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 * ========================================================================== */

#ifndef GLUE_ARRAY_LIT_MAX_ELEMS
#define GLUE_ARRAY_LIT_MAX_ELEMS 1024
#endif
#ifndef GLUE_ARRAY_LIT_MAX_PAYLOAD
#define GLUE_ARRAY_LIT_MAX_PAYLOAD 4096
#endif

/* Cap residual / pool / enc faces (host residual or pure elsewhere). */
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t er, int32_t idx);
extern int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_asm_array_lit_elem_byte_sz_c(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *a, int32_t er);
extern int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *a, void *elf, int32_t init, void *ctx, int32_t ta, int32_t ty, int32_t off);
extern int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_asm_emit_expr_elf_c(struct ast_ASTArena *a, void *elf, int32_t er, void *ctx, int32_t ta); /* public */
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t sz, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rbx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_zext8_from_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_load_i32_indirect_to_rax_arch(void *elf, int32_t ta);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *a, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t ref);
extern int32_t glue_index_elem_byte_sz_from_type_ref_c(struct ast_ASTArena *a, int32_t tr);
extern int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *a, int32_t er);
extern int32_t glue_var_expr_stack_off_elf_c(struct ast_ASTArena *a, void *ctx, int32_t er);
extern int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t er);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t er);
extern int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *a, void *mod, int32_t fa);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t glue_emit_bulk_mem_copy_spills_elf_c(void *elf, int32_t src, int32_t dst, int32_t n, int32_t ta);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_ctx_sret_home_off_get(void);

#ifndef PIPELINE_GLUE_ASM_FUNC_CTX_LAYOUT_SEED_T
#define PIPELINE_GLUE_ASM_FUNC_CTX_LAYOUT_SEED_T
typedef struct {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
} pipeline_glue_AsmFuncCtxLayout;
#endif

/* wave146 cold twins (faithful from pipeline_asm_emit_vector_let.c). */

int32_t pipeline_asm_array_lit_leaf_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t init_ref) {
  int32_t cur;
  int32_t guard;
  if (!arena || init_ref <= 0)
    return 4;
  cur = init_ref;
  for (guard = 0; guard < 8; guard++) {
    int32_t first;
    if (pipeline_expr_kind_ord_at(arena, cur) != 46)
      break;
    first = pipeline_expr_array_lit_elem_ref(arena, cur, 0);
    if (first <= 0)
      break;
    if (pipeline_expr_kind_ord_at(arena, first) != 46) {
      /* Innermost ARRAY_LIT of non-array elems — scalar/struct width. */
      int32_t esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, cur);
      return esz > 0 ? esz : 4;
    }
    cur = first;
  }
  {
    int32_t esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, init_ref);
    return esz > 0 ? esz : 4;
  }
}

/**
 * wave357: flatten nested ARRAY_LIT to row-major scalar stores at base+flat_i*leaf_esz.
 * Same address geometry as 1D vector_let (lea base once-per-store + positive store off).
 *
 * wave627 Cap residual pure: multi-dim nested ARRAY_LIT of STRUCT_LIT leaves
 * (e.g. `Pt[2][1] = [[Pt{10,0}], [Pt{0,32}]]`).
 * Root: flat path always emit_expr (STRUCT_LIT slot=-1 → next_offset aliases array
 * byte0) then store_sz clamped ≤8 of rax — same high-end overwrite class as
 * wave626 1D vector_let. Ubuntu pure-asm sum=32; host-C braces green.
 * G.7: per-leaf glue_emit_struct_type_let_init at arch-aware home (≡ wave598/626).
 * PLATFORM: SHARED freestanding multi-dim · LINUX|x86 high-end · MACOS|ARM64 low-end.
 *
 * @return 0 ok; -1 error
 */
/* wave143 pure Cap residual: static→extern. */
int32_t pipeline_asm_emit_array_lit_flat_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                      struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                      int32_t stack_slot_off, int32_t leaf_esz, int32_t *flat_i) {
  int32_t n_arr;
  int32_t ai;
  int32_t elem_ref;
  int32_t store_sz;
  int32_t dest_elem;
  int32_t dest_ek;
  int32_t inner;
  int32_t inner_k;
  int32_t row_esz;
  int32_t row_home;
  int32_t cell_home;
  int32_t n_inner;
  int32_t ji;
  int32_t cell_ref;
  int32_t row_st;
  if (!arena || !elf_ctx || !ctx || !flat_i || init_ref <= 0 || leaf_esz <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
  /*
   * dest extras dest-ARRAY of ARRAY extra `[K][N][]T`: dest elem is
   * TYPE_ARRAY of SLICE. Flatten used to write i32 leaves (asg run=1 /
   * extra SIGSEGV 139). Walk ARRAY-of-ARRAY until SLICE; emit each
   * nested ARRAY_LIT row via dest-ARRAY let-init. `[K][N]i32` dest
   * elem is ARRAY of scalar — keep flatten. Do not invent -3.
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
   */
  dest_elem = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
  if (dest_elem > 0) {
    dest_ek = pipeline_type_kind_ord_at(arena, dest_elem);
    if (dest_ek == 10) {
      inner = pipeline_type_elem_ref_at(arena, dest_elem);
      inner_k = 0;
      if (inner > 0)
        inner_k = pipeline_type_kind_ord_at(arena, inner);
      /*
       * Direct elem is TYPE_SLICE (`[N][]T` row of `[K][N][]T`). Do
       * not call glue_emit_fixed_array here: this seed's vector_let_init
       * still flattens nested ARRAY_LIT. Reuse
       * glue_emit_slice_from_array_let_init per cell — same writer as
       * dest-ARRAY extra `[2][]i32`. PLATFORM: SHARED.
       */
      if (inner_k == 11) {
        row_esz = glue_array_lit_force_esz_from_elem_type_c(arena, dest_elem);
        if (row_esz <= 0)
          return -1;
        for (ai = 0; ai < n_arr && ai < GLUE_ARRAY_LIT_MAX_ELEMS; ai++) {
          elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
          if (elem_ref <= 0)
            continue;
          row_home = (ta == 1) ? (stack_slot_off + ai * row_esz)
                               : (stack_slot_off - ai * row_esz);
          if (row_home < 0)
            return -1;
          if (pipeline_expr_kind_ord_at(arena, elem_ref) == 46) {
            n_inner = pipeline_expr_array_lit_num_elems_at(arena, elem_ref);
            for (ji = 0; ji < n_inner && ji < GLUE_ARRAY_LIT_MAX_ELEMS; ji++) {
              cell_ref = pipeline_expr_array_lit_elem_ref(arena, elem_ref, ji);
              if (cell_ref <= 0)
                continue;
              cell_home = (ta == 1) ? (row_home + ji * 16)
                                    : (row_home - ji * 16);
              if (cell_home < 0)
                return -1;
              row_st = glue_emit_slice_from_array_let_init_elf_c(
                  arena, elf_ctx, 0, 0, cell_ref, inner, ctx, ta, cell_home);
              if (row_st != 1)
                return -1;
            }
          } else {
            row_st = glue_emit_fixed_array_type_let_init_elf_c(
                arena, elf_ctx, elem_ref, ctx, ta, dest_elem, row_home);
            if (row_st != 0)
              return -1;
          }
        }
        *flat_i = *flat_i + n_arr;
        return 0;
      }
    }
  }
  store_sz = leaf_esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
    store_sz = 4;
  for (ai = 0; ai < n_arr && ai < GLUE_ARRAY_LIT_MAX_ELEMS; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref == 0)
      continue;
    if (pipeline_expr_kind_ord_at(arena, elem_ref) == 46) {
      if (pipeline_asm_emit_array_lit_flat_elf_c(arena, elf_ctx, elem_ref, ctx, ta, stack_slot_off, leaf_esz,
                                                  flat_i) != 0)
        return -1;
      continue;
    }
    /*
     * wave627: STRUCT_LIT / >8B leaf — in-place at flat home (not rvalue next_offset).
     * PLATFORM: MACOS|ARM64 low-end home=base+i*esz; LINUX|x86 high-end home=base-i*esz.
     */
    if (leaf_esz > 8 || pipeline_expr_kind_ord_at(arena, elem_ref) == 45) {
      int32_t elem_home;
      int32_t st;
      elem_home = (ta == 1) ? (stack_slot_off + (*flat_i) * leaf_esz)
                            : (stack_slot_off - (*flat_i) * leaf_esz);
      if (elem_home < 0)
        return -1;
      st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, 0, elem_home);
      if (st == 0) {
        *flat_i = *flat_i + 1;
        continue;
      }
      if (st == -1)
        return -1;
      /* st == -2: not STRUCT_LIT/CALL — fall through to scalar store */
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    {
      int32_t may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
      /* G.7 ≡ emit_array_lit_force_esz: FLOAT_LIT + force_esz packs f32 IEEE bits. */
      if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, init_ref, elem_ref, ctx, ta,
                                                        leaf_esz) != 0)
        return -1;
      if (may_clobber != 0) {
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
          return -1;
      }
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, (*flat_i) * leaf_esz, store_sz, ta) != 0)
        return -1;
    }
    *flat_i = *flat_i + 1;
  }
  return 0;
}

/**
 * Fixed TYPE_ARRAY / SIMD vector let-init: write ARRAY_LIT elems into stack_slot_off.
 * wave342: apply wave340 may_clobber re-lea (G.7 same authority as emit_array_lit).
 * Root: base held only in rbx; binop elems (`n+10`) write ebx → store to garbage → Ubuntu
 * freestanding `let a:[3]i32=[n,n+10,n+20]` SIGSEGV (const lit OK). Host-C hid it.
 *
 * wave357 Cap residual pure: multi-dim nested ARRAY_LIT flattens row-major into the
 * fixed slot (same lea+store-off geometry as 1D). Nested base+row_sz was inverted vs
 * INDEX lea+add on some stack-offset encodings → Ubuntu run=0 / SIGSEGV.
 * G.7: single flat writer; leaf esz from first non-array elem path.
 *
 * wave598 Cap residual pure: freestanding ARRAY_LIT of >8B named struct elements.
 * Root: store_sz was clamped to 4 for esz∉{1,2,4,8} and only rax was stored — dual-GP
 * (9–16B) / sret (>16B) / STRUCT_LIT payload never landed. mac freestanding
 * `S12[2]=[mk(),mk()]` run=20≠42; STRUCT_LIT control same class (run=11≠32). Host-C
 * braces hid it. G.7: per-elem glue_emit_struct_type_let_init at arch-aware home
 * (same nest_slot polarity as wave595 nested STRUCT_LIT field).
 *
 * wave626 Cap residual pure: ≤8B STRUCT_LIT elements of fixed TYPE_ARRAY (e.g. Pt[2]).
 * Root: rvalue STRUCT_LIT (slot_off=-1) materializes at ly->next_offset without
 * advancing the high-end top; after fixed-array alloc, next_offset aliases array
 * byte0. Field stores for elem1 overwrite a[0] before bulk store to +ai*esz →
 * Ubuntu pure-asm p0x=0 / sum=32 (host-C 42; arm64 low-end next past alloc green).
 * G.7: same in-place let-init authority for STRUCT_LIT (ko=45) at any esz — not
 * only esz>8. PLATFORM: SHARED freestanding · LINUX|x86 high-end · MACOS|ARM64.
 */
int32_t pipeline_asm_emit_vector_let_init_elf_c(struct ast_ASTArena *arena,
                                                       struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
                                                       struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                       int32_t stack_slot_off) {
  int32_t n_arr;
  int32_t esz;
  int32_t ai;
  int32_t elem_ref;
  int32_t store_sz;
  int32_t flat_i;
  int32_t has_nested;
  int32_t elem_ty;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n_arr <= 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
  has_nested = 0;
  for (ai = 0; ai < n_arr && ai < GLUE_ARRAY_LIT_MAX_ELEMS; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref > 0 && pipeline_expr_kind_ord_at(arena, elem_ref) == 46) {
      has_nested = 1;
      break;
    }
  }
  if (has_nested != 0) {
    /* Leaf esz: peel all nested ARRAY_LIT levels to scalar width (wave613). */
    esz = pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena, init_ref);
    if (esz <= 0)
      esz = 4;
    flat_i = 0;
    return pipeline_asm_emit_array_lit_flat_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, esz, &flat_i);
  }
  esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, init_ref);
  if (esz <= 0)
    esz = 4;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
  store_sz = esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
    store_sz = 4;
  for (ai = 0; ai < n_arr && ai < GLUE_ARRAY_LIT_MAX_ELEMS; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    if (elem_ref == 0)
      continue;
    /*
     * wave598/626: named struct / dual-GP / sret / STRUCT_LIT element — write in place.
     * Frame home polarity matches nested STRUCT_LIT field (wave595):
     *   PLATFORM: MACOS|ARM64 low-end — home = base + ai*esz
     *   PLATFORM: LINUX|x86 high-end — home = base - ai*esz
     * wave626: STRUCT_LIT (ko=45) at any esz (not only esz>8) — rvalue path aliases
     * high-end array byte0 via next_offset (see function doc).
     */
    /* SIMD named elem (`let arr:[2]i32x4 = [z, z]`): dest is the real
     * frame home. Scalar emit_expr of a 16B VAR dual-GP clobbers dest-in-x1
     * then str [x1] (Darwin 139). G.7: vector let-init first.
     * PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail. */
    {
      int32_t elem_home;
      int32_t st;
      extern int32_t glue_emit_vector_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                                          void *ctx, int32_t ta, int32_t off, int32_t ty);
      elem_home = (ta == 1) ? (stack_slot_off + ai * esz) : (stack_slot_off - ai * esz);
      if (elem_home < 0)
        return -1;
      {
        int32_t vty = elem_ty;
        if (vty <= 0)
          vty = pipeline_expr_resolved_type_ref(arena, elem_ref);
        if (vty > 0) {
          st = glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta, elem_home, vty);
          if (st == 0)
            continue;
          if (st == -1)
            return -1;
        }
      }
      if (esz > 8 || pipeline_expr_kind_ord_at(arena, elem_ref) == 45) {
        st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                   elem_ty > 0 ? elem_ty : 0, elem_home);
        if (st == 0)
          continue;
        if (st == -1)
          return -1;
        /* st == -2: not STRUCT_LIT/CALL — fall through to scalar store */
      }
    }
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    {
      int32_t may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
      /* G.7 ≡ emit_array_lit_force_esz scalar path (wave617 f32 pack).
       * PLATFORM: SHARED freestanding · Vec4f/f32xN pure-asm gold. */
      if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, init_ref, elem_ref, ctx, ta,
                                                        esz) != 0)
        return -1;
      if (may_clobber != 0) {
        /* value@rax; restore fixed-array base@rbx (wave340 dual-slot). */
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
          return -1;
      }
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, store_sz, ta) != 0)
        return -1;
    }
  }
  return 0;
}

/**
 * Frame magnitude of a struct field at byte offset `foff` from struct byte0
 * whose frame magnitude is `base_off`.
 *
 * wave652 Cap residual pure: fixed TYPE_ARRAY field stores used base+foff on all
 * arches. On x86 high-end, lea -base(%rbp) is Outer byte0 and field@byte0+foff is
 * magnitude base-foff. Using base+foff placed the array *before* Outer; elem[1]
 * at +esz then overwrote pad (Ubuntu fs return w.pad → 32 not 7; take(w.xs)=0).
 * Nested STRUCT_LIT already used this polarity (wave595 nest_slot); array fields
 * must match. sret true-address paths still use pointer + foff (not this helper).
 *
 * @param base_off frame magnitude of Outer byte0 (lea ±base from fp)
 * @param foff field byte offset from Outer byte0 (layout; always ≥0)
 * @param ta target arch (1=arm64 low-end, 0=x86 high-end)
 * @return field frame magnitude, or -1 if invalid
 * PLATFORM: MACOS|ARM64 low-end mag=base+foff · LINUX|x86 high-end mag=base-foff
 */
int32_t glue_struct_field_frame_mag_c(int32_t base_off, int32_t foff, int32_t ta) {
  int32_t mag;
  if (foff < 0)
    return -1;
  if (foff == 0)
    return base_off;
  if (ta == 1) {
    /* PLATFORM: MACOS|ARM64 low-end — lea [x29,#base]; field@base+foff. */
    mag = base_off + foff;
  } else {
    /* PLATFORM: LINUX|x86 high-end — lea -base(%rbp)=byte0; field mag base-foff. */
    if (foff > base_off)
      return -1;
    mag = base_off - foff;
  }
  if (mag < 0)
    return -1;
  return mag;
}

/**
 * wave349/350/351 Cap residual pure: STRUCT_LIT field of fixed TYPE_ARRAY stores inline
 * payload (N×esz), not an 8-byte pointer.
 *
 * Root: generic STRUCT_LIT path emitted ARRAY_LIT into a temp then stored rax (temp
 * pointer) into the field — layout expects N elements; freestanding field index /
 * field→slice then read garbage (host-C braced expand already correct in codegen.x).
 *
 * Authority (G.7 single path):
 * - ARRAY_LIT + stack slot → pipeline_asm_emit_vector_let_init_elf_c (same as let-init)
 * - ARRAY_LIT + sret → per-elem emit + store at foff+i×esz via sret dest@rbx
 * - VAR → element-wise lea(src)+i×esz + esz-wide load / store (wave399; matches ARRAY_LIT)
 * - wave350 FIELD (`Box { a: b0.a }`) → same from VAR-base + field_off
 *   (src base = arch-aware field mag; elem[i] at base + i×esz — SHARED with CALL E* copy)
 * - wave351 CALL (`Box { a: fill(n) }`) → materialize CALL into temp (G.7 reuse
 *   glue_store_retval_pair / sret let-init), then same element-wise from temp.
 *   Companion: WPO walks STRUCT_LIT field inits (ast_pool) so fill is reachable.
 * - wave354: also the authority for `let t: T[N] = b.a` / `= a` / `= fill(n)` (foff=0 into
 *   let slot) and whole-array assign `t = b.a` — same element-wise copy; host-C uses memcpy.
 * - wave615: INDEX multi-dim subrow (`let r: T[N] = m[0]`) — same E* element-wise as CALL.
 * - wave652: dest frame mag = glue_struct_field_frame_mag_c (≡ nest_slot wave595).
 *
 * @return 0 handled; -1 error; -2 unsupported init (caller falls through)
 * PLATFORM: SHARED freestanding emit · LINUX gold · MACOS host-C uses braced expand
 */
int32_t glue_struct_lit_store_fixed_array_field_elf_c(
    struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t init_ref,
    struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t sret_direct, int32_t base_off, int32_t foff, int32_t fty) {
  int32_t iko;
  int32_t n_arr;
  int32_t esz;
  int32_t ai;
  int32_t elem_tr;
  int32_t src_off;
  int32_t field_mag;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || fty <= 0)
    return -1;
  iko = pipeline_expr_kind_ord_at(arena, init_ref);
  n_arr = pipeline_type_array_size_at(arena, fty);
  if (n_arr <= 0 && iko == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT)
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  /* Empty ARRAY_LIT has 0 elems; type size still supplies n_arr for zero-fill. */
  if (n_arr <= 0)
    return -1;
  elem_tr = pipeline_type_elem_ref_at(arena, fty);
  /* Outer stride of dest TYPE_ARRAY = sizeof(elem). Peel-then-measure
   * via glue_index_elem_byte_sz(elem) is wrong for [K][N]T: elem is
   * TYPE_ARRAY and index-esz peels again to sizeof(leaf) (4 for i32),
   * so VAR/CALL dest memcpy copies only the first row (asm run=3).
   * G.7: glue_array_lit_force_esz_from_elem_type (TYPE_ARRAY →
   * glue_fixed_array_total_bytes). Twin of 4.2.7 nested SLICE esz.
   * PLATFORM: SHARED freestanding dest-ARRAY memcpy · LINUX gold.
   * Cold twin of runtime_pipeline_abi.x (inside #ifndef FROM_X). */
  esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_tr);
  if (esz <= 0)
    esz = glue_index_elem_byte_sz_from_type_ref_c(arena, fty);
  if (esz <= 0)
    esz = 4;
  /*
   * wave652: non-sret dest is a frame magnitude. foff>0 must be arch-aware
   * (x86 high-end base-foff). sret paths keep true address + foff below.
   */
  field_mag = 0;
  if (sret_direct == 0) {
    field_mag = glue_struct_field_frame_mag_c(base_off, foff, ta);
    if (field_mag < 0)
      return -1;
  }

  /*
   * Stage 12.2.7: empty ARRAY_LIT `[]` ≡ product zero-init (host-C `{0}`).
   * vector_let_init rejects n_arr==0 → CG002 on struct fields like `data: []`.
   * n_arr > MAX: accept without per-elem stores (multi-MiB STRUCT_LIT zero avoided).
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.
   */
  {
    int32_t empty_array_zero = 0;
    if (iko == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT) {
      int32_t lit_n = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
      if (lit_n == 0) {
        empty_array_zero = 1;
      } else if (n_arr > GLUE_ARRAY_LIT_MAX_ELEMS) {
        return -1;
      } else if (sret_direct == 0) {
        return pipeline_asm_emit_vector_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, field_mag);
      } else {
        /* SysV sret: dest base in [sret_home]; store each elem at foff + i*esz. */
        for (ai = 0; ai < n_arr; ai++) {
          int32_t elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
          if (elem_ref == 0)
            continue;
          if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, elem_ref, ctx, ta) != 0)
            return -1;
          if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
            return -1;
          if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
            return -1;
          if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
            return -1;
          if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta) != 0)
            return -1;
        }
        return 0;
      }
    }

    /*
     * wave363 Cap residual / tip L4: `let a: T[N] = 0` (and STRUCT_LIT field = 0 / empty []).
     * typeck coerces EXPR_LIT 0 onto TYPE_ARRAY (pipeline_typeck_coerce_init_lit_to_decl_c);
     * host-C emits `= {0}`; freestanding previously returned -2 → CG002 num_funcs=0
     * on Ubuntu gold (tests/array/main.x). Zero-fill each element into the inline slot.
     * PLATFORM: SHARED freestanding · LINUX gold · only int_val==0 (product zero-init).
     */
    if (iko == (int32_t)ast_ExprKind_EXPR_LIT || empty_array_zero != 0) {
      if (empty_array_zero == 0) {
        int64_t lit_v = pipeline_expr_int64_val_at(arena, init_ref);
        if (lit_v != 0)
          return -2;
      }
      if (n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
        return 0;
      if (sret_direct == 0) {
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta) != 0)
          return -1;
        for (ai = 0; ai < n_arr; ai++) {
          if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, esz, ta) != 0)
            return -1;
        }
        return 0;
      }
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta) != 0)
        return -1;
      for (ai = 0; ai < n_arr; ai++) {
        if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
          return -1;
        if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta) != 0)
          return -1;
      }
      return 0;
    }
  }

  /*
   * VAR or FIELD_ACCESS source → element-wise copy into dest field.
   * wave350: FIELD (`b0.a`) was -2 fallthrough → generic store 8B pointer / first lane.
   * PLATFORM: SHARED freestanding · host-C braced expand already emits (src)[i] (codegen.x).
   */
  src_off = -1;
  if (iko == (int32_t)ast_ExprKind_EXPR_VAR) {
    src_off = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
  } else if (iko == (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS) {
    int32_t var_base;
    int32_t var_off;
    int32_t field_off;
    if (pipeline_expr_field_access_is_enum_variant(arena, init_ref) != 0)
      return -2;
    var_base = pipeline_expr_field_access_base_ref(arena, init_ref);
    if (var_base <= 0 || pipeline_expr_kind_ord_at(arena, var_base) != (int32_t)ast_ExprKind_EXPR_VAR)
      return -2;
    var_off = glue_var_expr_stack_off_elf_c(arena, ctx, var_base);
    if (var_off < 0)
      return -1;
    field_off = glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), init_ref);
    if (field_off < 0)
      field_off = 0;
    /*
     * wave652: src field mag arch-aware (≡ dest field_mag / nest_slot).
     * PLATFORM: MACOS|ARM64 low-end var+foff · LINUX|x86 high-end var-foff.
     */
    src_off = glue_struct_field_frame_mag_c(var_off, field_off, ta);
    if (src_off < 0)
      return -1;
  } else if (iko == (int32_t)ast_ExprKind_EXPR_CALL ||
             iko == (int32_t)ast_ExprKind_EXPR_METHOD_CALL ||
             iko == (int32_t)ast_ExprKind_EXPR_INDEX ||
             iko == 52) {
    /*
     * wave351/354: CALL/METHOD returning fixed TYPE_ARRAY → E* (host codegen.x
     * wave352 durable static; freestanding returns stack/COMMON ptr in rax/x0).
     * Element-wise load from *rax into dest (STRUCT_LIT field / let slot).
     *
     * wave398 Cap residual pure: prior gate was `ta == 0` only — macOS arm64
     * `let t: T[N] = fill(n)` logged "fixed array let unhandled init_ko=48" →
     * CG002. store_retval dual-GP (rdx) is x86-only; N*esz>16 falsely took
     * sret while ABI is still E*. G.7: emit CALL then ptr-copy with esz-wide
     * store_rax_to_rbx_offset (not 8B store_rax_to_rbp which clobbers neighbors).
     *
     * wave615 Cap residual pure: multi-dim INDEX subrow as fixed TYPE_ARRAY src
     * (`let r: i32[2] = m[0]` / STRUCT_LIT field / whole-array assign). Host-C
     * emits memcpy(dst, (m)[0], sizeof); freestanding only handled VAR/FIELD/CALL
     * → init_ko=47 "fixed array let unhandled" → CG002. INDEX of TYPE_ARRAY leaves
     * subrow address (wave357 no-load); same E* element-wise authority as CALL.
     *
     * wave633 Cap residual pure: esz>8 large NAMED (S24=24) must bulk-copy the
     * whole payload. Old else-branch load_i32 + store esz wrote only the first
     * i32 of each element → Ubuntu pure-asm `let s: S24[2] = mk()` sum=11 (a0+a1)
     * not 110; host-C memcpy green; temporary INDEX mk()[i].field often green
     * (reads durable COMMON directly). G.7: reuse glue_emit_bulk_mem_copy_spills
     * (wave630) — one contiguous n*esz copy; no third fixed-array path.
     *
     * DEREF=52 of *[N]T is the same leave-ptr E* (emit_deref trk==10 return 0).
     * `unsafe { let y: [2]i32 = *p }` previously returned -2 → SAT emit_block_inits
     * "fixed array let init unhandled" → CG002. take(*p) is GREEN because
     * for_call_args recs DEREF; let-init never reached emit_deref.
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
     */
    pipeline_glue_AsmFuncCtxLayout *ly;
    int32_t spill_off;
    int32_t emit_rc;
    ly = pipeline_asm_ctx_layout(ctx);
    if (!ly)
      return -1;
    /* Spill E* so each elem load can reload src without burning rbx across stores. */
    if (ly->next_offset + 16 < ly->next_offset)
      return -1;
    ly->next_offset += 16;
    spill_off = ly->next_offset;
    emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    if (emit_rc != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, spill_off, ta) != 0)
      return -1;
    /*
     * wave633: large NAMED / esz>8 — bulk copy contiguous n_arr*esz from E*.
     * Scalar esz∈{1,4,8} keep per-elem load/store (existing authority).
     */
    if (esz > 8) {
      int32_t src_spill;
      int32_t dst_spill;
      int32_t total;
      if (n_arr > GLUE_ARRAY_LIT_MAX_PAYLOAD / esz)
        return -1;
      total = n_arr * esz;
      if (total <= 0 || total > GLUE_ARRAY_LIT_MAX_PAYLOAD)
        return -1;
      if (ly->next_offset + 32 < ly->next_offset)
        return -1;
      ly->next_offset += 16;
      src_spill = ly->next_offset;
      ly->next_offset += 16;
      dst_spill = ly->next_offset;
      /* src = E* already in spill_off */
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
        return -1;
      if (sret_direct == 0) {
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta) != 0)
          return -1;
      } else {
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
          return -1;
        if (foff != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta) != 0)
          return -1;
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
        return -1;
      if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, total, ta) != 0)
        return -1;
      return 0;
    }
    for (ai = 0; ai < n_arr; ai++) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, spill_off, ta) != 0)
        return -1;
      if (ai * esz != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
        return -1;
      if (esz == 1) {
        if (backend_enc_load_zext8_from_rax_arch(elf_ctx, ta) != 0)
          return -1;
      } else if (esz == 8) {
        if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
          return -1;
      } else if (esz == 4) {
        if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
          return -1;
      } else {
        if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
          return -1;
      }
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (sret_direct == 0) {
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
      } else {
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
          return -1;
      }
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx,
                                                   (sret_direct == 0 ? ai * esz : foff + ai * esz), esz,
                                                   ta) != 0)
        return -1;
    }
    /* Fully handled — do not fall through to src_off element-wise. */
    return 0;
  }
  if (src_off >= 0) {
    /*
     * wave399 Cap residual pure: freestanding VAR/FIELD → fixed TYPE_ARRAY whole copy.
     * Root: wave334 used load_rbp_lane(src_off − i×esz). On x86 that matches
     * [rbp−off] polarity vs ARRAY_LIT lea+store(+i×esz). On arm64 slots live at
     * x29+off (lea add) and product load_rbp is 64-bit scaled imm/8 — non-aligned
     * i32 steps collapse (disasm: 0x20,0x18,0x18) → let b:T[N]=a sum=12 not 33.
     * G.7: same geometry as CALL E* path / ARRAY_LIT — lea(src)+i×esz + esz-wide
     * load, then store into dest (re-lea dest each elem; do not hold rbx across load).
     *
     * wave633: esz>8 large NAMED VAR/FIELD whole-array copy also bulk (twin of CALL).
     * PLATFORM: SHARED freestanding · MACOS|ARM64 + LINUX|x86_64.
     */
    if (esz > 8) {
      pipeline_glue_AsmFuncCtxLayout *ly_v;
      int32_t src_spill;
      int32_t dst_spill;
      int32_t total;
      ly_v = pipeline_asm_ctx_layout(ctx);
      if (!ly_v)
        return -1;
      if (n_arr > GLUE_ARRAY_LIT_MAX_PAYLOAD / esz)
        return -1;
      total = n_arr * esz;
      if (total <= 0 || total > GLUE_ARRAY_LIT_MAX_PAYLOAD)
        return -1;
      if (ly_v->next_offset + 32 < ly_v->next_offset)
        return -1;
      ly_v->next_offset += 16;
      src_spill = ly_v->next_offset;
      ly_v->next_offset += 16;
      dst_spill = ly_v->next_offset;
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
        return -1;
      if (sret_direct == 0) {
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta) != 0)
          return -1;
      } else {
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
          return -1;
        if (foff != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, foff, ta) != 0)
          return -1;
      }
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta) != 0)
        return -1;
      if (glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, total, ta) != 0)
        return -1;
      return 0;
    }
    for (ai = 0; ai < n_arr; ai++) {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta) != 0)
        return -1;
      if (ai * esz != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta) != 0)
        return -1;
      if (esz == 1) {
        if (backend_enc_load_zext8_from_rax_arch(elf_ctx, ta) != 0)
          return -1;
      } else if (esz == 8) {
        if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
          return -1;
      } else if (esz == 4) {
        if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
          return -1;
      } else {
        if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0)
          return -1;
      }
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (sret_direct == 0) {
        if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, field_mag, ta) != 0)
          return -1;
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
          return -1;
      } else {
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, pipeline_asm_emit_ctx_sret_home_off_get(), ta) != 0)
          return -1;
      }
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbx_offset_arch(
              elf_ctx, (sret_direct == 0 ? ai * esz : foff + ai * esz), esz, ta) != 0)
        return -1;
    }
    return 0;
  }

  /* Unsupported init — leave generic path. */
  return -2;
}

/* ============================================================
 * wave1141-1144 G.7: fixed TYPE_ARRAY local let helpers cluster
 * (migrated from pipeline_glue.c L2087-2135).
 *
 * Why here: glue_type_is_fixed_array / glue_emit_fixed_array_type_let_init_elf_c
 * / glue_block_let_is_fixed_array_type / glue_fixed_array_let_init_uses_direct_slot
 * form the fixed TYPE_ARRAY (kind==10) local let classification + emit sub-domain.
 * They are the fixed-array twin of the vector let-init domain above (parallel to
 * glue_vector_let_init_uses_direct_slot which is in vector_simd.c, since SIMD
 * lane binops are colocated there).
 *
 * glue_emit_fixed_array_type_let_init_elf_c is a thin wrapper over
 * glue_struct_lit_store_fixed_array_field_elf_c (defined at L347 above, same file)
 * with foff=0 / sret_direct=0 into the let slot — colocation keeps the
 * element-wise / bulk store authority in one file.
 *
 * Callers (all in glue.c, after #include at L2063):
 *   - pipeline_asm_let_init_stack_reserve_bytes (glue.c L2141) calls
 *     glue_fixed_array_let_init_uses_direct_slot
 *   - pipeline_asm_emit_block_stmt_order_let_const_elf (glue.c L5142 area)
 *     calls glue_block_let_is_fixed_array_type + glue_emit_fixed_array_type_let_init_elf_c
 *   - pipeline_asm_fill_block_locals_tree (glue.c L3175-3185) calls
 *     glue_type_is_fixed_array
 *
 * Dependencies (visible via earlier decls in the TU):
 *   - pipeline_type_kind_ord_at (extern fwd at glue.c L774, before #include L2063)
 *   - pipeline_block_let_type_ref (extern fwd at glue.c L776, before #include L2063)
 *   - pipeline_expr_kind_ord_at (extern fwd at glue.c L1618, before #include L2063)
 *   - glue_struct_lit_store_fixed_array_field_elf_c (defined at L347 above, same file)
 *
 * Note: GLUE_TYPE_KIND_ARRAY macro (defined in glue.c L2076, AFTER this file's
 * #include at L2063 — NOT visible here) replaced with literal 10 to match
 * vector_let.c style (file already uses literals 45/46 for EXPR kinds; see
 * L59/L64/L101/L113/L123/L205/L213/L245/L359). Macro stays in glue.c for
 * callers in struct_let/index_helpers/spill/modlet/assign/array_lit/index/
 * vector_simd/block_inits/field_access (all #included AFTER L2076).
 *
 * PLATFORM: SHARED — pure fixed-array classification + emit dispatch; no
 * platform ABI dependency (platform branches handled inside
 * glue_struct_lit_store_fixed_array_field_elf_c).
 * ============================================================ */

/**
 * TYPE_ARRAY (kind==10) fixed-length array type predicate.
 *
 * Contract: arena non-NULL; type_ref > 0.
 * @return 1 if type_ref is TYPE_ARRAY; 0 otherwise (incl. invalid input).
 *
 * PLATFORM: SHARED — pure type kind comparison; no platform ABI dependency.
 */
int32_t glue_type_is_fixed_array(struct ast_ASTArena *arena, int32_t type_ref) {
  if (!arena || type_ref <= 0)
    return 0;
  return pipeline_type_kind_ord_at(arena, type_ref) == 10 ? 1 : 0;
}

/**
 * wave354 Cap residual pure: fixed TYPE_ARRAY local let init (asm freestanding).
 *
 * Root: only ARRAY_LIT went through vector_let_init; VAR/FIELD/CALL fell through
 * to emit_expr + store 8B (pointer / first lane) into the array slot, causing
 * Ubuntu freestanding `let t: T[N] = b.a` wrong sum (host-C memcpy already
 * correct, wave353).
 *
 * G.7: thin wrapper over glue_struct_lit_store_fixed_array_field_elf_c (L347
 * above, same file) with foff=0 / sret_direct=0 into the let slot — same
 * element-wise authority as STRUCT_LIT fields.
 *
 * Contract: arena / elf_ctx / ctx non-NULL; init_ref > 0; type_ref > 0.
 * @return 0 handled; -1 error; -2 not a fixed array / unsupported init.
 *
 * PLATFORM: SHARED freestanding emit — platform branches live inside
 * glue_struct_lit_store_fixed_array_field_elf_c.
 */
int32_t glue_emit_fixed_array_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t init_ref, struct backend_AsmFuncCtx *ctx,
                                                         int32_t ta, int32_t type_ref,
                                                         int32_t stack_slot_off) {
  if (!arena || !elf_ctx || !ctx || init_ref <= 0 || type_ref <= 0)
    return -2;
  if (!glue_type_is_fixed_array(arena, type_ref))
    return -2;
  return glue_struct_lit_store_fixed_array_field_elf_c(arena, elf_ctx, init_ref, ctx, ta, 0,
                                                       stack_slot_off, 0, type_ref);
}

/**
 * Block-let fixed-array type predicate.
 *
 * Contract: arena non-NULL; block_ref > 0; let_idx >= 0.
 * @return 1 if the let at (block_ref, let_idx) is TYPE_ARRAY; 0 otherwise.
 *
 * PLATFORM: SHARED — pure type kind comparison; no platform ABI dependency.
 */
/* wave145 pure Cap residual: static→extern. */
int32_t glue_block_let_is_fixed_array_type(struct ast_ASTArena *arena, int32_t block_ref,
                                                  int32_t let_idx) {
  int32_t tr;
  if (!arena || block_ref <= 0 || let_idx < 0)
    return 0;
  tr = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  return glue_type_is_fixed_array(arena, tr);
}

/**
 * Fixed-array let + ARRAY_LIT direct-slot classifier.
 *
 * Returns 1 when the let init is an EXPR_ARRAY_LIT (kind==46) destined for a
 * fixed TYPE_ARRAY — the element-wise flat writer above can inline the store
 * directly into the stack slot (mirrors glue_vector_let_init_uses_direct_slot
 * in vector_simd.c for SIMD TYPE_VECTOR let).
 *
 * Contract: glue_type_is_fixed_array(arena, type_ref) gating; init_ref > 0.
 * @return 1 if direct-slot emit applies; 0 otherwise.
 *
 * PLATFORM: SHARED — pure kind comparison; no platform ABI dependency.
 */
/* wave145 pure Cap residual: static→extern. */
int32_t glue_fixed_array_let_init_uses_direct_slot(struct ast_ASTArena *arena, int32_t type_ref,
                                                          int32_t init_ref) {
  if (!glue_type_is_fixed_array(arena, type_ref) || init_ref <= 0)
    return 0;
  return pipeline_expr_kind_ord_at(arena, init_ref) == 46 ? 1 : 0;
}


/* ============================================================
 * wave147: pipeline_asm_emit_index_eff_addr pure-owned leave cold twins
 * (void* style). Product hybrid uses pure under FROM_X.
 * PLATFORM: SHARED freestanding cold twin.
 * ============================================================ */

extern int32_t backend_enc_rax_plus_rbx_scale1_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale4_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_rax_plus_rbx_scale8_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mul_imm_to_rbx_arch(void *elf_ctx, int32_t esz, int32_t ta);
extern int32_t backend_enc_add_rax_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t glue_try_index_var_or_field_base_to_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, void *ctx, int32_t ta);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t backend_enc_load_rbp_to_rbx_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *a, int32_t expr_ref, uint8_t *out);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_find_offset_scoped(void *ctx, void *arena, uint8_t *name, int32_t name_len);
extern int32_t glue_enc_local_slot_ptr_or_addr_elf_c(void *arena, void *elf_ctx, int32_t var_ref, int32_t off, void *ctx, int32_t ta);
extern int32_t glue_local_var_slot_needs_ptr_load_elf_c(void *arena, int32_t var_expr_ref, int32_t stack_off, void *ctx);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_add_imm_to_rax_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_load_64_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t pipeline_expr_resolved_type_ref(void *a, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *a, int32_t type_ref);
extern int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(void *arena, int32_t call_expr_ref);
extern int32_t backend_enc_mov_arg_reg_to_rax_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t pipeline_expr_index_proven_in_bounds_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_is_slice_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern int32_t pipeline_asm_emit_panic_int_div_zero_elf_c(void *elf_ctx, int32_t ta);
extern int32_t pipeline_type_array_size_at(void *a, int32_t type_ref);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_enc_mov_imm32_to_rbx_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_cmp_rax_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jge_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t backend_enc_add_imm_to_rbx_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern void glue_align_next_offset(void *ctx);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t glue_try_index_var_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_var_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_var_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_mul_var_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_add3_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c(void *arena, void *elf_ctx, int32_t base_ref, int32_t idx_ref, void *ctx, int32_t ta, int32_t esz);
extern int32_t asm_local_var_slot_holds_indirect_ptr(void *arena, int32_t var_expr_ref, void *mod, void *ctx);
extern int32_t backend_arch_emit_load_rbp_to_rax(void *out, int32_t stack_off, int32_t ta);
extern int32_t backend_arch_emit_lea_rbp_to_rax(void *out, int32_t stack_off, int32_t ta);
extern int32_t pipeline_expr_index_base_ref(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *a, int32_t expr_ref);
extern int32_t glue_field_access_effective_offset_c(void *arena, void *mod, int32_t fa_ref);
extern int32_t glue_index_deref_ptr_field_slot_rax_elf_c(void *arena, void *elf_ctx, int32_t fa_ref, int32_t ta);
extern int32_t glue_var_expr_type_ref_with_decl_fallback_c(void *arena, int32_t var_ref);
extern int32_t backend_arch_emit_add_imm_to_rax(void *out, int32_t imm, int32_t ta);
extern int32_t backend_arch_emit_load_64_from_rax(void *out, int32_t ta);
extern int32_t pipeline_asm_emit_expr_c(void *arena, void *out, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_arch_emit_push_rax(void *out, int32_t ta);
extern int32_t backend_arch_emit_pop_rax(void *out, int32_t ta);
extern int32_t backend_arch_emit_mov_rax_to_rbx(void *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale1(void *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale4(void *out, int32_t ta);
extern int32_t backend_arch_emit_rax_plus_rbx_scale8(void *out, int32_t ta);
extern void *pipeline_asm_emit_module_ref_c(void);

static int32_t wave147_expr_lit_i32_at(void *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  if (expr_ref == 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    if (out_imm)
      *out_imm = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

int32_t glue_emit_index_rax_plus_rbx_scaled_elf_c(void *elf_ctx, int32_t esz,
                                                          int32_t ta) {
  if (esz == 1)
    return backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
  if (esz == 4)
    return backend_enc_rax_plus_rbx_scale4_arch(elf_ctx, ta);
  if (esz == 8)
    return backend_enc_rax_plus_rbx_scale8_arch(elf_ctx, ta);
  if (backend_enc_mul_imm_to_rbx_arch(elf_ctx, esz, ta) != 0)
    return -1;
  /* PLATFORM: SHARED · MACOS|ARM64 pointer add after non-1/4/8 scale.
   * add_rax_rbx is 32-bit ADD W (u32 wrap). G.7: same scale1 as ptr+int. */
  return backend_enc_rax_plus_rbx_scale1_arch(elf_ctx, ta);
}

/** 局部 VAR / VAR-base FIELD 数组基底 → rax（lea 或 load ptr）。 */
int32_t glue_emit_index_var_base_to_rax_elf_c(void *arena,
                                                       void *elf_ctx,
                                                       int32_t base_ref, void *ctx,
                                                       int32_t ta) {
  return glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
}

/**
 * 7.3：INDEX — base 已在 rax，index 装入 rbx 并 scale 加；0=OK，-1=错。
 */
int32_t glue_emit_index_add_index_to_base_rax_elf_c(void *arena,
                                                            void *elf_ctx,
                                                            int32_t idx_ref, void *ctx,
                                                            int32_t ta, int32_t esz) {
  int32_t ioff;
  if (!arena || !elf_ctx || !ctx)
    return -1;
  ioff = glue_var_expr_stack_off_elf_c(arena, ctx, idx_ref);
  if (ioff >= 0) {
    if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, ioff, ta) != 0)
      return -1;
  } else {
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * 7.3：INDEX 有效地址 — base→rax、index→rbx 后 scale 加；0=OK，-1=错，-2=需 push slow。
 */
int32_t glue_try_index_base_rax_index_rbx_elf_c(void *arena,
                                                        void *elf_ctx,
                                                        int32_t base_ref, int32_t idx_ref,
                                                        void *ctx, int32_t ta) {
  int32_t ioff;
  int32_t br;
  if (!arena || !elf_ctx || !ctx)
    return -2;
  ioff = glue_var_expr_stack_off_elf_c(arena, ctx, idx_ref);
  if (ioff >= 0) {
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br == 0)
      return backend_enc_load_rbp_to_rbx_arch(elf_ctx, ioff, ta) != 0 ? -1 : 0;
    if (br == -1)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0)
      return -1;
    return backend_enc_load_rbp_to_rbx_arch(elf_ctx, ioff, ta) != 0 ? -1 : 0;
  }
  br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
  if (br == 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
    if (br != 0)
      return br;
    return 0;
  }
  if (br == -1)
    return -1;
  return -2;
}

/** slow：base/index 各 emit 后 push 保 base（历史栈序）。 */
int32_t glue_finish_index_base_rax_index_rbx_slow_elf_c(void *arena,
                                                                  void *elf_ctx,
                                                                  int32_t base_ref, int32_t idx_ref,
                                                                  void *ctx, int32_t ta) {
  int32_t base_ko;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 3) {
    int32_t off;
    uint8_t vname[256];
    int32_t vlen;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, off, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0) {
    return -1;
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * Slice base length → rbx ({data,length} home, *slice param, or dual-GP call rvalue).
 *
 * PLATFORM: SHARED fat layout; LINUX/MACOS SysV / AAPCS64:
 * - Local dual-GP home: data @ off, length @ glue_slice_dual_gp_length_off_c(off,ta)
 *   (wave394: arm64 +8 / x86 -8; C fat memory order)
 * - slice* param: load fat*, then length at +8
 * - CALL/METHOD_CALL returning TYPE_SLICE: freestanding dual-GP data@rax length@rdx
 *   (wave333/335 return emit). Do NOT treat rax as fat* (+8 deref) — that was wave336
 *   soft residual take()[1] panic (bounds length garbage).
 *
 * Bounds guard holds index in rax; any emit of base that clobbers rax must push/pop.
 * G.7: single authority for slice length for INDEX bounds (no parallel path).
 */
int32_t glue_emit_slice_length_to_rbx_elf_c(void *arena,
                                                    void *elf_ctx,
                                                    void *ctx, int32_t ta, int32_t base_ref) {
  int32_t base_ko;
  uint8_t vname[256];
  int32_t vlen;
  int32_t off;
  int32_t bty;

  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 3) {
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_local_var_slot_needs_ptr_load_elf_c(arena, base_ref, off, ctx) != 0) {
      /*
       * wave332d: preserve rax (INDEX has index in rax when loading length to rbx).
       * Prior path load_rbp→rax clobbered the index → upper-bound cmp used length vs
       * length-1 → always panic (Ubuntu freestanding a[0] after slice* param fix).
       * G.7: push/pop around the pointer chase; dual-GP path already loads straight to rbx.
       * PLATFORM: SHARED freestanding · LINUX gold.
       */
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
      if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
        return -1;
      if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      return 0;
    }
    /* wave394: arch-aware dual-GP length half (matches slice_from_array_let_init). */
    return backend_enc_load_rbp_to_rbx_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta);
  }

  /*
   * wave336 Cap residual pure: non-VAR slice base (esp. CALL take()[1]).
   * Index is live in rax (bounds guard). Emit base may clobber rax/rdx.
   * TYPE_SLICE CALL/METHOD_CALL return is dual-GP (needs_rax_deref=0): length@rdx.
   * Else historical fat* in rax: length at [rax+8].
   * PLATFORM: SHARED freestanding · LINUX gold (host-C uses C codegen INDEX).
   */
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0)
    return -1;
  bty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (bty > 0 && pipeline_type_kind_ord_at(arena, bty) == 11 &&
      (base_ko == 48 || base_ko == 49) &&
      (base_ko != 48 || pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, base_ref) == 0)) {
    /* SysV arg_reg 2 = rdx — length half after dual-GP return. */
    if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    return 0;
  }
  if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
    return -1;
  if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 0;
}

/**
 * UB narrowing for INDEX (seed cold twin of runtime_pipeline_abi.x).
 * Stage 12.0.5: fixed-array non-lit index skips runtime xlang_panic_ to match
 * host -E codegen (hybrid pure-asm freestanding bag has no T xlang_panic_).
 * Slice lo/hi guards and fixed-array lit OOB still call panic.
 * ix_ref: INDEX expr (proven_in_bounds / base_is_slice); <=0 still type-checks base.
 * PLATFORM: SHARED freestanding · cold twin must stay same-commit with .x.
 */
int32_t glue_emit_index_bounds_guard_elf_c(void *arena,
                                                   void *elf_ctx,
                                                   void *ctx, int32_t ta, int32_t ix_ref,
                                                   int32_t base_ref, int32_t idx_ref) {
  int32_t base_ty;
  int32_t bt_kind;
  int32_t is_slice;
  int32_t lit_idx;
  int32_t array_sz;
  uint8_t ok_lo[128];
  uint8_t ok_hi[128];
  int32_t ok_lo_len;
  int32_t ok_hi_len;

  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return 0;

  if (ix_ref > 0) {
    if (pipeline_expr_index_proven_in_bounds_at(arena, ix_ref) != 0)
      return 0;
    is_slice = (pipeline_expr_index_base_is_slice_at(arena, ix_ref) != 0) ? 1 : 0;
  } else {
    is_slice = 0;
  }

  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (base_ty <= 0)
    return 0;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (is_slice == 0 && bt_kind == 11)
    is_slice = 1;
  if (is_slice == 0 && bt_kind != 10)
    return 0;

  if (wave147_expr_lit_i32_at(arena, idx_ref, &lit_idx)) {
    if (lit_idx < 0)
      return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    if (is_slice == 0) {
      array_sz = pipeline_type_array_size_at(arena, base_ty);
      if (array_sz > 0 && lit_idx >= array_sz)
        return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
      return 0;
    }
  }

  /* Stage 12.0.5: fixed-array non-lit — C parity, no U xlang_panic_. */
  if (is_slice == 0)
    return 0;

  ok_lo_len = pipeline_asm_emit_next_label_c(ctx, ok_lo, 64);
  ok_hi_len = pipeline_asm_emit_next_label_c(ctx, ok_hi, 64);
  if (ok_lo_len <= 0 || ok_hi_len <= 0)
    return -1;

  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, ok_lo, ok_lo_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_lo, ok_lo_len, 0, ta) != 0)
    return -1;

  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
    return -1;
  if (is_slice != 0) {
    if (glue_emit_slice_length_to_rbx_elf_c(arena, elf_ctx, ctx, ta, base_ref) != 0)
      return -1;
    if (backend_enc_add_imm_to_rbx_arch(elf_ctx, -1, ta) != 0)
      return -1;
  } else {
    array_sz = pipeline_type_array_size_at(arena, base_ty);
    if (array_sz <= 0)
      return 0;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, array_sz - 1, ta) != 0)
      return -1;
  }
  if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jge_arch(elf_ctx, ok_hi, ok_hi_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_hi, ok_hi_len, 0, ta) != 0)
    return -1;
  return 0;
}

/**
 * wave337 Cap residual pure: call-as-INDEX base evaluated once.
 *
 * Root: glue_emit_index_bounds_guard → glue_emit_slice_length_to_rbx emits CALL base
 * for length@rdx, then lit/scaled path emits base again for data@rax → take()[1]
 * double-eval (side effects / cost). Local VAR slice homes already single-eval.
 *
 * G.7 authority: materialize TYPE_SLICE CALL/METHOD_CALL dual-GP (data@rax length@rdx)
 * or fat* return into one dual-GP temp {data@home, length@home-8}, then bounds+addr
 * only load the temp — no second emit of base. Complements wave336 length@rdx.
 *
 * @return 0 handled (eff addr in rax), -2 not applicable, -1 error
 * PLATFORM: SHARED freestanding · LINUX gold (host-C uses C codegen INDEX).
 */
int32_t glue_try_index_rvalue_slice_once_elf_c(void *arena,
                                                       void *elf_ctx, int32_t ix_ref,
                                                       int32_t base_ref, int32_t idx_ref,
                                                       void *ctx, int32_t ta, int32_t esz) {
  int32_t base_ko;
  int32_t bty;
  int32_t dual_gp;
  int32_t home;
  int32_t base_off;
  void *ly;
  int32_t proven;
  int32_t lit_idx;
  int32_t ok_lo_len;
  int32_t ok_hi_len;
  uint8_t ok_lo[128];
  uint8_t ok_hi[128];

  if (!arena || !elf_ctx || !ctx || base_ref <= 0 || idx_ref <= 0)
    return -2;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  /*
   * CALL=48 METHOD_CALL=49 — rvalues that re-emit full base for length+data.
   * wave692: INDEX=47 base with TYPE_SLICE result (nested `rows[i][j]`) also
   * materializes dual-GP once — outer INDEX loads fat->data@rax length@rdx
   * (emit_index TYPE_SLICE arm); re-emitting for length path would double-eval
   * and the non-CALL length path assumes fat* not dual-GP.
   * wave773: DEREF=52 of *[]T yields TYPE_SLICE 16B dual-GP (rax=data,
   * rdx=length). Without this, base falls through to
   * glue_emit_slice_length_to_rbx_elf_c non-VAR path which does add 8;
   * load 64 on slice.ptr (data pointer), reading *(data+8) = OOB -> panic
   * 134 on x86. macOS ARM64 hides it (OOB read happens to not panic).
   */
  if (base_ko != 48 && base_ko != 49 && base_ko != 47 && base_ko != 52)
    return -2;
  bty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (bty <= 0 || pipeline_type_kind_ord_at(arena, bty) != 11)
    return -2;
  /*
   * dual-GP: freestanding TYPE_SLICE return (wave333/335); CALL only when
   * needs_rax_deref==0. METHOD_CALL TYPE_SLICE treated as dual-GP (wave336).
   * wave692: INDEX of nested outer yields dual-GP (emit_index TYPE_SLICE load).
   * wave773: DEREF of *[]T yields dual-GP (DEREF loads fat 16B rax:rdx).
   * Else fat* in rax (length at [rax+8], data at [rax]).
   */
  dual_gp = 0;
  if (base_ko == 49 || base_ko == 47 || base_ko == 52)
    dual_gp = 1;
  else if (base_ko == 48 && pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, base_ref) == 0)
    dual_gp = 1;

  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  {
    int32_t *nextp = (int32_t *)((uint8_t *)ly + 4);
    base_off = *nextp;
    if ((base_off % 8) != 0)
      base_off = (base_off + 7) / 8 * 8;
    home = base_off + 16;
    *nextp = (ta == 1) ? (home + 16) : (home + 8);
  }
  glue_align_next_offset(ctx);

  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0)
    return -1;
  if (dual_gp != 0) {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
      return -1;
  } else {
    /* fat*: rax → struct { data, length }; spill both halves into dual-GP home. */
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_add_imm_to_rax_arch(elf_ctx, 8, ta) != 0)
      return -1;
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
      return -1;
  }

  /* Bounds from materialized length only (no second base emit). */
  proven = 0;
  if (ix_ref > 0) {
    if (pipeline_expr_index_proven_in_bounds_at(arena, ix_ref) != 0)
      proven = 1;
  }
  if (proven == 0) {
    if (wave147_expr_lit_i32_at(arena, idx_ref, &lit_idx)) {
      if (lit_idx < 0)
        return pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta);
    }
    ok_lo_len = pipeline_asm_emit_next_label_c(ctx, ok_lo, 64);
    ok_hi_len = pipeline_asm_emit_next_label_c(ctx, ok_hi, 64);
    if (ok_lo_len <= 0 || ok_hi_len <= 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm32_to_rbx_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_cmp_rax_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, ok_lo, ok_lo_len, ta) != 0)
      return -1;
    if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, ok_lo, ok_lo_len, 0, ta) != 0)
      return -1;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, glue_slice_dual_gp_length_off_c(home, ta), ta) != 0)
      return -1;
    if (backend_enc_add_imm_to_rbx_arch(elf_ctx, -1, ta) != 0)
      return -1;
    if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jge_arch(elf_ctx, ok_hi, ok_hi_len, ta) != 0)
      return -1;
    if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_label_arch(elf_ctx, ok_hi, ok_hi_len, 0, ta) != 0)
      return -1;
  }

  /* Effective address: data@home + index * esz → rax. */
  if (wave147_expr_lit_i32_at(arena, idx_ref, &lit_idx)) {
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
      return -1;
    if (lit_idx != 0 && esz != 0) {
      int32_t off = lit_idx * esz;
      if (off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
    }
    return 0;
  }
  /* Non-lit: after bounds, index is in rax; move to rbx then load data. */
  if (proven != 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, idx_ref, ctx, ta) != 0)
      return -1;
  }
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
    return -1;
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * INDEX 有效地址完整发射：try 7.3 快速路径，否则 slow push。
 */
/* wave147 cold twin. PLATFORM: SHARED. */
int32_t glue_emit_index_eff_addr_scaled_elf_c(void *arena,
                                              void *elf_ctx, int32_t ix_ref,
                                              int32_t base_ref, int32_t idx_ref, void *ctx,
                                              int32_t ta, int32_t esz) {
  int32_t vr;
  int32_t lit_imm;
  int32_t once_rc;

  /* wave337: CALL/METHOD TYPE_SLICE base — materialize once before bounds+load. */
  once_rc = glue_try_index_rvalue_slice_once_elf_c(arena, elf_ctx, ix_ref, base_ref, idx_ref, ctx, ta, esz);
  if (once_rc == 0)
    return 0;
  if (once_rc == -1)
    return -1;

  if (glue_emit_index_bounds_guard_elf_c(arena, elf_ctx, ctx, ta, ix_ref, base_ref, idx_ref) != 0)
    return -1;
  /** 字面量下标：base→rax 后 add imm*esz，免 rbx 缩放（7.3 活跃性）。 */
  if (wave147_expr_lit_i32_at(arena, idx_ref, &lit_imm)) {
    {
      int32_t br;
      br = glue_try_index_var_or_field_base_to_rax_elf_c(arena, elf_ctx, base_ref, ctx, ta);
      if (br == -2) {
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0)
          return -1;
      } else if (br != 0) {
        return -1;
      }
    }
    if (lit_imm != 0 || esz != 0) {
      int32_t off;
      off = lit_imm * esz;
      if (off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta) != 0)
        return -1;
    }
    return 0;
  }
  {
    int32_t mr;
    mr = glue_try_index_var_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mr == 0)
      return 0;
    if (mr == -1)
      return -1;
  }
  {
    int32_t pr;
    pr = glue_try_index_var_plus_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pr == 0)
      return 0;
    if (pr == -1)
      return -1;
  }
  {
    int32_t mr2;
    mr2 = glue_try_index_var_minus_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mr2 == 0)
      return 0;
    if (mr2 == -1)
      return -1;
  }
  {
    int32_t pvr;
    pvr = glue_try_index_var_plus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pvr == 0)
      return 0;
    if (pvr == -1)
      return -1;
  }
  {
    int32_t mvr;
    mvr = glue_try_index_var_minus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvr == 0)
      return 0;
    if (mvr == -1)
      return -1;
  }
  {
    int32_t mvr2;
    mvr2 = glue_try_index_var_mul_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvr2 == 0)
      return 0;
    if (mvr2 == -1)
      return -1;
  }
  {
    int32_t pvv;
    pvv = glue_try_index_var_plus_var_plus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pvv == 0)
      return 0;
    if (pvv == -1)
      return -1;
  }
  {
    int32_t mvp;
    mvp = glue_try_index_var_minus_var_plus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvp == 0)
      return 0;
    if (mvp == -1)
      return -1;
  }
  {
    int32_t mvm;
    mvm = glue_try_index_var_minus_var_minus_var_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvm == 0)
      return 0;
    if (mvm == -1)
      return -1;
  }
  {
    int32_t ma3;
    ma3 = glue_try_index_var_minus_add3_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (ma3 == 0)
      return 0;
    if (ma3 == -1)
      return -1;
  }
  {
    int32_t pvm;
    pvm = glue_try_index_var_plus_var_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (pvm == 0)
      return 0;
    if (pvm == -1)
      return -1;
  }
  {
    int32_t mvl;
    mvl = glue_try_index_var_minus_var_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (mvl == 0)
      return 0;
    if (mvl == -1)
      return -1;
  }
  {
    int32_t a3m;
    a3m = glue_try_index_var_add3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (a3m == 0)
      return 0;
    if (a3m == -1)
      return -1;
  }
  {
    int32_t sa3m;
    sa3m = glue_try_index_var_subadd3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (sa3m == 0)
      return 0;
    if (sa3m == -1)
      return -1;
  }
  {
    int32_t ss3m;
    ss3m = glue_try_index_var_subsub3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (ss3m == 0)
      return 0;
    if (ss3m == -1)
      return -1;
  }
  {
    int32_t ma3m;
    ma3m = glue_try_index_var_minus_add3_mul_lit_eff_addr_rax_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta, esz);
    if (ma3m == 0)
      return 0;
    if (ma3m == -1)
      return -1;
  }
  vr = glue_try_index_base_rax_index_rbx_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta);
  if (vr == -1)
    return -1;
  if (vr == -2) {
    if (glue_finish_index_base_rax_index_rbx_slow_elf_c(arena, elf_ctx, base_ref, idx_ref, ctx, ta) != 0)
      return -1;
  }
  return glue_emit_index_rax_plus_rbx_scaled_elf_c(elf_ctx, esz, ta);
}

/**
 * text 路径：局部 VAR 槽地址（*T/T[N] load 指针，其余 lea 栈槽）。
 */
int32_t glue_arch_emit_local_slot_ptr_or_addr_text_c(void *arena,
                                                            void *out, int32_t var_expr_ref,
                                                            int32_t stack_off, void *ctx,
                                                            int32_t ta) {
  if (asm_local_var_slot_holds_indirect_ptr(arena, var_expr_ref, pipeline_asm_emit_module_ref_c(), (uint8_t *)ctx) != 0)
    return backend_arch_emit_load_rbp_to_rax(out, stack_off, ta);
  return backend_arch_emit_lea_rbp_to_rax(out, stack_off, ta);
}

/**
 * INDEX 左值 base 有效地址入 rax/x0（ELF）；与 backend.x 原 emit_index_eff_addr_elf 语义一致。
 */
int32_t glue_emit_index_eff_addr_base_elf_c(void *arena,
                                                   void *elf_ctx, int32_t ix_ref,
                                                   void *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t base_ko;
  int32_t tr;
  base_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  if (base_ref <= 0)
    return -1;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 44 && pipeline_expr_field_access_is_enum_variant(arena, base_ref) == 0) {
    int32_t fb_ref;
    int32_t field_off;
    fb_ref = pipeline_expr_field_access_base_ref(arena, base_ref);
    field_off = glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), base_ref);
    if (fb_ref > 0 && pipeline_expr_kind_ord_at(arena, fb_ref) == 3) {
      uint8_t vname[256];
      int32_t vlen;
      int32_t off;
      vlen = pipeline_expr_var_name_len(arena, fb_ref);
      if (vlen <= 0 || vlen > 255)
        return -1;
      pipeline_expr_var_name_into(arena, fb_ref, vname);
      off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (off < 0)
        return -1;
      if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, fb_ref, off, ctx, ta) != 0)
        return -1;
    } else {
      if (fb_ref <= 0)
        return -1;
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, fb_ref, ctx, ta) != 0)
        return -1;
    }
    if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0)
      return -1;
    if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta) != 0)
      return -1;
  } else if (base_ko == 3) {
    uint8_t vname[256];
    int32_t vlen;
    int32_t off;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, off, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, base_ref, ctx, ta) != 0) {
    return -1;
  }
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 11) {
    if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
      return -1;
  } else if (base_ko == 44) {
    if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, base_ref, ta) != 0)
      return -1;
  }
  return 0;
}

/**
 * INDEX 左值 base 有效地址入 rax/x0（text）；与 ELF 路径对称。
 */
int32_t glue_emit_index_eff_addr_base_text_c(void *arena, void *out,
                                                    int32_t ix_ref, void *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t base_ko;
  int32_t tr;
  base_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  if (base_ref <= 0)
    return -1;
  base_ko = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_ko == 44 && pipeline_expr_field_access_is_enum_variant(arena, base_ref) == 0) {
    int32_t fb_ref;
    int32_t field_off;
    fb_ref = pipeline_expr_field_access_base_ref(arena, base_ref);
    field_off = glue_field_access_effective_offset_c(arena, pipeline_asm_emit_module_ref_c(), base_ref);
    if (fb_ref > 0 && pipeline_expr_kind_ord_at(arena, fb_ref) == 3) {
      uint8_t vname[256];
      int32_t vlen;
      int32_t off;
      vlen = pipeline_expr_var_name_len(arena, fb_ref);
      if (vlen <= 0 || vlen > 255)
        return -1;
      pipeline_expr_var_name_into(arena, fb_ref, vname);
      off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
      if (off < 0)
        return -1;
      if (glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, out, fb_ref, off, ctx, ta) != 0)
        return -1;
    } else {
      if (fb_ref <= 0)
        return -1;
      if (pipeline_asm_emit_expr_c(arena, out, fb_ref, ctx, ta) != 0)
        return -1;
    }
    if (field_off != 0 && backend_arch_emit_add_imm_to_rax(out, field_off, ta) != 0)
      return -1;
  } else if (base_ko == 3) {
    uint8_t vname[256];
    int32_t vlen;
    int32_t off;
    vlen = pipeline_expr_var_name_len(arena, base_ref);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, base_ref, vname);
    off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
    if (off < 0)
      return -1;
    if (glue_arch_emit_local_slot_ptr_or_addr_text_c(arena, out, base_ref, off, ctx, ta) != 0)
      return -1;
  } else if (pipeline_asm_emit_expr_c(arena, out, base_ref, ctx, ta) != 0) {
    return -1;
  }
  tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (tr > 0 && pipeline_type_kind_ord_at(arena, tr) == 11) {
    if (backend_arch_emit_load_64_from_rax(out, ta) != 0)
      return -1;
  }
  return 0;
}

/**
 * INDEX 左值有效地址 ELF（ix_ref 替代 Expr 按值；M8-tail 薄包装 bl 目标）。
 */
int32_t pipeline_asm_emit_index_eff_addr_elf_c(void *arena, void *elf_ctx,
                                               int32_t ix_ref, void *ctx, int32_t ta,
                                               int32_t elem_sz) {
  int32_t idx_ref;
  if (!arena || !elf_ctx || !ctx || ix_ref <= 0)
    return -1;
  idx_ref = pipeline_expr_index_index_ref(arena, ix_ref);
  if (pipeline_expr_index_base_ref(arena, ix_ref) <= 0 || idx_ref <= 0)
    return -1;
  if (glue_emit_index_eff_addr_base_elf_c(arena, elf_ctx, ix_ref, ctx, ta) != 0)
    return -1;
  return glue_emit_index_add_index_to_base_rax_elf_c(arena, elf_ctx, idx_ref, ctx, ta, elem_sz);
}

/**
 * INDEX 左值有效地址 text（ix_ref 替代 Expr 按值；M8-tail 薄包装 bl 目标）。
 */
int32_t pipeline_asm_emit_index_eff_addr_text_c(void *arena, void *out,
                                                int32_t ix_ref, void *ctx, int32_t ta,
                                                int32_t elem_sz) {
  int32_t idx_ref;
  if (!arena || !out || !ctx || ix_ref <= 0)
    return -1;
  idx_ref = pipeline_expr_index_index_ref(arena, ix_ref);
  if (pipeline_expr_index_base_ref(arena, ix_ref) <= 0 || idx_ref <= 0)
    return -1;
  if (glue_emit_index_eff_addr_base_text_c(arena, out, ix_ref, ctx, ta) != 0)
    return -1;
  if (backend_arch_emit_push_rax(out, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_c(arena, out, idx_ref, ctx, ta) != 0)
    return -1;
  if (backend_arch_emit_mov_rax_to_rbx(out, ta) != 0)
    return -1;
  if (backend_arch_emit_pop_rax(out, ta) != 0)
    return -1;
  if (elem_sz == 1)
    return backend_arch_emit_rax_plus_rbx_scale1(out, ta);
  if (elem_sz == 8)
    return backend_arch_emit_rax_plus_rbx_scale8(out, ta);
  return backend_arch_emit_rax_plus_rbx_scale4(out, ta);
}




/* ============================================================
 * wave148: pipeline_asm_emit_vector_simd pure-owned leave cold twins
 * (void* style). Product hybrid uses pure under FROM_X.
 * PLATFORM: SHARED freestanding cold twin.
 * ============================================================ */
extern int32_t glue_is_vector_lane_scalar_binop_ko(int32_t ko);
extern int32_t asm_type_is_simd_vector_spelling(void *arena, int32_t type_ref);
extern int32_t asm_type_is_simd_vector(void *arena, int32_t type_ref);
extern int32_t asm_local_slot_bytes(void *arena, int32_t type_ref);
extern int32_t pipeline_block_let_type_ref(void *a, int32_t br, int32_t li);
extern int32_t pipeline_block_let_init_ref(void *a, int32_t br, int32_t li);
extern int32_t pipeline_type_kind_ord_at(void *a, int32_t tr);
extern int32_t pipeline_type_elem_ref_at(void *a, int32_t tr);
extern int32_t pipeline_type_array_size_at(void *a, int32_t tr);
extern int32_t pipeline_type_named_name_into(void *a, int32_t tr, uint8_t *out);
extern int32_t pipeline_arena_num_types(void *a);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t er);
extern int32_t pipeline_expr_var_name_len(void *a, int32_t er);
extern void pipeline_expr_var_name_into(void *a, int32_t er, uint8_t *out);
extern int32_t asm_ctx_local_find_offset_scoped(void *ctx, void *arena, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern int32_t pipeline_expr_array_lit_elem_ref(void *a, int32_t er, int32_t i);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *a, int32_t er);
extern int32_t pipeline_expr_binop_left_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(void *a, int32_t er);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_lane_to_rax_arch(void *elf, int32_t off, int32_t esz, int32_t ta);
extern int32_t backend_enc_load_rbp_lane_to_rbx_arch(void *elf, int32_t off, int32_t esz, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_pop_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_add_rax_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_sub_rbx_rax_then_mov_arch(void *elf, int32_t ta);
extern int32_t backend_enc_imul_rbx_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_idiv_rbx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_rem_mod_arch(void *elf, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_ecx_arch(void *elf, int32_t ta);
extern int32_t backend_enc_shr_cl_eax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_shl_cl_eax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_and_rbx_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_or_rbx_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_xor_rbx_rax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf, int32_t imm, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rbx_arch(void *elf, int32_t off, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbx_offset_arch(void *elf, int32_t off, int32_t esz, int32_t ta);
extern int32_t backend_enc_test_eax_eax_arch(void *elf, int32_t ta);
extern int32_t backend_enc_jz_arch(void *elf, uint8_t *lbl, int32_t len, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf, uint8_t *lbl, int32_t len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf, uint8_t *name, int32_t len, int32_t is_global, int32_t ta);
extern int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(void *elf, void *ctx, int32_t ta);
extern void *pipeline_asm_emit_dep_pipe_c(void);
extern void *pipeline_asm_emit_module_ref_c(void);
extern uint32_t driver_get_pending_target_cpu_features(void);
extern uint32_t xlang_target_cpu_detect_host(void);
extern int32_t xlang_simd_vector_lanes_esz_from_spelling(const char *name, size_t name_len, int32_t *out_lanes, int32_t *out_esz);
extern int32_t simd_enc_try_hw_vector_iadd_rbp(void *elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_isub_rbp(void *elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_imul_rbp(void *elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_fadd_rbp(void *elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_fmul_rbp(void *elf, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_fma_rbp(void *elf, int32_t a, int32_t b, int32_t c, int32_t d, int32_t lanes, int32_t esz, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_pshufd_rbp(void *elf, int32_t src, int32_t dst, int32_t imm8, int32_t lanes, int32_t ta, uint32_t feats);
extern int32_t simd_enc_try_hw_vector_select_rbp(void *elf, int32_t m, int32_t a, int32_t b, int32_t d, int32_t lanes, int32_t is_f32, int32_t ta, uint32_t feats);
extern int32_t pipeline_asm_emit_vector_let_init_elf_c(void *arena, void *elf, int32_t init, void *ctx, int32_t ta, int32_t off);
extern int32_t pipeline_expr_call_num_args_at(void *a, int32_t er);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_call_arg_ref(void *a, int32_t er, int32_t i);
/* METHOD_CALL=49 accessors — Stage12 s4 HW: simd.shuffle/select import METHOD. */
extern int32_t pipeline_expr_method_call_num_args_at(void *a, int32_t er);
extern int32_t pipeline_expr_method_call_arg_ref(void *a, int32_t er, int32_t i);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t er);
extern void pipeline_expr_method_call_name_into(void *a, int32_t er, uint8_t *out);
extern int32_t pipeline_expr_method_call_base_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_field_access_name_len(void *a, int32_t er);
extern void pipeline_expr_field_access_name_into(void *a, int32_t er, uint8_t *out);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t er);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t sz);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_return_type_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_num_params_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_param_name_len_at(void *m, int32_t fi, int32_t pi);
extern void pipeline_module_func_param_name_copy32(void *m, int32_t fi, int32_t pi, uint8_t *dst);
extern int32_t pipeline_asm_block_final_expr_ref_at(void *a, int32_t br);
extern int32_t ast_ast_block_num_expr_stmts(void *a, int32_t br);
extern int32_t ast_ast_block_expr_stmt_ref(void *a, int32_t br, int32_t ei);
extern int32_t pipeline_expr_unary_operand_ref_at(void *a, int32_t er);
extern int32_t pipeline_expr_const_folded_valid_at(void *a, int32_t er);
extern int32_t pipeline_expr_const_folded_val_at(void *a, int32_t er);
extern int32_t pipeline_expr_index_base_ref(void *a, int32_t er);
extern int32_t pipeline_expr_index_index_ref(void *a, int32_t er);
extern int32_t backend_fold_func_return_operand_ref(void *a, void *m, int32_t fi);
extern char *link_abi_getenv(const char *name);
/* Cap residual 9.7.1: raw libc fprintf/stderr externs removed — trace prints
 * route through pabi_trace (Cap snprintf + raw fd-2 write). */

int32_t glue_block_let_is_simd_vector_type(void *arena, int32_t block_ref, int32_t let_idx) {
  int32_t tr;
  int32_t init_ref;
  int32_t ko;
  int32_t tk;
  if (!arena || block_ref <= 0 || let_idx < 0)
    return 0;
  tr = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  if (tr > 0 && asm_type_is_simd_vector_spelling(arena, tr))
    return 1;
  if (tr > 0) {
    tk = pipeline_type_kind_ord_at(arena, tr);
    /** Fat slice / fixed array are never SIMD lanes — do not use 16B+ VAR heuristic. */
    if (tk == GLUE_TYPE_KIND_SLICE || tk == GLUE_TYPE_KIND_ARRAY)
      return 0;
  }
  init_ref = pipeline_block_let_init_ref(arena, block_ref, let_idx);
  if (tr > 0 && init_ref > 0 && pipeline_type_kind_ord_at(arena, tr) != 8 &&
      asm_local_slot_bytes(arena, tr) >= 16) {
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
    /** 勿把 Vec_i32/Vec3f_soa 等 struct let + *_new() CALL 当成 SIMD（会跳过 struct 内联）。 */
    if (ko == 46 || ko == 3 || glue_is_vector_lane_scalar_binop_ko(ko))
      return 1;
  }
  /* Class AY: Cap XLANG_ASM_EMIT_TRACE note retired. */
  return 0;
}

