/* Source-faithful user_asm_seed_bridge_uasb_note2 twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 * Same typool undersized-msg class as note1 (s187): lea -0x38/%rbp-0x50
 * for `let msg: u8[256]` then put_str/put_i32 with cap=256 smash upward
 * through saved frame (corrupts string arg → put_str int-as-ptr AV).
 * s214 DIG: dig first-wins tipU note2 → AV on
 * `if (i == lit) { return ...; }` (first stmt return) after coff_write
 * note2; host-cc inject aside green. Tip-land via g05 LINK_WINNERS.
 * docs-only .x, do not idx8.
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED note formatting.
 */
#include <stdint.h>

extern int32_t user_asm_seed_bridge_uasb_put_str(uint8_t *buf, int32_t at, int32_t cap, const uint8_t *s);
extern int32_t user_asm_seed_bridge_uasb_put_i32(uint8_t *buf, int32_t at, int32_t cap, int32_t v);
extern void diag_report(uint8_t *file, int32_t line, int32_t col, const uint8_t *kind, const uint8_t *msg, uint8_t *detail);

void user_asm_seed_bridge_uasb_note2(uint8_t *a, int32_t n1, uint8_t *b, int32_t n2) {
  uint8_t msg[256];
  int32_t at;
  static const uint8_t kind[] = "note";
  at = user_asm_seed_bridge_uasb_put_str(&msg[0], 0, 256, a);
  at = user_asm_seed_bridge_uasb_put_i32(&msg[0], at, 256, n1);
  at = user_asm_seed_bridge_uasb_put_str(&msg[0], at, 256, b);
  at = user_asm_seed_bridge_uasb_put_i32(&msg[0], at, 256, n2);
  diag_report(0, 0, 0, &kind[0], &msg[0], 0);
}
