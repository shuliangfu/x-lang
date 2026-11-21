/* Source-faithful user_asm_seed_bridge_uasb_put_str twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 * s141 hello build hang: after uasb_zero thin, emit_deps entered and
 * called typool uasb_put_str (trace path, cap=512). Live samples sat
 * in typool user_asm_seed_bridge_uasb_put_str (0x1403be2d8) at
 * +0x74 / +0x90 / +0x9c / +0xb8 for seconds, rbx often 2, rax 0 or
 * cap-1=0x1ff. typool compiled `let c: u8 = s[i]` as shallow-lea of
 * &s plus scale-8, so i=2 loaded the `at` slot (0 on the first
 * "asm emit trace..." call) as c. Source `if (c == 0) break;` was
 * typool-compiled as jmp to the loop test, without incrementing i or
 * pos, so pos < cap-1 stayed true and the scan never left. Same typool
 * break-as-jmp-to-head family as s137/s140 and same scale-8 / shallow-lea
 * family as s136/s141 uasb_zero. typool uasb_put_i32 was not on this
 * hang path and was not folded. docs-only .x, do not idx8.
 */
#include <stdint.h>

int32_t user_asm_seed_bridge_uasb_put_str(uint8_t *buf, int32_t at, int32_t cap, const uint8_t *s) {
  int32_t pos;
  int32_t i;
  uint8_t c;
  pos = at;
  if (s == 0) {
    return pos;
  }
  i = 0;
  while (pos < cap - 1) {
    c = s[i];
    if (c == 0) {
      break;
    }
    buf[pos] = c;
    pos = pos + 1;
    i = i + 1;
  }
  buf[pos] = 0;
  return pos;
}
