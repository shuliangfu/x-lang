/**
 * pipeline_asm_emit_block_body.c — asm ELF block body sync emit domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for product-mega freestanding block body ELF emit:
 * - GLUE_BLOCK_LET_DEFER_MAX + pass0/pass1 let defer mask (INDEX/CALL/METHOD +
 *   transitive use of deferred slots + stmt_order side-effect barriers)
 * - glue_live_fwd_collect_expr_uses_for_defer / glue_block_defer_lets_transitive
 * - glue_block_compute_pass1_deferred_lets
 * - pipeline_asm_emit_block_body_sync_elf (stmt_order C for-loop body emit)
 * - backend_emit_block_body_sync_elf (backend.x entry; module/dep_pipe snap)
 * - pipeline_asm_block_final_expr_ref_at / num_stmt_order_at /
 *   stmt_order_has_return (backend.x Block field accessors)
 *
 * G.7: single product-mega block_body_sync ELF path — do not open a second
 * stmt_order body emitter in seed partial or a parallel glue copy. Callers
 * (if_arm / mega_body / if_stmt / while) stay in pipeline_glue.c and call
 * these entry points (same TU). Nested block_if_stmt lives in
 * pipeline_asm_emit_block_if_stmt.c (wave976; same TU #include after this file).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c after
 * with_arena emit helpers and before block_if_stmt / expr field accessors.
 *
 * PLATFORM: SHARED — product residual C; host-cc via pipeline_x.o TU.
 */

/**
 * PLATFORM: SHARED — pure-asm two-pass let emit dependency mask.
 * Pass 0 hoists pure lets before if/loop (parser stmt_order can place let after if).
 * Seed pass-1 deferred: INDEX(47) / CALL(48) / METHOD_CALL(49) inits (side effects /
 * index-addr cache). Also mark any let whose init uses a deferred let slot (transitive
 * fixpoint), so `let extra = a + (buf[0] as i32)` is not evaluated before
 * `a = option.unwrap_or_i32(...)` (Ubuntu pure-asm tests/option SEGV / wrong value).
 */
#define GLUE_BLOCK_LET_DEFER_MAX 512

/* wave1042 G.7: forward decl — definition at EOF (block_body_sync_elf callsite
 * at line 768 precedes definition). Same-TU #include from pipeline_glue.c. */
static int glue_emit_block_final_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);

/* wave1043 G.7: forward decl — definition at EOF (callsites at lines 467/602
 * precede definition). Consumed by block_body_sync_elf + glue.c internal
 * (lines 6791/6872, after #include 4459 — visible there via this decl). */
static int32_t glue_emit_array_let_empty_init(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off);

/* wave1073 G.7: forward decl — definition at EOF (callsites at lines 819/851
 * precede definition). Also consumed by block_if_stmt.c:82 via #include at
 * glue.c L3875 > block_body.c L3872 (visible there via this decl). */
static int glue_block_stmt_order_has_return(struct ast_ASTArena *arena, int32_t block_ref);

/** Deeper use walk for defer analysis: INDEX / AS / field / array-lit elems / unaries. */
static void glue_live_fwd_collect_expr_uses_for_defer(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                     int32_t expr_ref, GlueBlockLiveFwd *gen) {
  int32_t ko;
  int32_t i;
  int32_t n;
  int32_t left_ref;
  int32_t right_ref;
  int32_t op_ref;
  int32_t off;
  if (!arena || !ctx || !gen || expr_ref <= 0)
    return;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == GLUE_EXPR_KIND_VAR) {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    if (off >= 0)
      glue_live_fwd_add(gen, off);
    return;
  }
  if (ko >= 4 && ko <= 21) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, right_ref, gen);
    return;
  }
  /* unary / LOGNOT / etc. */
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  /* EXPR_AS */
  if (ko == (int32_t)ast_ExprKind_EXPR_AS || pipeline_expr_as_operand_ref_at(arena, expr_ref) > 0) {
    op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
    if (op_ref <= 0)
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  /* EXPR_INDEX */
  if (ko == 47) {
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_index_base_ref(arena, expr_ref), gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_index_index_ref(arena, expr_ref), gen);
    return;
  }
  /* field access base */
  if (ko == 44) {
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_field_access_base_ref(arena, expr_ref), gen);
    return;
  }
  /* ARRAY_LIT elements (rare non-lit elems) */
  if (ko == 46) {
    n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    for (i = 0; i < n; i++)
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_array_lit_elem_ref(arena, expr_ref, i),
                                                gen);
    return;
  }
  /* STRUCT_LIT field inits */
  if (ko == 45) {
    n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    for (i = 0; i < n; i++)
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_struct_lit_init_ref(arena, expr_ref, i),
                                                gen);
    return;
  }
}

/**
 * Transitive fixpoint: any let whose init reads a deferred let's stack slot
 * is itself deferred (so pass0 cannot evaluate dependents before their sources).
 */
static void glue_block_defer_lets_transitive(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                            int32_t block_ref, int32_t slot_base, int32_t nconst, int32_t nlet,
                                            uint8_t *deferred) {
  int32_t li;
  int32_t changed;
  int32_t guard;
  GlueBlockLiveFwd uses;
  if (!arena || !ctx || !deferred || nlet <= 0)
    return;
  for (guard = 0; guard < nlet + 2; guard++) {
    changed = 0;
    for (li = 0; li < nlet; li++) {
      int32_t init_ref;
      int32_t ui;
      int32_t uj;
      if (deferred[li])
        continue;
      init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, li);
      if (init_ref <= 0)
        continue;
      glue_live_fwd_clear(&uses);
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, init_ref, &uses);
      for (ui = 0; ui < uses.n; ui++) {
        int32_t off = uses.offs[ui];
        for (uj = 0; uj < nlet; uj++) {
          if (!deferred[uj])
            continue;
          if (backend_asm_ctx_slot_offset(ctx, slot_base + nconst + uj) == off) {
            deferred[li] = 1;
            changed = 1;
            break;
          }
        }
        if (deferred[li])
          break;
      }
    }
    if (!changed)
      break;
  }
}

/**
 * Mark lets that must stay in pass 1 (stmt_order position).
 * @param deferred out[0..nlet) 1 = pass1 only; caller supplies buffer of size nlet
 *
 * Pass 0 still hoists pure lets (no stack reads) before if/loop — parser order
 * workaround for with_arena. wave320: never hoist a stack-reading let past an
 * earlier expr_stmt (kind 2). wave321: also never hoist past earlier while/for/
 * if/region (kinds 3–6) — nested assigns mutate outer slots
 * (`let a=0; if(1){a=6;} let b=a` was emitting b=a before the if → freestanding
 * run=0; mac host-gcc may hide). After stmt-order barriers, re-run transitive
 * so `let c=b` after a newly deferred `let b=a` also stays in pass1.
 * PLATFORM: SHARED — ELF block_body_sync pass0/pass1 ordering.
 */
