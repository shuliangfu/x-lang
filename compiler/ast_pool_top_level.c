/**
 * ast_pool_top_level.c — module TopLevelLetEntry cold accessors (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain:
 * - pipeline_module_top_level_let_* (alloc / set / name / type_ref / init_ref /
 *   is_const / is_export)
 *
 * Not in this slice (stay in core):
 * - pipeline_module_top_level_name_is_const — name-scan consumer over lets
 *   (calls these accessors; lives earlier in ast_pool.c)
 *
 * Depends on same-TU statics: module_sidecar_get, grow_vec_*, ModuleSidecar /
 * TopLevelLetEntry types (defined earlier in ast_pool.c).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/asm/codegen call these.
 * Wave: 980 · no semantic change · pin stays 77b334842.
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
