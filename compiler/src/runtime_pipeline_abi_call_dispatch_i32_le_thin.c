/*
 * Host-gcc twin of call_dispatch_load_i32_le / call_dispatch_store_i32_le.
 * Root (s41): typool bodies use scale-8 (lea (%rax,%rbx,8)) instead of
 *   byte index into AsmFuncCtx. w1545_win_mid_ret_call then sets
 *   pend_off = garbage_next_offset+16 (~0x1d5cc3a0), and typool
 *   w1545_pend_rcx_emit encodes lea rcx,[rbp-pend_off] into product main
 *   (48 8D 8D) for Option_ptr_u8 16-byte sret → SIGSEGV in some_ptr_u8.
 * Gdb: mid_ret cur=0x1d5cc390; product lea -0x1d5cc3a0(%rbp),%rcx.
 * Class: wrong slot entirely (not huge-lea of a sane slot).
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

int32_t call_dispatch_load_i32_le(uint8_t *p, int32_t off) {
  int32_t m;
  int32_t a;
  if (p == 0) {
    return 0;
  }
  m = 256;
  a = (int32_t)p[off];
  a = a + (int32_t)p[off + 1] * m;
  a = a + (int32_t)p[off + 2] * (m * m);
  a = a + (int32_t)p[off + 3] * (m * m * m);
  return a;
}

void call_dispatch_store_i32_le(uint8_t *p, int32_t off, int32_t v) {
  uint32_t u;
  if (p == 0) {
    return;
  }
  u = (uint32_t)v;
  p[off] = (uint8_t)(u & 255);
  p[off + 1] = (uint8_t)((u / 256) & 255);
  p[off + 2] = (uint8_t)((u / 65536) & 255);
  p[off + 3] = (uint8_t)((u / 16777216) & 255);
}
