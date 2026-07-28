/* seeds/runtime_test_fn_invoke_surface.from_x.c
 * G-02f-128 runtime_test_fn_invoke R2 thin surface — isomorphic with src/asm/runtime_test_fn_invoke.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_TEST_FN_INVOKE_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (1 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 1 _impl bridge (test_call_i32_void_impl_c, uintptr_t → fnptr cast + indirect call)
 *   in runtime_test_fn_invoke.from_x.c rest — Xlang cannot express C fnptr cast
 * Regen: ./xlang-c -E ... runtime_test_fn_invoke.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t test_call_i32_void_impl_c(uint64_t fn);

int32_t runtime_test_fn_invoke_x_doc_anchor(void) { return 0; }

int32_t test_call_i32_void_c(uint64_t fn) {
  if (fn == 0) { return (int32_t)(0 - 1); }
  return test_call_i32_void_impl_c(fn);
}
