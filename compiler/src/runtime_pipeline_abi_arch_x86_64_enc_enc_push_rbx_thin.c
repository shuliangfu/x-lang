/* Source-faithful arch_x86_64_enc_enc_push_rbx twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s164 hello-build residual: uninstrumented compile_rc=3221225477
 * (0xC0000005) in 0.404s, no output. first-chance / DEBUG_ONLY_THIS_PROCESS
 * WRITE at typool arch_x86_64_enc_enc_push_rbx+0x22 (0x1403bb0fe),
 * function T 0x1403bb0dc, t=0.761s. write=1,
 * fault/rbx=0xffffffffc767def0, rax=0x53, rbp=0x103f47d0,
 * rsp=0x103f45d0. rbp-0x48d768e0 = 0xffffffffc767def0, matching
 * the fault. typool prologue sub rsp,0x1f8 then lea [rbp-0x48d768e0]
 * (disp32 0xb7289720), mov rbx,rax, mov eax,0x53, mov qword [rbx],rax
 * (bytes 48 89 83 00 00 00 00). typool huge-frame dual-slot: source
 * `let ins: u8[1] = [83]` was lifted to function entry, first store
 * of 0x53 before the elf_ctx null check. This is not the already-folded
 * cousin push_rax (still first-wins 0x140003560) and not typool
 * mov_rax_to_arg_reg (s164 thin first-wins 0x140008100, leftovers
 * JMP'd). typool n_stack / typool lookup / typool note / typool
 * store-or-load / typool glue / typool other enc_* cousins / typool
 * for_call_args were not this writer and were not folded. docs-only
 * .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_push_rbx(uint8_t *elf_ctx) {
  uint8_t ins[1];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 83;
  return x86_enc_bytes(elf_ctx, ins, 1);
}
