/*
 * Thin pure: wave284 pipeline_parse_orch Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE284_PARSE_ORCH_ALWAYS (parse/load/typeck orch Cap residual:
 * impl_c, Cap-struct-return ParseIntoResult, diagnostics, sizeof_dep_ctx,
 * expr helpers).
 *
 * Independent C thin (Darwin additive-leaf rule). No file-local BSS.
 * Callees via prior Cap thins / pure (void* faces). Blacklist:
 * pipeline_dep_ctx_ndep always-visible struct* at seed ~2487.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc parse_orch Cap residual leave.
 */

/* XLANG_PABI_PARSE_ORCH_THIN_BEGIN */

#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "runtime_io_abi.h"

#include <stdarg.h>

/* Debug-only trace; seed mega uses Cap xlang_vfdprintf. Thin uses stderr. */
static void pabi_trace(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  (void)vfprintf(stderr, fmt, ap);
  va_end(ap);
}


struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;
struct ast_Func;
struct ast_Expr;

struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};

struct xlang_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

struct std_io_driver_Buffer {
  void *ptr;
  size_t length;
  size_t handle;
};

/* Blacklist face: always-visible struct* in seed mega (~2487). */
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);

extern char *link_abi_getenv(const char *name);
extern int xlang_preprocess_raw_to_malloc(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines);

/* Forward decls for same-TU Cap faces (call before def). */
int32_t pipeline_parse_into_buf_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf, int32_t buf_len);
int32_t pipeline_parse_into_buf_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf, int32_t buf_len);
int32_t pipeline_load_import_from_disk_impl_c(struct ast_Module *module, struct ast_ASTArena *arena, struct ast_PipelineDepCtx *ctx, int32_t import_idx);
int32_t pipeline_sync_dep_slots_from_driver_impl_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len);
int32_t pipeline_parse_into_with_init_buf_impl_rc(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len, int32_t *out_ok, int32_t *out_main_idx);
struct parser_ParseIntoResult pipeline_parse_into_with_init_result_c(void);
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len);
int32_t pipeline_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf, int32_t buf_len);
int32_t pipeline_load_import_from_disk(struct ast_Module *module, struct ast_ASTArena *arena, struct ast_PipelineDepCtx *ctx, int32_t import_idx);
int32_t pipeline_sync_dep_slots_from_driver(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t *import_path, int32_t path_len);
int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena, struct ast_PipelineDepCtx *ctx, int32_t import_idx);
int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
size_t pipeline_sizeof_arena(void);
size_t pipeline_sizeof_module(void);
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len);
int32_t pipeline_lsp_diag_parse_typeck_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, int32_t source_len, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_lsp_diag_parse_entry_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, int32_t source_len);
int32_t pipeline_lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, int32_t source_len, struct ast_PipelineDepCtx *ctx);
struct parser_ParseIntoResult pipeline_parse_into_with_init_c(struct ast_ASTArena *arena, struct ast_Module *module, struct xlang_slice_uint8_t *source);
int32_t pipeline_typeck_after_parse_ok_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_after_parse_ok_buf_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_x_stack_escape_gate_from_src_c(uint8_t *src, int32_t src_len);
int32_t pipeline_typeck_after_parse_ok_c(struct ast_ASTArena *arena, struct ast_Module *module, struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx);
int32_t parser_parse_strict_enabled(void);
void parser_diagnostic_parse_skip(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name);
void parser_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name);
void parser_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t *name, int32_t name_len, int32_t num_generic_params, int32_t is_main);
size_t pipeline_sizeof_dep_ctx(void);
size_t pipeline_sizeof_onefunc_result(void);
size_t pipeline_arena_offset_num_types(void);
void pipeline_debug_module_funcs(void *m);
int driver_get_module_num_funcs(void *m);
int driver_get_module_main_func_index(void *m);
void driver_diagnostic_entry_module(struct ast_Module *mod, struct ast_ASTArena *a);
void typeck_driver_diagnostic_after_entry_parse(int32_t num_funcs);
void typeck_driver_diagnostic_pipe_marker(int32_t id);
size_t typeck_driver_pipeline_entry_source_len(void);
size_t pipeline_driver_pipeline_entry_source_len(void);
void pipeline_driver_diagnostic_pipe_marker(int32_t id);
int32_t xlang_pipeline_check_only(void);
int32_t pipeline_shu_pipeline_check_only(void);
int32_t typeck_driver_typeck_skip_large_entry(void);
int32_t typeck_driver_asm_build_skip_typeck(void);
int32_t pipeline_driver_typeck_skip_large_entry(void);
int32_t pipeline_driver_asm_build_skip_typeck(void);
int32_t pipeline_driver_x_pipeline_skip_typeck(void);
void driver_diagnostic_entry_block_after_parse(void *mod, void *arena);
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, int32_t source_len, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module, struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, int32_t source_len, struct ast_PipelineDepCtx *ctx);
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module, struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx);
int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms);
int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms);
int32_t pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena *a, int32_t expr_ref);
int32_t compound_assign_token_to_expr_kind_from_glue(int32_t kind);
int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);