static void glue_block_compute_pass1_deferred_lets(struct ast_ASTArena *arena, struct backend_AsmFuncCtx *ctx,
                                                  int32_t block_ref, int32_t slot_base, int32_t nconst, int32_t nlet,
                                                  uint8_t *deferred) {
  int32_t li;
  int32_t nso;
  int32_t si;
  GlueBlockLiveFwd uses;
  if (!arena || !ctx || !deferred || nlet <= 0)
    return;
  for (li = 0; li < nlet; li++) {
    int32_t init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, li);
    int32_t ko = init_ref > 0 ? pipeline_expr_kind_ord_at(arena, init_ref) : 0;
    /* INDEX / CALL / METHOD_CALL: historical pass-1 seeds (side effects / addr cache). */
    deferred[li] = (uint8_t)(ko == 47 || ko == 48 || ko == 49 ? 1 : 0);
  }
  glue_block_defer_lets_transitive(arena, ctx, block_ref, slot_base, nconst, nlet, deferred);
  /**
   * wave320/wave321 Cap residual: pure-let pass0 must not reorder past earlier
   * side-effecting or control-flow stmts that can mutate stack slots.
   * stmt_order: kind 2 = expr_stmt (assign/call); 3=while; 4=for; 5=if; 6=region.
   * If a let's init reads any stack slot and any such stmt appears before this
   * let in source order, keep the let at its pass1 position.
   * Pure lit lets (uses.n==0) may still hoist past if/while (with_arena workaround).
   */
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (li = 0; li < nlet; li++) {
    int32_t init_ref;
    int32_t let_si;
    int32_t j;
    if (deferred[li])
      continue;
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, li);
    if (init_ref <= 0)
      continue;
    glue_live_fwd_clear(&uses);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, init_ref, &uses);
    if (uses.n <= 0)
      continue; /* pure lit / no stack reads — safe to hoist past assigns/cfg */
    let_si = -1;
    for (si = 0; si < nso; si++) {
      if (ast_ast_block_stmt_order_kind(arena, block_ref, si) == 1 &&
          ast_ast_block_stmt_order_idx(arena, block_ref, si) == li) {
        let_si = si;
        break;
      }
    }
    if (let_si < 0)
      continue;
    for (j = 0; j < let_si; j++) {
      uint8_t sk = ast_ast_block_stmt_order_kind(arena, block_ref, j);
      /* kind 2 expr_stmt; 3 while; 4 for; 5 if; 6 region; 7 goto/label — do not hoist past */
      if (sk == 2 || sk == 3 || sk == 4 || sk == 5 || sk == 6 || sk == 7) {
        deferred[li] = 1;
        break;
      }
    }
  }
  /* Re-close transitive after stmt-order barriers (dependents of newly deferred). */
  glue_block_defer_lets_transitive(arena, ctx, block_ref, slot_base, nconst, nlet, deferred);
}

/**
 * 按 stmt_order 同步发射块体（C for 循环）：避免 xlang-c -E 使 backend.x 内 while(i<nso) 只跑一轮，
 * 导致 while 体内仅首条 if/赋值被发射（escape 的 else 与 j++ 丢失）。
 */
