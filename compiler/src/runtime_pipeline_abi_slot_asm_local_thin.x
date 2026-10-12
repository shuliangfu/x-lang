// Thin pure: slot REST asm_local_slot_bytes only (peers via leftover/helpers).
// G.7: body MUST match asm_local_slot_bytes in slot_bytes_thin / mega.
// wave428: LINUX PREFER — Darwin -c ~510B; Ubuntu -c ~879B; product inject
//   + true relink L2 5/5 opt=102 (md5 changed). ensure injects after helpers.
// wave538 Soft Cap: drop 23 unused extern decls (tipU 1/24 → 1/1);
//   stamp w538 HARD BAN tip PRODUCT reinject (keep prior PREFER; stamp-only).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS (full slot covers).

export extern function pipe_local_slot_bytes_mod(arena: *u8, type_ref: i32, mod: *u8): i32;

/**
 * Public stack slot bytes for const/let (no ctx; emit module + dep walk).
 * Delegates to pipe_local_slot_bytes_mod with a null module.
 * @param arena *u8 - ASTArena*
 * @param type_ref i32 - type ref
 * @return i32 - slot bytes
 * wave268 pure: G.7 single product authority (was pipeline_asm_slot_bytes.c).
 * PLATFORM: SHARED freestanding stack layout · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function asm_local_slot_bytes(arena: *u8, type_ref: i32): i32 {
  unsafe {
    return pipe_local_slot_bytes_mod(arena, type_ref, 0 as *u8);
  }
}
