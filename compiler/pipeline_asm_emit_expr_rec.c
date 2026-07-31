/**
 * pipeline_asm_emit_expr_rec.c — asm ELF expr recursion dispatcher domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding expr ELF dispatch after
 * the fast path misses:
 * - pipeline_asm_expr_lit_i32_at_c (INT/BOOL lit kind 0/2 → imm)
 * - pipeline_asm_emit_expr_elf_rec (fast → kind dispatch → slow)
 *
 * G.7: single product-mega expr ELF recursion face — do not open a second
 * kind-dispatch table or parallel slow-path router. Face emitters stay in
 * their domain leaves (index/match/panic/struct_lit/array_lit/assign/…);
 * return/unary/as/logand impls stay in their leaves; backend_emit_expr_elf_slow
 * remains the ultimate residual fallback.
 *
 * Callers: pipeline_asm_emit_expr_elf_fast miss path; binop/index/call residual
 * helpers that re-enter expr emission via rec; XLANG_DEBUG_REGEX_EMIT depth log.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c in place of
 * the former residual body (after index_eff_addr; before lvalue_eff_addr text).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 *   · LINUX+MACOS x86_64 SysV — kind dispatch only (encoding in callees)
 *   · MACOS|ARM64 AAPCS64 — same dispatch twin
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_emit_expr_elf_fast / PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED
 * - pipeline_asm_emit_{if,if_arm,match,panic,struct_lit,array_lit,index,...}_elf_c
 * - pipeline_asm_emit_{return,break,continue,neg,bitnot,lognot,...}_elf_impl
 * - glue_expr_is_await_at_c / glue_expr_is_x_as_cast_at_c / assign-like
 * - glue_asm_emit_string_lit_ptr_rax_elf_c (string lit face)
 * - backend_emit_expr_elf_slow / backend_enc_mov_imm32_to_w0_arch
 * - pipeline_expr_kind_ord_at / pipeline_expr_int_val_at /
 *   pipeline_expr_enum_namespace_field_tag
 * - link_abi_getenv
 */

/** 字面量判定：kind 序 0/2。 */
static int32_t pipeline_asm_expr_lit_i32_at_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t *out_imm) {
  int32_t ko;
  if (expr_ref == 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 0 || ko == 2) {
    *out_imm = pipeline_expr_int_val_at(arena, expr_ref);
    return 1;
  }
  return 0;
}

