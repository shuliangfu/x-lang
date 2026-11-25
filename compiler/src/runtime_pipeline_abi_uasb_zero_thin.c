/* Source-faithful user_asm_seed_bridge_uasb_zero twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 * s140 hello build AV: WPO thin returned with intact ret 0x1403c3fd1
 * (asm_asm_codegen_elf_o+0x135); next call was
 * user_asm_seed_bridge_uasb_emit_deps. First-chance AV was execute-at-0
 * at RSP 0x103f8a50, 0x20 below the emit_deps frame after its shadow
 * sub, with a ~2KB zero run up the stack. typool uasb_zero compiled
 * source `p[i] = 0` as:
 *   lea &p, scale-8 index i, 8-byte store
 * instead of `*(p + i) = (u8)0`. At i=3 this zeros the function's own
 * return address, then ret to 0. Same typool u8[] scale-8 / shallow-lea
 * family as s136 rt_ab_step_prerun. docs-only .x, do not idx8.
 */
#include <stdint.h>

void user_asm_seed_bridge_uasb_zero(uint8_t *p, int32_t n) {
  int32_t i;
  i = 0;
  while (i < n) {
    p[i] = 0;
    i = i + 1;
  }
}
