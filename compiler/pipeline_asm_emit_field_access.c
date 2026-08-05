/**
 * pipeline_asm_emit_field_access.c — asm ELF EXPR_FIELD_ACCESS emit domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding FIELD_ACCESS ELF emit:
 * - glue_field_access_layout_field_type_ref_by_name_c (module struct layout
 *   scan by field name when typed field_type_ref fails)
 * - glue_field_access_call_arg_struct_by_addr_elf_c (CALL-arg MEMORY class
 *   >16B leave address in rax; SysV dual-GP 9–16B still by-value)
 * - glue_field_call_arg_try_load_agg_from_rax_elf_c (after field lvalue in rax:
 *   dual-load / load64 for CALL-arg aggregates ≤16B)
 * - glue_field_access_call_base_rvalue_elf_c (CALL/METHOD/STRUCT_LIT-rooted
 *   field chains: materialise root once, walk offsets, optional leave_addr
 *   for INDEX base — Cap residual pure waves 589–612)
 * - pipeline_asm_emit_var_field_access_elf_c (VAR base + stack slot + offset
 *   load; slice dual-GP length/data; CALL-arg aggregate twin)
 * - pipeline_asm_emit_field_access_elf_fast_c (enum variant imm; fixed array
 *   .length; SoA index field; CALL base; TokenKind/TypeKind/ExprKind; VAR;
 *   chained lvalue — Cap residual pure; avoid backend slow / rec SIGSEGV)
 *
 * G.7: single product-mega FIELD_ACCESS ELF face — do not open a second
 * field-access emitter. Offset/layout helpers
 * (glue_field_access_effective_offset_c / field_type_ref_c /
 * pipeline_expr_field_access_layout_offset) folded into this leaf (wave1026)
 * (same TU; shared with lvalue / init / INDEX paths).
 *
 * Callers: expr_elf_rec / expr_elf_fast FIELD_ACCESS arms; INDEX base helpers
 * (call_base leave_addr=1); CALL-arg typing residual (layout_by_name).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the former
 * field_access body site (after panic include + binop rem/mod; before
 * pipeline_asm_emit_expr_elf_c).
 *
 * PLATFORM: SHARED freestanding emit · LINUX gold · MACOS|ARM64 co-path
 * (ta layout / sret gate documented on call_base_rvalue). Host-cc via
 * pipeline_x.o TU.
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_emit_expr_elf_rec / lvalue_eff_addr_elf_c
 * - glue_field_access_effective_offset_c / field_type_ref_c
 * - glue_call_param_named_struct_pass_addr_elf_c / glue_type_* /
 *   glue_store_retval_pair_to_rbp_elf_c / try_inline_*_struct_lit_return*
 * - pipeline_asm_emit_struct_let_init_elf_c / glue_emit_soa_index_field_addr*
 * - pipeline_typeck_field_soa_index_c / backend_enc_*_arch / pipeline_expr_*
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_call_param_ty_ref
 *
 * wave1033 G.7 fold: pipeline_token_kind_variant_tag is now defined at the
 * top of this file (sole in-TU leaf consumer + residual glue.c caller
 * pipeline_expr_enum_namespace_field_tag after this #include site).
 */

/**
 * Resolve a TokenKind variant name (e.g. "TOKEN_EOF") to its ordinal.
 *
 * Why: ExprKind.XXX / TypeKind.XXX / TokenKind.XXX comparisons in asm have
 * no local slot; the field name is parsed and matched against the TokenKind
 * enum variant table to return the ordinal, or -1 on miss. Import token.x
 * without registered sidecar falls back to this fast path; the module
 * enum sidecar (pipeline_expr_enum_field_tag_via_module) is the slower
 * fallback path used by pipeline_expr_enum_namespace_field_tag.
 *
 * Contract: variant_name must be non-NULL and variant_len > 0; returns
 * 0..N-1 matching the include/token.h TokenKind enum order, or -1 if no
 * match. The names[] table is kept in lockstep with token.h TokenKind.
 *
 * PLATFORM: SHARED — names[] table mirrors include/token.h TokenKind enum
 * order; must not drift from token.h. Consumed by field_access fast path
 * (this file, 2 callsites) + residual glue.c enum_namespace_field_tag.
 */
static int32_t pipeline_token_kind_variant_tag(const uint8_t *variant_name, int32_t variant_len) {
  /* Keep in lockstep with include/token.h TokenKind enum order; import
   * token.x without registered sidecar falls back to this fast path. */
  static const char *const names[] = {
      "TOKEN_EOF",       "TOKEN_FUNCTION",  "TOKEN_LET",         "TOKEN_CONST",      "TOKEN_IF",
      "TOKEN_ELSE",      "TOKEN_WHILE",     "TOKEN_LOOP",        "TOKEN_FOR",        "TOKEN_BREAK",
      "TOKEN_CONTINUE",  "TOKEN_RETURN",    "TOKEN_PANIC",       "TOKEN_DEFER",      "TOKEN_MATCH",
      "TOKEN_STRUCT",    "TOKEN_PACKED",    "TOKEN_ENUM",        "TOKEN_GOTO",       "TOKEN_TRAIT",
      "TOKEN_IMPL",      "TOKEN_SELF",      "TOKEN_UNDERSCORE",  "TOKEN_IMPORT",     "TOKEN_EXTERN",
      "TOKEN_IDENT",     "TOKEN_I32",       "TOKEN_BOOL",        "TOKEN_U8",         "TOKEN_U32",
      "TOKEN_U64",       "TOKEN_I64",       "TOKEN_USIZE",       "TOKEN_ISIZE",      "TOKEN_I32X4",
      "TOKEN_I32X8",     "TOKEN_I32X16",    "TOKEN_U32X4",       "TOKEN_U32X8",      "TOKEN_U32X16",
      "TOKEN_F32X4",     "TOKEN_TRUE",      "TOKEN_FALSE",     "TOKEN_F32",         "TOKEN_F64",        "TOKEN_VOID",
      "TOKEN_INT",       "TOKEN_FLOAT",     "TOKEN_LPAREN",      "TOKEN_RPAREN",     "TOKEN_LBRACE",
      "TOKEN_RBRACE",    "TOKEN_LBRACKET",  "TOKEN_RBRACKET",    "TOKEN_ARROW",      "TOKEN_FATARROW",
      "TOKEN_COMMA",     "TOKEN_COLON",     "TOKEN_DOT",         "TOKEN_SEMICOLON",  "TOKEN_PLUS",
      "TOKEN_MINUS",     "TOKEN_STAR",      "TOKEN_SLASH",       "TOKEN_PERCENT",    "TOKEN_AMP",
      "TOKEN_PIPE",      "TOKEN_CARET",     "TOKEN_LSHIFT",      "TOKEN_RSHIFT",     "TOKEN_PLUS_EQ",
      "TOKEN_MINUS_EQ",  "TOKEN_STAR_EQ",   "TOKEN_SLASH_EQ",    "TOKEN_PERCENT_EQ", "TOKEN_AMP_EQ",
      "TOKEN_PIPE_EQ",   "TOKEN_CARET_EQ",  "TOKEN_LSHIFT_EQ",   "TOKEN_RSHIFT_EQ",  "TOKEN_TILDE",
      "TOKEN_ASSIGN",    "TOKEN_EQ",        "TOKEN_NE",          "TOKEN_LT",         "TOKEN_GT",
      "TOKEN_LE",        "TOKEN_GE",        "TOKEN_AMPAMP",      "TOKEN_PIPEPIPE",   "TOKEN_BANG",
      "TOKEN_QUESTION",  "TOKEN_AS",        "TOKEN_AT",
  };
  int32_t i;
  int32_t nlen;
  if (!variant_name || variant_len <= 0)
    return -1;
  for (i = 0; i < (int32_t)(sizeof(names) / sizeof(names[0])); i++) {
    nlen = (int32_t)strlen(names[i]);
    if (nlen == variant_len && memcmp(variant_name, names[i], (size_t)variant_len) == 0)
      return i;
  }
  return -1;
}

