/* Generated from src/lsp/lsp_diag_pipeline_sizes.x (G-02f-1).
 * Regen: ./xlang-c src/lsp/lsp_diag_pipeline_sizes.x -E > seeds/lsp_diag_pipeline_sizes.from_x.c
 * Product G05 links this as src/lsp/lsp_diag_pipeline_sizes_nostub.o (no handwritten .inc).
 */
#include <stdint.h>
#include <stddef.h>
#ifndef XLANG_LSP_DIAG_PIPELINE_SIZES_FROM_X
/* G-02f-20 thin+rest：完整模式下函数由 seed 提供；rest 模式下由 .x thin 提供 */
size_t lsp_diag_pipeline_sizeof_arena(void) {
  return 16;
}
size_t lsp_diag_pipeline_sizeof_module(void) {
  return 40;
}
size_t lsp_diag_pipeline_sizeof_dep_ctx(void) {
  return 1368;
}
#endif /* XLANG_LSP_DIAG_PIPELINE_SIZES_FROM_X */
