/**
 * pipeline_parse_orch.c — pipeline parse / load / typeck orchestration domain.
 *
 * wave1186 G.7: migrated from pipeline_glue.c (same-TU #include).
 *
 * Colocated domain: all parse_into_buf / load_import / sync_dep_slots /
 * resolve_path / read_file / lsp_diag / typeck_after_parse_ok /
 * stack_escape_gate orchestration helpers. These are weak cold twins +
 * impl_c authorities + _c dispatch wrappers for the pipeline parse/load
 * orchestration path. Product pure (runtime_pipeline_abi.x) owns the strong
 * symbols; these remain as cold authority for standalone / non-PREFER links.
 *
 * Members (24 fns):
 *  - pipeline_parse_into_buf_impl_c / _c
 *  - pipeline_load_import_from_disk_impl_c / _c
 *  - pipeline_sync_dep_slots_from_driver_impl_c / _c
 *  - pipeline_parse_into_with_init_buf_impl_c / _c
 *  - pipeline_parse_into_buf (XLANG_WEAK, standalone)
 *  - pipeline_load_import_from_disk (XLANG_WEAK, standalone)
 *  - pipeline_sync_dep_slots_from_driver (XLANG_WEAK, standalone)
 *  - pipeline_resolve_path_x (XLANG_WEAK, standalone)
 *  - pipeline_read_file_x (XLANG_WEAK, standalone)
 *  - pipeline_parse_into_with_init_buf (XLANG_WEAK, standalone)
 *  - pipeline_lsp_diag_parse_typeck_buf_impl_c / _c
 *  - pipeline_lsp_diag_parse_entry_buf_impl_c
 *  - pipeline_parse_into_with_init_c
 *  - pipeline_typeck_after_parse_ok_impl_c / _c
 *  - pipeline_typeck_after_parse_ok_buf_impl_c
 *  - pipeline_typeck_x_stack_escape_gate_from_src_c
 *  - pipeline_lsp_diag_parse_typeck_buf (XLANG_WEAK, standalone)
 *  - pipeline_typeck_after_parse_ok (XLANG_WEAK, standalone)
 *
 * No static state; all deps are extern (parser.o / ast_pool.c /
 * pipeline_typeck_region_assign.c / pipeline_typeck_check_block.c /
 * pipeline_parser_result.c / runtime.c).
 *
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 */

/* extern fwd decls for callsites in this domain file.
 * These are defined in other TUs or later in the same TU (pipeline_glue.c
 * body after #include). Declaring them here ensures visibility regardless
 * of #include position. */

/* ast_pool.c / ast_pool_block.c */
extern void pipeline_module_fixup_with_arena_stmt_orders(struct ast_Module *m, struct ast_ASTArena *a);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
extern int32_t pipeline_sync_one_dep_slot(struct ast_Module *module, struct ast_PipelineDepCtx *ctx, int32_t dep_i);
extern void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module);
extern int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                          struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_resolve_path_x_impl_c(struct ast_PipelineDepCtx *ctx, uint8_t *import_path, int32_t path_len);
extern int32_t pipeline_read_file_x_impl_c(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_preprocess_loaded_into_ctx(struct ast_PipelineDepCtx *ctx);
extern void pipeline_bind_import_dep_buffers(struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *path, int32_t len);
extern uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_preprocess_len_get(struct ast_PipelineDepCtx *ctx);

/* parser.o */
extern void parser_parse_into_init(struct ast_Module *module, struct ast_ASTArena *arena);
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                            uint8_t *buf, int32_t buf_len);
extern struct parser_ParseIntoResult parser_parse_into(struct ast_ASTArena *arena, struct ast_Module *module,
                                                        struct xlang_slice_uint8_t *source);
extern void parser_parse_into_set_main_index(struct ast_Module *module, int32_t main_idx);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t import_idx, uint8_t *path_buf);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);

/* typeck.o / runtime.c */
extern int32_t typeck_typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_typeck_fail(void);
extern void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len);
extern int32_t lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                            uint8_t *source_data, int32_t source_len,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t lsp_diag_parse_entry_buf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                           uint8_t *source_data, int32_t source_len);

/* pipeline_glue.c (defined later in same TU) */
extern void ast_ast_arena_init(struct ast_ASTArena *arena);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern void pipeline_module_set_main_func_index(struct ast_Module *m, int32_t idx);
extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern int32_t pipeline_module_num_type_aliases_at(struct ast_Module *m);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);

