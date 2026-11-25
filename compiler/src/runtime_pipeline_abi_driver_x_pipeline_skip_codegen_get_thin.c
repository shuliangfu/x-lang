/* Source-faithful driver_x_pipeline_skip_codegen_get twin
 * (runtime_driver_abi_thin.x / pabi_check_diag_emitted_flag_one.x).
 *
 * s211 DIG: tipU / thin first-wins at dig 0x14010193c uses a 0x1b8 frame,
 * lea of the local that holds the slot pointer, then cmp ebx,0 on the
 * POINTER (never dereferences *p). BSS flag stays 0 but get always
 * returns 1 → pipeline skip_cg early-out → -x -E CG004 (empty C buf
 * with num_funcs>0). Aside xor-ret on get restored -E C emit.
 *
 * Same class as s133 driver_check_only_get (host-cc twin). Only this
 * proven getter; set twin is the paired fold. docs-only .x, do not idx8.
 * PLATFORM: SHARED host-cc first-wins.
 */
#include <stdint.h>
extern int32_t *driver_x_pipeline_skip_codegen_flag_slot(void);
int32_t driver_x_pipeline_skip_codegen_get(void) {
  int32_t *p = driver_x_pipeline_skip_codegen_flag_slot();
  if (p == 0) return 0;
  if (p[0] != 0) return 1;
  return 0;
}
