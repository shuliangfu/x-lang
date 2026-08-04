/**
 * pipeline_typeck_field_access.c — EXPR_FIELD_ACCESS 类型检查的 C glue（从 typeck.x 机械移植）。
 *
 * 由 pipeline_glue.c #include 并入同一翻译单元；不单独编译。
 * 子逻辑导出 pipeline_typeck_field_*_c 供 typeck.x EMIT_HEAVY 编排；仍保留 pipeline_typeck_check_expr_field_access_c（strict_glue）。
 * 依赖 typeck_x_no_layout_partial 导出的 typeck_* helper 与 pipeline_* 池访问器。
 */

/* typeck_x_no_layout_partial 符号（X 经 C gen 带 typeck_ 前缀）；find_or_alloc_ptr 见 typeck_x_link_alias.c。 */
extern int32_t typeck_name_equal(uint8_t *a, int32_t a_len, uint8_t *b, int32_t b_len);
extern int32_t typeck_find_or_alloc_named_type_ref(struct ast_ASTArena *arena, uint8_t *name, int32_t name_len);
extern int32_t typeck_ensure_i32_type_ref(struct ast_ASTArena *arena);
extern int32_t typeck_ensure_u8_type_ref(struct ast_ASTArena *arena);
extern int32_t typeck_ensure_usize_type_ref(struct ast_ASTArena *arena);
extern int32_t typeck_ensure_array_type_ref_named_elem(struct ast_ASTArena *arena, uint8_t *elem_nm,
                                                       int32_t elem_nm_len, int32_t array_size);
extern int32_t typeck_find_or_alloc_array_type_ref(struct ast_ASTArena *arena, int32_t elem_ref, int32_t array_size);
extern int32_t find_or_alloc_ptr_type_ref(struct ast_ASTArena *arena, int32_t elem_ref);
extern int32_t typeck_get_field_offset_from_layout_deps(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                        uint8_t *type_name, int32_t type_name_len, uint8_t *field_name,
                                                        int32_t field_name_len);
extern int32_t typeck_get_field_type_ref_from_layout_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                            struct ast_PipelineDepCtx *ctx, uint8_t *type_name,
                                                            int32_t type_name_len, uint8_t *field_name,
                                                            int32_t field_name_len);
extern int32_t typeck_inline_u8_64_array_field_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                        int32_t field_name_len);
extern int32_t typeck_expr_inline_array_field_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                       int32_t field_name_len);
extern int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t typeck_top_level_let_name_equal(struct ast_Module *module, int32_t tl_idx, uint8_t *name,
                                               int32_t name_len);
extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);
extern int32_t pipeline_expr_line_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_col_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_module_import_binding_name_len(struct ast_Module *module, int32_t idx);
extern uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *module, int32_t idx, int32_t off);
extern int32_t pipeline_typeck_field_soa_index_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                int32_t base_ref);

/**
 * Dep top-level const name match.
 * R2 (8.3.3): body migrated to typeck.x as typeck_dep_top_level_const_match.
 * Zero business logic — thin surface for bare-import-const diagnostics.
 * PLATFORM: SHARED.
 */
int32_t typeck_dep_top_level_const_match(struct ast_Module *dep_mod, uint8_t *name, int32_t name_len,
                                         int32_t *out_type_ref);

static int32_t pipeline_typeck_dep_top_level_const_match(struct ast_Module *dep_mod, uint8_t *name, int32_t name_len,
                                                         int32_t *out_type_ref) {
  return typeck_dep_top_level_const_match(dep_mod, name, name_len, out_type_ref);
}

/** 写出含 const 的 import binding 名，供裸名 const 报错提示。 */
static int32_t pipeline_typeck_import_const_binding_hint(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                         uint8_t *const_name, int32_t const_name_len, uint8_t *bind_out,
                                                         int32_t bind_cap) {
  int32_t di;
  int32_t nd;
  int32_t tr;
  if (!module || !ctx || const_name_len <= 0 || !bind_out || bind_cap <= 0)
    return 0;
  bind_out[0] = '\0';
  nd = pipeline_dep_ctx_ndep(ctx);
  for (di = 0; di < nd && di < module->num_imports; di++) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
    if (!dm || !pipeline_typeck_dep_top_level_const_match(dm, const_name, const_name_len, &tr))
      continue;
    {
      int32_t bl = pipeline_module_import_binding_name_len(module, di);
      int32_t k;
      if (bl > 0 && bl < bind_cap) {
        for (k = 0; k < bl; k++)
          bind_out[k] = pipeline_module_import_binding_name_byte_at(module, di, k);
        bind_out[bl] = '\0';
        return 1;
      }
    }
  }
  return 0;
}

/**
 * 裸名访问 dep 模块顶层 const 时报错（须 binding.CONST）；返回 1 表示已报错。
 */
