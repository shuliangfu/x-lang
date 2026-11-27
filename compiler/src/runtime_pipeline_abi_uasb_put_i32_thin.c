/* Source-faithful user_asm_seed_bridge_uasb_put_i32 twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 *
 * DIG s251 Soft Cap (PLATFORM: SHARED host-cc; PE fold WINDOWS):
 * s214 Soft Cap note1/note2/put_str first-wins, but tipU put_i32 stayed
 * sole for the decimal append. Soft Cap note1 calls
 * user_asm_seed_bridge_uasb_put_i32 after put_str; typool put_i32 uses
 * an undersized/shallow frame and smashes the Soft Cap note1 msg slot
 * (emit trace shows `funcs=<NUL> --> <path>:0:0`). After coff_write the
 * smashed frame SEGV / RC=5 with a 0-byte -o. Same undersized-local
 * class as s214 note1/note2. Host-cc keeps a real tmp[12] and writes
 * decimal digits. docs-only .x, do not idx8. g05 folds into uasb_notes.o
 * LINK_WINNERS (s251).
 */
#include <stdint.h>

/**
 * Append decimal text of v into buf at `at` (NUL-terminated).
 * Contract: never writes past cap-1; returns new position.
 * @param buf output buffer
 * @param at start index
 * @param cap buffer capacity
 * @param v signed value to print
 * @return new write position
 */
int32_t user_asm_seed_bridge_uasb_put_i32(uint8_t *buf, int32_t at, int32_t cap, int32_t v) {
  int32_t pos;
  uint8_t tmp[12];
  int32_t n;
  int32_t neg;
  int64_t x;
  int64_t d;

  pos = at;
  n = 0;
  neg = 0;
  x = (int64_t)v;
  if (x < 0) {
    neg = 1;
    x = 0 - x;
  }
  if (x == 0) {
    tmp[0] = 48;
    n = 1;
  }
  while (x > 0 && n < 12) {
    d = x % 10;
    tmp[n] = (uint8_t)(48 + (int32_t)d);
    n = n + 1;
    x = x / 10;
  }
  if (neg != 0 && pos < cap - 1) {
    buf[pos] = 45;
    pos = pos + 1;
  }
  while (n > 0 && pos < cap - 1) {
    n = n - 1;
    buf[pos] = tmp[n];
    pos = pos + 1;
  }
  if (pos < cap) {
    buf[pos] = 0;
  }
  return pos;
}
