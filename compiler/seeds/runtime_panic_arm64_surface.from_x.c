/* seeds/runtime_panic_arm64_surface.from_x.c
 * G-02f-126 runtime_panic_arm64 R2 full surface — isomorphic with src/asm/runtime_panic_arm64.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_PANIC_ARM64_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (1 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 1 _impl OS bridge (xlang_crash_evidence_minimal_impl) in runtime_panic_arm64.from_x.c rest
 * Note: arm64 variant; mutually exclusive with runtime_panic (x86_64) at link time.
 * Regen: ./xlang-c -E ... runtime_panic_arm64.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void xlang_crash_evidence_minimal_impl(int32_t has_msg, int32_t msg_val);

int32_t runtime_panic_arm64_x_doc_anchor(void) { return 0; }

void xlang_crash_evidence_minimal(int32_t has_msg, int32_t msg_val) {
  xlang_crash_evidence_minimal_impl(has_msg, msg_val);
}
