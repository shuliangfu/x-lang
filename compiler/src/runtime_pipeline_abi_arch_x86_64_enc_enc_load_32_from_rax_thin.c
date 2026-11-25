/* Source-faithful arch_x86_64_enc_enc_load_32_from_rax twin
 * (compiler/src/asm/backend_x86_64_enc_c.x).
 * s178 hello-build residual after s177 AS-over-foldable: soft check green,
 * build hangs in io_read_fixed → pipeline_asm_emit_index_elf_c →
 * glue_emit_index_load_arms_elf_c → backend_enc_load_i32_indirect_to_rax_arch
 * → arch_x86_64_enc_enc_load_32_from_rax @ 0x1403c7b00 (enc_c dual T).
 * first-chance WRITE at load_32+0x22 (0x1403c7b22), write=1,
 * fault=0xffffffffc767bfb0, rbp=0x103f2890, rsp=0x103f2690.
 * rbp-0x48d768e0 matches the fault. typool store is mov qword [rbx],rax
 * then lea [rbp-0x48d768e0] (disp32 0xb7289720). typool huge-frame
 * dual-slot: source `let ins: u8[2] = [139, 0]` lifted to entry, first
 * store of 0x8b before the elf_ctx null check. Cousin of already-folded
 * load_64_from_rax_thin (s167). Good dual T @ 0x1403e9fb0 (thin.x
 * append_u8) is not the call target from i32_indirect. docs-only .x,
 * do not idx8.
 */
#include <stdint.h>

extern int32_t x86_enc_bytes(uint8_t *elf_ctx, uint8_t *buf, int32_t n);

int32_t arch_x86_64_enc_enc_load_32_from_rax(uint8_t *elf_ctx) {
  uint8_t ins[2];
  if (elf_ctx == 0) {
    return 0 - 1;
  }
  ins[0] = 139;
  ins[1] = 0;
  return x86_enc_bytes(elf_ctx, ins, 2);
}