/* LP64 SHARED layout constants (match pure wave83 + header sizeof DepCtx). */
#ifndef W284_ARENA_SZ
#define W284_ARENA_SZ ((size_t)16)
#define W284_MODULE_SZ ((size_t)68)
#define W284_DEP_CTX_SZ ((size_t)8390600)
#define W284_ONEFUNC_RESULT_SZ ((size_t)8192)
#define W284_ARENA_OFF_NUM_TYPES ((size_t)0)
#define W284_ARENA_OFF_NUM_EXPRS 4
#define W284_ARENA_OFF_NUM_BLOCKS 8
#endif

/* ExprKind ordinals (pipeline_gen enum). */
#ifndef W284_EXPR_LIT
#define W284_EXPR_LIT 0
#define W284_EXPR_VAR 3
#define W284_EXPR_ADD_ASSIGN 29
#define W284_EXPR_SUB_ASSIGN 30
#define W284_EXPR_MUL_ASSIGN 31
#define W284_EXPR_DIV_ASSIGN 32
#define W284_EXPR_MOD_ASSIGN 33
#define W284_EXPR_BITAND_ASSIGN 34
#define W284_EXPR_BITOR_ASSIGN 35
#define W284_EXPR_BITXOR_ASSIGN 36
#define W284_EXPR_SHL_ASSIGN 37
#define W284_EXPR_SHR_ASSIGN 38
#define W284_EXPR_FIELD_ACCESS 44
#define W284_EXPR_INDEX 47
#define W284_EXPR_DEREF 52
#endif

/* TokenKind ordinals (include/token.h). */
#ifndef W284_TOKEN_PLUS_EQ
#define W284_TOKEN_PLUS_EQ 106
#define W284_TOKEN_MINUS_EQ 107
#define W284_TOKEN_STAR_EQ 108
#define W284_TOKEN_SLASH_EQ 109
#define W284_TOKEN_PERCENT_EQ 110
#define W284_TOKEN_AMP_EQ 111
#define W284_TOKEN_PIPE_EQ 112
#define W284_TOKEN_CARET_EQ 113
#define W284_TOKEN_LSHIFT_EQ 114
#define W284_TOKEN_RSHIFT_EQ 115
#endif

/* Pure void* callees under prefer rest. */
extern void *pipeline_dep_ctx_arena_at(void *ctx, int32_t idx);
extern void *pipeline_dep_ctx_module_at(void *ctx, int32_t idx);
extern uint8_t *pipeline_dep_ctx_path_buf_ptr(void *ctx);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t len);
extern uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(void *ctx);
extern int32_t pipeline_dep_ctx_preprocess_len_get(void *ctx);
/* blacklist: pipeline_dep_ctx_ndep always-visible struct* at ~2487 (wave283 pattern). */
extern int32_t pipeline_read_file_x(void *ctx);
extern int32_t pipeline_preprocess_loaded_into_ctx(void *ctx);
extern void pipeline_bind_import_dep_buffers(void *ctx, int32_t import_idx);
extern int32_t pipeline_sync_one_dep_slot(void *module, void *ctx, int32_t dep_i);
extern void pipeline_module_fixup_with_arena_stmt_orders(void *m, void *a);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
extern void pipeline_strict_parse_into_init(void *arena, void *module);
extern int32_t pipeline_parse_scalars_ok_get(void);
extern int32_t pipeline_parse_scalars_main_idx_get(void);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_module_main_func_index(void *m);
extern void pipeline_module_set_main_func_index(void *m, int32_t idx);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t pipeline_module_num_type_aliases_at(void *m);
extern int32_t pipeline_module_num_struct_layouts_at(void *m);
extern void *pipeline_arena_expr_ptr(void *a, int32_t ref);
extern int32_t pipeline_expr_field_access_is_enum_variant(void *a, int32_t expr_ref);
extern int32_t lsp_diag_parse_typeck_buf_c(void *module, void *arena, uint8_t *source_data, int32_t source_len, void *ctx);
extern int32_t lsp_diag_parse_entry_buf_c(void *module, void *arena, uint8_t *source_data, int32_t source_len);
extern void pipeline_lint_set_source_buf(uint8_t *data, int32_t len);
extern void pipeline_typeck_set_active_ctx_c(void *module, void *ctx);
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(void *module, void *arena, void *ctx);
extern void ast_pool_arena_release(void *a);
extern void ast_pool_module_release(void *m);
extern int32_t ast_ast_block_num_lets(void *a, int32_t br);
extern int32_t ast_ast_block_num_stmt_order(void *a, int32_t br);
extern int32_t ast_ast_block_num_regions(void *a, int32_t br);

