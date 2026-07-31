/**
 * ast_pool_onefunc.c — OneFunc sidecar + fill_from_onefunc domain (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (contiguous cold APIs; G.7 single authority — extend in place):
 * - pipeline_onefunc_append_const / const_* accessors / num_consts
 * - pipeline_onefunc_append_let / let_* accessors / num_lets
 * - pipeline_onefunc_append_param / param_* / set_param_type_ref / num_params
 * - pipeline_onefunc_append_call_arg_val / call_arg_* / reset_call_args
 * - pipeline_onefunc_copy_sidecar (+ uses same-TU grow_vec_copy_append)
 * - pipeline_onefunc_const/let_name_copy64
 * - pipeline_onefunc_append_while/for + while/for accessors
 * - wave991 residual 有则补全:
 *   - defer / labeled / if / region / with_arena / unsafe / stmt_order / body_expr
 *   - pipeline_block_fill_*_from_onefunc (defers/labeled/regions/ifs/stmt_order/
 *     expr_stmts/whiles/fors) — block_append consumers live in same TU after
 *     #include "ast_pool_block.c"
 *
 * NOT in this slice:
 * - pipeline_module_top_level_name_is_const + hoist + hoist_target/sum
 *   (top_level domain · wave993–994)
 * - stmt_order rebuild / fixup / sparse_ifs (block domain · wave992)
 *
 * Depends on same-TU statics: onefunc_sidecar_get, grow_vec_*, OneFuncSidecar,
 * OneFuncLabeledEntry, OneFuncRegionEntry, grow_vec_copy_append,
 * block_at, pipeline_block_append_*, pipeline_block_labeled_ptr,
 * ast_pool_onefunc_reset (defined earlier in ast_pool.c).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser fill_block paths call these.
 * Wave: 984 + 991 residual · no semantic change · pin stays 77b334842.
 */

/** OneFunc const/let scratch 追加 API。 */
/**
 * 向 OneFunc 侧车池追加一条 const（与 append_let 对称；init_ref/type_ref 供 fill_block_const_let_from_res）。
 */
int32_t pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                      int32_t init_ref, int32_t type_ref) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t *pv;
  int32_t *pr;
  int32_t *pt;
  /* wave581 Cap residual: OneFunc const name rows are 128B; content cap 127. */
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 127)
    return -1;
  if (grow_vec_push(&sc->const_names) < 0 || grow_vec_push(&sc->const_name_lens) < 0 ||
      grow_vec_push(&sc->const_init_vals) < 0 || grow_vec_push(&sc->const_init_refs) < 0 ||
      grow_vec_push(&sc->const_type_refs) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->const_names, sc->const_names.len - 1);
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, sc->const_name_lens.len - 1);
  pv = (int32_t *)grow_vec_at(&sc->const_init_vals, sc->const_init_vals.len - 1);
  pr = (int32_t *)grow_vec_at(&sc->const_init_refs, sc->const_init_refs.len - 1);
  pt = (int32_t *)grow_vec_at(&sc->const_type_refs, sc->const_type_refs.len - 1);
  if (!row || !pl || !pv || !pr || !pt)
    return -1;
  memset(row, 0, 128);
  memcpy(row, name, (size_t)name_len);
  *pl = name_len;
  *pv = init_val;
  *pr = init_ref;
  *pt = type_ref;
  return sc->const_names.len - 1;
}

int32_t pipeline_onefunc_append_const_name(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val) {
  return pipeline_onefunc_append_const(out, name, name_len, init_val, 0, 0);
}

int32_t pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_init_refs.len)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->const_init_refs, i);
  return pr ? *pr : 0;
}

int32_t pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_type_refs.len)
    return 0;
  pt = (int32_t *)grow_vec_at(&sc->const_type_refs, i);
  return pt ? *pt : 0;
}

int32_t pipeline_onefunc_const_name_len(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_name_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, i);
  return pl ? *pl : 0;
}

uint8_t pipeline_onefunc_const_name_byte_at(uint8_t *out, int32_t i, int32_t off) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  /* wave581 Cap residual: content index 0..126. */
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_names.len || off < 0 || off >= 127)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->const_names, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

