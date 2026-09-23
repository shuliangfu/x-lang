/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* Prefer existing seed faces; cast only. */
extern uint8_t *pipeline_dep_ctx_path_buf_ptr(void *ctx);
extern uint8_t *pipeline_dep_ctx_loaded_buf_ptr(void *ctx);
extern void pipeline_dep_ctx_set_loaded_len(void *ctx, int64_t n);
extern uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(void *ctx);
extern int32_t preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out, int32_t out_cap);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t pl);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_slot_for_path(const char *path);
extern ptrdiff_t std_fs_fs_read(int fd, void *buf, size_t count);

/* LP64 offsets — match pure pipe_pctx_off_* */
static int32_t wave101_off_loaded_len(void) { return 4195344; }
static int32_t wave101_off_preprocess_len(void) { return 8389656; }

static void wave101_store_i32_le(uint8_t *base, int32_t off, int32_t v) {
  uint32_t u;
  if (!base || off < 0)
    return;
  u = (uint32_t)v;
  base[off] = (uint8_t)(u & 255u);
  base[off + 1] = (uint8_t)((u / 256u) & 255u);
  base[off + 2] = (uint8_t)((u / 65536u) & 255u);
  base[off + 3] = (uint8_t)((u / 16777216u) & 255u);
}

static int32_t wave101_load_i32_le(uint8_t *base, int32_t off) {
  uint32_t b0, b1, b2, b3, u;
  if (!base || off < 0)
    return 0;
  b0 = base[off];
  b1 = base[off + 1];
  b2 = base[off + 2];
  b3 = base[off + 3];
  u = b0 + b1 * 256u + b2 * 65536u + b3 * 16777216u;
  return (int32_t)u;
}

static int64_t wave101_load_i64_le(uint8_t *base, int32_t off) {
  uint64_t u = 0;
  int i;
  if (!base || off < 0)
    return 0;
  for (i = 0; i < 8; i++)
    u |= ((uint64_t)base[off + i]) << (8 * i);
  return (int64_t)u;
}

int32_t pipeline_dep_ctx_preprocess_len_get(void *ctx) {
  if (!ctx)
    return -1;
  return wave101_load_i32_le((uint8_t *)ctx, wave101_off_preprocess_len());
}

/**
 * Resolve-read embed fill (4MiB pin wall). Cold twin under seed.
 * M2 Class E: .x thin leave = runtime_pipeline_abi_read_file_x_view_thin.x
 * (wave297 C→.x via -E+$CC inject; was C strong overlay).
 * PLATFORM: SHARED — view whole file; reject > pin embed (no silent truncate).
 */
int32_t pipeline_read_file_x(void *ctx) {
  uint8_t *path;
  uint8_t *buf;
  XlangRuntimeFileView raw_view;
  if (!ctx)
    return -1;
  path = pipeline_dep_ctx_path_buf_ptr(ctx);
  buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  if (!path || !buf)
    return -1;
  /* PLATFORM: SHARED — view whole file; reject > pin embed (no silent truncate).
   * Product import orch heap-reads; this helper still fills ctx.loaded_buf. */
  memset(&raw_view, 0, sizeof(raw_view));
  if (runtime_read_file_view((const char *)path, &raw_view) != 0)
    return -1;
  if (raw_view.length > (size_t)4194304) {
    runtime_release_file_view(&raw_view);
    return -1;
  }
  if (raw_view.length > 0) {
    if (!raw_view.data) {
      runtime_release_file_view(&raw_view);
      return -1;
    }
    memcpy(buf, raw_view.data, raw_view.length);
  }
  pipeline_dep_ctx_set_loaded_len(ctx, (int64_t)raw_view.length);
  runtime_release_file_view(&raw_view);
  return 0;
}

int32_t pipeline_read_file_x_impl_c(void *ctx) {
  return pipeline_read_file_x(ctx);
}

int32_t pipeline_read_file_x_c(void *ctx) {
  return pipeline_read_file_x(ctx);
}

int32_t pipeline_read_fd_into_loaded_buf(void *ctx, int32_t fd) {
  uint8_t *buf;
  ptrdiff_t n;
  if (!ctx || fd < 0)
    return -1;
  buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  if (!buf)
    return -1;
  n = std_fs_fs_read(fd, buf, (size_t)4194304);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, (int64_t)n);
  return 0;
}

int32_t pipeline_preprocess_loaded_into_ctx(void *ctx) {
  uint8_t *loaded;
  uint8_t *prep;
  int64_t loaded_len;
  int32_t out_len;
  if (!ctx)
    return -1;
  loaded = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  prep = pipeline_dep_ctx_preprocess_buf_ptr(ctx);
  if (!loaded || !prep)
    return -1;
  loaded_len = wave101_load_i64_le((uint8_t *)ctx, wave101_off_loaded_len());
  out_len = preprocess_x_buf(loaded, (ptrdiff_t)loaded_len, prep, 4194304);
  if (out_len < 0)
    return -9;
  wave101_store_i32_le((uint8_t *)ctx, wave101_off_preprocess_len(), out_len);
  return 0;
}

void pipeline_bind_import_dep_buffers(void *ctx, int32_t import_idx) {
  if (!ctx || import_idx < 0)
    return;
  ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)(struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_ASTArena *)(struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
  ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)(struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_Module *)(struct ast_Module *)driver_dep_module_buf(import_idx));
}

int32_t pipeline_try_bind_seeded_import(void *ctx, int32_t import_idx, int32_t global_slot) {
  if (!ctx || import_idx < 0)
    return 0;
  if (global_slot >= 0 && driver_dep_seeded_get(global_slot) != 0) {
    ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(global_slot));
    ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(global_slot));
    return 1;
  }
  if (driver_dep_seeded_get(import_idx) != 0) {
    ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
    ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
    return 1;
  }
  return 0;
}

