/**
 * ast_pool_top_level.c — module TopLevelLetEntry cold accessors + name scan /
 * hoist + asm hoist-target / top-level stack residual (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain:
 * - pipeline_module_top_level_let_* (alloc / set / name / type_ref / init_ref /
 *   is_const / is_export)
 * - wave993 residual 有则补全:
 *   - pipeline_module_top_level_name_is_const (name-scan over top-level lets)
 *   - pipeline_module_hoist_top_level_lets_into_main (append lets into main /
 *     first emitable body + stmt_order prepend; needs block prepend_lets)
 * - wave994 residual 有则补全:
 *   - pipeline_asm_hoist_target_func_index (main or first non-extern body)
 *   - pipeline_asm_sum_module_top_level_lets_stack (non-hoist frame estimate;
 *     skips shared modlet cells)
 *
 * Include order (ast_pool.c): block domain first (static prepend_lets), then
 * this file — hoist may call static pipeline_block_stmt_order_prepend_lets.
 *
 * Depends on same-TU statics: module_sidecar_get, grow_vec_*, block_at,
 * ModuleSidecar / TopLevelLetEntry (defined earlier in ast_pool.c); block
 * append_let / prepend_lets (ast_pool_block.c); pipeline_module_func_* /
 * pipeline_asm_module_func_is_extern_at / pipeline_expr_kind_ord_at.
 * Asm frame helpers (extern via glue same TU): pipeline_asm_modlet_name_is_shared,
 * asm_local_slot_reg_offset, pipeline_asm_let_init_stack_reserve_bytes.
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/asm/codegen call these.
 * Wave: 980 + 993 + 994 residual · no semantic change · pin stays 77b334842.
 */

int32_t pipeline_module_top_level_let_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->top_level_lets);
  if (idx < 0)
    return -1;
  m->num_top_level_lets = sc->top_level_lets.len;
  return idx;
}

void pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                       int32_t type_ref, int32_t init_ref, int32_t is_const) {
  TopLevelLetEntry *tl;
  ModuleSidecar *sc;
  int32_t n;
  /* wave581 Cap residual: TopLevelLetEntry.name is u8[128]; content cap 127. */
  if (!m || !name || name_len <= 0 || name_len > 127)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  if (!tl)
    return;
  n = name_len > 127 ? 127 : name_len;
  tl->name_len = n;
  tl->type_ref = type_ref;
  tl->init_ref = init_ref;
  tl->is_const = is_const;
  memset(tl->name, 0, sizeof(tl->name));
  memcpy(tl->name, name, (size_t)n);
}

int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->name_len : 0;
}

uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  /* wave581 Cap residual: name slot is 128; content index 0..126. */
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len || off < 0 || off >= 127)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl && off < tl->name_len ? tl->name[off] : 0;
}

int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->type_ref : 0;
}

/**
 * wave423: stamp top-level const type_ref after inference from init.
 * G.7 authority for module sidecar; typeck pre-pass uses this.
 * PLATFORM: SHARED typeck/AST.
 */
void pipeline_module_top_level_let_set_type_ref(struct ast_Module *m, int32_t idx, int32_t type_ref) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  if (tl)
    tl->type_ref = type_ref;
}

int32_t pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->init_ref : 0;
}

int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->is_const : 0;
}

void pipeline_module_top_level_let_set_is_export(struct ast_Module *m, int32_t idx, int32_t is_export) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  if (tl)
    tl->is_export = is_export;
}
int32_t pipeline_module_top_level_let_is_export_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->is_export : 0;
}

/* BC 8.3.2 wave993: name-scan + hoist residual (有则补全 into top_level domain). */

/**
 * wave678 Cap residual: 1 if a module top-level let/const slot has this name and
 * is_const (top-level `const N = …`). 0 if missing or non-const top let.
 * @param m *Module
 * @param vname *u8
 * @param vlen i32
 * @return i32 — 1 const top-level, 0 otherwise
 * PLATFORM: SHARED
 */
int32_t pipeline_module_top_level_name_is_const(struct ast_Module *m, uint8_t *vname, int32_t vlen) {
  int32_t n;
  int32_t i;
  int32_t nl;
  int32_t k;
  if (!m || !vname || vlen <= 0)
    return 0;
  n = m->num_top_level_lets;
  for (i = 0; i < n; i++) {
    nl = pipeline_module_top_level_let_name_len(m, i);
    if (nl != vlen)
      continue;
    for (k = 0; k < vlen; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, i, k) != vname[k])
        break;
    }
    if (k == vlen)
      return pipeline_module_top_level_let_is_const(m, i) != 0 ? 1 : 0;
  }
  return 0;
}

/**
 * Hoist module top-level let/const into main (or first non-extern body) for asm
 * stack-slot init. Keeps num_top_level_lets so emit can still fall back to
 * module const literals for other functions (e.g. AF_INET as u16).
 *
 * Calls pipeline_block_append_let + static pipeline_block_stmt_order_prepend_lets
 * (same TU after ast_pool_block.c include).
 * PLATFORM: SHARED — asm emit / backend pre-mega path.
 */
