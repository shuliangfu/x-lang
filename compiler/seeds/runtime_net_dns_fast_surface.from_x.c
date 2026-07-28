/* seeds/runtime_net_dns_fast_surface.from_x.c
 * G-02f-137 runtime_net_dns_fast R2 thin surface — isomorphic with src/asm/runtime_net_dns_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_NET_DNS_FAST_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (3 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 3 _impl_c bridges (net_dns_ai_addconfig_c_impl_c getaddrinfo hints +
 *   net_dns_map_gai_error_c_impl_c gai error map + net_dns_ensure_wsa_c_impl_c WSA init)
 *   in runtime_net_dns_fast.from_x.c rest
 * Note: extern names use _impl_c suffix to match seed definitions (root-cause fix in wave545)
 * Regen: ./xlang-c -E ... runtime_net_dns_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t net_dns_ai_addconfig_c_impl_c(void);
extern int32_t net_dns_map_gai_error_c_impl_c(int32_t err);
extern int32_t net_dns_ensure_wsa_c_impl_c(void);

int32_t ast_runtime_net_dns_fast_x_doc_anchor(void) { return 0; }

int32_t net_dns_ai_addconfig_c(void) {
  return net_dns_ai_addconfig_c_impl_c();
}

int32_t net_dns_map_gai_error_c(int32_t err) {
  return net_dns_map_gai_error_c_impl_c(err);
}

int32_t net_dns_ensure_wsa_c(void) {
  return net_dns_ensure_wsa_c_impl_c();
}
