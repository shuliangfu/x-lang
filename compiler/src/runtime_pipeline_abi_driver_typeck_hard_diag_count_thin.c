/* Source-faithful driver_typeck_hard_diag_count / _note twin
 * (runtime_driver_abi_thin.x).
 *
 * DIG s137 / s250 Soft Cap (PLATFORM: SHARED host-cc; PE fold WINDOWS):
 * typool first-wins driver_typeck_hard_diag_count returns the BSS slot
 * POINTER, not p[0]:
 *   lea g_driver_typeck_hard_diag_n(%rip), %rax
 *   mov %rax, -0x48(%rbp)
 *   lea -0x48(%rbp), %rax
 *   mov (%rax), %rax
 * same shallow-lea-of-local-pointer class as driver_check_only_get (s239).
 * rt_ab_fail_on_hard_diag then sees count>0 with HARD_NOTE never entered,
 * unlinks -o, returns 1 (empty stdio). tipU note is the same class for
 * the increment path, so Soft Cap must own BOTH faces on one shared
 * i32[1] — otherwise real hard notes would write tipU Lxml while count
 * reads Soft Cap private BSS (false zero / false positive).
 * docs-only .x, do not idx8. g05 LINK_WINNERS + DRIVER_SEED first (s250).
 */
#include <stdint.h>

/* Shared Soft Cap counter — note and count must agree. */
static int32_t g_driver_typeck_hard_diag_n[1] = {0};

/* PLATFORM: SHARED — tipU / Soft Cap LSP gate for hard-diag notes. */
extern int32_t lsp_diag_get_enabled(void);

/**
 * Increment the hard typeck diagnostic counter (product path).
 * Skips when LSP diagnostics are enabled (exploratory / soft path).
 * Contract: saturates below INT32_MAX; never writes tipU Lxml BSS.
 */
void driver_typeck_hard_diag_note(void) {
  int32_t *p;
  if (lsp_diag_get_enabled() != 0) {
    return;
  }
  p = &g_driver_typeck_hard_diag_n[0];
  if (p[0] < 2147483647) {
    p[0] = p[0] + 1;
  }
}

/**
 * Return the hard typeck diagnostic count for this process.
 * Contract: returns p[0] (the integer), never the slot pointer.
 */
int32_t driver_typeck_hard_diag_count(void) {
  int32_t *p = &g_driver_typeck_hard_diag_n[0];
  return p[0];
}
