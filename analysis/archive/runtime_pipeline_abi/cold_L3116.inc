/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
uint8_t *pipeline_loaded_import_data(void) {
    return pipeline_loaded_import_buf ? (uint8_t *)pipeline_loaded_import_buf : NULL;
}

size_t pipeline_loaded_import_len_get(void) {
    return pipeline_loaded_import_len;
}