int32_t pipeline_onefunc_const_init_val(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_init_vals.len)
    return 0;
  pv = (int32_t *)grow_vec_at(&sc->const_init_vals, i);
  return pv ? *pv : 0;
}

int32_t pipeline_onefunc_num_consts(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->const_name_lens.len : 0;
}

/** OneFunc 侧车 let_init_refs：-1 表示 `let x: T;` 无显式初值（栈零填，等价 u8[N]=[] / asm prologue 清零）。 */
#define PIPELINE_ONEFUNC_LET_INIT_OMITTED (-1)

int32_t pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                    int32_t type_ref) {
  OneFuncSidecar *sc;
  uint8_t *row;
  /*
   * wave581 Cap residual (body let long name): parser accepts name_len<=127 but this
   * gate was still >64 → append fails → parse_body_lets returns false → no main (BLD001).
   * PLATFORM: SHARED — OneFunc sidecar row width 128.
   */
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 127)
    return -1;
  if (grow_vec_push(&sc->let_names) < 0 || grow_vec_push(&sc->let_name_lens) < 0 ||
      grow_vec_push(&sc->let_init_vals) < 0 || grow_vec_push(&sc->let_init_refs) < 0 ||
      grow_vec_push(&sc->let_type_refs) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->let_names, sc->let_names.len - 1);
  if (!row)
    return -1;
  memset(row, 0, 128);
  memcpy(row, name, (size_t)name_len);
  *((int32_t *)grow_vec_at(&sc->let_name_lens, sc->let_name_lens.len - 1)) = name_len;
  *((int32_t *)grow_vec_at(&sc->let_init_vals, sc->let_init_vals.len - 1)) = init_val;
  *((int32_t *)grow_vec_at(&sc->let_init_refs, sc->let_init_refs.len - 1)) = init_ref;
  *((int32_t *)grow_vec_at(&sc->let_type_refs, sc->let_type_refs.len - 1)) = type_ref;
  return sc->let_names.len - 1;
}

int32_t pipeline_onefunc_let_name_len(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_name_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->let_name_lens, i);
  return pl ? *pl : 0;
}

uint8_t pipeline_onefunc_let_name_byte_at(uint8_t *out, int32_t i, int32_t off) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  /* wave581 Cap residual: content index 0..126. */
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_names.len || off < 0 || off >= 127)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->let_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->let_names, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

int32_t pipeline_onefunc_let_init_val(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_init_vals.len)
    return 0;
  pv = (int32_t *)grow_vec_at(&sc->let_init_vals, i);
  return pv ? *pv : 0;
}

int32_t pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_init_refs.len)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->let_init_refs, i);
  return pr ? *pr : 0;
}

int32_t pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_type_refs.len)
    return 0;
  pt = (int32_t *)grow_vec_at(&sc->let_type_refs, i);
  return pt ? *pt : 0;
}

int32_t pipeline_onefunc_num_lets(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->let_name_lens.len : 0;
}

/**
 * Append one parse-scratch param name into OneFunc sidecar.
 * wave585 Cap residual: content ≤127; row width 128 (was 31/32).
 * @return new index, or -1 on failure
 * PLATFORM: SHARED
 */
int32_t pipeline_onefunc_append_param(uint8_t *out, uint8_t *name, int32_t name_len, int32_t type_ref) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t *pt;
  int32_t n;
  int32_t k;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 127)
    return -1;
  if (grow_vec_push(&sc->param_names) < 0 || grow_vec_push(&sc->param_name_lens) < 0 ||
      grow_vec_push(&sc->param_type_refs) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->param_names, sc->param_names.len - 1);
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, sc->param_name_lens.len - 1);
  pt = (int32_t *)grow_vec_at(&sc->param_type_refs, sc->param_type_refs.len - 1);
  if (!row || !pl || !pt)
    return -1;
  memset(row, 0, 128);
  n = name_len;
  for (k = 0; k < n; k++)
    row[k] = name[k];
  *pl = n;
  *pt = type_ref;
  return sc->param_name_lens.len - 1;
}

void pipeline_onefunc_set_param_type_ref(uint8_t *out, int32_t i, int32_t type_ref) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_type_refs.len)
    return;
  pt = (int32_t *)grow_vec_at(&sc->param_type_refs, i);
  if (pt)
    *pt = type_ref;
}

