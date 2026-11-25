/* Source-faithful driver_x_pipeline_skip_codegen_set twin
 * (runtime_driver_abi_thin.x / pabi_check_diag_emitted_flag_one.x).
 *
 * s211 DIG: tipU / thin first-wins at dig 0x1401018c4 stores v into the
 * stack local that holds the slot pointer (lea local; movq v, (local)),
 * never *p — BSS flag never updates. Paired with skip_codegen_get twin
 * (pointer-as-value get always returned 1 → CG004).
 *
 * Same class as s134 driver_check_only_set (host-cc twin). Only this
 * proven setter. docs-only .x, do not idx8.
 * PLATFORM: SHARED host-cc first-wins.
 */
#include <stdint.h>
extern int32_t *driver_x_pipeline_skip_codegen_flag_slot(void);
void driver_x_pipeline_skip_codegen_set(int32_t v) {
  int32_t *p = driver_x_pipeline_skip_codegen_flag_slot();
  if (p == 0) return;
  p[0] = v;
}