/**
 * layout 扫描：按字段名在 module struct 表查 field type_ref（glue_field_access_field_type_ref 失败时回落）。
 */
static int32_t glue_field_access_layout_field_type_ref_by_name_c(struct ast_ASTArena *arena,
                                                                  struct ast_Module *mod, int32_t fa_ref) {
  struct ast_Expr *ex;
  int32_t flen;
  uint8_t field_name[128];
  int32_t k;
  int32_t j;
  if (!arena || !mod || fa_ref <= 0)
    return 0;
  ex = pipeline_arena_expr_ptr(arena, fa_ref);
  if (!ex)
    return 0;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 127)
    return 0;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  for (k = 0; k < (int32_t)mod->num_struct_layouts; k++) {
    for (j = 0; j < pipeline_module_struct_layout_num_fields(mod, k); j++) {
      int32_t fnlen = pipeline_module_struct_layout_field_name_len(mod, k, j);
      int32_t feq = 1;
      int32_t fi;
      if (fnlen != flen)
        continue;
      for (fi = 0; fi < fnlen; fi++) {
        uint8_t fb[128];
        pipeline_module_struct_layout_field_name_into(mod, k, j, fb);
        if (fb[fi] != field_name[fi]) {
          feq = 0;
          break;
        }
      }
      if (feq)
        return pipeline_module_struct_layout_field_type_ref(mod, k, j);
    }
  }
  return 0;
}

/**
 * CALL 实参 FIELD_ACCESS：仅 MEMORY class（>16B）leave address in rax.
 * PLATFORM: LINUX+MACOS x86_64 SysV —
 * 9–16B INTEGER (Allocator/StrView) is by-value dual-GP — must dual-load, not lea.
 * G.7: matches glue_call_param_named_struct_pass_addr_elf_c + dual-GP param home.
 */
static int32_t glue_field_access_call_arg_struct_by_addr_elf_c(struct ast_ASTArena *arena, int32_t fa_ref) {
  int32_t fty;
  if (!pipeline_asm_emit_call_arg_active_c())
    return 0;
  if (g_pipeline_asm_emit_call_param_ty_ref > 0)
    return glue_call_param_named_struct_pass_addr_elf_c(arena, g_pipeline_asm_emit_call_param_ty_ref);
  fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty <= 0 && g_pipeline_asm_emit_module)
    fty = glue_field_access_layout_field_type_ref_by_name_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty > 0)
    return glue_call_param_named_struct_pass_addr_elf_c(arena, fty);
  return 0;
}

/**
 * After field lvalue address is in rax: load CALL-arg aggregate by SysV class.
 * PLATFORM: LINUX+MACOS x86_64 SysV — 9–16B dual-load rax+rdx; ≤8B load 64.
 * Returns 1 if handled, 0 if not a call-arg aggregate (use scalar load_sz), -1 on emit error.
 */
static int32_t glue_field_call_arg_try_load_agg_from_rax_elf_c(struct ast_ASTArena *arena,
                                                               struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                               int32_t fa_ref, int32_t ta) {
  int32_t fty;
  int32_t sz;
  if (!pipeline_asm_emit_call_arg_active_c() || !arena || !elf_ctx)
    return 0;
  fty = 0;
  if (g_pipeline_asm_emit_call_param_ty_ref > 0 &&
      pipeline_type_kind_ord_at(arena, g_pipeline_asm_emit_call_param_ty_ref) == GLUE_TYPE_NAMED)
    fty = g_pipeline_asm_emit_call_param_ty_ref;
  if (fty <= 0)
    fty = glue_field_access_field_type_ref_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty <= 0 && g_pipeline_asm_emit_module)
    fty = glue_field_access_layout_field_type_ref_by_name_c(arena, g_pipeline_asm_emit_module, fa_ref);
  if (fty <= 0 || pipeline_type_kind_ord_at(arena, fty) != GLUE_TYPE_NAMED)
    return 0;
  sz = glue_type_named_layout_size_any_module_elf_c(arena, fty);
  if (sz <= 0)
    sz = glue_type_size_simple(g_pipeline_asm_emit_module, arena, fty, 0);
  if (sz <= 0)
    return 0;
  if (sz > 16)
    return 0; /* MEMORY: address already in rax via by_addr path */
  if (sz > 8)
    return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta) != 0 ? -1 : 1;
  if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  return 1;
}

/**
 * wave589 Cap residual pure: freestanding FIELD_ACCESS on CALL/METHOD_CALL return
 * (`mk().x` / long-field `mk().f…`).
 * wave590: extend >16B MEMORY/sret rvalue field (was soft leave after wave589).
 * wave593: (1) nested chain `mk().i.f` — walk FIELD bases to CALL/METHOD root and
 *          sum AoS field offsets; (2) ≤16B STRUCT_LIT-return CALL.field — try_inline
 *          first (same order as glue_emit_struct_type_let_init). Prior ≤16 path only
 *          did emit CALL + store_retval_pair; mid-size (9–16B) dual-GP CALL.field
 *          CG002 on arm64 freestanding while let inlined and green; >16 already inlined.
 *
 * wave608 Cap residual pure: freestanding FIELD_ACCESS on STRUCT_LIT rvalue base
 * (`Big { a: 40, b: 2 }.a` / paren twin). Root: chain walk only accepted CALL/METHOD
 * (48/49); STRUCT_LIT (45) fell through → lvalue_eff_addr UNHANDLED → CG002 while
 * host-C temporary `.` stayed green. G.7: same materialise-then-load authority —
 * STRUCT_LIT root via pipeline_asm_emit_struct_let_init_elf_c (≡ wave605 MEMORY
 * call-arg / let s: Big = Big{…}), then field offset load (no second field path).
 *
 * wave609 Cap residual pure: INDEX base on materialised field (`Wrap{…}.xs[1]` /
 * `mk().xs[i]`). Prior leave_addr=0 loaded first array word; INDEX then treated
 * that value as pointer → freestanding SIGSEGV (host-C green). leave_addr=1 stops
 * after lea home+field_off (INDEX authority in glue_try_index_var_or_field_base_*).
 *
 * Root: field_access fast fell through to lvalue_eff_addr, which only handles
 * VAR / nested FIELD / INDEX / DEREF. CALL/STRUCT_LIT base returns -1 → UNHANDLED
 * → CG002 (host-C emits temporary `.` access; Ubuntu pure-asm gold exposes). Nested
 * `mk().i.f` base is FIELD not CALL → same UNHANDLED before wave593.
 *
 * G.7 authority (same as `let s = mk()` / glue_emit_struct_type_let_init):
 *   materialise CALL/METHOD/STRUCT_LIT root once into frame temp:
 *     0) STRUCT_LIT (45): emit fields into home (struct_let_init)
 *     1) try_inline STRUCT_LIT return (any size; CALL only)
 *     2) >16B: sret (x86 SysV rdi+shift / arm64 AAPCS64 x8)
 *     3) ≤16B: emit CALL + glue_store_retval_pair_to_rbp_elf_c
 *   then lea home+sum(field_offs); leave_addr ? return addr : load outermost field.
 *
 * Soft residual: frame temps ≥512 scratch.
 * wave611: ARRAY_LIT base INDEX parse+typeck closed; wave612: dual INDEX binop
 *   rbx clobber classifier closed (see glue_binop_operand_index_addr_clobbers_rbx).
 * wave599: dual-GP param field extract (take_m) closed — arm64 param_home +
 *   fill_param low-end polarity (was soft leave after wave593).
 *
 * wave596: pointer intermediate on CALL chain (`mk().p.f` / `mk().m.p.f`) —
 * pure offset-sum skipped *T loads (same root as VAR-chain lvalue). Now walk
 * chain root→outer and load at each *T/*slice intermediate (G.7 + lvalue twin).
 *
 * @param leave_addr 0=load field rvalue; 1=leave field slot address in rax (INDEX)
 * @return 0 success, -1 emit error, PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED not
 *   CALL/METHOD/STRUCT_LIT-rooted chain
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64 co-path (ta layout;
 *   sret gate: x86_64 SysV + arm64 AAPCS64 x8 (wave591))
 */
