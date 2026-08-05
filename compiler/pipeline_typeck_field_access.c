/**
 * pipeline_typeck_field_access.c — EXPR_FIELD_ACCESS typeck C residual (8.3.3).
 *
 * Included by pipeline_glue.c (same TU; not a separate .o).
 * Most knives migrated to typeck.x; this TU keeps thin C surfaces + residual
 * bare-import-const diag. mono/named_is_module_concrete/unknown_hard_fail are
 * thin forwarders to typeck.x (G.7 authority).
 * Orchestrator authority: typeck_check_expr_field_access (typeck.x);
 * pipeline_typeck_check_expr_field_access_c is a thin forwarder (strict_glue).
 * PLATFORM: SHARED.
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
 * R2 (8.3.3): TYPE_NAMED module/dep concrete probe.
 * Body migrated to typeck.x as typeck_named_is_module_concrete.
 * Zero business logic — thin surface for strict_minimal + residual callers.
 * PLATFORM: SHARED.
 */
extern int32_t typeck_named_is_module_concrete(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                               uint8_t *name, int32_t name_len);

int32_t pipeline_typeck_named_is_module_concrete_c(struct ast_Module *module,
                                                          struct ast_PipelineDepCtx *ctx,
                                                          uint8_t *name,
                                                          int32_t name_len) {
  return typeck_named_is_module_concrete(module, ctx, name, name_len);
}

/**
 * R2 (8.3.3): mono free type-param field against monomorphized base.
 * Body migrated to typeck.x as typeck_mono_field_type_from_base.
 * Zero business logic — thin surface for field_access + STRUCT_LIT coerce.
 * PLATFORM: SHARED — G.7 mono field authority (wave466/467/682).
 */
extern int32_t typeck_mono_field_type_from_base(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t field_ty, int32_t base_ty);

int32_t pipeline_typeck_mono_field_type_from_base_c(struct ast_Module *module,
                                                   struct ast_ASTArena *arena,
                                                   int32_t field_ty,
                                                   int32_t base_ty) {
  return typeck_mono_field_type_from_base(module, arena, field_ty, base_ty);
}

/**
 * R2 (8.3.3): hard-fail unknown field on known base.
 * Body migrated to typeck.x as typeck_field_unknown_hard_fail.
 * Zero business logic — thin surface for strict_minimal weak twin + heavy path.
 * PLATFORM: SHARED — G.7 single gate (wave674/684/702).
 */
extern int32_t typeck_field_unknown_hard_fail(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t expr_ref, int32_t base_ref,
                                              struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_field_unknown_hard_fail_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 int32_t expr_ref, int32_t base_ref,
                                                 struct ast_PipelineDepCtx *ctx) {
  return typeck_field_unknown_hard_fail(module, arena, expr_ref, base_ref, ctx);
}

/**
 * R2 (8.3.3): EXPR_FIELD_ACCESS typeck orchestrator.
 * Body migrated to typeck.x as typeck_check_expr_field_access.
 * Zero business logic — thin surface for strict_glue / seed / OMIT_X_DUP.
 *
 * G.7 / wave465: mega pipeline_x (OMIT_X_DUP, no STANDALONE_TU) keeps a local
 * thin copy only — product export must come from pipeline_glue_standalone.o so
 * daily L2 rebuilds of field_access are not silently overridden by a stale
 * pipeline_x.o (Linux first-def-wins). PLATFORM: SHARED link discipline.
 */
extern int32_t typeck_check_expr_field_access(struct ast_Module *module, struct ast_ASTArena *arena,
                                              int32_t expr_ref, int32_t return_type_ref,
                                              struct ast_PipelineDepCtx *ctx);

#if defined(XLANG_PIPELINE_GLUE_OMIT_X_DUP_EXPORTS) && !defined(XLANG_PIPELINE_GLUE_STANDALONE_TU)
static
#endif
int32_t pipeline_typeck_check_expr_field_access_c(struct ast_Module *module, struct ast_ASTArena *arena, int32_t expr_ref,
                                                  int32_t return_type_ref, struct ast_PipelineDepCtx *ctx) {
  return typeck_check_expr_field_access(module, arena, expr_ref, return_type_ref, ctx);
}
