/* Source-faithful *flag accessors for check-diag-emitted.
 * typool leftover get/note/reset lea the local pointer slot and
 * store/load 1/0 there, not at *flag. flag_slot itself is correct
 * (lea of BSS) and is not folded. Other flag-slot siblings are not. */
#include <stdint.h>
extern int32_t *driver_check_diag_emitted_flag_slot(void);
void driver_check_diag_emitted_note(void) {
  int32_t *p = driver_check_diag_emitted_flag_slot();
  p[0] = 1;
}
void driver_check_diag_emitted_reset(void) {
  int32_t *p = driver_check_diag_emitted_flag_slot();
  p[0] = 0;
}
int32_t driver_check_diag_emitted_get(void) {
  int32_t *p = driver_check_diag_emitted_flag_slot();
  if (p[0] != 0) {
    return 1;
  }
  return 0;
}
