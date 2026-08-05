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
 * - g_pipeline_asm_emit_module / g_pipeline_asm_emit_func_index (statics)
 * - pipeline_expr_resolved_type_ref / pipeline_module_func_param_type_ref_for_name
 * - pipeline_expr_var_name_* (expr_rec / sidecar)
 */
/* Same-file subject context (defined below match_elf; needed for field-bind arms). */
void pipeline_codegen_match_set_subject_c(struct ast_Module *module, int32_t matched_ref, int32_t subject_ty);
int32_t pipeline_codegen_match_matched_ref_c(void);
int32_t pipeline_codegen_match_subject_ty_c(void);
struct ast_Module *pipeline_codegen_match_mod_c(void);

/* wave700/708: optional `pat if cond` / struct field-lit implicit guard. */
extern int32_t pipeline_expr_match_arm_guard_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);

/**
 * EXPR_MATCH ELF emit — sequential first-match arm chain (host-C twin).
 *
 * Shape (mirrors codegen_emit_match_from_arm / codegen_emit_match_as_stmt):
 *   - pure wildcard (no guard) → terminal default arm
 *   - wildcard + guard → emit guard; jz next; body; jmp done
 *     (struct field-lit `Point { x:0, y:0 }` is stored as wildcard+implicit guard)
 *   - lit/enum [+ optional guard] → re-emit subject; cmp; jne next; [guard]; body
 * Arms join at done. RETURN arm skips join (wave372).
 *
 * wave707 freestanding twin: set host-C match subject context for the duration
 * of arm/guard emit so bare field-bind VARs (`Point { x, y } => x + y`) resolve
 * as subject.field loads (see glue_try_emit_match_subject_field_var_elf_c in
 * expr_rec). Without this hop, Ubuntu pure-asm CG002s (VAR has no stack slot).
 * G.7: same pipeline_codegen_match_* subject + guard_ref authority as host-C.
 * PLATFORM: SHARED freestanding · LINUX gold (Ubuntu pure-asm) · MACOS co-path.
 *
 * Avoids ko==43 → backend_emit_expr_elf_slow ↔ emit_expr_elf_c recursion SIGSEGV.
 */
