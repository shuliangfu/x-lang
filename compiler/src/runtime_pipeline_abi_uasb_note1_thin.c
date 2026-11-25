/* Source-faithful user_asm_seed_bridge_uasb_note1 twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 * s186 hello-build residual: check green; build AV 0xC0000005 in ~0.69s.
 * first-chance READ at user_asm_seed_bridge_uasb_note1+0x10e (0x1403d0772),
 * the epilogue `ret`, fault=0xffffffffffffffff. rbp/rbx held ASCII scraps
 * of the emit-trace message ("ntry mod" / "to_fle…"). typool placed
 * `let msg: u8[256]` at lea -0x28(%rbp) then called put_str(p,0,256,a);
 * writes grow upward and smash saved rbx/rbp/ret. Same class as note2
 * lea -0x38. Host-cc keeps a real 256-byte frame slot.
 * docs-only .x, do not idx8.
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED note formatting.
 */
#include <stdint.h>

extern int32_t user_asm_seed_bridge_uasb_put_str(uint8_t *buf, int32_t at, int32_t cap, const uint8_t *s);
extern int32_t user_asm_seed_bridge_uasb_put_i32(uint8_t *buf, int32_t at, int32_t cap, int32_t v);
extern void diag_report(uint8_t *file, int32_t line, int32_t col, const uint8_t *kind, const uint8_t *msg, uint8_t *detail);

void user_asm_seed_bridge_uasb_note1(uint8_t *a, int32_t n1) {
  uint8_t msg[256];
  int32_t at;
  static const uint8_t kind[] = "note";
  at = user_asm_seed_bridge_uasb_put_str(&msg[0], 0, 256, a);
  at = user_asm_seed_bridge_uasb_put_i32(&msg[0], at, 256, n1);
  diag_report(0, 0, 0, &kind[0], &msg[0], 0);
}