int32_t pipeline_asm_emit_block_body_sync_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  int32_t nconst;
  int32_t nlet;
  int32_t slot_base;
  int32_t nso;
  int32_t i;
  uint8_t let_defer_stack[GLUE_BLOCK_LET_DEFER_MAX];
  uint8_t *let_defer = NULL;
  /** 父 cfg 块 Chaitin 着色 / live_cfg_parent 快照（if 子块 emit 后须恢复）。 */
  int32_t saved_cfg_color_active;
  int32_t saved_cfg_live_parent;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return -1;
  if (link_abi_getenv("XLANG_ASM_DEBUG") != NULL) {
    static int32_t dbg_block_sync_n;
    if (dbg_block_sync_n < 12) {
      int32_t fn_body_dbg = 0;
      if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0)
        fn_body_dbg = pipeline_module_func_body_ref_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
      fprintf(stderr, "xlang: emit_block_body_sync br=%d nso=%d nif=%d ta=%d\n", (int)block_ref,
              (int)ast_ast_block_num_stmt_order(arena, block_ref),
              (int)ast_ast_block_num_if_stmts(arena, block_ref), (int)ta);
      fprintf(stderr, "xlang: emit_block_scope fi=%d fn_body=%d block=%d nlet=%d nconst=%d\n",
              (int)g_pipeline_asm_emit_func_index, (int)fn_body_dbg, (int)block_ref,
              (int)ast_ast_block_num_lets(arena, block_ref), (int)ast_ast_block_num_consts(arena, block_ref));
      fflush(stderr);
      dbg_block_sync_n++;
    }
  }
  saved_cfg_color_active = glue_asm73_cfg_coloring_active;
  saved_cfg_live_parent = glue_block_live_cfg_parent;
  glue_index_assign_addr_cache_clear();
  glue_binop_var_slot_cache_clear();
  glue_binop_stack_spill_clear();
  glue_asm73_pin_spill_off[0] = -1;
  glue_asm73_pin_spill_off[1] = -1;
  glue_asm73_pin_spill_off[2] = -1;
  glue_asm73_pin_spill_off[3] = -1;
  glue_asm73_pin_spill_off[4] = -1;
  glue_asm73_pin_spill_off[5] = -1;
  /** cfg 父块着色表在入口 Chaitin 后保留；if/while 子块 emit 勿清空（此前会 wipe 导致 final_expr 无 which=6）。 */
  if (!glue_asm73_cfg_coloring_active)
    glue_asm73_clear_spill_color_map();
  (void)glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  glue_index_subadd3_sum_cache_clear();
  glue_index_minus_pair_cache_clear();
  glue_index_scratch_stack_depth = 0;
  glue_binop_rax_frame_spill_n = 0;
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
  /** 预登记本块及 if/while/for 子树全部 let（修复 get_field_offset_from_layout 内层 `j` 未入 ctx）。 */
  pipeline_asm_fill_block_locals_tree(ctx, arena, block_ref);
  /** MEM-C1：函数根块体 emit 开始时预留 with_arena 临时 Arena64 区基址。 */
  if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
    int32_t fn_body = pipeline_module_func_body_ref_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
    if (fn_body == block_ref)
      glue_wa_emit_begin_func_c(ctx, arena, block_ref);
  }
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  slot_base = backend_block_slot_base_for(ctx, arena, block_ref);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  /** Pass-1 deferred let mask (CALL/INDEX + transitive users). Cap stack; oversize → all non-pure seed only. */
  if (nlet > 0 && nlet <= GLUE_BLOCK_LET_DEFER_MAX) {
    let_defer = let_defer_stack;
    glue_block_compute_pass1_deferred_lets(arena, ctx, block_ref, slot_base, nconst, nlet, let_defer);
  } else {
    let_defer = NULL;
  }
  glue_block_live_cfg_parent = glue_block_stmt_order_has_cfg(arena, block_ref);
  glue_block_live_fwd_active = 1;
  glue_live_fwd_clear(&glue_block_live_fwd);
  if (glue_block_live_cfg_parent && !saved_cfg_color_active) {
    /** 仅最外层 cfg 父块重算 Chaitin；嵌套 if+while 子块勿 wipe 父块着色表。 */
    glue_block_compute_cfg_peak_live_and_color(arena, ctx, block_ref, slot_base, nconst, nlet);
    /**
     * final_expr peak < 4：cfg 前向 next-use 在 emit 中不稳定；本块改线性 live+pin，着色表仍供 then/else 继承。
     */
    if (glue_asm73_cfg_peak_live.n >= 4)
      glue_asm73_cfg_coloring_active = 1;
    else {
      glue_asm73_cfg_coloring_active = 0;
      glue_block_compute_linear_live_in(arena, ctx, block_ref, slot_base, nconst, nlet);
      glue_asm73_compute_spill_color_pins();
    }
  } else if (saved_cfg_color_active) {
    /** cfg 子块（含内层 while/for）：继承父块着色与 final_expr 阈值，不重算 Chaitin。 */
    glue_asm73_cfg_coloring_active = 1;
    /**
     * 线性 then/else 体：须本块 live_at_stmt；否则 before_stmt 误读父 cfg 块槽位 SIGSEGV。
     */
    if (!glue_block_live_cfg_parent)
      glue_block_compute_linear_live_in(arena, ctx, block_ref, slot_base, nconst, nlet);
  } else {
    glue_asm73_cfg_coloring_active = 0;
    glue_block_compute_linear_live_in(arena, ctx, block_ref, slot_base, nconst, nlet);
    glue_asm73_compute_spill_color_pins();
  }
  /**
   * 两遍 emit：const/let 先于 if/loop（parser stmt_order 偶发 let 晚于 if → with_arena_vec 未初始化 push SIGSEGV）。
   * INDEX 初值 let 除外：须在 stmt_order 原位 emit，以便复用/失效上一笔 INDEX assign 址缓存（read-between）。
   */
  /** const 按声明下标序预先落栈；stmt_order 乱序时避免 `const B = A + 2` 在 A 之前 emit。 */
  for (i = 0; i < nconst; i++) {
    int32_t init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, i);
    if (init_ref != 0 && !glue_init_is_empty_array_lit(arena, init_ref)) {
      glue_index_assign_addr_cache_clear();
      if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot_base + i), ta) != 0)
        return -1;
    }
  }
  if (link_abi_getenv("XLANG_ASM_DEBUG2") != NULL) {
    int32_t dbg_fn_body2 = 0;
    if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0)
      dbg_fn_body2 = pipeline_module_func_body_ref_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
    fprintf(stderr, "xlang: SO-BEGIN fi=%d br=%d nso=%d is_fn_body=%d\n",
            (int)g_pipeline_asm_emit_func_index, (int)block_ref, (int)nso, (int)(dbg_fn_body2 == block_ref));
    fflush(stderr);
    for (i = 0; i < nso; i++) {
      uint8_t dk = ast_ast_block_stmt_order_kind(arena, block_ref, i);
      int32_t dix = ast_ast_block_stmt_order_idx(arena, block_ref, i);
      int32_t init_ko = -1;
      if (dk == 1 && dix >= 0 && dix < nlet) {
        int32_t iref = ast_pipeline_block_let_init_ref(arena, block_ref, dix);
        init_ko = iref > 0 ? pipeline_expr_kind_ord_at(arena, iref) : -1;
      }
      fprintf(stderr, "xlang: SO fi=%d br=%d [%d] kind=%d idx=%d init_ko=%d\n",
              (int)g_pipeline_asm_emit_func_index, (int)block_ref, (int)i, (int)dk, (int)dix, (int)init_ko);
      fflush(stderr);
    }
  }
  {
    int32_t pass;
    for (pass = 0; pass < 2; pass++) {
  for (i = 0; i < nso; i++) {
    uint8_t item_kind = ast_ast_block_stmt_order_kind(arena, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
    if (pass == 0) {
      if (item_kind == 0)
        continue;
      if (item_kind != 1)
        continue;
      /**
       * Pass 0: pure lets only (literals / array lit / binops of already-pure slots).
       * Defer INDEX/CALL/METHOD_CALL and any let that uses a deferred slot (transitive).
       * PLATFORM: SHARED — without transitive defer, option pure-asm SEGV at main entry.
       */
      if (item_kind == 1 && idx >= 0 && idx < nlet) {
        int32_t ix_init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
        int32_t ix_ko = ix_init_ref > 0 ? pipeline_expr_kind_ord_at(arena, ix_init_ref) : 0;
        if (let_defer != NULL) {
          if (let_defer[idx])
            continue;
        } else {
          /* Fallback when nlet > GLUE_BLOCK_LET_DEFER_MAX: historical seed only. */
          if (ix_ko == 47 || ix_ko == 48 || ix_ko == 49)
            continue;
        }
      }
    } else if (item_kind == 0) {
      continue;
    } else if (item_kind == 1) {
      /** pass 0 已发射无依赖纯 let；pass 1 补 deferred（INDEX/CALL/METHOD_CALL + 依赖它们的 let）。 */
      if (idx < 0 || idx >= nlet)
        continue;
      {
        int32_t ix_init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
        int32_t ix_ko = ix_init_ref > 0 ? pipeline_expr_kind_ord_at(arena, ix_init_ref) : 0;
        if (ix_init_ref <= 0)
          continue;
        if (let_defer != NULL) {
          if (!let_defer[idx])
            continue;
        } else if (ix_ko != 47 && ix_ko != 48 && ix_ko != 49) {
          continue;
        }
      }
    }
    glue_block_emit_stmt_i = i;
    glue_block_live_fwd_before_stmt(i, ta, elf_ctx);
    if (item_kind == 0) {
      if (idx >= 0 && idx < nconst) {
        int32_t init_ref = ast_pipeline_block_const_init_ref(arena, block_ref, idx);
        if (init_ref != 0) {
          if (glue_init_is_empty_array_lit(arena, init_ref)) {
            /* 空 [] 初值：无 store，与 emit_block_inits_elf 一致。 */
          } else {
            glue_index_assign_addr_cache_clear();
            if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0)
              return -1;
            else if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot_base + idx), ta) !=
                0)
              return -1;
            glue_block_live_fwd_apply_top_stmt(arena, ctx, block_ref, slot_base, nconst, nlet, i);
          }
        }
      }
    } else if (item_kind == 1) {
      if (idx >= 0 && idx < nlet) {
        int32_t slot = slot_base + nconst + idx;
        int32_t init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, idx);
        uint8_t lnb[128];
        int32_t llen = pipeline_block_let_name_len(arena, block_ref, idx);
        /** emit 前懒登记 let 栈槽（if 体内 let 可能未进 fill_tree 子树）。 */
        if (llen > 0) {
          pipeline_block_let_name_copy64(arena, block_ref, idx, lnb);
          if (glue_lazy_append_block_let_local(arena, ctx, block_ref, idx, lnb, llen) != 0)
            return -1;
        }
        if (init_ref != 0) {
          if (glue_init_is_empty_array_lit(arena, init_ref)) {
            int32_t tref_empty;
            int32_t slice_st_empty;
            tref_empty = pipeline_block_let_type_ref(arena, block_ref, idx);
            /**
             * wave330 Cap residual pure: TYPE_SLICE + `[]` actively store dual-GP
             * {data, length=0}. Prior path skipped empty ARRAY_LIT entirely (only prologue
             * zeros) → soft residual vs host-C `.length = 0` compound.
             * G.7: reuse glue_emit_slice_from_array_let_init_elf_c (ARRAY_LIT n=0).
             * PLATFORM: SHARED freestanding emit.
             */
            slice_st_empty =
                glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref, tref_empty,
                                                          ctx, ta, backend_asm_ctx_slot_offset(ctx, slot));
            if (slice_st_empty == 1) {
              /* empty fat slice written */
            } else if (slice_st_empty < 0) {
              return -1;
            } else if (glue_block_let_is_fixed_array_type(arena, block_ref, idx)) {
              /** T[N] = [] 内联 blob；prologue 已清零栈，勿 pointer+temp（会错位 offset 0）。 */
            } else if (glue_array_temp_bytes_for_let_init(arena, tref_empty, 0) > 0) {
              if (glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, backend_asm_ctx_slot_offset(ctx, slot)) != 0)
                return -1;
              pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
            }
          } else if (glue_block_let_is_fixed_array_type(arena, block_ref, idx)) {
            /* wave354: T[N] = ARRAY_LIT/VAR/FIELD/CALL element-wise (G.7 fixed_array_type_let). */
            int32_t arr_st = glue_emit_fixed_array_type_let_init_elf_c(
                arena, elf_ctx, init_ref, ctx, ta, pipeline_block_let_type_ref(arena, block_ref, idx),
                backend_asm_ctx_slot_offset(ctx, slot));
            if (arr_st == 0) {
              /* fixed array payload written */
            } else if (arr_st == -1) {
              return -1;
            } else {
              if (link_abi_getenv("XLANG_ASM_DEBUG"))
                fprintf(stderr, "xlang: fixed array let (body) unhandled block=%d idx=%d init_ko=%d\n",
                        (int)block_ref, (int)idx, (int)pipeline_expr_kind_ord_at(arena, init_ref));
              return -1;
            }
          } else if (glue_block_let_is_simd_vector_type(arena, block_ref, idx)) {
            int32_t vtype_ref = pipeline_block_let_type_ref(arena, block_ref, idx);
            int32_t vst =
                glue_emit_vector_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                     backend_asm_ctx_slot_offset(ctx, slot), vtype_ref);
            if (vst == 0) {
              /* 向量 let 直写栈槽 */
            } else if (vst == -1) {
              return -1;
            } else {
              glue_index_assign_addr_cache_clear();
              if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0) {
              return -1;
            } else if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0) {
              return -1;
            }
            }
          } else {
            int32_t slice_st =
                glue_emit_slice_from_array_let_init_elf_c(arena, elf_ctx, block_ref, idx, init_ref,
                                                          pipeline_block_let_type_ref(arena, block_ref, idx), ctx, ta,
                                                          backend_asm_ctx_slot_offset(ctx, slot));
            if (slice_st == 1) {
              /* slice from array var 已写入 { data, length } */
            } else if (slice_st < 0) {
              return -1;
            } else {
            int32_t st =
                glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta,
                                                     pipeline_block_let_type_ref(arena, block_ref, idx),
                                                     backend_asm_ctx_slot_offset(ctx, slot));
            if (st == 0) {
              /* struct 字面量或 mk(...) 内联已写入 let 槽 */
            } else if (st == -1) {
              return -1;
            } else if (pipeline_expr_kind_ord_at(arena, init_ref) == 46) {
            /** u8[N] = [..] 非空 ARRAY_LIT：走 rec（pipeline_asm_emit_array_lit_elf_c）。 */
            glue_index_assign_addr_cache_clear();
            if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0) {
              if (link_abi_getenv("XLANG_ASM_DEBUG"))
                fprintf(stderr,
                        "xlang: block let array_lit slow fail block_ref=%d let_idx=%d init_ref=%d nlet=%d\n",
                        (int)block_ref, (int)idx, (int)init_ref, (int)ast_ast_block_num_lets(arena, block_ref));
              return -1;
            }
            if (backend_enc_store_rax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
              return -1;
            pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, init_ref, ctx);
            } else {
            int32_t ix_init;
            ix_init = glue_try_block_let_index_init_from_assign_cache_elf_c(arena, elf_ctx, ctx, init_ref, ta);
            if (ix_init < 0)
              return -1;
            if (ix_init == 0) {
              int32_t let_ty;
              int32_t init_ko;
              glue_index_assign_addr_cache_clear();
              let_ty = pipeline_block_let_type_ref(arena, block_ref, idx);
              init_ko = pipeline_expr_kind_ord_at(arena, init_ref);
              if (let_ty > 0 && pipeline_type_kind_ord_at(arena, let_ty) == GLUE_TYPE_KIND_F32_ORD && init_ko == 1) {
                if (glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, init_ref, ta, let_ty, 0) != 0)
                  return -1;
              } else if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, init_ref, ctx, ta) != 0) {
                if (link_abi_getenv("XLANG_ASM_DEBUG"))
                  fprintf(stderr,
                          "xlang: block let init emit fail block_ref=%d let_idx=%d name=%.*s init_ref=%d kind_ord=%d nlet=%d\n",
                          (int)block_ref, (int)idx, (int)(llen > 0 ? llen : 0),
                          (char *)(llen > 0 ? lnb : (uint8_t *)""), (int)init_ref,
                          (int)pipeline_expr_kind_ord_at(arena, init_ref),
                          (int)ast_ast_block_num_lets(arena, block_ref));
                return -1;
              }
            }
            {
              int32_t let_ty2 = pipeline_block_let_type_ref(arena, block_ref, idx);
              if (let_ty2 > 0 && pipeline_type_kind_ord_at(arena, let_ty2) == GLUE_TYPE_KIND_F32_ORD) {
                if (backend_enc_store_eax_to_rbp_arch(elf_ctx, backend_asm_ctx_slot_offset(ctx, slot), ta) != 0)
                  return -1;
              } else {
                /**
                 * wave315: true freestanding let path is pipeline_asm_emit_block_body_sync_elf
                 * (nso>0). wave314 only hooked block_inits (nso==0) + stmt_order_let_const
                 * sibling — hot path stored rax without cvtss2sd → f32 bits zero-extended as
                 * f64 (Ubuntu run=0; mac often const-folds the probe).
                 * G.7: reuse glue_maybe_promote_f32_to_f64_rax_elf_c + float_promote_src;
                 * prefer same-block VAR decl type over stamped resolved.
                 * PLATFORM: SHARED type gate / LINUX+MACOS x86_64|arm64 encode via arch helper.
                 */
                int32_t src_ty = glue_float_promote_src_ty_ref_c(arena, init_ref);
                if (pipeline_expr_kind_ord_at(arena, init_ref) == GLUE_EXPR_KIND_VAR) {
                  uint8_t vn[128];
                  int32_t vl = pipeline_expr_var_name_len(arena, init_ref);
                  if (vl > 0 && vl <= 63) {
                    int32_t bt;
                    pipeline_expr_var_name_into(arena, init_ref, vn);
                    bt = pipeline_block_resolve_var_type_ref(arena, block_ref, vn, vl);
                    if (bt > 0)
                      src_ty = bt;
                  }
                }
                if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, let_ty2, src_ty, ta) != 0)
                  return -1;
                if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, let_ty2,
                                                         backend_asm_ctx_slot_offset(ctx, slot), ta,
                                                         init_ref, ctx) != 0)
                  return -1;
              }
            }
            glue_binop_var_slot_cache_kill_def_at_slot(backend_asm_ctx_slot_offset(ctx, slot));
            glue_live_fwd_forward_after_def(arena, ctx, backend_asm_ctx_slot_offset(ctx, slot), init_ref);
            }
            }
          }
        } else if (glue_array_temp_bytes_for_let_init(arena, pipeline_block_let_type_ref(arena, block_ref, idx),
                                                      0) > 0) {
          if (glue_emit_array_let_empty_init(arena, elf_ctx, ctx, ta, backend_asm_ctx_slot_offset(ctx, slot)) != 0)
            return -1;
          pipeline_asm_bump_next_offset_after_let_init(arena, block_ref, idx, 0, ctx);
        }
        /** WPO-S3：let mid = await … 边界 emit save/suspend/restore。 */
        if (init_ref != 0 && glue_expr_is_await_at_c(arena, init_ref)) {
          if (glue_async_cps_emit_after_await(arena, elf_ctx, ctx, ta) != 0)
            return -1;
        }
      }
    } else if (item_kind == 2) {
      if (idx >= 0 && idx < ast_ast_block_num_expr_stmts(arena, block_ref)) {
        int32_t expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
        if (expr_ref != 0) {
          int32_t stmt_ko = pipeline_expr_kind_ord_at(arena, expr_ref);
          /**
           * 赋值类：仅 kill 左值 VAR 槽（7.3 线性活跃性）；plain ASSIGN(28) 可保留 INDEX 址 cache。
           * 其它语句可能 clobber rbx/rax，清空全部 binop/INDEX 缓存。
           */
          if (glue_expr_kind_is_assign_like_ord(stmt_ko)) {
            glue_binop_kill_assign_lhs_slots_elf_c(arena, ctx, expr_ref);
            if (stmt_ko != 28)
              glue_index_assign_addr_cache_clear();
          } else {
            glue_index_assign_addr_cache_clear();
            glue_binop_var_slot_cache_clear();
          }
          if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, expr_ref, ctx, ta) != 0) {
            if (link_abi_getenv("XLANG_ASM_DEBUG")) {
              uint8_t fnb[128];
              int32_t flen = 0;
              if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
                pipeline_asm_module_func_name_copy64(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index,
                                                     fnb);
                flen = pipeline_asm_module_func_name_len_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
              }
              fprintf(stderr,
                      "xlang: block expr_stmt emit fail func=%.*s fi=%d block_ref=%d ex_i=%d expr_ref=%d kind=%d\n",
                      (int)flen, (char *)fnb, (int)g_pipeline_asm_emit_func_index, (int)block_ref, (int)idx,
                      (int)expr_ref, (int)pipeline_expr_kind_ord_at(arena, expr_ref));
            }
            return -1;
          }
          glue_block_live_fwd_apply_top_stmt(arena, ctx, block_ref, slot_base, nconst, nlet, i);
        }
      }
    } else if (item_kind == 3) {
      glue_index_assign_addr_cache_clear();
      if (idx >= 0 && idx < ast_ast_block_num_loops(arena, block_ref)) {
        glue_live_fwd_copy(&glue_live_snap_before_if, &glue_block_live_fwd);
        if (backend_emit_while_loop_elf_sync(arena, elf_ctx, block_ref, idx, ctx, ta) != 0)
          return -1;
      }
    } else if (item_kind == 4) {
      glue_index_assign_addr_cache_clear();
      if (idx >= 0 && idx < ast_ast_block_num_for_loops(arena, block_ref)) {
        glue_live_fwd_copy(&glue_live_snap_before_if, &glue_block_live_fwd);
        if (backend_emit_for_loop_elf_sync(arena, elf_ctx, block_ref, idx, ctx, ta) != 0)
          return -1;
      }
    } else if (item_kind == 5) {
      glue_index_assign_addr_cache_clear();
      if (idx >= 0 && idx < ast_ast_block_num_if_stmts(arena, block_ref)) {
        glue_live_fwd_copy(&glue_live_snap_before_if, &glue_block_live_fwd);
        if (pipeline_asm_emit_block_if_stmt_elf(arena, elf_ctx, block_ref, idx, ctx, ta, i) != 0)
          return -1;
      }
    } else if (item_kind == 6) {
      /**
       * M-3 / MEM-C1：region / with_arena（parser stmt_order kind=6）。
       * with_arena(cap>0)：栈上 Arena64 init → 块体 → deinit；块内 default_alloc 内联为 scope bump。
       */
      glue_index_assign_addr_cache_clear();
      if (idx >= 0 && idx < ast_ast_block_num_regions(arena, block_ref)) {
        int32_t reg_body = ast_ast_block_region_body_ref(arena, block_ref, idx);
        int32_t wa_cap = pipeline_block_region_with_arena_cap_ref(arena, block_ref, idx);
        if (reg_body > 0) {
          int32_t wa_off = 0;
          glue_live_fwd_copy(&glue_live_snap_before_if, &glue_block_live_fwd);
          backend_ensure_block_local_slots(ctx, arena, reg_body);
          /** 块内 let 须先于 wa 槽分配（func 入口 fill 已含 region 子块；此处仅 ensure sidecar）。 */
          if (wa_cap > 0) {
            wa_off = glue_wa_scope_alloc_off_c(ctx);
            if (glue_emit_with_arena_init_elf(arena, elf_ctx, ctx, wa_off, wa_cap, ta) != 0)
              return -1;
            glue_wa_scope_push_c(wa_off);
          }
          glue_asm_ctx_set_scope_block((uint8_t *)ctx, reg_body);
          if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, reg_body, ctx, ta) != 0)
            return -1;
          if (wa_cap > 0) {
            if (glue_emit_with_arena_deinit_elf(elf_ctx, wa_off, ta) != 0)
              return -1;
            glue_wa_scope_pop_c();
          }
        }
      }
    } else if (item_kind == 7) {
      /**
       * wave387 Cap residual pure: bare `goto T;` / `L:` / `L: return e;` freestanding+default asm.
       * Root: wave379 closed host-C kind=7 only; pipeline_asm_emit_block_body_sync_elf skipped
       * kind=7 → product -backend asm (default) fell through to first return (goto_ec=0/1).
       * G.7: single labeled pool + backend_enc_jmp_arch / backend_enc_label_arch (same face as
       * if/while break/continue); labeled return emits operand then jmp tail_join.
       * PLATFORM: SHARED freestanding emit · LINUX+MACOS x86_64|arm64 via arch helpers.
       */
      glue_index_assign_addr_cache_clear();
      glue_binop_var_slot_cache_clear();
      if (idx >= 0 && idx < pipeline_block_num_labeled_stmts(arena, block_ref)) {
        int32_t is_g = pipeline_block_labeled_is_goto(arena, block_ref, idx);
        if (is_g != 0) {
          /* wave586 Cap residual: goto target scratch 128 (content ≤127; *copy32 payload 128). */
          uint8_t gt_buf[128];
          int32_t gt_len;
          pipeline_block_labeled_goto_target_copy32(arena, block_ref, idx, gt_buf);
          gt_len = pipeline_block_labeled_goto_target_len(arena, block_ref, idx);
          if (gt_len > 0 && gt_len <= 127) {
            if (backend_enc_jmp_arch(elf_ctx, gt_buf, gt_len, ta) != 0)
              return -1;
          }
        } else {
          /* wave586 Cap residual: label scratch 128 (content ≤127; *copy32 payload 128). */
          uint8_t lb_buf[128];
          int32_t lb_len;
          int32_t ret_ref_lab;
          pipeline_block_labeled_label_copy32(arena, block_ref, idx, lb_buf);
          lb_len = pipeline_block_labeled_label_len(arena, block_ref, idx);
          if (lb_len > 0 && lb_len <= 127) {
            if (backend_enc_label_arch(elf_ctx, lb_buf, lb_len, 0, ta) != 0)
              return -1;
          }
          ret_ref_lab = pipeline_block_labeled_return_expr_ref(arena, block_ref, idx);
          if (ret_ref_lab > 0) {
            pipeline_glue_AsmFuncCtxLayout *ly_lab = pipeline_asm_ctx_layout(ctx);
            glue_index_assign_addr_cache_clear();
            if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, ret_ref_lab, ctx, ta) != 0)
              return -1;
            if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
              int32_t rty_lab = pipeline_module_func_return_type_at(g_pipeline_asm_emit_module,
                                                                   g_pipeline_asm_emit_func_index);
              int32_t sty_lab = glue_float_promote_src_ty_ref_c(arena, ret_ref_lab);
              if (glue_maybe_promote_f32_to_f64_rax_elf_c(arena, elf_ctx, rty_lab, sty_lab, ta) != 0)
                return -1;
            }
            if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0)
              return -1;
            if (!ly_lab || ly_lab->tail_join_label_len <= 0)
              return -1;
            if (backend_enc_jmp_arch(elf_ctx, ly_lab->tail_join_label, ly_lab->tail_join_label_len, ta) != 0)
              return -1;
          }
        }
      }
    }
  }
    }
  }
  /** 7.3：在 final_expr 修剪前快照子块出口活跃集（含 cfg 体内 if/while 汇合结果）。 */
  glue_live_fwd_clear(&glue_block_live_sub_exit_snap);
  if (glue_block_live_fwd_active)
    glue_live_fwd_copy(&glue_block_live_sub_exit_snap, &glue_block_live_fwd);
  else if (!glue_block_stmt_order_has_cfg(arena, block_ref))
    glue_block_compute_live_end_linear(arena, ctx, block_ref, &glue_block_live_sub_exit_snap);
  if (glue_block_live_fwd_active) {
    struct ast_Block *blk_live = pipeline_arena_block_ptr(arena, block_ref);
    glue_block_emit_stmt_i = nso;
    glue_live_fwd_clear(&glue_block_live_fwd);
    if (blk_live && blk_live->final_expr_ref > 0)
      glue_live_fwd_collect_expr_uses(arena, ctx, blk_live->final_expr_ref, &glue_block_live_fwd);
    glue_binop_cache_intersect_live_fwd();
  }
  if (glue_emit_block_final_expr_elf(arena, elf_ctx, block_ref, ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: block final_expr emit fail block_ref=%d nlet=%d nso=%d\n", (int)block_ref,
              (int)ast_ast_block_num_lets(arena, block_ref), (int)ast_ast_block_num_stmt_order(arena, block_ref));
    return -1;
  }
  glue_asm73_cfg_coloring_active = saved_cfg_color_active;
  glue_block_live_fwd_active = 0;
  glue_block_live_cfg_parent = saved_cfg_live_parent;
  (void)glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta);
  return 0;
}