int32_t pipeline_typeck_reject_bare_import_const_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   int32_t expr_ref, struct ast_PipelineDepCtx *ctx, uint8_t *vbuf,
                                                   int32_t vnlen) {
  int32_t di;
  int32_t nd;
  int32_t tr;
  int32_t line;
  int32_t col;
  uint8_t hint[128];
  if (!module || !arena || !ctx || vnlen <= 0 || !vbuf)
    return 0;
  nd = pipeline_dep_ctx_ndep(ctx);
  for (di = 0; di < nd; di++) {
    struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
    if (!dm || !pipeline_typeck_dep_top_level_const_match(dm, vbuf, vnlen, &tr))
      continue;
    line = pipeline_expr_line_at(arena, expr_ref);
    col = pipeline_expr_col_at(arena, expr_ref);
    hint[0] = '\0';
    if (pipeline_typeck_import_const_binding_hint(module, ctx, vbuf, vnlen, hint, (int32_t)sizeof(hint))) {
      lsp_diag_report_typeck((int)line, (int)col, "import constant '%.*s' must be qualified; use %s.%.*s",
                             (int)vnlen, vbuf, hint, (int)vnlen, vbuf);
    } else {
      lsp_diag_report_typeck((int)line, (int)col, "import constant '%.*s' must be qualified as binding.%.*s",
                             (int)vnlen, vbuf, (int)vnlen, vbuf);
    }
    return 1;
  }
  return 0;
}

extern int32_t typeck_expr_field_access_fallback_scalar_type_ref(struct ast_ASTArena *arena, uint8_t *field_name,
                                                                 int32_t field_name_len);
extern int32_t typeck_field_access_lexer_wrapper_fallback(struct ast_ASTArena *arena, int32_t base_type_ref,
                                                          uint8_t *field_name, int32_t field_name_len);
/* wave465: module concrete-type probe for type-param field ambient fill */
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module *module, int32_t idx);
extern void pipeline_module_struct_layout_name_into(struct ast_Module *module, int32_t idx, uint8_t *out);
extern int32_t pipeline_module_enum_name_len(struct ast_Module *module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module *module, int32_t idx, int32_t off);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t type_ref, uint8_t *out);
extern void driver_diagnostic_typeck_ptr_field(int32_t bt_kind, int32_t inner_kind, int32_t inner_nlen,
                                               int32_t base_resolved_ref, int32_t num_struct_layouts);

/** 递归检查子表达式；定义于 pipeline_glue.c（本文件在其之前 include）。 */
extern int32_t pipeline_typeck_check_expr_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                            int32_t return_type_ref, struct ast_PipelineDepCtx *ctx);

/**
 * EXPR_FIELD_ACCESS: prebind untyped VAR base as TYPE_NAMED of same spelling.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_prebind.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_prebind(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                          struct ast_PipelineDepCtx *ctx);

void pipeline_typeck_field_prebind_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                    struct ast_PipelineDepCtx *ctx) {
  typeck_field_prebind(module, arena, expr_ref, ctx);
}

/**
 * EXPR_FIELD_ACCESS: *ASTArena / *Module known-field special-case.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_known_ptr.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 * @return 1 = matched and stamped; 0 = continue field fallbacks.
 */
int32_t typeck_field_known_ptr(struct ast_Module *module, struct ast_ASTArena *arena,
                               int32_t expr_ref, int32_t base_ref,
                               int32_t num_struct_layouts);

int32_t pipeline_typeck_field_known_ptr_types_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                       int32_t expr_ref, int32_t base_ref,
                                                       int32_t num_struct_layouts) {
  return typeck_field_known_ptr(module, arena, expr_ref, base_ref, num_struct_layouts);
}

/**
 * EXPR_FIELD_ACCESS: named-type layout / enum / TypeKind / TokenKind.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_layout_named.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 * @return 2 = user enum done (caller returns 0); 0 = continue field fallbacks.
 */
int32_t typeck_field_layout_named(struct ast_Module *module, struct ast_ASTArena *arena,
                                  int32_t expr_ref, int32_t base_ref,
                                  struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_field_layout_named_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t expr_ref, int32_t base_ref,
                                                    struct ast_PipelineDepCtx *ctx) {
  return typeck_field_layout_named(module, arena, expr_ref, base_ref, ctx);
}

/**
 * EXPR_FIELD_ACCESS：T[] 的 .length（usize）与 .data（*elem for any T）.
 *
 * Fat layout (PLATFORM: SHARED / SysV dual-GP home): { .data @ +0, .length @ +8 }.
 * Asm stack homes register byte0 at slot_off; high half at slot_off-8 (see
 * asm_local_slot_reg_offset / param dual-home). Emit must use field_access_offset so
 * lea base + add offset hits the correct half — previously offset stayed 0 and
 * s.length loaded .data (tests/slice/data_field.x exit 2).
 *
 * G.7 complete: .data must resolve to TYPE_PTR(elem) for i32/u8/u64/… — not only U8.
 * Old U8-only gate left s.data untyped for i32[] → INDEX `s.data[i]` T001 on Ubuntu
 * (formal core/slice/mod.x get_i32 / length.x co-emit typeck). mac often soft-pathed.
 *
 * wave346 Cap residual pure: TYPE_ARRAY / TYPE_VECTOR `.length` is also usize (compile-time
 * N). Prior: only TYPE_SLICE → fixed `a.length` never stamped; host C emitted `a.length`
 * on a C array (illegal); freestanding loaded slot[0] as length (run=10 not 3).
 * G.7: extend this authority — no second field_array helper. Emit paths use array_size_at.
 * PLATFORM: SHARED — typeck; host+fs emit co-land same wave.
 */
