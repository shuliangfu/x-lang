/**
 * ast_pool_l5_bridge.c — B-strict 链补链：preprocess -D 与 labeled 名写入（从 ast_pool.c 抽出，避免整 TU 编 glue_standalone）。
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

/** 与 ast.su LabeledStmt / ast_pool grow 池布局一致。 */
struct ast_LabeledStmt {
  uint8_t label[32];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[32];
  int32_t goto_target_len;
  int32_t return_expr_ref;
};

struct ast_ASTArena;

extern struct ast_LabeledStmt *pipeline_block_labeled_ptr(struct ast_ASTArena *a, int32_t br, int32_t li);

#define PREPROCESS_MAX_DEFINES 32
static char g_preprocess_defines[PREPROCESS_MAX_DEFINES][64];
static int g_preprocess_ndefines;

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