static int32_t glue_field_access_call_base_rvalue_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t leave_addr) {
  int32_t base_ref;
  int32_t base_ko;
  int32_t base_ty;
  int32_t ret_sz;
  int32_t alloc_sz;
  int32_t home;
  int32_t base_off;
  int32_t load_sz;
  int32_t emit_rc;
  int32_t agg;
  int32_t materialised;
  int32_t cur_fa;
  int32_t chain_depth;
  int32_t chain_fa[16];
  int32_t chain_n;
  int32_t ci;
  pipeline_glue_AsmFuncCtxLayout *ly;
  struct ast_Module *mod;

  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  if (pipeline_expr_kind_ord_at(arena, expr_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;

  /*
   * wave593: walk FIELD_ACCESS chain to CALL/METHOD root.
   * wave596: keep FA refs (outer→inner) so *T intermediate can load; pure
   * offset sum is wrong when a mid-field is a pointer (`mk().p.f`).
   * Cap depth 16 — pathological nest falls through UNHANDLED (use let).
   */
  mod = g_pipeline_asm_emit_module;
  cur_fa = expr_ref;
  base_ref = 0;
  base_ko = 0;
  chain_depth = 0;
  chain_n = 0;
  while (chain_depth < 16) {
    int32_t next_base;
    if (pipeline_expr_field_access_is_enum_variant(arena, cur_fa) != 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    if (chain_n >= 16)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    chain_fa[chain_n++] = cur_fa;
    next_base = pipeline_expr_field_access_base_ref(arena, cur_fa);
    if (next_base <= 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    base_ko = pipeline_expr_kind_ord_at(arena, next_base);
    /* EXPR_STRUCT_LIT=45, EXPR_CALL=48, EXPR_METHOD_CALL=49, EXPR_FIELD_ACCESS=44 */
    if (base_ko == 48 || base_ko == 49 || base_ko == 45) {
      base_ref = next_base;
      break;
    }
    if (base_ko == 44) {
      cur_fa = next_base;
      chain_depth++;
      continue;
    }
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  }
  if (base_ref <= 0 || chain_n <= 0)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;

  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  ret_sz = 0;
  if (base_ty > 0)
    ret_sz = glue_type_size_simple(mod, arena, base_ty, 0);
  if (ret_sz <= 0 && base_ko == 48)
    ret_sz = glue_call_return_byte_size_c(arena, base_ref);
  if (ret_sz <= 0 && base_ko == 45)
    ret_sz = pipeline_expr_struct_lit_value_bytes(arena, mod, base_ref);
  if (ret_sz <= 0 && base_ty > 0)
    ret_sz = glue_type_named_layout_size_any_module_elf_c(arena, base_ty);
  if (ret_sz <= 0)
    ret_sz = 8;
  if (base_ty > 0 && ret_sz <= 16) {
    int32_t nsz = glue_sysv_dual_gp_byte_size_c(arena, base_ty);
    if (nsz > ret_sz)
      ret_sz = nsz;
  }
  /*
   * Cap frame temp: compute_frame_size scratch is ≥512; refuse pathological
   * aggregates rather than silent SP overrun (use let binding for huge types).
   */
  if (ret_sz > 4096)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;

  alloc_sz = (ret_sz <= 8) ? 8 : ((ret_sz <= 16) ? 16 : ((ret_sz + 7) & ~7));
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  base_off = ly->next_offset;
  if ((base_off % 8) != 0)
    base_off = (base_off + 7) / 8 * 8;
  /*
   * PLATFORM: MACOS|ARM64 low-end home=off (wave402); LINUX|x86 high-end
   * home=off+alloc (store_retval dual-GP: low@home, high@home-8; sret byte0@home).
   */
  if (ta == 1) {
    home = base_off;
    ly->next_offset = base_off + alloc_sz;
  } else {
    home = base_off + alloc_sz;
    ly->next_offset = home;
  }
  glue_align_next_offset(ctx);

  /*
   * Materialise root CALL/METHOD/STRUCT_LIT into home — same order as let_init (G.7):
   * STRUCT_LIT fields → inline STRUCT_LIT return CALL → sret if >16 → dual-GP if ≤16.
   * wave593: pull try_inline out of >16-only so 9–16B STRUCT_LIT CALL.field greens.
   * wave608: bare STRUCT_LIT.field (not only CALL-return inline).
   */
  materialised = 0;
  if (base_ko == 45) {
    /* PLATFORM: SHARED — reuse wave605 MEMORY / let struct_let_init (G.7 one path). */
    if (pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, base_ref, ctx, ta, home) != 0)
      return -1;
    materialised = 1;
  }
  if (materialised == 0 && base_ko == 48) {
    int32_t inl;
    inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, base_ref, ctx, ta, home);
    if (inl == 1)
      materialised = 1;
    if (materialised == 0) {
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, base_ref, ctx, ta, home);
      if (inl == 1)
        materialised = 1;
    }
  }
  if (materialised == 0 && ret_sz > 16) {
    /*
     * Non-inline large CALL: materialise via sret into home.
     * PLATFORM: LINUX+MACOS x86_64 SysV — hidden dest in rdi + GP shift.
     * PLATFORM: MACOS|ARM64 AAPCS64 (wave591) — dest in x8; no GP shift.
     * METHOD_CALL has no STRUCT_LIT-return inline helper; sret path covers it.
     */
    if (ta != 0 && ta != 1)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    pipeline_asm_set_call_expected_ret_ty_c(base_ty > 0 ? base_ty : 0);
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0) {
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return -1;
    }
    if (ta == 0) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      pipeline_asm_emit_set_call_sret_reg_shift_c(1);
    } else {
      if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
    }
    emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta);
    pipeline_asm_emit_set_call_sret_reg_shift_c(0);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    materialised = 1;
  } else if (materialised == 0) {
    emit_rc = pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, base_ref, ctx, ta);
    if (emit_rc != 0)
      return -1;
    if (glue_store_retval_pair_to_rbp_elf_c(mod, arena, elf_ctx, base_ty > 0 ? base_ty : 0, home, ta, base_ref,
                                            ctx) != 0)
      return -1;
    materialised = 1;
  }
  if (materialised == 0)
    return -1;

  /*
   * Walk chain root→outer (chain_fa is outer→inner): add each field offset;
   * auto-deref *T / fat-slice intermediate (wave596) before the next hop.
   * Outermost load uses load_sz of expr_ref (chain_fa[0]).
   */
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta) != 0)
    return -1;
  for (ci = chain_n - 1; ci >= 0; ci--) {
    int32_t fo = glue_field_access_effective_offset_c(arena, mod, chain_fa[ci]);
    if (fo < 0)
      fo = 0;
    if (fo != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, fo, ta) != 0)
      return -1;
    if (ci > 0) {
      /* Intermediate FA: if field is *T or slice fat, load pointer before next offset. */
      if (glue_index_deref_ptr_field_slot_rax_elf_c(arena, elf_ctx, chain_fa[ci], ta) != 0)
        return -1;
    }
  }
  /* wave609: INDEX base needs field slot address only (TYPE_ARRAY / *T[] home). */
  if (leave_addr != 0)
    return 0;
  if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0)
    return 0;
  agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
  if (agg < 0)
    return -1;
  if (agg > 0)
    return 0;
  load_sz = pipeline_expr_field_access_load_byte_sz(arena, mod, expr_ref);
  if (load_sz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (load_sz == 8)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

/**
 * VAR 基底字段访问（lex.pos、l.line 等）：经 asm_ctx 查栈槽 + 字段偏移 load，勿落 backend slow 的 ast_arena_expr_get 按值拷贝。
 */
static int32_t pipeline_asm_emit_var_field_access_elf_c(struct ast_ASTArena *arena,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t expr_ref,
                                                        struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t base_ref;
  int32_t vlen;
  int32_t var_off;
  int32_t field_off;
  int32_t load_sz;
  uint8_t vname[128];

  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (base_ref <= 0 || pipeline_expr_kind_ord_at(arena, base_ref) != 3)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  vlen = pipeline_expr_var_name_len(arena, base_ref);
  if (vlen <= 0 || vlen > 127)
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  pipeline_expr_var_name_into(arena, base_ref, vname);
  var_off = asm_ctx_local_find_offset_scoped((uint8_t *)ctx, arena, vname, vlen);
  /** while/for 体内访问外层 let：scoped min_slot 可能排除形参/外层槽，退化为全表搜索。 */
  if (var_off < 0)
    var_off = asm_ctx_local_find_offset((uint8_t *)ctx, vname, vlen);
  if (var_off < 0) {
    if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
      fprintf(stderr, "xlang: var_field_access miss var='%.*s'\n", (int)vlen, (char *)vname);
    return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
  }
  /*
   * wave393 Cap residual pure: freestanding TYPE_SLICE dual-GP local home.
   * wave394: length half offset is arch-aware (glue_slice_dual_gp_length_off_c)
   * so memory order is always C fat; arm64 home+8, x86 home-8.
   * slice* params still fat*+8 via needs_ptr_load path below.
   * G.7: match INDEX bounds `glue_emit_slice_length_to_rbx_elf_c` dual-GP load.
   * PLATFORM: SHARED freestanding · LINUX+MACOS (arm64/x86_64); host-C untouched.
   */
  {
    int32_t base_ty_sl = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
    int32_t flen_sl = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (base_ty_sl > 0 && flen_sl > 0 && flen_sl <= 63 &&
        pipeline_type_kind_ord_at(arena, base_ty_sl) == GLUE_TYPE_KIND_SLICE &&
        glue_local_var_slot_needs_ptr_load_elf_c(arena, base_ref, var_off, ctx) == 0) {
      uint8_t fn_sl[128];
      pipeline_expr_field_access_name_into(arena, expr_ref, fn_sl);
      if (flen_sl == 6 && memcmp(fn_sl, "length", 6) == 0)
        return backend_enc_load_rbp_to_rax_arch(elf_ctx, glue_slice_dual_gp_length_off_c(var_off, ta),
                                               ta);
      if (flen_sl == 4 && memcmp(fn_sl, "data", 4) == 0)
        return backend_enc_load_rbp_to_rax_arch(elf_ctx, var_off, ta);
    }
  }
  field_off = glue_field_access_effective_offset_c(arena, g_pipeline_asm_emit_module, expr_ref);
  if (glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, base_ref, var_off, ctx, ta) != 0)
    return -1;
  if (field_off != 0 && backend_enc_add_imm_to_rax_arch(elf_ctx, field_off, ta) != 0)
    return -1;
  if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0)
    return 0;
  {
    int32_t agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    if (agg < 0)
      return -1;
    if (agg > 0)
      return 0;
  }
  load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, expr_ref);
  if (load_sz == 1)
    return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
  if (load_sz == 8)
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
}