/* Always-needed externs (parser / typeck / driver / io / link). */
extern void parser_parse_into_init(void *module, void *arena);
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *buf, int32_t buf_len);
extern struct parser_ParseIntoResult parser_parse_into(void *arena, void *module, struct xlang_slice_uint8_t *source);
extern void parser_parse_into_set_main_index(void *module, int32_t main_idx);
extern int32_t parser_copy_module_import_path64(void *module, int32_t import_idx, uint8_t *path_buf);
extern int32_t parser_get_module_num_imports(void *module);
extern void ast_ast_arena_init(void *arena);
extern int32_t typeck_typeck_x_ast(void *module, void *arena, void *ctx);
extern int32_t typeck_typeck_x_ast_library(void *module, void *arena, void *ctx);
extern void xlang_trait_reg_reset_c(void *arena);
extern int32_t xlang_trait_check_impls_complete_c(void *module);
extern void xlang_generic_bound_stash_source_buf_c(uint8_t *data, int32_t len);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern size_t driver_pipeline_entry_source_len(void);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern void driver_diagnostic_pipe_marker(int32_t id);
extern int32_t driver_check_only_get(void);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern int32_t driver_parse_strict_enabled(void);
extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, const uint8_t *name);
extern void driver_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, const uint8_t *name);
extern void driver_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, const uint8_t *name, int32_t name_len, int32_t num_generic_params, int32_t is_main);
/* link_abi_getenv already declared earlier (char*). */
extern int32_t pipeline_resolve_path_x_impl_c(void *ctx, uint8_t *import_path, int32_t path_len);
extern int32_t pipeline_read_file_x_impl_c(void *ctx);
extern ptrdiff_t io_read_batch_buf(int handle, void *bufs, int32_t n, uint32_t timeout_ms);
extern ptrdiff_t io_write_batch_buf(int handle, void *bufs, int32_t n, uint32_t timeout_ms);

/* ParseIntoResult + xlang_slice_uint8_t already defined earlier in this seed TU. */

static int32_t w284_load_i32(void *p, int32_t off) {
  uint8_t *b;
  if (!p || off < 0)
    return 0;
  b = (uint8_t *)p + off;
  return (int32_t)(b[0] | (b[1] << 8) | (b[2] << 16) | (b[3] << 24));
}

static int32_t w284_arena_num_exprs(void *a) {
  return w284_load_i32(a, W284_ARENA_OFF_NUM_EXPRS);
}
static int32_t w284_arena_num_blocks(void *a) {
  return w284_load_i32(a, W284_ARENA_OFF_NUM_BLOCKS);
}

/* ------------------------------------------------------------------------- */
/* Core parse/load impl_c authority (always).                                */
/* ------------------------------------------------------------------------- */

