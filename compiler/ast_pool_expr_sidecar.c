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

/* ============================================================
 * wave152: Cap residual expr pool accessors relocated from
 * pipeline_asm_emit_expr_rec.c L514–EOF (emit faces pure-owned leave).
 * Same-TU via ast_pool.c → pipeline_glue. No semantic change.
 * Uses glue_arena_expr_at_ref / pipeline_arena_expr_ptr (arena before sidecar).
 * PLATFORM: SHARED host residual pool faces.
 * ============================================================ */
/* ============================================================
 * wave1160 G.7: expr accessor public wrappers (10 fns) +
 * ast_pipeline_* forwarding wrappers (9 fns) migrated from
 * pipeline_glue.c L3564-3625 / L10412-10449. Colocated with expr
 * ELF recursion dispatcher — these are the field readers consumed
 * by emit_expr_elf_rec / emit_expr_elf_fast above. Fwd decls at
 * glue.c L1532-1578 (before #include L2210).
 */

/**
 * Read EXPR_AS operand expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_AS arm to load the cast source.
 */
int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->as_operand_ref : 0;
}

/**
 * Read EXPR_AS target type pool ref. Returns 0 for invalid ref.
 * Used by typeck return path and emit EXPR_AS arm to determine
 * the cast target type.
 */
int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->as_target_type_ref : 0;
}

/**
 * Read EXPR_ENUM_VARIANT / FIELD_ACCESS enum variant tag.
 * Returns 0 for invalid ref. Used by emit_expr_elf_rec to emit
 * the variant ordinal as immediate.
 */
int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->enum_variant_tag : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY condition expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_cond_ref : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY then-branch expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_then_ref : 0;
}

/**
 * Read EXPR_IF/EXPR_TERNARY else-branch expr ref.
 * Returns 0 for invalid ref.
 */
int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->if_else_ref : 0;
}

/**
 * Read EXPR_BLOCK inner block ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_BLOCK arm and typeck tail-expr scan.
 */
int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->block_ref : 0;
}

/**
 * Read EXPR_MATCH matched-value expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_MATCH arm and typeck check_expr_match.
 */
int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->match_matched_ref : 0;
}

/**
 * Read CTFE const-folded valid flag. Returns 0 for invalid ref.
 * Used by emit_expr_elf_fast to short-circuit folded constants.
 */
int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? (int32_t)ex->const_folded_valid : 0;
}

/**
 * Read CTFE const-folded integer value. Returns 0 for invalid ref.
 * Used by emit_expr_elf_fast to emit folded constant as immediate.
 */
int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->const_folded_val : 0;
}

/*
 * ast_pipeline_* forwarding wrappers: codegen may prepend ast_ prefix
 * when importing the ast module; each delegates to the pipeline_expr_*
 * bare symbol defined above.
 */

int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_as_operand_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_enum_variant_tag_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_cond_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_then_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_if_else_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_block_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_matched_ref_at(a, expr_ref);
}

int32_t ast_pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_valid_at(a, expr_ref);
}

int32_t ast_pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_const_folded_val_at(a, expr_ref);
}

/* ============================================================
 * wave1161 G.7: index/field_access/line/col accessor public wrappers
 * (10 fns) + ast_pipeline_* forwarding wrappers (3 fns) migrated from
 * pipeline_glue.c L3816-3950 / L10382-10392. Colocated with expr ELF
 * recursion dispatcher — these field readers/writers are consumed by
 * emit_expr_elf_rec / emit_expr_elf_fast and typeck index/field checks.
 * Fwd decls at glue.c L1554-1565 (before #include L2210).
 */

/**
 * Read EXPR_INDEX base expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_INDEX arm to load the indexed value.
 */
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_base_ref : 0;
}

/**
 * Read EXPR_INDEX index expr ref. Returns 0 for invalid ref.
 * Used by emit_expr_elf_rec EXPR_INDEX arm to load the index operand.
 */
