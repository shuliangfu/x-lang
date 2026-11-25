/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only — tip_l4_tip_pe_cg002_asm_codegen.
 *
 * Tip PE selfhost-emitted glue_module_func_overload_count_c drops both i++ and
 * c++ in the scan loop (Cap keeps both). After export_sym+dep_export twins open
 * the non-bare path, tip busy-loops here → hang → tip_after.o 0B / no `_main`.
 * Soft Cap Prefer / Cap aside / Win banned.
 *
 * Tip-local host-cc twin Cap-aligned with src/asm/backend_call_dispatch.x.
 */
#include <stddef.h>
#include <stdint.h>

extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t i);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t i, uint8_t *name, int32_t nlen);

int32_t glue_module_func_overload_count_c(void *m, uint8_t *name, int32_t nlen) {
  int32_t c;
  int32_t n;
  int32_t i;

  if (!m || !name || nlen <= 0)
    return 0;
  c = 0;
  n = pipeline_module_num_funcs(m);
  i = 0;
  while (i < n) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0) {
      if (pipeline_module_func_name_equal_at(m, i, name, nlen) != 0)
        c = c + 1;
    }
    i = i + 1;
  }
  return c;
}
