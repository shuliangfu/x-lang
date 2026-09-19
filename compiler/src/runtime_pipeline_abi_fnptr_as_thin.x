// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: LINUX -E (w606 smash leftover as_cast) / MACOS overlay keep.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_await_sync_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_target_type_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ta: i32, tgt: i32, widen: i32): i32;
export extern function glue_emit_as_cast_orch_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32;

/**
 * Product-mega freestanding EXPR_AS ELF face (gate).
 * wave507: tip peer-flat — await/float-lit here; cast/fnptr via cast_orch.
 * G.7 authority was monolith pipeline_asm_emit_as_elf_impl.
 * PLATFORM: SHARED freestanding cast emit · LINUX gold · MACOS.
 */
#[no_mangle]
export function pipeline_asm_emit_as_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_expr_is_await_at_c(arena, expr_ref) != 0) {
      return pipeline_asm_emit_await_sync_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
    }
    if (pipeline_expr_as_operand_ref_at(arena, expr_ref) == 0) {
      return 0 - 1;
    }
    if (pipeline_expr_as_target_type_ref_at(arena, expr_ref) > 0) {
      if (pipeline_type_kind_ord_at(arena, pipeline_expr_as_target_type_ref_at(arena, expr_ref)) == 14
          && pipeline_expr_kind_ord_at(arena, pipeline_expr_as_operand_ref_at(arena, expr_ref)) == 1) {
        return glue_emit_float_lit_to_rax_elf_c(
          arena, elf_ctx,
          pipeline_expr_as_operand_ref_at(arena, expr_ref),
          ta,
          pipeline_expr_as_target_type_ref_at(arena, expr_ref),
          0);
      }
    }
    return glue_emit_as_cast_orch_elf_c(
      arena, elf_ctx,
      pipeline_expr_as_operand_ref_at(arena, expr_ref),
      ctx, ta,
      pipeline_expr_as_target_type_ref_at(arena, expr_ref));
  }
}

/**
 * Public EXPR_AS ELF face (thin delegate to as_elf_impl).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipeline_asm_emit_as_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_as_elf_impl(arena, elf_ctx, expr_ref, ctx, ta);
  }
}
