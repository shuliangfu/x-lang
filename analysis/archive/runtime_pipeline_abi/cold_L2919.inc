/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
void pipeline_resolve_path_into_static(const char *path_c) {
    const char *lib_roots[1] = { "." };
    if (!path_c)
        return;
    xlang_resolve_import_file_path_multi(lib_roots, 1, pipeline_entry_dir, path_c, pipeline_resolved_path_buf,
        sizeof(pipeline_resolved_path_buf));
}

/* Cold-only _impl: pure resolve_path inlines path copy + pure into_static under hybrid. */
int32_t pipeline_resolve_path_impl(const uint8_t *path_ptr, int32_t path_len) {
    char path_c[65];
    size_t k = 0;
    if (path_len <= 0 || path_len > 64)
        path_len = 64;
    while (k < (size_t)path_len && path_ptr[k]) {
        path_c[k] = (char)path_ptr[k];
        k++;
    }
    path_c[k] = '\0';
    pipeline_resolve_path_into_static(path_c);
    return 0;
}

/* G-02f-237：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_resolve_path(const uint8_t *path_ptr, int32_t path_len) {
  if (path_ptr == NULL) {
    return -1;
  }
  {
    return pipeline_resolve_path_impl(path_ptr, path_len);
  }
  return -1;
}
