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
