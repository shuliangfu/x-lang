/* seeds/runtime_net_ipv6_fast_surface.from_x.c
 * G-02f-138 runtime_net_ipv6_fast R2 thin surface — isomorphic with src/asm/runtime_net_ipv6_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_NET_IPV6_FAST_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (5 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 5 _impl_c bridges (net_ipv6_ensure_wsa_c_impl_c WSA init +
 *   net_ipv6_close_socket_c_impl_c close/closesocket + net_ipv6_set_nonblock_c_impl_c fcntl/FIONBIO +
 *   net_ipv6_poll_writable_c_impl_c poll/WSAPoll + net_ipv6_connect_retry_ok_c_impl_c retry flag)
 *   in runtime_net_ipv6_fast.from_x.c rest — IPv6 socket OS calls
 * Note: extern names use _impl_c suffix to match seed definitions (root-cause fix in wave545)
 * Regen: ./xlang-c -E ... runtime_net_ipv6_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern int32_t net_ipv6_ensure_wsa_c_impl_c(void);
extern int32_t net_ipv6_close_socket_c_impl_c(int32_t fd);
extern int32_t net_ipv6_set_nonblock_c_impl_c(int32_t fd);
extern int32_t net_ipv6_poll_writable_c_impl_c(int32_t fd, uint32_t timeout_ms);
extern int32_t net_ipv6_connect_retry_ok_c_impl_c(void);

int32_t ast_runtime_net_ipv6_fast_x_doc_anchor(void) { return 0; }

int32_t net_ipv6_ensure_wsa_c(void) {
  return net_ipv6_ensure_wsa_c_impl_c();
}

int32_t net_ipv6_close_socket_c(int32_t fd) {
  return net_ipv6_close_socket_c_impl_c(fd);
}

int32_t net_ipv6_set_nonblock_c(int32_t fd) {
  return net_ipv6_set_nonblock_c_impl_c(fd);
}

int32_t net_ipv6_poll_writable_c(int32_t fd, uint32_t timeout_ms) {
  return net_ipv6_poll_writable_c_impl_c(fd, timeout_ms);
}

int32_t net_ipv6_connect_retry_ok_c(void) {
  return net_ipv6_connect_retry_ok_c_impl_c();
}