int32_t pipeline_sync_one_dep_slot(void *module, void *ctx, int32_t dep_i) {
  uint8_t sync_path[128];
  int32_t sync_slot;
  int32_t pl;
  if (!module || !ctx || dep_i < 0)
    return -1;
  (void)parser_copy_module_import_path64(module, dep_i, sync_path);
  sync_slot = driver_dep_slot_for_path((const char *)sync_path);
  if (sync_slot < 0)
    sync_slot = dep_i;
  pl = 0;
  while (pl < 64 && sync_path[pl] != 0)
    pl = pl + 1;
  if (pl > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_i, sync_path, pl);
  ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)ctx, dep_i, (struct ast_Module *)driver_dep_module_buf(sync_slot));
  ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)ctx, dep_i, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
  return 0;
}

/* wave102 asm_diag leave cold twins — former pipeline_asm_diag.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong asm_diag_* after host-cc leave. Product hybrid defines FROM_X so
 * this block is excluded; pure prints full BODY_TRACE metrics via write(2). */
extern char *link_abi_getenv(const char *name);
/* Cold twin of static asm_env_build_skip_typeck (emit_heavy_env same-TU helper). */
static int32_t wave102_asm_env_build_skip_typeck(void) {
  const char *e = link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

int32_t asm_diag_start_func_skip(void) {
  const char *e = link_abi_getenv("XLANG_ASM_START_FUNC");
  const char *allow = link_abi_getenv("XLANG_ASM_ALLOW_START_FUNC");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 0;
  if ((allow == NULL || allow[0] == '\0' || allow[0] == '0') &&
      wave102_asm_env_build_skip_typeck() != 0 &&
      link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY") != NULL) {
    const char *em = link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY");
    if (em && em[0] != '\0' && em[0] != '0')
      return 0;
  }
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 0;
  if (v > 100000)
    return 100000;
  return (int32_t)v;
}

void asm_diag_trace_func_body(struct ast_ASTArena *arena, int32_t body_ref) {
  /* Class AX: Cap XLANG_ASM_BODY_TRACE retired. */
  (void)arena;
  (void)body_ref;
}

void asm_diag_trace_body_ref(int32_t body_ref) {
  /* Class AX: Cap XLANG_ASM_BODY_TRACE retired. */
  (void)body_ref;
}

void asm_diag_trace_emit_phase(int32_t phase) {
  /* Class AX: Cap XLANG_ASM_BODY_TRACE retired. */
  (void)phase;
}

void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len) {
  /* Class AX: Cap XLANG_ASM_FUNC_TRACE retired. */
  (void)func_idx;
  (void)name;
  (void)name_len;
}

void asm_diag_trace_func(uint8_t *name, int32_t name_len) {
  asm_diag_trace_func_idx(-1, name, name_len);
}

/* wave103 lsp_diag leave cold twins — former pipeline_lsp_diag.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong lsp_diag_*_c after host-cc leave. */
extern int32_t pipeline_load_and_sync_direct_import_deps_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_typeck_parsed_module_c(void *module, void *arena, void *ctx, int32_t fail_mapped);
extern int32_t pipeline_parse_set_main_from_buf_c(void *module, void *arena, uint8_t *data, int32_t len);
extern int32_t driver_is_large_stack_thread(void);
extern void driver_run_thread_on_large_stack(uint8_t *fn, uint8_t *arg);

int32_t lsp_diag_typeck_after_load_c(void *module, void *arena, void *ctx) {
  int32_t load_rc;
  if (!module || !arena || !ctx)
    return -1;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

int32_t lsp_diag_parse_entry_buf_c(void *module, void *arena, uint8_t *source_data, int32_t source_len) {
  return pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
}

static int32_t wave103_lsp_diag_parse_typeck_buf_impl(void *module, void *arena, uint8_t *source_data,
                                                     int32_t source_len, void *ctx) {
  int32_t parse_rc;
  int32_t load_rc;
  if (!module || !arena || !ctx || !source_data || source_len <= 0)
    return -2;
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  if (parse_rc != 0)
    return parse_rc;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

/* LP64 pack matches pure: module@0 arena@8 src@16 len@24 ctx@32 result@40. */
typedef struct {
  void *module;
  void *arena;
  uint8_t *source_data;
  int32_t source_len;
  void *ctx;
  int32_t result;
} Wave103LspDiagArgs;

static void *wave103_lsp_diag_parse_typeck_thread_fn(void *arg) {
  Wave103LspDiagArgs *a = (Wave103LspDiagArgs *)arg;
  a->result = wave103_lsp_diag_parse_typeck_buf_impl(a->module, a->arena, a->source_data, a->source_len, a->ctx);
  return NULL;
}

uint8_t *lsp_diag_parse_typeck_thread_fn(uint8_t *arg) {
  (void)wave103_lsp_diag_parse_typeck_thread_fn(arg);
  return NULL;
}

uint8_t *lsp_diag_parse_typeck_thread_fn_ptr(void) {
  return (uint8_t *)(void *)&wave103_lsp_diag_parse_typeck_thread_fn;
}

int32_t lsp_diag_parse_typeck_buf_c(void *module, void *arena, uint8_t *source_data, int32_t source_len,
                                   void *ctx) {
  Wave103LspDiagArgs args;
  if (driver_is_large_stack_thread())
    return wave103_lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  args.module = module;
  args.arena = arena;
  args.source_data = source_data;
  args.source_len = source_len;
  args.ctx = ctx;
  args.result = -99;
  driver_run_thread_on_large_stack((uint8_t *)(void *)&wave103_lsp_diag_parse_typeck_thread_fn,
                                   (uint8_t *)&args);
  if (args.result == -99)
    return wave103_lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  return args.result;
}
