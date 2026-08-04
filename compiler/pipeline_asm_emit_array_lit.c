/**
 * pipeline_asm_emit_array_lit.c — asm ELF EXPR_ARRAY_LIT emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding ARRAY_LIT ELF emit:
 * - pipeline_asm_array_lit_elem_byte_sz_c (T width in T[N]/T[]; nested row,
 *   NAMED layout, SLICE fat 16 — Cap residual pure waves 357/416/597/692)
 * - glue_init_is_empty_array_lit (empty `[]` classification; twin backend.x)
 * - pipeline_asm_emit_array_lit_elf_c (force_esz=0 wrapper)
 * - pipeline_asm_emit_array_lit_force_esz_elf_c (stack temp + nested flat +
 *   SLICE dual-GP + >8B STRUCT_LIT/CALL homes + may_clobber re-lea —
 *   Cap residual pure waves 340/598/613/626/631/647/692)
 * - glue_array_lit_force_esz_from_elem_type_c (scalar/NAMED/SLICE force_esz)
 * - glue_asm_emit_array_lit_durable_ptr_rax_elf_c (text-embed / COMMON durable)
 *
 * G.7: single product-mega ARRAY_LIT ELF face — do not open a second array_lit
 * emitter. Nested helpers: leaf_elem_byte_sz / flat_elf live in
 * pipeline_asm_emit_vector_let.c (same TU). scalar_elem_to_rax lives in
 * pipeline_asm_emit_as.c (float_lit twin). wave1021: durable_ptr +
 * force_esz_from_elem_type folded here. wave1055: glue_fixed_array_temp_bytes +
 * glue_array_temp_bytes_for_let_init folded here (array temp sizing domain).
 * bump_next_offset + slice_from_array_let_init remain in pipeline_glue.c
 * (stack/temp deps).
 *
 * Callers: expr_elf_rec, return_impl (force_esz), block_body/inits (empty check),
 * vector_let_init / durable COMMON fill paths in glue.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_assign.c (before index_elem_byte_sz / addr_of).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Forward decls for helpers defined later in pipeline_glue.c (same TU).
 * Many already appear in the early glue forward block; restate the ones this
 * domain calls that are defined after this include point. */
static int32_t glue_type_size_simple(struct ast_Module *m, struct ast_ASTArena *a, int32_t ty_ref,
                                     int32_t depth);
static int32_t glue_array_lit_emit_scalar_elem_to_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t array_lit_ref, int32_t elem_ref,
                                                            struct backend_AsmFuncCtx *ctx, int32_t ta,
                                                            int32_t force_esz);
static int32_t glue_emit_struct_type_let_init_elf_c(struct ast_ASTArena *arena,
                                                     struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                     int32_t init_ref, struct backend_AsmFuncCtx *ctx,
                                                     int32_t ta, int32_t type_ref, int32_t home_off);
static int32_t glue_expr_emit_may_clobber_rbx_elf_c(struct ast_ASTArena *arena, int32_t expr_ref);
static int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
/* leaf/flat defined earlier in pipeline_glue.c (~L3346); prototypes keep static linkage. */
static int32_t pipeline_asm_array_lit_leaf_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t init_ref);
static int32_t pipeline_asm_emit_array_lit_flat_elf_c(struct ast_ASTArena *arena,
                                                      struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                      int32_t init_ref, struct backend_AsmFuncCtx *ctx,
                                                      int32_t ta, int32_t stack_slot_off, int32_t leaf_esz,
                                                      int32_t *flat_i);
static int32_t glue_fixed_array_total_bytes_c(struct ast_ASTArena *arena, int32_t ty_ref, int32_t depth);
/* wave1055: ast_pipeline_expr_array_lit_num_elems_at defined in ast_pool.c
 * (glue.c:16314); forward decl at glue.c:3902 > this #include (L2299), so
 * declare locally for glue_array_temp_bytes_for_let_init body (EOF below). */
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);

/* wave1021 durable fold: helpers defined earlier in pipeline_glue TU (lea/COMMON)
 * or later (align, dual_gp body, expr_rec). Prototypes keep static linkage. */
static void glue_align_next_offset(struct backend_AsmFuncCtx *ctx);
static int32_t glue_emit_bulk_mem_copy_spills_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                    int32_t src_spill, int32_t dst_spill, int32_t esz,
                                                    int32_t ta);
static int32_t glue_asm_lea_rax_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                               int32_t name_len);
static int32_t glue_asm_lea_rbx_common_rip_x86(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                               int32_t name_len);
static int32_t glue_asm_lea_rax_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                  int32_t name_len);
static int32_t glue_asm_lea_rbx_common_adrp_arm64(struct platform_elf_ElfCodegenCtx *elf_ctx, uint8_t *name,
                                                  int32_t name_len);
