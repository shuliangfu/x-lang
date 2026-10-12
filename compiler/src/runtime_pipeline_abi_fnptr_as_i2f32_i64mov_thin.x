// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: BOTH tip PREFER (stamp w507).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_elf_ctx_append_bytes(elf_ctx: *u8, ptr: *u8, n: i32): i32;

/**
 * Cast arm peer. Return -2 fallthrough.
 * PLATFORM: SHARED freestanding cast emit.
 */
#[no_mangle]
export function glue_emit_as_i2f32_i64mov_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32 {
  let mov_eax: u8[2] = [];
  unsafe {
    if (pipeline_expr_resolved_type_ref(arena, op) <= 0) { return 0 - 2; }
    if (!(pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, op)) == 3)) { return 0 - 2; }
    mov_eax[0] = 137 as u8;
    mov_eax[1] = 192 as u8;
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0) { return 0 - 1; }
    if (pipeline_elf_ctx_append_bytes(elf_ctx, &mov_eax[0], 2) != 0) { return 0 - 1; }
    return backend_enc_cvtsi2ss_eax_from_i64_arch(elf_ctx, ta);
  }
}