/**
 * EXPR_FIELD_ACCESS 快速路径：枚举 TokenKind/ExprKind/TypeKind、VAR 字段（lex.pos），勿落 backend slow。
 */
/* wave149 Cap residual: pure binop leave (was static). PLATFORM: SHARED. */
int32_t pipeline_asm_emit_field_access_elf_fast_c(struct ast_ASTArena *arena,
                                                           struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                           int32_t expr_ref, struct backend_AsmFuncCtx *ctx,
                                                           int32_t ta) {
  int32_t fa_base2;
  int32_t blen2;
  if (pipeline_expr_field_access_is_enum_variant(arena, expr_ref) != 0)
    return backend_enc_mov_imm32_to_w0_arch(elf_ctx, pipeline_expr_enum_variant_tag_at(arena, expr_ref), ta);
  /*
   * wave346 Cap residual pure: fixed TYPE_ARRAY / TYPE_VECTOR `.length` → imm N in rax.
   * Prior: var_field_access loaded base+0 (first elem) when field_offset stayed 0
   * (typeck only stamped fat-slice length@+8). G.7: match host ((size_t)N) + typeck usize.
   * PLATFORM: SHARED freestanding emit (LINUX gold; mac host-C co-path).
   */
  {
    int32_t flen_arr = pipeline_expr_field_access_name_len(arena, expr_ref);
    if (flen_arr == 6) {
      uint8_t fn_arr[128];
      int32_t base_ref_arr;
      int32_t base_ty_arr;
      int32_t bk_arr;
      int32_t asz_arr;
      pipeline_expr_field_access_name_into(arena, expr_ref, fn_arr);
      if (memcmp(fn_arr, "length", 6) == 0) {
        base_ref_arr = pipeline_expr_field_access_base_ref(arena, expr_ref);
        base_ty_arr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref_arr);
        if (base_ty_arr <= 0)
          base_ty_arr = pipeline_expr_resolved_type_ref(arena, base_ref_arr);
        if (base_ty_arr > 0) {
          bk_arr = pipeline_type_kind_ord_at(arena, base_ty_arr);
          if (bk_arr == GLUE_TYPE_KIND_ARRAY || bk_arr == 13 /* TYPE_VECTOR */) {
            asz_arr = pipeline_type_array_size_at(arena, base_ty_arr);
            if (asz_arr > 0)
              return backend_enc_mov_imm64_to_rax_arch(elf_ctx, asz_arr, 0, ta);
          }
        }
      }
    }
  }
  fa_base2 = pipeline_expr_field_access_base_ref(arena, expr_ref);
  /** DOD-S1：SoA `arr[i].field` 读路径（列基址 + index*stride；失败/无 stride 时回落 lvalue 寻址）。 */
  if (fa_base2 > 0 && pipeline_expr_kind_ord_at(arena, fa_base2) == 47) {
    int32_t load_sz;
    /** emit 时 stride 仍缺：再跑 SoA typeck（skip .x typeck / 形参 T[N] 回填遗漏）。 */
    if (pipeline_expr_field_access_soa_stride(arena, expr_ref) <= 0 && g_pipeline_asm_emit_module != NULL)
      /* 8.3.3 host-cc leave: typeck.x authority (no pipeline_typeck_soa.c thin). */
      {
        extern int32_t typeck_soa_field_soa_index(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t expr_ref, int32_t base_ref);
        (void)typeck_soa_field_soa_index(g_pipeline_asm_emit_module, arena, expr_ref, fa_base2);
      }
    if (pipeline_expr_field_access_soa_stride(arena, expr_ref) > 0) {
      if (glue_emit_soa_index_field_addr_elf_c(arena, elf_ctx, fa_base2, expr_ref, ctx, ta) != 0 &&
          pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0)
        return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    } else if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    }
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, expr_ref);
    if (load_sz == 1)
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    if (load_sz == 8)
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
  }
  /**
   * wave589: CALL/METHOD_CALL rvalue base (`mk().x`) before VAR / chain lvalue.
   * PLATFORM: SHARED freestanding · LINUX gold.
   */
  {
    int32_t call_fa = glue_field_access_call_base_rvalue_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0);
    if (call_fa != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
      return call_fa;
  }
  /** 局部/形参 struct 字段（listener.fd 等）；枚举 TokenKind/TypeKind/ExprKind 须先于 var_field_access（skip typeck 无 is_enum_variant）。 */
  if (fa_base2 > 0 && pipeline_expr_kind_ord_at(arena, fa_base2) == 3) {
    blen2 = pipeline_expr_var_name_len(arena, fa_base2);
    if (blen2 >= 9) {
      uint8_t bn[128];
      uint8_t fb[128];
      int32_t flen2 = pipeline_expr_field_access_name_len(arena, expr_ref);
      int32_t tk;
      pipeline_expr_var_name_into(arena, fa_base2, bn);
      if (memcmp(bn, "TokenKind", 9) == 0 && flen2 > 0) {
        pipeline_expr_field_access_name_into(arena, expr_ref, fb);
        tk = pipeline_token_kind_variant_tag(fb, flen2);
        if (tk < 0) {
          /** parser 偶发 field_len 多 1（含尾零）；前缀一致再试 NUL 终止长。 */
          int32_t sl = (int32_t)strlen((const char *)fb);
          if (sl > 0 && sl < flen2)
            tk = pipeline_token_kind_variant_tag(fb, sl);
        }
        if (tk >= 0)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, tk, ta);
      }
    }
    if (blen2 >= 8) {
      uint8_t bn[128];
      uint8_t fb[128];
      int32_t flen2 = pipeline_expr_field_access_name_len(arena, expr_ref);
      int32_t ev_tag;
      pipeline_expr_var_name_into(arena, fa_base2, bn);
      if (memcmp(bn, "TypeKind", 8) == 0 && flen2 > 0) {
        pipeline_expr_field_access_name_into(arena, expr_ref, fb);
        ev_tag = pipeline_asm_typekind_variant_tag(fb, flen2);
        if (ev_tag >= 0)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ev_tag, ta);
      }
      if (memcmp(bn, "ExprKind", 8) == 0 && flen2 > 0) {
        ev_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
        if (ev_tag >= 0)
          return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ev_tag, ta);
      }
    }
    {
      int32_t vr = pipeline_asm_emit_var_field_access_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
      if (vr != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED)
        return vr;
    }
  }
  /** skip typeck：enum namespace 未标 is_enum_variant 时的最后回落。 */
  {
    int32_t ns_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
    if (ns_tag >= 0)
      return backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
  }
  /** 链式 FIELD_ACCESS（v.al.kind 等）：lvalue 寻址 + load；勿落 backend slow（与 rec 互递归 SIGSEGV）。 */
  {
    int32_t load_sz;
    int32_t agg;
    if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, expr_ref, ctx, ta) != 0)
      return PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED;
    if (glue_field_access_call_arg_struct_by_addr_elf_c(arena, expr_ref) != 0)
      return 0;
    agg = glue_field_call_arg_try_load_agg_from_rax_elf_c(arena, elf_ctx, expr_ref, ta);
    if (agg < 0)
      return -1;
    if (agg > 0)
      return 0;
    load_sz = pipeline_expr_field_access_load_byte_sz(arena, g_pipeline_asm_emit_module, expr_ref);
    if (load_sz == 1)
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    if (load_sz == 8)
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
  }
}