void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t mi;
  int32_t br;
  int32_t tl;
  int32_t fi;
  int32_t n;
  int32_t let_start_idx;
  uint8_t name_buf[128];
  int32_t name_len;
  int32_t k;
  ModuleSidecar *sc;
  TopLevelLetEntry *ent;
  const char *dbg_hoist;
  struct ast_Block *main_blk;
  if (!m || !a || m->num_top_level_lets <= 0)
    return;
  dbg_hoist = link_abi_getenv("XLANG_DEBUG_TOPLEVEL_HOIST");
  mi = m->main_func_index;
  if (mi < 0) {
    /* Library -o .o has no main: hoist into first emitable non-extern body
     * (same as C static globals for init). */
    mi = -1;
    for (fi = 0; fi < m->num_funcs; fi++) {
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 &&
          pipeline_module_func_body_ref_at(m, fi) > 0) {
        mi = fi;
        break;
      }
    }
    if (mi < 0)
      return;
  }
  br = pipeline_module_func_body_ref_at(m, mi);
  if (br <= 0)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  main_blk = block_at(a, br);
  let_start_idx = main_blk ? main_blk->num_lets : 0;
  n = m->num_top_level_lets;
  if (dbg_hoist && dbg_hoist[0] && dbg_hoist[0] != '0') {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "hoist debug: target_fi=%d body_ref=%d top_level_lets=%d prior_block_lets=%d",
                 (int)mi, (int)br, (int)n, (int)let_start_idx);
  }
  for (tl = 0; tl < n; tl++) {
    if (tl < 0 || tl >= sc->top_level_lets.len)
      break;
    ent = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, tl);
    /* wave581 Cap residual: top-level let name content cap 127. */
    if (!ent || ent->name_len <= 0 || ent->name_len > 127)
      continue;
    if (dbg_hoist && dbg_hoist[0] && dbg_hoist[0] != '0' && tl < 40) {
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "hoist debug: idx=%d const=%d name=%.*s init_ref=%d init_kind=%d",
                   (int)tl, (int)ent->is_const, (int)ent->name_len, (const char *)ent->name,
                   (int)ent->init_ref, (int)pipeline_expr_kind_ord_at(a, ent->init_ref));
    }
    name_len = ent->name_len;
    for (k = 0; k < name_len; k++)
      name_buf[k] = ent->name[k];
    (void)pipeline_block_append_let(a, br, name_buf, name_len, ent->type_ref, ent->init_ref);
  }
  pipeline_block_stmt_order_prepend_lets(a, br, let_start_idx, n);
}

/* BC 8.3.2 wave994: asm hoist-target + top-level lets stack residual (有则补全). */

/**
 * Return the hoist target function index: main_func_index when set, else the
 * first non-extern function with a body (library -o .o has no main).
 * @param m *Module
 * @return i32 — func index, or -1 if none
 * PLATFORM: SHARED — asm frame layout / backend pre-mega path.
 */
int32_t pipeline_asm_hoist_target_func_index(struct ast_Module *m) {
  int32_t fi;
  if (!m)
    return -1;
  if (m->main_func_index >= 0)
    return m->main_func_index;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 &&
        pipeline_module_func_body_ref_at(m, fi) > 0)
      return fi;
  }
  return -1;
}

/** pipeline_glue.c — x86_64 text-embedded module mutable lets (true cross-fn share). */
extern int32_t pipeline_asm_modlet_name_is_shared(uint8_t *name, int32_t name_len);
/** Frame slot helpers (glue / bootstrap_glue same TU; prototypes for free-standing cc). */
extern int32_t asm_local_slot_reg_offset(struct ast_ASTArena *arena, int32_t type_ref, int32_t off,
                                        int32_t *inout_off);
extern int32_t pipeline_asm_let_init_stack_reserve_bytes(struct ast_ASTArena *arena, int32_t type_ref,
                                                        int32_t init_ref);

/**
 * Accumulate stack occupancy of module top-level let/const slots for non-hoist
 * target functions (frame_size estimate). Shared modlet cells live in .text and
 * are skipped.
 * @param a *ASTArena
 * @param m *Module
 * @param off i32 — incoming frame offset
 * @return i32 — updated frame offset
 * PLATFORM: SHARED — asm emit frame layout.
 */
int32_t pipeline_asm_sum_module_top_level_lets_stack(struct ast_ASTArena *a, struct ast_Module *m, int32_t off) {
  ModuleSidecar *sc;
  int32_t tl;
  int32_t n;
  if (!a || !m || m->num_top_level_lets <= 0)
    return off;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return off;
  n = m->num_top_level_lets;
  for (tl = 0; tl < n; tl++) {
    TopLevelLetEntry *ent;
    int32_t type_ref;
    int32_t init_ref;
    if (tl < 0 || tl >= sc->top_level_lets.len)
      break;
    ent = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, tl);
    if (!ent || ent->type_ref <= 0)
      continue;
    /* Modlet cells live in .text, not the per-fn frame. */
    if (ent->name_len > 0 && pipeline_asm_modlet_name_is_shared(ent->name, ent->name_len) != 0)
      continue;
    type_ref = ent->type_ref;
    init_ref = ent->init_ref;
    (void)asm_local_slot_reg_offset(a, type_ref, off, &off);
    off += pipeline_asm_let_init_stack_reserve_bytes(a, type_ref, init_ref);
  }
  return off;
}
