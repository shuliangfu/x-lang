// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: BOTH tip PREFER (stamp w507).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_as_f2i32_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32;
export extern function glue_emit_as_f2i64_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32;

/**
 * Cast sub-orchestrator. Return -2 fallthrough.
 * wave507: slot cascade (ban mid `rc=call()` tip drop).
 * PLATFORM: SHARED freestanding cast emit.
 */
#[no_mangle]
export function glue_emit_as_f2i_orch_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32 {
  let s: i32[1] = [];
  unsafe {
    s[0] = glue_emit_as_f2i32_elf_c(arena, elf_ctx, op, ctx, ta, tgt);
    if (s[0] != (0 - 2)) { return s[0]; }
    s[0] = glue_emit_as_f2i64_elf_c(arena, elf_ctx, op, ctx, ta, tgt);
    if (s[0] != (0 - 2)) { return s[0]; }
    return 0 - 2;
  }
}
