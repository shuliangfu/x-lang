/* seeds/pipeline_bootstrap_orchestration.from_x.c — G-02f-17 product TU
 * Logic still C until full .x port.
 */
/**
 * pipeline_bootstrap_orchestration.c — 实验 ./shux 链占位 TU
 *
 * run_x_pipeline_impl 已迁入 pipeline.x（build_asm/pipeline.o EMIT_HEAVY 真 emit）；
 * pipeline_run_x_pipeline_impl 由 pipeline_x.o / pipeline_run_bootstrap_trampoline.c 提供。
 */
#include <stddef.h>
#include <stdint.h>

#include "pipeline_glue_types.inc"

/** 避免空 TU 被链接器丢弃。 */
int32_t pipeline_bootstrap_orchestration_placeholder(void) {
  return 0;
}

#ifndef PIPELINE_BOOTSTRAP_ORCH_NO_PIPELINE_RUN_WRAPPER
/** weak 回退：未链 pipeline_x.o 真 emit 时返回 -1。 */
__attribute__((weak)) int32_t pipeline_run_x_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                                            uint8_t *source_data, size_t source_len,
                                                            struct codegen_CodegenOutBuf *out_buf,
                                                            struct ast_PipelineDepCtx *ctx) {
  (void)module;
  (void)arena;
  (void)source_data;
  (void)source_len;
  (void)out_buf;
  (void)ctx;
  return -1;
}
#endif
