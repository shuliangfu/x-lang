/* Source-faithful user_asm_seed_bridge_uasb_zero twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 *
 * DIG s140 / s252 Soft Cap (PLATFORM: SHARED host-cc; PE fold WINDOWS):
 * tipU compiles `p[i] = 0` as lea &p + scale-8 index + 8-byte store
 * instead of `*(p + i) = (u8)0`. At i≈3 this zeros the caller's /
 * own return address → execute-at-0. s140 wrote this twin; s252 nails
 * tip land: after Soft Cap put_i32 (s251) Win bare reaches
 * seed_platform_coff_write_coff_o_to_buf which calls tipU uasb_zero
 * (sole T @ late PE text) → SEGV / RC=5 / 0-byte -o. Fold into
 * uasb_notes.o LINK_WINNERS (s252). docs-only .x, do not idx8.
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