int32_t pipeline_onefunc_param_name_len(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_name_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, i);
  return pl ? *pl : 0;
}

uint8_t pipeline_onefunc_param_name_byte_at(uint8_t *out, int32_t i, int32_t off) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  /* wave585 Cap residual: off bound 32→128 (param row[128]). */
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_names.len || off < 0 || off >= 128)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->param_names, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

/**
 * ABI name kept as *copy32; wave585 Cap residual raised payload 32→128.
 * Callers must pass a dst buffer of at least 128 bytes.
 * PLATFORM: SHARED
 */
void pipeline_onefunc_param_name_copy32(uint8_t *out, int32_t i, uint8_t *dst) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 128);
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_names.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->param_names, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 127)
    n = 127;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

int32_t pipeline_onefunc_param_type_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_type_refs.len)
    return 0;
  pt = (int32_t *)grow_vec_at(&sc->param_type_refs, i);
  return pt ? *pt : 0;
}

int32_t pipeline_onefunc_num_params_from_pool(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->param_name_lens.len : 0;
}

int32_t pipeline_onefunc_append_call_arg_val(uint8_t *out, int32_t val) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->call_arg_vals) < 0)
    return -1;
  pv = (int32_t *)grow_vec_at(&sc->call_arg_vals, sc->call_arg_vals.len - 1);
  if (!pv)
    return -1;
  *pv = val;
  return sc->call_arg_vals.len - 1;
}

int32_t pipeline_onefunc_call_arg_val_at(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->call_arg_vals.len)
    return 0;
  pv = (int32_t *)grow_vec_at(&sc->call_arg_vals, i);
  return pv ? *pv : 0;
}

void pipeline_onefunc_reset_call_args(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  if (sc)
    sc->call_arg_vals.len = 0;
}


/** 复制 OneFunc 侧车池（const/let/if/stmt_order 等）；dst 与 src 可为不同 OneFuncResult 地址。 */
void pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src) {
  OneFuncSidecar *dsc;
  OneFuncSidecar *ssc;
  if (!dst || !src || dst == src)
    return;
  if (!(ssc = onefunc_sidecar_get(src, 0)))
    return;
  ast_pool_onefunc_reset(dst);
  if (!(dsc = onefunc_sidecar_get(dst, 0)))
    return;
  grow_vec_copy_append(&dsc->if_cond_refs, &ssc->if_cond_refs);
  grow_vec_copy_append(&dsc->if_then_body_refs, &ssc->if_then_body_refs);
  grow_vec_copy_append(&dsc->if_else_body_refs, &ssc->if_else_body_refs);
  grow_vec_copy_append(&dsc->const_names, &ssc->const_names);
  grow_vec_copy_append(&dsc->const_name_lens, &ssc->const_name_lens);
  grow_vec_copy_append(&dsc->const_init_vals, &ssc->const_init_vals);
  grow_vec_copy_append(&dsc->const_init_refs, &ssc->const_init_refs);
  grow_vec_copy_append(&dsc->const_type_refs, &ssc->const_type_refs);
  grow_vec_copy_append(&dsc->let_names, &ssc->let_names);
  grow_vec_copy_append(&dsc->let_name_lens, &ssc->let_name_lens);
  grow_vec_copy_append(&dsc->let_init_vals, &ssc->let_init_vals);
  grow_vec_copy_append(&dsc->let_init_refs, &ssc->let_init_refs);
  grow_vec_copy_append(&dsc->let_type_refs, &ssc->let_type_refs);
  grow_vec_copy_append(&dsc->src_stmt_kind, &ssc->src_stmt_kind);
  grow_vec_copy_append(&dsc->src_stmt_idx, &ssc->src_stmt_idx);
  grow_vec_copy_append(&dsc->src_body_expr_stmt_refs, &ssc->src_body_expr_stmt_refs);
  grow_vec_copy_append(&dsc->while_cond_refs, &ssc->while_cond_refs);
  grow_vec_copy_append(&dsc->while_body_refs, &ssc->while_body_refs);
  grow_vec_copy_append(&dsc->for_init_refs, &ssc->for_init_refs);
  grow_vec_copy_append(&dsc->for_cond_refs, &ssc->for_cond_refs);
  grow_vec_copy_append(&dsc->for_step_refs, &ssc->for_step_refs);
  grow_vec_copy_append(&dsc->for_body_refs, &ssc->for_body_refs);
  grow_vec_copy_append(&dsc->param_names, &ssc->param_names);
  grow_vec_copy_append(&dsc->param_name_lens, &ssc->param_name_lens);
  grow_vec_copy_append(&dsc->param_type_refs, &ssc->param_type_refs);
  grow_vec_copy_append(&dsc->call_arg_vals, &ssc->call_arg_vals);
  /* wave379: labeleds (goto/label) must follow const/let/stmt_order in copy. */
  grow_vec_copy_append(&dsc->labeleds, &ssc->labeleds);
}

