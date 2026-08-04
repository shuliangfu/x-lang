/**
 * ast_pool_expr_sidecar.c — Expr (+ type-pos) var-len sidecar domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (contiguous former ast_pool block):
 * - domain-private statics: expr_match_arm_at / expr_struct_lit_field_at /
 *   expr_call_arg_slot / expr_method_call_arg_slot / expr_array_lit_elem_slot /
 *   expr_call_type_arg_base_cell / type_type_arg_ensure_meta
 * - pipeline_expr_* : CALL args + turbofish type-args, METHOD_CALL args,
 *   match arms (+ guard), struct_lit fields, array_lit elems
 * - pipeline_type_append_type_arg / pipeline_type_type_arg_ref_at (TYPE_NAMED
 *   type-pos sidecar; co-located with expr var-len pools)
 *
 * Later same-TU consumers (e.g. asm_wpo_collect_edges_from_expr) still call the
 * static slot helpers — include site must remain before those uses.
 *
 * Depends on same-TU: arena_sidecar_get, grow_vec_*, pipeline_arena_expr_ptr,
 * MatchArmEntry / StructLitFieldEntry / ArenaSidecar (defined earlier in
 * ast_pool.c); pipeline_type_elem_ref_at (pipeline_glue, before #include
 * ast_pool).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen/asm call these.
 * Wave: 982 · no semantic change · pin stays 77b334842.
 */

/** ---------- Expr 变长附属（call/method/match/struct_lit/array_lit）动态池 ---------- */

static MatchArmEntry *expr_match_arm_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t arm_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arm_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->match_arm_base + arm_idx;
  if (create) {
    while (sc->expr_match_arms.len <= abs) {
      if (grow_vec_push(&sc->expr_match_arms) < 0)
        return NULL;
    }
  } else if (arm_idx >= ex->match_num_arms || abs >= sc->expr_match_arms.len) {
    return NULL;
  }
  return (MatchArmEntry *)grow_vec_at(&sc->expr_match_arms, abs);
}

static StructLitFieldEntry *expr_struct_lit_field_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t field_idx,
                                                     int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || field_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->struct_lit_field_base + field_idx;
  if (create) {
    while (sc->expr_struct_lit_fields.len <= abs) {
      if (grow_vec_push(&sc->expr_struct_lit_fields) < 0)
        return NULL;
    }
  } else if (field_idx >= ex->struct_lit_num_fields || abs >= sc->expr_struct_lit_fields.len) {
    return NULL;
  }
  return (StructLitFieldEntry *)grow_vec_at(&sc->expr_struct_lit_fields, abs);
}

static int32_t *expr_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arg_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->call_arg_base + arg_idx;
  if (create) {
    while (sc->expr_call_arg_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_call_arg_refs) < 0)
        return NULL;
    }
  } else if (arg_idx >= ex->call_num_args || abs >= sc->expr_call_arg_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_call_arg_refs, abs);
}

static int32_t *expr_method_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arg_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->method_call_arg_base + arg_idx;
  if (create) {
    while (sc->expr_method_call_arg_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_method_call_arg_refs) < 0)
        return NULL;
    }
  } else if (arg_idx >= ex->method_call_num_args || abs >= sc->expr_method_call_arg_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_method_call_arg_refs, abs);
}

static int32_t *expr_array_lit_elem_slot(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || elem_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->array_lit_elem_base + elem_idx;
  if (create) {
    while (sc->expr_array_lit_elem_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_array_lit_elem_refs) < 0)
        return NULL;
    }
  } else if (elem_idx >= ex->array_lit_num_elems || abs >= sc->expr_array_lit_elem_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_array_lit_elem_refs, abs);
}

/**
 * CALL 节点刚分配后调用：立即固定 call_arg_base，避免嵌套实参解析时内层 CALL 与外层未写入槽位重叠。
 */
void pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  ArenaSidecar *sc;
  if (!a || expr_ref <= 0)
    return;
  sc = arena_sidecar_get(a, 1);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return;
  ex->call_arg_base = (int32_t)sc->expr_call_arg_refs.len;
}

/**
 * 解析/append 前：grow 侧车池至 call_arg_base + call_num_args。
 * 权威调用序见 parser_asm_primary_slice：先 parse 完全部实参，再统一 append
 * （避免嵌套 CALL 与外层 call_arg 槽交错覆盖）。
 */
