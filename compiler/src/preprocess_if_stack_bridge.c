/**
 * preprocess_if_stack_bridge.c — verify-selfhost-stage2 / 分 TU 链：提供 preprocess_if_stack_*。
 *
 * pipeline_gen2.c 不 #include pipeline_glue.c（避免与 ast_su2.o 重复 ast 辅助符号），
 * preprocess.sx 仍依赖本栈 API；用固定深度栈实现，与 ast_pool.c 语义一致。
 */
#include <stdint.h>

#define PREPROCESS_IF_STACK_CAP 64

static int32_t g_pp_if_stack[PREPROCESS_IF_STACK_CAP];
static int32_t g_pp_if_depth;

/** 清空 #if 嵌套栈。 */
void preprocess_if_stack_reset(void) {
  g_pp_if_depth = 0;
}

/** 当前嵌套深度。 */
int32_t preprocess_if_stack_len(void) {
  return g_pp_if_depth;
}

/** 追加一层；失败返回 -1。 */
int32_t preprocess_if_stack_push(int32_t v) {
  if (g_pp_if_depth >= PREPROCESS_IF_STACK_CAP)
    return -1;
  g_pp_if_stack[g_pp_if_depth++] = v;
  return 0;
}

/** 弹出一层。 */
void preprocess_if_stack_pop(void) {
  if (g_pp_if_depth > 0)
    g_pp_if_depth--;
}

/** 读 stack[i]；越界返回 0。 */
int32_t preprocess_if_stack_at(int32_t i) {
  if (i < 0 || i >= g_pp_if_depth)
    return 0;
  return g_pp_if_stack[i];
}

/** 写 stack[i]；越界忽略。 */
void preprocess_if_stack_set_at(int32_t i, int32_t v) {
  if (i < 0 || i >= g_pp_if_depth)
    return;
  g_pp_if_stack[i] = v;
}
