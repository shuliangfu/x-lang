/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
int32_t pipeline_parse_into_bytes(void *arena, void *module, uint8_t *data, size_t len) {
    struct xlang_slice_uint8_t slice;
    struct parser_ParseIntoResult pr;
    if (!arena || !module || !data)
        return -1;
    slice.data = data;
    slice.length = len;
    parser_parse_into_init(module, arena);
    pr = parser_parse_into(arena, module, &slice);
    return pr.ok == 0 ? 0 : -1;
}

/* Cold-only _impl: pure loaded_import public inlines Cap residual data/len + pure parse_into_bytes. */
int32_t pipeline_parse_into_loaded_import_impl(void *arena, void *module) {
    uint8_t *data = pipeline_loaded_import_data();
    if (!data)
        return -1;
    return pipeline_parse_into_bytes(arena, module, data, pipeline_loaded_import_len_get());
}

/* G-02f-239：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_parse_into_loaded_import(void *arena, void *module) {
  if (arena == NULL) {
    return -1;
  }
  if (module == NULL) {
    return -1;
  }
  {
    return pipeline_parse_into_loaded_import_impl(arena, module);
  }
  return -1;
}
