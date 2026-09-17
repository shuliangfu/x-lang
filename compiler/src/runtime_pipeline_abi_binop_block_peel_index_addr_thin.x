// Thin pure: peel REST index_addr walker (INDEX arm via ko47 peer).
// G.7: body MUST match glue_binop_operand_index_addr_clobbers_rbx_elf_c
// in binop_block_peel_thin.x / mega.
// wave426: Darwin -c ~3561B; LINUX HARD BAN (Ubuntu asm -c empty .o RC=0).
// wave435: LINUX PREFER — INDEX ko47 peer thin (co-file XT001).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_as_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_ko47_clobbers_rbx(arena: *u8, expr_ref: i32): i32;

/**
 * wave149 pure: G.7 authority (was pipeline_asm_emit_binop.c::glue_binop_operand_index_addr_clobbers_rbx_elf_c).
 * @param arena *u8 - parameter
 * @param expr_ref i32 - parameter
 * @return i32 - face-specific status
 * PLATFORM: SHARED freestanding emit.
 * wave435: INDEX arm delegated to glue_binop_index_ko47_clobbers_rbx peer.
 */
export function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let ko: i32 = 0;
    let op_ref: i32 = 0;
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      return 0;
    }
    op_ref = glue_expr_block_transparent_value_ref_at(arena, expr_ref);
    if (op_ref > 0) {
      return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
    }
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    if ((glue_expr_is_await_at_c(arena, expr_ref)) != 0) {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    if ((glue_expr_is_x_as_cast_at_c(arena, expr_ref)) != 0) {
      op_ref = pipeline_expr_as_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    if (ko == 44) {
      op_ref = pipeline_expr_field_access_base_ref(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    if (ko == 52) {
      op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
      if (op_ref > 0) {
        return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, op_ref);
      }
      return 0;
    }
    if (ko == 47) {
      return glue_binop_index_ko47_clobbers_rbx(arena, expr_ref);
    }
    return 0;
  }
}