/**
 * EXPR_FIELD_ACCESS: slice / fixed-array / vector built-in field typing.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_slice.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_slice(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref);

void pipeline_typeck_field_slice_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  typeck_field_slice(arena, expr_ref, base_ref);
}

/**
 * EXPR_FIELD_ACCESS: name fallback (CodegenOutBuf / inline array / scalar).
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_name_fallback.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_name_fallback(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref);

void pipeline_typeck_field_name_fallback_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref) {
  typeck_field_name_fallback(arena, expr_ref, base_ref);
}

/**
 * EXPR_FIELD_ACCESS: LexerResult / formal-type field-name fallback.
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_lexer_fallback.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 */
void typeck_field_lexer_fallback(struct ast_Module *module, struct ast_ASTArena *arena,
                                 int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx *ctx);

void pipeline_typeck_field_lexer_fallback_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t base_ref, struct ast_PipelineDepCtx *ctx) {
  typeck_field_lexer_fallback(module, arena, expr_ref, base_ref, ctx);
}

/**
 * typeck.x::typeck_check_expr_field_access 的 C 委托：prebind → check base → known_ptr/layout/slice/fallback。
 */
/**
 * EXPR_FIELD_ACCESS: import binding resolve (dep function / const / enum).
 * R2 (8.3.3): body migrated to typeck.x as typeck_field_import_binding.
 * Zero business logic — thin surface for field_access orchestration.
 * PLATFORM: SHARED.
 * @return 1 = matched and stamped; 0 = continue field typeck.
 */
int32_t typeck_field_import_binding(struct ast_Module *module, struct ast_ASTArena *arena,
                                    int32_t expr_ref, int32_t base_ref,
                                    struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_field_import_binding_resolve_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                        int32_t expr_ref, int32_t base_ref,
                                                        struct ast_PipelineDepCtx *ctx) {
  return typeck_field_import_binding(module, arena, expr_ref, base_ref, ctx);
}

/**
 * wave454: reverse-infer the owner type of a FIELD_ACCESS from the field name
 * (and optional outer expected field type) among module struct layouts.
 *
 * Why: the ambient expected type of `base.field` is the *field result* type
 * (e.g. i32 for `.v`), not the base type. Passing that expected into base
 * typeck made wave453 bare ret-only generic inference pin T=i32 for
 * `return mk_default().v`, so the CALL typed as i32 and `.v` became `?`.
 *
 * When exactly one module struct owns field `name` (and, when outer_expected
 * is a concrete type, that field's type equals outer_expected), return the
 * named type_ref for that struct so a bare generic CALL base can use it as
 * expected_ret (`mk_default()` → A). Zero or multiple hits → 0 (fail-closed;
 * caller still checks base without a wrong ambient).
 *
 * @param module module with struct layouts
 * @param arena type/name pool
 * @param expr_ref FIELD_ACCESS expr
 * @param outer_expected ambient expected of the field expression (0 if none)
 * @return unique owner TYPE_NAMED ref, or 0
 * PLATFORM: SHARED — typeck; rebuild pipeline_glue_standalone.o after edit.
 */
