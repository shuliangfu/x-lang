/*
 * w1041: strong first-wins overlay for glue_asm_sum_block_call_spill_bytes.
 *
 * Root: product egg still budgets (n+1)*32 per CALL/METHOD_CALL even after
 * w1040 shrunk single-GP spill stride to 8 (and cold/thin twins to *16).
 * Tip-compiled emit_call trampolines stayed at sub $0x188 because the egg
 * walk never shipped into the link (HARD BAN tip reinject of w157 thin —
 * Darwin BRANCH26). This host-cc sidecar mirrors the cold walk with
 * (n+1)*8 so frame estimate tracks the live spill cursor.
 *
 * Link ahead of runtime_pipeline_abi.o / pabi_weak. On Windows weaken the
 * egg T in pabi_weak so PE first-wins this strong T. Darwin/Ubuntu egg
 * already expose weak W — strong overlay wins without weaken.
 *
 * PLATFORM: SHARED host-cc sidecar · LINUX gold · MACOS co-path · WINDOWS.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_num_args_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_arg_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_method_call_base_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_num_args_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(void *arena, int32_t expr_ref, int32_t i);
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
extern int32_t pipeline_expr_struct_lit_init_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_if_cond_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_block_ref_at(void *arena, int32_t expr_ref);

extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_const_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_let_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_expr_stmts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_expr_stmt_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_final_expr_ref(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(void *arena, int32_t block_ref);
extern int32_t ast_pipeline_block_if_cond_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_if_then_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_pipeline_block_if_else_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_while_cond_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_while_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_for_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_for_init_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_for_cond_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_for_step_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_for_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t ast_ast_block_num_regions(void *arena, int32_t block_ref);
extern int32_t pipeline_block_region_body_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_num_labeled_stmts(void *arena, int32_t block_ref);
extern int32_t pipeline_block_labeled_is_goto(void *arena, int32_t block_ref, int32_t li);
extern int32_t pipeline_block_labeled_return_expr_ref(void *arena, int32_t block_ref, int32_t li);
extern int32_t ast_ast_block_num_stmt_order(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_stmt_order_kind(void *arena, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(void *arena, int32_t block_ref, int32_t si);

static int32_t g_w157_spill_total = 0;
static int32_t g_w157_spill_visits = 0;

static void w157_walk_block_rec(void *arena, int32_t cur, int32_t depth);

/**
 * Recursive sum of permanent call-arg spill bytes under one expression.
 * CALL(48)/METHOD_CALL(49): budget (n+1)*8 (w1041; egg leftover was *32).
 * PLATFORM: SHARED — twin of runtime_pipeline_abi.x / w157_sum_thin.
 */
