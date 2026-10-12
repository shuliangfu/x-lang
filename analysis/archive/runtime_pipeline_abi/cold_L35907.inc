/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */

/* Cap residual callees for cold twin (declared elsewhere in product link). */
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_num_elems_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_array_lit_elem_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_struct_lit_num_fields(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_struct_lit_init_ref(void *arena, int32_t expr_ref, int32_t j);
extern int32_t ast_pipeline_block_let_init_ref(void *arena, int32_t block_ref, int32_t li);
extern int32_t backend_asm_ctx_slot_offset(void *ctx, int32_t slot_idx);
extern int32_t ast_ast_block_num_stmt_order(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_stmt_order_kind(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_num_expr_stmts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_expr_stmt_ref(void *arena, int32_t block_ref, int32_t ei);
extern int32_t pipeline_block_num_labeled_stmts(void *arena, int32_t block_ref);
extern int32_t pipeline_block_labeled_is_goto(void *arena, int32_t block_ref, int32_t li);
extern int32_t pipeline_block_labeled_return_expr_ref(void *arena, int32_t block_ref, int32_t li);
extern int32_t ast_ast_block_final_expr_ref(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_stmt_order(void *arena, int32_t block_ref);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t pipeline_expr_block_ref_at(void *arena, int32_t expr_ref);
extern void backend_ensure_block_local_slots(void *ctx, void *arena, int32_t block_ref);
extern int32_t glue_if_expr_arm_emit_depth_get(void);
extern void glue_if_expr_arm_emit_depth_set(int32_t v);
extern int32_t pipeline_asm_emit_expr_elf_rec(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern void glue_block_body_bind_module_dep_from_ctx(void *ctx);
extern void glue_asm_ctx_set_scope_block(void *ctx, int32_t block_ref);
extern int32_t glue_index_scratch_spills_cleanup_all_elf_c(void *elf_ctx, int32_t ta);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_module_func_body_ref_at(void *mod, int32_t fi);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, void *label, int32_t label_len, int32_t ta);
extern int32_t glue_live_fwd_n_get(const void *live);
extern int32_t glue_live_fwd_off_at(const void *live, int32_t i);
extern void glue_live_fwd_clear_u8(void *live);
extern void glue_live_fwd_add_u8(void *live, int32_t off);

/* Minimal GlueBlockLiveFwd overlay for cold defer (offs[32]+n). */
typedef struct {
  int32_t offs[32];
  int32_t n;
} wave153_LiveFwd;

/* Thin cold twins for non-body faces (body_sync cold falls through residual link
 * when product hybrid uses pure .o; cold pin path needs public symbols). */

void glue_live_fwd_collect_expr_uses_for_defer(void *arena, void *ctx, int32_t expr_ref, void *gen) {
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
  if (ko == 3) {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
    if (off >= 0)
      glue_live_fwd_add_u8(gen, off);
    return;
  }
  if (ko >= 4 && ko <= 21) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, left_ref, gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, right_ref, gen);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (op_ref > 0) {
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, op_ref, gen);
    return;
  }
  if (ko == 47) {
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_index_base_ref(arena, expr_ref), gen);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_index_index_ref(arena, expr_ref), gen);
    return;
  }
  if (ko == 44) {
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_field_access_base_ref(arena, expr_ref), gen);
    return;
  }
  if (ko == 46) {
    n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    for (i = 0; i < n; i++)
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_array_lit_elem_ref(arena, expr_ref, i), gen);
    return;
  }
  if (ko == 45) {
    n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    for (i = 0; i < n; i++)
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, pipeline_expr_struct_lit_init_ref(arena, expr_ref, i), gen);
    return;
  }
}

