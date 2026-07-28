/* seeds/runtime_net_io_batch_fast_surface.from_x.c
 * G-02f-20 runtime_net_io_batch_fast R2 thin+rest surface — isomorphic with src/asm/runtime_net_io_batch_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + ld -r with rest (seeds/runtime_net_io_batch_fast.from_x.c)
 * Prove: full.x vs this surface → nm IDENTICAL (8 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest — .x provides 8 public API (3 weak io_* stubs + 3 stream batch + 2 UDP batch);
 *   _impl bridges (Linux recvmmsg/sendmmsg syscall) stay in rest seed
 * Cap residual: 2 _impl — net_udp_recv_many_buf_impl + net_udp_send_many_buf_impl
 *   (Linux-only recvmmsg/sendmmsg syscall, guarded by __linux__/__GLIBC__)
 * Note: doc_anchor ast_runtime_net_io_batch_fast_x_doc_anchor (non-no_mangle, xlang-c auto-prepends
 *   ast_ prefix; same pattern as string_fast/path_fast/net_sock_fast/net_addr_fast).
 * Logic: 8 functions = 3 weak io_* defaults (return -1) + 3 net_stream_*_batch_c (forward to io_*) +
 *   2 net_udp_*_many_buf_c (validate n∈[1,8] + non-null pointers, forward to _impl).
 * Regen: ./xlang-c -E ... runtime_net_io_batch_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t net_udp_recv_many_buf_impl(int32_t fd, uint8_t *bufs, int32_t n, uint32_t timeout_ms,
                                          int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports);
extern int32_t net_udp_send_many_buf_impl(int32_t fd, uint32_t *addrs, uint32_t *ports,
                                          uint8_t *bufs, int32_t n);

int32_t ast_runtime_net_io_batch_fast_x_doc_anchor(void) {
  return 0;
}

int32_t io_read_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1,
                      uint8_t *p2, uintptr_t l2, uint8_t *p3, uintptr_t l3,
                      int32_t n, uint32_t timeout_ms) {
  (void)fd; (void)p0; (void)l0; (void)p1; (void)l1;
  (void)p2; (void)l2; (void)p3; (void)l3; (void)n; (void)timeout_ms;
  return 0 - 1;
}

int32_t io_write_batch(int32_t fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1,
                       uint8_t *p2, uintptr_t l2, uint8_t *p3, uintptr_t l3,
                       int32_t n, uint32_t timeout_ms) {
  (void)fd; (void)p0; (void)l0; (void)p1; (void)l1;
  (void)p2; (void)l2; (void)p3; (void)l3; (void)n; (void)timeout_ms;
  return 0 - 1;
}

int32_t io_read_batch_provided(int32_t fd, int32_t n, uint32_t timeout_ms,
                               uint32_t *out_bids, uint32_t *out_lens) {
  (void)fd; (void)n; (void)timeout_ms; (void)out_bids; (void)out_lens;
  return 0 - 1;
}

int32_t net_stream_write_batch_c(int32_t stream_fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1,
                                 uint8_t *p2, uintptr_t l2, uint8_t *p3, uintptr_t l3,
                                 int32_t n, uint32_t timeout_ms) {
  return io_write_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

int32_t net_stream_read_batch_c(int32_t stream_fd, uint8_t *p0, uintptr_t l0, uint8_t *p1, uintptr_t l1,
                                uint8_t *p2, uintptr_t l2, uint8_t *p3, uintptr_t l3,
                                int32_t n, uint32_t timeout_ms) {
  return io_read_batch(stream_fd, p0, l0, p1, l1, p2, l2, p3, l3, n, timeout_ms);
}

int32_t net_stream_read_batch_provided_c(int32_t stream_fd, int32_t n, uint32_t timeout_ms,
                                         uint32_t *out_bids, uint32_t *out_lens) {
  return io_read_batch_provided(stream_fd, n, timeout_ms, out_bids, out_lens);
}

int32_t net_udp_recv_many_buf_c(int32_t fd, uint8_t *bufs, int32_t n, uint32_t timeout_ms,
                                int32_t *out_sizes, uint32_t *out_addrs, uint32_t *out_ports) {
  if (n <= 0) { return 0 - 1; }
  if (n > 8) { return 0 - 1; }
  if (bufs == 0) { return 0 - 1; }
  if (out_sizes == 0) { return 0 - 1; }
  if (out_addrs == 0) { return 0 - 1; }
  if (out_ports == 0) { return 0 - 1; }
  return net_udp_recv_many_buf_impl(fd, bufs, n, timeout_ms, out_sizes, out_addrs, out_ports);
}

int32_t net_udp_send_many_buf_c(int32_t fd, uint32_t *addrs, uint32_t *ports,
                                uint8_t *bufs, int32_t n) {
  if (n <= 0) { return 0 - 1; }
  if (n > 8) { return 0 - 1; }
  if (addrs == 0) { return 0 - 1; }
  if (ports == 0) { return 0 - 1; }
  if (bufs == 0) { return 0 - 1; }
  return net_udp_send_many_buf_impl(fd, addrs, ports, bufs, n);
}
