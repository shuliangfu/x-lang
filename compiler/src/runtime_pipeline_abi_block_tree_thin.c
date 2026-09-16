/*
 * Thin pure: wave269 block_tree Cap domain leave.
 * G.7: bodies match mega runtime_pipeline_abi.x wave269 leave /
 * seeds/runtime_pipeline_abi.from_x.c cold twins (direct C map, not Lxml).
 *
 * Independent C thin (Darwin additive-leaf rule). File-local walk stack.
 * wave268 sizing already productized via slot_bytes_thin.x + NL-04 seed;
 * this leaf owns block-tree walk faces.
 *
 * Faces:
 *   asm_sum_block_local_slot_bytes / asm_count_block_stack_slots
 *   asm_sum_block_array_temp_bytes / asm_sum_block_wa_temp_bytes
 *   asm_ctx_fill_locals_block_tree
 *
 * Fixed i32[256] walk stack (matches pure; no GrowVec).
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding frame layout Cap leave.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern int32_t asm_local_slot_bytes(void *arena, int32_t type_ref);
extern int32_t asm_fixed_array_total_bytes_mod(void *arena, int32_t type_ref, void *mod);
extern void asm_ctx_ensure_block_locals(uint8_t *ctx, void *arena, int32_t block_ref, int32_t *inout_next_offset,
                                        int32_t *inout_num_locals);
extern int32_t pipeline_arena_num_types(void *arena);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t ref);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_for_loops(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_regions(void *arena, int32_t block_ref);
extern int32_t pipeline_block_while_body_ref(void *arena, int32_t block_ref, int32_t wi);
extern int32_t pipeline_block_for_body_ref(void *arena, int32_t block_ref, int32_t fi);
extern int32_t ast_pipeline_block_if_then_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t ast_pipeline_block_if_else_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t pipeline_block_region_body_ref(void *arena, int32_t block_ref, int32_t ri);
extern int32_t pipeline_block_region_with_arena_cap_ref(void *arena, int32_t block_ref, int32_t ri);
extern int32_t pipeline_block_const_type_ref(void *arena, int32_t block_ref, int32_t i);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t i);

static int32_t g_bt_stack[256];

static int32_t bt_push(int32_t sp, int32_t block_ref) {
  if (block_ref <= 0 || sp < 0 || sp >= 256)
    return sp;
  g_bt_stack[sp] = block_ref;
  return sp + 1;
}

static int32_t bt_push_children(void *arena, int32_t sp, int32_t cur) {
  int32_t i, n, ch;
  if (!arena || cur <= 0)
    return sp;
  n = ast_ast_block_num_loops(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_while_body_ref(arena, cur, i);
    sp = bt_push(sp, ch);
  }
  n = ast_ast_block_num_for_loops(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_for_body_ref(arena, cur, i);
    sp = bt_push(sp, ch);
  }
  n = ast_ast_block_num_if_stmts(arena, cur);
  for (i = 0; i < n; i++) {
    ch = ast_pipeline_block_if_then_body_ref(arena, cur, i);
    sp = bt_push(sp, ch);
    ch = ast_pipeline_block_if_else_body_ref(arena, cur, i);
    sp = bt_push(sp, ch);
  }
  return sp;
}

static int32_t bt_push_region_children(void *arena, int32_t sp, int32_t cur) {
  int32_t i, n, ch;
  if (!arena || cur <= 0)
    return sp;
  n = ast_ast_block_num_regions(arena, cur);
  for (i = 0; i < n; i++) {
    ch = pipeline_block_region_body_ref(arena, cur, i);
    sp = bt_push(sp, ch);
  }
  return sp;
}

static int32_t bt_fixed_array_temp_bytes(void *arena, int32_t type_ref) {
  int32_t nt, ko, asz, elem_ref, esz, bytes, ek;
  if (!arena || type_ref <= 0)
    return 0;
  nt = pipeline_arena_num_types(arena);
  if (type_ref > nt)
    return 0;
  ko = pipeline_type_kind_ord_at(arena, type_ref);
  asz = pipeline_type_array_size_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  if (ko != 10 || asz <= 0)
    return 0;
  bytes = asm_fixed_array_total_bytes_mod(arena, type_ref, NULL);
  if (bytes > 0)
    return bytes;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= nt) {
    ek = pipeline_type_kind_ord_at(arena, elem_ref);
    if (ek == 2)
      esz = 1;
    else if (ek == 14)
      esz = 4;
    else if (ek == 8 || ek == 4 || ek == 5 || ek == 6)
      esz = 8;
  }
  bytes = asz * esz;
  return bytes > 0 ? bytes : 0;
}

int32_t asm_sum_block_local_slot_bytes(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, i, n, tref;
  if (!arena || block_ref <= 0)
    return 0;
  sp = bt_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_bt_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    n = ast_ast_block_num_consts(arena, cur);
    for (i = 0; i < n; i++) {
      tref = pipeline_block_const_type_ref(arena, cur, i);
      total += asm_local_slot_bytes(arena, tref);
    }
    n = ast_ast_block_num_lets(arena, cur);
    for (i = 0; i < n; i++) {
      tref = pipeline_block_let_type_ref(arena, cur, i);
      total += asm_local_slot_bytes(arena, tref);
    }
    sp = bt_push_children(arena, sp, cur);
    sp = bt_push_region_children(arena, sp, cur);
  }
  return total;
}

int32_t asm_count_block_stack_slots(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, nc, nl;
  if (!arena || block_ref <= 0)
    return 0;
  sp = bt_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_bt_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    nc = ast_ast_block_num_consts(arena, cur);
    nl = ast_ast_block_num_lets(arena, cur);
    total += nc + nl;
    sp = bt_push_children(arena, sp, cur);
    sp = bt_push_region_children(arena, sp, cur);
  }
  return total;
}

int32_t asm_sum_block_array_temp_bytes(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, i, n, tref;
  if (!arena || block_ref <= 0)
    return 0;
  sp = bt_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_bt_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    n = ast_ast_block_num_lets(arena, cur);
    for (i = 0; i < n; i++) {
      tref = pipeline_block_let_type_ref(arena, cur, i);
      total += bt_fixed_array_temp_bytes(arena, tref);
    }
    sp = bt_push_children(arena, sp, cur);
  }
  return total;
}

int32_t asm_sum_block_wa_temp_bytes(void *arena, int32_t block_ref) {
  int32_t total = 0, sp = 0, visits = 0, cur, i, n, cap_ref;
  if (!arena || block_ref <= 0)
    return 0;
  sp = bt_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_bt_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    n = ast_ast_block_num_regions(arena, cur);
    for (i = 0; i < n; i++) {
      cap_ref = pipeline_block_region_with_arena_cap_ref(arena, cur, i);
      if (cap_ref > 0)
        total += 24;
    }
    sp = bt_push_children(arena, sp, cur);
    sp = bt_push_region_children(arena, sp, cur);
  }
  if (total > 0 && total % 8 != 0)
    total += 8 - (total % 8);
  return total;
}

void asm_ctx_fill_locals_block_tree(uint8_t *ctx, void *arena, int32_t block_ref, int32_t *inout_next_offset,
                                    int32_t *inout_num_locals) {
  int32_t sp = 0, visits = 0, cur;
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  sp = bt_push(0, block_ref);
  while (sp > 0) {
    sp--;
    cur = g_bt_stack[sp];
    if (cur <= 0)
      continue;
    visits++;
    if (visits > 8192)
      break;
    asm_ctx_ensure_block_locals(ctx, arena, cur, inout_next_offset, inout_num_locals);
    sp = bt_push_children(arena, sp, cur);
    sp = bt_push_region_children(arena, sp, cur);
  }
}