void glue_block_defer_lets_transitive(void *arena, void *ctx, int32_t block_ref, int32_t slot_base, int32_t nconst,
                                      int32_t nlet, uint8_t *deferred) {
  int32_t li, changed, guard, ui, uj, init_ref, off;
  wave153_LiveFwd uses;
  if (!arena || !ctx || !deferred || nlet <= 0)
    return;
  for (guard = 0; guard < nlet + 2; guard++) {
    changed = 0;
    for (li = 0; li < nlet; li++) {
      if (deferred[li])
        continue;
      init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, li);
      if (init_ref <= 0)
        continue;
      glue_live_fwd_clear_u8(&uses);
      glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, init_ref, &uses);
      for (ui = 0; ui < glue_live_fwd_n_get(&uses); ui++) {
        off = glue_live_fwd_off_at(&uses, ui);
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

/* Stage12.0.5: nested INDEX/CALL/METHOD in let init must stay pass1 (G.7 twin of
 * glue_expr_tree_has_call_index_c). Top-level-only defer missed `f() - 4` and
 * pass0-hoisted emit_code_len before append_bytes (x86_enc_jcc_rel32 / option-si). */
int32_t glue_expr_tree_has_call_index_c(void *arena, int32_t expr_ref) {
  int32_t ko, i, n, left_ref, right_ref, op_ref;
  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 47 || ko == 48 || ko == 49)
    return 1;
  if (ko >= 4 && ko <= 21) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0)
      return 1;
    return glue_expr_tree_has_call_index_c(arena, right_ref);
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return glue_expr_tree_has_call_index_c(arena, op_ref);
  }
  op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (op_ref > 0)
    return glue_expr_tree_has_call_index_c(arena, op_ref);
  if (ko == 44) {
    left_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    return glue_expr_tree_has_call_index_c(arena, left_ref);
  }
  if (ko == 46) {
    n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    for (i = 0; i < n; i++) {
      left_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0)
        return 1;
    }
    return 0;
  }
  return 0;
}

/* 9.6.0: true when expr tree reads a VAR that does not resolve to a block
 * local (module global / extern). EXPR_VAR = 3; resolution through the
 * wave188 authority glue_asm_local_var_stack_off_scoped (param homes and
 * enclosing-scope locals count as local). Callers must only consult this
 * when glue_expr_tree_has_call_index_c already returned 0 (INDEX/CALL/
 * METHOD_CALL nodes are claimed there first). A let whose init reads a
 * global must stay in pass 1 source order — pass 0 would read the global
 * before prior statements mutate it (probe pd: non-main
 * `g=g+1; g=g+1; let c=g; return c` returned the pre-statement value).
 * Previously this only worked in the hoist target because hoisting turned
 * globals into block locals. G.7 twin of runtime_pipeline_abi.x walker.
 * PLATFORM: SHARED freestanding emit. */
int32_t glue_expr_tree_has_nonlocal_var_c(void *arena, void *ctx, int32_t expr_ref) {
  int32_t ko, i, n, left_ref, right_ref, op_ref;
  if (!arena || expr_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3) {
    if (glue_asm_local_var_stack_off_scoped(arena, ctx, expr_ref) < 0)
      return 1;
    return 0;
  }
  if (ko >= 4 && ko <= 21) {
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0)
      return 1;
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, right_ref);
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41) {
    op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, op_ref);
  }
  op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (op_ref > 0)
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, op_ref);
  if (ko == 44) {
    left_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
    return glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref);
  }
  if (ko == 46) {
    n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    for (i = 0; i < n; i++) {
      left_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0)
        return 1;
    }
    return 0;
  }
  if (ko == 45) {
    n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    for (i = 0; i < n; i++) {
      left_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      if (glue_expr_tree_has_nonlocal_var_c(arena, ctx, left_ref) != 0)
        return 1;
    }
    return 0;
  }
  return 0;
}
  if (ko == 45) {
    n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    for (i = 0; i < n; i++) {
      left_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      if (glue_expr_tree_has_call_index_c(arena, left_ref) != 0)
        return 1;
    }
    return 0;
  }
  return 0;
}

