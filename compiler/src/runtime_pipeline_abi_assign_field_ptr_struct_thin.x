// Thin pure: FIELD ptr-path TYPE_STRUCT(8) arm (wave476).
// G.7: part of glue_emit_assign_field_ptr_elf_c (peer-flat).
// wave476: split from monolith CG002. Tip U=6/6.
//   PRODUCT inject: LINUX PREFER (stamp w476); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32): i32;

/**
 * FIELD ptr-path struct arm — lvalue→rbx then struct_type_let_init (slot -3).
 * wave476: no-local — re-call type_ref; ban `let x=call()`.
 * @return i32 — 0 ok; -1 fail; -3 not this arm
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_field_ptr_struct_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref) > 0) {
      if (pipeline_type_kind_ord_at(arena, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref)) == 8) {
        if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0) {
          return 0 - 1;
        }
        if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
        if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), 0 - 3) == 0) {
          return 0;
        }
        if (glue_emit_struct_type_let_init_elf_c(arena, elf_ctx, right_ref, ctx, ta, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref), 0 - 3) == (0 - 1)) {
          return 0 - 1;
        }
      }
    }
    return 0 - 3;
  }
}