/**
 * backend.x emit_block_body_elf 入口：转发 C 同步块体发射（避免 X while 在自举 asm 下只跑一轮）。
 */
int32_t backend_emit_block_body_sync_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                         int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
  /** 供 FIELD_ACCESS layout 查表；与 backend.x ctx.module_ref / dep_pipe 对齐。 */
  if (ly && ly->module_ref)
    g_pipeline_asm_emit_module = ly->module_ref;
  if (ly && ly->dep_pipe)
    g_pipeline_asm_emit_dep_pipe = (struct ast_PipelineDepCtx *)ly->dep_pipe;
  return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
}

/** backend.x：读 Block.final_expr_ref（勿 ast_arena_block_get 按值拷贝）。 */
int32_t pipeline_asm_block_final_expr_ref_at(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *blk = pipeline_arena_block_ptr(a, br);
  return blk ? blk->final_expr_ref : 0;
}

/** backend.x：读 Block.num_stmt_order（与 ast_ast_block_num_stmt_order 一致）。 */
int32_t pipeline_asm_block_num_stmt_order_at(struct ast_ASTArena *a, int32_t br) {
  return ast_ast_block_num_stmt_order(a, br);
}

/** stmt_order 已含 EXPR_RETURN 时勿再 emit final_expr（避免 return 1+2 后重复 emit 占位 LIT 1）。 */
int32_t pipeline_asm_block_stmt_order_has_return(struct ast_ASTArena *a, int32_t br) {
  return glue_block_stmt_order_has_return(a, br);
}