static int32_t pipeline_asm_emit_expr_elf_rec(struct ast_ASTArena *arena,
                                              struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                              struct backend_AsmFuncCtx *ctx, int32_t ta);
/* g_pipeline_asm_al_nc_seq defined earlier in pipeline_glue.c (same TU). */

/**
 * ARRAY_LIT element byte width (T in T[N] / T[]); twin of backend.x asm_array_lit_elem_byte_sz.
 * wave357: nested TYPE_ARRAY elems use full contiguous row size (not pointer 8).
 *
 * wave416 Cap residual pure: freestanding i64/u64/usize/isize ARRAY_LIT stores used esz=4.
 * Root: stamped scalar kinds TYPE_U64=4 … TYPE_ISIZE=7 fell through to default 4 while INDEX
 * loads used glue_index_elem_byte_sz (8) → stride mismatch (host-C braces correct; sum/idx red).
 * G.7: align 8-byte integer/ptr kinds with glue_index_elem_byte_sz_from_type_ref_c scalars
 * (do not call that helper for PTR: index peels pointee; ARRAY_LIT of *T is pointer width 8).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS host-C already green.
 */
static int32_t pipeline_asm_array_lit_elem_byte_sz_c(struct ast_ASTArena *arena, int32_t expr_ref) {
  int32_t elem_ty;
  int32_t kind_ord;
  int32_t nested;
  int32_t first_ref;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
  if (elem_ty > 0) {
    kind_ord = pipeline_type_kind_ord_at(arena, elem_ty);
    if (kind_ord == 10) {
      nested = glue_fixed_array_total_bytes_c(arena, elem_ty, 0);
      if (nested > 0)
        return nested;
    }
    /* 1-byte: TYPE_U8=2, TYPE_BOOL=1 */
    if (kind_ord == 2 || kind_ord == 1)
      return 1;
    /* 4-byte: TYPE_I32=0, TYPE_U32=3, TYPE_VECTOR=13, TYPE_F32=14 */
    if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
      return 4;
    /*
     * 8-byte: TYPE_F64=15, TYPE_U64=4, TYPE_I64=5, TYPE_USIZE=6, TYPE_ISIZE=7,
     * TYPE_PTR=9 (element is a pointer; not pointee width).
     * wave416: U64/I64/USIZE/ISIZE were missing → default 4 broke fixed i64[N] lit.
     */
    if (kind_ord == 15 || kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 ||
        kind_ord == 9)
      return 8;
    /*
     * wave692 Cap residual pure: TYPE_SLICE fat element of nested `[][]T` lit —
     * element width 16 (data+length), not peel-to-scalar 4. G.7 twin of
     * glue_array_lit_force_esz_from_elem_type_c / glue_type_size_simple(SLICE).
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
     */
    if (kind_ord == GLUE_TYPE_KIND_SLICE)
      return 16;
    /*
     * wave597 Cap residual pure: TYPE_NAMED=8 struct/array-of-struct elements.
     * Root: NAMED fell through to default 4 → `let xs: S[2] = [mk(), mk()]` stored
     * only 4B per CALL (eax of packed 8B return) at stride 4 → xs[0].a+xs[1].b=10
     * not 22 on Ubuntu pure-asm (mac freestanding often constant-folds main to 22).
     * G.7: glue_type_size_simple is the layout authority (same as INDEX named stride).
     * PLATFORM: SHARED freestanding · LINUX gold.
     */
    if (kind_ord == 8 && g_pipeline_asm_emit_module) {
      int32_t ssz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, elem_ty, 0);
      if (ssz > 0)
        return ssz;
    }
  }
  /* Unstamped multi-dim lit: first elem is nested ARRAY_LIT — infer row width. */
  first_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, 0);
  if (first_ref > 0 && pipeline_expr_kind_ord_at(arena, first_ref) == 46) {
    int32_t n_inner = pipeline_expr_array_lit_num_elems_at(arena, first_ref);
    int32_t iesz = pipeline_asm_array_lit_elem_byte_sz_c(arena, first_ref);
    if (n_inner > 0 && iesz > 0)
      return n_inner * iesz;
  }
  return 4;
}

/**
 * let/const 初值为 `[]` 的空 ARRAY_LIT：与 backend.x asm_init_is_empty_array_lit 一致。
 * PLATFORM: SHARED — classification only.
 *
 * wave330: TYPE_SLICE + empty must still go through glue_emit_slice_from_array_let_init_elf_c
 * (dual-GP {data, length=0}). Fixed-array / pointer-slot empties may skip rec emit; do not
 * treat "empty" as "no store" for fat slices (prologue zero is not a substitute).
 */
static int32_t glue_init_is_empty_array_lit(struct ast_ASTArena *arena, int32_t init_ref) {
  if (init_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 46)
    return 0;
  return pipeline_expr_array_lit_num_elems_at(arena, init_ref) == 0 ? 1 : 0;
}

