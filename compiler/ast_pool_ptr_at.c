/* ast_pool_ptr_at.c — core pointer accessors into sidecar GrowVec pools
 *
 * static block_at / module_layout_at / module_import_at — index into arena/module
 * sidecar pools. Same-TU #include AFTER ast_pool_sidecar_pool.c (needs *_sidecar_get)
 * and BEFORE domain accessors that call these statics (arena/block/import/…).
 * PLATFORM: SHARED — host-cc residual; G.7 single authority with domain thin files.
 */

static struct ast_Block *block_at(struct ast_ASTArena *a, int32_t br) {
  ArenaSidecar *sc;
  if (!a || br <= 0 || br > a->num_blocks)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Block *)grow_vec_at(&sc->blocks, br - 1);
}

static struct ast_StructLayout *module_layout_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_struct_layouts)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return NULL;
  return (struct ast_StructLayout *)grow_vec_at(&sc->struct_layouts, idx);
}

static ImportEntry *module_import_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_imports)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return NULL;
  return (ImportEntry *)grow_vec_at(&sc->imports, idx);
}
