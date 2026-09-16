/*
 * Thin pure: wave223 emit_ctx sret_active / sret_home_off / sret_ret_sz.
 * G.7: bodies match mega runtime_pipeline_abi.x wave223 leave.
 *
 * Independent C thin (same Darwin rule as wave222): do not grow prior
 * emit_ctx named-BSS leaves — Apple ld -r rejects data dups on re-merge.
 *
 * Why C (not .x pure-asm): `let x: i32 = -1` emits no BSS under pure-asm;
 * non-zero scalars that do emit become Lxml COMMON vs mega named .data
 * (dual-home SEGV). This thin owns the canonical named cells.
 *
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding (SysV rdi / AAPCS64 x8 sret polarity).
 */

#include <stdint.h>

/* wave223: canonical names (match mega leave). */
int32_t g_pipeline_asm_func_sret_active = 0;
int32_t g_pipeline_asm_sret_home_off = -1;
int32_t g_pipeline_asm_func_sret_ret_sz = 0;

/** wave223: get sret-active flag. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_sret_active_get(void) {
  return g_pipeline_asm_func_sret_active;
}

/** wave223: set sret-active flag. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_sret_active_set(int32_t v) {
  g_pipeline_asm_func_sret_active = v;
}

/** wave223: get sret home stack offset. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_sret_home_off_get(void) {
  return g_pipeline_asm_sret_home_off;
}

/** wave223: set sret home stack offset. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_sret_home_off_set(int32_t off) {
  g_pipeline_asm_sret_home_off = off;
}

/** wave223: get sret return byte width. PLATFORM: SHARED. */
int32_t pipeline_asm_emit_ctx_sret_ret_sz_get(void) {
  return g_pipeline_asm_func_sret_ret_sz;
}

/** wave223: set sret return byte width. PLATFORM: SHARED. */
void pipeline_asm_emit_ctx_sret_ret_sz_set(int32_t sz) {
  g_pipeline_asm_func_sret_ret_sz = sz;
}