int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_index_ref : 0;
}

/**
 * Read resolved_type_ref from arena-pooled Expr. Returns 0 for invalid
 * ref. Used throughout typeck and asm emit to determine the inferred
 * type of an expression.
 */
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->resolved_type_ref : 0;
}

/**
 * Write resolved_type_ref on arena-pooled Expr. Called by typeck.x
 * EMIT_HEAVY emit path to stamp the inferred type without Expr
 * by-value get/set (which tears the struct on the asm backend).
 * Includes optional XLANG_TRACE_EXPR_SET debug tracing.
 */
void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref) {
  struct ast_Expr *ex;
  const char *trace_expr;
  int32_t trace_ref;
  int32_t old_ref;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  old_ref = ex->resolved_type_ref;
  ex->resolved_type_ref = type_ref;
  trace_expr = link_abi_getenv("XLANG_TRACE_EXPR_SET");
  if (!trace_expr || !*trace_expr)
    return;
  trace_ref = atoi(trace_expr);
  if (trace_ref != expr_ref)
    return;
  fprintf(stderr, "note: expr set debug: expr=%d kind=%d block=%d old_ty=%d new_ty=%d\n", (int)expr_ref,
          (int)ex->kind, (int)ex->block_ref, (int)old_ref, (int)type_ref);
}

/**
 * Write index_base_is_slice flag on EXPR_INDEX. Called by typeck
 * index bounds check to mark slice-typed bases for asm emit.
 * Avoids ast_arena_expr_set (EMIT_HEAVY asm struct tear).
 */
void pipeline_expr_set_index_base_is_slice(struct ast_ASTArena *a, int32_t expr_ref, int32_t v) {
  struct ast_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->index_base_is_slice = v;
}

/**
 * Write index_proven_in_bounds flag on EXPR_INDEX. Called by typeck
 * after static bounds proof to skip runtime bounds check in asm emit.
 */
void pipeline_expr_set_index_proven_in_bounds(struct ast_ASTArena *a, int32_t expr_ref, int32_t v) {
  struct ast_Expr *ex;

  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return;
  ex->index_proven_in_bounds = v;
}

/**
 * Read index_base_is_slice on EXPR_INDEX (wave147 pure Cap residual getter).
 * G.7: pool face twin of pipeline_expr_set_index_base_is_slice.
 * @return 0 if invalid ref / unset; else flag value
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_index_base_is_slice_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  return ex->index_base_is_slice;
}

/**
 * Read index_proven_in_bounds on EXPR_INDEX (wave147 pure Cap residual getter).
 * G.7: pool face twin of pipeline_expr_set_index_proven_in_bounds.
 * @return 0 if invalid ref / unset; else flag value
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_index_proven_in_bounds_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return 0;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex)
    return 0;
  return ex->index_proven_in_bounds;
}

/**
 * Read source line number from Expr. Returns 0 for invalid ref.
 * Used by break/continue diagnostics and typeck error reporting.
 */
int32_t pipeline_expr_line_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->line : 0;
}

/**
 * Read source column number from Expr. Returns 0 for invalid ref.
 * Used by break/continue diagnostics and typeck error reporting.
 */
int32_t pipeline_expr_col_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->col : 0;
}

/**
 * Read FIELD_ACCESS byte offset. Returns 0 for invalid ref.
 * Used by asm emit to compute the field address (base + offset).
 */
int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_offset : 0;
}

/**
 * Write FIELD_ACCESS byte offset. Called by typeck field layout
 * resolver. Avoids ast_arena_expr_set (EMIT_HEAVY asm struct tear).
 */
void pipeline_expr_set_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref, int32_t offset) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (ex)
    ex->field_access_offset = offset;
}

/**
 * Read FIELD_ACCESS SoA column stride (DOD-S1). Returns 0 for AoS
 * static offset. Used by asm emit for SoA struct field access.
 */
