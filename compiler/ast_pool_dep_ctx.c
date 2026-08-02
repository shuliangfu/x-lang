/**
 * ast_pool_dep_ctx.c — PipelineDepCtx cold accessors domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (cold APIs; path resolve / load / preprocess orchestration stay in
 * ast_pool.c core):
 * - pipeline_dep_ctx_reset / set_module / set_arena / module_at / arena_at
 * - import_path set/len/byte_at/copy64 / ndep / set_ndep
 * - codegen_prefix_* / path_buf_* / entry_dir_*
 * - ensure/free/heap_destroy source buffers / loaded|preprocess ptr / set_loaded_len
 * - entry_already_parsed / asm_entry_module_only / check_only_mode
 * - use_asm_backend / use_macho_o / use_coff_o / target_arch
 * - current_codegen_* / current_func_index / current_block_ref_at
 * - pipeline_ctx_append_lib_root / lib_root_count/len/copy/byte_at
 * - pipeline_dep_ctx_empty_param_* (reset/append/at/backup/restore)
 *
 * Left in core (mixed with resolve/FS/orchestration):
 * - path_append_from_buf_* / path_append_import_path / resolve_path_*
 * - CodegenOutBuf helpers (not DepCtx)
 * - read_file / load_import / preprocess_len_get / has_earlier_same_import_path
 *
 * Depends on same-TU statics: depctx_sidecar_get, depctx_ensure_slot,
 * grow_vec_*, grow_vec_copy_append, DepCtxSidecar; extern driver_check_only_get.
 *
 * PLATFORM: SHARED — host-cc Cap residual; pipeline/typeck/codegen call these.
 * Wave: 985 · no semantic change · pin stays 77b334842.
 */

/** ---------- PipelineDepCtx dep / lib_root 动态池 ---------- */

void pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = depctx_sidecar_get(ctx, 0);
  if (!sc)
    return;
  sc->dep_modules.len = 0;
  sc->dep_arenas.len = 0;
  sc->dep_path_rows.len = 0;
  sc->dep_path_lens.len = 0;
  sc->lib_root_rows.len = 0;
  sc->lib_root_lens.len = 0;
  ctx->ndep = 0;
  ctx->num_lib_roots = 0;
}

void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m) {
  DepCtxSidecar *sc;
  void **pm;
  if (!ctx || idx < 0)
    return;
  if (!(sc = depctx_sidecar_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
    return;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  if (pm)
    *pm = (void *)m;
  if (idx + 1 > ctx->ndep)
    ctx->ndep = idx + 1;
}

void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a) {
  DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return;
  if (!(sc = depctx_sidecar_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
    return;
  pa = (void **)grow_vec_at(&sc->dep_arenas, idx);
  if (pa)
    *pa = (void *)a;
}

struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  void **pm;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_modules.len)
    return NULL;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  return pm ? (struct ast_Module *)*pm : NULL;
}

struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_arenas.len)
    return NULL;
  pa = (void **)grow_vec_at(&sc->dep_arenas, idx);
  return pa ? (struct ast_ASTArena *)*pa : NULL;
}

void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  if (!ctx || idx < 0 || !bytes || len <= 0)
    return;
  if (!(sc = depctx_sidecar_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
    return;
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  if (!row || !pl)
    return;
  /* wave579 Cap: row is 128 bytes; allow up to 127 path bytes + NUL. */
  n = len > 127 ? 127 : len;
  memset(row, 0, 128);
  memcpy(row, bytes, (size_t)n);
  row[n] = 0;
  *pl = n;
}

int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || idx < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_path_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  return pl ? *pl : 0;
}

uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx *ctx, int32_t idx, int32_t off) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || idx < 0 || off < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

/**
 * Copy dep import path into dst (zero-pad first 128 bytes).
 * wave584 Cap residual: historical name "copy64"; width matches dep_path_rows[128]
 * (wave579). Callers must provide ≥128-byte dst (typeck/codegen already do).
 * PLATFORM: SHARED product dep resolve path.
 */
void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 128);
  if (!ctx || idx < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 127)
    n = 127;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return 0;
  sc = depctx_sidecar_get(ctx, 0);
  if (sc && sc->dep_modules.len > ctx->ndep)
    ctx->ndep = sc->dep_modules.len;
  return ctx->ndep;
}

void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
  if (ctx)
    ctx->ndep = n > 0 ? n : 0;
}

/** codegen.x：读 current_codegen_prefix_len，避免 asm 对大 PipelineDepCtx 字段 FIELD_ACCESS。 */
int32_t pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_prefix_len : 0;
}

