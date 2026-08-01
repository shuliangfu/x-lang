/**
 * pipeline_asm_emit_return.c — asm ELF EXPR_RETURN emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding return ELF emit:
 * - GLUE_SLICE_ESC_WALK_* capacity for nested-block fixed→slice finder
 * - glue_match_slice_escape_lets_in_block_c (let s: T[] = a / field)
 * - pipeline_find_fixed_array_slice_escape (DFS body + nested blocks; host+fs)
 * - glue_try_return_slice_escape_from_fixed_array_elf_c (COMMON durable escape)
 * - pipeline_asm_emit_return_elf_impl (sret / slice escape / ARRAY_LIT dual-GP
 *   / float promote / tail_join jmp)
 *
 * G.7: single product-mega EXPR_RETURN ELF emit path — do not open a second
 * return emitter in seed partial or a parallel glue copy. Thin public wrapper
 * pipeline_asm_emit_return_elf_c lives at end of this leaf (wave1014 fold) and
 * calls the static impl (same TU). Host codegen also calls
 * pipeline_find_fixed_array_slice_escape (non-static) for twin escape capacity.
 *
 * wave1025 G.7 fold: sret return path helpers moved here from glue residual
 * (same TU; no new DEPS):
 * - glue_emit_sret_memcpy_rbx_to_home_elf_c (memcpy struct to caller dest)
 * - glue_emit_sret_return_from_var_elf_c (return local_var sret copy)
 * - glue_copy_large_struct_from_rax_ptr_elf_c (>16B struct from rax ptr to slot)
 * Shared with struct_lit leaf (sret_memcpy) and struct_let leaf
 * (copy_large_struct via store_retval_pair). glue 1989-1991 forward decls kept.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after float
 * promote / module return-type forward decls and before unary / as emit slices.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/*
 * wave343 Cap residual pure: nested-block fixed→slice return escape (G.7 complete).
 * wave342 only scanned function-body top-level lets → nested `{ let a; let s=a; return s }`
 * missed → host/fs run=1. Authority: DFS block tree from body (if/while/for/region +
 * EXPR_BLOCK children) + resolved TYPE_ARRAY on slice-init VAR.
 * PLATFORM: SHARED — host (codegen) and freestanding (ELF) share this finder.
 * Soft leave-off: untyped-let; reentrancy last-wins static/COMMON (wave344 closed reassign N).
 */
#define GLUE_SLICE_ESC_WALK_DEPTH_MAX 256
#define GLUE_SLICE_ESC_WALK_VISIT_MAX 4096

/* Forward decls: full prototypes appear later in this TU / ast_pool. */
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
extern int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
extern int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);

/**
 * Match `let s: T[] = a` / wave348 `let s: T[] = b.a` where a / field is fixed TYPE_ARRAY.
 * Writes *out_arr_sz / *out_elem_tr / *out_arr_init_ref.
 * @return 1 found; 0 not in this block.
 * PLATFORM: SHARED (host+fs escape capacity N).
 */