/* pipeline_typeck_region_assign.c (via #include in pipeline_glue.c) */
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module,
                                                                  struct ast_ASTArena *arena,
                                                                  struct ast_PipelineDepCtx *ctx);

/* pipeline_typeck_check_block.c (via #include in pipeline_glue.c) */
extern void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);

/* trait / generic (extern, runtime.c) */
extern void xlang_trait_reg_reset_c(void *arena);
extern int32_t xlang_trait_check_impls_complete_c(void *module);
extern void xlang_generic_bound_stash_source_buf_c(uint8_t *data, int32_t len);


/**
 * wave96: product pure owns pipeline_parse_into_buf (runtime_pipeline_abi.x orch).
 * This impl_c remains cold authority for pipeline.x thin / non-PREFER via weak dispatch.
 * PLATFORM: SHARED.
 */
int32_t pipeline_parse_into_buf_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf,
                                        int32_t buf_len) {
  struct parser_ParseIntoResult pr;
  if (!arena || !module || !buf || buf_len <= 0)
    return -1;
  /* wave421/wave425: per-module trait registry (names + ret kinds; stash arena). */
  xlang_trait_reg_reset_c(arena);
  /*
   * wave455: product path fully parses structs (no skip_one_struct) so the
   * historical stash-from-skip never ran on clean struct+fn files → generic
   * bound/type-param scan saw null source and multi type_arg ret fixup
   * could not map T→type_arg[i]. Stash full buffer at product parse entry.
   * PLATFORM: SHARED — same slice as freestanding -o / typeck.
   */
  xlang_generic_bound_stash_source_buf_c(buf, buf_len);
  parser_parse_into_init(module, arena);
  pr = parser_parse_into_buf(arena, module, buf, buf_len);
  if (pr.ok == 0) {
    /* Completeness check before dep loads wipe the registry. */
    if (xlang_trait_check_impls_complete_c(module) != 0)
      return -1;
    pipeline_debug_trace_named_func_bodies("parse_post", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("parse_post_fixup", module, arena);
  }
  return pr.ok == 0 ? 0 : -1;
}

/** M8-tail: EMIT_HEAVY X thin wrapper return _c; do not dispatch back to X (let struct init Abort). */
int32_t pipeline_parse_into_buf_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf,
                                   int32_t buf_len) {
  return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
}

/**
 * strict fallback: single import resolve/read/preprocess/parse (C path, aligned with X semantics).
 * build_asm/pipeline.o links strong pipeline_load_import_from_disk to override weak default.
 * wave94: product pure owns pipeline_load_import_from_disk_c (runtime_pipeline_abi.x orch);
 * this impl_c remains cold authority for pipeline.x thin / non-PREFER via weak _c dispatch.
 * PLATFORM: SHARED.
 */
int32_t pipeline_load_import_from_disk_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t path_len;
  struct ast_ASTArena *dep_arena;
  struct ast_Module *dep_module;

  if (!module || !arena || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  path_len = parser_copy_module_import_path64(module, import_idx, path_buf);
  if (pipeline_resolve_path_x(ctx, path_buf, path_len) != 0)
    return -7;
  if (pipeline_read_file_x(ctx) != 0)
    return -8;
  if (pipeline_preprocess_loaded_into_ctx(ctx) != 0)
    return -9;
  /*
   * PLATFORM: SHARED — pin import path on the same slot we parse into.
   * Why: path was only written later in sync_one_dep_slot / fill_dep; if seed
   * partially binds or sync is skipped, dep slots keep a stale path (parser M1:
   * ast layouts registered under path=lexer → path de-dupe suppresses struct
   * ast_* full emit → dual-extern incomplete tags). Authority = the path used
   * to resolve/read this import_idx.
   */
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, import_idx, path_buf, path_len);
  pipeline_bind_import_dep_buffers(ctx, import_idx);
  dep_arena = pipeline_dep_ctx_arena_at(ctx, import_idx);
  dep_module = pipeline_dep_ctx_module_at(ctx, import_idx);
  if (pipeline_parse_into_buf(dep_arena, dep_module, pipeline_dep_ctx_preprocess_buf_ptr(ctx),
                                pipeline_dep_ctx_preprocess_len_get(ctx)) != 0)
    return -10;
  return 0;
}

/**
 * strict fallback: align dep slots with driver seed; build_asm links X strong to override weak default.
 * wave94: product pure owns pipeline_sync_dep_slots_from_driver_c (runtime_pipeline_abi.x orch);
 * this impl_c remains cold authority for pipeline.x thin / non-PREFER via weak _c dispatch.
 * PLATFORM: SHARED.
 */
