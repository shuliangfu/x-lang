// Thin pure: asm_ctx_block_slot_get peer (wave595).
// G.7: body MUST match asm_ctx_block_slot_get in
// runtime_pipeline_abi_asm_locals_thin.x / runtime_pipeline_abi.x
// (same exported symbol). Reads the main thin's maps via pipe_al_bn_at /
// pipe_al_brefs_slot / pipe_al_bbases_slot — one BSS, no second table.
// Why separate leaf: Ubuntu tip -c of the monolith drops the trailing
// asm_ctx_block_slot_get (isolated get compiles; Darwin keeps the export).
// PLATFORM: SHARED freestanding Cap leave · LINUX gold · MACOS co-path.

export extern function pipe_al_find(ctx: *u8, create: i32): i32;
export extern function pipe_al_bn_at(s: i32): i32;
export extern function pipe_al_brefs_slot(s: i32): *u8;
export extern function pipe_al_bbases_slot(s: i32): *u8;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;

/**
 * Lookup block_ref starting local index; -1 if unregistered.
 * @param ctx *u8 — AsmFuncCtx* key; null → -1
 * @param block_ref i32 — block ref; <=0 → -1
 * @return i32 — slot_base or -1
 * wave267/w595 pure: G.7 single product authority (historical asm_ctx_block_slot_get).
 * PLATFORM: SHARED — scan from end (latest registration wins); maps live in
 * the main asm_locals thin (pipe_al_find / bn / brefs / bbases accessors).
 */
#[no_mangle]
export function asm_ctx_block_slot_get(ctx: *u8, block_ref: i32): i32 {
  if (ctx == 0 as *u8 || block_ref <= 0) {
    return 0 - 1;
  }
  // M2 class A: export-extern calls sit in unsafe (-backend asm T001).
  unsafe {
    let s: i32 = pipe_al_find(ctx, 0);
    if (s < 0) {
      return 0 - 1;
    }
    let i: i32 = pipe_al_bn_at(s) - 1;
    let pr: *u8 = pipe_al_brefs_slot(s);
    let pb: *u8 = pipe_al_bbases_slot(s);
    if (pr == 0 as *u8 || pb == 0 as *u8) {
      return 0 - 1;
    }
    while (i >= 0) {
      let br: i32 = pipe_load_i32_le(pr, i * 4);
      if (br == block_ref) {
        return pipe_load_i32_le(pb, i * 4);
      }
      i = i - 1;
    }
  }
  return 0 - 1;
}
