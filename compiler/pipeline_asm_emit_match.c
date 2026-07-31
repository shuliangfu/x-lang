/**
 * pipeline_asm_emit_match.c — asm ELF EXPR_MATCH + EXPR_IF emit domain
 * (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding control-flow expr ELF emit:
 * - pipeline_asm_emit_match_elf_c (matched value in rbx; arm cmp+jeq; wildcard
 *   default; arm results join at done; RETURN arm skips join — Cap residual
 *   pure; avoids ko==43 backend_emit_expr_elf_slow ↔ emit_expr_elf_c recursion)
 * - pipeline_asm_emit_expr_if_elf_c (cond emit + jz else + then/else arms via
 *   expr_if_arm; optional else → imm 0 — Cap residual pure)
 *
 * G.7: single product-mega MATCH / EXPR_IF ELF face — do not open a second
 * control-flow expr emitter. CALL / METHOD_CALL bodies live in
 * backend_call_dispatch seed (glue holds forward decls only). Nested helpers
 * (expr_if_arm, glue_enc_jz_after_bool_in_eax, expr_elf_rec) remain in
 * pipeline_glue.c / earlier #include slices (same TU).
 *
 * Callers: expr_elf_rec / mega MATCH and IF arms.
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c immediately
 * after pipeline_asm_emit_index.c (after call/method_call/panic forward decls;
 * before glue_var_expr_stack_off helpers).
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/* Forward decls / callees defined elsewhere in the same TU:
 * - pipeline_asm_emit_expr_elf_rec (static; declared earlier in pipeline_glue.c)
 * - pipeline_asm_emit_expr_if_arm_elf_c (defined earlier)
 * - pipeline_asm_emit_next_label_c (extern / defined earlier)
 * - glue_enc_jz_after_bool_in_eax (static in pipeline_asm_emit_unary.c, #included earlier)
 * - backend_enc_*_arch, pipeline_expr_match_*, pipeline_expr_if_*, link_abi_getenv
 */

/**
 * EXPR_MATCH ELF 发射：待匹配值在 rbx，逐臂 cmp+jeq，通配符/default 兜底，各臂结果汇合于 done。
 * 避免 ko==43 落 backend_emit_expr_elf_slow 与 pipeline_asm_emit_expr_elf_c 互递归 SIGSEGV。
 */
int32_t pipeline_asm_emit_match_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t matched_ref;
  int32_t num_arms;
  int32_t wild_idx;
  int32_t i;
  int32_t cmp_val;
  int32_t arm_lbl_len[32];
  uint8_t arm_lbl[32][128];
  uint8_t done_lbl[128];
  int32_t done_len;
  int32_t result_ref;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  matched_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
  num_arms = pipeline_expr_match_num_arms_at(arena, expr_ref);
  if (matched_ref <= 0 || num_arms <= 0 || num_arms > 32)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, matched_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  wild_idx = -1;
  for (i = 0; i < num_arms; i++) {
    if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i) != 0) {
      wild_idx = i;
      continue;
    }
    arm_lbl_len[i] = pipeline_asm_emit_next_label_c(ctx, arm_lbl[i], 64);
    if (arm_lbl_len[i] <= 0)
      return -1;
    if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, i) != 0)
      cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, i);
    else
      cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, i);
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, cmp_val, ta) != 0)
      return -1;
    if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_jeq_arch(elf_ctx, arm_lbl[i], arm_lbl_len[i], ta) != 0)
      return -1;
  }
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (done_len <= 0)
    return -1;
  if (wild_idx >= 0) {
    result_ref = pipeline_expr_match_arm_result_ref(arena, expr_ref, wild_idx);
    if (result_ref <= 0 || pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, result_ref, ctx, ta) != 0)
      return -1;
    /*
     * wave372: EXPR_RETURN arm already jmps to function tail_join — do not fall
     * through / jmp done (same discipline as if-then with return in stmt_order).
     * PLATFORM: SHARED freestanding · LINUX+MACOS x86_64/aarch64.
     */
    if (pipeline_expr_kind_ord_at(arena, result_ref) != 41) {
      if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
        return -1;
    }
  } else if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) {
    return -1;
  } else if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0) {
    return -1;
  }
  for (i = 0; i < num_arms; i++) {
    if (pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i) != 0)
      continue;
    if (backend_enc_label_arch(elf_ctx, arm_lbl[i], arm_lbl_len[i], 0, ta) != 0)
      return -1;
    result_ref = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
    if (result_ref <= 0 || pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, result_ref, ctx, ta) != 0)
      return -1;
    /* wave372: RETURN arm → real early return; skip join to done. */
    if (pipeline_expr_kind_ord_at(arena, result_ref) != 41) {
      if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
        return -1;
    }
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  return 0;
}

int32_t pipeline_asm_emit_expr_if_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                               int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t cond;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[128];
  uint8_t done_lbl[128];
  int32_t else_len;
  int32_t done_len;
  cond = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  then_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
  else_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
    fprintf(stderr, "xlang: if_elf_c expr=%d cond=%d then=%d else=%d\n", (int)expr_ref, (int)cond, (int)then_ref,
            (int)else_ref);
  if (cond == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, cond, ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
      fprintf(stderr, "xlang: if_elf_c cond emit fail\n");
    return -1;
  }
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
    fprintf(stderr, "xlang: if_elf_c cond ok, labels...\n");
  else_len = pipeline_asm_emit_next_label_c(ctx, else_lbl, 64);
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
    fprintf(stderr, "xlang: if_elf_c else_len=%d done_len=%d jz...\n", (int)else_len, (int)done_len);
  if (else_len <= 0 || done_len <= 0)
    return -1;
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, else_lbl, else_len, ta) != 0)
    return -1;
  if (link_abi_getenv("XLANG_ASM_EMIT_TRACE"))
    fprintf(stderr, "xlang: if_elf_c then arm...\n");
  if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, then_ref, ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: if_elf_c then fail expr_ref=%d then_ref=%d kind=%d\n", (int)expr_ref, (int)then_ref,
              (int)pipeline_expr_kind_ord_at(arena, then_ref));
    return -1;
  }
  if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
    return -1;
  if (else_ref != 0) {
    if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, else_ref, ctx, ta) != 0) {
      if (link_abi_getenv("XLANG_ASM_DEBUG"))
        fprintf(stderr, "xlang: if_elf_c else fail expr_ref=%d else_ref=%d\n", (int)expr_ref, (int)else_ref);
      return -1;
    }
  } else {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
      return -1;
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  return 0;
}
