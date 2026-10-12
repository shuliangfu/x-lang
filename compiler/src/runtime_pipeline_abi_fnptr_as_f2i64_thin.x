// Thin pure: Cap-fn-ptr EXPR_AS peer (wave507).
// G.7: part of pipeline_asm_emit_as_elf_impl cast/fnptr path (peer-flat).
// tip BB budget: monolith tip T001/CG002 after i→f32 i64mov; single-arm
//   peers tipU-complete; gate→cast_orch→sub-orch→arms→lea.
// PRODUCT: BOTH tip PREFER (stamp w507).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_is_scalar_f64_elf_c(arena: *u8, ctx: *u8, op: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Float→i64/u64 truncate arm. Return -2 fallthrough.
 * PLATFORM: SHARED freestanding cast emit.
 */
#[no_mangle]
export function glue_emit_as_f2i64_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32, tgt: i32): i32 {
  unsafe {
    if (pipeline_type_kind_ord_at(arena, tgt) != 4 && pipeline_type_kind_ord_at(arena, tgt) != 5
        && pipeline_type_kind_ord_at(arena, tgt) != 6 && pipeline_type_kind_ord_at(arena, tgt) != 7) {
      return 0 - 2;
    }
    if (pipeline_expr_resolved_type_ref(arena, op) > 0) {
      if (pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, op)) != 14
          && pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, op)) != 15
          && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op) == 0) {
        return 0 - 2;
      }
    } else {
      if (pipeline_expr_kind_ord_at(arena, op) != 1 && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op) == 0) {
        return 0 - 2;
      }
    }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0) { return 0 - 1; }
    if (pipeline_expr_resolved_type_ref(arena, op) > 0
        && pipeline_type_kind_ord_at(arena, pipeline_expr_resolved_type_ref(arena, op)) == 14) {
      return backend_enc_cvttss2si_rax_from_f32_bits_arch(elf_ctx, ta);
    }
    return backend_enc_cvttsd2si_rax_from_f64_bits_arch(elf_ctx, ta);
  }
}
