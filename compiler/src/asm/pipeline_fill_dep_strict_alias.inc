#include <stdint.h>

extern int32_t run_x_pipeline_fill_dep_import_path_c(uint8_t *module, uint8_t *ctx, int32_t dep_j);

int32_t run_x_pipeline_fill_dep_import_path(uint8_t *module, uint8_t *ctx, int32_t dep_j) {
  return run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j);
}
