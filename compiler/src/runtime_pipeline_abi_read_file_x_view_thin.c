/*
 * Strong overlay of pipeline_read_file_x (resolve_read embed fill).
 * G.7: body matches runtime_pipeline_abi.x + seed cold twin.
 * Product hybrid keeps the mega symbol WEAK; this TU is strong and must
 * first-wins ld -r over it (Darwin mega -E hang-prone).
 * PipelineDepCtx embed stays 4MiB (pin layout). Reads the resolved path via
 * runtime_read_file_view (whole file) and copies into loaded_buf only when
 * length <= 4194304; larger files fail honestly (no silent truncate).
 * Product import orch (pipeline_load_import_from_disk_c) does not use this
 * helper — it heap-reads + PP002 malloc.
 * PLATFORM: SHARED — LINUX gold · MACOS co-path.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "runtime_io_abi.h"

struct ast_PipelineDepCtx;

extern uint8_t *pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx);
extern uint8_t *pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, int64_t n);

int32_t pipeline_read_file_x(struct ast_PipelineDepCtx *ctx)
{
    uint8_t *path;
    uint8_t *buf;
    XlangRuntimeFileView raw_view;

    if (!ctx)
        return -1;
    path = pipeline_dep_ctx_path_buf_ptr(ctx);
    buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
    if (!path || !buf)
        return -1;
    memset(&raw_view, 0, sizeof(raw_view));
    if (runtime_read_file_view((const char *)path, &raw_view) != 0)
        return -1;
    if (raw_view.length > (size_t)4194304) {
        runtime_release_file_view(&raw_view);
        return -1;
    }
    if (raw_view.length > 0) {
        if (!raw_view.data) {
            runtime_release_file_view(&raw_view);
            return -1;
        }
        memcpy(buf, raw_view.data, raw_view.length);
    }
    pipeline_dep_ctx_set_loaded_len(ctx, (int64_t)raw_view.length);
    runtime_release_file_view(&raw_view);
    return 0;
}
