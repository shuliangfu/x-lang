/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* G-02f-234：import path 拷到 C 字符串（供 .x merge pure） */
void xlang_module_import_path_cstr(void *module, int32_t idx, uint8_t *buf, int32_t cap) {
    uint8_t path_buf[128];
    int32_t k = 0;
    if (!buf || cap <= 0)
        return;
    buf[0] = 0;
    if (!module)
        return;
    parser_get_module_import_path(module, idx, path_buf);
    while (k < 64 && path_buf[k] && k + 1 < cap) {
        buf[k] = path_buf[k];
        k++;
    }
    buf[k] = 0;
}

void xlang_ptr_slot_set(void **arr, int32_t i, void *p) {
    if (!arr || i < 0)
        return;
    arr[i] = p;
}

/* G.7 expand set authority: load pointer array slot i (argv/paths). PLATFORM: SHARED. */
void *xlang_ptr_slot_get(void **arr, int32_t i) {
    if (!arr || i < 0)
        return NULL;
    return arr[i];
}

void xlang_i32_store(int32_t *p, int32_t v) {
    if (p)
        *p = v;
}
