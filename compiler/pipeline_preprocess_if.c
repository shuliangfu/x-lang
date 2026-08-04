/* pipeline_preprocess_if.c — preprocess #if/#else 嵌套栈 cold fallback（自 ast_pool.c 抽出）
 *
 * preprocess_if_stack_*：GrowVec cold fallback（product pure 走 runtime_pipeline_abi 固定 i32[32]；
 *   XLANG_WEAK 弱符号）。同 TU #include。 */

/**
 * preprocess.x：#if/#else 嵌套栈 cold fallback（GrowVec）。
 *
 * wave86: product pure owns preprocess_if_stack_* via fixed i32[32] BSS in
 * runtime_pipeline_abi.x (G.7 single authority under PREFER hybrid). This
 * GrowVec body stays XLANG_WEAK so cold / non-hybrid links without pure still
 * work, and pure weak/strong overrides under product L2 hybrid.
 *
 * PLATFORM: SHARED — ELF weak overridden by pure; PE XLANG_WEAK empty +
 * --allow-multiple-definition (Windows hybrid not required this wave).
 */
static GrowVec g_preprocess_if_stack;
static int g_preprocess_if_inited;

static void preprocess_if_stack_ensure(void) {
  if (g_preprocess_if_inited)
    return;
  if (!grow_vec_init(&g_preprocess_if_stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return;
  g_preprocess_if_inited = 1;
}

/** Clear #if nest stack (weak cold fallback; pure owns product). */
XLANG_WEAK void preprocess_if_stack_reset(void) {
  preprocess_if_stack_ensure();
  g_preprocess_if_stack.len = 0;
}

/** Current nest depth (weak cold fallback). */
XLANG_WEAK int32_t preprocess_if_stack_len(void) {
  preprocess_if_stack_ensure();
  return g_preprocess_if_inited ? g_preprocess_if_stack.len : 0;
}

/** Push one nest state; -1 on OOM/fail (weak cold fallback). */
XLANG_WEAK int32_t preprocess_if_stack_push(int32_t v) {
  int32_t *slot;
  preprocess_if_stack_ensure();
  if (!g_preprocess_if_inited)
    return -1;
  if (grow_vec_push(&g_preprocess_if_stack) < 0)
    return -1;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, g_preprocess_if_stack.len - 1);
  if (!slot)
    return -1;
  *slot = v;
  return 0;
}

/** Pop one nest level (weak cold fallback). */
XLANG_WEAK void preprocess_if_stack_pop(void) {
  preprocess_if_stack_ensure();
  if (g_preprocess_if_stack.len > 0)
    g_preprocess_if_stack.len--;
}

/** Read stack[i] (weak cold fallback; OOB → 0). */
XLANG_WEAK int32_t preprocess_if_stack_at(int32_t i) {
  int32_t *slot;
  if (i < 0 || !g_preprocess_if_inited || i >= g_preprocess_if_stack.len)
    return 0;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, i);
  return slot ? *slot : 0;
}

/** Write stack[i] (weak cold fallback; OOB → no-op). */
XLANG_WEAK void preprocess_if_stack_set_at(int32_t i, int32_t v) {
  int32_t *slot;
  if (i < 0 || !g_preprocess_if_inited || i >= g_preprocess_if_stack.len)
    return;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, i);
  if (slot)
    *slot = v;
}