static int32_t pipeline_typeck_field_reverse_infer_base_type_c(struct ast_Module *module,
                                                              struct ast_ASTArena *arena,
                                                              int32_t expr_ref,
                                                              int32_t outer_expected) {
  uint8_t fn_buf[128] /* wave577 Cap name into */;
  int32_t fl;
  int32_t nsl;
  int32_t k;
  int32_t hits;
  int32_t unique_ty;

  if (!module || !arena || expr_ref <= 0)
    return 0;
  fl = pipeline_expr_field_access_name_len(arena, expr_ref);
  if (fl <= 0 || fl > 127)
    return 0;
  memset(fn_buf, 0, sizeof(fn_buf));
  pipeline_expr_field_access_name_into(arena, expr_ref, &fn_buf[0]);
  nsl = module->num_struct_layouts;
  if (nsl <= 0)
    return 0;
  /* Field-name uniqueness among module layouts (outer_expected reserved). */
  (void)outer_expected;
  hits = 0;
  unique_ty = 0;
  for (k = 0; k < nsl; k++) {
    int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
    int32_t j;
    for (j = 0; j < nf; j++) {
      int32_t fjl;
      uint8_t fjn[128] /* wave577 Cap name into */;
      int32_t bi;
      int32_t match;
      uint8_t lnm[128] /* wave577 Cap name into */;
      int32_t lnl;
      int32_t nty;

      fjl = pipeline_module_struct_layout_field_name_len(module, k, j);
      if (fjl != fl)
        continue;
      memset(fjn, 0, sizeof(fjn));
      pipeline_module_struct_layout_field_name_into(module, k, j, &fjn[0]);
      match = 1;
      for (bi = 0; bi < fl; bi++) {
        if (fjn[bi] != fn_buf[bi]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
      lnl = pipeline_module_struct_layout_name_len(module, k);
      if (lnl <= 0 || lnl > 127)
        continue;
      memset(lnm, 0, sizeof(lnm));
      pipeline_module_struct_layout_name_into(module, k, &lnm[0]);
      nty = typeck_find_or_alloc_named_type_ref(arena, &lnm[0], lnl);
      if (nty <= 0)
        continue;
      /* Dedup same owner type (multiple fields same name should not happen). */
      if (hits == 1 && unique_ty == nty)
        continue;
      hits++;
      unique_ty = nty;
      if (hits > 1)
        return 0; /* ambiguous owner — leave bare CALL unconstrained */
    }
  }
  return hits == 1 ? unique_ty : 0;
}

/**
 * wave465: TYPE_NAMED is a module concrete type (struct layout or enum) iff a
 * matching name exists. Otherwise it is treated as an unconstrained type
 * parameter (e.g. field `v: T` on `struct Wrap<T>`).
 * PLATFORM: SHARED — used only to decide ambient fill of field results.
 */
int32_t pipeline_typeck_named_is_module_concrete_c(struct ast_Module *module,
                                                          struct ast_PipelineDepCtx *ctx,
                                                          uint8_t *name,
                                                          int32_t name_len) {
  int32_t k;
  int32_t nsl;
  int32_t ne;
  if (!module || !name || name_len <= 0 || name_len > 127)
    return 0;
  nsl = module->num_struct_layouts;
  for (k = 0; k < nsl; k++) {
    int32_t sl = pipeline_module_struct_layout_name_len(module, k);
    uint8_t snm[128] /* wave577 Cap name into */;
    if (sl != name_len)
      continue;
    memset(snm, 0, sizeof(snm));
    pipeline_module_struct_layout_name_into(module, k, &snm[0]);
    if (typeck_name_equal(&snm[0], sl, name, name_len))
      return 1;
  }
  ne = module->num_module_enums;
  for (k = 0; k < ne; k++) {
    int32_t el = pipeline_module_enum_name_len(module, k);
    int32_t bi;
    if (el != name_len)
      continue;
    for (bi = 0; bi < el; bi++) {
      if (pipeline_module_enum_name_byte_at(module, k, bi) != name[bi])
        break;
    }
    if (bi == el)
      return 1;
  }
  /*
   * wave1220 P4: also check dependency modules for concrete types.
   * Root cause: TokenKind / Token / Lexer are defined in the `token` / `lexer`
   * dep modules, not in the current module. Without this dep walk,
   * pipeline_typeck_field_apply_ambient_for_type_param_c mistook cross-module
   * enum types (TokenKind) for free type params and overwrote their resolved
   * type with the ambient (e.g., bool from an assignment target), causing
   * "comparison operands have incompatible types" for r.tok.kind == TokenKind.X.
   * G.7: single fix point at the concrete-type check; ambient + mono both benefit.
   * PLATFORM: SHARED — no platform branch.
   */
  if (ctx) {
    int32_t nd = pipeline_dep_ctx_ndep(ctx);
    int32_t di;
    for (di = 0; di < nd; di++) {
      struct ast_Module *dm = pipeline_dep_ctx_module_at(ctx, di);
      if (!dm || dm == module)
        continue;
      nsl = dm->num_struct_layouts;
      for (k = 0; k < nsl; k++) {
        int32_t sl = pipeline_module_struct_layout_name_len(dm, k);
        uint8_t snm[128] /* wave577 Cap name into */;
        if (sl != name_len)
          continue;
        memset(snm, 0, sizeof(snm));
        pipeline_module_struct_layout_name_into(dm, k, &snm[0]);
        if (typeck_name_equal(&snm[0], sl, name, name_len))
          return 1;
      }
      ne = dm->num_module_enums;
      for (k = 0; k < ne; k++) {
        int32_t el = pipeline_module_enum_name_len(dm, k);
        int32_t bi;
        if (el != name_len)
          continue;
        for (bi = 0; bi < el; bi++) {
          if (pipeline_module_enum_name_byte_at(dm, k, bi) != name[bi])
            break;
        }
        if (bi == el)
          return 1;
      }
    }
  }
  return 0;
}

/**
 * wave465 Cap residual pure: after layout/fallback, if the field result is still
 * a TYPE_NAMED type-param (name not a module concrete struct/enum) and ambient
 * expected is present, stamp ambient onto the field access.
 *
 * wave472 L4: do NOT stamp ambient when the field type is still null/unknown.
 * Null meant layout did not resolve (enum fields / missing type_ref). Stamping
 * ambient onto null rewrote assign LHS with function return (expected S/?) and
 * polluted dual-overload scoring. Type-param fields keep TYPE_NAMED `T` in
 * layout (not null), so Wrap.v still fills. PLATFORM: SHARED.
 */
static void pipeline_typeck_field_apply_ambient_for_type_param_c(struct ast_Module *module,
                                                                struct ast_ASTArena *arena,
                                                                int32_t expr_ref,
                                                                int32_t ambient_ty,
                                                                struct ast_PipelineDepCtx *ctx) {
  int32_t got_ty;
  int32_t use_ambient;
  uint8_t gnm[128] /* wave577 Cap name into */;
  int32_t gnl;

  if (!module || !arena || expr_ref <= 0)
    return;
  if (ambient_ty <= 0 || ambient_ty > arena->num_types)
    return;
  got_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  use_ambient = 0;
  /* wave472: null/unknown field type → leave unresolved; never invent ambient. */
  if (ast_ref_is_null(got_ty) || got_ty <= 0 || got_ty > arena->num_types) {
    return;
  } else if (pipeline_type_kind_ord_at(arena, got_ty) == (int32_t)ast_TypeKind_TYPE_NAMED) {
    memset(gnm, 0, sizeof(gnm));
    gnl = pipeline_type_named_name_into(arena, got_ty, &gnm[0]);
    /* wave587 Cap residual: TYPE_NAMED content ≤127 (gnm[128]).
     * Prior gnl<=63 skipped long concrete names → ambient stamped over real type. */
    if (gnl > 0 && gnl <= 127 && !pipeline_typeck_named_is_module_concrete_c(module, ctx, &gnm[0], gnl))
      use_ambient = 1;
  }
  if (use_ambient)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, ambient_ty);
}

/**
 * wave466/467 Cap residual pure: generic struct mono for type-param fields.
 *
 * When the base type is TYPE_NAMED with type-position args (`Wrap<i32>` /
 * `Pair<A,B>`) and the field result is still an unconstrained TYPE_NAMED
 * type-param (`v: T` / `b: U` from layout), map to the matching type arg:
 *   - wave467: map field type name → layout type-param slot → type_arg[slot]
 *   - wave466: slot0 via elem_type_ref when no type-param registry
 * Prefer this over ambient so `take(w.v)` / return without expected still resolve.
 *
 * wave682 Cap residual: exported for STRUCT_LIT field-init coerce (layout still
 * stores free T/U; expected `Wrap<i32>` / `Pair<i32,i32>` supplies mono args).
 * G.7 single authority — field access stamp + struct-lit coerce both call this.
 * PLATFORM: SHARED.
 */
extern int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_type_params_at(struct ast_Module *m, int32_t li);
extern int32_t pipeline_module_struct_layout_type_param_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_type_param_name_into(struct ast_Module *m, int32_t li, int32_t j,
                                                              uint8_t *out64);

/**
 * Resolve a free type-param field type against a monomorphized base type.
 *
 * @param module Module — layout + type-param registry
 * @param arena ASTArena — type pool / type-arg sidecar
 * @param field_ty type_ref of layout field (often free TYPE_NAMED T/U)
 * @param base_ty type_ref of base (`Wrap<i32>`, `*Wrap<i32>`, …)
 * @return mono concrete type_ref, or 0 if no substitution applies
 * PLATFORM: SHARED — G.7 mono field authority (wave466/467/682).
 */
int32_t pipeline_typeck_mono_field_type_from_base_c(struct ast_Module *module,
                                                   struct ast_ASTArena *arena,
                                                   int32_t field_ty,
                                                   int32_t base_ty) {
  int32_t mono_ty;
  int32_t bt_kind;
  uint8_t gnm[128] /* wave577 Cap name into */;
  int32_t gnl;
  uint8_t bnm[128] /* wave577 Cap name into */;
  int32_t bnl;
  int32_t sk;
  int32_t tp_slot;

  if (!module || !arena)
    return 0;
  if (field_ty <= 0 || field_ty > arena->num_types)
    return 0;
  if (base_ty <= 0 || base_ty > arena->num_types)
    return 0;
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
    int32_t elem = pipeline_type_elem_ref_at(arena, base_ty);
    if (elem > 0 && elem <= arena->num_types
        && pipeline_type_kind_ord_at(arena, elem) == (int32_t)ast_TypeKind_TYPE_NAMED)
      base_ty = elem;
    else
      return 0;
  } else if (bt_kind != (int32_t)ast_TypeKind_TYPE_NAMED) {
    return 0;
  }
  if (pipeline_type_kind_ord_at(arena, field_ty) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  memset(gnm, 0, sizeof(gnm));
  gnl = pipeline_type_named_name_into(arena, field_ty, &gnm[0]);
  if (gnl <= 0 || gnl > 127)
    return 0;
  if (pipeline_typeck_named_is_module_concrete_c(module, NULL, &gnm[0], gnl))
    return 0;
  /* Map field type name → type-param slot on base layout name. */
  memset(bnm, 0, sizeof(bnm));
  bnl = pipeline_type_named_name_into(arena, base_ty, &bnm[0]);
  tp_slot = 0;
  if (bnl > 0) {
    for (sk = 0; sk < module->num_struct_layouts; sk++) {
      int32_t sl = pipeline_module_struct_layout_name_len(module, sk);
      uint8_t snm[128] /* wave577 Cap name into */;
      int32_t bi;
      int32_t match;
      int32_t ntp;
      int32_t tj;
      if (sl != bnl)
        continue;
      memset(snm, 0, sizeof(snm));
      pipeline_module_struct_layout_name_into(module, sk, snm);
      match = 1;
      for (bi = 0; bi < bnl; bi++) {
        if (snm[bi] != bnm[bi]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
      ntp = pipeline_module_struct_layout_num_type_params_at(module, sk);
      if (ntp > 0) {
        tp_slot = -1;
        for (tj = 0; tj < ntp; tj++) {
          int32_t tpl = pipeline_module_struct_layout_type_param_name_len(module, sk, tj);
          uint8_t tpn[128] /* wave577 Cap name into */;
          int32_t pi;
          int32_t peq;
          if (tpl != gnl)
            continue;
          memset(tpn, 0, sizeof(tpn));
          pipeline_module_struct_layout_type_param_name_into(module, sk, tj, tpn);
          peq = 1;
          for (pi = 0; pi < gnl; pi++) {
            if (tpn[pi] != gnm[pi]) {
              peq = 0;
              break;
            }
          }
          if (peq) {
            tp_slot = tj;
            break;
          }
        }
        if (tp_slot < 0)
          return 0;
      }
      break;
    }
  }
  mono_ty = pipeline_type_type_arg_ref_at(arena, base_ty, tp_slot);
  if (mono_ty <= 0 && tp_slot == 0)
    mono_ty = pipeline_type_elem_ref_at(arena, base_ty);
  if (mono_ty <= 0 || mono_ty > arena->num_types)
    return 0;
  return mono_ty;
}

static void pipeline_typeck_field_apply_mono_type_arg_c(struct ast_Module *module,
                                                       struct ast_ASTArena *arena,
                                                       int32_t expr_ref,
                                                       int32_t base_ty) {
  int32_t got_ty;
  int32_t mono_ty;

  if (!module || !arena || expr_ref <= 0)
    return;
  got_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (ast_ref_is_null(got_ty) || got_ty <= 0 || got_ty > arena->num_types)
    return;
  mono_ty = pipeline_typeck_mono_field_type_from_base_c(module, arena, got_ty, base_ty);
  if (mono_ty <= 0 || mono_ty == got_ty)
    return;
  pipeline_expr_set_resolved_type_ref(arena, expr_ref, mono_ty);
}

/**
 * wave674 Cap residual: hard-fail unknown field when base type is known field-bearing.
 *
 * Prior: layout miss left field type null; assign LHS then stamped RHS onto the
 * unresolved FIELD → typeck green, host-C BLD001 (`no member named 'nope'`).
 * Same false-green on compound assign / nested / *S / slice.nope / E.Nope.
 *
 * Soft residual (still return 0): base type unknown; TYPE_NAMED type-param with
 * no struct/enum layout in module+deps (generic mono path).
 *
 * G.7 single gate — called from heavy check_expr_field_access and the
 * strict_minimal weak twin so product link order cannot skip the fail.
 *
 * @param module *Module — entry module (struct/enum layouts)
 * @param arena *ASTArena
 * @param expr_ref i32 — EXPR_FIELD_ACCESS
 * @param base_ref i32 — field base expr
 * @param ctx *PipelineDepCtx — optional dep modules for cross-module layouts
 * @return i32 — 0 ok (resolved or soft-skip), -1 unknown field (diag emitted)
 * PLATFORM: SHARED — typeck field resolve; dual L2 mac+Ubuntu.
 */
int32_t pipeline_typeck_field_unknown_hard_fail_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t base_ref,
                                                 struct ast_PipelineDepCtx *ctx) {
  int32_t got_ty;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t check_ty;
  int32_t elem_ty;
  int32_t line_f;
  int32_t col_f;
  int32_t nlen;
  uint8_t nbuf[128];
  int32_t has_struct;
  int32_t has_enum;
  int32_t di;
  int32_t nd;
  struct ast_Module *dm;
  extern void driver_diagnostic_typeck_enum_no_variant(int32_t line, int32_t col);

  if (!module || !arena || expr_ref <= 0 || base_ref <= 0)
    return 0;
  got_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
  /* Resolved field type → already known member / enum variant / slice .length/.data. */
  if (!ast_ref_is_null(got_ty) && got_ty > 0 && got_ty <= arena->num_types)
    return 0;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (ast_ref_is_null(base_ty) || base_ty <= 0 || base_ty > arena->num_types)
    return 0; /* soft: unknown base type */
  /* wave702: peel type aliases so `type P = Point` is concrete for unknown-field gate. */
  {
    extern int32_t typeck_resolve_type_alias_ref_local(struct ast_Module *m, struct ast_ASTArena *a,
                                                       int32_t ty, int32_t depth);
    int32_t peeled = typeck_resolve_type_alias_ref_local(module, arena, base_ty, 0);
    if (!ast_ref_is_null(peeled) && peeled > 0 && peeled <= arena->num_types)
      base_ty = peeled;
  }
  bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
  check_ty = base_ty;
  /* Peel *S → S for layout/enum concrete check. */
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
    elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
    if (ast_ref_is_null(elem_ty) || elem_ty <= 0 || elem_ty > arena->num_types) {
      line_f = pipeline_expr_line_at(arena, expr_ref);
      col_f = pipeline_expr_col_at(arena, expr_ref);
      lsp_diag_report_typeck((int)line_f, (int)col_f, "unknown field on this type");
      return -1;
    }
    {
      extern int32_t typeck_resolve_type_alias_ref_local(struct ast_Module *m, struct ast_ASTArena *a,
                                                         int32_t ty, int32_t depth);
      int32_t peeled_e = typeck_resolve_type_alias_ref_local(module, arena, elem_ty, 0);
      if (!ast_ref_is_null(peeled_e) && peeled_e > 0 && peeled_e <= arena->num_types)
        elem_ty = peeled_e;
    }
    check_ty = elem_ty;
    bt_kind = pipeline_type_kind_ord_at(arena, check_ty);
  }
  /* Slice / fixed array / vector: only .length / .data (slice) resolve above. */
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_SLICE || bt_kind == (int32_t)ast_TypeKind_TYPE_ARRAY
      || bt_kind == (int32_t)ast_TypeKind_TYPE_VECTOR) {
    line_f = pipeline_expr_line_at(arena, expr_ref);
    col_f = pipeline_expr_col_at(arena, expr_ref);
    lsp_diag_report_typeck((int)line_f, (int)col_f, "unknown field on this type");
    return -1;
  }
  if (bt_kind == (int32_t)ast_TypeKind_TYPE_NAMED) {
    memset(nbuf, 0, sizeof(nbuf));
    nlen = pipeline_type_named_name_into(arena, check_ty, &nbuf[0]);
    if (nlen <= 0 || nlen > 127)
      return 0;
    has_struct = 0;
    has_enum = 0;
    /* Local module concrete? */
    {
      int32_t k;
      int32_t nsl = module->num_struct_layouts;
      int32_t ne = module->num_module_enums;
      for (k = 0; k < nsl; k++) {
        int32_t sl = pipeline_module_struct_layout_name_len(module, k);
        uint8_t snm[128];
        if (sl != nlen)
          continue;
        memset(snm, 0, sizeof(snm));
        pipeline_module_struct_layout_name_into(module, k, &snm[0]);
        if (typeck_name_equal(&snm[0], sl, &nbuf[0], nlen)) {
          has_struct = 1;
          break;
        }
      }
      for (k = 0; k < ne; k++) {
        int32_t el = pipeline_module_enum_name_len(module, k);
        int32_t bi;
        if (el != nlen)
          continue;
        for (bi = 0; bi < el; bi++) {
          if (pipeline_module_enum_name_byte_at(module, k, bi) != nbuf[bi])
            break;
        }
        if (bi == el) {
          has_enum = 1;
          break;
        }
      }
    }
    /* Dep modules (import structs/enums). */
    if ((!has_struct || !has_enum) && ctx) {
      nd = pipeline_dep_ctx_ndep(ctx);
      for (di = 0; di < nd; di++) {
        dm = pipeline_dep_ctx_module_at(ctx, di);
        if (!dm)
          continue;
        if (!has_struct) {
          int32_t k;
          int32_t nsl = dm->num_struct_layouts;
          for (k = 0; k < nsl; k++) {
            int32_t sl = pipeline_module_struct_layout_name_len(dm, k);
            uint8_t snm[128];
            if (sl != nlen)
              continue;
            memset(snm, 0, sizeof(snm));
            pipeline_module_struct_layout_name_into(dm, k, &snm[0]);
            if (typeck_name_equal(&snm[0], sl, &nbuf[0], nlen)) {
              has_struct = 1;
              break;
            }
          }
        }
        if (!has_enum) {
          int32_t k;
          int32_t ne = dm->num_module_enums;
          for (k = 0; k < ne; k++) {
            int32_t el = pipeline_module_enum_name_len(dm, k);
            int32_t bi;
            if (el != nlen)
              continue;
            for (bi = 0; bi < el; bi++) {
              if (pipeline_module_enum_name_byte_at(dm, k, bi) != nbuf[bi])
                break;
            }
            if (bi == el) {
              has_enum = 1;
              break;
            }
          }
        }
        if (has_struct && has_enum)
          break;
      }
    }
    /*
     * wave684 Cap residual: free type-param / incomplete TYPE_NAMED had soft
     * return 0 here → generic bodies (historically skipped) and bare `x: T`
     * could write `x.nope` with typeck green. No layout ⇒ no fields; hard-fail
     * same diagnostic as concrete unknown field. PLATFORM: SHARED.
     */
    if (!has_struct && !has_enum) {
      line_f = pipeline_expr_line_at(arena, expr_ref);
      col_f = pipeline_expr_col_at(arena, expr_ref);
      lsp_diag_report_typeck((int)line_f, (int)col_f, "unknown field on this type");
      return -1;
    }
    line_f = pipeline_expr_line_at(arena, expr_ref);
    col_f = pipeline_expr_col_at(arena, expr_ref);
    if (has_enum && !has_struct) {
      driver_diagnostic_typeck_enum_no_variant(line_f, col_f);
      return -1;
    }
    lsp_diag_report_typeck((int)line_f, (int)col_f, "unknown field on this type");
    return -1;
  }
  /*
   * Scalar / other first-class types (i32, bool, ptr already peeled, …): no fields.
   * Hard-fail so `x.nope` cannot stamp through assign.
   */
  line_f = pipeline_expr_line_at(arena, expr_ref);
  col_f = pipeline_expr_col_at(arena, expr_ref);
  lsp_diag_report_typeck((int)line_f, (int)col_f, "unknown field on this type");
  return -1;
}

