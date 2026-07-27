/* seeds/runtime_net_addr_fast_surface.from_x.c
 * G-02f-139 runtime_net_addr_fast R2 thin surface — isomorphic with src/asm/runtime_net_addr_fast.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + seed-rest (-DXLANG_RUNTIME_NET_ADDR_FAST_FROM_X) ld -r
 * Prove: full.x vs this seed → nm IDENTICAL (1 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest — .x provides 1 thin function (net_sockaddr_in_pack_addr_port_c);
 *   seed provides 4 rest functions (net_tcp_local/peer_addr_c + net_tcp/udp_set_addr_port_buf_c)
 * Cap residual: 4 rest functions in runtime_net_addr_fast.from_x.c (getsockname/getpeername +
 *   sockaddr_in field assignment with htonl/htons — asm codegen u16 store bug workaround)
 * Note: doc_anchor uses ast_ prefix — net_ #[no_mangle] triggers xlang compiler ast_ prefix
 *   (internal symbol conflict avoidance, discovered wave545)
 * Logic: .x uses manual byte parsing (no libc); seed uses struct cast + ntohl/ntohs (libc).
 *   Both are semantically equivalent.
 * Regen: ./xlang-c -E ... runtime_net_addr_fast.x | filter DBG + polish prologue
 */
#include <stdint.h>

int32_t ast_runtime_net_addr_fast_x_doc_anchor(void) { return 0; }

int64_t net_sockaddr_in_pack_addr_port_c(uint8_t *sin_ptr) {
  if (sin_ptr == 0) { return 0; }
  uint32_t p0 = (uint32_t)sin_ptr[2];
  uint32_t p1 = (uint32_t)sin_ptr[3];
  uint32_t port = p0 * 256 + p1;
  port = port & 65535u;
  uint32_t a0 = (uint32_t)sin_ptr[4];
  uint32_t a1 = (uint32_t)sin_ptr[5];
  uint32_t a2 = (uint32_t)sin_ptr[6];
  uint32_t a3 = (uint32_t)sin_ptr[7];
  uint32_t addr = a0 * 16777216u + a1 * 65536u + a2 * 256u + a3;
  int64_t hi = (int64_t)addr;
  int64_t lo = (int64_t)port;
  return hi * 4294967296LL + lo;
}