/**
 * EXPR_ARRAY_LIT：temp 区逐元素 emit（与 struct_lit 对称，勿落 ast_arena_expr_get 慢路径）。
 *
 * wave340 Cap residual pure: non-const elems (binop / call / …) clobber rbx while the
 * payload base is held only in rbx → later stores write to garbage (Ubuntu SIGSEGV on
 * `let a:i32[]=[n,n+10,n+20]`). G.7: same dual-slot discipline as binop (wave338) —
 * after an elem emit that may clobber rbx, push value, re-lea temp_base → rbx, pop value,
 * then store. LIT/VAR elems leave rbx intact (glue_expr_emit_may_clobber_rbx_elf_c=0).
 *
 * wave598 Cap residual pure: >8B STRUCT_LIT/CALL elems use struct let-init into temp
 * homes (dual-GP / sret / in-place lit) then re-lea payload base for return ptr.
 *
 * wave613 Cap residual pure: nested multi-dim ARRAY_LIT rvalue (`[[10,32],[1,2]][0][0]`)
 * must flatten row-major into the temp (G.7 same authority as vector_let_init wave357).
 * Root: per-elem `emit_expr_rec` on nested ARRAY_LIT leaves a **pointer** in rax; storing
 * that at outer stride builds array-of-pointers while INDEX leave_addr+load expects
 * contiguous T[N][M] (let `m:i32[2][2]=[[…]]` already green via flat writer). host-C
 * braces hid freestanding wrong values (mac fs [0][0]=32, [0][1]=1; dual sum=65).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
int32_t pipeline_asm_emit_array_lit_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                 int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_array_lit_force_esz_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0);
}

/**
 * EXPR_ARRAY_LIT stack emit with optional force_esz (wave631).
 * force_esz>0: formal/let elem width wins over lit-inferred (TYPE_SLICE large NAMED).
 * force_esz==0: same as historical pipeline_asm_emit_array_lit_elf_c.
 * PLATFORM: SHARED freestanding.
 */
