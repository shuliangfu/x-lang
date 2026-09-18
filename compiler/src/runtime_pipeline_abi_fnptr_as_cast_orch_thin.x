// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: BOTH tip PREFER (stamp w507).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_as_f2i_orch_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32;
export extern function glue_emit_as_i2f32_orch_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_as_i2f64_orch_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;
export extern function glue_emit_as_fnptr_or_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;

/**
 * Mid cast orchestrator: f2i → i2f32 → i2f64 → Cap-fn-ptr/expr.
 * wave507: tipU-complete with slot cascade.
 * PLATFORM: SHARED freestanding cast emit.
 */
#[no_mangle]
export function glue_emit_as_cast_orch_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32 {
  let s: i32[1] = [];
  unsafe {
    s[0] = glue_emit_as_f2i_orch_elf_c(arena, elf_ctx, op, ctx, ta, tgt);
    if (s[0] != (0 - 2)) { return s[0]; }
    if (pipeline_type_kind_ord_at(arena, tgt) == 14) {
      s[0] = glue_emit_as_i2f32_orch_elf_c(arena, elf_ctx, op, ctx, ta);
      if (s[0] != (0 - 2)) { return s[0]; }
    }
    if (pipeline_type_kind_ord_at(arena, tgt) == 15) {
      s[0] = glue_emit_as_i2f64_orch_elf_c(arena, elf_ctx, op, ctx, ta);
      if (s[0] != (0 - 2)) { return s[0]; }
    }
    return glue_emit_as_fnptr_or_expr_elf_c(arena, elf_ctx, op, ctx, ta, tgt);
  }
}
