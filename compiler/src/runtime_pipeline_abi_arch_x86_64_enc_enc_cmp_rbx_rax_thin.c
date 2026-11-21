/* Source-faithful arch_x86_64_enc_enc_cmp_rbx_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s146 hello build residual: uninstrumented 25s hang (empty RC, no
 * output file, 61-byte typool-garbled emit-trace stderr) is the typool
 * WRITE AV followed by ntdll SEH unwind. Debugger first-chance
 * 0xC0000005 WRITE at typool arch_x86_64_enc_enc_cmp_rbx_rax+0x22
 * (0x1403b5d1e), function 0x1403b5cfc, t=0.655s. write=1, fault/rbx=
 * 0xffffffffc767df20, rax=0x39, rbp=0x103f4800, rsp=0x103f4600.
 * rbp-0x48d768e0 = 0xffffffffc767df20, matching the fault. typool in a
 * small frame (sub rsp,0x1f8) did lea [rbp-0x48d768e0] (disp32
 * 0xb7289720) then mov qword [rbx], rax (bytes 48 89 83 00 00 00 00).
 * typool huge-frame dual-slot: source `let ins: u8[2] = [57, 195]`
 * (0x39,0xc3) was lifted to function entry, first store before the
 * elf_ctx null check. Saved [rbp+8] caller is
 * backend_enc_cmp_rbx_rax_arch+0xa8 (0x1403c7a20 / 0x1403c7978).
 * Prior path: emit_deps entered, typool uasb_put_i32 entered twice
 * and returned to emit_deps+0x166b / +0x17c3, codegen_ast_to_elf
 * entered, mov_rax_to_rbx thin entered 8+ times and returned to
 * backend_enc_mov_rax_to_rbx_arch+0xb5. Uninstrumented SuspendThread
 * poll (no DEBUG_ONLY_THIS_PROCESS) at t=1.003s already in
 * ntdll __C_specific_handler+0x18, then RtlVirtualUnwind2 with a
 * rapidly shrinking RSP, which is the 25s hang — SEH unwind after
 * this typool AV, not a parked typool loop and not put_i32.
 * Cousins arch_x86_64_enc_enc_cmp_rax_rbx, mov_rbx_to_rax,
 * mov_rax_to_arg_reg, and typool uasb_put_i32 were not the live first
 * producer and were not folded.
 * docs-only .x, do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_cmp_rbx_rax(uint8_t *elf_ctx) {
  uint8_t ins[2];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 57;
  ins[1] = 195;
  return x86_enc_bytes(elf_ctx, ins, 2);
}