static int32_t pipeline_asm_emit_array_lit_force_esz_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                          int32_t ta, int32_t force_esz) {
  int32_t n_arr;
  int32_t esz;
  int32_t ai;
  int32_t temp_base;
  int32_t elem_ref;
  int32_t elem_ty;
  int32_t nbytes;
  int32_t has_nested;
  pipeline_glue_AsmFuncCtxLayout *ly;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
  if (n_arr == 0) {
    temp_base = ly->next_offset;
    return backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_base, ta);
  }
  /** ARRAY_LIT face: cap GLUE_ARRAY_LIT_MAX_ELEMS (1024, wave415; was 512 wave413). */
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
  /* wave631: formal force_esz (e.g. S24=24 from TYPE_SLICE let) before lit infer. */
  esz = force_esz > 0 ? force_esz : pipeline_asm_array_lit_elem_byte_sz_c(arena, expr_ref);
  if (esz <= 0)
    esz = 4;
  elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
  /*
   * Reserve contiguous payload for per-elem struct let-init homes.
   * PLATFORM: MACOS|ARM64 low-end — byte0 @ temp_base, grows +ai*esz.
   * PLATFORM: LINUX|x86 high-end — byte0 @ temp_base (top of alloc), home = base-ai*esz
   *   (same polarity as nested STRUCT_LIT field / wave595).
   */
  nbytes = n_arr * esz;
  {
    int32_t reserve = (nbytes + 7) & ~7;
    if (reserve < 8)
      reserve = 8;
    if (ta == 1) {
      temp_base = ly->next_offset;
      if ((temp_base % 8) != 0)
        temp_base = (temp_base + 7) / 8 * 8;
      ly->next_offset = temp_base + reserve;
    } else {
      temp_base = ly->next_offset;
      if ((temp_base % 8) != 0)
        temp_base = (temp_base + 7) / 8 * 8;
      temp_base = temp_base + reserve;
      ly->next_offset = temp_base;
    }
  }
  /*
   * wave613: multi-dim nested ARRAY_LIT → flat row-major (≡ vector_let_init has_nested).
   * Do not emit_rec nested rows (pointer-in-slot); INDEX expects contiguous scalars.
   */
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
      /*
       * wave598/626: >8B struct homes + STRUCT_LIT at any esz (G.7 same as vector_let_init).
       * wave626: ≤8B STRUCT_LIT rvalue next_offset aliases high-end temp_base byte0.
       */
      /*
       * wave692: TYPE_SLICE fat elem (esz=16) — dual-GP → C fat at elem_home.
       * High-end polarity: elem_home = temp_base - ai*esz (byte0 of fat).
       * Memory order always data@home, length@home+8 (C fat; not dual-GP frame).
       */
      if (esz == 16 && elem_ty > 0 &&
          pipeline_type_kind_ord_at(arena, elem_ty) == GLUE_TYPE_KIND_SLICE) {
        int32_t elem_home;
        int32_t len_spill;
        pipeline_glue_AsmFuncCtxLayout *ly2 = pipeline_asm_ctx_layout(ctx);
        elem_home = (ta == 1) ? (temp_base + ai * esz) : (temp_base - ai * esz);
        if (elem_home < 0 || !ly2)
          return -1;
        if (ly2->next_offset + 16 < ly2->next_offset)
          return -1;
        ly2->next_offset += 16;
        len_spill = ly2->next_offset;
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, elem_ref, ctx, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, elem_home, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(
                elf_ctx, glue_slice_dual_gp_length_off_c(elem_home, ta), ta) != 0)
          return -1;
        continue;
      }
      if (esz > 8 || pipeline_expr_kind_ord_at(arena, elem_ref) == 45) {
        int32_t elem_home;
        int32_t st;
        elem_home = (ta == 1) ? (temp_base + ai * esz) : (temp_base - ai * esz);
        if (elem_home < 0)
          return -1;
        st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                   elem_ty > 0 ? elem_ty : 0, elem_home);
        if (st == 0)
          continue;
        if (st == -1)
          return -1;
        /* st == -2: fall through to emit+store */
      }
      {
        int32_t may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
        int32_t store_sz = esz;
        if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8)
          store_sz = 4;
        /* wave647: FLOAT_LIT force_ty/force_esz (twin of durable COMMON fill). */
        if (glue_array_lit_emit_scalar_elem_to_rax_elf_c(arena, elf_ctx, expr_ref, elem_ref, ctx, ta,
                                                          force_esz) != 0)
          return -1;
        if (may_clobber != 0) {
          /* value@rax; restore payload base@rbx without dropping the value. */
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

/**
 * wave625 / wave692: formal/let element force_esz for ARRAY_LIT durable/stack pack.
 * Scalar kinds + TYPE_NAMED layout size + TYPE_SLICE fat 16.
 * G.7: single force_esz authority for let-init / call-arg / return (wave1021 leaf).
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
 */
static int32_t glue_array_lit_force_esz_from_elem_type_c(struct ast_ASTArena *arena, int32_t et) {
  int32_t ek;
  if (!arena || et <= 0)
    return 0;
  ek = pipeline_type_kind_ord_at(arena, et);
  /* TYPE_U8=2, BOOL=1 */
  if (ek == 2 || ek == 1)
    return 1;
  /* TYPE_I32=0, U32=3, VECTOR=13, F32=14 */
  if (ek == 0 || ek == 3 || ek == 13 || ek == 14)
    return 4;
  /* TYPE_U64=4, I64=5, USIZE=6, ISIZE=7, F64=15, PTR=9 */
  if (ek == 4 || ek == 5 || ek == 6 || ek == 7 || ek == 15 || ek == 9)
    return 8;
  /*
   * TYPE_NAMED=8: layout size (Pt i32+i32 → 8 → durable str x0 full by-value).
   * ssz>8 (e.g. 12) still returned; durable rejects non-{1,2,4,8} → stack path.
   */
  if (ek == 8 && g_pipeline_asm_emit_module) {
    int32_t ssz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, et, 0);
    if (ssz > 0)
      return ssz;
  }
  /*
   * wave692 Cap residual pure: TYPE_SLICE=11 element of nested `[][]T` is a fat
   * pointer {data,length}=16B (glue_type_size_simple). Prior fell through → force_esz=0
   * → lit-inferred esz=4 → durable COMMON stored only eax of .data (Ubuntu pure-asm
   * nested INDEX SIGSEGV; host-C braces green; mac arm64 CTFE often hid).
   * G.7: same force_esz authority as scalar/NAMED — no second pack path.
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
   */
  if (ek == GLUE_TYPE_KIND_SLICE)
    return 16;
  return 0;
}

/**
 * wave335 Cap residual pure: freestanding durable ARRAY_LIT payload → rax.
 * wave341: non-const elems also durable via SHN_COMMON BSS + runtime stores
 * (const still uses jmp-skip text-embed; non-const cannot live in RX .text).
 * wave632: force_esz>8 (large NAMED) COMMON bulk fill via struct let-init + chunked
 * copy (kill return [S24{…}] stack dangle; Ubuntu pure-asm was 193≠110).
 *
 * Root: stack compound from pipeline_asm_emit_array_lit_elf_c dangles after return;
 * caller INDEX then SIGSEGV (Ubuntu) or reads garbage (host).
 * G.7: const = string-lit rodata pattern; non-const = modlet COMMON BSS pattern;
 *      large NAMED = same COMMON + bulk (expand wave341/598/630, no second face).
 * nbytes cap GLUE_ARRAY_LIT_MAX_PAYLOAD. Empty → rax=0.
 *
 * wave1021: body folded into pipeline_asm_emit_array_lit.c (G.7 same authority;
 * no second durable face). scalar_elem stays in pipeline_asm_emit_as.c (float twin).
 *
 * @param ctx AsmFuncCtx for non-const / large-NAMED elem emit (may be null when all-const only).
 * @param force_esz element byte size from TYPE_SLICE elem (0 → infer from lit).
 * @return 0 success (rax = durable ptr); -1 cannot pack (caller may fall back).
 * PLATFORM: SHARED freestanding · LINUX|x86_64 (text-embed const / COMMON) ·
 * MACOS|ARM64 (COMMON + ADRP, wave408).
 */