void glue_block_compute_pass1_deferred_lets(void *arena, void *ctx, int32_t block_ref, int32_t slot_base, int32_t nconst,
                                            int32_t nlet, uint8_t *deferred) {
  int32_t li, nso, si, j, init_ref, ko, let_si, has_call;
  uint8_t sk;
  wave153_LiveFwd uses;
  if (!arena || !ctx || !deferred || nlet <= 0)
    return;
  for (li = 0; li < nlet; li++) {
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, li);
    ko = init_ref > 0 ? pipeline_expr_kind_ord_at(arena, init_ref) : 0;
    has_call = init_ref > 0 ? glue_expr_tree_has_call_index_c(arena, init_ref) : 0;
    deferred[li] = (uint8_t)(has_call != 0 || ko == 47 || ko == 48 || ko == 49 ? 1 : 0);
    /* 9.6.0: init reading a non-local VAR (module global) must stay in
     * pass 1 source order — pass 0 would read the global before prior
     * statements mutate it. Over-deferral is harmless; under-deferral is
     * the pd miscompile. G.7 twin of runtime_pipeline_abi.x guard. */
    if (!deferred[li] && init_ref > 0 &&
        glue_expr_tree_has_nonlocal_var_c(arena, ctx, init_ref) != 0)
      deferred[li] = 1;
  }
  glue_block_defer_lets_transitive(arena, ctx, block_ref, slot_base, nconst, nlet, deferred);
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (li = 0; li < nlet; li++) {
    if (deferred[li])
      continue;
    init_ref = ast_pipeline_block_let_init_ref(arena, block_ref, li);
    if (init_ref <= 0)
      continue;
    glue_live_fwd_clear_u8(&uses);
    glue_live_fwd_collect_expr_uses_for_defer(arena, ctx, init_ref, &uses);
    if (glue_live_fwd_n_get(&uses) <= 0)
      continue;
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
      sk = (uint8_t)ast_ast_block_stmt_order_kind(arena, block_ref, j);
      if (sk == 2 || sk == 3 || sk == 4 || sk == 5 || sk == 6 || sk == 7) {
        deferred[li] = 1;
        break;
      }
    }
  }
  glue_block_defer_lets_transitive(arena, ctx, block_ref, slot_base, nconst, nlet, deferred);
}

int glue_block_stmt_order_has_return(void *arena, int32_t block_ref) {
  int32_t nso, i, idx, expr_ref;
  uint8_t sk;
  if (!arena || block_ref <= 0)
    return 0;
  nso = ast_ast_block_num_stmt_order(arena, block_ref);
  for (i = 0; i < nso; i++) {
    sk = (uint8_t)ast_ast_block_stmt_order_kind(arena, block_ref, i);
    idx = ast_ast_block_stmt_order_idx(arena, block_ref, i);
    if (sk == 2) {
      if (idx < 0 || idx >= ast_ast_block_num_expr_stmts(arena, block_ref))
        continue;
      expr_ref = ast_pipeline_block_expr_stmt_ref(arena, block_ref, idx);
      if (expr_ref != 0 && pipeline_expr_kind_ord_at(arena, expr_ref) == 41)
        return 1;
    } else if (sk == 7) {
      if (idx >= 0 && idx < pipeline_block_num_labeled_stmts(arena, block_ref) &&
          pipeline_block_labeled_is_goto(arena, block_ref, idx) == 0 &&
          pipeline_block_labeled_return_expr_ref(arena, block_ref, idx) > 0)
        return 1;
    }
  }
  return 0;
}

int32_t pipeline_asm_block_final_expr_ref_at(void *a, int32_t br) {
  return ast_ast_block_final_expr_ref(a, br);
}

extern void *pipeline_arena_block_ptr(void *a, int32_t br);

/**
 * Block stmt_order count for mega emit_block gate.
 * PLATFORM: WINDOWS PE — do not call ast_ast_block_num_stmt_order (duplicate
 * block_get-by-value twin + strict_glue stub collide under first-wins). Read
 * W277_Block.num_stmt_order @0x54 via arena block pointer (G.7 with w277 path).
 * PLATFORM: SHARED pointer layout (same offset on POSIX).
 */
int32_t pipeline_asm_block_num_stmt_order_at(void *a, int32_t br) {
  void *b;
  if (!a || br <= 0)
    return 0;
  b = pipeline_arena_block_ptr(a, br);
  if (!b)
    return 0;
  return *(int32_t *)((uint8_t *)b + 0x54);
}

int32_t pipeline_asm_block_stmt_order_has_return(void *a, int32_t br) {
  return glue_block_stmt_order_has_return(a, br);
}

