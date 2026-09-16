/*
 * Thin pure: wave272 PipelineDepCtx Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave272 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local DepCtxSidecar
 * table (MAX 64) + GrowVec pools via grow_vec_* (wave271 thin).
 * Layout authority: runtime_pipeline_abi.h struct ast_PipelineDepCtx.
 *
 * Faces: pipeline_dep_ctx_* / pipeline_ctx_lib_root_* /
 *   pipeline_dep_ctx_sidecar_release (+ check_only via driver_check_only_get).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding DepCtx Cap leave.
 */

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "runtime_pipeline_abi.h"

#ifndef MAX_DEP_CTX_SIDECARS
#define MAX_DEP_CTX_SIDECARS 64
#endif
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  int32_t mmap_backed;
} GrowVec;

extern int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap);
extern void grow_vec_free(GrowVec *v);
extern int grow_vec_ensure(GrowVec *v);
extern void *grow_vec_at(GrowVec *v, int32_t idx);
extern int32_t grow_vec_push(GrowVec *v);
extern void grow_vec_copy_append(GrowVec *dst, GrowVec *src);

extern int32_t driver_check_only_get(void);

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
} DepCtxSidecar;

static DepCtxSidecar g_depctx_sc[MAX_DEP_CTX_SIDECARS];

static DepCtxSidecar *depctx_get(struct ast_PipelineDepCtx *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_depctx_sc[i].used && g_depctx_sc[i].ctx == ctx)
      return &g_depctx_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (!g_depctx_sc[i].used) {
      DepCtxSidecar *sc = &g_depctx_sc[i];
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

static int depctx_ensure_slot(DepCtxSidecar *sc, int32_t idx) {
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

static void depctx_free(DepCtxSidecar *sc) {
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
    if (g_depctx_sc[i].used && g_depctx_sc[i].ctx == ctx) {
      depctx_free(&g_depctx_sc[i]);
      return;
    }
  }
}

/** ---------- PipelineDepCtx dep / lib_root 动态池 ---------- */

void pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = depctx_get(ctx, 0);
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
  if (!(sc = depctx_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
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
  if (!(sc = depctx_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
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
  if (!(sc = depctx_get(ctx, 0)) || idx >= sc->dep_modules.len)
    return NULL;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  return pm ? (struct ast_Module *)*pm : NULL;
}

struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = depctx_get(ctx, 0)) || idx >= sc->dep_arenas.len)
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
  if (!(sc = depctx_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
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
  DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || idx < 0 || !(sc = depctx_get(ctx, 0)) || idx >= sc->dep_path_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  return pl ? *pl : 0;
}

uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx *ctx, int32_t idx, int32_t off) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || idx < 0 || off < 0 || !(sc = depctx_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
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
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 256);
  if (!ctx || idx < 0 || !(sc = depctx_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
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
  sc = depctx_get(ctx, 0);
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
  /* same-TU: pipeline_dep_ctx_sidecar_release in ast_pool.c */
  pipeline_dep_ctx_sidecar_release(ctx);
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
  if (!(sc = depctx_get(ctx, 1)))
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
  DepCtxSidecar *sc = ctx ? depctx_get(ctx, 0) : NULL;
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || i < 0 || !(sc = depctx_get(ctx, 0)) || i >= sc->lib_root_lens.len)
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
  if (!ctx || i < 0 || !(sc = depctx_get(ctx, 0)) || i >= sc->lib_root_rows.len)
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
  if (!ctx || i < 0 || off < 0 || !(sc = depctx_get(ctx, 0)) || i >= sc->lib_root_rows.len)
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
  sc = depctx_get(ctx, 0);
  if (sc)
    sc->empty_param_indices.len = 0;
  ctx->current_func_empty_param_count = 0;
}

int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx *ctx, int32_t pi) {
  DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || !(sc = depctx_get(ctx, 1)))
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
  if (!ctx || i < 0 || !(sc = depctx_get(ctx, 0)) || i >= sc->empty_param_indices.len)
    return -1;
  slot = (int32_t *)grow_vec_at(&sc->empty_param_indices, i);
  return slot ? *slot : -1;
}

void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx || !(sc = depctx_get(ctx, 1)))
    return;
  sc->empty_param_backup.len = 0;
  grow_vec_copy_append(&sc->empty_param_backup, &sc->empty_param_indices);
}

void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx || !(sc = depctx_get(ctx, 0)))
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

