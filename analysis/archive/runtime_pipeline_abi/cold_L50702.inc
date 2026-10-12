/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X /* reopen wave178 FROM_X after wave271 */

/* ==========================================================================
 * WAVE272: PipelineDepCtx Cap residual pure-owned leave cold twins
 * + DepCtxSidecar process table (single authority under non-FROM_X).
 * PLATFORM: SHARED freestanding DepCtx Cap leave · dual-end L2.
 * ========================================================================== */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

#ifndef WAVE272_DEP_CTX_COLD
#define WAVE272_DEP_CTX_COLD 1

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* GrowVec from wave271 cold twins above in this seed. */

#ifndef MAX_DEP_CTX_SIDECARS
#define MAX_DEP_CTX_SIDECARS 64
#endif
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

/* XLANG_PABI_DEP_CTX_THIN_BEGIN */
typedef struct {
  struct ast_PipelineDepCtx *ctx;
  int used;
  GrowVec dep_modules;
  GrowVec dep_arenas;
  GrowVec dep_path_rows;
  GrowVec dep_path_lens;
  GrowVec lib_root_rows;
  GrowVec lib_root_lens;
  GrowVec empty_param_indices;
  GrowVec empty_param_backup;
} Wave272DepCtxSidecar;

static Wave272DepCtxSidecar g_wave272_depctx_sc[MAX_DEP_CTX_SIDECARS];

static Wave272DepCtxSidecar *wave272_depctx_get(struct ast_PipelineDepCtx *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_wave272_depctx_sc[i].used && g_wave272_depctx_sc[i].ctx == ctx)
      return &g_wave272_depctx_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (!g_wave272_depctx_sc[i].used) {
      Wave272DepCtxSidecar *sc = &g_wave272_depctx_sc[i];
      sc->ctx = ctx;
      sc->used = 1;
      if (!grow_vec_init(&sc->dep_modules, sizeof(void *), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->dep_arenas, sizeof(void *), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->dep_path_rows, 256, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->dep_path_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->lib_root_rows, 256, AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->lib_root_lens, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->empty_param_indices, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      if (!grow_vec_init(&sc->empty_param_backup, sizeof(int32_t), AST_POOL_INIT_CAP))
        return NULL;
      return sc;
    }
  }
  return NULL;
}

static int wave272_depctx_ensure_slot(Wave272DepCtxSidecar *sc, int32_t idx) {
  int32_t need;
  void **pm;
  void **pa;
  uint8_t *row;
  int32_t *pl;
  if (!sc || idx < 0)
    return 0;
  need = idx + 1;
  while (sc->dep_modules.len < need) {
    if (grow_vec_push(&sc->dep_modules) < 0)
      return 0;
    pm = (void **)grow_vec_at(&sc->dep_modules, sc->dep_modules.len - 1);
    if (pm)
      *pm = NULL;
    if (grow_vec_push(&sc->dep_arenas) < 0)
      return 0;
    pa = (void **)grow_vec_at(&sc->dep_arenas, sc->dep_arenas.len - 1);
    if (pa)
      *pa = NULL;
    if (grow_vec_push(&sc->dep_path_rows) < 0)
      return 0;
    row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, sc->dep_path_rows.len - 1);
    if (row)
      memset(row, 0, 256);
    if (grow_vec_push(&sc->dep_path_lens) < 0)
      return 0;
    pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, sc->dep_path_lens.len - 1);
    if (pl)
      *pl = 0;
  }
  return 1;
}

static void wave272_depctx_free(Wave272DepCtxSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->dep_modules);
  grow_vec_free(&sc->dep_arenas);
  grow_vec_free(&sc->dep_path_rows);
  grow_vec_free(&sc->dep_path_lens);
  grow_vec_free(&sc->lib_root_rows);
  grow_vec_free(&sc->lib_root_lens);
  grow_vec_free(&sc->empty_param_indices);
  grow_vec_free(&sc->empty_param_backup);
  memset(sc, 0, sizeof(*sc));
}