/*
 * G.7 / wave465: mega pipeline_x (OMIT_X_DUP, no STANDALONE_TU) keeps a local
 * copy only — product export must come from pipeline_glue_standalone.o so daily
 * L2 rebuilds of field_access are not silently overridden by a stale pipeline_x.o
 * (Linux first-def-wins). PLATFORM: SHARED link discipline.
 */
#if defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS) && !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU)
static
#endif
int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  int32_t base_ref;
  int32_t base_ty;
  int32_t bt_kind;
  int32_t elem_ty;
  int32_t layout_rc;
  int32_t base_expected;
  int32_t base_kind;

  base_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
  if (ast_ref_is_null(base_ref) || base_ref <= 0 || base_ref > arena->num_exprs)
    return -1;
  pipeline_typeck_field_prebind_c(module, arena, expr_ref, ctx);
  /** Import binding 特判：backend.foo(args) 中 backend 是 import binding，
   * foo 是 dep 模块中的函数；field access 的 typeck 应从 dep 模块查找函数返回类型。 */
  if (pipeline_typeck_field_import_binding_resolve_c(module, arena, expr_ref, base_ref, ctx))
    return 0;
  /*
   * wave454: do NOT pass field-result ambient (return_type_ref) into base.
   * Base type ≠ field type. For CALL/METHOD_CALL bases, reverse-infer a unique
   * owner struct from the field name so bare ret-only generics get the right
   * expected (`mk_default().v` → expected A, not i32).
   */
  base_expected = 0;
  base_kind = pipeline_expr_kind_ord_at(arena, base_ref);
  if (base_kind == (int32_t)ast_ExprKind_EXPR_CALL ||
      base_kind == (int32_t)ast_ExprKind_EXPR_METHOD_CALL) {
    base_expected = pipeline_typeck_field_reverse_infer_base_type_c(module, arena, expr_ref,
                                                                   return_type_ref);
  }
  /* wave454: never pass field-result ambient into base. wave465 uses ambient
   * only after field resolve (type-param field fill). */
  if (pipeline_typeck_check_expr_c(module, arena, base_ref, base_expected, ctx) != 0)
    return -1;
  /** DOD-S1：INDEX 基址的 SoA 字段访问优先于 AoS layout 回落。 */
  if (pipeline_typeck_field_soa_index_c(module, arena, expr_ref, base_ref) != 0)
    return 0;
  base_ty = pipeline_expr_resolved_type_ref(arena, base_ref);
  if (!ast_ref_is_null(base_ty) && base_ty > 0 && base_ty <= arena->num_types) {
    bt_kind = pipeline_type_kind_ord_at(arena, base_ty);
    if (bt_kind == (int32_t)ast_TypeKind_TYPE_PTR) {
      elem_ty = pipeline_type_elem_ref_at(arena, base_ty);
      if (!ast_ref_is_null(elem_ty))
        pipeline_typeck_field_known_ptr_types_c(module, arena, expr_ref, base_ref, module->num_struct_layouts);
    }
    layout_rc = pipeline_typeck_field_layout_named_c(module, arena, expr_ref, base_ref, ctx);
    if (layout_rc == 2) {
      /*
       * User enum variant (Method.GET): resolved to enum TYPE_NAMED.
       * wave472: do not mono/ambient — concrete, not type-param. PLATFORM: SHARED.
       */
      return 0;
    }
    pipeline_typeck_field_slice_c(arena, expr_ref, base_ref);
  }
  pipeline_typeck_field_name_fallback_c(arena, expr_ref, base_ref);
  pipeline_typeck_field_lexer_fallback_c(module, arena, expr_ref, base_ref, ctx);
  pipeline_typeck_field_apply_mono_type_arg_c(module, arena, expr_ref, base_ty);
  pipeline_typeck_field_apply_ambient_for_type_param_c(module, arena, expr_ref, return_type_ref, ctx);
  /* wave674: hard-fail unresolved field on known base (G.7 single gate). */
  if (pipeline_typeck_field_unknown_hard_fail_c(module, arena, expr_ref, base_ref, ctx) != 0)
    return -1;
  return 0;
}