static int32_t glue_asm_emit_array_lit_durable_ptr_rax_elf_c(struct ast_ASTArena *arena,
                                                            struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                            int32_t expr_ref, int32_t force_esz, int32_t ta,
                                                            struct backend_AsmFuncCtx *ctx) {
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
  /*
   * PLATFORM: LINUX+MACOS x86_64 (ta==0) + MACOS|ARM64 (ta==1).
   * wave408: arm64 was hard -1 → return [..] fell to stack ARRAY_LIT → dangle after
   * epilogue + missing dual-GP length → pure0/rec panic on INDEX bounds.
   * wave413: n_arr cap 256→512; wave415: 512→1024 + payload 2048→4096.
   */
  if (!arena || !elf_ctx || expr_ref <= 0 || (ta != 0 && ta != 1))
    return -1;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != (int32_t)ast_ExprKind_EXPR_ARRAY_LIT)
    return -1;
  n_arr = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
  if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
    return -1;
  if (n_arr == 0) {
    /* Empty slice: null data pointer is durable. */
    return backend_enc_mov_imm64_to_rax_arch(elf_ctx, 0, 0, ta);
  }
  /*
   * Prefer formal/let force_esz (u64[] lit elems still type as i32 without stamp).
   * wave631: force_esz>0 but not scalar {1,2,4,8} must NOT re-infer to esz=4
   * (packed stack-pointer halves into COMMON while INDEX strode 24).
   * wave632 Cap residual pure: force_esz>8 (large NAMED S24=24) is accepted for
   * COMMON bulk fill below — return [S24{…}] must not fall to stack (Ubuntu pure-asm
   * simple_r=193≠110 / deep=113≠110; host-C 110; mac arm64 often hid). force_esz in
   * {3,5,6,7} still reject. force_esz==0 → lit infer (scalar pack or bulk if >8).
   * G.7: expand same durable authority (wave341 COMMON + wave598/630 bulk).
   * PLATFORM: SHARED freestanding · LINUX gold exposes; MACOS|ARM64 co-path.
   */
  esz = force_esz;
  if (esz != 1 && esz != 2 && esz != 4 && esz != 8) {
    if (force_esz > 8) {
      esz = force_esz;
    } else if (force_esz > 0) {
      /* Weird non-scalar widths 3/5/6/7 — no pack path. */
      return -1;
    } else {
      esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, expr_ref);
    }
  }
  if (esz <= 0)
    return -1;
  /* Scalar pack widths or large-NAMED bulk (>8); reject other mid widths. */
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
  /* PLATFORM: LINUX+MACOS x86_64 — jmp-over text-embed + lea [rip] (const scalar only). */
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
      if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, jmp_short, 2) != 0)
        return -1;
    } else {
      rel32 = nbytes;
      jmp_near[0] = 0xe9;
      jmp_near[1] = (uint8_t)(rel32 & 0xff);
      jmp_near[2] = (uint8_t)((rel32 >> 8) & 0xff);
      jmp_near[3] = (uint8_t)((rel32 >> 16) & 0xff);
      jmp_near[4] = (uint8_t)((rel32 >> 24) & 0xff);
      if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, jmp_near, 5) != 0)
        return -1;
    }
    if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, payload, nbytes) != 0)
      return -1;
    disp32 = -nbytes - 7;
    lea7[0] = 0x48;
    lea7[1] = 0x8d;
    lea7[2] = 0x05; /* rax */
    lea7[3] = (uint8_t)(disp32 & 0xff);
    lea7[4] = (uint8_t)((disp32 >> 8) & 0xff);
    lea7[5] = (uint8_t)((disp32 >> 16) & 0xff);
    lea7[6] = (uint8_t)((disp32 >> 24) & 0xff);
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, lea7, 7);
  }
  /*
   * wave341 Cap residual pure: non-const durable via SHN_COMMON BSS (writable).
   * wave408: arm64 const also uses COMMON + runtime fill (text-embed is x86-only);
   *           ADRP/PAGEOFF lea via glue_asm_lea_*_common_adrp_arm64.
   * wave632: esz>8 large NAMED — COMMON + per-elem struct let-init temp + bulk copy
   *           (scalar store_rax_to_rbx_offset only packs ≤8).
   * G.7: pipeline_elf_ctx_add_common_sym (modlet face); never RW .text.
   * Fill (scalar): emit elem → rax; lea rbx COMMON; store [rbx+i*esz]; lea rax COMMON.
   * Fill (bulk):   let-init → frame temp; src/dst spills; bulk_mem_copy_spills.
   * PLATFORM: SHARED freestanding · LINUX|x86_64 · MACOS|ARM64.
   * Needs ctx for non-const / large-NAMED elem emit; const arm64 uses imm→store.
   */
  if ((all_const == 0 || esz > 8) && !ctx)
    return -1;
  seq = g_pipeline_asm_al_nc_seq;
  if (seq < 0 || seq > 999999)
    seq = 0;
  g_pipeline_asm_al_nc_seq = seq + 1;
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
  /* Align COMMON size to esz (loader min align); cap esz for align arg at 16. */
  {
    int32_t common_align = esz;
    if (common_align > 16)
      common_align = 16;
    if (common_align < 1)
      common_align = 1;
    if (pipeline_elf_ctx_add_common_sym((uint8_t *)elf_ctx, label, llen, nbytes, common_align) != 0)
      return -1;
  }
  /*
   * wave632 Cap residual pure: large NAMED / esz>8 bulk into COMMON.
   * Root: wave631 rejected force_esz=24 → stack emit_array_lit → return dual-GP
   * data@rax points into callee frame → Ubuntu pure-asm after return: 193≠110
   * (host-C static compound green; mac arm64 often still-green).
   * G.7: same COMMON face as wave341; fill reuses glue_emit_struct_type_let_init
   * (wave598) + glue_emit_bulk_mem_copy_spills (wave630) — no third durable path.
   * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
   */
  if (esz > 8) {
    pipeline_glue_AsmFuncCtxLayout *ly;
    int32_t elem_ty;
    int32_t src_spill;
    int32_t dst_spill;
    int32_t temp_home;
    int32_t elem_reserve;
    int32_t st;
    ly = pipeline_asm_ctx_layout(ctx);
    if (!ly)
      return -1;
    elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, expr_ref);
    /*
     * wave692 Cap residual pure: TYPE_SLICE fat elements (nested `[][]T` lit).
     * Root: esz=16 bulk path called glue_emit_struct_type_let_init (STRUCT only)
     * → fail or scalar fallthrough wrote mov eax half of .data into COMMON
     * (Ubuntu pure-asm nested INDEX SIGSEGV; host-C green).
     * G.7: emit dual-GP (data@rax length@rdx) → temp dual-GP home → bulk 16 to
     * COMMON (same COMMON face as large NAMED; C fat memory order data@0 len@8).
     * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path.
     */
    if (elem_ty > 0 &&
        pipeline_type_kind_ord_at(arena, elem_ty) == (int32_t)ast_TypeKind_TYPE_SLICE && esz == 16) {
      int32_t data_spill;
      int32_t len_spill;
      if (ly->next_offset + 48 < ly->next_offset)
        return -1;
      ly->next_offset += 16;
      data_spill = ly->next_offset;
      ly->next_offset += 16;
      len_spill = ly->next_offset;
      ly->next_offset += 16;
      src_spill = ly->next_offset;
      ly->next_offset += 16;
      dst_spill = ly->next_offset;
      temp_home = ly->next_offset + 16;
      ly->next_offset = temp_home + 16;
      glue_align_next_offset(ctx);
      for (ai = 0; ai < n_arr; ai++) {
        elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
        if (elem_ref <= 0)
          return -1;
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, elem_ref, ctx, ta) != 0)
          return -1;
        /* Spill dual-GP halves (rdx store may be arch-specific — use frame). */
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, data_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        /* Materialize dual-GP fat at temp_home (arch-aware length half → contiguous 16B). */
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, data_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(elf_ctx, temp_home, ta) != 0)
          return -1;
        if (backend_enc_load_rbp_to_rax_arch(elf_ctx, len_spill, ta) != 0)
          return -1;
        if (backend_enc_store_rax_to_rbp_arch(
                elf_ctx, glue_slice_dual_gp_length_off_c(temp_home, ta), ta) != 0)
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
    /* Two pointer spills (src, dst); 16B each for dual-GP slot alignment. */
    if (ly->next_offset + 32 < ly->next_offset)
      return -1;
    ly->next_offset += 16;
    src_spill = ly->next_offset;
    ly->next_offset += 16;
    dst_spill = ly->next_offset;
    elem_reserve = (esz + 7) & ~7;
    if (elem_reserve < 8)
      elem_reserve = 8;
    if (ly->next_offset + elem_reserve < ly->next_offset)
      return -1;
    ly->next_offset += elem_reserve;
    temp_home = ly->next_offset;
    for (ai = 0; ai < n_arr; ai++) {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
      if (elem_ref <= 0)
        return -1;
      st = glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, elem_ref, ctx, ta,
                                                 elem_ty > 0 ? elem_ty : 0, temp_home);
      if (st != 0)
        return -1;
      /* src = &temp_home */
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_home, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta) != 0)
        return -1;
      /* dst = COMMON + ai*esz */
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
  for (ai = 0; ai < n_arr; ai++) {
    elem_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, ai);
    if (elem_ref <= 0)
      return -1;
    if (all_const != 0) {
      /* Const path: imm into rax (works without ctx). INT_LIT/BOOL only. */
      v64 = (int64_t)pipeline_expr_int_val_at(arena, elem_ref);
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, (int32_t)(v64 & 0xffffffff),
                                             (int32_t)((v64 >> 32) & 0xffffffff), ta) != 0)
        return -1;
    } else {
      /*
       * wave647: FLOAT_LIT pack via force_ty/force_esz (f32 bits when esz=4).
       * Prior emit_expr_rec alone left f64 bits → store esz=4 wrote zeros.
       */
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

/* wave1055 G.7 fold: glue_fixed_array_temp_bytes + glue_array_temp_bytes_for_let_init
 * migrated here from pipeline_glue.c (definitions were at glue.c:3912/3952).
 * Array temp sizing domain — fixed-array T[N] stack temp byte width, colocated
 * with ARRAY_LIT emit (same domain; consumed by bump_next_offset +
 * block_body.c let-init temp reservation + block stmt order let_const fold).
 *
 * Dependencies (all visible before this #include site at glue.c:2299):
 * - glue_type_size_simple (forward decl above at L35; definition later in TU)
 * - pipeline_arena_type_ptr / pipeline_type_kind_ord_at (public; visible)
 * - pipeline_expr_resolved_type_ref / pipeline_expr_kind_ord_at (public)
 * - ast_pipeline_expr_array_lit_num_elems_at (public; ast_pool.c)
 * - pipeline_asm_array_lit_elem_type_ref (public; defined at glue.c:1278 < 2299)
 * - g_pipeline_asm_emit_module (global; visible)
 *
 * No forward decl needed in array_lit.c: zero internal callsites before EOF.
 * All external callsites (glue.c:4018/4042/6402/6483 + block_body.c:473/606)
 * are after this #include at glue.c:2299 — definition visible via same-TU. */

/**
 * Byte width of a fixed-length array T[N] in the stack temp area.
 *
 * Why: §11.1 layout step — let a:T[N]=[] needs a temp slot sized array_size *
 * elem_sz to hold the in-progress array before lea to the let home. Non-ARRAY
 * types return 0 (caller falls back to scalar 8B). STRUCT[N] (kind_ord 10)
 * delegates to glue_type_size_simple for SoA column-major or AoS N×layout
 * width — must match typeck / asm_local_slot_bytes or csv buf/line overlap.
 *
 * Invariant: returns 0 for invalid arena/ref or array_size <= 0; otherwise
 * returns array_size * elem_sz where elem_sz is 1 (u8/bool), 8 (ptr/i64/u64/
 * usize/isize/f64/named), or 4 (default: i32/u32/f32). elem_sz table mirrors
 * glue_type_align_simple scalar width (wave1054) — do not diverge.
 *
 * Asm/Perf: O(1) — single arena type ptr deref + kind_ord lookup; STRUCT[N]
 * adds one glue_type_size_simple call (O(depth) bounded by 64). Cold path —
 * called once per let-decl with array type during frame layout.
 *
 * PLATFORM: SHARED — pure type sizing; arch-agnostic.
 */
static int32_t glue_fixed_array_temp_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t esz;
  int32_t bytes;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t || t->array_size <= 0)
    return 0;
  /* Struct[N]: match typeck / asm_local_slot_bytes width (SoA or AoS N×layout). */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 10) {
    bytes = glue_type_size_simple(g_pipeline_asm_emit_module, arena, type_ref, 0);
    if (bytes > 0)
      return bytes;
  }
  elem_ref = t->elem_type_ref;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if (pipeline_type_kind_ord_at(arena, elem_ref) == 2)
        esz = 1;
      else if (pipeline_type_kind_ord_at(arena, elem_ref) == 8 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 4 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 5 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 6 ||
               pipeline_type_kind_ord_at(arena, elem_ref) == 14)
        esz = 8;
      else
        esz = 4;
    }
  }
  bytes = t->array_size * esz;
  return bytes > 0 ? bytes : 0;
}

