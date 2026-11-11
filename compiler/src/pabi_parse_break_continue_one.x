// One strong parser_asm_primary_break_continue_x_into_c.
// Official/stage1 miscompiled the kind==TOKEN_BREAK test after
// expr_alloc: the compare used the new expr ref instead of the
// token kind, so break was stamped EXPR_CONTINUE and emitted as
// a jump to the loop head. This TU maps the token to the expr
// kind before alloc so a stage1 rebuild cannot reload the wrong
// register. Do not fold this into runtime_pipeline_abi.x.
// PLATFORM: SHARED.

export extern function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
export extern function ast_ast_arena_expr_alloc(arena: *u8): i32;
export extern function pipeline_expr_set_kind(arena: *u8, expr_ref: i32, kind: i32): void;
export extern function pipeline_expr_set_line_col(arena: *u8, expr_ref: i32, line: i32, col: i32): void;
export extern function pipeline_expr_set_common_zeros_c(arena: *u8, expr_ref: i32): void;

/**
 * BREAK / CONTINUE primary. Token-to-kind runs before expr_alloc.
 * @return i32 — 1 handled; 0 not those tokens
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_break_continue_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let ek: i32 = 0;
  if (arena == (0 as *u8) || lex_inout == (0 as *u8) || source == (0 as *u8) || out_ok == (0 as *i32) || out_expr_ref == (0 as *i32)) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  }
  if (kind != 9 && kind != 10) {
    return 0;
  }
  if (kind == 9) {
    ek = 39;
  } else {
    ek = 40;
  }
  unsafe {
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
  }
  if (ref == 0) {
    unsafe {
      out_ok[0] = 0;
    }
    return 1;
  }
  unsafe {
    pipeline_expr_set_kind(arena, ref, ek);
    pipeline_expr_set_line_col(arena, ref, tl, tc);
    pipeline_expr_set_common_zeros_c(arena, ref);
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
  }
  return 1;
}