int32_t pipeline_sync_dep_slots_from_driver_impl_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t dep_sync_nd;
  int32_t dep_sync_i;
  int32_t sync_rc;
  int32_t n_entry_imports;

  if (!module || !ctx)
    return -1;
  dep_sync_nd = pipeline_dep_ctx_ndep(ctx);
  n_entry_imports = parser_get_module_num_imports(module);
  /*
   * [Why root cause] Closure seed time ndep > entry imports; old logic narrowed sync range to n_entry_imports,
   *   and pipeline_sync_one_dep_slot used entry import[i] path to overwrite slot i → same structure as
   *   load_and_sync entry-index re-pin, wiping transitive deps like std.io.core.
   * [Invariant] ndep > n_entry_imports: slots already aligned by pctx_seed, skip entry-index sync.
   * PLATFORM: SHARED — aligned with pipeline_load_and_sync_direct_import_deps_c.
   */
  if (n_entry_imports >= 0 && n_entry_imports < dep_sync_nd) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      fprintf(stderr,
              "xlang: [XLANG_DEBUG_PIPE] skip entry-index dep sync (ndep=%d entry_imports=%d)\n",
              (int)dep_sync_nd, (int)n_entry_imports);
    return 0;
  }
  dep_sync_i = 0;
  while (dep_sync_i < dep_sync_nd) {
    sync_rc = pipeline_sync_one_dep_slot(module, ctx, dep_sync_i);
    if (sync_rc != 0)
      return sync_rc;
    dep_sync_i = dep_sync_i + 1;
  }
  return 0;
}

/**
 * strict fallback: strict reset then parser_parse_into_buf; do not stack ast_ast_arena_init+parser_parse_into_init.
 */
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_impl_c(struct ast_ASTArena *arena,
                                                                        struct ast_Module *module, uint8_t *data,
                                                                        int32_t len) {
  struct parser_ParseIntoResult fail;
  struct parser_ParseIntoResult pr;

  fail.ok = 1;
  fail.main_idx = -1;
  if (!arena || !module || !data || len <= 0)
    return fail;
  /* wave421 Cap residual pure — per-module trait registry for missing method.
   * Root: incomplete impl was false-green; check immediately after parse so
   * dep load reset cannot wipe entry trait tables.
   * wave425: stash arena for return type kind compare.
   * wave455: also stash source for generic type-param / bound scan (see
   * pipeline_parse_into_buf_impl_c).
   * G.7: xlang_trait_* in skip_tl + this product parse entry.
   * PLATFORM: SHARED parse. */
  xlang_trait_reg_reset_c(arena);
  xlang_generic_bound_stash_source_buf_c(data, len);
  pipeline_strict_parse_into_init(arena, module);
  pr = parser_parse_into_buf(arena, module, data, len);
  if (pr.ok == 0 && xlang_trait_check_impls_complete_c(module) != 0) {
    fail.ok = 1;
    fail.main_idx = -1;
    return fail;
  }
  return pr;
}

#ifdef XLANG_PIPELINE_GLUE_STANDALONE_TU
/**
 * wave96: product pure owns pipeline_parse_into_buf (runtime_pipeline_abi.x).
 * Keep weak cold twin for standalone / non-PREFER links.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                                       uint8_t *buf, int32_t buf_len) {
  return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
}

XLANG_WEAK int32_t pipeline_load_import_from_disk(struct ast_Module *module, struct ast_ASTArena *arena,
                                                             struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
}

XLANG_WEAK int32_t pipeline_sync_dep_slots_from_driver(struct ast_Module *module,
                                                                   struct ast_PipelineDepCtx *ctx) {
  return pipeline_sync_dep_slots_from_driver_impl_c(module, ctx);
}

/**
 * wave95: product pure owns pipeline_resolve_path_x (runtime_pipeline_abi.x).
 * Keep weak cold twin for standalone / non-PREFER links.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t *import_path,
                                                        int32_t path_len) {
  return pipeline_resolve_path_x_impl_c(ctx, import_path, path_len);
}

/**
 * wave95: product pure owns pipeline_read_file_x (runtime_pipeline_abi.x).
 * Keep weak cold twin for standalone / non-PREFER links.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_read_file_x(struct ast_PipelineDepCtx *ctx) {
  return pipeline_read_file_x_impl_c(ctx);
}

/** weak default: parse_into_with_init / lsp / typeck thin orchestration (standalone; build_asm pipeline.o X strong override). */
XLANG_WEAK struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena *arena,
                                                                                       struct ast_Module *module,
                                                                                       uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
}
#endif