int32_t pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  ArenaSidecar *sc;
  int32_t abs;
  if (!a || expr_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return -1;
  /* 兼容未调用 on_call_created 的旧路径：首个实参前 lazy 固定 base */
  if (ex->call_num_args == 0)
    pipeline_expr_on_call_created(a, expr_ref);
  abs = ex->call_arg_base + ex->call_num_args;
  while (sc->expr_call_arg_refs.len <= (size_t)abs) {
    if (grow_vec_push(&sc->expr_call_arg_refs) < 0)
      return -1;
  }
  return 0;
}

int32_t pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (pipeline_expr_prepare_call_arg_slot(a, expr_ref) < 0)
    return -1;
  slot = expr_call_arg_slot(a, expr_ref, ex->call_num_args, 1);
  if (!slot)
    return -1;
  *slot = arg_ref;
  ex->call_num_args++;
  return ex->call_num_args - 1;
}

int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_call_arg_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->call_num_args : 0;
}

int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  return ex->call_num_type_args;
}

/**
 * wave452: ensure expr_call_type_arg_bases has a slot for expr_ref; return pointer to base cell.
 * Unset base is -1. PLATFORM: SHARED — G.7 with append/get type_arg APIs.
 */
static int32_t *expr_call_type_arg_base_cell(struct ast_ASTArena *a, int32_t expr_ref, int create) {
  ArenaSidecar *sc;
  int32_t *cell;
  if (!a || expr_ref <= 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create && (size_t)expr_ref >= sc->expr_call_type_arg_bases.len)
    return NULL;
  while ((size_t)expr_ref >= sc->expr_call_type_arg_bases.len) {
    int32_t idx = grow_vec_push(&sc->expr_call_type_arg_bases);
    if (idx < 0)
      return NULL;
    cell = (int32_t *)grow_vec_at(&sc->expr_call_type_arg_bases, idx);
    if (!cell)
      return NULL;
    *cell = -1;
  }
  return (int32_t *)grow_vec_at(&sc->expr_call_type_arg_bases, expr_ref);
}

/**
 * wave452: append one turbofish type-arg type_ref to CALL expr.
 * First append fixes base in sidecar; increments call_num_type_args.
 * Call after CALL node is created; may reset count if base was unset and count
 * was only a skip-count from legacy path — caller should set count via appends
 * or set call_num_type_args then fill slots. Here: append owns the count when
 * base was -1 (resets count to 0 then increments).
 *
 * @return 0 on success, -1 on failure.
 * PLATFORM: SHARED
 */
int32_t pipeline_expr_append_call_type_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t *base_cell;
  int32_t base;
  int32_t abs;
  int32_t *slot;
  if (!a || expr_ref <= 0 || type_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return -1;
  base_cell = expr_call_type_arg_base_cell(a, expr_ref, 1);
  if (!base_cell)
    return -1;
  if (*base_cell < 0) {
    *base_cell = (int32_t)sc->expr_call_type_arg_refs.len;
    ex->call_num_type_args = 0;
  }
  base = *base_cell;
  abs = base + ex->call_num_type_args;
  while (sc->expr_call_type_arg_refs.len <= (size_t)abs) {
    if (grow_vec_push(&sc->expr_call_type_arg_refs) < 0)
      return -1;
  }
  slot = (int32_t *)grow_vec_at(&sc->expr_call_type_arg_refs, abs);
  if (!slot)
    return -1;
  *slot = type_ref;
  ex->call_num_type_args = ex->call_num_type_args + 1;
  return 0;
}

/**
 * wave452: type_ref of CALL turbofish type arg at index, or 0 if missing.
 * PLATFORM: SHARED
 */
int32_t pipeline_expr_call_type_arg_ref_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t *base_cell;
  int32_t base;
  int32_t abs;
  int32_t *slot;
  if (!a || expr_ref <= 0 || idx < 0)
    return 0;
  sc = arena_sidecar_get(a, 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return 0;
  if (idx >= ex->call_num_type_args)
    return 0;
  base_cell = expr_call_type_arg_base_cell(a, expr_ref, 0);
  if (!base_cell || *base_cell < 0)
    return 0;
  base = *base_cell;
  abs = base + idx;
  if (abs < 0 || (size_t)abs >= sc->expr_call_type_arg_refs.len)
    return 0;
  slot = (int32_t *)grow_vec_at(&sc->expr_call_type_arg_refs, abs);
  return slot ? *slot : 0;
}

