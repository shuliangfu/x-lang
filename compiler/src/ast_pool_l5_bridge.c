/**
 * ast_pool_l5_bridge.c — B-strict 链补链：preprocess -D 与 labeled 名写入（从 ast_pool.c 抽出，避免整 TU 编 glue_standalone）。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

/** #[cfg] 表达式求值（cfg_eval.sx / bootstrap stub）；供 target_os == "linux" 等 #if 条件。 */
extern int cfg_eval_expr_c(const char *start, int len);

struct ast_LabeledStmt {
  uint8_t label[32];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[32];
  int32_t goto_target_len;
  int32_t return_expr_ref;
};

struct ast_ASTArena;
struct ast_Module;
struct ast_PipelineDepCtx;

extern struct ast_LabeledStmt *pipeline_block_labeled_ptr(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void driver_diagnostic_pipe_marker(int32_t id);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);

#define PREPROCESS_MAX_DEFINES 32
static char g_preprocess_defines[PREPROCESS_MAX_DEFINES][64];
static int g_preprocess_ndefines;
static uint8_t g_typeck_scratch64[16][64];
static int32_t g_typeck_layout_metrics_sz_slot;
static int32_t g_typeck_layout_metrics_al_slot = 1;
static int32_t g_typeck_layout_metrics_sz_depth[64];
static int32_t g_typeck_layout_metrics_al_depth[64];
static int32_t g_typeck_call_resolve_dep_idx_slot;
static int32_t g_typeck_call_resolve_func_idx_slot;

__attribute__((weak)) uint8_t *typeck_scratch64_slot(int32_t slot) {
  if (slot < 0)
    slot = 0;
  if (slot >= 16)
    slot = 15;
  return &g_typeck_scratch64[slot][0];
}

__attribute__((weak)) int32_t *typeck_layout_metrics_sz_slot(void) {
  return &g_typeck_layout_metrics_sz_slot;
}

__attribute__((weak)) int32_t *typeck_layout_metrics_al_slot(void) {
  return &g_typeck_layout_metrics_al_slot;
}

__attribute__((weak)) int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth) {
  if (depth < 0)
    depth = 0;
  if (depth >= 64)
    depth = 63;
  return &g_typeck_layout_metrics_sz_depth[depth];
}

__attribute__((weak)) int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth) {
  if (depth < 0)
    depth = 0;
  if (depth >= 64)
    depth = 63;
  return &g_typeck_layout_metrics_al_depth[depth];
}

__attribute__((weak)) void typeck_layout_metrics_init_depth(int32_t depth) {
  int32_t *sz = typeck_layout_metrics_sz_slot_depth(depth);
  int32_t *al = typeck_layout_metrics_al_slot_depth(depth);
  if (sz)
    *sz = 0;
  if (al)
    *al = 1;
}

__attribute__((weak)) int32_t typeck_layout_metrics_al_read_depth(int32_t depth) {
  return *typeck_layout_metrics_al_slot_depth(depth);
}

__attribute__((weak)) int32_t typeck_layout_metrics_sz_read_depth(int32_t depth) {
  return *typeck_layout_metrics_sz_slot_depth(depth);
}

__attribute__((weak)) void typeck_layout_metrics_init_slot(void) {
  *typeck_layout_metrics_sz_slot() = 0;
  *typeck_layout_metrics_al_slot() = 1;
}

__attribute__((weak)) void typeck_i32_ptr_store(int32_t *p, int32_t v) {
  if (p)
    *p = v;
}

__attribute__((weak)) int32_t typeck_i32_ptr_read(int32_t *p) {
  return p ? *p : 0;
}

__attribute__((weak)) void typeck_driver_diagnostic_pipe_marker(int32_t id) {
  driver_diagnostic_pipe_marker(id);
}

__attribute__((weak)) int32_t *typeck_call_resolve_dep_idx_slot(void) {
  return &g_typeck_call_resolve_dep_idx_slot;
}

__attribute__((weak)) int32_t *typeck_call_resolve_func_idx_slot(void) {
  return &g_typeck_call_resolve_func_idx_slot;
}