/**
 * Derive array temp bytes from a let init (fallback to init resolved_type
 * when let_type_ref is missing; fallback to ARRAY_LIT num_elems * elem_sz
 * when type-based sizing misses).
 *
 * Why: let a:=[] may lack an explicit type_ref — the init's resolved_type
 * or the ARRAY_LIT element count must size the temp slot. Without this
 * fallback, `let a:=[]` would get 0 temp bytes and the subsequent lea to
 * home would overlap the next let's slot (csv buf/line corruption).
 *
 * Invariant: returns 0 if no array sizing can be derived; otherwise returns
 * glue_fixed_array_temp_bytes(let_type_ref) > 0, else
 * glue_fixed_array_temp_bytes(init resolved_type) > 0, else
 * ARRAY_LIT num_elems * elem_sz (kind_ord 46 == EXPR_ARRAY_LIT).
 *
 * Asm/Perf: O(1) — up to 2 glue_fixed_array_temp_bytes calls + 1 ARRAY_LIT
 * elem type lookup. Cold path — once per let-decl during frame layout.
 *
 * PLATFORM: SHARED — pure type/init sizing; arch-agnostic.
 */
static int32_t glue_array_temp_bytes_for_let_init(struct ast_ASTArena *arena, int32_t let_type_ref,
                                                  int32_t init_ref) {
  int32_t bytes;
  bytes = glue_fixed_array_temp_bytes(arena, let_type_ref);
  if (bytes > 0)
    return bytes;
  if (init_ref > 0) {
    int32_t rt;
    rt = pipeline_expr_resolved_type_ref(arena, init_ref);
    bytes = glue_fixed_array_temp_bytes(arena, rt);
    if (bytes > 0)
      return bytes;
    if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
      int32_t ne;
      int32_t esz;
      ne = ast_pipeline_expr_array_lit_num_elems_at(arena, init_ref);
      if (ne > 0) {
        esz = 4;
        {
          int32_t inner;
          inner = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
          if (inner > 0 && pipeline_type_kind_ord_at(arena, inner) == 2)
            esz = 1;
          else if (inner > 0 && (pipeline_type_kind_ord_at(arena, inner) == 8 ||
                                 pipeline_type_kind_ord_at(arena, inner) == 4))
            esz = 8;
        }
        bytes = ne * esz;
        if (bytes > 0)
          return bytes;
      }
    }
  }
  return 0;
}

