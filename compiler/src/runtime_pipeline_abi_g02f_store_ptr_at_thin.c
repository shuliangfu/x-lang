/* Source-faithful g02f_store_ptr_at twin
 * (compiler/src/asm/backend_try_inline_dispatch.x).
 * s158 hello-build residual: first-chance 0xC0000005 execute (write=8,
 * DEP), RIP/fault 0x20 or 0x10 (varies), ins empty, rsp=0x103f37f0,
 * rax=0, rbx=0xed, rcx=8, rbp smashed to a small constant. Not a typool
 * huge-frame first-store WRITE. typool enc_label 99/99 returned,
 * inflight=0; IAT getenv / __imp___initenv unchanged.
 * Hardware write-watch on 0x103f37e8 after typool label n=99 returned:
 * typool g02f_store_ptr_at (0x1403ec6dc) at 0x1403ec816 wrote 0x20
 * into its own return slot (rbp+8 / 0x103f37e8), rax=0x20,
 * rbx=0x103f37e8, then wrote 0 to 0x103f37f0 at 0x1403ec855, then
 * ret to 0x20. Instruction family is typool scale-8 plus lea of the
 * local slot: source `p[off+i] = (a & 255) as u8` became
 * `lea rax, [rbp-0x10]; lea rax, [rax+idx*8]; mov qword [rax], byte`
 * so idx=3 lands on the saved return address. The varying RIP 0x10/0x20
 * is a typool-extracted pointer byte stored into that slot.
 * typool g02f_load_ptr_at was entered just before as the caller-side
 * cousin and was not folded. typool enc_label / enc_call / u32_le /
 * enc_jmp / note / uasb_put_i32 / store_offset were not the writer.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

void g02f_store_ptr_at(uint8_t *p, int32_t off, uint8_t *val) {
  uintptr_t a;
  if (p == 0) {
    return;
  }
  a = (uintptr_t)val;
  p[off + 0] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 1] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 2] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 3] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 4] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 5] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 6] = (uint8_t)(a & 255);
  a = a >> 8;
  p[off + 7] = (uint8_t)(a & 255);
}
