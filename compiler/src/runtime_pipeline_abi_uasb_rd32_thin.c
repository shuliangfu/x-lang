/* Source-faithful uasb_rd32 / uasb_wr32 twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 *
 * DIG s254 Soft Cap (PLATFORM: SHARED host-cc; PE fold WINDOWS):
 * After Soft Cap coff_machine_ok (s253), Win bare under ASLR still SEGV
 * in tipU uasb_rd32. GDB: ctx is a real 53MB ElfCodegenCtx and
 * ctx+UASB_NUM_RELOCS is readable from the debugger, but tipU computes
 * `p + off` after truncating p to 32 bits (rax ends as low32(p)+off,
 * e.g. 0x32e4104c), then movzbl faults. Same class as shallow-lea /
 * width loss. Host-cc keeps full pointer width. Fold into uasb_notes.o
 * LINK_WINNERS; win_patch dual-T folds same-TU tipU. docs-only .x.
 */
#include <stdint.h>

/**
 * Little-endian i32 read at byte offset.
 * Contract: p non-null; off may be large (ElfCodegenCtx field offsets).
 * @param p base pointer (full 64-bit)
 * @param off byte offset
 * @return loaded i32
 */
int32_t uasb_rd32(uint8_t *p, int32_t off) {
  uint8_t *q;
  int32_t b0;
  int32_t b1;
  int32_t b2;
  int32_t b3;

  q = p + (int64_t)off;
  b0 = ((int32_t)q[0]) & 255;
  b1 = ((int32_t)q[1]) & 255;
  b2 = ((int32_t)q[2]) & 255;
  b3 = ((int32_t)q[3]) & 255;
  return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
}

/**
 * Little-endian i32 write at byte offset.
 * #[no_mangle] product name is user_asm_seed_bridge_uasb_wr32 on tipU PE.
 * @param p base pointer (full 64-bit)
 * @param off byte offset
 * @param v value to store
 */
void user_asm_seed_bridge_uasb_wr32(uint8_t *p, int32_t off, int32_t v) {
  uint8_t *q;

  q = p + (int64_t)off;
  q[0] = (uint8_t)(v & 255);
  q[1] = (uint8_t)((v >> 8) & 255);
  q[2] = (uint8_t)((v >> 16) & 255);
  q[3] = (uint8_t)((v >> 24) & 255);
}
