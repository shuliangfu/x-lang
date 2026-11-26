/* Source-faithful driver_check_only_get twin (runtime_driver_abi_thin.x).
 * s133 T 0x1400eb4e1 lea local + 0x1400eb4e5 mov reloads slot pointer,
 * not p[0]; cmp at 0x1400eb4f0 sees 0x404f90e0 although slot i32 is 0.
 * DIG s239: same tipU still first-wins on Win tip after s238 argv Soft Caps;
 * false check_only=1 → post_parse clears use_asm_backend → emit_c hang.
 * Wire via g05 LINK_WINNERS + DRIVER_SEED + win_patch dual-T fold.
 * Only this proven getter; set/slot/quiet_ok/fallback are not folded.
 * docs-only .x, do not idx8. PLATFORM: SHARED host-cc. */
#include <stdint.h>
extern int32_t *driver_check_only_flag_slot(void);
int32_t driver_check_only_get(void) {
  int32_t *p = driver_check_only_flag_slot();
  if (p[0] != 0) return 1;
  return 0;
}
