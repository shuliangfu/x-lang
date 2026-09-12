/*
 * Strong overlay of pipeline_load_import_from_disk_c (import orch heap).
 * G.7: body matches runtime_pipeline_abi.x + seed impl_c cold twin.
 * Product hybrid keeps the mega symbol WEAK; this TU is strong and must
 * first-wins ld -r over it (Darwin mega -E hang-prone).
 * PipelineDepCtx embed stays 4MiB (pin layout). Reads the resolved path via
 * runtime_read_file_view (whole file) and preprocesses via
 * xlang_preprocess_raw_to_malloc (PP002 heap scratch).
 * PLATFORM: SHARED — LINUX gold · MACOS co-path.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "runtime_io_abi.h"

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t *import_path, int32_t path_len);
extern uint8_t *pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx);
extern int xlang_preprocess_raw_to_malloc(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *path,
    int32_t len);
extern void pipeline_bind_import_dep_buffers(struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern void *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_parse_into_buf(void *arena, void *module, uint8_t *buf, int32_t buf_len);

int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                         struct ast_PipelineDepCtx *ctx, int32_t import_idx)
{
    uint8_t path_buf[128];
    int32_t path_len;
    uint8_t *path;
    XlangRuntimeFileView raw_view;
    char *prep = NULL;
    size_t prep_len = 0;
    void *dep_arena;
    void *dep_module;
    int32_t parse_rc;

    if (!module || !arena || !ctx || import_idx < 0)
        return -1;
    memset(path_buf, 0, sizeof(path_buf));
    path_len = parser_copy_module_import_path64(module, import_idx, path_buf);
    if (pipeline_resolve_path_x(ctx, path_buf, path_len) != 0)
        return -7;
    memset(&raw_view, 0, sizeof(raw_view));
    path = pipeline_dep_ctx_path_buf_ptr(ctx);
    if (!path)
        return -8;
    if (runtime_read_file_view((const char *)path, &raw_view) != 0)
        return -8;
    if (xlang_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
            (const char *)path, NULL, 0) != 0) {
        runtime_release_file_view(&raw_view);
        return -9;
    }
    runtime_release_file_view(&raw_view);
    if (!prep || prep_len > (size_t)2147483647) {
        free(prep);
        return -9;
    }
    if (path_len > 0)
        pipeline_dep_ctx_set_import_path(ctx, import_idx, path_buf, path_len);
    pipeline_bind_import_dep_buffers(ctx, import_idx);
    dep_arena = pipeline_dep_ctx_arena_at(ctx, import_idx);
    dep_module = pipeline_dep_ctx_module_at(ctx, import_idx);
    parse_rc = pipeline_parse_into_buf(dep_arena, dep_module, (uint8_t *)prep, (int32_t)prep_len);
    free(prep);
    if (parse_rc != 0)
        return -10;
    return 0;
}