/**
 * M8-tail: dispatch to pipeline_load_import_from_disk first (X or weak impl_c).
 * wave94: product pure owns pipeline_load_import_from_disk_c (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                          struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  return pipeline_load_import_from_disk(module, arena, ctx, import_idx);
}

/**
 * M8-tail: dispatch to pipeline_parse_into_with_init_buf first (X or weak impl_c).
 */
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                   uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf(arena, module, data, len);
}

/**
 * M8-tail: dispatch to pipeline_sync_dep_slots_from_driver (X or weak impl_c).
 * wave94: product pure owns pipeline_sync_dep_slots_from_driver_c (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  return pipeline_sync_dep_slots_from_driver(module, ctx);
}

/**
 * strict fallback: LSP parse + load deps + typeck (no codegen); parse via set_main_c, typeck via pipeline_typeck_parsed_module.
 */
int32_t pipeline_lsp_diag_parse_typeck_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   uint8_t *source_data, int32_t source_len,
                                                   struct ast_PipelineDepCtx *ctx) {
  return lsp_diag_parse_typeck_buf_c(module, arena, source_data, source_len, ctx);
}

/**
 * LSP parse half-path: pipeline_parse_set_main_from_buf_c; on fail parse diagnostic already in C glue.
 */
int32_t pipeline_lsp_diag_parse_entry_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                uint8_t *source_data, int32_t source_len) {
  return lsp_diag_parse_entry_buf_c(module, arena, source_data, source_len);
}

/** X or weak impl_c; _c dispatch forward decl. */
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                            int32_t source_len, struct ast_PipelineDepCtx *ctx);

/** M8-tail: dispatch to pipeline_lsp_diag_parse_typeck_buf (X or weak impl_c). */
int32_t pipeline_lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                              int32_t source_len, struct ast_PipelineDepCtx *ctx) {
  return pipeline_lsp_diag_parse_typeck_buf(module, arena, source_data, source_len, ctx);
}

/**
 * strict fallback: slice parse_into_with_init + typeck; X thin orchestration calls _c (do not _c→bare name dispatch, avoid X thin wrapper recursion).
 */
struct parser_ParseIntoResult pipeline_parse_into_with_init_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                               struct xlang_slice_uint8_t *source) {
  struct parser_ParseIntoResult fail;

  fail.ok = 1;
  fail.main_idx = -1;
  if (!arena || !module || !source || !source->data)
    return fail;
  ast_ast_arena_init(arena);
  parser_parse_into_init(module, arena);
  return parser_parse_into(arena, module, source);
}

/**
 * strict fallback: slice parse + typeck; parse_into mega via pipeline_parse_into_with_init_c (see above, no dispatch loop).
 */
int32_t pipeline_typeck_after_parse_ok_impl_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                               struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx) {
  struct parser_ParseIntoResult r;
  int32_t tc;

  if (!arena || !module || !source || !ctx)
    return -1;
  if (source->data && source->length > 0)
    pipeline_lint_set_source_buf(source->data, (int32_t)source->length);
  r = pipeline_parse_into_with_init_c(arena, module, source);
  if (r.ok != 0)
    return r.main_idx;
  pipeline_module_set_main_func_index(module, r.main_idx);
  pipeline_typeck_set_active_ctx_c(module, ctx);
  if (link_abi_getenv("XLANG_DEBUG_PIPE") != NULL) {
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] type_aliases=%d struct_layouts=%d\n",
            (int)pipeline_module_num_type_aliases_at(module),
            (int)pipeline_module_num_struct_layouts_at(module));
  }
  if (pipeline_module_main_func_index(module) < 0) {
    tc = typeck_typeck_x_ast_library(module, arena, ctx);
    if (tc != 0) {
      driver_diagnostic_typeck_fail();
      return tc;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      return -1;
    }
    return tc;
  }
  tc = typeck_typeck_x_ast(module, arena, ctx);
  if (tc != 0) {
    driver_diagnostic_typeck_fail();
    return tc;
  }
  if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
    driver_diagnostic_typeck_fail();
    return -1;
  }
  return tc;
}