int32_t pipeline_asm_emit_match_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                      int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t matched_ref;
  int32_t num_arms;
  int32_t i;
  int32_t cmp_val;
  int32_t is_wild;
  int32_t guard_ref;
  uint8_t done_lbl[128];
  uint8_t next_lbl[128];
  int32_t done_len;
  int32_t next_len;
  int32_t result_ref;
  struct ast_Module *prev_mod;
  int32_t prev_mref;
  int32_t prev_ty;
  int32_t rc;
  int32_t saw_terminal_wild;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  matched_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
  num_arms = pipeline_expr_match_num_arms_at(arena, expr_ref);
  if (matched_ref <= 0 || num_arms <= 0 || num_arms > 32)
    return -1;
  /*
   * Freestanding field-bind + guards: activate subject context before any arm
   * result / guard emit. Nested MATCH saves/restores prev_* like host-C.
   */
  prev_mod = pipeline_codegen_match_mod_c();
  prev_mref = pipeline_codegen_match_matched_ref_c();
  prev_ty = pipeline_codegen_match_subject_ty_c();
  if (g_pipeline_asm_emit_module != 0 && matched_ref > 0) {
    int32_t subj_ty = pipeline_expr_resolved_type_ref(arena, matched_ref);
    if (subj_ty <= 0 && pipeline_expr_kind_ord_at(arena, matched_ref) == 3 &&
        g_pipeline_asm_emit_func_index >= 0) {
      uint8_t mn[128];
      int32_t mln = pipeline_expr_var_name_len(arena, matched_ref);
      if (mln > 0 && mln <= 127) {
        pipeline_expr_var_name_into(arena, matched_ref, mn);
        subj_ty = pipeline_module_func_param_type_ref_for_name(g_pipeline_asm_emit_module,
                                                              g_pipeline_asm_emit_func_index, mn, mln);
      }
    }
    if (subj_ty > 0)
      pipeline_codegen_match_set_subject_c(g_pipeline_asm_emit_module, matched_ref, subj_ty);
  }
  rc = -1;
  saw_terminal_wild = 0;
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (done_len <= 0)
    goto match_elf_done;
  for (i = 0; i < num_arms; i++) {
    is_wild = pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i);
    guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, i);
    result_ref = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
    if (result_ref <= 0)
      goto match_elf_done;
    /*
     * Terminal pure wildcard (no guard): default arm — emit body and end chain.
     * Host-C: first pure wild ends ternary / becomes else. Arms after are dead.
     */
    if (is_wild != 0 && guard_ref <= 0) {
      if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, result_ref, ctx, ta) != 0)
        goto match_elf_done;
      /* wave372: RETURN arm already jmps to function tail_join — skip join. */
      if (pipeline_expr_kind_ord_at(arena, result_ref) != 41) {
        if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
          goto match_elf_done;
      }
      saw_terminal_wild = 1;
      break;
    }
    next_len = pipeline_asm_emit_next_label_c(ctx, next_lbl, 64);
    if (next_len <= 0)
      goto match_elf_done;
    if (is_wild != 0) {
      /*
       * wave708: wildcard + guard — condition is the guard only
       * (struct field-lit patterns + `_ if cond`).
       * Guard expr reloads subject from stack/VAR; no rbx subject cache needed.
       */
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, guard_ref, ctx, ta) != 0)
        goto match_elf_done;
      if (glue_enc_jz_after_bool_in_eax(elf_ctx, next_lbl, next_len, ta) != 0)
        goto match_elf_done;
    } else {
      /*
       * Lit / enum arm: re-emit subject each arm so guard / field-lit paths that
       * clobber rbx cannot poison later scalar compares (host-C re-emits too).
       */
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, matched_ref, ctx, ta) != 0)
        goto match_elf_done;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        goto match_elf_done;
      if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, i) != 0)
        cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, i);
      else
        cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, i);
      if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, cmp_val, ta) != 0)
        goto match_elf_done;
      if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
        goto match_elf_done;
      if (backend_enc_jne_arch(elf_ctx, next_lbl, next_len, ta) != 0)
        goto match_elf_done;
      /* wave708: non-wildcard + guard — append guard test after lit match. */
      if (guard_ref > 0) {
        if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, guard_ref, ctx, ta) != 0)
          goto match_elf_done;
        if (glue_enc_jz_after_bool_in_eax(elf_ctx, next_lbl, next_len, ta) != 0)
          goto match_elf_done;
      }
    }
    if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, result_ref, ctx, ta) != 0)
      goto match_elf_done;
    /* wave372: RETURN arm → real early return; skip join to done. */
    if (pipeline_expr_kind_ord_at(arena, result_ref) != 41) {
      if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
        goto match_elf_done;
    }
    if (backend_enc_label_arch(elf_ctx, next_lbl, next_len, 0, ta) != 0)
      goto match_elf_done;
  }
  /* Exhausted arms with no pure-wild default: result 0 (host-C emits '0'). */
  if (saw_terminal_wild == 0) {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
      goto match_elf_done;
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    goto match_elf_done;
  rc = 0;
match_elf_done:
  pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
  return rc;
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

/* wave1174 G.7: codegen match subject context cluster (6 fns + 3 statics)
 * migrated from pipeline_glue.c L6719-6813. Colocated with MATCH emit domain
 * — the subject-field lookup is consumed by MATCH arm codegen to emit
 * matched.x / matched.y field accesses instead of bare x/y (which would be
 * undeclared C).
 *
 * No glue.c callsites (sole callers are codegen_gen.c seed via extern).
 * No fwd decls needed (definitions in this file via #include at glue.c L1991
 * precede codegen_gen.c extern refs).
 * PLATFORM: SHARED — host-cc via pipeline_x.o TU. */

/*
 * wave707: host-C match field-bind emit context.
 * typeck already resolves `Point { x, y } => x + y` VARs as subject fields
 * (wildcard arms). Codegen must emit `matched.x` / `matched.y` — bare `x`/`y`
 * is undeclared C.
 * PLATFORM: SHARED — G.7 single authority with typeck subject-field lookup.
 */
static int32_t g_codegen_match_matched_ref = 0;
static int32_t g_codegen_match_subject_ty = 0;
static struct ast_Module *g_codegen_match_mod = 0;

/**
 * Set the active match subject context (module + matched expr ref + subject type).
 * Why: codegen_gen seed calls this before emitting MATCH arms so that
 *      field-name lookups can resolve to subject.field accesses.
 */
void pipeline_codegen_match_set_subject_c(struct ast_Module *module, int32_t matched_ref, int32_t subject_ty) {
  g_codegen_match_mod = module;
  g_codegen_match_matched_ref = matched_ref;
  g_codegen_match_subject_ty = subject_ty;
}

/** Clear the match subject context after emitting all MATCH arms. */
void pipeline_codegen_match_clear_subject_c(void) {
  g_codegen_match_mod = 0;
  g_codegen_match_matched_ref = 0;
  g_codegen_match_subject_ty = 0;
}

/** Get the currently matched expression ref (0 if no active match context). */
int32_t pipeline_codegen_match_matched_ref_c(void) {
  return g_codegen_match_matched_ref;
}

/** Get the currently active subject type ref (0 if no active match context). */
int32_t pipeline_codegen_match_subject_ty_c(void) {
  return g_codegen_match_subject_ty;
}

/** Get the currently active match module (NULL if no active match context). */
struct ast_Module *pipeline_codegen_match_mod_c(void) {
  return g_codegen_match_mod;
}

/**
 * wave707: return 1 if name is a field of the active host-C match subject
 * struct type. Same layout scan shape as typeck match subject field lookup.
 * Why: during MATCH arm codegen, bare field names (e.g. `x`) must be resolved
 *      to `matched.x` to avoid undeclared C identifiers; this check tells
 *      codegen whether a given name is a subject field.
 * Contract: returns 0 when no active match context, or when name does not
 *           match any field of the subject struct layout.
 * Dependencies: pipeline_type_kind_ord_at + pipeline_type_named_name_into
 *               (ast_pool_type.c) + pipeline_module_struct_layout_* (ast_pool.c).
 */
int32_t pipeline_codegen_match_name_is_subject_field_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      uint8_t *name, int32_t name_len) {
  int32_t ty;
  int32_t k;
  int32_t nsl;
  int32_t fi;
  int32_t nf;
  int32_t fl;
  int32_t j;
  uint8_t tnm[128];
  uint8_t fnm[128];
  int32_t tnl;
  if (!module || !arena || !name || name_len <= 0)
    return 0;
  ty = g_codegen_match_subject_ty;
  if (ty <= 0 || g_codegen_match_mod != module || g_codegen_match_matched_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty) != (int32_t)ast_TypeKind_TYPE_NAMED)
    return 0;
  tnl = pipeline_type_named_name_into(arena, ty, tnm);
  if (tnl <= 0)
    return 0;
  nsl = module->num_struct_layouts;
  for (k = 0; k < nsl; k++) {
    fl = pipeline_module_struct_layout_name_len(module, k);
    if (fl != tnl)
      continue;
    {
      int32_t match = 1;
      int32_t bi;
      for (bi = 0; bi < fl && match; bi++) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, bi) != tnm[bi])
          match = 0;
      }
      if (!match)
        continue;
    }
    nf = pipeline_module_struct_layout_num_fields(module, k);
    for (fi = 0; fi < nf; fi++) {
      int32_t fnl = pipeline_module_struct_layout_field_name_len(module, k, fi);
      if (fnl != name_len)
        continue;
      memset(fnm, 0, sizeof(fnm));
      pipeline_module_struct_layout_field_name_into(module, k, fi, fnm);
      {
        int32_t match = 1;
        for (j = 0; j < fnl && match; j++) {
          if (fnm[j] != name[j])
            match = 0;
        }
        if (match)
          return 1;
      }
    }
  }
  return 0;
}
