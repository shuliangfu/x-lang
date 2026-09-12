/*
 * Strong overlay of xlang_preprocess_raw_to_malloc_impl (heap scratch).
 * G.7: body matches runtime_pipeline_abi.x (wave PP002 heap) + seed cold twin.
 * Product hybrid keeps the mega symbol WEAK; this TU is strong and must
 * first-wins ld -r over it (Darwin mega -E hang-prone).
 * PipelineDepCtx embed stays 4MiB (pin layout).
 * PLATFORM: SHARED — LINUX gold · MACOS co-path.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern int32_t preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out, int32_t out_cap);
extern void preprocess_define_reset(void);
extern int preprocess_define_add(const uint8_t *name);
extern int32_t preprocess_if_stack_len(void);
extern void xlang_ptr_slot_set(uint8_t *arr, int32_t i, uint8_t *p);
extern void xlang_size_slot_set(uint8_t *arr, int32_t i, int64_t v);
extern uint8_t *xlang_ptr_slot_get(uint8_t *arr, int32_t i);
extern void pipeline_diag_preprocess_fail(const uint8_t *path);
extern void pipeline_diag_preprocess_alloc_fail(const uint8_t *path, const uint8_t *what);
extern void pipeline_diag_preprocess_directive_code(const uint8_t *path, int32_t n);
extern void pipeline_diag_preprocess_unclosed_if(const uint8_t *path);

int xlang_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag)
{
    int di;
    if (out_src)
        xlang_ptr_slot_set((uint8_t *)out_src, 0, 0);
    if (out_src_len)
        xlang_size_slot_set((uint8_t *)out_src_len, 0, 0);
    if ((int64_t)raw_len < 0)
        return -1;
    if (raw_len > (size_t)INT32_MAX) {
        if (emit_diag)
            pipeline_diag_preprocess_fail((const uint8_t *)path_diag);
        return -1;
    }
    int32_t need = (int32_t)raw_len;
    int32_t buf_cap = 4194304;
    if (need > buf_cap)
        buf_cap = need;
    uint8_t *scratch = (uint8_t *)malloc((size_t)buf_cap);
    if (!scratch) {
        if (emit_diag)
            pipeline_diag_preprocess_alloc_fail((const uint8_t *)path_diag, (const uint8_t *)"scratch buffer");
        return -1;
    }
    preprocess_define_reset();
    for (di = 0; di < ndefines; di++) {
        uint8_t *dname = 0;
        if (defines)
            dname = xlang_ptr_slot_get((uint8_t *)defines, di);
        if (dname)
            preprocess_define_add(dname);
    }
    int32_t n = preprocess_x_buf(raw, (ptrdiff_t)raw_len, scratch, buf_cap);
    if (n < 0) {
        free(scratch);
        if (emit_diag) {
            if (n <= -2)
                pipeline_diag_preprocess_directive_code((const uint8_t *)path_diag, n);
            else if (preprocess_if_stack_len() != 0)
                pipeline_diag_preprocess_unclosed_if((const uint8_t *)path_diag);
            else
                pipeline_diag_preprocess_fail((const uint8_t *)path_diag);
        }
        return -1;
    }
    if (preprocess_if_stack_len() != 0) {
        free(scratch);
        if (emit_diag)
            pipeline_diag_preprocess_unclosed_if((const uint8_t *)path_diag);
        return -1;
    }
    char *dup = (char *)malloc((size_t)n + 1);
    if (!dup) {
        free(scratch);
        if (emit_diag)
            pipeline_diag_preprocess_alloc_fail((const uint8_t *)path_diag, (const uint8_t *)"output buffer");
        return -1;
    }
    memcpy(dup, scratch, (size_t)n);
    dup[n] = '\0';
    free(scratch);
    if (out_src)
        xlang_ptr_slot_set((uint8_t *)out_src, 0, (uint8_t *)dup);
    if (out_src_len)
        xlang_size_slot_set((uint8_t *)out_src_len, 0, (int64_t)n);
    return 0;
}
