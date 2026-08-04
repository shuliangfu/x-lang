/* pipeline_import_bind.c — fs 读 + import bind/sync 域（自 ast_pool.c 抽出）
 *
 * pipeline_read_file_x_impl_c／_c／read_fd_into_loaded_buf：单点 POSIX fs read → ctx.loaded_buf
 *   （B-20 xlang_read_file_into_path；product pure owns read_file_x，impl 为 cold twin）。
 * pipeline_dep_ctx_preprocess_len_get：读 ctx.preprocess_len（避免 FIELD_ACCESS emit 失败）。
 * pipeline_preprocess_loaded_into_ctx／bind_import_dep_buffers／try_bind_seeded_import／
 *   sync_one_dep_slot：import dep 缓冲绑定 + driver seed 槽对齐（XLANG_WEAK cold twin；
 *   product pure 走 runtime_pipeline_abi）。
 * 依赖：pipeline_dep_ctx_* 访问器 + driver_dep_* extern（先于此 include，resolve_path/早期）；
 *   xlang_read_file_into_path／std_fs_*（resolve_path.c，先于此 include）。
 * 同 TU #include（resolve_path 之后）；公共符号 + XLANG_WEAK。 */

/** read_file_x X emit：单点 fs read + loaded_len（前向声明，供 read_file_x / impl_c 调用）。 */
int32_t pipeline_read_fd_into_loaded_buf(struct ast_PipelineDepCtx *ctx, int32_t fd);

/**
 * M8-tail strict 回退：`read_file_x` 读 ctx.path_buf 文件到 ctx.loaded_buf（B-20 POSIX，非 fopen）。
 * wave95: product pure owns pipeline_read_file_x; this impl remains cold twin target.
 * PLATFORM: SHARED.
 */
int32_t pipeline_read_file_x_impl_c(struct ast_PipelineDepCtx *ctx) {
  int32_t n;

  if (!ctx)
    return -1;
  n = xlang_read_file_into_path((const char *)pipeline_dep_ctx_path_buf_ptr(ctx),
                               pipeline_dep_ctx_loaded_buf_ptr(ctx),
                               (size_t)PIPELINE_SOURCE_BUF_CAP);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, (ptrdiff_t)n);
  return 0;
}

/** M8-tail：优先 dispatch 至 pipeline_read_file_x（X 或 weak impl_c）。 */
int32_t pipeline_read_file_x_c(struct ast_PipelineDepCtx *ctx) {
  return pipeline_read_file_x(ctx);
}

/**
 * read_file_x X emit：单点 fs read + loaded_len 写入（避免 X 侧 fs_posix_read_c 嵌套 ptr 实参 SIGSEGV）。
 */
int32_t pipeline_read_fd_into_loaded_buf(struct ast_PipelineDepCtx *ctx, int32_t fd) {
  ptrdiff_t n;

  if (!ctx || fd < 0)
    return -1;
  n = std_fs_fs_read(fd, pipeline_dep_ctx_loaded_buf_ptr(ctx), (size_t)PIPELINE_SOURCE_BUF_CAP);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, n);
  return 0;
}

extern int32_t preprocess_x_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                              int32_t out_cap);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern const char *driver_dep_path_registry_at(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t *path);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[128]);

/** pipeline_load_import_from_disk X emit：读 ctx.preprocess_len（避免 FIELD_ACCESS emit 失败）。 */
int32_t pipeline_dep_ctx_preprocess_len_get(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->preprocess_len : -1;
}

/**
 * loaded_buf → preprocess_buf；成功返回 0，preprocess 失败返回 -9。
 * wave95: product pure owns pipeline_preprocess_loaded_into_ctx (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_preprocess_loaded_into_ctx(struct ast_PipelineDepCtx *ctx) {
  int32_t out_len;

  if (!ctx)
    return -1;
  out_len = preprocess_x_buf(pipeline_dep_ctx_loaded_buf_ptr(ctx), ctx->loaded_len,
                                         pipeline_dep_ctx_preprocess_buf_ptr(ctx), PIPELINE_SOURCE_BUF_CAP);
  if (out_len < 0)
    return -9;
  ctx->preprocess_len = out_len;
  return 0;
}

/**
 * import 槽绑定 driver dep arena/module 缓冲（指针 cast 须 C glue）。
 * wave94: product pure owns pipeline_bind_import_dep_buffers (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK void pipeline_bind_import_dep_buffers(struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  if (!ctx || import_idx < 0)
    return;
  pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
  pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
}

/**
 * 若 global_slot 或 import_idx 已由 driver seed，绑定 arena/module 槽并返回 1；未 seed 返回 0。
 * C glue：X 侧 (struct ast_ASTArena *)driver_dep_arena_buf 指针 cast 在 M8 asm 真 emit 时易 SIGSEGV。
 * wave93: product pure owns pipeline_try_bind_seeded_import (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_try_bind_seeded_import(struct ast_PipelineDepCtx *ctx, int32_t import_idx, int32_t global_slot) {
  if (!ctx || import_idx < 0)
    return 0;
  if (global_slot >= 0 && driver_dep_seeded_get(global_slot) != 0) {
    pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(global_slot));
    pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(global_slot));
    return 1;
  }
  if (driver_dep_seeded_get(import_idx) != 0) {
    pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
    pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
    return 1;
  }
  return 0;
}

/**
 * 将 dep_i 槽与 driver 全局 seed 槽对齐；C glue 单点指针 cast。
 * wave94: product pure owns pipeline_sync_one_dep_slot (runtime_pipeline_abi.x).
 * Keep XLANG_WEAK cold twin for links without pure pipeline_abi / PREFER hybrid.
 * PLATFORM: SHARED — ELF weak overridden by pure.
 */
XLANG_WEAK int32_t pipeline_sync_one_dep_slot(struct ast_Module *module, struct ast_PipelineDepCtx *ctx, int32_t dep_i) {
  uint8_t sync_path[128];
  int32_t sync_slot;

  if (!module || !ctx || dep_i < 0)
    return -1;
  (void)parser_copy_module_import_path64(module, dep_i, sync_path);
  sync_slot = driver_dep_slot_for_path(sync_path);
  if (sync_slot < 0)
    sync_slot = dep_i;
  {
    int32_t pl = 0;
    while (pl < 64 && sync_path[pl] != 0)
      pl = pl + 1;
    if (pl > 0)
      pipeline_dep_ctx_set_import_path(ctx, dep_i, sync_path, pl);
  }
  pipeline_dep_ctx_set_module(ctx, dep_i, (struct ast_Module *)driver_dep_module_buf(sync_slot));
  pipeline_dep_ctx_set_arena(ctx, dep_i, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
  return 0;
}