/** 读 prefix_mirror[off]；越界或未设置返回 0。 */
uint8_t pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  if (!ctx || off < 0 || off >= ctx->current_codegen_prefix_len || off >= 64)
    return 0;
  return ctx->current_codegen_prefix_mirror[off];
}

/** 将 prefix_mirror 拷入 dst（最多 cap-1 字节，末尾写 NUL）。 */
void pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap) {
  int32_t n, k;
  if (!ctx || !dst || cap <= 0)
    return;
  n = ctx->current_codegen_prefix_len;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = ctx->current_codegen_prefix_mirror[k];
  dst[n] = 0;
}

/** 写入 current_codegen_prefix_mirror 与 len（最多 63 字节）。 */
void pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len) {
  int32_t k, n;
  if (!ctx)
    return;
  n = len > 127 ? 127 : (len > 0 ? len : 0);
  ctx->current_codegen_prefix_len = 0;
  for (k = 0; k < n; k++)
    ctx->current_codegen_prefix_mirror[k] = bytes[k];
  ctx->current_codegen_prefix_mirror[n] = 0;
  ctx->current_codegen_prefix_len = n;
}

/** pipeline.x：返回 path_buf 首地址，供 fs_open_read 等 *u8 API。 */
uint8_t *pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->path_buf : NULL;
}

/** 读 path_buf[off]；越界返回 0。 */
uint8_t pipeline_dep_ctx_path_buf_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  if (!ctx || off < 0 || off >= 512)
    return 0;
  return ctx->path_buf[off];
}

/** 写 path_buf[off]；越界忽略。 */
void pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b) {
  if (!ctx || off < 0 || off >= 512)
    return;
  ctx->path_buf[off] = b;
}

/** pipeline.x：读 entry_dir_len。 */
int32_t pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->entry_dir_len : 0;
}

/** 将 entry_dir_buf 拷入 dst（最多 cap-1 字节，末尾写 NUL）。 */
void pipeline_dep_ctx_entry_dir_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap) {
  int32_t n, k;
  if (!ctx || !dst || cap <= 0)
    return;
  n = ctx->entry_dir_len;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = ctx->entry_dir_buf[k];
  dst[n] = 0;
}


/** ---------- PipelineDepCtx 源缓冲堆分配（根因：避免 ctx 内嵌 4MiB×2 撑爆栈/asm emit） ---------- */

#define PIPELINE_SOURCE_BUF_CAP 4194304

/** 源缓冲内嵌于 ast.x PipelineDepCtx（loaded_buf/preprocess_buf 各 4MiB）；无需堆分配。 */
int32_t pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx) {
  return ctx ? 0 : -1;
}

/** 内嵌缓冲无堆释放；仅清零长度字段。 */
void pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return;
  ctx->loaded_len = 0;
  ctx->preprocess_len = 0;
}

/** calloc 得到的 ctx：先释放堆缓冲再 free 结构体。 */
void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return;
  pipeline_dep_ctx_free_source_buffers(ctx);
  free(ctx);
}

/** pipeline.x：返回 loaded_buf 首地址，供 fs_read 等 *u8 API。 */
uint8_t *pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return NULL;
  return ctx->loaded_buf;
}

/** pipeline.x：返回 preprocess_buf 首地址，供 dep parse_into_with_init_buf 使用。 */
uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return NULL;
  return ctx->preprocess_buf;
}

/** 写 loaded_len（isize）。 */
void pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n) {
  if (ctx)
    ctx->loaded_len = n;
}

/** 读 entry_already_parsed。 */
int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->entry_already_parsed : 0;
}

int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->asm_entry_module_only : 0;
}

extern int32_t driver_check_only_get(void);

/** xlang check 标志在 runtime driver 槽；PipelineDepCtx 无该字段（与 ast.x 布局一致）。 */
int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx) {
  (void)ctx;
  return driver_check_only_get();
}

int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->use_asm_backend : 0;
}

/** 读 use_macho_o；供 user_asm_seed_bridge 等勿自建截断 PipelineDepCtx 布局的 TU 使用。 */
int32_t pipeline_dep_ctx_use_macho_o(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->use_macho_o : 0;
}

/** 读 use_coff_o；Windows -target *-windows-* 且 -o .obj 时为 1。 */
int32_t pipeline_dep_ctx_use_coff_o(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->use_coff_o : 0;
}

/** 读 target_arch；供不暴露完整 PipelineDepCtx 定义的 TU 使用。 */
int32_t pipeline_dep_ctx_target_arch(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->target_arch : 0;
}

/** 读 entry_dir_buf[off]；越界返回 0。 */
uint8_t pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  if (!ctx || off < 0 || off >= ctx->entry_dir_len || off >= 512)
    return 0;
  return ctx->entry_dir_buf[off];
}

