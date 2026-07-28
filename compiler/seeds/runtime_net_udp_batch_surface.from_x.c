/* seeds/runtime_net_udp_batch_surface.from_x.c
 * G-02f-135 runtime_net_udp_batch R2 thin surface — isomorphic with src/asm/runtime_net_udp_batch.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_NET_UDP_BATCH_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (2 #[no_mangle] + 1 doc_anchor)
 * Cap residual: 2 _impl bridges (xlang_udp_batch_set_addr_port_impl sockaddr pack +
 *   xlang_udp_batch_poll_readable_impl poll/WSAPoll) in runtime_net_udp_batch.from_x.c rest
 * Regen: ./xlang-c -E ... runtime_net_udp_batch.x | filter DBG + polish prologue
 */
#include <stdint.h>

extern void xlang_udp_batch_set_addr_port_impl(uint8_t * sin, uint32_t addr_u32, uint32_t port_u32);
extern int32_t xlang_udp_batch_poll_readable_impl(int32_t fd, uint32_t timeout_ms);

int32_t runtime_net_udp_batch_x_doc_anchor(void) { return 0; }

void xlang_udp_batch_set_addr_port(uint8_t * sin, uint32_t addr_u32, uint32_t port_u32) {
  xlang_udp_batch_set_addr_port_impl(sin, addr_u32, port_u32);
}

int32_t xlang_udp_batch_poll_readable(int32_t fd, uint32_t timeout_ms) {
  return xlang_udp_batch_poll_readable_impl(fd, timeout_ms);
}