/**
 * Copy OneFunc const name i into dst.
 * ABI name kept as *copy64; wave581 Cap residual raised payload 64→128.
 * @param out OneFuncResult pool pointer
 * @param i const index
 * @param dst caller buffer; must have capacity >= 128
 * PLATFORM: SHARED
 */
void pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 128);
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_names.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->const_names, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 127)
    n = 127;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/**
 * Copy OneFunc let name i into dst.
 * ABI name kept as *copy64; wave581 Cap residual raised payload 64→128.
 * @param out OneFuncResult pool pointer
 * @param i let index
 * @param dst caller buffer; must have capacity >= 128
 * PLATFORM: SHARED — fill_block_const_let_from_res + typeck use this path
 */
void pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 128);
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_names.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->let_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->let_names, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 127)
    n = 127;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** ---------- OneFunc while/for 侧车池 ---------- */

int32_t pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref) {
  OneFuncSidecar *sc;
  int32_t *pc;
  int32_t *pb;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->while_cond_refs) < 0 || grow_vec_push(&sc->while_body_refs) < 0)
    return -1;
  pc = (int32_t *)grow_vec_at(&sc->while_cond_refs, sc->while_cond_refs.len - 1);
  pb = (int32_t *)grow_vec_at(&sc->while_body_refs, sc->while_body_refs.len - 1);
  if (!pc || !pb)
    return -1;
  *pc = cond_ref;
  *pb = body_ref;
  return sc->while_cond_refs.len - 1;
}

int32_t pipeline_onefunc_while_cond_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->while_cond_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->while_cond_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_while_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->while_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->while_body_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_num_whiles(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->while_cond_refs.len : 0;
}

int32_t pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                     int32_t body_ref) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->for_init_refs) < 0 || grow_vec_push(&sc->for_cond_refs) < 0 ||
      grow_vec_push(&sc->for_step_refs) < 0 || grow_vec_push(&sc->for_body_refs) < 0)
    return -1;
  p = (int32_t *)grow_vec_at(&sc->for_init_refs, sc->for_init_refs.len - 1);
  if (p)
    *p = init_ref;
  p = (int32_t *)grow_vec_at(&sc->for_cond_refs, sc->for_cond_refs.len - 1);
  if (p)
    *p = cond_ref;
  p = (int32_t *)grow_vec_at(&sc->for_step_refs, sc->for_step_refs.len - 1);
  if (p)
    *p = step_ref;
  p = (int32_t *)grow_vec_at(&sc->for_body_refs, sc->for_body_refs.len - 1);
  if (p)
    *p = body_ref;
  return sc->for_init_refs.len - 1;
}

int32_t pipeline_onefunc_for_init_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_init_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_init_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_for_cond_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_cond_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_cond_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_for_step_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_step_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_step_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_for_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_body_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_num_fors(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->for_init_refs.len : 0;
}

/* -------------------------------------------------------------------------- */
/* wave991: onefunc residual + fill_from_onefunc (G.7 有则补全 into this leaf) */
/* -------------------------------------------------------------------------- */


/** MEM-B0：OneFunc 侧车追加 defer body；返回 defer 下标，失败 -1。 */
int32_t pipeline_onefunc_append_defer(uint8_t *out, int32_t body_ref) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || body_ref <= 0 || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->defer_body_refs) < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->defer_body_refs, sc->defer_body_refs.len - 1);
  *pr = body_ref;
  return sc->defer_body_refs.len - 1;
}