static void w157_sum_expr_call_spill_bytes(void *arena, int32_t expr_ref) {
  int32_t ko, n, i, arg_ref, op, as_op;
  if (!arena || expr_ref <= 0) {
    return;
  }
  g_w157_spill_visits++;
  if (g_w157_spill_visits > 32768) {
    return;
  }
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 48) { /* EXPR_CALL */
    n = pipeline_expr_call_num_args_at(arena, expr_ref);
    if (n < 0) {
      n = 0;
    }
    if (n > 64) {
      n = 64;
    }
    {
      int32_t need = 0;
      for (i = 0; i < n; i++) {
        arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
        w157_sum_expr_call_spill_bytes(arena, arg_ref);
        /* w1042: EXPR_VAR args reuse stack homes (call_dispatch elide) —
         * do not reserve a fresh spill slot for them. */
        if (arg_ref > 0 && pipeline_expr_kind_ord_at(arena, arg_ref) != 3) {
          need = need + 1;
        }
      }
      /* One temp slot when any non-VAR arg / empty call still needs scratch. */
      if (need > 0 || n == 0) {
        need = need + 1;
      }
      g_w157_spill_total += need * 8;
    }
    return;
  }
  if (ko == 49) { /* EXPR_METHOD_CALL */
    arg_ref = pipeline_expr_method_call_base_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    n = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    if (n < 0) {
      n = 0;
    }
    if (n > 64) {
      n = 64;
    }
    {
      int32_t need = 0;
      /* Receiver: count unless it is EXPR_VAR (home reuse). */
      if (arg_ref > 0 && pipeline_expr_kind_ord_at(arena, arg_ref) != 3) {
        need = need + 1;
      }
      for (i = 0; i < n; i++) {
        arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
        w157_sum_expr_call_spill_bytes(arena, arg_ref);
        if (arg_ref > 0 && pipeline_expr_kind_ord_at(arena, arg_ref) != 3) {
          need = need + 1;
        }
      }
      if (need > 0) {
        need = need + 1;
      }
      g_w157_spill_total += need * 8;
    }
    return;
  }
  /*
   * P12g: EXPR_IF(25)/EXPR_BLOCK(26) share ordinals with binop — try if/block
   * accessors first so else-if chains keep their arms in the spill estimate.
   * PLATFORM: SHARED.
   */
  if (ko == 25) {
    arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
    if (arg_ref > 0) {
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
      op = pipeline_expr_if_then_ref_at(arena, expr_ref);
      w157_sum_expr_call_spill_bytes(arena, op);
      op = pipeline_expr_if_else_ref_at(arena, expr_ref);
      w157_sum_expr_call_spill_bytes(arena, op);
      return;
    }
  }
  if (ko == 26) {
    int32_t wb26 = pipeline_expr_block_ref_at(arena, expr_ref);
    if (wb26 > 0) {
      w157_walk_block_rec(arena, wb26, 40);
      return;
    }
  }
  if ((ko >= 4 && ko <= 21) || ko == 25 || ko == 26 || (ko >= 28 && ko <= 38)) {
    arg_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    op = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 22 || ko == 23 || ko == 24 || ko == 41 || ko == 51) {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  as_op = pipeline_expr_as_operand_ref_at(arena, expr_ref);
  if (ko == 54 || as_op > 0) {
    op = as_op;
    if (op <= 0) {
      op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    }
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 47) { /* INDEX */
    arg_ref = pipeline_expr_index_base_ref(arena, expr_ref);
    op = pipeline_expr_index_index_ref(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 44) { /* FIELD_ACCESS */
    op = pipeline_expr_field_access_base_ref(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    return;
  }
  if (ko == 46) { /* ARRAY_LIT */
    n = pipeline_expr_array_lit_num_elems_at(arena, expr_ref);
    if (n > 1024) {
      n = 1024;
    }
    for (i = 0; i < n; i++) {
      arg_ref = pipeline_expr_array_lit_elem_ref(arena, expr_ref, i);
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
    }
    return;
  }
  if (ko == 45) { /* STRUCT_LIT */
    n = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    if (n > 64) {
      n = 64;
    }
    for (i = 0; i < n; i++) {
      arg_ref = pipeline_expr_struct_lit_init_ref(arena, expr_ref, i);
      w157_sum_expr_call_spill_bytes(arena, arg_ref);
    }
    return;
  }
  arg_ref = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  if (arg_ref > 0) {
    w157_sum_expr_call_spill_bytes(arena, arg_ref);
    op = pipeline_expr_if_then_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
    op = pipeline_expr_if_else_ref_at(arena, expr_ref);
    w157_sum_expr_call_spill_bytes(arena, op);
  }
}

/**
 * Depth-capped block walk shared by the public driver and EXPR_BLOCK unwrap.
 * stmt_order is the emitter's sequencing authority when present.
 * PLATFORM: SHARED.
 */
static void w157_walk_block_rec(void *arena, int32_t cur, int32_t depth) {
  int32_t i, n, ch, er, fin, nso;
  if (!arena || cur <= 0 || depth <= 0) {
    return;
  }
  if (g_w157_spill_visits > 32768) {
    return;
  }
  nso = ast_ast_block_num_stmt_order(arena, cur);
  if (nso > 0) {
    for (i = 0; i < nso; i++) {
      int32_t sok = (int32_t)ast_ast_block_stmt_order_kind(arena, cur, i);
      int32_t soi = ast_ast_block_stmt_order_idx(arena, cur, i);
      if (soi < 0) {
        continue;
      }
      if (sok == 2) {
        er = ast_pipeline_block_expr_stmt_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
      } else if (sok == 1) {
        er = ast_pipeline_block_let_init_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
      } else if (sok == 0) {
        er = ast_pipeline_block_const_init_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
      } else if (sok == 5) {
        er = ast_pipeline_block_if_cond_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        ch = ast_pipeline_block_if_then_body_ref(arena, cur, soi);
        if (ch > 0) {
          w157_walk_block_rec(arena, ch, depth - 1);
        }
        ch = ast_pipeline_block_if_else_body_ref(arena, cur, soi);
        if (ch > 0) {
          w157_walk_block_rec(arena, ch, depth - 1);
        }
      } else if (sok == 3) {
        er = ast_ast_block_while_cond_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        ch = pipeline_block_while_body_ref(arena, cur, soi);
        if (ch > 0) {
          w157_walk_block_rec(arena, ch, depth - 1);
        }
      } else if (sok == 4) {
        er = ast_ast_block_for_init_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        er = ast_ast_block_for_cond_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        er = ast_ast_block_for_step_ref(arena, cur, soi);
        w157_sum_expr_call_spill_bytes(arena, er);
        ch = pipeline_block_for_body_ref(arena, cur, soi);
        if (ch > 0) {
          w157_walk_block_rec(arena, ch, depth - 1);
        }
      } else if (sok == 6) {
        ch = pipeline_block_region_body_ref(arena, cur, soi);
        if (ch > 0) {
          w157_walk_block_rec(arena, ch, depth - 1);
        }
      } else if (sok == 7) {
        if (pipeline_block_labeled_is_goto(arena, cur, soi) == 0) {
          er = pipeline_block_labeled_return_expr_ref(arena, cur, soi);
          if (er > 0) {
            w157_sum_expr_call_spill_bytes(arena, er);
          }
        }
      }
    }
    fin = ast_ast_block_final_expr_ref(arena, cur);
    if (fin > 0) {
      w157_sum_expr_call_spill_bytes(arena, fin);
    }
    return;
  }
  n = ast_ast_block_num_consts(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_const_init_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
  }
  n = ast_ast_block_num_lets(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_let_init_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
  }
  n = ast_ast_block_num_expr_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_expr_stmt_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
  }
  fin = ast_ast_block_final_expr_ref(arena, cur);
  if (fin > 0) {
    w157_sum_expr_call_spill_bytes(arena, fin);
  }
  n = ast_ast_block_num_if_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_pipeline_block_if_cond_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
    if (ch > 0) {
      w157_walk_block_rec(arena, ch, depth - 1);
    }
    ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
    if (ch > 0) {
      w157_walk_block_rec(arena, ch, depth - 1);
    }
  }
  n = ast_ast_block_num_loops(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_ast_block_while_cond_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    ch = pipeline_block_while_body_ref(arena, cur, i);
    if (ch > 0) {
      w157_walk_block_rec(arena, ch, depth - 1);
    }
  }
  n = ast_ast_block_num_for_loops(arena, cur);
  for (i = 0; i < n; i++) {
    er = ast_ast_block_for_init_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    er = ast_ast_block_for_cond_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    er = ast_ast_block_for_step_ref(arena, cur, i);
    w157_sum_expr_call_spill_bytes(arena, er);
    ch = pipeline_block_for_body_ref(arena, cur, i);
    if (ch > 0) {
      w157_walk_block_rec(arena, ch, depth - 1);
    }
  }
  n = ast_ast_block_num_regions(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_region_body_ref(arena, cur, i);
    if (ch > 0) {
      w157_walk_block_rec(arena, ch, depth - 1);
    }
  }
  n = pipeline_block_num_labeled_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    if (pipeline_block_labeled_is_goto(arena, cur, i) == 0) {
      er = pipeline_block_labeled_return_expr_ref(arena, cur, i);
      if (er > 0) {
        w157_sum_expr_call_spill_bytes(arena, er);
      }
    }
  }
}

/**
 * Sum call-arg spill bytes for one function body block (w1041 *8 stride).
 * PLATFORM: SHARED — mirrors runtime_pipeline_abi.x authority.
 */
int32_t glue_asm_sum_block_call_spill_bytes(void *arena, int32_t block_ref) {
  if (!arena || block_ref <= 0) {
    return 0;
  }
  g_w157_spill_total = 0;
  g_w157_spill_visits = 0;
  w157_walk_block_rec(arena, block_ref, 256);
  return g_w157_spill_total;
}
