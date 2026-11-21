/* Source-faithful driver_check_only_set twin (runtime_driver_abi_thin.x).
 * s134 typool set at 0x1400eb3b9 lea local p and 0x1400eb3c1 movq v into
 * that pointer slot, not p[0]; BSS 0x1404f90e0 stayed 0. Live check calls
 * set(rcx=1) then typool-smashed local; getter therefore still returned 0.
 * Only this proven setter; other same-class get/set cousins are not folded.
 * docs-only .x, do not idx8. Keep the existing getter thin.
 */
#include <stdint.h>
extern int32_t *driver_check_only_flag_slot(void);
void driver_check_only_set(int32_t v) {
  int32_t *p = driver_check_only_flag_slot();
  p[0] = v;
}
