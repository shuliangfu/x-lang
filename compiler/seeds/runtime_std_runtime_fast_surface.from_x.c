/* seeds/runtime_std_runtime_fast_surface.from_x.c
 * G-02f-143 runtime_std_runtime_fast R2 DIRECT surface — isomorphic with src/asm/runtime_std_runtime_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o (no rest; seed fully guarded)
 * Prove: full.x vs this seed → nm IDENTICAL (6 #[no_mangle], no doc_anchor)
 * Mode: DIRECT — .x provides all 6 functions (pure forwards to xlang_panic_/_crash_evidence_collect_c);
 *   seed has #ifndef XLANG_RUNTIME_STD_RUNTIME_FAST_FROM_X guard (all 6 skipped when PREFER_X_O)
 * Cap residual: none (DIRECT mode, pure forwards to extern bridges declared in .x)
 * Note: no doc_anchor function in .x — .x has no runtime_std_runtime_fast_x_doc_anchor definition.
 *   prove nm compares only #[no_mangle] T symbols; missing doc_anchor is OK (0 = 0).
 * Logic: 6 functions = 2 crash_evidence_collect (std + runtime alias) + 2 panic (std + runtime) +
 *   2 abort (std + runtime). All forward to xlang_panic_(0,0) or xlang_crash_evidence_collect_c.
 * Regen: ./xlang-c -E ... runtime_std_runtime_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void xlang_panic_(int32_t has_msg, intptr_t msg_val);
extern void xlang_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val);

void std_runtime_crash_evidence_collect(int32_t has_msg, int32_t msg_val) {
  xlang_crash_evidence_collect_c(has_msg, msg_val);
}

void runtime_crash_evidence_collect_c(int32_t has_msg, int32_t msg_val) {
  std_runtime_crash_evidence_collect(has_msg, msg_val);
}

void std_runtime_runtime_panic(void) {
  xlang_panic_(0, 0);
}

void runtime_panic(void) {
  xlang_panic_(0, 0);
}

void std_runtime_runtime_abort(void) {
  xlang_panic_(0, 0);
}

void runtime_abort(void) {
  xlang_panic_(0, 0);
}
