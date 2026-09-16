// Thin pure: wave219 al_nc_seq COMMON label counter.
// G.7: body MUST match mega runtime_pipeline_abi.x wave219 leave.
// Seed cold twin keeps freestanding BSS; inject first-wins.
// wave220/221 deferred: leftover still reads named g_pipeline_asm_emit_*
// (file-level let → Lxml COMMON = dual-home SEGV on f32).
// PLATFORM: SHARED freestanding emit label uniqueness.

// wave219: ARRAY_LIT / durable / escape COMMON label seq pure leave
// (was Cap residual pipeline_glue.c static g_pipeline_asm_al_nc_seq + take)
// G.7 product authority for freestanding unique Lxlang_al_* / Lxlang_esc_* /
//   Lxlang_sd_* COMMON symbol sequence numbers:
//   glue_pipeline_asm_al_nc_seq_take_c  (take + increment; clamp wrap)
// Pure-owned BSS: g_pipeline_asm_al_nc_seq (was file-scoped static in glue).
// Consumers: pure array_lit durable COMMON path, slice escape COMMON, deep-copy
//   sd COMMON (for_call_args / reent); seed cold twin under #ifndef FROM_X.
// Deferred: typeck/elf/ast_pool residual pure leave / pipeline_x mega off host-cc.
// PLATFORM: SHARED freestanding — seq is platform-agnostic emit counter.
// ===========================================================================

// wave219: monotonic seq for unique COMMON labels (Lxlang_al_N / esc_N / sd_N).
// Clamp on take if out of [0,999999] so cold/hybrid never emit insane names.
let g_pipeline_asm_al_nc_seq: i32 = 0;

/**
 * Take the next unique ARRAY_LIT / escape / deep-copy COMMON sequence number.
 *
 * Contract: returns current seq then increments. If stored value is <0 or
 * >999999, clamps to 0 before take (matches Cap residual glue body). Never
 * returns a value outside 0..999999 after clamp.
 *
 * @return i32 — sequence number to embed in Lxlang_al_ / Lxlang_esc_ / Lxlang_sd_
 *
 * wave219 pure: G.7 authority (was Cap residual glue.c static counter + take).
 * PLATFORM: SHARED freestanding emit label uniqueness.
 */
#[no_mangle]
export function glue_pipeline_asm_al_nc_seq_take_c(): i32 {
  let seq: i32 = g_pipeline_asm_al_nc_seq;
  if (seq < 0 || seq > 999999) {
    seq = 0;
  }
  g_pipeline_asm_al_nc_seq = seq + 1;
  return seq;
}

// end wave219 pure-owned leave