int32_t pipeline_expr_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_soa_stride : 0;
}

/* ast_pipeline_* forwarding wrappers for index/field_access accessors. */

int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_index_base_ref(a, expr_ref);
}

int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_index_index_ref(a, expr_ref);
}

int32_t ast_pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_field_access_offset(a, expr_ref);
}

/* ============================================================
 * wave1162 G.7: lit/var/field_access/unary/binop accessor public
 * wrappers (13 fns) migrated from pipeline_glue.c L3244-3422.
 * Colocated with expr ELF recursion dispatcher — these are the
 * field readers consumed by emit_expr_elf_rec / emit_expr_elf_fast
 * and typeck expr check paths. Fwd decls at glue.c L1530-1571.
 */

/**
 * Read EXPR_LIT/EXPR_BOOL_LIT int_val as i32. Returns 0 for invalid
 * ref. Backend asm must not use ast_arena_expr_get (large module
 * stack overflow risk).
 */
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? (int32_t)ex->int_val : 0;
}

/**
 * Read EXPR_LIT full i64 value (avoids int32 truncation for
 * INT64_MIN and large constants like P0-4).
 */
int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->int_val : 0;
}

/**
 * Read EXPR_NEG/EXPR_BITNOT/EXPR_LOGNOT unary operand ref.
 * Returns 0 for invalid ref. typeck check_block_impl block-tail
 * `return;` detection uses this glue (not ast_arena_expr_get
 * which fails on bootstrap asm FIELD_ACCESS).
 */
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->unary_operand_ref : 0;
}

/**
 * Copy FIELD_ACCESS field name into out64 (u8[128], max 127 bytes
 * + zero-fill). wave577 Cap: output buffer is u8[128].
 */
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 128);
    return;
  }
  nlen = ex->field_access_field_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  memset(out64, 0, 128);
  if (nlen > 0)
    memcpy(out64, ex->field_access_field_name, (size_t)nlen);
}

/**
 * Read FIELD_ACCESS field name length. Returns 0 for non-FIELD_ACCESS
 * or invalid ref.
 */
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_field_len;
}

/**
 * Read FIELD_ACCESS base_ref. Returns 0 for non-FIELD_ACCESS or
 * invalid ref.
 */
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_base_ref;
}

/**
 * Copy EXPR_VAR variable name into out64 (u8[128], max 127 bytes
 * + zero-fill).
 */
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  int32_t nlen;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 128);
    return;
  }
  nlen = ex->var_name_len;
  if (nlen < 0)
    nlen = 0;
  if (nlen > 127)
    nlen = 127;
  memset(out64, 0, 128);
  if (nlen > 0)
    memcpy(out64, ex->var_name, (size_t)nlen);
}

/**
 * Read STRING_LIT (kind 59) byte length. Returns 0 for non-string-lit
 * or invalid ref.
 */
int32_t pipeline_expr_var_name_len_for_string_lit_c(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || (int32_t)ex->kind != 59)
    return 0;
  return ex->var_name_len;
}

/**
 * Read EXPR_VAR name length. Returns 0 for non-VAR or invalid ref.
 */
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_VAR)
    return 0;
  return ex->var_name_len;
}

/**
 * wave670 Cap residual: keyword `null` is EXPR_LIT int_val=0 tagged
 * var_name="null"/len=4. G.7 single null face.
 * PLATFORM: SHARED.
 */
int32_t pipeline_expr_is_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || (int32_t)ex->kind != 0 /* EXPR_LIT */)
    return 0;
  if (ex->int_val != 0 || ex->var_name_len != 4)
    return 0;
  if (ex->var_name[0] == (uint8_t)'n' && ex->var_name[1] == (uint8_t)'u' &&
      ex->var_name[2] == (uint8_t)'l' && ex->var_name[3] == (uint8_t)'l')
    return 1;
  return 0;
}