/**
 * wave467: ensure type_type_arg_bases/counts have a slot for type_ref.
 * PLATFORM: SHARED.
 */
static int32_t type_type_arg_ensure_meta(struct ast_ASTArena *a, int32_t type_ref, int create,
                                        int32_t **out_base, int32_t **out_count) {
  ArenaSidecar *sc;
  int32_t *bcell;
  int32_t *ccell;
  if (!a || type_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return -1;
  if (!create && ((size_t)type_ref >= sc->type_type_arg_bases.len
                  || (size_t)type_ref >= sc->type_type_arg_counts.len))
    return -1;
  while ((size_t)type_ref >= sc->type_type_arg_bases.len) {
    int32_t idx = grow_vec_push(&sc->type_type_arg_bases);
    if (idx < 0)
      return -1;
    bcell = (int32_t *)grow_vec_at(&sc->type_type_arg_bases, idx);
    if (!bcell)
      return -1;
    *bcell = -1;
  }
  while ((size_t)type_ref >= sc->type_type_arg_counts.len) {
    int32_t idx = grow_vec_push(&sc->type_type_arg_counts);
    if (idx < 0)
      return -1;
    ccell = (int32_t *)grow_vec_at(&sc->type_type_arg_counts, idx);
    if (!ccell)
      return -1;
    *ccell = 0;
  }
  if (out_base)
    *out_base = (int32_t *)grow_vec_at(&sc->type_type_arg_bases, type_ref);
  if (out_count)
    *out_count = (int32_t *)grow_vec_at(&sc->type_type_arg_counts, type_ref);
  return 0;
}

/**
 * wave467: append one type-position type arg to TYPE_NAMED (`Name<T,U>`).
 * First append fixes base; caller sets Type.array_size = n and elem_type_ref = first.
 * @return 0 success, -1 failure. PLATFORM: SHARED
 */
int32_t pipeline_type_append_type_arg(struct ast_ASTArena *a, int32_t type_ref, int32_t arg_ref) {
  ArenaSidecar *sc;
  int32_t *base_cell;
  int32_t *count_cell;
  int32_t base;
  int32_t n;
  int32_t abs;
  int32_t *slot;
  if (!a || type_ref <= 0 || arg_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  if (!sc)
    return -1;
  if (type_type_arg_ensure_meta(a, type_ref, 1, &base_cell, &count_cell) != 0)
    return -1;
  if (!base_cell || !count_cell)
    return -1;
  if (*base_cell < 0) {
    *base_cell = (int32_t)sc->type_type_arg_refs.len;
    *count_cell = 0;
  }
  base = *base_cell;
  n = *count_cell;
  abs = base + n;
  while (sc->type_type_arg_refs.len <= (size_t)abs) {
    int32_t pi = grow_vec_push(&sc->type_type_arg_refs);
    if (pi < 0)
      return -1;
    slot = (int32_t *)grow_vec_at(&sc->type_type_arg_refs, pi);
    if (slot)
      *slot = 0;
  }
  slot = (int32_t *)grow_vec_at(&sc->type_type_arg_refs, abs);
  if (!slot)
    return -1;
  *slot = arg_ref;
  *count_cell = n + 1;
  return 0;
}

/**
 * wave467: type_ref of TYPE_NAMED type-pos arg at index, or 0 if missing.
 * Slot0 falls back to Type.elem_type_ref when sidecar empty (wave466).
 * PLATFORM: SHARED
 */
int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx) {
  ArenaSidecar *sc;
  int32_t *base_cell;
  int32_t *count_cell;
  int32_t base;
  int32_t abs;
  int32_t *slot;
  if (!a || type_ref <= 0 || idx < 0)
    return 0;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return 0;
  if (type_type_arg_ensure_meta(a, type_ref, 0, &base_cell, &count_cell) == 0
      && base_cell && count_cell && *base_cell >= 0 && idx < *count_cell) {
    base = *base_cell;
    abs = base + idx;
    if (abs >= 0 && (size_t)abs < sc->type_type_arg_refs.len) {
      slot = (int32_t *)grow_vec_at(&sc->type_type_arg_refs, abs);
      if (slot && *slot > 0)
        return *slot;
    }
  }
  /* wave466 single-arg: only slot0 lives in elem_type_ref. */
  if (idx == 0)
    return pipeline_type_elem_ref_at(a, type_ref);
  return 0;
}

int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->method_call_num_args == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->method_call_arg_base = sc->expr_method_call_arg_refs.len;
  }
  slot = expr_method_call_arg_slot(a, expr_ref, ex->method_call_num_args, 1);
  if (!slot)
    return -1;
  *slot = arg_ref;
  ex->method_call_num_args++;
  return ex->method_call_num_args - 1;
}

