// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// pthin_expr_as_suffix_tramp.x — checklist 6.2 / w1537.
// Pointer face parser_asm_parse_as_suffix_into_slice_c, the peek-after
// shim, and the slice marker. The four algorithm functions stay in
// pthin_expr_as_suffix.x. The as_* writer stays in
// pthin_expr_as_suffix_set.x. This file does not add a fifth function
// to the Darwin four-function splitter.
//
// The public face takes arena, source, and the 24-byte result by
// pointer on SysV and Win64. There is no by-value lexer argument.
// The cursor is the 16 bytes at result offset 8 (pos, line, col).
// memcpy moves that cursor. A struct assignment keeps only 8 bytes.
// Peek-after does not call lexer_next_into. It saves the cursor,
// steps once, peeks the following kind, and restores, all through
// the P9a bridge. Stretch-audit calls stay in the C seed. They are
// product nops and are not copied here. The C seed stays on disk
// for prove. Product g05 must not host-cc it.
// PLATFORM: SHARED.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/**
 * Dest-buffer as_suffix body. Defined in pthin_expr_as_suffix.x.
 * This file only forwards the cursor.
 */
extern function parser_asm_parse_as_suffix_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;

/** P9a: read the lexer cursor offset. Null returns 0. */
extern function parser_asm_lex_pos_c(lex: *u8): usize;
/** P9a: read the lexer line. Null returns 0. */
extern function parser_asm_lex_line_c(lex: *u8): i32;
/** P9a: read the lexer column. Null returns 0. */
extern function parser_asm_lex_col_c(lex: *u8): i32;
/** P9a: write the lexer cursor offset. Null is a no-op. */
extern function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
/** P9a: write the lexer line. Null is a no-op. */
extern function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
/** P9a: write the lexer column. Null is a no-op. */
extern function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
/** P9a: advance one token and return its kind. Null returns 0. */
extern function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
/** P9a: peek the next kind without advancing. Null returns 0. */
extern function parser_asm_lex_peek_kind_c(lex: *u8, source: *u8): i32;

/**
 * Peek the token after the unconsumed next token.
 * The caller's 16-byte lexer is restored before return. A null
 * lexer or source returns 0 and does not step.
 * Save, step, peek, and restore are separate calls. The step
 * result is ignored: the cursor is restored even when the step
 * returns 0. The kind returned is the peek after that step.
 * @param lex *u8 — 16-byte cursor; null returns 0
 * @param source *u8 — source slice; null returns 0
 * @return i32 — kind of the token after the next one, or 0
 * PLATFORM: SHARED. Does not call lexer_next_into.
 */
#[no_mangle]
export function parser_asm_lex_peek_kind_after_c(lex: *u8, source: *u8): i32 {
  if (lex == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  let saved_pos: usize = 0;
  let saved_line: i32 = 0;
  let saved_col: i32 = 0;
  let kind: i32 = 0;
  // Step advances the live cursor by one token. Peek then reads the
  // following kind and does not advance. Restoring pos, line, and col
  // puts the caller's 16-byte lexer back. Each call is its own
  // statement. PLATFORM: SHARED.
  unsafe {
    saved_pos = parser_asm_lex_pos_c(lex);
    saved_line = parser_asm_lex_line_c(lex);
    saved_col = parser_asm_lex_col_c(lex);
    parser_asm_lex_step_kind_c(lex, source);
    kind = parser_asm_lex_peek_kind_c(lex, source);
    parser_asm_lex_set_pos_c(lex, saved_pos);
    parser_asm_lex_set_line_c(lex, saved_line);
    parser_asm_lex_set_col_c(lex, saved_col);
  }
  return kind;
}

/**
 * Copy the result cursor, run the as_suffix body, and write the
 * cursor back on both success and failure.
 * A null out or source returns. ok==0 returns without calling the
 * body. A null arena is the body's job: it returns 0 and this face
 * then stores ok=0. The caller already filled ok and expr_ref;
 * success stores the body's ok and does not force either slot to 0.
 * @param arena *u8 — AST arena; passed through; null is not checked here
 * @param source *u8 — source slice; null returns
 * @param out *u8 — 24-byte parse_expr_result; null returns; cursor at offset 8
 * @return void
 * PLATFORM: SHARED. Pointer face. No stretch-audit call.
 */
#[no_mangle]
export function parser_asm_parse_as_suffix_into_slice_c(arena: *u8, source: *u8, out: *u8): void {
  if (out == 0 as *u8 || source == 0 as *u8) {
    return;
  }
  let op: *i32 = out as *i32;
  let ok: i32 = 0;
  unsafe {
    ok = op[0];
  }
  if (ok == 0) {
    return;
  }
  // Mutable copy of the 16-byte cursor at result offset 8.
  // The body parks the cursor through the pointer. memcpy keeps
  // line and col; a struct assignment does not. The copy is written
  // back on success and on failure. PLATFORM: SHARED.
  let cur: u8[16] = [];
  cur[0] = 0;
  let refv: i32 = 0;
  unsafe {
    refv = op[1];
    memcpy(&cur[0], out + 8, 16);
    let rc: i32 = parser_asm_parse_as_suffix_x_into_c(arena, &cur[0], source, &ok, &refv);
    memcpy(out + 8, &cur[0], 16);
    op[1] = refv;
    if (rc == 0 || ok == 0) {
      op[0] = 0;
    } else {
      op[0] = ok;
    }
  }
}

/**
 * Slice marker. Returns 1 when this object is linked.
 * @return i32 — always 1
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_pthin_expr_as_suffix_slice_marker(): i32 {
  return 1;
}

/**
 * Proof that product g05 linked this .x trampoline.
 * The face name and the marker can also come from the C seed.
 * This anchor cannot.
 * @return i32 — always 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pthin_expr_as_suffix_tramp_w1537_anchor(): i32 {
  return 0;
}