/**
 * Synchronize block-body tail: if the block has a final_expr_ref (e.g.
 * `return offset;`) and stmt_order does not contain RETURN, emit the
 * trailing expression here.
 *
 * Why: parser stmt_order may omit an explicit EXPR_RETURN when the block
 * ends with a bare expression; this emit path ensures the value-producing
 * expr is emitted exactly once. Caller: pipeline_asm_emit_block_body_sync_elf
 * (same file, same TU #include from pipeline_glue.c at line 4533).
 *
 * Invariant: block_ref > 0 && blk->final_expr_ref > 0 && no RETURN in
 * stmt_order. Emits expr via pipeline_asm_emit_expr_elf_rec then optionally
 * jmp tail_join_label when this block *is* the function body.
 *
 * Asm/Perf: index scratch spills cleanup preserves rbx address cache for
 * EXPR_INDEX symmetric reuse in the final return (7.3). tail_join jmp is
 * gated by function-body identity (not a second loop-only special case)
 * to avoid freestanding one-iteration regression (wave653 root).
 *
 * PLATFORM: SHARED freestanding · LINUX x86_64 gold · MACOS arm64 co-path.
 */
static int glue_emit_block_final_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  struct ast_Block *blk;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return 0;
  blk = pipeline_arena_block_ptr(arena, block_ref);
  if (!blk || blk->final_expr_ref == 0)
    return 0;
  if (glue_block_stmt_order_has_return(arena, block_ref))
    return 0;
  {
    pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
    if (ly && ly->module_ref)
      g_pipeline_asm_emit_module = ly->module_ref;
    if (ly && ly->dep_pipe)
      g_pipeline_asm_emit_dep_pipe = (struct ast_PipelineDepCtx *)ly->dep_pipe;
  }
  glue_asm_ctx_set_scope_block((uint8_t *)ctx, block_ref);
  /* Preserve assign rbx address cache for final return EXPR_INDEX symmetric reuse (7.3). */
  if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: final_expr scratch cleanup fail block=%d fref=%d ko=%d\n", (int)block_ref,
              (int)blk->final_expr_ref, (int)pipeline_expr_kind_ord_at(arena, blk->final_expr_ref));
    return -1;
  }
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, blk->final_expr_ref, ctx, ta) != 0) {
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: final_expr emit_expr fail block=%d fref=%d ko=%d sret=%d ret_sz=%d\n",
              (int)block_ref, (int)blk->final_expr_ref,
              (int)pipeline_expr_kind_ord_at(arena, blk->final_expr_ref),
              (int)g_pipeline_asm_func_sret_active, (int)g_pipeline_asm_func_sret_ret_sz);
    return -1;
  }
  /*
   * Implicit trailing expr (non-EXPR_RETURN): jmp function tail_join only
   * when this block *is* the function body (value falls into epilogue).
   * Nested blocks must not:
   *   - if-expr arms: done-label joins (glue_if_expr_arm_emit_depth)
   *   - while/for loop bodies: back-edge joins after body emit
   *   - if-stmt then/else / bare blocks: fall through to parent CFG
   * wave653 root: ASI omits `;` so trailing `s = s + i` is final_expr of
   * while body; old path always jmp tail_join -> freestanding one-iteration
   * (fs=1 vs host=12). G.7 single authority: function-body gate.
   * PLATFORM: SHARED freestanding · LINUX x86_64 gold · MACOS arm64 co-path.
   */
  {
    int32_t allow_tail_join = 0;
    int32_t fref_ko = pipeline_expr_kind_ord_at(arena, blk->final_expr_ref);
    if (glue_if_expr_arm_emit_depth <= 0 && fref_ko != 41) {
      if (g_pipeline_asm_emit_module && g_pipeline_asm_emit_func_index >= 0) {
        int32_t fb =
            pipeline_module_func_body_ref_at(g_pipeline_asm_emit_module, g_pipeline_asm_emit_func_index);
        if (fb > 0 && fb == block_ref)
          allow_tail_join = 1;
      } else {
        /* No module context (rare unit path): keep prior non-if-arm tail_join. */
        allow_tail_join = 1;
      }
    }
    if (allow_tail_join) {
      pipeline_glue_AsmFuncCtxLayout *ly = pipeline_asm_ctx_layout(ctx);
      if (ly->tail_join_label_len > 0 &&
          backend_enc_jmp_arch(elf_ctx, ly->tail_join_label, ly->tail_join_label_len, ta) != 0) {
        if (link_abi_getenv("XLANG_ASM_DEBUG"))
          fprintf(stderr, "xlang: final_expr tail_join jmp fail block=%d\n", (int)block_ref);
        return -1;
      }
    }
  }
  return 0;
}