int32_t pipeline_parse_into_buf_impl_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf,
                                        int32_t buf_len) {
  struct parser_ParseIntoResult pr;
  if (!arena || !module || !buf || buf_len <= 0)
    return -1;
  xlang_trait_reg_reset_c(arena);
  xlang_generic_bound_stash_source_buf_c(buf, buf_len);
  parser_parse_into_init(module, arena);
  pr = parser_parse_into_buf(arena, module, buf, buf_len);
  if (pr.ok == 0) {
    if (xlang_trait_check_impls_complete_c(module) != 0)
      return -1;
    pipeline_debug_trace_named_func_bodies("parse_post", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("parse_post_fixup", module, arena);
  }
  return pr.ok == 0 ? 0 : -1;
}

int32_t pipeline_parse_into_buf_c(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *buf,
                                   int32_t buf_len) {
  return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
}

int32_t pipeline_load_import_from_disk_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                             struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t path_len;
  void *dep_arena;
  void *dep_module;
  uint8_t *path;
  XlangRuntimeFileView raw_view;
  char *prep = NULL;
  size_t prep_len = 0;
  int32_t parse_rc;

  if (!module || !arena || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  path_len = parser_copy_module_import_path64(module, import_idx, path_buf);
  if (pipeline_resolve_path_x(ctx, path_buf, path_len) != 0)
    return -7;
  /* PLATFORM: SHARED — import orch heap (PP002). Ctx embed stays 4MiB pin.
   * G.7 reuse runtime_read_file_view + xlang_preprocess_raw_to_malloc.
   * Historical read_file_x + preprocess_loaded_into_ctx truncated at 4MiB. */
  memset(&raw_view, 0, sizeof(raw_view));
  path = pipeline_dep_ctx_path_buf_ptr(ctx);
  if (!path)
    return -8;
  if (runtime_read_file_view((const char *)path, &raw_view) != 0)
    return -8;
  if (xlang_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
          (const char *)path, NULL, 0) != 0) {
    runtime_release_file_view(&raw_view);
    return -9;
  }
  runtime_release_file_view(&raw_view);
  if (!prep || prep_len > (size_t)2147483647) {
    free(prep);
    return -9;
  }
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, import_idx, path_buf, path_len);
  pipeline_bind_import_dep_buffers(ctx, import_idx);
  dep_arena = pipeline_dep_ctx_arena_at(ctx, import_idx);
  dep_module = pipeline_dep_ctx_module_at(ctx, import_idx);
  parse_rc = pipeline_parse_into_buf(dep_arena, dep_module, (uint8_t *)prep, (int32_t)prep_len);
  free(prep);
  if (parse_rc != 0)
    return -10;
  return 0;
}

int32_t pipeline_sync_dep_slots_from_driver_impl_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t dep_sync_nd;
  int32_t dep_sync_i;
  int32_t sync_rc;
  int32_t n_entry_imports;

  if (!module || !ctx)
    return -1;
  dep_sync_nd = pipeline_dep_ctx_ndep(ctx);
  n_entry_imports = parser_get_module_num_imports(module);
  if (n_entry_imports >= 0 && n_entry_imports < dep_sync_nd) {
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
      pabi_trace(
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

struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_impl_c(struct ast_ASTArena *arena,
                                                                        struct ast_Module *module, uint8_t *data,
                                                                        int32_t len) {
  struct parser_ParseIntoResult fail;
  struct parser_ParseIntoResult pr;

  fail.ok = 1;
  fail.main_idx = -1;
  if (!arena || !module || !data || len <= 0)
    return fail;
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

int32_t pipeline_parse_into_with_init_buf_impl_rc(struct ast_ASTArena *arena, struct ast_Module *module,
                                                   uint8_t *data, int32_t len, int32_t *out_ok,
                                                   int32_t *out_main_idx) {
  struct parser_ParseIntoResult r;

  if (!arena || !module || !data || len <= 0) {
    if (out_ok)
      *out_ok = 1;
    if (out_main_idx)
      *out_main_idx = -1;
    return 0;
  }
  r = pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
  if (out_ok)
    *out_ok = r.ok;
  if (out_main_idx)
    *out_main_idx = r.main_idx;
  return 0;
}

struct parser_ParseIntoResult pipeline_parse_into_with_init_result_c(void) {
  struct parser_ParseIntoResult r;
  r.ok = pipeline_parse_scalars_ok_get();
  r.main_idx = pipeline_parse_scalars_main_idx_get();
  return r;
}

/* wave308: Cap-struct product face ALWAYS seed leave from pipeline.x host residual.
 * Pure freestanding avoids by-value ParseIntoResult (scalars/impl_rc authority);
 * G.7 single product Cap face = seed ALWAYS thin→impl_c (not host-cc pipeline_x).
 * PLATFORM: SHARED freestanding 8.3 Cap-struct residual leave. */
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena *arena,
                                                                 struct ast_Module *module,
                                                                 uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
}

/* Cold twins for pure-owned strong symbols (not under FROM_X prefer). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module,
                                           uint8_t *buf, int32_t buf_len) {
  return pipeline_parse_into_buf_impl_c(arena, module, buf, buf_len);
}
int32_t pipeline_load_import_from_disk(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
}
int32_t pipeline_sync_dep_slots_from_driver(struct ast_Module *module,
                                                       struct ast_PipelineDepCtx *ctx) {
  return pipeline_sync_dep_slots_from_driver_impl_c(module, ctx);
}
int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t *import_path,
                                           int32_t path_len) {
  return pipeline_resolve_path_x_impl_c(ctx, import_path, path_len);
}
/* pipeline_read_file_x cold twin already defined earlier in this seed (~4212). */
/* wave308: pipeline_parse_into_with_init_buf Cap face is ALWAYS above (not cold-only). */
int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  return pipeline_load_import_from_disk(module, arena, ctx, import_idx);
}
int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module,
                                                         struct ast_PipelineDepCtx *ctx) {
  return pipeline_sync_dep_slots_from_driver(module, ctx);
}
size_t pipeline_sizeof_arena(void) { return W284_ARENA_SZ; }
size_t pipeline_sizeof_module(void) { return W284_MODULE_SZ; }
#endif /* !FROM_X pure dual cold */

struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                                   uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf(arena, module, data, len);
}

int32_t pipeline_lsp_diag_parse_typeck_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   uint8_t *source_data, int32_t source_len,
                                                   struct ast_PipelineDepCtx *ctx) {
  return lsp_diag_parse_typeck_buf_c(module, arena, source_data, source_len, ctx);
}

int32_t pipeline_lsp_diag_parse_entry_buf_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                uint8_t *source_data, int32_t source_len) {
  return lsp_diag_parse_entry_buf_c(module, arena, source_data, source_len);
}

int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                            int32_t source_len, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                              int32_t source_len, struct ast_PipelineDepCtx *ctx) {
  return pipeline_lsp_diag_parse_typeck_buf(module, arena, source_data, source_len, ctx);
}

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
    pabi_trace( "xlang: [XLANG_DEBUG_PIPE] type_aliases=%d struct_layouts=%d\n",
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
  source.data = data;
  source.length = (size_t)len;
  return pipeline_typeck_after_parse_ok_impl_c(arena, module, &source, ctx);
}

int32_t pipeline_typeck_x_stack_escape_gate_from_src_c(uint8_t *src, int32_t src_len) {
  size_t asz;
  size_t msz;
  void *arena_heap;
  void *module_heap;
  void *ctx_heap;
  struct parser_ParseIntoResult pr;
  int32_t rc;

  if (!src || src_len <= 0)
    return 0;
  asz = pipeline_sizeof_arena();
  msz = pipeline_sizeof_module();
  arena_heap = calloc(1, asz);
  module_heap = calloc(1, msz);
  ctx_heap = calloc(1, W284_DEP_CTX_SZ);
  if (!arena_heap || !module_heap || !ctx_heap) {
    free(arena_heap);
    free(module_heap);
    free(ctx_heap);
    return -1;
  }
  pipeline_strict_parse_into_init(arena_heap, module_heap);
  pr = parser_parse_into_buf(arena_heap, module_heap, src, src_len);
  if (pr.ok != 0) {
    ast_pool_arena_release(arena_heap);
    ast_pool_module_release(module_heap);
    free(arena_heap);
    free(module_heap);
    free(ctx_heap);
    return -1;
  }
  parser_parse_into_set_main_index(module_heap, pr.main_idx);
  rc = pipeline_typeck_scan_module_struct_stack_escape_c(module_heap, arena_heap, ctx_heap);
  if (rc != 0)
    driver_diagnostic_typeck_fail();
  ast_pool_arena_release(arena_heap);
  ast_pool_module_release(module_heap);
  free(arena_heap);
  free(module_heap);
  free(ctx_heap);
  return (rc == 0) ? 0 : -1;
}

int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module,
                                        struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_typeck_after_parse_ok_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                          struct xlang_slice_uint8_t *source, struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_after_parse_ok(arena, module, source, ctx);
}