void pipeline_dep_ctx_sidecar_release(struct ast_PipelineDepCtx *ctx) {
  int i;
  if (!ctx)
    return;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_wave272_depctx_sc[i].used && g_wave272_depctx_sc[i].ctx == ctx) {
      wave272_depctx_free(&g_wave272_depctx_sc[i]);
      return;
    }
  }
}

/** ---------- PipelineDepCtx dep / lib_root 动态池 ---------- */

void pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  Wave272DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = wave272_depctx_get(ctx, 0);
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
  Wave272DepCtxSidecar *sc;
  void **pm;
  if (!ctx || idx < 0)
    return;
  if (!(sc = wave272_depctx_get(ctx, 1)) || !wave272_depctx_ensure_slot(sc, idx))
    return;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  if (pm)
    *pm = (void *)m;
  if (idx + 1 > ctx->ndep)
    ctx->ndep = idx + 1;
}

void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a) {
  Wave272DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return;
  if (!(sc = wave272_depctx_get(ctx, 1)) || !wave272_depctx_ensure_slot(sc, idx))
    return;
  pa = (void **)grow_vec_at(&sc->dep_arenas, idx);
  if (pa)
    *pa = (void *)a;
}

struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  Wave272DepCtxSidecar *sc;
  void **pm;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = wave272_depctx_get(ctx, 0)) || idx >= sc->dep_modules.len)
    return NULL;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  return pm ? (struct ast_Module *)*pm : NULL;
}

struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  Wave272DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = wave272_depctx_get(ctx, 0)) || idx >= sc->dep_arenas.len)
    return NULL;
  pa = (void **)grow_vec_at(&sc->dep_arenas, idx);
  return pa ? (struct ast_ASTArena *)*pa : NULL;
}

void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len) {
  Wave272DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  if (!ctx || idx < 0 || !bytes || len <= 0)
    return;
  if (!(sc = wave272_depctx_get(ctx, 1)) || !wave272_depctx_ensure_slot(sc, idx))
    return;
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  if (!row || !pl)
    return;
  /* wave579 Cap: row is 128 bytes; allow up to 127 path bytes + NUL. */
  n = len > 255 ? 255 : len;
  memset(row, 0, 256);
  memcpy(row, bytes, (size_t)n);
  row[n] = 0;
  *pl = n;
}

int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  Wave272DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || idx < 0 || !(sc = wave272_depctx_get(ctx, 0)) || idx >= sc->dep_path_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  return pl ? *pl : 0;
}

uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx *ctx, int32_t idx, int32_t off) {
  Wave272DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || idx < 0 || off < 0 || !(sc = wave272_depctx_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

/**
 * Copy dep import path into dst (zero-pad 256 bytes).
 * Cap 4.2.8: ABI name kept as copy64; writer memset(dst,0,256). Callers must
 * provide ≥256-byte dst (dep_path_rows payload still ≤127 chars + NUL pad).
 * PLATFORM: SHARED product dep resolve path.
 */
void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst) {
  Wave272DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 256);
  if (!ctx || idx < 0 || !(sc = wave272_depctx_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
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
  Wave272DepCtxSidecar *sc;
  if (!ctx)
    return 0;
  sc = wave272_depctx_get(ctx, 0);
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
  n = len > 255 ? 255 : (len > 0 ? len : 0);
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

/** calloc 得到的 ctx：先释放 DepCtx sidecar + 堆缓冲再 free 结构体。
 * wave1228: g_xlang_depctx_sc is process-wide (MAX 64). free(ctx) alone left
 * slots used with dangling keys → batch check exhausts table and truncates
 * later files. PLATFORM: SHARED — release-before-free (arena/module twin). */
void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return;
  if (pipeline_asm_debug_enabled())
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm debug: dep_ctx_heap_destroy begin");
  /* same-TU: pipeline_dep_ctx_sidecar_release in ast_pool.c */
  pipeline_dep_ctx_sidecar_release(ctx);
  pipeline_dep_ctx_free_source_buffers(ctx);
  free(ctx);
  if (pipeline_asm_debug_enabled())
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "asm debug: dep_ctx_heap_destroy end");
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
  Wave272DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!ctx || !path || len <= 0)
    return -1;
  if (!(sc = wave272_depctx_get(ctx, 1)))
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
  Wave272DepCtxSidecar *sc = ctx ? wave272_depctx_get(ctx, 0) : NULL;
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  Wave272DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || i < 0 || !(sc = wave272_depctx_get(ctx, 0)) || i >= sc->lib_root_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  return pl ? *pl : 0;
}

void pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap) {
  Wave272DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (!ctx || i < 0 || !(sc = wave272_depctx_get(ctx, 0)) || i >= sc->lib_root_rows.len)
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
  Wave272DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || i < 0 || off < 0 || !(sc = wave272_depctx_get(ctx, 0)) || i >= sc->lib_root_rows.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

/** codegen 无名形参下标 grow 池（替代 PipelineDepCtx 内联 i32[16]）。 */
void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx *ctx) {
  Wave272DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = wave272_depctx_get(ctx, 0);
  if (sc)
    sc->empty_param_indices.len = 0;
  ctx->current_func_empty_param_count = 0;
}

int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx *ctx, int32_t pi) {
  Wave272DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || !(sc = wave272_depctx_get(ctx, 1)))
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
  Wave272DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || i < 0 || !(sc = wave272_depctx_get(ctx, 0)) || i >= sc->empty_param_indices.len)
    return -1;
  slot = (int32_t *)grow_vec_at(&sc->empty_param_indices, i);
  return slot ? *slot : -1;
}

void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx *ctx) {
  Wave272DepCtxSidecar *sc;
  if (!ctx || !(sc = wave272_depctx_get(ctx, 1)))
    return;
  sc->empty_param_backup.len = 0;
  grow_vec_copy_append(&sc->empty_param_backup, &sc->empty_param_indices);
}

void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx *ctx) {
  Wave272DepCtxSidecar *sc;
  if (!ctx || !(sc = wave272_depctx_get(ctx, 0)))
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

/* XLANG_PABI_DEP_CTX_THIN_END */
#endif /* WAVE272_DEP_CTX_COLD */
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X — wave272 cold twins */

/* ==========================================================================
 * WAVE273: ELF/Mach-O ctx + write_o Cap residual pure-owned leave cold twins
 * PLATFORM: SHARED freestanding ELF leave · dual-end L2.
 * Live authority: runtime_pipeline_abi.x #[no_mangle] under FROM_X hybrid.
 * ========================================================================== */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X

/* XLANG_PABI_ELF_CTX_THIN_BEGIN */
#ifndef WAVE273_ELF_DOMAIN_COLD
#define WAVE273_ELF_DOMAIN_COLD 1

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/* driver diagnostics live in pipeline_glue / product host */
extern void driver_diagnostic_asm_elf_unresolved_patch(const uint8_t *name, int32_t name_len);
extern void driver_diagnostic_asm_macho_empty_reloc(int32_t reloc_idx);
extern void driver_diagnostic_asm_macho_missing_und_reloc(int32_t reloc_idx);
extern void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt, ...);
extern char *link_abi_getenv(const char *name);
extern int32_t codegen_out_buf_len(void *out);
extern void codegen_out_buf_set_len(void *out, int32_t n);

#ifndef PIPELINE_CODEGEN_OUTBUF_CAP
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184
#endif

/* CodegenOutBuf is opaque to residual; writers cast via void* helpers above. */
struct codegen_CodegenOutBuf;

/* ============================================================================
 * pipeline_elf_ctx.c — ELF/Mach-O codegen ctx accessors + label/sym/patch/reloc
 *
 * wave1247 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   PipelineElfCtxAccess layout + PGO-Lite + reloc/label/patch/shndx/common sidecar
 *   ctx accessors (set_emit_hot/total_code_len/emit_code_len/append_bytes/code_data_ptr)
 *   label_mod_scope + add_label/ensure_label/pad_code/add_sym/add_common_sym
 *   append_patch/resolve_patches + reloc_sym_name + log_unresolved_patch
 *
 * Included from ast_pool.c (replaces former inline body). Writers
 * (pipeline_elf_write_o.c) included mid-file so writers share one layout
 * authority (G.7). Not a separate .o.
 *
 * PLATFORM: SHARED layout; ELF ctx primary on LINUX; Mach-O underscore on MACOS.
 * ============================================================================ */