/**
 * Emit empty init for fixed-size array let without init_ref (e.g.
 * `let buf: u8[64] = []` with omitted init).
 *
 * Why: when a fixed-size array let has no explicit initializer, the slot
 * must still point to a valid temp region at ctx->next_offset. This emits
 * a lea rbp + temp_off -> rax, then stores rax to the stack slot offset.
 *
 * Invariant: elf_ctx && ctx valid; stack_slot_off is the resolved slot
 * offset from backend_asm_ctx_slot_offset. temp_off = ly->next_offset
 * (caller bumps next_offset via pipeline_asm_bump_next_offset_after_let_init).
 *
 * Asm/Perf: single lea + store pair (2 instructions); no loop, no spill.
 * PLATFORM: SHARED — arch-agnostic via backend_enc_lea_rbp_to_rax_arch +
 * backend_enc_store_rax_to_rbp_arch.
 *
 * Consumers: pipeline_asm_emit_block_body_sync_elf (this file, lines 467/602)
 * + pipeline_glue.c internal (lines 6791/6872, after #include 4459 — visible
 * via forward decl at top of this file). G.7 single authority.
 */
static int32_t glue_emit_array_let_empty_init(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                              struct backend_AsmFuncCtx *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t temp_off;
  pipeline_glue_AsmFuncCtxLayout *ly;
  (void)arena;
  if (!elf_ctx || !ctx)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  temp_off = ly->next_offset;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_off, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  return 0;
}

