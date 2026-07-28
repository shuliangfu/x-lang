/* seeds/runtime_process_argv_surface.from_x.c
 * G-02f-127 runtime_process_argv R2 thin surface — isomorphic with src/asm/runtime_process_argv.x
 * Product PREFER_X_O: XLANG_KEEP_C=1 xlang-c(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_PROCESS_ARGV_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (1 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 1 _impl OS bridge (xlang_process_argv_bind_from_crt_impl, macOS _NSGetArgc /
 *   Linux /proc/self/cmdline) in runtime_process_argv.from_x.c rest
 * Regen: ./xlang-c -E ... runtime_process_argv.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void xlang_process_argv_bind_from_crt_impl(void);

int32_t runtime_process_argv_x_doc_anchor(void) { return 0; }

void xlang_process_argv_bind_from_crt(void) {
  xlang_process_argv_bind_from_crt_impl();
}
