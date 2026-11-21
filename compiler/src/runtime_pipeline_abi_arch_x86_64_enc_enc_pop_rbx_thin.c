/* Source-faithful arch_x86_64_enc_enc_pop_rbx twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s165 hello-build residual: uninstrumented compile_rc=3221225477
 * (0xC0000005) in 0.387s, no output. first-chance / DEBUG_ONLY_THIS_PROCESS
 * WRITE at typool arch_x86_64_enc_enc_pop_rbx+0x22 (0x1403bb1da),
 * function T 0x1403bb1b8, t=0.777s. write=1,
 * fault/rbx=0xffffffffc767def0, rax=0x5b, rbp=0x103f47d0,
 * rsp=0x103f45d0. rbp-0x48d768e0 = 0xffffffffc767def0, matching
 * the fault. typool prologue sub rsp,0x1f8 then lea [rbp-0x48d768e0]
 * (disp32 0xb7289720), mov rbx,rax, mov eax,0x5b, mov qword [rbx],rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[1] = [91]` was lifted to function entry, first store
 * of 0x5b before the elf_ctx null check. This is not already-folded
 * push_rbx (s165 thin first-wins 0x1400082c0, leftovers JMP'd) and
 * not already-folded pop_rax (first-wins 0x1400035a0). typool n_stack
 * / typool lookup / typool note / typool store-or-load / typool glue
 * / typool other enc_* cousins / typool for_call_args were not this
 * writer and were not folded. docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_pop_rbx(uint8_t *elf_ctx) {
  uint8_t ins[1];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 91;
  return x86_enc_bytes(elf_ctx, ins, 1);
}
