/**
 * ast_pool_module_import.c — module ImportEntry cold-twin accessors (BC 8.3.2).
 *
 * Same-TU #include from ast_pool.c (itself #include'd into pipeline_glue /
 * pipeline_x). Not a separate .o.
 *
 * Domain (wave110 Cap residual cold twins):
 * - XLANG_WEAK pipeline_module_import_* (alloc / path / kind / binding /
 *   select_name + storage_release no-op). Product pure strong overrides at
 *   hybrid link; Cap GrowVec bodies remain here for non-PREFER / seed links.
 *
 * Depends on same-TU statics: module_sidecar_get, module_import_at, grow_vec_*,
 * ImportEntry / ModuleSidecar types (defined earlier in ast_pool.c).
 *
 * PLATFORM: SHARED — pure strong overrides weak at final product hybrid link.
 * Wave: 978 · no semantic change · pin stays 77b334842.
 */

/*
 * wave110: product pure owns ImportEntry storage via runtime_pipeline_abi.x
 * (multi-module malloc map + full pipeline_module_import_* set). Cap GrowVec
 * bodies stay as XLANG_WEAK cold twins for non-PREFER / seed-only links.
 * PLATFORM: SHARED — pure strong overrides weak at final product hybrid link.
 */

/** Cold twin no-op: pure pipeline_module_import_storage_release frees pure map. */
XLANG_WEAK void pipeline_module_import_storage_release(struct ast_Module *m) {
  (void)m;
}

XLANG_WEAK int32_t pipeline_module_import_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->imports);
  if (idx < 0)
    return -1;
  m->num_imports = sc->imports.len;
  return idx;
}

XLANG_WEAK void pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ImportEntry *ie;
  if (!bytes || len <= 0 || len > 255)
    return;
  ie = module_import_at(m, idx);
  if (!ie)
    return;
  ie->path_len = len;
  memset(ie->path, 0, sizeof(ie->path));
  memcpy(ie->path, bytes, (size_t)len);
}

XLANG_WEAK int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->path_len : 0;
}

XLANG_WEAK void pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap) {
  ImportEntry *ie;
  int32_t n;
  if (!dst || dst_cap <= 0)
    return;
  ie = module_import_at(m, idx);
  if (!ie) {
    dst[0] = 0;
    return;
  }
  n = ie->path_len;
  if (n >= dst_cap)
    n = dst_cap - 1;
  if (n > 0)
    memcpy(dst, ie->path, (size_t)n);
  dst[n] = 0;
}

XLANG_WEAK uint8_t pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ImportEntry *ie;
  if (off < 0)
    return 0;
  ie = module_import_at(m, idx);
  if (!ie || off >= ie->path_len || off >= 256)
    return 0;
  return ie->path[off];
}

XLANG_WEAK void pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind) {
  ImportEntry *ie = module_import_at(m, idx);
  if (ie)
    ie->kind = kind;
}

XLANG_WEAK int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->kind : 0;
}

XLANG_WEAK void pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ImportEntry *ie;
  /* wave584 Cap residual: binding content ≤127 (ImportEntry.binding_name[128]). */
  if (!bytes || len <= 0 || len > 127)
    return;
  ie = module_import_at(m, idx);
  if (!ie)
    return;
  ie->binding_name_len = len;
  memset(ie->binding_name, 0, sizeof(ie->binding_name));
  memcpy(ie->binding_name, bytes, (size_t)len);
}

XLANG_WEAK int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->binding_name_len : 0;
}

XLANG_WEAK uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ImportEntry *ie;
  /* wave584 Cap residual: off bound 64→128 (binding_name[128]). */
  if (off < 0 || off >= 128)
    return 0;
  ie = module_import_at(m, idx);
  if (!ie || off >= ie->binding_name_len)
    return 0;
  return ie->binding_name[off];
}

XLANG_WEAK void pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n) {
  ImportEntry *ie = module_import_at(m, idx);
  if (ie)
    ie->select_count = n;
}

/** 向 import 槽追加一条 select 名称（动态 grow，无 8 条上限）。 */
XLANG_WEAK int32_t pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  uint8_t *row;
  int32_t *pl;
  int32_t vi;
  int32_t n;
  if (!m || !bytes || len <= 0 || idx < 0 || !(sc = module_sidecar_get(m, 1)) || !(ie = module_import_at(m, idx)))
    return -1;
  if (ie->select_count == 0)
    ie->select_base = sc->import_select_name_rows.len;
  vi = grow_vec_push(&sc->import_select_name_rows);
  if (vi < 0 || grow_vec_push(&sc->import_select_name_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->import_select_name_rows, vi);
  pl = (int32_t *)grow_vec_at(&sc->import_select_name_lens, vi);
  if (!row || !pl)
    return -1;
  n = len > 127 ? 127 : len;
  /* wave584: select row is 128 bytes (was 64; prior memcpy of n≤127 overflowed). */
  memset(row, 0, 128);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
  ie->select_count++;
  return ie->select_count - 1;
}

XLANG_WEAK int32_t pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->select_count : 0;
}

XLANG_WEAK void pipeline_module_import_set_select_name(struct ast_Module *m, int32_t idx, int32_t sel, uint8_t *bytes,
                                            int32_t len) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  uint8_t *row;
  int32_t *pl;
  int32_t abs;
  int32_t n;
  if (!m || !bytes || len <= 0 || sel < 0 || !(sc = module_sidecar_get(m, 1)) || !(ie = module_import_at(m, idx)))
    return;
  while (ie->select_count <= sel) {
    if (pipeline_module_import_append_select_name(m, idx, bytes, len) < 0)
      return;
    if (sel < ie->select_count - 1)
      return;
  }
  abs = ie->select_base + sel;
  row = (uint8_t *)grow_vec_at(&sc->import_select_name_rows, abs);
  pl = (int32_t *)grow_vec_at(&sc->import_select_name_lens, abs);
  if (!row || !pl)
    return;
  n = len > 127 ? 127 : len;
  /* wave584: select row is 128 bytes. */
  memset(row, 0, 128);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
}

XLANG_WEAK int32_t pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  int32_t *pl;
  int32_t abs;
  if (!m || sel < 0 || !(sc = module_sidecar_get(m, 0)) || !(ie = module_import_at(m, idx)))
    return 0;
  if (sel >= ie->select_count)
    return 0;
  abs = ie->select_base + sel;
  pl = (int32_t *)grow_vec_at(&sc->import_select_name_lens, abs);
  return pl ? *pl : 0;
}

XLANG_WEAK uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  uint8_t *row;
  int32_t abs;
  int32_t nlen;
  if (!m || sel < 0 || off < 0 || !(sc = module_sidecar_get(m, 0)) || !(ie = module_import_at(m, idx)))
    return 0;
  if (sel >= ie->select_count)
    return 0;
  abs = ie->select_base + sel;
  row = (uint8_t *)grow_vec_at(&sc->import_select_name_rows, abs);
  nlen = pipeline_module_import_select_name_len(m, idx, sel);
  /* wave584 Cap residual: off bound 64→128 (select row[128]). */
  if (!row || off >= nlen || off >= 128)
    return 0;
  return row[off];
}