int32_t pipeline_onefunc_num_defers(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->defer_body_refs.len : 0;
}



/** MEM-B0：将 OneFunc 中 defer 链批量写入 Block 池。 */
void pipeline_block_fill_defers_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  OneFuncSidecar *sc;
  int32_t *pr;
  int32_t i;
  if (!a || !out || !(sc = onefunc_sidecar_get(out, 0)))
    return;
  for (i = 0; i < count && i < sc->defer_body_refs.len; i++) {
    pr = (int32_t *)grow_vec_at(&sc->defer_body_refs, i);
    if (pr && *pr > 0)
      pipeline_block_append_defer(a, br, *pr);
  }
}



/* BC 8.3.2 wave989–990: block residual (+ parent/resolve/name-binding wave990)
 * moved into ast_pool_block.c (same-TU #include above).
 * onefunc labeled + fill_* stay here as residual. */

/**
 * wave379: append labeled entry to OneFunc scratch (goto / label / labeled return).
 * @return index in onefunc labeled pool, or -1 on failure
 * PLATFORM: SHARED — G.7 authority with pipeline_block_append_labeled.
 */
int32_t pipeline_onefunc_append_labeled(uint8_t *out, uint8_t *label, int32_t label_len, int32_t is_goto,
                                        uint8_t *goto_target, int32_t goto_target_len, int32_t return_expr_ref) {
  OneFuncSidecar *sc;
  OneFuncLabeledEntry *le;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->labeleds) < 0)
    return -1;
  le = (OneFuncLabeledEntry *)grow_vec_at(&sc->labeleds, sc->labeleds.len - 1);
  if (!le)
    return -1;
  memset(le, 0, sizeof(*le));
  le->is_goto = is_goto;
  le->return_expr_ref = return_expr_ref;
  if (label && label_len > 0) {
    /* wave586 Cap residual: label content ≤127 (OneFuncLabeledEntry.label[128]). */
    if (label_len > 127)
      label_len = 127;
    memcpy(le->label, label, (size_t)label_len);
    le->label_len = label_len;
  }
  if (goto_target && goto_target_len > 0) {
    /* wave586 Cap residual: goto target content ≤127. */
    if (goto_target_len > 127)
      goto_target_len = 127;
    memcpy(le->goto_target, goto_target, (size_t)goto_target_len);
    le->goto_target_len = goto_target_len;
  }
  return sc->labeleds.len - 1;
}



int32_t pipeline_onefunc_num_labeleds(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->labeleds.len : 0;
}



/**
 * wave379: flush OneFunc labeled pool into Block.labeled_stmts (preserves names).
 * Resets block num_labeled_stmts first (same pattern as fill_ifs_from_onefunc).
 * Names are written via labeled_ptr (append only stores lengths).
 * PLATFORM: SHARED.
 */
void pipeline_block_fill_labeled_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  OneFuncSidecar *sc;
  OneFuncLabeledEntry *le;
  struct ast_Block *b;
  struct ast_LabeledStmt *ls;
  int32_t i;
  int32_t li;
  if (!a || !out || !(sc = onefunc_sidecar_get(out, 0)))
    return;
  if (br > 0 && (b = block_at(a, br)))
    b->num_labeled_stmts = 0;
  for (i = 0; i < count && i < sc->labeleds.len; i++) {
    le = (OneFuncLabeledEntry *)grow_vec_at(&sc->labeleds, i);
    if (!le)
      continue;
    li = pipeline_block_append_labeled(a, br, le->label_len, le->is_goto, le->goto_target_len,
                                       le->return_expr_ref);
    if (li < 0)
      continue;
    ls = pipeline_block_labeled_ptr(a, br, li);
    if (!ls)
      continue;
    if (le->label_len > 0) {
      int32_t n = le->label_len;
      if (n > 127)
        n = 127;
      memcpy(ls->label, le->label, (size_t)n);
      ls->label[n] = 0;
      ls->label_len = n;
    }
    if (le->goto_target_len > 0) {
      int32_t n = le->goto_target_len;
      if (n > 127)
        n = 127;
      memcpy(ls->goto_target, le->goto_target, (size_t)n);
      ls->goto_target[n] = 0;
      ls->goto_target_len = n;
    }
  }
}