/**
 * Tag EXPR_LIT 0 as keyword null on the live arena expr.
 * Use after parser_asm primary set — avoids parser_asm_ast_expr ↔
 * ast_Expr memcpy layout drift (mac vs gcc) losing var_name tag.
 * PLATFORM: SHARED.
 */
void pipeline_expr_tag_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  int32_t zi;
  if (!ex)
    return;
  ex->kind = ast_ExprKind_EXPR_LIT;
  ex->int_val = 0;
  ex->var_name[0] = (uint8_t)'n';
  ex->var_name[1] = (uint8_t)'u';
  ex->var_name[2] = (uint8_t)'l';
  ex->var_name[3] = (uint8_t)'l';
  ex->var_name_len = 4;
  for (zi = 4; zi < 128; zi++)
    ex->var_name[zi] = 0;
}

/** Read expr.binop_left_ref. Returns 0 for invalid ref. */
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->binop_left_ref : 0;
}

/** Read expr.binop_right_ref. Returns 0 for invalid ref. */
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->binop_right_ref : 0;
}

/* wave1183 G.7: Forward declarations for pipeline_expr_* functions defined
 * in ast_pool_expr_sidecar.c (included later via ast_pool.c #include L4607).
 * Needed because the ast_pipeline_expr_* forwarders below call these before
 * their definitions appear in the same TU. */
int32_t pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
void pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
int32_t pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                       int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                       int32_t variant_index);
void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                              int32_t is_var, int32_t variant_index);
int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                              int32_t name_len, int32_t init_ref);
int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref);
int32_t pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);

/* wave1183 G.7: ast_pipeline_expr_* + codegen_pipeline_expr_* +
 * backend_pipeline_expr_* forwarder cluster (40 fns) migrated from
 * pipeline_glue.c to this file's EOF.
 *
 * Why colocate: ast.x / codegen.x / backend.x resolve extern pipeline_expr_*
 * symbols with module prefixes at codegen time (ast_pipeline_expr_*,
 * codegen_pipeline_expr_*, backend_pipeline_expr_*), but the authoritative
 * implementations live in ast_pool_expr_sidecar.c / pipeline_asm_emit_expr_rec.c
 * with unprefixed C names (pipeline_expr_*). These 40 thin forwarders exist
 * solely to satisfy the linker name-mangling gap; colocating them here
 * keeps pipeline_glue.c focused on real glue logic.
 *
 * Sub-clusters:
 *  - codegen_pipeline_module_func_param_type_ref_at (1 fn: codegen_ prefix)
 *  - ast_pipeline_expr_call_* (6 fns: append_arg/on_created/prepare_slot/
 *    arg_ref/num_args/callee_ref -- call expr sidecar accessors)
 *  - ast_pipeline_expr_method_call_* (5 fns: append_arg/arg_ref/num_args/
 *    name_len/name_into -- method call sidecar accessors)
 *  - ast_pipeline_expr_match_* (10 fns: append_arm/num_arms/result_ref/
 *    is_wildcard/lit_val/is_enum_variant/variant_index/set_wildcard/
 *    set_lit_val/set_enum_variant -- match arm sidecar accessors)
 *  - ast_pipeline_expr_struct_lit/array_lit/float/if/block/match/const_folded
 *    (12 fns: append_field/append_elem/elem_ref/num_elems/bits_lo/hi/
 *    cond_ref/then_ref/else_ref/block_ref/matched_ref/const_folded_valid/val)
 *  - ast_pipeline_expr_index/field_access (6 fns: base_ref/index_ref/
 *    is_enum_variant/offset/layout_offset/load_byte_sz)
 *  - ast_pipeline_module_import_append_select_name (1 fn: import select name)
 *  - codegen_pipeline_expr_* + backend_pipeline_expr_* (5 fns: kind_ord/
 *    struct_lit_num_fields/init_ref -- codegen_ and backend_ prefix twins)
 *
 * Contract: every function here is a pure pass-through -- no state mutation,
 *   no branch, single tail call to the underlying pipeline_expr_* impl.
 *
 * PLATFORM: SHARED -- forwarders are platform-agnostic.
 */