/**
 * Reset per-func AsmFuncCtx for a new function emit pass.
 *
 * Why: the mega-emit C main loop (glue.c:8270) emits each function in
 * sequence into the same AsmFuncCtxLayout. Frame size, locals, break/
 * continue stacks, loop depth, tail-join label, and dep_pipe must be
 * zeroed between functions to prevent stale state leaking across function
 * boundaries (e.g. a break in func B jumping to func A's loop label).
 * label_counter is intentionally preserved to keep .L_N unique across the
 * whole mega emit. Equivalent to backend.x ctx_reset.
 *
 * Invariant: NULL ctx is a no-op. All frame/locals/break/continue/loop/
 * tail_join fields zeroed; module_ref set to current mod; dep_pipe
 * cleared (re-set per-func by caller if needed). asm_ctx_local_reset
 * flushes the local sidecar table.
 *
 * Asm/Perf: O(1) — field writes + one sidecar reset. Called once per
 * function in the mega emit loop (glue.c:8342).
 *
 * PLATFORM: SHARED — ctx layout is platform-independent; arch select
 * happens at backend_enc call sites, not here.
 *
 * wave1067 G.7: migrated from glue.c:8255 (body 13 LOC). Static
 * (non-extern): same-TU visibility — block_body.c #include at L3872 <
 * def L8255 < sole callsite glue.c:8342. Dependencies:
 * pipeline_glue_AsmFuncCtxLayout (struct, defined early in glue.c <
 * L3872); asm_ctx_local_reset (extern).
 */