/** ElfCodegenCtx 标签/补丁/重定位/符号表行数；与 platform/elf.x 内联数组维度一致（改须全链 rebuild）。
 * parser EMIT_HEAVY 真 emit 时 num_patches/labels 可上千；4096 与 elf.x 16384 漂移会导致 resolve_patches 失败。 */
#define PIPELINE_ELF_CTX_TABLE_CAP 16384
/* wave651: patches-only 65536 for the FORCE monofile full-body emit
 * (labels/relocs/syms stay 16384). Shifts fields after patches.
 * Twin of pure pipe_elf_patch_cap. PLATFORM: SHARED. */
#define PIPELINE_ELF_CTX_PATCH_CAP 65536
/* wave652: labels-only 65536 (mono full-body ~26K labels); relocs/syms stay
 * 16384. Twin of pure pipe_elf_label_cap. PLATFORM: SHARED. */
#define PIPELINE_ELF_CTX_LABEL_CAP 65536
/** 堆 sidecar 扩 reloc 总上限（内联 16384 + heap 16384）。 */
#define PIPELINE_ELF_CTX_RELOC_TOTAL_CAP 32768
#define PIPELINE_ELF_CTX_RELOC_HEAP_CAP (PIPELINE_ELF_CTX_RELOC_TOTAL_CAP - PIPELINE_ELF_CTX_TABLE_CAP)

/**
 * platform/elf.x：ElfCodegenCtx 体量大，.x/asm 对 patches[pi].* / relocs[ri].* 字段写入 typeck 失败；
 * 布局须与 elf.x 中 ElfLabelEntry / ElfPatchEntry / ElfRelocEntry / ElfSymEntry 前缀一致（改 elf.x 时同步）。
 */
/** 与 elf.x ElfLabelEntry 布局一致（无 code_shndx；PGO 段索引见 sidecar）。 */
typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t offset;
} PipelineElfLabelEntry;

/** 与 elf.x ElfPatchEntry 布局一致。 */
typedef struct {
  int32_t rel32_offset;
  uint8_t name[256];
  int32_t name_len;
  int32_t patch_imm_bits;
} PipelineElfPatchEntry;

/** 与 elf.x ElfRelocEntry 布局一致。 */
typedef struct {
  int32_t offset;
  int32_t name_len;
} PipelineElfRelocEntry;

/** heap reloc sidecar 专用：内联 relocs[] 无 code_shndx 字段。 */
typedef struct {
  int32_t offset;
  int32_t name_len;
  int32_t code_shndx;
} PipelineElfRelocHeapEntry;

typedef struct {
  uint8_t name[256];
  int32_t name_len;
  int32_t offset;
  /** 符号所属段：1=.text，2=.text.hot，3=.text.unlikely。 */
  int32_t sym_shndx;
} PipelineElfSymEntry;

typedef struct {
  uint8_t bytes[256];
} PipelineElfRelocSymName64;

