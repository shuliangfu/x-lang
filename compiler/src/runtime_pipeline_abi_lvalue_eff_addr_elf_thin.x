// Thin pure: pipeline_asm_emit_lvalue_eff_addr_elf_c Cap leave (knife256/10.2).
// Hollow m8 / phase1 branches to text_c → CG002 on ELF field/ptr assign.
// FIELD(44): recurse base; PTR base load_64; add layout offset.
// VAR(3): stack_off → glue_enc_local_slot_ptr_or_addr_elf_c (LEA/LDR).
// PLATFORM: SHARED freestanding · MACOS tip cold · LINUX gold.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_field_access_layout_offset(arena: *u8, mod: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_call_arg_resolve_var_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_enc_local_slot_ptr_or_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, stack_off: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;

/**
 * ELF lvalue effective address → rax.
 * @return i32 — 0 ok; -1 fail
 * PLATFORM: SHARED freestanding · MACOS|ARM64 · LINUX.
 */
#[no_mangle]
export function pipeline_asm_emit_lvalue_eff_addr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    if (arena == (0 as *u8)) {
      return 0 - 1;
    }
    if (elf_ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (ctx == (0 as *u8)) {
      return 0 - 1;
    }
    if (expr_ref <= 0) {
      return 0 - 1;
    }
    let k: i32 = pipeline_expr_kind_ord_at(arena, expr_ref);
    // FIELD_ACCESS == 44 (0x2c)
    if (k == 44) {
      let base: i32 = pipeline_expr_field_access_base_ref(arena, expr_ref);
      if (base <= 0) {
        return 0 - 1;
      }
      if (pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, base, ctx, ta) != 0) {
        return 0 - 1;
      }
      // If base yields a pointer value already in rax for nested FIELD of PTR:
      // when base itself is FIELD and resolved type PTR — load. For VAR of
      // PTR, local_slot already loaded the pointer value when needs_ptr_load.
      // Mirror restored: load when base kind is FIELD and type kind PTR(9).
      if (pipeline_expr_kind_ord_at(arena, base) == 44) {
        let rty: i32 = pipeline_expr_resolved_type_ref(arena, base);
        if (rty > 0) {
          if (pipeline_type_kind_ord_at(arena, rty) == 9) {
            if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0) {
              return 0 - 1;
            }
          }
        }
      }
      // VAR base with PTR type: local_slot may LEA the slot; load pointer value.
      if (pipeline_expr_kind_ord_at(arena, base) == 3) {
        let rty2: i32 = pipeline_expr_resolved_type_ref(arena, base);
        if (rty2 > 0) {
          if (pipeline_type_kind_ord_at(arena, rty2) == 9) {
            if (backend_enc_load_64_from_rax_arch(elf_ctx, ta) != 0) {
              return 0 - 1;
            }
          }
        }
      }
      let mod: *u8 = glue_emit_module_from_ctx(ctx);
      if (mod == (0 as *u8)) {
        mod = pipeline_asm_emit_module_ref_c();
      }
      let off: i32 = pipeline_expr_field_access_layout_offset(arena, mod, expr_ref);
      if (off < 0) {
        return 0 - 1;
      }
      return backend_enc_add_imm_to_rax_arch(elf_ctx, off, ta);
    }
    // VAR == 3
    if (k == 3) {
      let soff: i32 = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
      if (soff < 0) {
        soff = glue_var_expr_stack_off_elf_c(arena, ctx, expr_ref);
      }
      if (soff < 0) {
        return 0 - 1;
      }
      return glue_enc_local_slot_ptr_or_addr_elf_c(arena, elf_ctx, expr_ref, soff, ctx, ta);
    }
    // DEREF / unary * == 52 (0x34) — emit operand into rax (pointer value)
    if (k == 52) {
      let op: i32 = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op <= 0) {
        return 0 - 1;
      }
      return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    }
    return 0 - 1;
  }
}