/* Diagnostic / sizeof / driver forwarders */
int32_t parser_parse_strict_enabled(void) {
  return driver_parse_strict_enabled();
}
void parser_diagnostic_parse_skip(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name) {
  driver_diagnostic_parse_skip_function(byte_pos, num_funcs_so_far, name_len, name);
}
void parser_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t *name) {
  driver_diagnostic_parse_commit_fail(byte_pos, num_funcs_so_far, name_len, name);
}
void parser_diagnostic_parse_func_generic(int32_t byte_pos, int32_t num_funcs_so_far, uint8_t *name, int32_t name_len,
                                          int32_t num_generic_params, int32_t is_main) {
  driver_diagnostic_parse_func_generic(byte_pos, num_funcs_so_far, name, name_len, num_generic_params, is_main);
}

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
size_t pipeline_sizeof_dep_ctx(void) { return W284_DEP_CTX_SZ; }
#endif
size_t pipeline_sizeof_onefunc_result(void) { return W284_ONEFUNC_RESULT_SZ; }
size_t pipeline_arena_offset_num_types(void) { return W284_ARENA_OFF_NUM_TYPES; }

void pipeline_debug_module_funcs(void *m) {
  int i, n, len;
  uint8_t nm[256];
  if (!m)
    return;
  n = (int)pipeline_module_num_funcs(m);
  for (i = 0; i < n; i++) {
    len = (int)pipeline_module_func_name_len_at(m, i);
    memset(nm, 0, sizeof(nm));
    pipeline_module_func_name_copy64(m, i, nm);
    pabi_trace( "[DEBUG] module func[%d] name_len=%d name=%.*s\n", i, len,
            len > 0 && len <= 64 ? len : 0, (const char *)nm);
  }
}

int driver_get_module_num_funcs(void *m) {
  return m ? (int)pipeline_module_num_funcs(m) : 0;
}
int driver_get_module_main_func_index(void *m) {
  return m ? (int)pipeline_module_main_func_index(m) : -2;
}

void driver_diagnostic_entry_module(struct ast_Module *mod, struct ast_ASTArena *a) {
  const char *list_env;
  int32_t i, j, n;
  list_env = link_abi_getenv("XLANG_ASM_LIST_FUNCS");
  if (list_env && list_env[0] != '\0' && list_env[0] != '0' && mod) {
    n = pipeline_module_num_funcs(mod);
    for (i = 0; i < n; i++) {
      uint8_t nm[256];
      int32_t nl = pipeline_module_func_name_len_at(mod, i);
      int32_t body_ref = pipeline_module_func_body_ref_at(mod, i);
      int32_t nlet = 0, nso = 0, nreg = 0;
      int32_t nblocks = w284_arena_num_blocks(a);
      pipeline_module_func_name_copy64(mod, i, nm);
      if (body_ref > 0 && a && body_ref <= nblocks) {
        nlet = ast_ast_block_num_lets(a, body_ref);
        nso = ast_ast_block_num_stmt_order(a, body_ref);
        nreg = ast_ast_block_num_regions(a, body_ref);
      }
      pabi_trace("asm_list: #%d extern=%d body_ref=%d nlet=%d nso=%d nreg=%d name=%.*s\n",
              (int)i, (int)pipeline_module_func_is_extern_at(mod, i),
              (int)body_ref, (int)nlet, (int)nso, (int)nreg,
              nl < 64 ? (int)nl : 64, (const char *)nm);
    }
    return;
  }
  (void)mod;
  (void)a;
}

void typeck_driver_diagnostic_after_entry_parse(int32_t num_funcs) {
  driver_diagnostic_after_entry_parse(num_funcs);
}
void typeck_driver_diagnostic_pipe_marker(int32_t id) { driver_diagnostic_pipe_marker(id); }
size_t typeck_driver_pipeline_entry_source_len(void) { return driver_pipeline_entry_source_len(); }
size_t pipeline_driver_pipeline_entry_source_len(void) { return driver_pipeline_entry_source_len(); }
void pipeline_driver_diagnostic_pipe_marker(int32_t id) { driver_diagnostic_pipe_marker(id); }
int32_t xlang_pipeline_check_only(void) { return driver_check_only_get(); }
int32_t pipeline_shu_pipeline_check_only(void) { return xlang_pipeline_check_only(); }
int32_t typeck_driver_typeck_skip_large_entry(void) { return driver_typeck_skip_large_entry(); }
int32_t typeck_driver_asm_build_skip_typeck(void) { return driver_asm_build_skip_typeck(); }
int32_t pipeline_driver_typeck_skip_large_entry(void) { return driver_typeck_skip_large_entry(); }
int32_t pipeline_driver_asm_build_skip_typeck(void) { return driver_asm_build_skip_typeck(); }
int32_t pipeline_driver_x_pipeline_skip_typeck(void) { return driver_x_pipeline_skip_typeck_get(); }