int32_t glue_emit_array_let_empty_init(void *arena, void *elf_ctx, void *ctx, int32_t ta, int32_t stack_slot_off) {
  int32_t temp_off;
  int32_t *ly_next;
  uint8_t *ly;
  (void)arena;
  if (!elf_ctx || !ctx)
    return -1;
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  /* next_offset@4 LP64 */
  ly_next = (int32_t *)(ly + 4);
  temp_off = *ly_next;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, temp_off, ta) != 0)
    return -1;
  if (backend_enc_store_rax_to_rbp_arch(elf_ctx, stack_slot_off, ta) != 0)
    return -1;
  return 0;
}

/* Forward: body_sync defined below (or residual host provides when hybrid). */
int32_t pipeline_asm_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta);

int32_t glue_emit_block_final_expr_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta) {
  int32_t fref;
  int32_t allow_tail_join;
  int32_t fref_ko;
  int32_t depth;
  void *mod;
  int32_t fi;
  int32_t fb;
  uint8_t *ly;
  int32_t tj_len;
  if (!arena || !elf_ctx || !ctx || block_ref <= 0)
    return 0;
  fref = pipeline_asm_block_final_expr_ref_at(arena, block_ref);
  if (fref == 0)
    return 0;
  if (glue_block_stmt_order_has_return(arena, block_ref))
    return 0;
  glue_block_body_bind_module_dep_from_ctx(ctx);
  glue_asm_ctx_set_scope_block(ctx, block_ref);
  if (glue_index_scratch_spills_cleanup_all_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, fref, ctx, ta) != 0)
    return -1;
  allow_tail_join = 0;
  fref_ko = pipeline_expr_kind_ord_at(arena, fref);
  depth = glue_if_expr_arm_emit_depth_get();
  if (depth <= 0 && fref_ko != 41) {
    mod = pipeline_asm_emit_module_ref_c();
    fi = pipeline_asm_emit_func_index_c();
    if (mod && fi >= 0) {
      fb = pipeline_module_func_body_ref_at(mod, fi);
      if (fb > 0 && fb == block_ref)
        allow_tail_join = 1;
    } else {
      allow_tail_join = 1;
    }
  }
  if (allow_tail_join) {
    ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
    if (ly) {
      tj_len = *(int32_t *)(ly + 1520);
      if (tj_len > 0 && backend_enc_jmp_arch(elf_ctx, ly + 1392, tj_len, ta) != 0)
        return -1;
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_expr_if_arm_elf_c(void *arena, void *elf_ctx, int32_t arm_ref, void *ctx, int32_t ta) {
  int32_t ko, br, sv_locs, sv_next, r, depth;
  uint8_t *ly;
  if (arm_ref <= 0)
    return 0;
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  ko = pipeline_expr_kind_ord_at(arena, arm_ref);
  if (ko == 26) {
    br = pipeline_expr_block_ref_at(arena, arm_ref);
    if (br <= 0)
      return -1;
    sv_locs = *(int32_t *)(ly + 8);
    sv_next = *(int32_t *)(ly + 4);
    backend_ensure_block_local_slots(ctx, arena, br);
    depth = glue_if_expr_arm_emit_depth_get();
    glue_if_expr_arm_emit_depth_set(depth + 1);
    r = pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, br, ctx, ta);
    depth = glue_if_expr_arm_emit_depth_get();
    glue_if_expr_arm_emit_depth_set(depth - 1);
    *(int32_t *)(ly + 8) = sv_locs;
    *(int32_t *)(ly + 4) = sv_next;
    return r;
  }
  return pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, arm_ref, ctx, ta);
}

int32_t backend_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta) {
  glue_block_body_bind_module_dep_from_ctx(ctx);
  return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
}

/*
 * Cold body_sync: product hybrid links pure .o (FROM_X set). Cold pin path
 * without pure may leave body_sync UNDEF unless residual host-cc provides it.
 * For cold completeness provide a minimal stub that returns -1 (no freestanding
 * emit in pure-less cold pin for complex blocks). Prefer full port only if cold
 * product matrix requires it; L2 hybrid uses pure.
 */
int32_t pipeline_asm_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta) {
  (void)arena;
  (void)elf_ctx;
  (void)block_ref;
  (void)ctx;
  (void)ta;
  /* Cold without pure: not a freestanding product path after wave153. */
  return -1;
}

