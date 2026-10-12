// Thin pure: peel REST index_addr walker (INDEX arm via ko47 peer).
// G.7: body MUST match glue_binop_operand_index_addr_clobbers_rbx_elf_c
// in binop_block_peel_thin.x / mega.
// wave426: Darwin -c ~3561B; LINUX HARD BAN (Ubuntu asm -c empty .o RC=0).
// wave435: LINUX PREFER — INDEX ko47 peer thin (co-file XT001).
// wave479: peer-flat no-local (monolith tip U=1/8→3/8). Tip U=8/8.
//   PRODUCT inject: LINUX PREFER (stamp w479); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_block_transparent_value_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_await_at_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_is_x_as_cast_at_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_addr_await_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_addr_as_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_addr_field_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_addr_deref_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function glue_binop_index_ko47_clobbers_rbx(arena: *u8, expr_ref: i32): i32;
export extern function glue_expr_type_is_ptr_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_binop_right_ref_at(arena: *u8, expr_ref: i32): i32;

/**
 * wave149 pure: G.7 authority (was pipeline_asm_emit_binop.c::glue_binop_operand_index_addr_clobbers_rbx_elf_c).
 * @param arena *u8 - parameter
 * @param expr_ref i32 - parameter
 * @return i32 - face-specific status
 * PLATFORM: SHARED freestanding emit.
 * wave435: INDEX arm delegated to glue_binop_index_ko47_clobbers_rbx peer.
 * wave479: peer-flat — await/as/field/deref peers; ban `let x=call()`.
 */
#[no_mangle]
export function glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      return 0;
    }
    if (glue_expr_block_transparent_value_ref_at(arena, expr_ref) > 0) {
      return glue_binop_operand_index_addr_clobbers_rbx_elf_c(arena, glue_expr_block_transparent_value_ref_at(arena, expr_ref));
    }
    if ((glue_expr_is_await_at_c(arena, expr_ref)) != 0) {
      return glue_binop_index_addr_await_elf_c(arena, expr_ref);
    }
    if ((glue_expr_is_x_as_cast_at_c(arena, expr_ref)) != 0) {
      return glue_binop_index_addr_as_elf_c(arena, expr_ref);
    }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 44) {
      return glue_binop_index_addr_field_elf_c(arena, expr_ref);
    }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 52) {
      return glue_binop_index_addr_deref_elf_c(arena, expr_ref);
    }
    if (pipeline_expr_kind_ord_at(arena, expr_ref) == 47) {
      return glue_binop_index_ko47_clobbers_rbx(arena, expr_ref);
    }
    /* *(p + j) / *(p - j): same park as the mega walker.
     * Body is glue_binop_ptr_arith_clobbers_rbx below. Linux injects this
     * thin into the frozen egg and does not rebuild runtime_pipeline_abi.x,
     * so the callee has to be defined in this file. The body must match
     * the mega. PLATFORM: SHARED · LINUX PREFER this thin · MACOS skip. */
    if (glue_binop_ptr_arith_clobbers_rbx(arena, expr_ref) != 0) {
      return 1;
    }
    return 0;
  }
}

/**
 * 1 when expr is pointer arithmetic that writes rbx before the compare.
 * ADD with exactly one TYPE_PTR side (ptr+int or int+ptr), or SUB of
 * ptr-int. glue_try_emit_ptr_arith_scaled_elf_c spills the pointer,
 * mov_rax_to_rbx's the offset, then mul_imm_to_rbx (arm64 mov w3, #esz;
 * mul w1, w1, w3). That sequence writes x1 and w3, not x2.
 * Integer add/sub and ptr-ptr return 0.
 * Product Linux never recompiles runtime_pipeline_abi.x into the egg
 * (full pabi rebuild is banned). This thin is injected, so this
 * definition is the one the link sees. It must match
 * glue_binop_ptr_arith_clobbers_rbx in runtime_pipeline_abi.x.
 * @param arena *u8 — AST arena; null returns 0
 * @param expr_ref i32 — candidate ADD (kind 4) or SUB (kind 5)
 * @return i32 — 1 when the compare-left in rbx must be parked, else 0
 * PLATFORM: SHARED — MACOS|ARM64 park is mov x2, x1. LINUX|x86_64 push rbx.
 */
#[no_mangle]
export function glue_binop_ptr_arith_clobbers_rbx(arena: *u8, expr_ref: i32): i32 {
  unsafe {
    let ko: i32 = 0;
    let left_ref: i32 = 0;
    let right_ref: i32 = 0;
    let lp: i32 = 0;
    let rp: i32 = 0;
    if ((arena == (0 as *u8)) || expr_ref <= 0) {
      return 0;
    }
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
    if (ko != 4 && ko != 5) {
      return 0;
    }
    left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (left_ref <= 0 || right_ref <= 0) {
      return 0;
    }
    lp = glue_expr_type_is_ptr_c(arena, left_ref);
    rp = glue_expr_type_is_ptr_c(arena, right_ref);
    /* ADD: ptr+int or int+ptr. Both-pointer is not this scale path. */
    if (ko == 4 && lp != rp) {
      return 1;
    }
    /* SUB: ptr-int only. int-ptr is rejected; ptr-ptr is an element count. */
    if (ko == 5 && lp != 0 && rp == 0) {
      return 1;
    }
    return 0;
  }
}