/* ========================================================================
 * wave1026 G.7 fold: field_access layout/offset helpers
 * (from pipeline_glue residual after this #include). Same-TU static.
 * Callers: this leaf (var_field_access / call_base_rvalue / field_access_fast);
 * index_helpers / assign / index_eff_addr / vector_let leaves (via forward
 * decls kept in glue: glue_field_access_effective_offset_c @2500;
 * pipeline_expr_field_access_layout_offset / load_byte_sz @1726-1727 public).
 * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64 · MACOS|ARM64 AAPCS64.
 * ======================================================================== */

/* wave1026: forward decls for helpers defined later in this TU (after
 * field_access.c #include at glue:2847). Needed by layout/offset helpers.
 * wave1050: glue_struct_layout_field_offset_by_name_c migrated here (definition
 * at EOF below); forward decl retained for callsites at L811/L832/L866/L884
 * (all in this leaf, before the definition). glue.c has zero self-callsites —
 * pure leaf consumed only by field_access.c. */
static int32_t glue_struct_layout_field_offset_by_name_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                          int32_t li, uint8_t *name, int32_t nlen);
static int32_t glue_struct_layout_index_by_type_name_c(struct ast_Module *m, uint8_t *struct_name,
                                                        int32_t nlen);
/* wave138: Cap residual in ast_pool_arena.c (non-static). */
struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
/* wave1179: pipeline_expr_enum_field_tag_via_module migrated to this file's
 * EOF; fwd decl here so pipeline_expr_enum_namespace_field_tag (also migrated)
 * can call it before its definition. */
int32_t pipeline_expr_enum_field_tag_via_module(uint8_t *enum_name, int32_t enum_len, uint8_t *variant_name,
                                                int32_t variant_len);
/* wave1026: extern decls for typeck/dep helpers declared after this #include
 * in glue (5653-5657); duplicated here for visibility. Compatible redecls OK. */
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                         uint8_t *type_name, int32_t type_name_len,
                                                         uint8_t *field_name, int32_t field_name_len);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);

/**
 * dep 编译单元 struct layout 中按字段名查偏移（caller 无 layout 时，如 stack_promote_cross_ret）。
 */
static int32_t glue_dep_layout_field_offset_by_name_c(struct ast_PipelineDepCtx *ctx, uint8_t *field_name,
                                                        int32_t flen) {
  int32_t nd;
  int32_t di;
  int32_t k;
  int32_t j;
  if (!ctx || !field_name || flen <= 0)
    return -1;
  nd = pipeline_dep_ctx_ndep(ctx);
  di = 0;
  while (di < nd) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
    if (dm) {
      for (k = 0; k < (int32_t)dm->num_struct_layouts; k++) {
        for (j = 0; j < pipeline_module_struct_layout_num_fields(dm, k); j++) {
          int32_t fnlen = pipeline_module_struct_layout_field_name_len(dm, k, j);
          int32_t feq = 1;
          int32_t fi;
          if (fnlen != flen)
            continue;
          for (fi = 0; fi < fnlen; fi++) {
            uint8_t fb[128];
            pipeline_module_struct_layout_field_name_into(dm, k, j, fb);
            if (fb[fi] != field_name[fi]) {
              feq = 0;
              break;
            }
          }
          if (!feq)
            continue;
          return pipeline_module_struct_layout_field_offset_at(dm, k, j);
        }
      }
    }
    di = di + 1;
  }
  return -1;
}

/**
 * VAR 基址 FIELD_ACCESS：按 base 的 struct 类型名 + 字段名查 layout 偏移。
 * emit 时 resolved_type 常缺失，须回落 module 形参 *T 类型；勿全局按字段名扫 layout（易误命中 path_buf 等）。
 * 命中返回 offset，未命中返回 -1。
 */
static int32_t glue_field_layout_offset_for_var_base_field(struct ast_ASTArena *a, struct ast_Module *m,
                                                           int32_t base_var_ref, uint8_t *field_name,
                                                           int32_t flen) {
  int32_t base_ty;
  int32_t fi;
  uint8_t vname[128];
  int32_t vlen;
  struct ast_Type *tp;
  uint8_t struct_name[128];
  int32_t nlen;
  int32_t k;
  int32_t j;
  if (!a || !m || base_var_ref <= 0 || !field_name || flen <= 0 || flen > 127)
    return -1;
  base_ty = 0;
  /** emit 中 VAR 形参：优先当前函数 param 表，勿信 fill 误写的 resolved_type（同名 v 跨函数覆盖）。 */
  if (pipeline_expr_kind_ord_at(a, base_var_ref) == 3) {
    fi = g_pipeline_asm_emit_func_index;
    vlen = pipeline_expr_var_name_len(a, base_var_ref);
    if (fi >= 0 && fi < m->num_funcs && vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(a, base_var_ref, vname);
      base_ty = pipeline_module_func_param_type_ref_for_name(m, fi, vname, vlen);
    }
  }
  if (base_ty <= 0)
    base_ty = pipeline_expr_resolved_type_ref(a, base_var_ref);
  /** while/for 体内 let p: Pair 等：skip typeck 时 resolved_type 常缺，从 scope 块链查 let 声明类型。 */
  if (base_ty <= 0 && pipeline_expr_kind_ord_at(a, base_var_ref) == 3 && g_pipeline_asm_emit_scope_block > 0) {
    vlen = pipeline_expr_var_name_len(a, base_var_ref);
    if (vlen > 0 && vlen <= 63) {
      pipeline_expr_var_name_into(a, base_var_ref, vname);
      base_ty = pipeline_block_resolve_var_type_ref(a, g_pipeline_asm_emit_scope_block, vname, vlen);
    }
  }
  /** final_expr 等无 scope sidecar：从当前 emit 函数体查 let p: Pair 类型。 */
  if (base_ty <= 0 && pipeline_expr_kind_ord_at(a, base_var_ref) == 3 && g_pipeline_asm_emit_func_index >= 0 &&
      g_pipeline_asm_emit_func_index < m->num_funcs) {
    vlen = pipeline_expr_var_name_len(a, base_var_ref);
    if (vlen > 0 && vlen <= 63) {
      int32_t body_ref = pipeline_module_func_body_ref_at(m, g_pipeline_asm_emit_func_index);
      pipeline_expr_var_name_into(a, base_var_ref, vname);
      if (body_ref > 0)
        base_ty = pipeline_block_resolve_var_type_ref(a, body_ref, vname, vlen);
    }
  }
  /** skip typeck：单 layout 入口模块按字段名查 offset（cl_align64 Ring64 等）。 */
  if (base_ty <= 0 && m->num_struct_layouts == 1) {
    int32_t off = glue_struct_layout_field_offset_by_name_c(m, a, 0, field_name, flen);
    if (off >= 0)
      return off;
  }
  if (base_ty <= 0)
    return -1;
  tp = pipeline_arena_type_ptr(a, base_ty);
  if (!tp)
    return -1;
  if (tp->kind == ast_TypeKind_TYPE_PTR && tp->elem_type_ref > 0) {
    base_ty = tp->elem_type_ref;
    tp = pipeline_arena_type_ptr(a, base_ty);
  }
  if (!tp || tp->kind != ast_TypeKind_TYPE_NAMED)
    return -1;
  nlen = tp->name_len;
  if (nlen <= 0 || nlen > 127)
    return -1;
  memcpy(struct_name, tp->name, (size_t)nlen);
  k = glue_struct_layout_index_by_type_name_c(m, struct_name, nlen);
  if (k >= 0) {
    int32_t off = glue_struct_layout_field_offset_by_name_c(m, a, k, field_name, flen);
    if (off >= 0)
      return off;
    return -1;
  }
  /** import Pair 等：struct layout 在 dep 编译单元（stack_promote_cross_ret 的 p.a/p.b）。 */
  if (g_pipeline_asm_emit_dep_pipe) {
    int32_t dep_off;
    dep_off = typeck_get_field_offset_from_layout_deps(m, g_pipeline_asm_emit_dep_pipe, struct_name, nlen, field_name,
                                                       flen);
    if (dep_off >= 0)
      return dep_off;
  }
  return -1;
}

