/*
 * DIG s223: host-cc twins for asg_thin_* helpers.
 *
 * Leftover Linux runtime_pipeline_abi.o can keep U refs to asg_thin_* after
 * assign_thin inject (helpers are TU-private in .x but tip-asm emits global T;
 * inject/localize can leave callers without providers). Product g05 then fails
 * pure-ld / CC residual with undefined asg_thin_*.
 *
 * Authority: runtime_pipeline_abi_assign_thin.x (asg_thin_load/store/ctx_off/
 * align). This .c is G.7 twin for LINK_WINNERS — same LE i32 + next_offset=4
 * contract. PLATFORM: SHARED host-cc first-wins (Linux gold for leftover U).
 */
#include <stdint.h>

/**
 * Load host LE i32 from base[off..off+3].
 * Null base or negative off → 0.
 */
int32_t asg_thin_load_i32_le(uint8_t *base, int32_t off) {
  uint32_t b0;
  uint32_t b1;
  uint32_t b2;
  uint32_t b3;
  uint32_t u;
  if (base == 0 || off < 0) {
    return 0;
  }
  b0 = (uint32_t)base[off];
  b1 = (uint32_t)base[off + 1];
  b2 = (uint32_t)base[off + 2];
  b3 = (uint32_t)base[off + 3];
  u = b0 + b1 * 256u + b2 * 65536u + b3 * 16777216u;
  return (int32_t)u;
}

/**
 * Store host LE i32 to base[off..off+3].
 * Null base or negative off → no-op.
 */
void asg_thin_store_i32_le(uint8_t *base, int32_t off, int32_t v) {
  uint32_t u;
  if (base == 0 || off < 0) {
    return;
  }
  u = (uint32_t)v;
  base[off] = (uint8_t)(u & 255u);
  base[off + 1] = (uint8_t)((u / 256u) & 255u);
  base[off + 2] = (uint8_t)((u / 65536u) & 255u);
  base[off + 3] = (uint8_t)((u / 16777216u) & 255u);
}

/**
 * LP64 offsetof(AsmFuncCtx, next_offset) — assign_thin.x returns 4.
 */
int32_t asg_thin_ctx_off_next_offset(void) {
  return 4;
}

/**
 * Align AsmFuncCtx.next_offset up to 8 bytes.
 */
void asg_thin_align_next_offset(uint8_t *ctx) {
  int32_t off;
  int32_t m;
  if (ctx == 0) {
    return;
  }
  off = asg_thin_load_i32_le(ctx, asg_thin_ctx_off_next_offset());
  m = off % 8;
  if (m != 0) {
    asg_thin_store_i32_le(ctx, asg_thin_ctx_off_next_offset(), off + (8 - m));
  }
}