int32_t pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_dep_index : -1;
}

struct ast_Module *pipeline_dep_ctx_current_codegen_module(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_module : NULL;
}

struct ast_ASTArena *pipeline_dep_ctx_current_codegen_arena(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_arena : NULL;
}

int32_t pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_func_index : -1;
}

/** typeck EXPR_VAR：读 ctx.current_block_ref（EMIT_HEAVY 勿 X 直接写字段）。 */
int32_t pipeline_dep_ctx_current_block_ref_at(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_block_ref : 0;
}

void pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m) {
  if (ctx)
    ctx->current_codegen_module = m;
}

void pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a) {
  if (ctx)
    ctx->current_codegen_arena = a;
}

void pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  if (ctx)
    ctx->current_codegen_dep_index = ix;
}

void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  if (ctx)
    ctx->current_func_index = ix;
}

int32_t pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!ctx || !path || len <= 0)
    return -1;
  if (!(sc = depctx_sidecar_get(ctx, 1)))
    return -1;
  idx = grow_vec_push(&sc->lib_root_rows);
  if (idx < 0 || grow_vec_push(&sc->lib_root_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, idx);
  if (!row || !pl)
    return -1;
  n = len > 255 ? 255 : len;
  memset(row, 0, 256);
  memcpy(row, path, (size_t)n);
  *pl = n;
  ctx->num_lib_roots = sc->lib_root_rows.len;
  return idx;
}

int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc = ctx ? depctx_sidecar_get(ctx, 0) : NULL;
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || i < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->lib_root_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  return pl ? *pl : 0;
}

void pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (!ctx || i < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->lib_root_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** 读 lib_root 路径第 off 字节；越界或无效返回 0（避免 pipeline.x 侧整段 copy 大缓冲）。 */
uint8_t pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || i < 0 || off < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->lib_root_rows.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

/** codegen 无名形参下标 grow 池（替代 PipelineDepCtx 内联 i32[16]）。 */
void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = depctx_sidecar_get(ctx, 0);
  if (sc)
    sc->empty_param_indices.len = 0;
  ctx->current_func_empty_param_count = 0;
}

int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx *ctx, int32_t pi) {
  DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || !(sc = depctx_sidecar_get(ctx, 1)))
    return -1;
  if (grow_vec_push(&sc->empty_param_indices) < 0)
    return -1;
  slot = (int32_t *)grow_vec_at(&sc->empty_param_indices, sc->empty_param_indices.len - 1);
  if (!slot)
    return -1;
  *slot = pi;
  ctx->current_func_empty_param_count = sc->empty_param_indices.len;
  return sc->empty_param_indices.len - 1;
}

int32_t pipeline_dep_ctx_empty_param_at(struct ast_PipelineDepCtx *ctx, int32_t i) {
  DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || i < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->empty_param_indices.len)
    return -1;
  slot = (int32_t *)grow_vec_at(&sc->empty_param_indices, i);
  return slot ? *slot : -1;
}

void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx || !(sc = depctx_sidecar_get(ctx, 1)))
    return;
  sc->empty_param_backup.len = 0;
  grow_vec_copy_append(&sc->empty_param_backup, &sc->empty_param_indices);
}

void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx || !(sc = depctx_sidecar_get(ctx, 0)))
    return;
  sc->empty_param_indices.len = 0;
  grow_vec_copy_append(&sc->empty_param_indices, &sc->empty_param_backup);
  ctx->current_func_empty_param_count = sc->empty_param_indices.len;
}

/* wave1178 G.7: pipeline_dep_ctx_typeck_loop_depth_at migrated from
 * pipeline_glue.c L3159-3162. Colocated with PipelineDepCtx cold accessor
 * domain — reads ctx.typeck_loop_depth for break/continue X-emit to avoid
 * self-host asm SIGSEGV when typeck.x reads PipelineDepCtx fields directly.
 *
 * No glue.c callsites (sole callers are typeck_gen.c seed via extern:
 * typeck_loop_depth_push/pop + break/continue emit).
 * No static deps — reads struct field directly. Fwd decl retained in
 * glue.c L3160 (callsite only by seed via extern, no glue.c callers).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/**
 * Read ctx.typeck_loop_depth for break/continue X-emit.
 * Why: typeck.x must not read PipelineDepCtx fields directly during self-host
 *      asm emit (causes SIGSEGV); this helper provides a safe C-resident read.
 * Contract: returns 0 when ctx is null; otherwise returns ctx->typeck_loop_depth.
 */
int32_t pipeline_dep_ctx_typeck_loop_depth_at(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->typeck_loop_depth : 0;
}
