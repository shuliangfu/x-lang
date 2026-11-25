/* Source-faithful arch_x86_64_enc_enc_store_rax_to_rbx_indirect twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s154 hello build residual: uninstrumented fast compile_rc=3221225477
 * (0xC0000005) in 0.359s, no output file, ~61-byte typool-garbled
 * emit-trace stderr. Debugger first-chance 0xC0000005 WRITE at typool
 * arch_x86_64_enc_enc_store_rax_to_rbx_indirect+0x2b (0x1403bd113),
 * function 0x1403bd0e8, t=0.664s. write=1, fault/rbx=0xffffffffc767d860,
 * rax=0x48, rdx=0x1 (live elem_sz), rbp=0x103f4140, rsp=0x103f3e30.
 * rbp-0x48d768e0 = 0xffffffffc767d860, matching the fault. typool did
 * lea [rbp-0x48d768e0] (disp32 0xb7289720) then mov qword [rbx], rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let b8: u8[3] = [72, 137, 3]` (0x48) was lifted to function entry
 * and first-stored before the elf_ctx null check, even though the live
 * elem_sz was 1 (the taken source path would use b1=[136, 3]). Saved
 * [rbp+8] caller is backend_enc_store_rax_to_rbx_indirect_arch+0xc6
 * (0x1403c928e / 0x1403c91c8).
 * Cousins typool scale4, scale8, shl_cl_eax, push_rbx, mid typool
 * scale1, typool store_rax_to_rbx_offset, typool uasb_put_i32, and
 * typool note were not folded unless a live pin proved one was the
 * first producer.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_store_rax_to_rbx_indirect(uint8_t *elf_ctx, int32_t elem_sz) {
  uint8_t b1[2];
  uint8_t b4[2];
  uint8_t b8[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  if (elem_sz == 1) {
    b1[0] = 136;
    b1[1] = 3;
    return x86_enc_bytes(elf_ctx, b1, 2);
  }
  if (elem_sz == 4) {
    b4[0] = 137;
    b4[1] = 3;
    return x86_enc_bytes(elf_ctx, b4, 2);
  }
  b8[0] = 72;
  b8[1] = 137;
  b8[2] = 3;
  return x86_enc_bytes(elf_ctx, b8, 3);
}
