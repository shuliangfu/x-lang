/* Source-faithful arch_x86_64_enc_enc_load_64_from_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s167 hello-build residual: uninstrumented compile_rc=3221225477
 * (0xC0000005) in 0.41s, no output. first-chance / DEBUG_ONLY_THIS_PROCESS
 * WRITE at typool arch_x86_64_enc_enc_load_64_from_rax+0x22 (0x1403bbd36),
 * function T 0x1403bbd14, t=0.779s. write=1,
 * fault/rbx=0xffffffffc7680120, rax=0x48, rbp=0x103f6a00,
 * rsp=0x103f6800. rbp-0x48d768e0 = 0xffffffffc7680120, matching
 * the fault. typool store is mov qword [rbx],rax
 * (bytes 48 89 83 00 00 00 00) then lea [rbp-0x48d768e0]
 * (disp32 0xb7289720). typool huge-frame dual-slot: source
 * `let ins: u8[3] = [72, 139, 0]` was lifted to function entry,
 * first store of 0x48 before the elf_ctx null check. This is not
 * already-folded pop_rbx / push_rbx / pop_rax / push_rax /
 * mov_rax_to_arg_reg / mov_arg_reg_to_rax / for_call_args /
 * glue_asm_overload_param_sig_count_c or other typool glue.
 * typool n_stack / typool lookup / typool note / typool
 * store-or-load / typool other enc_* cousins were not this
 * writer and were not folded. docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_load_64_from_rax(uint8_t *elf_ctx) {
  uint8_t ins[3];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 72;
  ins[1] = 139;
  ins[2] = 0;
  return x86_enc_bytes(elf_ctx, ins, 3);
}