int32_t pipeline_typeck_after_parse_ok_buf_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data,
                                                   int32_t len, struct ast_PipelineDepCtx *ctx) {
  struct xlang_slice_uint8_t source;

  if (!data || len <= 0)
    return -1;
  source = pipeline_source_slice(data, len);
  return pipeline_typeck_after_parse_ok_impl_c(arena, module, &source, ctx);
}

/** xlang check WPO-S3 X stack-escape gate (strict parse + post-scan; C typeck already passed). */
int32_t pipeline_typeck_x_stack_escape_gate_from_src_c(uint8_t *src, int32_t src_len) {
  size_t asz;
  size_t msz;
  void *arena_heap;
  void *module_heap;
  struct ast_PipelineDepCtx ctx;
  struct parser_ParseIntoResult pr;
  int32_t rc;

  if (!src || src_len <= 0)
    return 0;
  asz = pipeline_sizeof_arena();
  msz = pipeline_sizeof_module();
  arena_heap = calloc(1, asz);
  module_heap = calloc(1, msz);
  if (!arena_heap || !module_heap) {
    free(arena_heap);
    free(module_heap);
    return -1;
  }
  memset(&ctx, 0, sizeof(ctx));
  pipeline_strict_parse_into_init((struct ast_ASTArena *)arena_heap, (struct ast_Module *)module_heap);
  pr = parser_parse_into_buf((struct ast_ASTArena *)arena_heap, (struct ast_Module *)module_heap, src, src_len);
  if (pr.ok != 0) {
    free(arena_heap);
    free(module_heap);
    return -1;
  }
  parser_parse_into_set_main_index((struct ast_Module *)module_heap, pr.main_idx);
  rc = pipeline_typeck_scan_module_struct_stack_escape_c((struct ast_Module *)module_heap,
                                                         (struct ast_ASTArena *)arena_heap, &ctx);
  if (rc != 0)
    driver_diagnostic_typeck_fail();
  free(arena_heap);
  free(module_heap);
  return (rc == 0) ? 0 : -1;
}

/** X or weak impl_c; _c dispatch forward decl. */
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module,
                                        struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx);

/** M8-tail: dispatch to pipeline_typeck_after_parse_ok (X or weak impl_c). */
int32_t pipeline_typeck_after_parse_ok_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                          struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_after_parse_ok(arena, module, source, ctx);
}

/* ============================================================
 * wave1193 G.7: driver diagnostic + sizeof + check_only/skip
 * forwarding cluster (24 fns) migrated from pipeline_glue.c
 *
 * driver_* extern decls (were at glue.c L415-L419/L426/L445/L473):
 * redeclared here for the migrated forwarder bodies below.
 */
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern size_t driver_pipeline_entry_source_len(void);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern void driver_diagnostic_pipe_marker(int32_t id);
extern int32_t driver_check_only_get(void);
extern int32_t driver_x_pipeline_skip_typeck_get(void);

/* ============================================================
 * wave1193 G.7: driver diagnostic + sizeof + check_only/skip
 * forwarding cluster (24 fns) migrated from pipeline_glue.c
 * L316-L544. Colocated with parse/load/typeck orchestration domain
 * — these are all thin extern forwarders to driver_* functions in
 * runtime.c, used by the parse/typeck/pipeline orchestration path.
 *
 * Excluded (remain in glue.c due to #ifdef guards):
 * - pipeline_run_x_pipeline (#ifndef XLANG_PARSER_EXE_PIPELINE_GLUE)
 * - pipeline_sizeof_elf_ctx (#ifdef XLANG_PARSER_EXE_PIPELINE_GLUE)
 *
 * Dependencies visible at #include point (parse_orch.c #include at
 * glue.c L4263):
 * - driver_* extern functions (declared in glue.c L463-L521 before
 *   #include — visible in same TU)
 * - link_abi_getenv (extern at glue.c L51)
 * - pipeline_module_func_name_len_at / body_ref_at / name_copy64 /
 *   is_extern_at (extern fwd decls at glue.c L256-L260)
 * - ast_ast_block_num_lets / num_stmt_order / num_regions (extern
 *   fwd decls at glue.c L413-L416)
 * - pipeline_module_func_ptr (extern fwd decl at glue.c L91)
 * - struct ast_ASTArena / ast_Module / ast_Func / platform_elf_ElfCodegenCtx
 *   (defined in headers included at glue.c L33-L42)
 * - offsetof / sizeof (from <stddef.h> at glue.c L33)
 * - fprintf / fputc / fflush (from <stdio.h> at glue.c L390)
 *
 * No glue.c callsites before #include (verified: only L501
 * pipeline_shu_pipeline_check_only -> xlang_pipeline_check_only,
 * both migrated together here).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU.
 * ============================================================ */

