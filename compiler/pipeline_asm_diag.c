/* pipeline_asm_diag.c — asm 诊断域（自 ast_pool.c 抽出；同 TU #include 于 ctx_fill 之前）
 *
 * XLANG_ASM_* env 驱动的调试输出：start_func_skip（跳过前 N func 二分 emit）+
 * body_trace／body_ref／emit_phase／func_idx（fill/emit 阶段 stderr trace）+ func wrapper。
 * 依赖：link_abi_getenv（extern）／asm_env_build_skip_typeck（Block B，先于此 include）／
 * block_at（arena）。公共符号（非 static）；TU 内调用方均在此 include 之后。
 */

/**
 * 读 XLANG_ASM_START_FUNC：跳过 module 中前 N 个函数（调试大模块 asm 单编 139）。
 * build_xlang_asm 须 env -u XLANG_ASM_START_FUNC；若 N>=num_funcs 则整模块无机器码、仅 8B 空 __text 桩。
 * XLANG_ASM_ALLOW_START_FUNC=1 时 build 路径也生效（手工二分 emit 用）。
 */
int32_t asm_diag_start_func_skip(void) {
  const char *e = link_abi_getenv("XLANG_ASM_START_FUNC");
  const char *allow = link_abi_getenv("XLANG_ASM_ALLOW_START_FUNC");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 0;
  /* build_xlang_asm 默认清除 START_FUNC；未显式 ALLOW 时 ENTRY skip 模式忽略，避免 pipeline 56 func 全跳过。 */
  if ((allow == NULL || allow[0] == '\0' || allow[0] == '0') && asm_env_build_skip_typeck() != 0 &&
      link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY") != NULL) {
    const char *em = link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY");
    if (em && em[0] != '\0' && em[0] != '0')
      return 0;
  }
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 0;
  if (v > 100000)
    return 100000;
  return (int32_t)v;
}

/** XLANG_ASM_BODY_TRACE=1 时打印函数体块规模，定位错误 body_ref 导致 fill/emit 崩溃。 */
void asm_diag_trace_func_body(struct ast_ASTArena *arena, int32_t body_ref) {
  const char *trace;
  struct ast_Block *b;
  if (!arena || body_ref <= 0)
    return;
  trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  b = block_at(arena, body_ref);
  if (!b) {
    fprintf(stderr, "asm_body: ref=%d invalid\n", (int)body_ref);
    return;
  }
  fprintf(stderr,
          "asm_body: ref=%d consts=%d lets=%d loops=%d for=%d ifs=%d stmt_order=%d final_expr=%d\n",
          (int)body_ref, (int)b->num_consts, (int)b->num_lets, (int)b->num_loops, (int)b->num_for_loops,
          (int)b->num_if_stmts, (int)b->num_stmt_order, (int)b->final_expr_ref);
  fflush(stderr);
}

/** XLANG_ASM_BODY_TRACE=1：仅打印 body_ref 数值（在 pipeline_asm_module_func_body_ref_at 前后对照）。 */
void asm_diag_trace_body_ref(int32_t body_ref) {
  const char *trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_body_ref=%d\n", (int)body_ref);
  fflush(stderr);
}

/** XLANG_ASM_BODY_TRACE=1：emit 阶段标记（1=fill 后 2=prologue 后 3=emit_body 后）。 */
void asm_diag_trace_emit_phase(int32_t phase) {
  const char *trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_emit_phase=%d\n", (int)phase);
  fflush(stderr);
}

void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len) {
  const char *trace;
  int32_t i;
  if (!name || name_len <= 0)
    return;
  trace = link_abi_getenv("XLANG_ASM_FUNC_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  if (func_idx >= 0)
    fprintf(stderr, "asm_trace: #%d ", (int)func_idx);
  else
    fprintf(stderr, "asm_trace: ");
  for (i = 0; i < name_len && i < 64; i++)
    fputc(name[i], stderr);
  fputc('\n', stderr);
  fflush(stderr);
}
/* asm_diag_trace_func：XLANG_ASM_FUNC_TRACE=1 wrapper → asm_diag_trace_func_idx（func_idx 已于上定义）。 */
void asm_diag_trace_func(uint8_t *name, int32_t name_len) {
  asm_diag_trace_func_idx(-1, name, name_len);
}
