/* Source-faithful driver_typeck_hard_diag_count twin (runtime_driver_abi_thin.x).
 * s137 build RC=1 in 0.028s with empty stdio and no -o file: prerun
 * returned 0 (WAITS/NEXT/PARSE_ONLY all 0) then typool
 * rt_ab_fail_on_hard_diag called driver_typeck_hard_diag_count at
 * 0x1400ed470, which returned BSS slot pointer 0x1404fa0e8, not p[0].
 * FAIL_DIAG therefore took the >0 path, unlinked the output, returned 1.
 * HARD_NOTE was never entered; typool count does
 *   lea g_driver_typeck_hard_diag_n(%rip), %rax
 *   mov %rax, -0x48(%rbp)
 *   lea -0x48(%rbp), %rax
 *   mov (%rax), %rax
 * same shallow-lea-of-local-pointer class as driver_check_only_get.
 * No flag_slot export exists on this face, so the thin keeps the
 * source local i32[1] and returns p[0]. Note is same-class by
 * disassembly but was not entered and is not folded.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

static int32_t g_driver_typeck_hard_diag_n[1] = {0};

int32_t driver_typeck_hard_diag_count(void) {
  int32_t *p = &g_driver_typeck_hard_diag_n[0];
  return p[0];
}