/**
 * parser.x::parse_strict_enabled C forwarder.
 *
 * Why: non-zero means parse_into_buf fails the whole file on any
 *      function parse failure instead of silently skipping.
 * Contract: returns driver_parse_strict_enabled() value.
 * PLATFORM: SHARED — parse orchestration diagnostic.
 */
int32_t parser_parse_strict_enabled(void) {
  extern int32_t driver_parse_strict_enabled(void);
  return driver_parse_strict_enabled();
}

/**
 * parser.x::diagnostic_parse_skip C forwarder.
 *
 * Why: stderr diagnostic when parse_into_buf skips a function
 *      (XLANG_DEBUG_PARSE=1 or XLANG_PARSE_STRICT=1).
 * PLATFORM: SHARED — parse orchestration diagnostic.
 */
void parser_diagnostic_parse_skip(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name) {
  extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                                    const uint8_t *name);
  driver_diagnostic_parse_skip_function(byte_pos, num_funcs_so_far, name_len, name);
}

/**
 * parser.x::diagnostic_parse_commit_fail C forwarder.
 *
 * Why: stderr diagnostic when parse_into_buf commit fails; large
 *      modules must skip+continue, not abort.
 * PLATFORM: SHARED — parse orchestration diagnostic.
 */
void parser_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name) {
  extern void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                                const uint8_t *name);
  driver_diagnostic_parse_commit_fail(byte_pos, num_funcs_so_far, name_len, name);
}

/**
 * parser.x::diagnostic_parse_func_generic C forwarder.
 *
 * Why: prints generic param count before committing a function slot
 *      (XLANG_DEBUG_PARSE_GENERIC=1).
 * PLATFORM: SHARED — parse orchestration diagnostic.
 */
void parser_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t *name, int32_t name_len,
                                          int32_t num_generic_params, int32_t is_main) {
  extern void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name,
                                                   int32_t name_len, int32_t num_generic_params, int32_t is_main);
  driver_diagnostic_parse_func_generic(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
}

/**
 * pipeline.x::sizeof_arena weak C twin.
 *
 * Why: layout truth via C sizeof for cold full-C bootstrap. Product
 *      hybrid pure owns strong pipeline_sizeof_arena (fixed LP64
 *      constant 16 matching this sizeof). Keep weak so pure.o can
 *      override without dual-strong clash.
 * Contract: returns sizeof(struct ast_ASTArena).
 * PLATFORM: SHARED LP64 — re-verify pure constants dual-end on change.
 */
XLANG_WEAK size_t pipeline_sizeof_arena(void) { return sizeof(struct ast_ASTArena); }

/**
 * pipeline.x::sizeof_module weak C twin.
 *
 * Why: same as sizeof_arena but for struct ast_Module (fixed LP64 68).
 * PLATFORM: SHARED LP64.
 */
XLANG_WEAK size_t pipeline_sizeof_module(void) { return sizeof(struct ast_Module); }

/**
 * pipeline.x::sizeof_dep_ctx C twin.
 *
 * Why: LSP / lsp_diag.x — PipelineDepCtx is large (4MiB×2 buffers);
 *      one-time calloc then memset reuse.
 * PLATFORM: SHARED.
 */
size_t pipeline_sizeof_dep_ctx(void) { return sizeof(struct ast_PipelineDepCtx); }

/**
 * pipeline.x::sizeof_onefunc_result C twin.
 *
 * Why: parser OneFuncResult is large (256×64 let names etc.);
 *      parse_block_into heap-allocates scratch to avoid recursive
 *      block parse stack overflow.
 * PLATFORM: SHARED.
 */
size_t pipeline_sizeof_onefunc_result(void) { return (size_t)8192; }

/**
 * pipeline.x::arena_offset_num_types C twin.
 *
 * Why: offsetof num_types field for runtime.c cold introspection.
 * PLATFORM: SHARED.
 */
size_t pipeline_arena_offset_num_types(void) { return offsetof(struct ast_ASTArena, num_types); }

/**
 * pipeline.x::debug_module_funcs C twin.
 *
 * Why: stderr dump of all module function names+len for debugging
 *      (XLANG_DEBUG_PIPE / XLANG_ASM_LIST_FUNCS).
 * PLATFORM: SHARED — debug diagnostic.
 */
