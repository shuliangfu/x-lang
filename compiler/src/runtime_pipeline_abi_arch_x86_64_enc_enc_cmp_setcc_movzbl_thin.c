/* Source-faithful arch_x86_64_enc_enc_cmp_setcc_movzbl twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s147 hello build residual: uninstrumented 25s timeout (empty RC, no
 * output file, 61-byte typool-garbled emit-trace stderr) is again a
 * typool WRITE AV followed by ntdll SEH unwind. Debugger first-chance
 * 0xC0000005 WRITE at typool arch_x86_64_enc_enc_cmp_setcc_movzbl+0x34
 * (0x1403b7d20), function 0x1403b7cec, t=0.666s. write=1, fault/rbx=
 * 0xffffffffc767de90, rax=0xf, rbp=0x103f4770, rsp=0x103f44e0, rdx=0x2
 * (live cc). rbp-0x48d768e0 = 0xffffffffc767de90, matching the fault.
 * typool did lea [rbp-0x48d768e0] (disp32 0xb7289720) then
 * mov qword [rbx], rax (bytes 48 89 83 00 00 00 00). typool huge-frame
 * dual-slot: source `let s: u8[3] = [15, 0, 192]` was lifted to
 * function entry, first store of 0x0f before the elf_ctx null check.
 * Saved [rbp+8] caller is backend_enc_cmp_setcc_movzbl_arch+0xd2
 * (0x1403c850e / 0x1403c843c). HW exec BPs: s147 cmp_rbx_rax thin at
 * 0x140003340 entered once and would return to
 * backend_enc_cmp_rbx_rax_arch+0xa8; mid typool cmp_rbx_rax 0x1403b5d3c
 * was not entered (last-only leftover not on the live path); typool
 * cmp_rax_rbx 0x1403b5df0 was not entered; typool cmp_setcc_movzbl
 * entered once from the same arch wrapper then AV at +0x34.
 * Cousins cmp_rax_rbx, mov_rbx_to_rax, mov_rax_to_arg_reg, typool
 * uasb_put_i32, and typool note were not the live first producer and
 * were not folded. Mid typool cmp_rbx_rax was not JMP-patched.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_cmp_setcc_movzbl(uint8_t *elf_ctx, int32_t cc) {
  uint8_t op;
  uint8_t s[3];
  uint8_t m[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  op = 148;
  if (cc == 1) {
    op = 149;
  } else if (cc == 2) {
    op = 156;
  } else if (cc == 3) {
    op = 158;
  } else if (cc == 4) {
    op = 159;
  } else if (cc == 5) {
    op = 157;
  } else if (cc == 6) {
    op = 146;
  } else if (cc == 7) {
    op = 150;
  } else if (cc == 8) {
    op = 151;
  } else if (cc == 9) {
    op = 147;
  }
  s[0] = 15;
  s[1] = 0;
  s[2] = 192;
  s[1] = op;
  if (x86_enc_bytes(elf_ctx, s, 3) != 0) {
    return 0 - 1;
  }
  m[0] = 15;
  m[1] = 182;
  m[2] = 192;
  return x86_enc_bytes(elf_ctx, m, 3);
}
