/* seeds/runtime_net_workers_surface.from_x.c
 * G-02f-129 runtime_net_workers R2 thin surface — isomorphic with src/asm/runtime_net_workers.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_NET_WORKERS_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (2 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 1 _impl bridge (xlang_net_worker_accept_entry_ptr_impl_c, returns fnptr as u64)
 *   in runtime_net_workers.from_x.c rest — Xlang cannot express void*(*)(void*) C ABI
 * Note: thread_set_affinity_self_c is a weak default (returns 0); strong override in std.thread
 * Regen: ./xlang-c -E ... runtime_net_workers.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern uint64_t xlang_net_worker_accept_entry_ptr_impl_c(void);

int32_t runtime_net_workers_x_doc_anchor(void) { return 0; }

int32_t thread_set_affinity_self_c(int32_t cpu_index) {
  /* Weak default: no-op success. Strong override in std.thread wins at link. */
  return 0;
}

uint64_t xlang_net_worker_accept_entry_ptr_c(void) {
  return xlang_net_worker_accept_entry_ptr_impl_c();
}
