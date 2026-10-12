/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
static char *pipeline_rf_stage_prep;
static size_t pipeline_rf_stage_prep_len;

/* wave66 / wave71 cold twin: free prior stage prep and clear BSS cells.
 * Pure stage_prep calls pure clear under hybrid. PLATFORM: SHARED. */
void pipeline_rf_stage_prep_clear(void) {
    free(pipeline_rf_stage_prep);
    pipeline_rf_stage_prep = NULL;
    pipeline_rf_stage_prep_len = 0;
}

/* wave66 / wave71 cold twin: store owned prep into stage BSS (does not free prior;
 * caller must clear first). prep may be null (stores empty). PLATFORM: SHARED. */
void pipeline_rf_stage_prep_set(char *prep, size_t prep_len) {
    pipeline_rf_stage_prep = prep;
    pipeline_rf_stage_prep_len = prep ? prep_len : 0;
}

/* wave66 / wave71 cold twin: move stage prep out without free (caller owns);
 * clear stage BSS. Returns 0 if prep non-null; -1 if empty. PLATFORM: SHARED. */
int32_t pipeline_rf_stage_prep_take(char **out_prep, size_t *out_len) {
    char *prep = pipeline_rf_stage_prep;
    size_t prep_len = pipeline_rf_stage_prep_len;
    pipeline_rf_stage_prep = NULL;
    pipeline_rf_stage_prep_len = 0;
    if (out_prep)
        *out_prep = prep;
    if (out_len)
        *out_len = prep ? prep_len : 0;
    if (!prep)
        return -1;
    return 0;
}
