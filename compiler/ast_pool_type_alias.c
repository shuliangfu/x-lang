/**
 * ast_pool_type_alias.c — module TypeAliasEntry cold accessors (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain:
 * - pipeline_module_type_alias_* (alloc / set / name_len / name_byte_at /
 *   target_ref)
 * - pipeline_module_num_type_aliases_at
 *
 * Depends on same-TU statics: module_sidecar_get, grow_vec_*, ModuleSidecar /
 * TypeAliasEntry types (defined earlier in ast_pool.c).
 *
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck call these.
 * Wave: 981 · no semantic change · pin stays 77b334842.
 */

/** Allocate module sidecar type-alias slot; return idx or -1. */
int32_t pipeline_module_type_alias_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->type_aliases);
  if (idx < 0)
    return -1;
  return idx;
}

/**
 * Write type-alias name + target type ref into sidecar slot.
 * wave582 Cap residual: TypeAliasEntry.name is already u8[128]; gate was still
 * name_len>64 → long aliases never stored → typeck "expected NAMED, found i32".
 * Content cap 127 (match AST name[128] / wave577 Cap); zero-fill full row.
 * PLATFORM: SHARED
 */
void pipeline_module_type_alias_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                    int32_t target_type_ref) {
  TypeAliasEntry *ta;
  ModuleSidecar *sc;
  int32_t i;
  /* Content max 127; storage is name[128]. */
  if (!m || !name || name_len <= 0 || name_len > 127)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx < 0 || idx >= sc->type_aliases.len)
    return;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  if (!ta)
    return;
  for (i = 0; i < name_len; i++)
    ta->name[i] = name[i];
  for (i = name_len; i < 128; i++)
    ta->name[i] = 0;
  ta->name_len = name_len;
  ta->target_type_ref = target_type_ref;
  if (link_abi_getenv("XLANG_DEBUG_PIPE") != NULL) {
    fprintf(stderr, "xlang: [XLANG_DEBUG_PIPE] type_alias_set idx=%d len=%d target=%d\n", (int)idx, (int)name_len,
            (int)target_type_ref);
  }
}

/** Read type-alias name length. */
int32_t pipeline_module_type_alias_name_len(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TypeAliasEntry *ta;
  if (!sc || idx < 0 || idx >= sc->type_aliases.len)
    return 0;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  return ta ? ta->name_len : 0;
}

/** Read type-alias name byte; OOB → 0. wave582: off bound 64→128. PLATFORM: SHARED */
uint8_t pipeline_module_type_alias_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TypeAliasEntry *ta;
  if (!sc || idx < 0 || idx >= sc->type_aliases.len || off < 0 || off >= 128)
    return 0;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  return ta ? ta->name[off] : 0;
}

/** Read type-alias target type ref. */
int32_t pipeline_module_type_alias_target_ref(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TypeAliasEntry *ta;
  if (!sc || idx < 0 || idx >= sc->type_aliases.len)
    return 0;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  return ta ? ta->target_type_ref : 0;
}

/** Read module type-alias count (glue thin struct uses sidecar; do not read module field). */
int32_t pipeline_module_num_type_aliases_at(struct ast_Module *m) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  if (!sc)
    return 0;
  return sc->type_aliases.len;
}