/**
 * FIELD_ACCESS 基址 expr：按 base 的 struct 类型名 + 字段名查 layout 偏移。
 * VAR 走 glue_field_layout_offset_for_var_base_field（形参/let 回落）；其余走 resolved *T/NAMED + dep 池。
 * 命中返回 offset，未命中返回 -1。
 * Link surface: non-static so typeck_soa_fill_field_access_for_asm_emit
 * (typeck_x.o) can call after 8.3.3 R2 migration. PLATFORM: SHARED.
 */
int32_t glue_field_layout_offset_for_base_field(struct ast_ASTArena *a, struct ast_Module *m, int32_t base_ref,
                                                uint8_t *field_name, int32_t flen) {
  int32_t base_ty;
  struct ast_Type *tp;
  uint8_t struct_name[128];
  int32_t nlen;
  int32_t k;
  if (!a || !m || base_ref <= 0 || !field_name || flen <= 0 || flen > 127)
    return -1;
  if (pipeline_expr_kind_ord_at(a, base_ref) == 3)
    return glue_field_layout_offset_for_var_base_field(a, m, base_ref, field_name, flen);
  base_ty = pipeline_expr_resolved_type_ref(a, base_ref);
  if (base_ty <= 0 && m->num_struct_layouts == 1)
    return glue_struct_layout_field_offset_by_name_c(m, a, 0, field_name, flen);
  if (base_ty <= 0)
    return -1;
  tp = pipeline_arena_type_ptr(a, base_ty);
  if (!tp)
    return -1;
  if (tp->kind == ast_TypeKind_TYPE_PTR && tp->elem_type_ref > 0) {
    base_ty = tp->elem_type_ref;
    tp = pipeline_arena_type_ptr(a, base_ty);
  }
  if (!tp || tp->kind != ast_TypeKind_TYPE_NAMED)
    return -1;
  nlen = tp->name_len;
  if (nlen <= 0 || nlen > 127)
    return -1;
  memcpy(struct_name, tp->name, (size_t)nlen);
  k = glue_struct_layout_index_by_type_name_c(m, struct_name, nlen);
  if (k >= 0) {
    int32_t off = glue_struct_layout_field_offset_by_name_c(m, a, k, field_name, flen);
    if (off >= 0)
      return off;
  }
  if (g_pipeline_asm_emit_dep_pipe) {
    int32_t dep_off = typeck_get_field_offset_from_layout_deps(m, g_pipeline_asm_emit_dep_pipe, struct_name, nlen,
                                                               field_name, flen);
    if (dep_off >= 0)
      return dep_off;
  }
  return -1;
}

/**
 * FIELD_ACCESS 有效字节偏移：typed layout → typeck stored；勿全局字段名首匹配（len/cap 误中 Vec_i32）。
 */
int32_t glue_field_access_effective_offset_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                     int32_t fa_ref) {
  return pipeline_expr_field_access_layout_offset(arena, mod, fa_ref);
}

/**
 * FIELD_ACCESS 字节偏移：优先 module struct layout 中字段 offset（strict typeck 未填 field_access_offset 时），
 * 否则回落 expr 上 typeck 写入的 field_access_offset。
 *
 * TYPE_SLICE built-in fat layout (G.7 with pipeline_typeck_field_slice_c): data@0, length@8.
 * PLATFORM: SHARED — both backends; asm uses this for lea+add when typeck offset missing.
 */
int32_t pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  struct ast_Expr *ex;
  int32_t flen;
  uint8_t field_name[128];
  int32_t stored;
  int32_t typed_off;
  if (!a || expr_ref <= 0)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  stored = ex->field_access_offset;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 127)
    return stored;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  /** import 入口无本地 layout：dep 池按字段名查 Pair.a/b 等（cross_ret final_expr）。 */
  if (m && m->num_struct_layouts == 0 && g_pipeline_asm_emit_dep_pipe) {
    int32_t dep_off = glue_dep_layout_field_offset_by_name_c(g_pipeline_asm_emit_dep_pipe, field_name, flen);
    if (dep_off >= 0)
      return dep_off;
  }
  /** *T 形参/局部或具名基址：按 struct 类型查字段；禁全局 len/cap 首匹配误中 Vec_i32（覆盖 col_y）。 */
  if (ex->field_access_base_ref > 0) {
    typed_off = glue_field_layout_offset_for_base_field(a, m, ex->field_access_base_ref, field_name, flen);
    if (typed_off >= 0)
      return typed_off;
    /** Built-in T[] fat pointer — not a named struct layout.
     * Base may be VAR (`sub.length`) or FIELD_ACCESS (`sp.left.length` → left is TYPE_SLICE). */
    {
      int32_t base_ref = ex->field_access_base_ref;
      int32_t base_ty = glue_var_expr_type_ref_with_decl_fallback_c(a, base_ref);
      if (base_ty <= 0)
        base_ty = pipeline_expr_resolved_type_ref(a, base_ref);
      if (base_ty <= 0 && pipeline_expr_kind_ord_at(a, base_ref) == 44)
        base_ty = glue_field_access_field_type_ref_c(a, m, base_ref);
      if (base_ty > 0 && pipeline_type_kind_ord_at(a, base_ty) == GLUE_TYPE_KIND_SLICE) {
        if (flen == 4 && memcmp(field_name, "data", 4) == 0)
          return 0;
        if (flen == 6 && memcmp(field_name, "length", 6) == 0)
          return 8;
      }
    }
  }
  /** typeck layout_deps 已写入 offset 时回落 stored，勿再扫 module 全 layout 按字段名首匹配。 */
  if (stored != 0)
    return stored;
  return 0;
}

/**
 * 按类型 ref 返回 FIELD_ACCESS 加载宽度（bool/u8=1，i32/u32/f32=4，i64/指针=8）。
 * 与 backend.x asm_field_access_load_byte_sz 中 TypeKind 分支一致。
 */
