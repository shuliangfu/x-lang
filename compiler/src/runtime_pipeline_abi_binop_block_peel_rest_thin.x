// Thin pure: peel REST may_clobber only (other peel exports via leftover).
// G.7: body MUST match glue_expr_emit_may_clobber_rbx_elf_c in peel thin/mega.
// wave422: LINUX PREFER probe — single export; peers are UNDEF→leftover/helpers.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_block_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_num_lets(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_loops(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_expr_stmts(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_final_expr_ref(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_num_stmt_order(arena: *u8, block_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function pipeline_block_region_body_ref(arena: *u8, block_ref: i32, ri: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function asm_module_top_level_const_lit_i32(mod: *u8, arena: *u8, name: *u8, nlen: i32, out: *i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function glue_asm73_evict_cache_if_live_pressure_elf_c(ta: i32, elf_ctx: *u8): void;
export extern function glue_binop_var_slot_cache_hit_rbx(ctx: *u8, off: i32): i32;
export extern function glue_binop_try_reload_spill_off_elf_c(elf_ctx: *u8, ctx: *u8, off: i32, ta: i32, to_rbx: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function glue_load_f32_var_slot_to_rbx_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_asm73_var_prefers_stack_spill(off: i32): i32;
export extern function glue_binop_stack_spill_push_elf_c(elf_ctx: *u8, ta: i32, off: i32, which: i32): i32;
export extern function glue_binop_var_slot_cache_set_ctx_key(ctx: *u8): void;
export extern function glue_binop_var_slot_cache_set_rbx(ctx: *u8, off: i32): void;
export extern function glue_binop_var_slot_cache_hit_rax(ctx: *u8, off: i32): i32;
export extern function glue_load_f32_var_slot_to_rax_elf_c(elf_ctx: *u8, arena: *u8, ctx: *u8, expr_ref: i32, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_binop_var_slot_cache_set_rax(ctx: *u8, off: i32): void;
export extern function pipeline_expr_field_access_is_enum_variant(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_var_slot_cache_clear(): void;
export extern function pipeline_asm_emit_expr_elf_fast(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_field_access_elf_fast_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_as_needs_full_emit_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_as_elf_impl(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_index_base_is_slice_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_expr_lit_i32_at_c(arena: *u8, expr_ref: i32, out: *i32): i32;
export extern function pipeline_asm_cmp_expr_lit_i32_at(arena: *u8, expr_ref: i32, out_imm: *i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_try_binop_load_operand_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32;
export extern function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_operand_load_to_rbx_clobbers_rax_elf_c(arena: *u8, expr_ref: i32): i32;

/**
 * wave149 pure: G.7 authority (was pipeline_asm_emit_binop.c::glue_expr_emit_may_clobber_rbx_elf_c).
 * @param arena *u8 - parameter
 * @param expr_ref i32 - parameter
 * @return i32 - face-specific status
 * PLATFORM: SHARED freestanding emit.
 */
export function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let ko: i32 = 0;
    let op_ref: i32 = 0;
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      return 1;
    }
    op_ref = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    if (op_ref > 0) {
      return glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref);
    }
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (ko == 3 || ko == 0 || ko == 2) {
      return 0;
    }
    if (ko == 44 || ko == 47) {
      return 1;
    }
    if ((glue_expr_is_await_at_c(arena, expr_ref)) != 0) {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref);
      }
      return 1;
    }
    if ((glue_expr_is_x_as_cast_at_c(arena, expr_ref)) != 0) {
      /* Full-AS may walk INDEX/FIELD operands that park temps in rbx. */
      if (glue_binop_as_needs_full_emit_elf_c(arena, expr_ref) != 0) {
        op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
        if (op_ref > 0) {
        return glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref);
      }
      return 1;
    }
      op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_expr_emit_may_clobber_rbx_elf_c(arena, op_ref);
      }
      return 1;
    }
    return 1;
  }
}
