
/* ============================================================================
 * pipeline_asm_block_tree.c — backend asm block tree traversal + frame sizing
 *
 * wave1254 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   asm_block_tree_push_ref/children/region_children
 *   + asm_sum_block_local_slot_bytes + asm_count_block_stack_slots
 *   + asm_fixed_array_temp_bytes + asm_sum_block_array_temp_bytes
 *   + asm_sum_block_wa_temp_bytes
 *
 * GrowVec-backed DFS over function body block tree to compute total
 * const/let slot bytes, slot count, array temp bytes, and with_arena
 * temp bytes for compute_frame_size. Replaces .x recursive DFS to
 * avoid host stack overflow on large modules.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 * Depends on GrowVec + block_at (static, ast_pool.c host TU) +
 * asm_local_slot_bytes/asm_fixed_array_total_bytes_mod (pipeline_asm_slot_bytes.c).
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/** 块树遍历栈：压入待访问 block_ref（GrowVec，避免 .x 大栈数组在大模块 asm 单编时 SIGSEGV）。 */
static void asm_block_tree_push_ref(GrowVec *stack, int32_t block_ref) {
  int32_t *slot;
  if (!stack || block_ref <= 0)
    return;
  if (grow_vec_push(stack) < 0)
    return;
  slot = (int32_t *)grow_vec_at(stack, stack->len - 1);
  if (slot)
    *slot = block_ref;
}

/** 将 cur 的 while/for/if 子块压入遍历栈。 */
static void asm_block_tree_push_children(struct ast_ASTArena *arena, GrowVec *stack, int32_t cur) {
  struct ast_Block *b;
  int32_t i, ch;
  if (!arena || !stack || cur <= 0 || !(b = block_at(arena, cur)))
    return;
  for (i = 0; i < b->num_loops; i++) {
    ch = pipeline_block_while_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
  for (i = 0; i < b->num_for_loops; i++) {
    ch = pipeline_block_for_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
  for (i = 0; i < b->num_if_stmts; i++) {
    ch = pipeline_block_if_then_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
    ch = pipeline_block_if_else_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
}

/** 将 cur 的 region/with_arena 子块压入遍历栈（cfg/while/for/if 子块由 asm_block_tree_push_children 处理）。 */
static void asm_block_tree_push_region_children(struct ast_ASTArena *arena, GrowVec *stack, int32_t cur) {
  struct ast_Block *b;
  int32_t i;
  int32_t ch;
  if (!arena || !stack || cur <= 0 || !(b = block_at(arena, cur)))
    return;
  for (i = 0; i < b->num_regions; i++) {
    ch = pipeline_block_region_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
}

/**
 * 函数体块树中全部 const/let 栈槽字节总和（含嵌套 if/while/for 体）；供 compute_frame_size。
 */
int32_t asm_sum_block_local_slot_bytes(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  int32_t i;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      for (i = 0; i < b->num_consts; i++)
        total += asm_local_slot_bytes(arena, pipeline_block_const_type_ref(arena, cur, i));
      for (i = 0; i < b->num_lets; i++)
        total += asm_local_slot_bytes(arena, pipeline_block_let_type_ref(arena, cur, i));
      asm_block_tree_push_children(arena, &stack, cur);
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * 统计函数体块树中全部 const/let 槽位数（含 if-then/else、while/for 嵌套体）。
 * 供 backend.x compute_frame_size 使用；C 显式栈避免 .x DFS 栈溢出。
 */
int32_t asm_count_block_stack_slots(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      total += b->num_consts + b->num_lets;
      asm_block_tree_push_children(arena, &stack, cur);
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * 定长数组 let 在栈 temp 区占用字节（与 pipeline_glue.c glue_fixed_array_temp_bytes 一致）。
 */
static int32_t asm_fixed_array_temp_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t esz;
  int32_t bytes;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, type_ref);
  /* TYPE_ARRAY 序数为 10（与 ast.h AST_TYPE_ARRAY / ast.x TypeKind 一致）；误用 9 会当成 TYPE_PTR 导致 frame 未预留 temp。 */
  if (!t || (int32_t)t->kind != 10 || t->array_size <= 0)
    return 0;
  bytes = asm_fixed_array_total_bytes_mod(arena, type_ref, NULL);
  if (bytes > 0)
    return bytes;
  elem_ref = t->elem_type_ref;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if ((int32_t)et->kind == 2)
        esz = 1;
      else if ((int32_t)et->kind == 14)
        esz = 4;
      else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
               (int32_t)et->kind == 6)
        esz = 8;
    }
  }
  bytes = t->array_size * esz;
  return bytes > 0 ? bytes : 0;
}

/**
 * 函数体块树中全部定长数组 let 的 temp 区总字节数；供 compute_frame_size 预留栈空间。
 */
int32_t asm_sum_block_array_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      {
        int32_t li;
        for (li = 0; li < b->num_lets; li++) {
          int32_t tref = pipeline_block_let_type_ref(arena, cur, li);
          total += asm_fixed_array_temp_bytes(arena, tref);
        }
      }
      asm_block_tree_push_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * MEM-C1：函数体块树中全部 with_arena 临时 Arena64 栈字节（每 scope 24B，总和对 8 取整）。
 * 供 compute_frame_size 在 array temp 之后预留 wa 区。
 */
int32_t asm_sum_block_wa_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_INIT_CAP))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      {
        int32_t ri;
        for (ri = 0; ri < b->num_regions; ri++) {
          if (pipeline_block_region_with_arena_cap_ref(arena, cur, ri) > 0)
            total += 24;
        }
      }
      asm_block_tree_push_children(arena, &stack, cur);
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  if (total > 0 && total % 8 != 0)
    total += 8 - (total % 8);
  return total;
}
