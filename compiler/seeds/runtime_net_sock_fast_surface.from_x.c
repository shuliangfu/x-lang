/* seeds/runtime_net_sock_fast_surface.from_x.c
 * G-02f-136 runtime_net_sock_fast R2 thin surface — isomorphic with src/asm/runtime_net_sock_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_NET_SOCK_FAST_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (2 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 2 _impl_c bridges (net_ensure_wsa_impl_c WSAStartup + net_wsa_ctor_impl_c
 *   constructor) in runtime_net_sock_fast.from_x.c rest — Windows Winsock init
 * Note: extern names use _impl_c suffix to match seed definitions (root-cause fix in wave545)
 * Regen: ./xlang-c -E ... runtime_net_sock_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void net_ensure_wsa_impl_c(void);
extern void net_wsa_ctor_impl_c(void);

int32_t ast_runtime_net_sock_fast_x_doc_anchor(void) { return 0; }

void net_ensure_wsa(void) {
  net_ensure_wsa_impl_c();
}

void net_wsa_ctor(void) {
  net_wsa_ctor_impl_c();
}