/** 快速路径未命中时走 backend_emit_expr_elf（slow）。 */
static int32_t pipeline_asm_emit_expr_elf_rec(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t dbg_on;
  int32_t dbg_depth_now;
  int32_t dbg_log_now;
  int32_t r;
  int32_t ko;
  int32_t out_rc;
  /* #region debug-point A:regex-asm-expr-recursion */
  static int32_t dbg_depth = 0;
  static int32_t dbg_max_depth = 0;
  static int32_t dbg_prev_expr_ref = -1;
  static int32_t dbg_prev_ko = -1;
  static int32_t dbg_same_expr_streak = 0;
  /* #endregion debug-point A:regex-asm-expr-recursion */
  dbg_on = link_abi_getenv("XLANG_DEBUG_REGEX_EMIT") != NULL ? 1 : 0;
  dbg_depth_now = 0;
  dbg_log_now = 0;
  ko = expr_ref > 0 ? pipeline_expr_kind_ord_at(arena, expr_ref) : -1;
  /* #region debug-point A:regex-asm-expr-recursion */
  if (dbg_on) {
    dbg_depth = dbg_depth + 1;
    dbg_depth_now = dbg_depth;
    if (expr_ref == dbg_prev_expr_ref && ko == dbg_prev_ko)
      dbg_same_expr_streak = dbg_same_expr_streak + 1;
    else
      dbg_same_expr_streak = 1;
    dbg_prev_expr_ref = expr_ref;
    dbg_prev_ko = ko;
    if (dbg_depth_now <= 24 || dbg_depth_now > dbg_max_depth ||
        dbg_same_expr_streak == 2 || dbg_same_expr_streak == 4 || dbg_same_expr_streak == 8 ||
        dbg_same_expr_streak == 16 || dbg_same_expr_streak == 32 || dbg_same_expr_streak == 64) {
      dbg_log_now = 1;
      if (dbg_depth_now > dbg_max_depth)
        dbg_max_depth = dbg_depth_now;
    }
    if (dbg_log_now) {
      fprintf(stderr,
              "xlang: [XLANG_DEBUG_REGEX_EMIT] rec depth=%d expr_ref=%d ko=%d streak=%d ctx=%p ta=%d\n",
              (int)dbg_depth_now, (int)expr_ref, (int)ko, (int)dbg_same_expr_streak, (void *)ctx, (int)ta);
    }
  }
  /* #endregion debug-point A:regex-asm-expr-recursion */
  r = pipeline_asm_emit_expr_elf_fast(arena, elf_ctx, expr_ref, ctx, ta);
  if (r != PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED) {
    out_rc = r;
    goto debug_done;
  }
  if (ko == 25 || ko == 27)
    out_rc = pipeline_asm_emit_expr_if_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** EXPR_BLOCK 需走块体同步发射；若落 slow 会把同一 expr_ref 再喂回 rec，形成自递归。 */
  else if (ko == 26)
    out_rc = pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 43)
    out_rc = pipeline_asm_emit_match_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 42)
    out_rc = pipeline_asm_emit_panic_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 45)
    out_rc = pipeline_asm_emit_struct_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 46)
    out_rc = pipeline_asm_emit_array_lit_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 47)
    out_rc = pipeline_asm_emit_index_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 51)
    out_rc = pipeline_asm_emit_addr_of_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** wave323: EXPR_DEREF — load [ptr]; must not fall through to slow no-op. */
  else if (ko == 52)
    out_rc = pipeline_asm_emit_deref_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 48)
    out_rc = pipeline_asm_emit_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 49)
    out_rc = pipeline_asm_emit_method_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  /** STRING_LIT（kind 59）：内嵌 .text rodata，指针在 rax（fmt.println 实参等）。 */
  else if (ko == 59) {
    extern int32_t glue_asm_emit_string_lit_ptr_rax_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t str_expr_ref, int32_t ta);
    out_rc = glue_asm_emit_string_lit_ptr_rax_elf_c(arena, elf_ctx, expr_ref, ta);
  } else if (ko >= 14 && ko <= 19)
    out_rc = pipeline_asm_emit_cmp_elf(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 41)
    out_rc = pipeline_asm_emit_return_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 39)
    out_rc = pipeline_asm_emit_break_elf_impl(arena, elf_ctx, ctx, ta);
  else if (ko == 40)
    out_rc = pipeline_asm_emit_continue_elf_impl(arena, elf_ctx, ctx, ta);
  else if (ko == 22)
    out_rc = pipeline_asm_emit_neg_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 23)
    out_rc = pipeline_asm_emit_bitnot_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 24)
    out_rc = pipeline_asm_emit_lognot_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (glue_expr_is_await_at_c(arena, expr_ref))
    out_rc = pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (glue_expr_is_x_as_cast_at_c(arena, expr_ref))
    out_rc = pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == GLUE_EXPR_KIND_TRY_PROPAGATE || ko == GLUE_EXPR_KIND_C_TRY_PROPAGATE)
    out_rc = pipeline_asm_emit_try_propagate_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (glue_expr_kind_is_assign_like_ord(ko))
    out_rc = pipeline_asm_emit_assign_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 20)
    out_rc = pipeline_asm_emit_logand_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  else if (ko == 21)
    out_rc = pipeline_asm_emit_logor_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  /** FIELD_ACCESS 已在 fast 尝试过（含链式 v.al.kind）；勿落 slow（与 rec 互递归 SIGSEGV）。 */
  else if (ko == 44) {
    int32_t ns_tag = pipeline_expr_enum_namespace_field_tag(arena, expr_ref);
    if (ns_tag >= 0)
      out_rc = backend_enc_mov_imm32_to_w0_arch(elf_ctx, ns_tag, ta);
    else
      out_rc = -1;
  } else
    out_rc = backend_emit_expr_elf_slow(arena, elf_ctx, expr_ref, ctx, ta);
debug_done:
  /* #region debug-point A:regex-asm-expr-recursion */
  if (dbg_on && dbg_log_now && out_rc == PIPELINE_ASM_ELF_EXPR_FAST_UNHANDLED) {
    fprintf(stderr,
            "xlang: [XLANG_DEBUG_REGEX_EMIT] unhandled depth=%d expr_ref=%d ko=%d\n",
            (int)dbg_depth_now, (int)expr_ref, (int)ko);
  }
  if (dbg_on && dbg_depth > 0)
    dbg_depth = dbg_depth - 1;
  /* #endregion debug-point A:regex-asm-expr-recursion */
  return out_rc;
}