static void pipeline_asm_ctx_reset_for_func_c(pipeline_glue_AsmFuncCtxLayout *ctx, struct ast_Module *mod) {
  if (!ctx)
    return;
  ctx->frame_size = 0;
  ctx->next_offset = 0;
  ctx->num_locals = 0;
  ctx->module_ref = mod;
  ctx->break_len = 0;
  ctx->continue_len = 0;
  ctx->loop_label_depth = 0;
  ctx->dep_pipe = NULL;
  ctx->tail_join_label_len = 0;
  asm_ctx_local_reset((uint8_t *)ctx);
}

/**
 * Check whether a block's stmt_order contains an EXPR_RETURN (any operand).
 *
 * Why: if-then branch that contains a return must NOT emit a jump to the
 * post-if statement (control flow falls through). This helper scans stmt_order
 * for kind 2 (expr_stmt) with EXPR_RETURN (kind_ord 41), and kind 7 (labeled
 * stmt) with a return-expr in the labeled pool (wave387: `L: return e;`).
 *
 * Invariant: returns 0 for NULL arena or invalid block_ref; returns 1 iff at
 * least one stmt_order entry is a return (expr_stmt kind 41 or labeled return).
 *
 * Asm/Perf: O(nso) — one pass over stmt_order. Cold path — called per
 * if-then branch in block_if_stmt.c:82 and per block tail in block_body.c
 * (lines 819/851).
 *
 * PLATFORM: SHARED — stmt_order traversal is platform-independent.
 *
 * wave1073 G.7: migrated from glue.c:3807 (body 25 LOC). Static (non-extern):
 * same-TU — block_body.c #include at L3872 < fwd decl L48 < def EOF.
 * Callsites: block_body.c:819/851 (fwd decl L48) + block_if_stmt.c:82
 * (via #include at glue.c L3875 > block_body.c L3872 — fwd decl visible).
 * Dependencies: ast_ast_block_num_stmt_order / ast_ast_block_stmt_order_kind /
 * ast_ast_block_stmt_order_idx / ast_ast_block_num_expr_stmts /
 * ast_pipeline_block_expr_stmt_ref / pipeline_expr_kind_ord_at /
 * pipeline_block_num_labeled_stmts / pipeline_block_labeled_is_goto /
 * pipeline_block_labeled_return_expr_ref (all extern).
 */
static int glue_block_stmt_order_has_return(struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nso;
  int32_t i;
  if (!arena || block_ref <= 0)
    return 0;
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (i = 0; i < nso; i++) {
    uint8_t sk = ast_ast_block_stmt_order_kind(arena, block_ref, i);
    int32_t idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
    if (sk == 2) {
      int32_t expr_ref;
      if (idx < 0 || idx >= ast_ast_block_num_expr_stmts(arena, block_ref))
        continue;
      expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
      if (expr_ref != 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 41)
        return 1;
    } else if (sk == 7) {
      /* wave387: L: return e; stores operand in labeled pool (not EXPR_RETURN expr_stmt). */
      if (idx >= 0 && idx < pipeline_block_num_labeled_stmts(arena, block_ref) &&
          pipeline_block_labeled_is_goto(arena, block_ref, idx) == 0 &&
          pipeline_block_labeled_return_expr_ref(arena, block_ref, idx) > 0)
        return 1;
    }
  }
  return 0;
}