int32_t codegen_pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index,
                                                       int32_t param_index) {
  return pipeline_module_func_param_type_ref_at(m, func_index, param_index);
}

/** Expr sidecar pool symbol forwarders called via import prefix by ast.x / typeck / codegen / backend / parser. */
int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_call_arg(a, expr_ref, arg_ref);
}
void ast_pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref) {
  pipeline_expr_on_call_created(a, expr_ref);
}
int32_t ast_pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_prepare_call_arg_slot(a, expr_ref);
}
int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_method_call_arg(a, expr_ref, arg_ref);
}
int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_method_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index) {
  return pipeline_expr_append_match_arm(a, expr_ref, result_ref, is_wildcard, lit_val, is_enum_variant,
                                        variant_index);
}
int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_num_arms_at(a, expr_ref);
}
int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_result_ref(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_wildcard(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_lit_val(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_variant_index(a, expr_ref, i);
}
void ast_pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_wildcard(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_lit_val(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index) {
  pipeline_expr_match_arm_set_enum_variant(a, expr_ref, i, is_var, variant_index);
}
int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref) {
  return pipeline_expr_append_struct_lit_field(a, expr_ref, name_bytes, name_len, init_ref);
}
int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref) {
  return pipeline_expr_append_array_lit_elem(a, expr_ref, elem_ref);
}
int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_array_lit_elem_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_array_lit_num_elems_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_lo_at(a, expr_ref);
}
int32_t ast_pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_float_bits_hi_at(a, expr_ref);
}
int32_t ast_pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_callee_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_base_ref_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_method_call_name_len(a, expr_ref);
}
void ast_pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  pipeline_expr_method_call_name_into(a, expr_ref, out64);
}
int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
/* wave1160 G.7: 9 ast_pipeline_expr_* wrappers above (as/if/block/match/
 * const_folded/enum_variant) migrated to pipeline_asm_emit_expr_rec.c EOF
 * as fwd decls. wave1159: 4 method_call wrappers remain as function bodies
 * (their pipeline_expr_* twins are in method_call.c via #include L9703). */
/* wave1161 G.7: index/field_access_offset wrappers migrated to
 * pipeline_asm_emit_expr_rec.c EOF as fwd decls below. */
int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_field_access_is_enum_variant(a, expr_ref);
}
int32_t ast_pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
int32_t ast_pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  return pipeline_expr_field_access_layout_offset(a, m, expr_ref);
}

int32_t ast_pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref) {
  return pipeline_expr_field_access_load_byte_sz(a, m, expr_ref);
}
int32_t ast_pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len) {
  return pipeline_module_import_append_select_name(m, idx, bytes, len);
}

/** backend import codegen uses codegen_ prefix for struct_lit glue. */
int32_t codegen_pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_kind_ord_at(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
int32_t backend_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t backend_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}

/* wave1187 G.7: codegen_/backend_ struct_lit field offset/store_sz forwarders
 * migrated from pipeline_glue.c L7239-L7255. Pure forwarders to
 * pipeline_expr_struct_lit_field_offset_at / _field_store_sz. */
int32_t codegen_pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                         int32_t field_ix) {
  return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
}
int32_t codegen_pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                        int32_t field_ix) {
  return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
}
int32_t backend_pipeline_expr_struct_lit_field_offset_at(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                         int32_t field_ix) {
  return pipeline_expr_struct_lit_field_offset_at(a, m, expr_ref, field_ix);
}
int32_t backend_pipeline_expr_struct_lit_field_store_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref,
                                                        int32_t field_ix) {
  return pipeline_expr_struct_lit_field_store_sz(a, m, expr_ref, field_ix);
}