/* wave1195 G.7: pipeline_asm_array_lit_elem_type_ref migrated from
 * pipeline_glue.c L662-687.
 *
 * Why colocate: array lit elem type ref resolution is the array_lit
 * domain's core helper — used by vector_let_init / array_lit emit /
 * as cast to determine the element type_ref of a TYPE_ARRAY or
 * TYPE_SLICE stamped array literal.
 *
 * Deps (all declared before array_lit.c #include at L1574):
 *  - pipeline_arena_expr_ptr (glue.c L213 fwd decl; def in ast_pool_arena.c)
 *  - pipeline_type_kind_ord_at (glue.c L761 fwd decl; def in ast_pool_type.c)
 *  - pipeline_type_elem_ref_at (glue.c L399 fwd decl; def in ast_pool_type.c)
 *
 * Callers (same TU): pipeline_asm_emit_as.c (L1345 < L1574 — sees via
 * extern fwd decl in glue.c L662), pipeline_asm_emit_vector_let.c
 * (L1476 < L1574 — sees via extern fwd decl in glue.c L662).
 * Cross-TU: seeds/backend_try_inline_dispatch*.from_x.c.
 *
 * PLATFORM: SHARED — array lit elem type resolution is platform-agnostic. */

/**
 * pipeline_asm_array_lit_elem_type_ref — get elem_type_ref from an
 * array literal's resolved_type_ref (TYPE_ARRAY or TYPE_SLICE).
 *
 * Why: backend.x asm_expr_array_lit_elem_store_sz_bytes — X cannot
 *      safely typeck `let e: Expr = ast_arena_expr_get(...)` then
 *      access fields; C reads resolved_type_ref directly from pool.
 * wave631: peel TYPE_SLICE (11) as well as TYPE_ARRAY (10) — `let s:
 *      S24[] = [S24{…}, …]` stamps lit as TYPE_SLICE; old gate only
 *      accepted TYPE_ARRAY → elem_ty=0 → wrong elem byte sz.
 * Contract: returns 0 if arena/ref invalid, not array/slice, or
 *           elem_type_ref missing; else returns elem_type_ref.
 * PLATFORM: SHARED freestanding.
 */
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref) {
  int32_t arr_tr;
  int32_t tk;
  struct ast_Expr *ex;
  if (!arena || array_lit_expr_ref <= 0 || array_lit_expr_ref > arena->num_exprs)
    return 0;
  ex = pipeline_arena_expr_ptr(arena, array_lit_expr_ref);
  if (!ex)
    return 0;
  arr_tr = ex->resolved_type_ref;
  if (arr_tr <= 0)
    return 0;
  tk = pipeline_type_kind_ord_at(arena, arr_tr);
  if (tk != 10 && tk != 11)
    return 0;
  return pipeline_type_elem_ref_at(arena, arr_tr);
}