__attribute__((weak)) int32_t typeck_call_resolve_dep_idx_peek(void) {
  return *typeck_call_resolve_dep_idx_slot();
}

__attribute__((weak)) int32_t typeck_call_resolve_func_idx_peek(void) {
  return *typeck_call_resolve_func_idx_slot();
}

__attribute__((weak)) int32_t run_sx_pipeline_fill_dep_import_path_c(struct ast_Module *module,
                                                                     struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  uint8_t path_buf[64];
  int32_t path_len;
  if (!module || !ctx || dep_j < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, dep_j, path_buf);
  path_len = 0;
  while (path_len < 64 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/** 清空 -D 宏表。 */
void preprocess_define_reset(void) {
  g_preprocess_ndefines = 0;
}

/** 追加 -D 宏名。 */
void preprocess_define_add(const char *name) {
  size_t n;
  if (!name || g_preprocess_ndefines >= PREPROCESS_MAX_DEFINES)
    return;
  n = strlen(name);
  if (n == 0 || n >= 64)
    return;
  memcpy(g_preprocess_defines[g_preprocess_ndefines], name, n + 1);
  g_preprocess_ndefines++;
}

/** 判断 sym[0..sym_len) 是否在 -D 宏表中。 */
int32_t preprocess_define_has(const uint8_t *sym, int32_t sym_len) {
  int i, k;
  if (!sym || sym_len <= 0)
    return 0;
  for (i = 0; i < g_preprocess_ndefines; i++) {
    for (k = 0; k < sym_len; k++) {
      if (g_preprocess_defines[i][k] != (char)sym[k])
        break;
      if (g_preprocess_defines[i][k] == '\0')
        break;
    }
    if (k == sym_len && g_preprocess_defines[i][k] == '\0')
      return 1;
  }
  return 0;
}

/**
 * .sx 预处理路径：求值 #if COND（bridge 内 -D 宏表；不依赖 preprocess.c）。
 * 参数：cond 条件字节；cond_len 长度。
 * 返回值：非 0 表示成立。
 */
int32_t preprocess_eval_condition_c(const uint8_t *cond, int32_t cond_len) {
  int k;

  if (!cond || cond_len <= 0)
    return 0;
  /* 去首尾空白。 */
  while (cond_len > 0 && (cond[0] == ' ' || cond[0] == '\t')) {
    cond++;
    cond_len--;
  }
  while (cond_len > 0 && (cond[cond_len - 1] == ' ' || cond[cond_len - 1] == '\t'))
    cond_len--;
  if (cond_len <= 0)
    return 0;
  /* 复杂条件（含空格/运算符）走 cfg_eval，与 #[cfg] / preprocess.c 对齐。 */
  for (k = 0; k < cond_len; k++) {
    char c = (char)cond[k];
    if (c == ' ' || c == '\t' || c == '=' || c == '!' || c == '(' || c == ')')
      return cfg_eval_expr_c((const char *)cond, cond_len) ? 1 : 0;
  }
  return preprocess_define_has(cond, cond_len) ? 1 : 0;
}

/** 写 labeled 槽的标签名与 goto 目标名。 */
void pipeline_block_labeled_set_names(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *label, int32_t label_len,
                                      uint8_t *goto_target, int32_t goto_target_len) {
  struct ast_LabeledStmt *ls;
  if (!a || li < 0)
    return;
  ls = pipeline_block_labeled_ptr(a, br, li);
  if (!ls)
    return;
  if (label && label_len > 0) {
    if (label_len > 31)
      label_len = 31;
    memcpy(ls->label, label, (size_t)label_len);
    ls->label[label_len] = 0;
    ls->label_len = label_len;
  }
  if (goto_target && goto_target_len > 0) {
    if (goto_target_len > 31)
      goto_target_len = 31;
    memcpy(ls->goto_target, goto_target, (size_t)goto_target_len);
    ls->goto_target[goto_target_len] = 0;
    ls->goto_target_len = goto_target_len;
  }
}