static int32_t glue_match_slice_escape_lets_in_block_c(struct ast_ASTArena *arena, int32_t block_ref,
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
    uint8_t nb[128];
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
    if (tr <= 0 || pipeline_type_kind_ord_at(arena, tr) != (int32_t)ast_TypeKind_TYPE_SLICE)
      continue;
    init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
    if (init_ref <= 0)
      continue;
    init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
    /* Prefer resolved TYPE_ARRAY on init (VAR or FIELD_ACCESS). */
    {
      int32_t irty = pipeline_expr_resolved_type_ref(arena, init_ref);
      if (irty > 0 && pipeline_type_kind_ord_at(arena, irty) == (int32_t)ast_TypeKind_TYPE_ARRAY) {
        arr_sz = pipeline_type_array_size_at(arena, irty);
        arr_ty = irty;
      }
    }
    if (arr_sz <= 0 && init_ko == 3) {
      int32_t avlen = pipeline_expr_var_name_len(arena, init_ref);
      uint8_t aname[128];
      if (avlen <= 0 || avlen > 127)
        continue;
      pipeline_expr_var_name_into(arena, init_ref, aname);
      for (lj = 0; lj < nlet; lj++) {
        int32_t alen = pipeline_block_let_name_len(arena, block_ref, lj);
        int32_t am = 1;
        int32_t ac;
        uint8_t ab[128];
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
        if (atr > 0 && pipeline_type_kind_ord_at(arena, atr) == (int32_t)ast_TypeKind_TYPE_ARRAY) {
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

/* wave394: TYPE_SLICE dual-GP length half (def near glue_emit_slice_from_array_let_init). */
static int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
static void glue_slice_dual_gp_bump_past_home_c(struct backend_AsmFuncCtx *ctx, int32_t data_home,
                                               int32_t ta);
/* wave1025: glue_var_decl_type_ref_elf_c body in pipeline_asm_emit_var_decl.c (wave1023);
 * needed by glue_emit_sret_return_from_var_elf_c (body at end of this leaf). */
static int32_t glue_var_decl_type_ref_elf_c(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                             int32_t var_expr_ref);
/* wave1025: glue_enc_local_slot_ptr_or_addr_rbx_elf_c body in pipeline_asm_emit_index_helpers.c
 * (#included after this leaf); needed by glue_emit_sret_return_from_var_elf_c. */
static int32_t glue_enc_local_slot_ptr_or_addr_rbx_elf_c(struct ast_ASTArena *arena,
                                                         struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                         int32_t var_expr_ref, int32_t stack_off,
                                                         struct backend_AsmFuncCtx *ctx, int32_t ta);

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
static int32_t glue_try_return_slice_escape_from_fixed_array_elf_c(
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
  uint8_t vname[128];
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
  if (!g_pipeline_asm_emit_module || g_pipeline_asm_emit_func_index < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, ret_op) != 3) /* EXPR_VAR */
    return 0;
  rty = pipeline_module_func_return_type_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
  sty = pipeline_expr_resolved_type_ref(arena, ret_op);
  if (rty > 0 && pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_SLICE)
    slice_ret = 1;
  else if (sty > 0 && pipeline_type_kind_ord_at(arena, sty) == (int32_t)ast_TypeKind_TYPE_SLICE)
    slice_ret = 1;
  if (slice_ret == 0)
    return 0;

  vlen = pipeline_expr_var_name_len(arena, ret_op);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, ret_op, vname);
  body_ref = pipeline_module_func_body_ref_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
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
  seq = g_pipeline_asm_al_nc_seq;
  if (seq < 0 || seq > 999999)
    seq = 0;
  g_pipeline_asm_al_nc_seq = seq + 1;
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

static int32_t pipeline_asm_emit_return_elf_impl(struct ast_ASTArena *arena,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                   struct backend_AsmFuncCtx *ctx, int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t ret_op;
  ly = pipeline_asm_ctx_layout(ctx);
  ret_op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (ret_op != 0) {
    /* PLATFORM: x86_64 SysV + arm64 AAPCS64 sret — return local_var of >16B struct. */
    if (g_pipeline_asm_func_sret_active && g_pipeline_asm_func_sret_ret_sz > 16 &&
        (ta == 0 || ta == 1) && pipeline_expr_kind_ord_at(arena, ret_op) == 3) {
      if (glue_emit_sret_return_from_var_elf_c(arena, elf_ctx, ret_op, ctx, ta) != 0)
        return -1;
    } else if (arena && ctx && elf_ctx && (ta == 0 || ta == 1) &&
               pipeline_expr_kind_ord_at(arena, ret_op) == 3 &&
               g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
      /*
       * wave342/418: return TYPE_SLICE VAR that views a fixed TYPE_ARRAY local → durable
       * COMMON copy (kill owned-buffer escape). wave418: arm64 too (was ta==0 only).
       * Falls through on 0 (not applicable).
       */
      int32_t esc = glue_try_return_slice_escape_from_fixed_array_elf_c(arena, elf_ctx, ret_op, ctx, ta);
      if (esc < 0)
        return -1;
      if (esc == 0) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, ret_op, ctx, ta) != 0)
          return -1;
        if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
          int32_t rty = pipeline_module_func_return_type_at(g_pipeline_asm_emit_module,
                                                            g_pipeline_asm_emit_func_index);
          int32_t sty = glue_float_promote_src_ty_ref_c(arena, ret_op);
          if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta) != 0)
            return -1;
        }
      }
    } else if (arena && ctx && elf_ctx && (ta == 0 || ta == 1) &&
               pipeline_expr_kind_ord_at(arena, ret_op) == (int32_t)ast_ExprKind_EXPR_ARRAY_LIT &&
               g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
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
      int32_t rty = pipeline_module_func_return_type_at(g_pipeline_asm_emit_module,
                                                        g_pipeline_asm_emit_func_index);
      int32_t sty = pipeline_expr_resolved_type_ref(arena, ret_op);
      int32_t slice_ty = 0;
      if (rty > 0 && pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_SLICE)
        slice_ty = rty;
      else if (sty > 0 && pipeline_type_kind_ord_at(arena, sty) == (int32_t)ast_TypeKind_TYPE_SLICE)
        slice_ty = sty;
      /*
       * wave417: return ARRAY_LIT → TYPE_ARRAY also durable E* (host __xlang_ar twin).
       * Prior only TYPE_SLICE took durable; TYPE_ARRAY fell to stack emit → dangle.
       */
      if (slice_ty == 0 && rty > 0 &&
          pipeline_type_kind_ord_at(arena, rty) == (int32_t)ast_TypeKind_TYPE_ARRAY) {
        int32_t n_arr = pipeline_expr_array_lit_num_elems_at(arena, ret_op);
        /* wave625: G.7 force_esz includes TYPE_NAMED (was scalar-only). */
        int32_t force_esz = glue_array_lit_force_esz_from_elem_type_c(
            arena, pipeline_type_elem_ref_at(arena, rty));
        if (n_arr < 0 || n_arr > GLUE_ARRAY_LIT_MAX_ELEMS)
          return -1;
        if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, force_esz, ta, ctx) != 0) {
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
        if (glue_asm_emit_array_lit_durable_ptr_rax_elf_c(arena, elf_ctx, ret_op, force_esz, ta, ctx) == 0) {
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
      } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, ret_op, ctx, ta) != 0) {
        return -1;
      } else if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
        int32_t rty2 = pipeline_module_func_return_type_at(g_pipeline_asm_emit_module,
                                                           g_pipeline_asm_emit_func_index);
        int32_t sty2 = glue_float_promote_src_ty_ref_c(arena, ret_op);
        if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty2, sty2, ta) != 0)
          return -1;
      }
    } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, ret_op, ctx, ta) != 0) {
      return -1;
    } else if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
      /* wave314: return f32 value from f64 function — cvtss2sd. */
      int32_t rty = pipeline_module_func_return_type_at(g_pipeline_asm_emit_module,
                                                        g_pipeline_asm_emit_func_index);
      int32_t sty = glue_float_promote_src_ty_ref_c(arena, ret_op);
      if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty, sty, ta) != 0)
        return -1;
    }
  }
  if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_emit_phase_reset(elf_ctx, ta) != 0)
    return -1;
  if (ly->tail_join_label_len <= 0)
    return -1;
  return backend_enc_jmp_arch(elf_ctx, ly->tail_join_label, ly->tail_join_label_len, ta);
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
 * g_pipeline_asm_sret_home_off.
 * PLATFORM: LINUX+MACOS x86_64 SysV — dest@rdi src@rsi n@rdx (rax scratch; arg regs distinct).
 * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — dest@x0 src@x1 n@x2.
 *   arm64 cannot reuse the x86 push/pop sequence: mov_rax_to_arg_reg(0) is a no-op
 *   (arg0≡x0), so pop would clobber dest. Order: keep src in x1 (rbx), size→x2 first,
 *   then load dest into x0.
 */
