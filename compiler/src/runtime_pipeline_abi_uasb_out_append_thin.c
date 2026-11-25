/* Source-faithful user_asm_seed_bridge_uasb_out_append twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 * s187 hello-build residual: check green; build AV 0xC0000005 in ~0.77s.
 * first-chance WRITE at user_asm_seed_bridge_uasb_out_append+0x163
 * (0x1403d1157), T 0x1403d0ff4, FN already at main (past note1 smash).
 * write=1, fault/rbx=0x10400000. typool compiled
 * `out[UASB_OUT_DATA_OFF + len] = c` as lea (%rax,%rbx,8) scale-8 then
 * qword store — same shallow-lea / scale-8 family as uasb_put_str (s141)
 * and uasb_zero. Inlines LE rd32/wr32 so typool wr32 byte stores cannot
 * re-smash the length slot.
 * docs-only .x, do not idx8.
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED COFF outbuf helper.
 */
#include <stdint.h>

enum {
  UASB_OUT_CAP = 9437184,
  UASB_OUT_LEN_OFF = 0,
  UASB_OUT_DATA_OFF = 4
};

static int32_t uasb_rd32_le(uint8_t *p, int32_t off) {
  uint8_t *q = p + off;
  return (int32_t)q[0] | ((int32_t)q[1] << 8) | ((int32_t)q[2] << 16) | ((int32_t)q[3] << 24);
}

static void uasb_wr32_le(uint8_t *p, int32_t off, int32_t v) {
  uint8_t *q = p + off;
  q[0] = (uint8_t)(v & 255);
  q[1] = (uint8_t)((v >> 8) & 255);
  q[2] = (uint8_t)((v >> 16) & 255);
  q[3] = (uint8_t)((v >> 24) & 255);
}

int32_t user_asm_seed_bridge_uasb_out_append(uint8_t *out, uint8_t *ptr, int32_t n) {
  int32_t len;
  int32_t i;
  if (n < 0) {
    return 0 - 1;
  }
  if (n > 0 && ptr == 0) {
    return 0 - 1;
  }
  len = uasb_rd32_le(out, UASB_OUT_LEN_OFF);
  i = 0;
  while (i < n && len < UASB_OUT_CAP) {
    out[UASB_OUT_DATA_OFF + len] = ptr[i];
    len = len + 1;
    i = i + 1;
  }
  uasb_wr32_le(out, UASB_OUT_LEN_OFF, len);
  if (i < n) {
    return 0 - 1;
  }
  return 0;
}
