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
 *
 * G.7: single product-mega ARRAY_LIT ELF face — do not open a second array_lit
 * emitter. Nested helpers: leaf_elem_byte_sz / flat_elf live in
 * pipeline_asm_emit_vector_let.c (same TU). scalar_elem_to_rax,
 * durable_ptr, force_esz_from_elem_type, bump_next_offset remain in
 * pipeline_glue.c (same TU; defined earlier or later).
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
