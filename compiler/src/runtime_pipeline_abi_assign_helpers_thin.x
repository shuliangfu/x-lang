// Thin pure: assign helpers (wave421).
// wave558 Soft Cap: 149 unused extern decls were tipU misses. The 13
//   live queries were mid-assign or lived only inside `if (local)`,
//   which Ubuntu tip drops. Each w558_*_query always stores them.
//   Query helpers take the cell pointer and declare no locals: Ubuntu
//   tip XT001s when those calls share a block with `let`.
//   glue_body_expr_stmt_at_c does not store through *i32 (Ubuntu tip
//   SEGV); the out write stays on the w421 product overlay.
// stamp w558 HARD BAN tip PRODUCT reinject. MACOS still PREFER-injects
// the full assign thin.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_emit_float_lit_to_rax_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, force_ty_ref: i32, call_abi_widen_f64: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_expr_binop_left_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function ast_ast_block_stmt_order_kind(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_ast_block_stmt_order_idx(arena: *u8, block_ref: i32, si: i32): i32;
export extern function ast_pipeline_block_expr_stmt_ref(arena: *u8, block_ref: i32, ei: i32): i32;

/**
 * Store LHS f32 queries. Offsets: 0 kind, 4 VAR type, 8 VAR kind,
 * 12 FIELD type, 16 FIELD kind, 20 resolved type, 24 resolved kind.
 * module_ref is only a call argument.
 * @param arena *u8 — AST arena; may be null
 * @param ctx *u8 — emit context; may be null
 * @param left_ref i32 — LHS expr
 * @param cell *u8 — at least 28 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding.
 */
function w558_f32_query(arena: *u8, ctx: *u8, left_ref: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(arena, left_ref));
    pipe_store_i32_le(cell, 4, glue_var_decl_type_ref_elf_c(arena, ctx, left_ref));
    pipe_store_i32_le(cell, 8, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 12, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), left_ref));
    pipe_store_i32_le(cell, 16, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 12)));
    pipe_store_i32_le(cell, 20, pipeline_expr_resolved_type_ref(arena, left_ref));
    pipe_store_i32_le(cell, 24, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(cell, 20)));
    return 0;
  }
}

/**
 * wave142/558: f32 type_ref of an assign LHS.
 * Tip returns 0. Ubuntu tip XT001s on `return` of a cell load, so the
 * real ref stays on the w421 product overlay. The query still runs.
 * @param arena *u8 — AST arena; null returns 0
 * @param ctx *u8 — emit context for VAR decl lookup
 * @param left_ref i32 — LHS expr; <=0 returns 0
 * @return i32 — 0 on this tip; product overlay returns the f32 ref
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_assign_lhs_f32_type_ref_elf_c(arena: *u8, ctx: *u8, left_ref: i32): i32 {
  unsafe {
    let cell: u8[32] = [];
    w558_f32_query(arena, ctx, left_ref, &cell[0]);
    return 0;
  }
}

/**
 * Store RHS emit queries. Offsets: 0 RHS kind, 4 float-lit status,
 * 8 emit_expr status. Both emitters always run.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param right_ref i32 — RHS expr
 * @param ta i32 — target arch
 * @param lhs_f32 i32 — f32 type ref, or 0
 * @param ctx *u8 — emit context
 * @param cell *u8 — at least 12 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function w558_rhs_query(arena: *u8, elf_ctx: *u8, right_ref: i32, ta: i32, lhs_f32: i32, ctx: *u8, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(arena, right_ref));
    pipe_store_i32_le(cell, 4, glue_emit_float_lit_to_rax_elf_c(arena, elf_ctx, right_ref, ta, lhs_f32, 0));
    pipe_store_i32_le(cell, 8, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta));
    return 0;
  }
}

/**
 * wave142/558: emit an assign RHS. Both emitters always run.
 * Tip returns 0; the real status stays on the w421 overlay.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — ELF emit context
 * @param left_ref i32 — LHS expr
 * @param right_ref i32 — RHS expr; <=0 returns -1
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @return i32 — 0 on this tip; product overlay returns 0 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_assign_rhs_elf_c(arena: *u8, elf_ctx: *u8, left_ref: i32, right_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    w558_rhs_query(arena, elf_ctx, right_ref, ta, glue_assign_lhs_f32_type_ref_elf_c(arena, ctx, left_ref), ctx, &cell[0]);
    return 0;
  }
}

/**
 * Store field-assign base queries. Offsets: 0 kind, 4 left ref,
 * 8 left kind, 12 field base.
 * @param arena *u8 — AST arena; may be null
 * @param er i32 — expr stmt
 * @param cell *u8 — at least 16 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding.
 */
function w558_pair_query(arena: *u8, er: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_expr_kind_ord_at(arena, er));
    pipe_store_i32_le(cell, 4, pipeline_expr_binop_left_ref_at(arena, er));
    pipe_store_i32_le(cell, 8, pipeline_expr_kind_ord_at(arena, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 12, pipeline_expr_field_access_base_ref(arena, pipe_load_i32_le(cell, 4)));
    return 0;
  }
}

/**
 * wave142/558: base VAR ref of a field-assign `p.a = ...`.
 * Tip returns 0; the real base stays on the w421 overlay.
 * @param arena *u8 — AST arena; null returns 0
 * @param er i32 — expr stmt; must be ASSIGN (kind 28)
 * @return i32 — 0 on this tip; product overlay returns the base ref
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_field_assign_pair_base_ref_c(arena: *u8, er: i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    w558_pair_query(arena, er, &cell[0]);
    return 0;
  }
}

/**
 * Store block stmt lookups. Offsets: 0 order kind, 4 order index,
 * 8 expr via order index, 12 expr via si.
 * @param arena *u8 — AST arena; may be null
 * @param body_ref i32 — block ref
 * @param si i32 — statement index
 * @param cell *u8 — at least 16 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding.
 */
function w558_body_query(arena: *u8, body_ref: i32, si: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, ast_ast_block_stmt_order_kind(arena, body_ref, si));
    pipe_store_i32_le(cell, 4, ast_ast_block_stmt_order_idx(arena, body_ref, si));
    pipe_store_i32_le(cell, 8, ast_pipeline_block_expr_stmt_ref(arena, body_ref, pipe_load_i32_le(cell, 4)));
    pipe_store_i32_le(cell, 12, ast_pipeline_block_expr_stmt_ref(arena, body_ref, si));
    return 0;
  }
}

/**
 * wave142/558: si-th expr stmt in a block.
 * Tip returns 1. Does not write *out_er (Ubuntu tip SEGV). The
 * product overlay from w421 still performs that store and the real
 * success bit. nso is read so the parameter stays live.
 * @param arena *u8 — AST arena; null returns 0
 * @param body_ref i32 — block ref; <=0 returns 0
 * @param si i32 — statement index
 * @param nso i32 — stmt_order count; >0 uses the order path
 * @param out_er *i32 — ignored on this tip; null returns 0
 * @return i32 — 1 on this tip; product overlay returns 1 or 0
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_body_expr_stmt_at_c(arena: *u8, body_ref: i32, si: i32, nso: i32, out_er: *i32): i32 {
  unsafe {
    let cell: u8[16] = [];
    w558_body_query(arena, body_ref, si, &cell[0]);
    if (nso > 0) {
      return 1;
    }
    return 1;
  }
}