void pipeline_debug_module_funcs(void *m) {
  struct ast_Module *mod = (struct ast_Module *)m;
  int i, n = (int)mod->num_funcs;
  for (i = 0; i < n; i++) {
    struct ast_Func *f = pipeline_module_func_ptr(mod, i);
    int len = f ? (int)f->name_len : 0;
    if (f)
      fprintf(stderr, "[DEBUG] module func[%d] name_len=%d name=%.*s\n", i, len,
              len > 0 && len <= 64 ? len : 0, f->name);
  }
}

/**
 * runtime.c diagnostic: return module num_funcs.
 *
 * Why: runtime.c needs ast_Module layout access via same TU.
 * PLATFORM: SHARED.
 */
int driver_get_module_num_funcs(void *m) {
  return m ? (int)((struct ast_Module *)m)->num_funcs : 0;
}

/**
 * runtime.c diagnostic: return module main_func_index.
 *
 * Why: smoke test summary — -1 if no main, -2 if null module.
 * PLATFORM: SHARED.
 */
int driver_get_module_main_func_index(void *m) {
  return m ? (int)((struct ast_Module *)m)->main_func_index : -2;
}

/**
 * pipeline.x::driver_diagnostic_entry_module C twin.
 *
 * Why: post-parse diagnostic — lists all module functions with extern
 *      flag, body_ref, let/stmt_order/region counts when
 *      XLANG_ASM_LIST_FUNCS=1 (for asm single-compile missing symbol
 *      triage). Otherwise no-op.
 * Invariant: mod/arena may be null; checks internally.
 * PLATFORM: SHARED — parse orchestration diagnostic.
 */
void driver_diagnostic_entry_module(struct ast_Module *mod, struct ast_ASTArena *a) {
  const char *list_env;
  int32_t i;
  int32_t j;
  (void)a;
  list_env = link_abi_getenv("XLANG_ASM_LIST_FUNCS");
  if (list_env && list_env[0] != '\0' && list_env[0] != '0' && mod) {
    for (i = 0; i < (int32_t)mod->num_funcs; i++) {
      uint8_t nm[128];
      int32_t nl = pipeline_module_func_name_len_at(mod, i);
      int32_t body_ref = pipeline_module_func_body_ref_at(mod, i);
      int32_t nlet = 0;
      int32_t nso = 0;
      int32_t nreg = 0;
      pipeline_module_func_name_copy64(mod, i, nm);
      if (body_ref > 0 && a && body_ref <= a->num_blocks) {
        nlet = ast_ast_block_num_lets(a, body_ref);
        nso = ast_ast_block_num_stmt_order(a, body_ref);
        nreg = ast_ast_block_num_regions(a, body_ref);
      }
      fprintf(stderr, "asm_list: #%d extern=%d body_ref=%d nlet=%d nso=%d nreg=%d name=",
              (int)i, (int)pipeline_module_func_is_extern_at(mod, i),
              (int)body_ref, (int)nlet, (int)nso, (int)nreg);
      for (j = 0; j < nl && j < 64; j++)
        fputc((char)nm[j], stderr);
      fputc('\n', stderr);
    }
    fflush(stderr);
    return;
  }
  (void)mod;
}

/**
 * typeck.x::driver_diagnostic_after_entry_parse C forwarder.
 *
 * Why: pipeline.x -E produces typeck_ prefix; delegates to
 *      driver_diagnostic_after_entry_parse in runtime.c.
 * PLATFORM: SHARED — typeck orchestration diagnostic.
 */
void typeck_driver_diagnostic_after_entry_parse(int32_t num_funcs) {
  driver_diagnostic_after_entry_parse(num_funcs);
}

/**
 * typeck.x::driver_diagnostic_pipe_marker C forwarder.
 *
 * Why: pipeline.x via typeck_ prefix; delegates to runtime.c.
 * PLATFORM: SHARED — typeck orchestration diagnostic.
 */
void typeck_driver_diagnostic_pipe_marker(int32_t id) {
  driver_diagnostic_pipe_marker(id);
}

/**
 * typeck.x / pipeline.x::pipeline_entry_source_len C forwarder.
 *
 * Why: entry source length from runtime.c.
 * PLATFORM: SHARED — typeck orchestration diagnostic.
 */
size_t typeck_driver_pipeline_entry_source_len(void) {
  return driver_pipeline_entry_source_len();
}

