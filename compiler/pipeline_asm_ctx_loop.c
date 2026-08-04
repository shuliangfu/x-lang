/* ============================================================================
 * pipeline_asm_ctx_loop.c — backend asm loop label stack + block emit continuation
 *
 * wave1255 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   AsmLoopLabelsSidecar + asm_loop_sidecar_get
 *   + asm_ctx_loop_reset/push/pop/depth
 *   + AsmBlockEmitCont + g_asm_be_cont + asm_be_cont_reset/suspend/resume/depth
 *
 * Loop break/continue label stack (up to 8 nested) + if-then continuation
 * suspend/resume (up to 24 deep) to avoid emit_block_body↔if-then recursion.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 * Depends on MAX_ASM_LOCALS_SIDECARS (pipeline_asm_locals.c).
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
typedef struct {
  void *ctx;
  int used;
  int32_t depth;
  uint8_t break_stack[512];
  int32_t break_lens[8];
  uint8_t continue_stack[512];
  int32_t continue_lens[8];
} AsmLoopLabelsSidecar;

static AsmLoopLabelsSidecar g_asm_loop_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmLoopLabelsSidecar *asm_loop_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_loop_sc[i].used && g_asm_loop_sc[i].ctx == (void *)ctx)
      return &g_asm_loop_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_loop_sc[i].used) {
      g_asm_loop_sc[i].ctx = (void *)ctx;
      g_asm_loop_sc[i].used = 1;
      g_asm_loop_sc[i].depth = 0;
      return &g_asm_loop_sc[i];
    }
  }
  return NULL;
}

/** 清空某 AsmFuncCtx 的循环标签栈。 */
void asm_ctx_loop_reset(uint8_t *ctx) {
  AsmLoopLabelsSidecar *sc = asm_loop_sidecar_get(ctx, 0);
  if (sc)
    sc->depth = 0;
}

/** 压入一层 break/continue 标签；depth>=8 时返回 -1。 */
int32_t asm_ctx_loop_push(uint8_t *ctx, uint8_t *exit_buf, int32_t exit_len, uint8_t *loop_buf, int32_t loop_len) {
  AsmLoopLabelsSidecar *sc;
  int32_t d, base, k, n, m;
  if (!ctx || !exit_buf || !loop_buf || exit_len < 0 || loop_len < 0)
    return -1;
  if (!(sc = asm_loop_sidecar_get(ctx, 1)))
    return -1;
  d = sc->depth;
  if (d >= 8)
    return -1;
  base = d * 64;
  n = exit_len > 64 ? 64 : exit_len;
  for (k = 0; k < n; k++)
    sc->break_stack[base + k] = exit_buf[k];
  sc->break_lens[d] = exit_len;
  m = loop_len > 64 ? 64 : loop_len;
  for (k = 0; k < m; k++)
    sc->continue_stack[base + k] = loop_buf[k];
  sc->continue_lens[d] = loop_len;
  sc->depth = d + 1;
  return 0;
}

/** 弹出一层；若仍有外层则把其 break/continue 写入 out（长度经 *len_out 返回）。 */
void asm_ctx_loop_pop(uint8_t *ctx, uint8_t *break_out, int32_t break_cap, int32_t *break_len_out,
                      uint8_t *cont_out, int32_t cont_cap, int32_t *cont_len_out) {
  AsmLoopLabelsSidecar *sc;
  int32_t d, prev, base, k, bl, cl, bn, cn;
  if (break_len_out)
    *break_len_out = 0;
  if (cont_len_out)
    *cont_len_out = 0;
  if (!ctx || !(sc = asm_loop_sidecar_get(ctx, 0)) || sc->depth <= 0)
    return;
  sc->depth--;
  d = sc->depth;
  if (d <= 0)
    return;
  prev = d - 1;
  base = prev * 64;
  bl = sc->break_lens[prev];
  cl = sc->continue_lens[prev];
  if (break_out && break_len_out && break_cap > 0) {
    bn = bl > break_cap - 1 ? break_cap - 1 : bl;
    for (k = 0; k < bn; k++)
      break_out[k] = sc->break_stack[base + k];
    *break_len_out = bl;
  }
  if (cont_out && cont_len_out && cont_cap > 0) {
    cn = cl > cont_cap - 1 ? cont_cap - 1 : cl;
    for (k = 0; k < cn; k++)
      cont_out[k] = sc->continue_stack[base + k];
    *cont_len_out = cl;
  }
}

/** 当前循环标签栈深度。 */
int32_t asm_ctx_loop_depth(uint8_t *ctx) {
  AsmLoopLabelsSidecar *sc = asm_loop_sidecar_get(ctx, 0);
  return sc ? sc->depth : 0;
}

/**
 * emit_block_body 迭代续延：if-then 后挂起 (block_ref, stmt_i) 与 end 标签，避免 emit_block_body↔if-then 递归。
 */
typedef struct {
  int32_t block_ref;
  int32_t stmt_i;
  int32_t end_label_len;
  uint8_t end_label[128];
} AsmBlockEmitCont;

static AsmBlockEmitCont g_asm_be_cont[24];
static int32_t g_asm_be_cont_depth;

/** 清空 if 续延栈（每个顶层 emit_block_body 入口调用一次）。 */
void asm_be_cont_reset(void) {
  g_asm_be_cont_depth = 0;
}

/**
 * 挂起当前块在 stmt_i 处，保存 if end 标签；随后切换至 then 块 stmt_i=0。
 * end_len 须 <= 64；end_len==0 表示 then 结束后不 jmp merge（由 resume 直接恢复 stmt_i）。栈满返回 -1。
 */
int32_t asm_be_cont_suspend(int32_t block_ref, int32_t stmt_i, uint8_t *end_lbl, int32_t end_len) {
  AsmBlockEmitCont *c;
  int32_t k, n;
  if (g_asm_be_cont_depth >= 24 || !end_lbl || end_len < 0)
    return -1;
  c = &g_asm_be_cont[g_asm_be_cont_depth++];
  c->block_ref = block_ref;
  c->stmt_i = stmt_i;
  if (end_len == 0) {
    c->end_label_len = 0;
    return 0;
  }
  n = end_len > 64 ? 64 : end_len;
  for (k = 0; k < n; k++)
    c->end_label[k] = end_lbl[k];
  c->end_label_len = end_len;
  return 0;
}

/**
 * 弹出最内层续延；out_block 与 out_stmt_i 为恢复点；end 标签写入 out_end（cap 字节，out_end_len 为原长）。
 * 无续延返回 0；有续延返回 1。
 */
int32_t asm_be_cont_resume(int32_t *out_block, int32_t *out_stmt_i, uint8_t *out_end, int32_t end_cap, int32_t *out_end_len) {
  AsmBlockEmitCont *c;
  int32_t k, n;
  if (g_asm_be_cont_depth <= 0)
    return 0;
  c = &g_asm_be_cont[--g_asm_be_cont_depth];
  if (out_block)
    *out_block = c->block_ref;
  if (out_stmt_i)
    *out_stmt_i = c->stmt_i;
  if (out_end_len)
    *out_end_len = c->end_label_len;
  if (out_end && end_cap > 0 && out_end_len) {
    n = c->end_label_len;
    if (n > end_cap - 1)
      n = end_cap - 1;
    for (k = 0; k < n; k++)
      out_end[k] = c->end_label[k];
  }
  return 1;
}

/** 当前 if 续延栈深度（调试）。 */
int32_t asm_be_cont_depth(void) {
  return g_asm_be_cont_depth;
}