/** code_data 之前的完整前缀；glue 用 offsetof 取 e_machine / code_data，避免手算偏移漂移。 */
typedef struct {
  int32_t code_len;
  PipelineElfLabelEntry labels[PIPELINE_ELF_CTX_LABEL_CAP];
  int32_t num_labels;
  PipelineElfPatchEntry patches[PIPELINE_ELF_CTX_PATCH_CAP];
  int32_t num_patches;
  PipelineElfRelocEntry relocs[PIPELINE_ELF_CTX_TABLE_CAP];
  PipelineElfRelocSymName64 reloc_sym_names[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_relocs;
  PipelineElfSymEntry syms[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_syms;
  int32_t sym_name_len;
  int32_t e_machine;
  int32_t reloc_type_r_pc32;
  int32_t current_frame_size;
  int32_t macho_leading_underscore;
  /** PGO-Lite：.text.hot 已写字节数；与 code_data 之后的 code_hot_data 对应。 */
  int32_t code_hot_len;
  /** 当前 emit 段：0=.text，非 0=.text.hot（须 XLANG_WPO_PGO_HOT=1）。 */
  int32_t emit_hot;
} PipelineElfCtxAccess;

/** code_data 容量；与 elf.x ElfCodegenCtx.code_data 维度一致（8716288，勿用旧 8388608）。 */
#define PIPELINE_ELF_CTX_CODE_BUF_CAP 8716288
/** .text.hot 缓冲（用户程序热段通常远小于 cold；减小 ctx 体积避免 malloc/栈压力）。 */
#define PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP 1048576

/** platform_elf_ElfCodegenCtx 后缀字段偏移（须与 elf.x / pipeline_gen 一致）。 */
enum {
  kPipelineElfCtxEMachineOff = (int)offsetof(PipelineElfCtxAccess, e_machine),
  kPipelineElfCtxMachoUnderscoreOff = (int)offsetof(PipelineElfCtxAccess, macho_leading_underscore),
  kPipelineElfCtxCodeDataOff = (int)sizeof(PipelineElfCtxAccess),
  kPipelineElfCtxCodeHotDataOff = (int)sizeof(PipelineElfCtxAccess) + PIPELINE_ELF_CTX_CODE_BUF_CAP,
  kPipelineElfCtxSymNameDataOff =
      (int)sizeof(PipelineElfCtxAccess) + PIPELINE_ELF_CTX_CODE_BUF_CAP + PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP
};

/** 与 elf.x ElfCodegenCtx 前缀一致；漂移会导致 append_bytes 写穿 malloc 区。 */
_Static_assert(sizeof(PipelineElfLabelEntry) == 264, "PipelineElfLabelEntry must match elf.x ElfLabelEntry (Cap 4.2.8: name[128]→[256])");
_Static_assert(sizeof(PipelineElfPatchEntry) == 268, "PipelineElfPatchEntry must match elf.x ElfPatchEntry (wave577 Cap: name[64]→[128])");
_Static_assert(sizeof(PipelineElfRelocEntry) == 8, "PipelineElfRelocEntry must match elf.x ElfRelocEntry");
_Static_assert(sizeof(PipelineElfSymEntry) == 268, "PipelineElfSymEntry must match elf.x ElfSymEntry (wave577 Cap: name[64]→[128])");
_Static_assert(kPipelineElfCtxCodeDataOff == (int)sizeof(PipelineElfCtxAccess),
               "PipelineElfCtxAccess prefix size drift vs elf.x");

/** XLANG_WPO_PGO_HOT=1 时启用 .text.hot 双段 emit。 */
int32_t pipeline_elf_pgo_hot_enabled(void) {
  const char *e = link_abi_getenv("XLANG_WPO_PGO_HOT");
  if (!e || e[0] == '\0')
    return 0;
  if (e[0] == '0' && (e[1] == '\0' || e[1] == '\n'))
    return 0;
  return 1;
}

/** 设置当前函数 emit 目标段（backend 每函数 emit 前调用）。 */
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  ctx->emit_hot = hot != 0 ? 1 : 0;
}

/** .text + .text.hot 已编码字节总和（空 __text 拒绝用）。 */
int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->code_len + ctx->code_hot_len;
}

/** 当前 emit 段已写字节数（x86 call patch 的 rel32_at 须相对本段 code_len）。 */
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx->emit_hot != 0)
    return ctx->code_hot_len;
  return ctx->code_len;
}

#endif /* WAVE273_ELF_DOMAIN_COLD — close before leftover-PE F7 */
#endif /* close wave273 FROM_X for leftover-PE F7 data-section */
#endif /* close wave178 FROM_X @34287 for leftover-PE F7 */