/**
 * pipeline.x::pipeline_entry_source_len C forwarder (pipeline_ prefix).
 *
 * Why: same as typeck_ prefix twin — delegates to runtime.c.
 * PLATFORM: SHARED — pipeline orchestration diagnostic.
 */
size_t pipeline_driver_pipeline_entry_source_len(void) {
  return driver_pipeline_entry_source_len();
}

/**
 * pipeline.x::driver_diagnostic_pipe_marker C forwarder (pipeline_ prefix).
 *
 * PLATFORM: SHARED — pipeline orchestration diagnostic.
 */
void pipeline_driver_diagnostic_pipe_marker(int32_t id) {
  driver_diagnostic_pipe_marker(id);
}

/**
 * pipeline.x::check_only C forwarder.
 *
 * Why: non-zero means pipeline runs in check-only mode (no codegen).
 *      Delegates to driver_check_only_get in runtime.c.
 * PLATFORM: SHARED — pipeline control flow.
 */
int32_t xlang_pipeline_check_only(void) {
  return driver_check_only_get();
}

/**
 * Legacy glue compat name for xlang_pipeline_check_only.
 *
 * PLATFORM: SHARED — backward compat.
 */
int32_t pipeline_shu_pipeline_check_only(void) {
  return xlang_pipeline_check_only();
}

/**
 * typeck.x::typeck_skip_large_entry C forwarder.
 *
 * Why: skip typeck for large entry modules (build time optimization).
 * PLATFORM: SHARED — typeck control flow.
 */
int32_t typeck_driver_typeck_skip_large_entry(void) {
  return driver_typeck_skip_large_entry();
}

/**
 * typeck.x::asm_build_skip_typeck C forwarder.
 *
 * Why: XLANG_ASM_BUILD_SKIP_TYPECK=1 skips .x typeck in pipeline.
 * PLATFORM: SHARED — typeck control flow.
 */
int32_t typeck_driver_asm_build_skip_typeck(void) {
  return driver_asm_build_skip_typeck();
}

/**
 * pipeline.x::typeck_skip_large_entry C forwarder (pipeline_ prefix).
 *
 * PLATFORM: SHARED — pipeline control flow.
 */
int32_t pipeline_driver_typeck_skip_large_entry(void) {
  return driver_typeck_skip_large_entry();
}

/**
 * build_xlang_asm: XLANG_ASM_BUILD_SKIP_TYPECK=1 pipeline skip .x typeck.
 *
 * PLATFORM: SHARED — pipeline control flow.
 */
int32_t pipeline_driver_asm_build_skip_typeck(void) {
  return driver_asm_build_skip_typeck();
}

/**
 * asm -o: skip .x typeck when C precheck already passed.
 *
 * Why: avoids redundant .x typeck on asm -o path
 *      (see driver_run_asm_backend).
 * PLATFORM: SHARED — pipeline control flow.
 */
int32_t pipeline_driver_x_pipeline_skip_typeck(void) {
  return driver_x_pipeline_skip_typeck_get();
}

/**
 * Diagnostic: print main body block num_stmt_order after parse.
 *
 * Why: debug diagnostic for empty-body triage; normally inactive
 *      (commented out body); re-enable in runtime.c when needed.
 * PLATFORM: SHARED — parse orchestration diagnostic.
 */
void driver_diagnostic_entry_block_after_parse(void *mod, void *arena) {
  struct ast_Module *m = (struct ast_Module *)mod;
  struct ast_ASTArena *a = (struct ast_ASTArena *)arena;
  if (!m || !a || m->main_func_index < 0 || m->main_func_index >= m->num_funcs)
    return;
  {
    struct ast_Func *mf = pipeline_module_func_ptr(m, m->main_func_index);
    int32_t br = mf ? (int32_t)mf->body_ref : 0;
    if (br <= 0 || br > a->num_blocks)
      return;
    (void)br;
    (void)a;
  }
}

/** weak default: lsp / typeck diagnostic path (standalone; build_asm pipeline.o X strong override). */
#ifdef XLANG_PIPELINE_GLUE_STANDALONE_TU
XLANG_WEAK int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                  uint8_t *source_data, int32_t source_len,
                                                                  struct ast_PipelineDepCtx *ctx) {
  return pipeline_lsp_diag_parse_typeck_buf_impl_c(module, arena, source_data, source_len, ctx);
}

XLANG_WEAK int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module,
                                                              struct xlang_slice_uint8_t *source,
                                                              struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_after_parse_ok_impl_c(arena, module, source, ctx);
}
#endif