static int32_t glue_field_access_load_bytes_for_type_ref(struct ast_ASTArena *a, int32_t ty_ref) {
  int32_t kind_ord;
  if (!a || ty_ref <= 0 || ty_ref > a->num_types)
    return 8;
  kind_ord = pipeline_type_kind_ord_at(a, ty_ref);
  if (kind_ord == 2 || kind_ord == 1)
    return 1;
  if (kind_ord == 0 || kind_ord == 3 || kind_ord == 13 || kind_ord == 14)
    return 4;
  if (kind_ord == 5 || kind_ord == 4 || kind_ord == 6 || kind_ord == 7 || kind_ord == 15 || kind_ord == 9)
    return 8;
  if (kind_ord == 8)
    return 8;
  return 4;
}

/**
 * resolved_type_ref 缺失或误为聚合/指针时：按 module struct layout + 字段名推断 load 宽度。
 * 修复 strict backend 编 core.option 时 opt.is_some 误 ldr x0（应为 ldrb）导致 option 测试失败。
 */
int32_t pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  struct ast_Expr *ex;
  int32_t tr;
  int32_t base_tr;
  uint8_t struct_name[128];
  int32_t nlen;
  int32_t flen;
  uint8_t field_name[128];
  int32_t k;
  int32_t j;
  int32_t ftr;
  int32_t kind_ord;
  static const uint8_t nm_is_some[7] = { 105, 115, 95, 115, 111, 109, 101 };
  static const uint8_t nm_is_none[7] = { 105, 115, 95, 110, 111, 110, 101 };
  if (!a || expr_ref <= 0)
    return 8;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->field_access_base_ref <= 0)
    return 8;
  flen = ex->field_access_field_len;
  if (flen <= 0 || flen > 127)
    return 8;
  memcpy(field_name, ex->field_access_field_name, (size_t)flen);
  /* 任意 struct layout 中按字段名匹配（base resolved_type_ref 缺失时仍可用，如 core.option 形参 opt）。 */
  if (m) {
    for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
      for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
        int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
        int32_t feq = 1;
        int32_t fi;
        if (fnlen != flen)
          continue;
        for (fi = 0; fi < fnlen; fi++) {
          uint8_t fb[128];
          pipeline_module_struct_layout_field_name_into(m, k, j, fb);
          if (fb[fi] != field_name[fi]) {
            feq = 0;
            break;
          }
        }
        if (!feq)
          continue;
        ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
        return glue_field_access_load_bytes_for_type_ref(a, ftr);
      }
    }
  }
  base_tr = pipeline_expr_resolved_type_ref(a, ex->field_access_base_ref);
  if (base_tr > 0 && pipeline_type_kind_ord_at(a, base_tr) == 8) {
    nlen = pipeline_type_named_name_into(a, base_tr, struct_name);
    if (nlen > 0 && nlen <= 63 && m) {
      for (k = 0; k < (int32_t)m->num_struct_layouts; k++) {
        int32_t ln = pipeline_module_struct_layout_name_len(m, k);
        int32_t eq = 1;
        if (ln != nlen)
          continue;
        for (j = 0; j < nlen; j++) {
          if (pipeline_module_struct_layout_name_byte_at(m, k, j) != struct_name[j]) {
            eq = 0;
            break;
          }
        }
        if (!eq)
          continue;
        for (j = 0; j < pipeline_module_struct_layout_num_fields(m, k); j++) {
          int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, k, j);
          int32_t feq = 1;
          int32_t fi;
          if (fnlen != flen)
            continue;
          for (fi = 0; fi < fnlen; fi++) {
            uint8_t fb[128];
            pipeline_module_struct_layout_field_name_into(m, k, j, fb);
            if (fb[fi] != field_name[fi]) {
              feq = 0;
              break;
            }
          }
          if (!feq)
            continue;
          ftr = pipeline_module_struct_layout_field_type_ref(m, k, j);
          return glue_field_access_load_bytes_for_type_ref(a, ftr);
        }
      }
    }
  }
  tr = pipeline_expr_resolved_type_ref(a, expr_ref);
  if (tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(a, tr);
    if (kind_ord != 8 && kind_ord != 10 && kind_ord != 11 && kind_ord != 12)
      return glue_field_access_load_bytes_for_type_ref(a, tr);
  }
  if (flen == 7 && memcmp(field_name, nm_is_some, 7) == 0)
    return 1;
  if (flen == 7 && memcmp(field_name, nm_is_none, 7) == 0)
    return 1;
  return 8;
}

/* wave1050 G.7 fold: glue_struct_layout_field_offset_by_name_c migrated here
 * from pipeline_glue.c (definition was at glue.c:3698). Same-TU #include at
 * glue.c:2419 makes the forward decl at L708 above visible to all 4 callsites
 * in this leaf (L811/L832/L866/L884 — all before this definition). glue.c has
 * zero self-callsites — pure leaf consumed only by field_access.c.
 *
 * glue_struct_layout_compute_field_offset_c (called by the body) is defined
 * in pipeline_asm_emit_struct_lit.c (wave1044 fold; struct_lit.c #include at
 * glue.c:2095 < field_access.c #include at glue.c:2419, so visible here). */

/**
 * Look up a struct field's dynamic byte offset by field name within a layout.
 *
 * Why: §11.1 struct layout registry — the authoritative name→offset lookup
 * consumed by field_access effective offset (4 callsites above: L811 single-
 * layout fallback; L832 named-layout; L866 single-layout fallback return;
 * L884 named-layout). Walks layout li fields comparing names byte-by-byte;
 * on match returns the cumulative offset computed by
 * glue_struct_layout_compute_field_offset_c (handles packed / aligned /
 * mixed-size fields). Returns -1 on any miss so callers fall back to the
 * fast-path offset table or default 8-byte stride.
 *
 * Invariant: returns -1 for invalid module/arena/li/name or flen<=0; returns
 * -1 when no field name matches; otherwise returns the cumulative byte offset
 * of the matched field within layout li.
 *
 * Asm/Perf: O(nf * flen) — linear scan over fields with byte-by-byte name
 * comparison. Bounded by struct field count (typically small).
 *
 * PLATFORM: SHARED — pure layout registry query; arch-agnostic.
 */
static int32_t glue_struct_layout_field_offset_by_name_c(struct ast_Module *m, struct ast_ASTArena *a, int32_t li,
                                                         uint8_t *field_name, int32_t flen) {
  int32_t j;
  if (!m || !a || li < 0 || !field_name || flen <= 0)
    return -1;
  for (j = 0; j < pipeline_module_struct_layout_num_fields(m, li); j++) {
    int32_t fnlen = pipeline_module_struct_layout_field_name_len(m, li, j);
    int32_t feq = 1;
    int32_t fi;
    if (fnlen != flen)
      continue;
    for (fi = 0; fi < fnlen; fi++) {
      uint8_t fb[128];
      pipeline_module_struct_layout_field_name_into(m, li, j, fb);
      if (fb[fi] != field_name[fi]) {
        feq = 0;
        break;
      }
    }
    if (!feq)
      continue;
    return glue_struct_layout_compute_field_offset_c(m, a, li, j);
  }
  return -1;
}

/**
 * Enum variant name prefix match: parser occasionally emits field_len with +1
 * trailing zero; flen >= expected length and prefix match → hit.
 *
 * Why: pipeline_expr_enum_namespace_field_tag resolves FIELD_ACCESS on enum
 * namespace (e.g. `ExprKind.EXPR_LIT`) by comparing the field name against
 * known enum variant strings. The parser may include a trailing NUL byte in
 * the field buffer, so exact-length comparison would miss valid matches.
 * This helper centralizes the lenient prefix match so the caller does not
 * repeat strlen/memcmp pairs for every variant check.
 *
 * Invariant: returns 0 for NULL field_buf/expect or flen <= 0; returns 1 iff
 * flen >= strlen(expect) and the first strlen(expect) bytes match exactly.
 *
 * Asm/Perf: O(elen) — one strlen + one memcmp. Cold path — called per enum
 * variant probe in pipeline_expr_enum_namespace_field_tag (glue.c:4402+).
 *
 * PLATFORM: SHARED — string comparison is platform-independent.
 *
 * wave1074 G.7: migrated from glue.c:4359 (body 8 LOC). Static (non-extern):
 * same-TU — field_access.c #include at L2419 < def EOF < all callsites
 * glue.c:4402+. Dependencies: strlen / memcmp (libc, global).
 */
