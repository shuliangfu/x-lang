/* Class CD cold twin. Included only under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
 * from compiler/seeds/runtime_pipeline_abi.from_x.c.
 * PLATFORM: SHARED — cold seed fallback. Not the product FROM_X rest.
 */
int32_t pipeline_read_file_stage_prep(void) {
    XlangRuntimeFileView raw_view;
    char *prep = NULL;
    size_t prep_len = 0;

    pipeline_rf_stage_prep_clear();

    if (runtime_read_file_view(pipeline_resolved_path_buf, &raw_view) != 0) {
        pipeline_diag_import_open_fail_once(NULL, pipeline_resolved_path_buf);
        return -1;
    }
    if (xlang_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
            pipeline_resolved_path_buf, NULL, 0) != 0) {
        runtime_release_file_view(&raw_view);
        return -1;
    }
    runtime_release_file_view(&raw_view);
    if (!prep) {
        pipeline_diag_import_preprocess_fail(NULL, pipeline_resolved_path_buf);
        return -1;
    }
    pipeline_rf_stage_prep_set(prep, prep_len);
    return 0;
}

/* G-02f-238 / wave66：hybrid pure owns commit_prep; cold twin under #ifndef FROM_X.
 * Pure orch: pure take (wave71) + pure loaded_import_commit_from_owned (wave72). PLATFORM: SHARED. */
int32_t pipeline_read_file_commit_prep(void) {
    char *prep = NULL;
    size_t prep_len = 0;

    if (pipeline_rf_stage_prep_take(&prep, &prep_len) != 0)
        return -1;
    return pipeline_loaded_import_commit_from_owned(prep, prep_len);
}

/* G-02f-238：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_read_file(void) {
    if (pipeline_read_file_stage_prep() != 0)
        return -1;
    if (pipeline_read_file_commit_prep() != 0)
        return -1;
    return 0;
}
