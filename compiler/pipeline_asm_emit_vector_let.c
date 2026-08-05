/**
 * pipeline_asm_emit_vector_let.c — asm ELF vector/fixed-array let-init domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding fixed TYPE_ARRAY /
 * multi-dim ARRAY_LIT materialization into stack slots and STRUCT_LIT fixed
 * array fields:
 * - pipeline_asm_array_lit_leaf_elem_byte_sz_c (peel nested ARRAY_LIT to leaf esz)
 * - pipeline_asm_emit_array_lit_flat_elf_c (row-major flat scalar/struct stores)
 * - pipeline_asm_emit_vector_let_init_elf_c (1D / nested ARRAY_LIT into slot)
 * - glue_struct_field_frame_mag_c (arch-aware field frame magnitude)
 * - glue_struct_lit_store_fixed_array_field_elf_c (STRUCT_LIT TYPE_ARRAY field
 *   + fixed-array let/assign element-wise / bulk paths)
 *
 * G.7: single product-mega vector_let / fixed-array field face — do not open a
 * second flat writer or second element-wise fixed-array copy path.
 * Fixed-array let helpers (glue_type_is_fixed_array +
 * glue_emit_fixed_array_type_let_init_elf_c + glue_block_let_is_fixed_array_type
 * + glue_fixed_array_let_init_uses_direct_slot) migrated to EOF at wave1141-1144.
 * SIMD vector lane binops / shuffle / fma: pipeline_asm_emit_vector_simd.c.
 *
 * Callers: STRUCT_LIT fields (via store_fixed_array); block let/assign fixed
 * arrays (via glue_emit_fixed_array_type_let_init); vector/array let-init;
 * rvalue array_lit force_esz nested flat (array_lit slice).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_struct_lit.c (before vector_simd lane domain).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX|x86 high-end frame mag base-foff; bulk spill copy
 *   · MACOS|ARM64 low-end frame mag base+foff
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_array_lit_elem_byte_sz_c / pipeline_asm_array_lit_elem_type_ref
 * - glue_emit_struct_type_let_init_elf_c / glue_expr_emit_may_clobber_rbx_elf_c
 * - glue_var_expr_stack_off_elf_c / glue_field_access_effective_offset_c
 * - glue_index_elem_byte_sz_from_type_ref_c / glue_emit_bulk_mem_copy_spills_elf_c
 * - pipeline_asm_emit_expr_elf_rec / backend_enc_* / g_pipeline_asm_*
 * - pipeline_type_array_size_at / pipeline_type_elem_ref_at
 */

/**
 * wave613: peel nested ARRAY_LIT to the scalar/leaf element byte width for flat stores.
 * `pipeline_asm_array_lit_elem_byte_sz_c` on a mid-level row returns full row width
 * (e.g. `[[10,32]]` → 8), which is correct as outer stride but wrong as leaf_esz —
 * flat writer would `str x0` at +0/+8 while INDEX uses i32 stride 4 →
 * `[[[10,32]]][0][0][1]` freestanding=0 (host-C green; 2-level already green).
 * G.7: single peel helper for vector_let_init + rvalue emit_array_lit flat paths.
 * PLATFORM: SHARED freestanding multi-dim.
 */
/* wave143 pure Cap residual: static→extern for pure array_lit force_esz nested path. */
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
  if (!arena || !elf_ctx || !ctx || !flat_i || init_ref <= 0 || leaf_esz <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
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
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, elem_ref, ctx, ta) != 0)
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
static int32_t pipeline_asm_emit_vector_let_init_elf_c(struct ast_ASTArena *arena,
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
    if (esz > 8 || pipeline_expr_kind_ord_at(arena, elem_ref) == 45) {
      int32_t elem_home;
      int32_t st;
      elem_home = (ta == 1) ? (stack_slot_off + ai * esz) : (stack_slot_off - ai * esz);
      if (elem_home < 0)
        return -1;
      st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                 elem_ty > 0 ? elem_ty : 0, elem_home);
      if (st == 0)
        continue;
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
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, elem_ref, ctx, ta) != 0)
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
static int32_t glue_struct_field_frame_mag_c(int32_t base_off, int32_t foff, int32_t ta) {
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
static int32_t glue_struct_lit_store_fixed_array_field_elf_c(
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
  if (n_arr <= 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
  elem_tr = pipeline_type_elem_ref_at(arena, fty);
  esz = glue_index_elem_byte_sz_from_type_ref_c(arena, elem_tr);
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

  if (iko == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT) {
    if (sret_direct == 0) {
      /* rbp-relative: write elems at arch-aware field mag (wave652 ≡ nest_slot). */
      return pipeline_asm_emit_vector_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, field_mag);
    }
    /* SysV sret: dest base in [sret_home]; store each elem at foff + i*esz. */
    for (ai = 0; ai < n_arr; ai++) {
      int32_t elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
      if (elem_ref == 0)
        continue;
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, elem_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta) != 0)
        return -1;
    }
    return 0;
  }

  /*
   * wave363 Cap residual / tip L4: `let a: T[N] = 0` (and STRUCT_LIT field = 0).
   * typeck coerces EXPR_LIT 0 onto TYPE_ARRAY (pipeline_typeck_coerce_init_lit_to_decl_c);
   * host-C emits `= {0}`; freestanding previously returned -2 → CG002 num_funcs=0
   * on Ubuntu gold (tests/array/main.x). Zero-fill each element into the inline slot.
   * PLATFORM: SHARED freestanding · LINUX gold · only int_val==0 (product zero-init).
   */
  if (iko == (int32_t)ast_ExprKind_EXPR_LIT) {
    int64_t lit_v = pipeline_expr_int64_val_at(arena, init_ref);
    if (lit_v != 0)
      return -2;
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
      if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
        return -1;
      if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, foff + ai * esz, esz, ta) != 0)
        return -1;
    }
    return 0;
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
    field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, init_ref);
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
             iko == (int32_t)ast_ExprKind_EXPR_INDEX) {
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
    emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta);
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
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
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
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
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
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
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
        if (backend_enc_load_rbp_to_rbx_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
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
static int32_t glue_type_is_fixed_array(struct ast_ASTArena *arena, int32_t type_ref) {
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
static int32_t glue_block_let_is_fixed_array_type(struct ast_ASTArena *arena, int32_t block_ref,
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
static int32_t glue_fixed_array_let_init_uses_direct_slot(struct ast_ASTArena *arena, int32_t type_ref,
                                                          int32_t init_ref) {
  if (!glue_type_is_fixed_array(arena, type_ref) || init_ref <= 0)
    return 0;
  return pipeline_expr_kind_ord_at(arena, init_ref) == 46 ? 1 : 0;
}