static int glue_enum_field_name_equal(const uint8_t *field_buf, int32_t flen, const char *expect) {
  int32_t elen;
  if (!field_buf || !expect || flen <= 0)
    return 0;
  elen = (int32_t)strlen(expect);
  if (flen < elen)
    return 0;
  return memcmp(field_buf, expect, (size_t)elen) == 0;
}

/* wave1179 G.7: field_access enum/soa setter cluster (4 fns) migrated from
 * pipeline_glue.c L3155-3184 + L3203-3206 + L3217-3309. Colocated with
 * FIELD_ACCESS emit domain — all read/write ast_Expr field_access_* struct
 * fields for typeck.x and asm emit.
 *
 * Dependencies:
 * - glue_arena_expr_at_ref (static fwd decl at L712 above; defined in glue.c
 *   L2340 < field_access.c #include L2111 — wait, L2340 > L2111, so the fwd
 *   decl at L712 is required; resolved at link time via same-TU).
 * - pipeline_expr_kind_ord_at / pipeline_expr_var_name_len /
 *   pipeline_expr_var_name_into / pipeline_expr_field_access_name_len /
 *   pipeline_expr_field_access_name_into (fwd decls at L1554-1565 in glue.c
 *   < field_access.c #include L2111).
 * - pipeline_token_kind_variant_tag (extern fwd decl glue.c L1773).
 * - pipeline_expr_enum_field_tag_via_module (extern fwd decl glue.c L3208,
 *   removed and migrated below in this same wave).
 * - glue_enum_field_name_equal (static at L1169 above).
 * - g_pipeline_asm_emit_module (static global glue.c L132 — but accessed via
 *   pipeline_expr_enum_field_tag_via_module which is migrated below).
 *
 * No glue.c callsites for any of these 4 fns (sole callers are typeck_gen.c
 * / codegen_gen.c seeds via extern).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Write expr.field_access_is_enum_variant and enum_variant_tag.
 * Why: typeck_coerce_init_expr_to_decl X-emit must write these flags via C
 *      helper to avoid X Expr struct field assignment typeck failures.
 * Contract: no-op when arena null, expr_ref out of range, or expr ptr null.
 */
void pipeline_expr_set_field_access_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t tag) {
  struct ast_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->field_access_is_enum_variant = 1;
  ex->enum_variant_tag = tag;
}

/** DOD-S1: write FIELD_ACCESS SoA stride (paired with field_access_offset column base). */
void pipeline_expr_set_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref, int32_t stride) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (ex)
    ex->field_access_soa_stride = stride;
}

/** Read expr.field_access_is_enum_variant flag (1 if set, 0 otherwise). */
int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_is_enum_variant : 0;
}

/**
 * Look up enum variant tag for FIELD_ACCESS on enum namespace base
 * (e.g. ExprKind.EXPR_LIT, TypeKind.TYPE_I32, TokenKind.TOKEN_EOF).
 * Why: typeck/asm-emit FIELD_ACCESS on enum-typed base VAR must resolve the
 *      variant tag at compile time; this scans ExprKind/TypeKind/TokenKind
 *      built-in tables + module enum sidecar via pipeline_expr_enum_field_tag_via_module.
 * Contract: returns -1 when arena null, expr_ref out of range, expr kind != 44
 *           (FIELD_ACCESS), base ref invalid, base kind != 3 (VAR), or no
 *           matching enum variant found.
 * Dependencies: pipeline_expr_kind_ord_at + pipeline_expr_var_name_len/into
 *               + pipeline_expr_field_access_name_len/into + glue_enum_field_name_equal
 *               + pipeline_token_kind_variant_tag + pipeline_expr_enum_field_tag_via_module.
 */
int32_t pipeline_expr_enum_namespace_field_tag(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  uint8_t base_buf[32];
  uint8_t field_buf[128];
  int32_t blen, flen;
  if (!a || expr_ref <= 0 || pipeline_expr_kind_ord_at(a, expr_ref) != 44)
    return -1;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->field_access_base_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(a, ex->field_access_base_ref) != 3)
    return -1;
  blen = pipeline_expr_var_name_len(a, ex->field_access_base_ref);
  if (blen <= 0 || blen > 31)
    return -1;
  pipeline_expr_var_name_into(a, ex->field_access_base_ref, base_buf);
  flen = pipeline_expr_field_access_name_len(a, expr_ref);
  if (flen <= 0 || flen > 127)
    return -1;
  pipeline_expr_field_access_name_into(a, expr_ref, field_buf);
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE")) {
    fprintf(stderr, "xlang: enum_ns_tag base_len=%d field_len=%d mod=%p base='", (int)blen, (int)flen,
            (void *)g_pipeline_asm_emit_module);
    for (int32_t di = 0; di < blen && di < 31; di++)
      fputc((char)base_buf[di], stderr);
    fprintf(stderr, "' field='");
    for (int32_t di = 0; di < flen && di < 63; di++)
      fputc((char)field_buf[di], stderr);
    fprintf(stderr, "'\n");
  }
  if (blen == 8 && memcmp(base_buf, "ExprKind", 8) == 0) {
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_LIT"))
      return 0;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_FIELD_ACCESS"))
      return 44;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_CALL"))
      return 48;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_VAR"))
      return 3;
    if (glue_enum_field_name_equal(field_buf, flen, "EXPR_BLOCK"))
      return 26;
  }
  if (blen == 8 && memcmp(base_buf, "TypeKind", 8) == 0) {
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_I32"))
      return 0;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_BOOL"))
      return 1;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_U8"))
      return 2;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_U32"))
      return 3;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_U64"))
      return 4;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_I64"))
      return 5;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_USIZE"))
      return 6;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_ISIZE"))
      return 7;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_NAMED"))
      return 8;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_PTR"))
      return 9;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_ARRAY"))
      return 10;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_SLICE"))
      return 11;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_VECTOR"))
      return 12;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_F32"))
      return 13;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_F64"))
      return 14;
    if (glue_enum_field_name_equal(field_buf, flen, "TYPE_VOID"))
      return 15;
  }
  /** import token.x TokenKind: fast path via pipeline_token_kind_variant_tag; here only module sidecar fallback. */
  if (blen == 9 && memcmp(base_buf, "TokenKind", 9) == 0) {
    int32_t tk = pipeline_token_kind_variant_tag(field_buf, flen);
    if (tk >= 0)
      return tk;
  }
  {
    int32_t mod_tag = pipeline_expr_enum_field_tag_via_module(base_buf, blen, field_buf, flen);
    if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
      fprintf(stderr, "xlang: enum_ns_tag mod_tag=%d\n", (int)mod_tag);
    if (mod_tag >= 0)
      return mod_tag;
  }
  return -1;
}

/* wave1179 G.7: pipeline_expr_enum_field_tag_via_module migrated from
 * pipeline_glue.c L3419-3425. Colocated with FIELD_ACCESS emit domain —
 * called only by pipeline_expr_enum_namespace_field_tag above (now in same
 * file). Reads g_pipeline_asm_emit_module to look up enum variant tag via
 * module enum sidecar.
 *
 * Dependencies: g_pipeline_asm_emit_module (static global in glue.c L132 <
 *   field_access.c #include L2111 — visible via same-TU) +
 *   pipeline_module_enum_variant_tag_for_names (fwd decl glue.c L129).
 * No glue.c callsites other than the forward decl at L3208 (also removed).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/** Look up enum variant tag by module enum sidecar (e.g. TokenKind.TOKEN_EOF); -1 if not found. */
int32_t pipeline_expr_enum_field_tag_via_module(uint8_t *enum_name, int32_t enum_len, uint8_t *variant_name,
                                                int32_t variant_len) {
  if (!g_pipeline_asm_emit_module)
    return -1;
  return pipeline_module_enum_variant_tag_for_names(g_pipeline_asm_emit_module, enum_name, enum_len, variant_name,
                                                   variant_len);
}