/** OneFunc scratch 池 API */
int32_t pipeline_onefunc_append_if(uint8_t *out, int32_t cond, int32_t then_ref, int32_t else_ref) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->if_cond_refs) < 0)
    return -1;
  if (grow_vec_push(&sc->if_then_body_refs) < 0)
    return -1;
  if (grow_vec_push(&sc->if_else_body_refs) < 0)
    return -1;
  p = (int32_t *)grow_vec_at(&sc->if_cond_refs, sc->if_cond_refs.len - 1);
  *p = cond;
  p = (int32_t *)grow_vec_at(&sc->if_then_body_refs, sc->if_then_body_refs.len - 1);
  *p = then_ref;
  p = (int32_t *)grow_vec_at(&sc->if_else_body_refs, sc->if_else_body_refs.len - 1);
  *p = else_ref;
  return sc->if_cond_refs.len - 1;
}



int32_t pipeline_onefunc_if_cond_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->if_cond_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->if_cond_refs, i);
  return p ? *p : 0;
}



int32_t pipeline_onefunc_if_then_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->if_then_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->if_then_body_refs, i);
  return p ? *p : 0;
}



int32_t pipeline_onefunc_if_else_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->if_else_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->if_else_body_refs, i);
  return p ? *p : 0;
}



int32_t pipeline_onefunc_num_if_stmts(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->if_cond_refs.len : 0;
}



/** M-3：OneFunc 侧车追加 region；返回 region 下标，失败 -1。 */
int32_t pipeline_onefunc_append_region(uint8_t *out, uint8_t *label, int32_t label_len, int32_t body_ref) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !label || label_len <= 0 || label_len > 127)
    return -1;
  if (grow_vec_push(&sc->regions) < 0)
    return -1;
  re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, sc->regions.len - 1);
  if (!re)
    return -1;
  memset(re, 0, sizeof(*re));
  memcpy(re->label, label, (size_t)label_len);
  re->label_len = label_len;
  re->body_ref = body_ref;
  re->with_arena_cap_ref = 0;
  return sc->regions.len - 1;
}



/** MEM-C1：OneFunc 侧车追加 with_arena(cap) { body }。 */
int32_t pipeline_onefunc_append_with_arena(uint8_t *out, int32_t cap_ref, int32_t body_ref) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || cap_ref <= 0 || body_ref <= 0)
    return -1;
  if (grow_vec_push(&sc->regions) < 0)
    return -1;
  re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, sc->regions.len - 1);
  if (!re)
    return -1;
  memset(re, 0, sizeof(*re));
  re->with_arena_cap_ref = cap_ref;
  re->body_ref = body_ref;
  return sc->regions.len - 1;
}



/** LANG-007 v2：OneFunc 侧车追加 unsafe { body }。 */
int32_t pipeline_onefunc_append_unsafe(uint8_t *out, int32_t body_ref) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || body_ref <= 0)
    return -1;
  if (grow_vec_push(&sc->regions) < 0)
    return -1;
  re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, sc->regions.len - 1);
  if (!re)
    return -1;
  memset(re, 0, sizeof(*re));
  re->with_arena_cap_ref = -1;
  re->body_ref = body_ref;
  return sc->regions.len - 1;
}



int32_t pipeline_onefunc_num_regions(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->regions.len : 0;
}



/** M-3：将 OneFunc 中 region 链批量写入 Block 池。 */
void pipeline_block_fill_regions_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  int32_t i;
  if (!a || !out || !(sc = onefunc_sidecar_get(out, 0)))
    return;
  for (i = 0; i < count && i < sc->regions.len; i++) {
    re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, i);
    if (!re)
      continue;
    if (re->with_arena_cap_ref > 0)
      pipeline_block_append_with_arena(a, br, re->with_arena_cap_ref, re->body_ref);
    else if (re->with_arena_cap_ref == -1)
      pipeline_block_append_unsafe(a, br, re->body_ref);
    else if (re->label_len > 0)
      pipeline_block_append_region(a, br, re->label, re->label_len, re->body_ref);
  }
}



