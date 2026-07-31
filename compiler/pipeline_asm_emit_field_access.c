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
 * pipeline_expr_field_access_layout_offset) remain in pipeline_glue.c
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
 */

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
static int32_t pipeline_asm_emit_field_access_elf_fast_c(struct ast_ASTArena *arena,
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
      (void)pipeline_typeck_field_soa_index_c(g_pipeline_asm_emit_module, arena, expr_ref, fa_base2);
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
