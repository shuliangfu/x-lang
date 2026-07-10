/* seeds/pipeline_fill_dep_strict_alias.from_x.c — G-02f-79 product cold-start TU
 * Promoted from compiler/src/asm/pipeline_fill_dep_strict_alias.inc (alias/stub; retired .inc).
 * Compile: cc -c seeds/pipeline_fill_dep_strict_alias.from_x.c  (or cc_inc_tu wrap).
 */
#include <stdint.h>

extern int32_t run_x_pipeline_fill_dep_import_path_c(uint8_t *module, uint8_t *ctx, int32_t dep_j);

int32_t run_x_pipeline_fill_dep_import_path(uint8_t *module, uint8_t *ctx, int32_t dep_j) {
  return run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j);
}