int32_t pipeline_onefunc_push_stmt_order(uint8_t *out, uint8_t kind, int32_t idx) {
  OneFuncSidecar *sc;
  uint8_t *pk;
  int32_t *pi;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->src_stmt_kind) < 0 || grow_vec_push(&sc->src_stmt_idx) < 0)
    return -1;
  pk = (uint8_t *)grow_vec_at(&sc->src_stmt_kind, sc->src_stmt_kind.len - 1);
  pi = (int32_t *)grow_vec_at(&sc->src_stmt_idx, sc->src_stmt_idx.len - 1);
  *pk = kind;
  *pi = idx;
  return sc->src_stmt_kind.len - 1;
}



int32_t pipeline_onefunc_num_src_stmt_order(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->src_stmt_kind.len : 0;
}



uint8_t pipeline_onefunc_src_stmt_kind(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  uint8_t *pk;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->src_stmt_kind.len)
    return 0;
  pk = (uint8_t *)grow_vec_at(&sc->src_stmt_kind, i);
  return pk ? *pk : 0;
}



int32_t pipeline_onefunc_src_stmt_idx(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pi;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->src_stmt_idx.len)
    return 0;
  pi = (int32_t *)grow_vec_at(&sc->src_stmt_idx, i);
  return pi ? *pi : 0;
}



int32_t pipeline_onefunc_push_body_expr_stmt(uint8_t *out, int32_t expr_ref) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->src_body_expr_stmt_refs) < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->src_body_expr_stmt_refs, sc->src_body_expr_stmt_refs.len - 1);
  *pr = expr_ref;
  return sc->src_body_expr_stmt_refs.len - 1;
}



int32_t pipeline_onefunc_body_expr_stmt_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->src_body_expr_stmt_refs.len)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->src_body_expr_stmt_refs, i);
  return pr ? *pr : 0;
}



int32_t pipeline_onefunc_num_body_expr_stmts(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->src_body_expr_stmt_refs.len : 0;
}



/**
 * 将 OneFunc 中 if 链批量写入 Block 池。
 * 调用方勿预置 b->num_if_stmts（与 num_loops 相同）：否则 lazy_fix if_base 错位，
 * asm emit 读到错误 IfStmt，块内 if 被静默跳过（run-asm-binop-var #38）。
 */
void pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  struct ast_Block *b;
  if (a && br > 0 && (b = block_at(a, br)))
    b->num_if_stmts = 0;
  for (i = 0; i < count; i++) {
    pipeline_block_append_if(a, br, pipeline_onefunc_if_cond_ref(out, i),
                             pipeline_onefunc_if_then_body_ref(out, i),
                             pipeline_onefunc_if_else_body_ref(out, i));
  }
}



void pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  for (i = 0; i < count; i++) {
    pipeline_block_append_stmt_order(a, br, pipeline_onefunc_src_stmt_kind(out, i),
                                     pipeline_onefunc_src_stmt_idx(out, i));
  }
}



void pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  for (i = 0; i < count; i++) {
    pipeline_block_append_expr_stmt(a, br, pipeline_onefunc_body_expr_stmt_ref(out, i));
  }
}



void pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  for (i = 0; i < count; i++) {
    int32_t cond_ref = pipeline_onefunc_while_cond_ref(out, i);
    int32_t body_ref = pipeline_onefunc_while_body_ref(out, i);
    if (link_abi_getenv("XLANG_ASM_DEBUG"))
      fprintf(stderr, "xlang: fill_while_from_onefunc i=%d cond=%d body=%d\n", (int)i, (int)cond_ref, (int)body_ref);
    pipeline_block_append_while(a, br, cond_ref, body_ref);
  }
}



void pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: fill_fors br=%d count=%d\n", (int)br, (int)count);
  for (i = 0; i < count; i++) {
    pipeline_block_append_for(a, br, pipeline_onefunc_for_init_ref(out, i), pipeline_onefunc_for_cond_ref(out, i),
                              pipeline_onefunc_for_step_ref(out, i), pipeline_onefunc_for_body_ref(out, i));
  }
}
