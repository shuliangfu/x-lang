/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
/* G-02f-235：size_t 槽读写（.x merge deps pure） */
size_t xlang_size_slot_get(size_t *arr, int32_t i) {
    if (!arr || i < 0)
        return 0;
    return arr[i];
}

void xlang_size_slot_set(size_t *arr, int32_t i, size_t v) {
    if (!arr || i < 0)
        return;
    arr[i] = v;
}