void driver_diagnostic_entry_block_after_parse(void *mod, void *arena) {
  int32_t mi, nf, br, nblocks;
  if (!mod || !arena)
    return;
  mi = pipeline_module_main_func_index(mod);
  nf = pipeline_module_num_funcs(mod);
  if (mi < 0 || mi >= nf)
    return;
  br = pipeline_module_func_body_ref_at(mod, mi);
  nblocks = w284_arena_num_blocks(arena);
  if (br <= 0 || br > nblocks)
    return;
  (void)br;
}

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      uint8_t *source_data, int32_t source_len,
                                                      struct ast_PipelineDepCtx *ctx) {
  return pipeline_lsp_diag_parse_typeck_buf_impl_c(module, arena, source_data, source_len, ctx);
}
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module,
                                                  struct xlang_slice_uint8_t *source,
                                                  struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_after_parse_ok_impl_c(arena, module, source, ctx);
}
#else
/* Prefer: strong default bodies for faces pure does not own. */
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module *module, struct ast_ASTArena *arena,
                                            uint8_t *source_data, int32_t source_len,
                                            struct ast_PipelineDepCtx *ctx) {
  return pipeline_lsp_diag_parse_typeck_buf_impl_c(module, arena, source_data, source_len, ctx);
}
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena *arena, struct ast_Module *module,
                                        struct xlang_slice_uint8_t *source,
                                        struct ast_PipelineDepCtx *ctx) {
  return pipeline_typeck_after_parse_ok_impl_c(arena, module, source, ctx);
}
#endif

int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_read_batch_buf((int)handle, (void *)bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}
int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_write_batch_buf((int)handle, (void *)bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}

/* Forward: used by pipeline_expr_ref_is_assign_lvalue (void* match pure / seed ~39012). */
int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);

int32_t pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena *a, int32_t expr_ref) {
  int32_t kd;
  int32_t nexprs;
  if (!a || expr_ref <= 0)
    return 0;
  nexprs = w284_arena_num_exprs(a);
  if (expr_ref > nexprs)
    return 0;
  kd = pipeline_expr_kind_ord_at(a, expr_ref);
  if (kd == W284_EXPR_VAR || kd == W284_EXPR_INDEX || kd == W284_EXPR_DEREF)
    return 1;
  if (kd != W284_EXPR_FIELD_ACCESS)
    return 0;
  return pipeline_expr_field_access_is_enum_variant(a, expr_ref) == 0 ? 1 : 0;
}

int32_t compound_assign_token_to_expr_kind_from_glue(int32_t kind) {
  if (kind == W284_TOKEN_PLUS_EQ) return W284_EXPR_ADD_ASSIGN;
  if (kind == W284_TOKEN_MINUS_EQ) return W284_EXPR_SUB_ASSIGN;
  if (kind == W284_TOKEN_STAR_EQ) return W284_EXPR_MUL_ASSIGN;
  if (kind == W284_TOKEN_SLASH_EQ) return W284_EXPR_DIV_ASSIGN;
  if (kind == W284_TOKEN_PERCENT_EQ) return W284_EXPR_MOD_ASSIGN;
  if (kind == W284_TOKEN_AMP_EQ) return W284_EXPR_BITAND_ASSIGN;
  if (kind == W284_TOKEN_PIPE_EQ) return W284_EXPR_BITOR_ASSIGN;
  if (kind == W284_TOKEN_CARET_EQ) return W284_EXPR_BITXOR_ASSIGN;
  if (kind == W284_TOKEN_LSHIFT_EQ) return W284_EXPR_SHL_ASSIGN;
  if (kind == W284_TOKEN_RSHIFT_EQ) return W284_EXPR_SHR_ASSIGN;
  return W284_EXPR_SHR_ASSIGN;
}

int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref) {
  void *ex;
  int32_t nexprs;
  if (!a || expr_ref <= 0)
    return -1;
  nexprs = w284_arena_num_exprs(a);
  if (expr_ref > nexprs)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  /* Expr.kind @0 LE i32 (W278 / pure LE). */
  return w284_load_i32(ex, 0);
}

/* XLANG_PABI_PARSE_ORCH_THIN_END */
/* XLANG_PABI_PARSE_ORCH_THIN_END */