int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_method_call_arg_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                       int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                       int32_t variant_index) {
  struct ast_Expr *ex;
  MatchArmEntry *arm;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->match_num_arms == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->match_arm_base = sc->expr_match_arms.len;
  }
  arm = expr_match_arm_at(a, expr_ref, ex->match_num_arms, 1);
  if (!arm)
    return -1;
  arm->result_ref = result_ref;
  arm->is_wildcard = is_wildcard;
  arm->lit_val = lit_val;
  arm->is_enum_variant = is_enum_variant;
  arm->variant_index = variant_index;
  arm->guard_ref = 0; /* wave700: set via pipeline_expr_match_arm_set_guard_ref */
  ex->match_num_arms++;
  return ex->match_num_arms - 1;
}

int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->match_num_arms : 0;
}

int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->result_ref : 0;
}

int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->is_wildcard : 0;
}

int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->lit_val : 0;
}

int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->is_enum_variant : 0;
}

int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->variant_index : 0;
}

void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->is_wildcard = v;
}

void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->lit_val = v;
}

void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t is_var,
                                              int32_t variant_index) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm) {
    arm->is_enum_variant = is_var;
    arm->variant_index = variant_index;
  }
}

/**
 * wave700: set optional match-arm guard expr (`pat if cond =>`).
 * @param guard_ref — EXPR ref for cond, or 0 to clear
 * PLATFORM: SHARED
 */
void pipeline_expr_match_arm_set_guard_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t guard_ref) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->guard_ref = guard_ref;
}

/**
 * wave700: get optional match-arm guard expr ref (0 = no guard).
 * PLATFORM: SHARED
 */
int32_t pipeline_expr_match_arm_guard_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->guard_ref : 0;
}

int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                              int32_t name_len, int32_t init_ref) {
  struct ast_Expr *ex;
  StructLitFieldEntry *fe;
  int32_t n;
  if (!a || expr_ref <= 0 || !name_bytes || name_len <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->struct_lit_num_fields == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->struct_lit_field_base = sc->expr_struct_lit_fields.len;
  }
  fe = expr_struct_lit_field_at(a, expr_ref, ex->struct_lit_num_fields, 1);
  if (!fe)
    return -1;
  n = name_len > 127 ? 127 : name_len;
  memset(fe->name, 0, sizeof(fe->name));
  memcpy(fe->name, name_bytes, (size_t)n);
  fe->name_len = n;
  fe->init_ref = init_ref;
  ex->struct_lit_num_fields++;
  return ex->struct_lit_num_fields - 1;
}

int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  StructLitFieldEntry *fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  return fe ? fe->name_len : 0;
}

void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena *a, int32_t expr_ref, int32_t j,
                                              uint8_t *out64) {
  StructLitFieldEntry *fe;
  if (!out64) {
    return;
  }
  fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  if (!fe) {
    memset(out64, 0, 128);
    return;
  }
  memcpy(out64, fe->name, 128); /* wave577 Cap */
}

int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  StructLitFieldEntry *fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  return fe ? fe->init_ref : 0;
}

int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->array_lit_num_elems == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->array_lit_elem_base = sc->expr_array_lit_elem_refs.len;
  }
  slot = expr_array_lit_elem_slot(a, expr_ref, ex->array_lit_num_elems, 1);
  if (!slot)
    return -1;
  *slot = elem_ref;
  ex->array_lit_num_elems++;
  return ex->array_lit_num_elems - 1;
}

int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_array_lit_elem_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->array_lit_num_elems : 0;
}
