/* PLATFORM: SHARED — pure-asm formal vehicle for std/runtime (class-batch 2).
 *
 * Why C face: mod.x monofile co-emits panic_hook_collect / bare abort wrappers that
 * leave U runtime_abort / runtime_crash_evidence_collect_c without runtime.x leaf
 * faces in the same TU. Product body stays in mod.x + runtime.x (C path / glue).
 * This vehicle only exports std_runtime_ready (and light diag faces) for pure-asm.
 *
 * G.7: single formal vehicle for pure-asm product link (std/runtime/runtime.o).
 * formal_mod kind=c_face.
 */
#include <stdint.h>

int32_t std_runtime_ready(void) {
  return 0;
}

int32_t std_runtime_diag_enabled(void) {
  return 1;
}

void std_runtime_diag_collect(int32_t code, int32_t detail) {
  (void)code;
  (void)detail;
}

/* tests/exc/panic_hook_align.x — pure-asm residual (run-runtime panic_hook). */
void std_runtime_panic_hook_collect(int32_t has_msg, int32_t msg_val) {
  (void)has_msg;
  (void)msg_val;
}