static int32_t glue_emit_sret_memcpy_rbx_to_home_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t sz,
                                                       int32_t ta) {
  static const uint8_t memcpy_sym[] = "memcpy";
  if ((ta != 0 && ta != 1) || !elf_ctx || sz <= 16 || g_pipeline_asm_sret_home_off < 0)
    return -1;
  if (ta == 1) {
    /* src already in x1 (=rbx); set n@x2 then dest@x0 (load must not clobber x1/x2). */
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
      return -1;
    /* x0=dest, x1=src, x2=n */
    return backend_enc_call_arch(elf_ctx, (uint8_t *)memcpy_sym, (int32_t)(sizeof(memcpy_sym) - 1), ta);
  }
  /* x86 SysV: rax scratch, rdi/rsi/rdx hold args. */
  if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_load_rbp_to_rax_arch(elf_ctx, g_pipeline_asm_sret_home_off, ta) != 0)
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
static int32_t glue_emit_sret_return_from_var_elf_c(struct ast_ASTArena *arena,
                                                    struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t var_expr_ref,
                                                    struct backend_AsmFuncCtx *ctx, int32_t ta) {
  uint8_t vname[128];
  int32_t vlen;
  int32_t off;
  int32_t tr;
  int32_t sz;
  if (!arena || !elf_ctx || !ctx || var_expr_ref <= 0 || !g_pipeline_asm_func_sret_active)
    return -1;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
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
  sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, tr, 0);
  if (sz <= 16)
    return -1;
  if (glue_enc_local_slot_ptr_or_addr_rbx_elf_c(arena, elf_ctx, var_expr_ref, off, ctx, ta) != 0)
    return -1;
  return glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx, sz, ta);
}

/**
 * 大 struct（>16B）按值返回：callee 在 rax 放指向栈上结果的指针，memcpy 到 let 槽。
 */
static int32_t glue_copy_large_struct_from_rax_ptr_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t slot_off,
                                                         int32_t sz, int32_t ta) {
  static const uint8_t memcpy_sym[] = "memcpy";
  if (ta != 0 || sz <= 16)
    return -1;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
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

