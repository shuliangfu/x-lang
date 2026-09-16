// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// pthin_let_alias.x — G-02f-279 P2 parser thin let/alias product bodies.
//
// 7.2.1 P2b B-minus (2026-09-16): 有则补全 this existing P2 stub with
// dest-buffer parse of top-level let/const and type-alias. The C twins
// lived in top_level_let_slice.inc / type_alias_slice.inc (always
// host-cc via pthin_let_alias.from_x.c). P9a peek/step walks:
//   let/const: optional mut IDENT, IDENT name, optional `: T`, `= expr ;`
//   type alias: IDENT name, `= T ;` (caller already consumed `type`)
// Language has no local u8[N]; the C trampoline holds the name pack.
// type_ref stays the primary ptr shim (do not dest-buffer parse_type_ref
// — P3f was hello/fmt red). expr stays the primary parse_expr ptr shim
// (G.7 one shim). P010/P012/P014 stay the existing C reporters.
// 7.2.1 P2c B-minus (2026-09-16): 有则补全 parse_cond_expr dest-buffer.
// INT followed by `as` rewinds to the INT token start so parse_expr
// sees `0 as T` (same as `return 0 as T`). Other heads call parse_expr
// from the entry cursor. Do not merge wrap. Do not dest-buffer
// parse_one_function_library. Do not dest-buffer parse_type_ref. Do
// not mix range_for. Do not wrap AUDIT. Do not open a new P-lane. Do
// not FORCE pabi mega.
// 7.2.1 P2d B-minus (2026-09-16): 有则补全 body_let_bracket dest-buffer.
// Rewind cursor to `[` (bracket_start) keeping entry line/col, then
// parse_expr (G.7 primary ptr shim). C trampoline publishes lex_out
// and lexer_next_into r_out (P1d face; .x never sees lexer_result).
// AUDIT stays on the cold twin. Do not migrate glue_tail wrapper.
//
// Hybrid P2b/P2c/P2d: g05_try_x_to_o this file;
// XLANG_PTHIN_LET_ALIAS_BODIES_FROM_X skips the two parse C twins when
// both parse_x symbols are present. XLANG_PTHIN_LET_ALIAS_COND_FROM_X
// is a separate define (P6e PARSE_LAYOUT pattern) so a missing
// parse_cond_expr_x keeps the C cond twin without dropping P2b.
// XLANG_PTHIN_LET_ALIAS_BRACKET_FROM_X is a further separate define so
// a missing body_let_bracket_x keeps the C bracket twin without
// dropping P2b/P2c. P9a is linked later into the same thin_glue
// (same as P6e/P7d/P4ud). Cold: no define, full .inc.
// Do not reuse XLANG_PTHIN_LET_ALIAS_FROM_X for P2b/P2c/P2d bodies.
// PLATFORM: SHARED freestanding.

// TOKEN_* pin copies of include/token.h. P2 C _Static_assert fires if
// the pin drifts; do not treat these as a second enum authority.
const TOKEN_IDENT: i32 = 59;
const TOKEN_INT: i32 = 80;
const TOKEN_COLON: i32 = 91;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_ASSIGN: i32 = 117;
const TOKEN_AS: i32 = 128;

/** P9a lexer-step bridge. Pure peeks re-lex the same token. */
export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_next_pos_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
/** G.7 one type_ref ptr shim (primary.inc). Do not dest-buffer parse_type_ref. */
export extern "C" function parser_asm_parse_type_ref_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;
/** G.7 one expr ptr shim (primary.inc). */
export extern "C" function parser_parse_expr_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
/** P18d: keyword used as a binding name. */
export extern "C" function parser_report_keyword_binding_p014_c(line: i32, col: i32): void;
/** P18d: untyped let, or const without `=` / `:`. is_let=1 for let. */
export extern "C" function parser_report_untyped_binding_p010_c(line: i32, col: i32, is_let: i32): void;
/** P18d: duplicate name. kind=2 is module top-level let/const. */
export extern "C" function parser_report_duplicate_name_p012_c(line: i32, col: i32, kind: i32): void;
/** Sidecar: 1 if a top-level let/const already uses this spelling. */
export extern "C" function asm_module_top_level_let_name_exists(module: *u8, name: *u8, name_len: i32): i32;
/** Sidecar: allocate a top-level let slot; -1 on full. */
export extern "C" function pipeline_module_top_level_let_alloc(module: *u8): i32;
/** Sidecar: allocate a type-alias slot; -1 on full. */
export extern "C" function pipeline_module_type_alias_alloc(module: *u8): i32;
/** P2b pack trampolines (C stack; language has no local u8[N]). */
export extern "C" function parser_asm_let_alias_pack_reset_c(pack: *u8): void;
export extern "C" function parser_asm_let_alias_pack_is_mut_src_c(source: *u8, next_pos: usize, ident_len: i32): i32;
export extern "C" function parser_asm_let_alias_pack_copy_name_src_c(pack: *u8, source: *u8, next_pos: usize, ident_len: i32, line: i32, col: i32): i32;
export extern "C" function parser_asm_let_alias_pack_name_exists_c(pack: *u8, module: *u8): i32;
export extern "C" function parser_asm_let_alias_pack_commit_let_c(pack: *u8, module: *u8, type_ref: i32, init_ref: i32, is_const: i32): i32;
export extern "C" function parser_asm_let_alias_pack_commit_alias_c(pack: *u8, module: *u8, target_ref: i32): i32;

/**
 * Parse one top-level `let [mut] Name [: T] = expr ;` or
 * `const Name [: T] = expr ;`. Entry cursor is the first unconsumed
 * token after `let`/`const` (C twin's first lexer_next). On success
 * the cursor is parked after `;`.
 * Optional `mut` is only consumed for let (is_const==0) when the
 * spelling is exactly three bytes `mut`. ident_len<=0 or >255 fails
 * (not clamp; same as the C twin / P6e struct-name). const may omit
 * `: T` when the next token is `=` (type_ref=0, typeck infers). let
 * still requires `: T`. Duplicate names report P012 kind=2 and fail
 * before alloc. Keyword-as-name reports P014. Missing type/`=`
 * reports P010.
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param module *u8 — opaque ast_Module; null → 0
 * @param lex_inout *u8 — cursor after `let`/`const`; success parks after `;`
 * @param source *u8 — opaque slice
 * @param is_const i32 — 0 let, nonzero const
 * @param pack *u8 — C-stack name pack
 * @return i32 — 1 success, 0 fail (out->ok stays 0; next_lex unpublished)
 * PLATFORM: SHARED — product P2b B-minus. type_ref = primary ptr shim
 * (do not dest-buffer parse_type_ref). expr = primary ptr shim.
 * Do not merge wrap. Do not mix range_for. Do not wrap AUDIT. Do not
 * open a new lane. Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_parse_one_top_level_let_x_into_c(arena: *u8, module: *u8, lex_inout: *u8, source: *u8, is_const: i32, pack: *u8): i32 {
  let kind: i32 = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let line: i32 = 0;
  let col: i32 = 0;
  let type_ref: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  let ic: i32 = 0;
  let is_let: i32 = 0;
  if (arena == 0 as *u8 || module == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || pack == 0 as *u8) {
    return 0;
  }
  unsafe {
    parser_asm_let_alias_pack_reset_c(pack);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    /* wave385: optional IDENT "mut" after let (not const). */
    if (is_const == 0 && kind == TOKEN_IDENT && parser_asm_let_alias_pack_is_mut_src_c(source, np, il) != 0) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    }
    line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      parser_report_keyword_binding_p014_c(line, col);
      return 0;
    }
    il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (il <= 0 || il > 255) {
      return 0;
    }
    np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    if (parser_asm_let_alias_pack_copy_name_src_c(pack, source, np, il, line, col) == 0) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    type_ref = 0;
    if (kind == TOKEN_COLON) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      type_ref = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
      if (type_ref == 0) {
        return 0;
      }
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    } else if (is_const != 0 && kind == TOKEN_ASSIGN) {
      /* const name = init — type inference; leave type_ref=0. */
    } else {
      /* C twin reports P010 at the unexpected token, not the name. */
      line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
      col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
      if (is_const == 0) {
        is_let = 1;
      } else {
        is_let = 0;
      }
      parser_report_untyped_binding_p010_c(line, col, is_let);
      return 0;
    }
    if (kind != TOKEN_ASSIGN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    eok = 0;
    eref = 0;
    if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0) {
      return 0;
    }
    if (eok == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_SEMICOLON) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_let_alias_pack_name_exists_c(pack, module) != 0) {
      parser_report_duplicate_name_p012_c(line, col, 2);
      return 0;
    }
    if (is_const != 0) {
      ic = 1;
    } else {
      ic = 0;
    }
    if (parser_asm_let_alias_pack_commit_let_c(pack, module, type_ref, eref, ic) == 0) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * Parse one top-level `type Alias = Target;`. Entry cursor is the
 * unconsumed alias IDENT (caller already consumed `type`; C twin's
 * first lexer_next). On success the cursor is parked after `;`.
 * ident_len<=0 or >255 fails (not clamp). Target is the existing
 * type_ref ptr shim (full type grammar, including `*T` / slices).
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param module *u8 — opaque ast_Module; null → 0
 * @param lex_inout *u8 — cursor on the alias name; success parks after `;`
 * @param source *u8 — opaque slice
 * @param pack *u8 — C-stack name pack
 * @return i32 — 1 success, 0 fail (out->ok stays 0; next_lex unpublished)
 * PLATFORM: SHARED — product P2b B-minus. type_ref = primary ptr shim
 * (do not dest-buffer parse_type_ref). Do not merge wrap. Do not mix
 * range_for. Do not wrap AUDIT. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_parse_one_type_alias_x_into_c(arena: *u8, module: *u8, lex_inout: *u8, source: *u8, pack: *u8): i32 {
  let kind: i32 = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let line: i32 = 0;
  let col: i32 = 0;
  let target_ref: i32 = 0;
  if (arena == 0 as *u8 || module == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || pack == 0 as *u8) {
    return 0;
  }
  unsafe {
    parser_asm_let_alias_pack_reset_c(pack);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind != TOKEN_IDENT || il <= 0 || il > 255) {
      return 0;
    }
    line = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    col = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
    if (parser_asm_let_alias_pack_copy_name_src_c(pack, source, np, il, line, col) == 0) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_ASSIGN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    target_ref = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
    if (target_ref == 0) {
      return 0;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_SEMICOLON) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_let_alias_pack_commit_alias_c(pack, module, target_ref) == 0) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * Parse a condition / return / expr-stmt expression.
 * INT followed by `as` rewinds the cursor to the INT token start so
 * parse_expr sees `0 as T` (same as `return 0 as T`). Other heads call
 * parse_expr from the entry cursor. Peek is non-consuming; the INT+as
 * probe steps then restores (language has no lexer by-value).
 * token_start==0 falls back to next_pos-1 (C twin).
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param lex_inout *u8 — entry cursor; success parks after the expr
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — 1 when parse_expr succeeded
 * @param out_expr_ref *i32 — expr ref from parse_expr
 * @return i32 — 1 handled (ok may still be 0); 0 null args
 * PLATFORM: SHARED — product P2c B-minus. expr = primary ptr shim
 * (G.7). Do not dest-buffer parse_type_ref. Do not merge wrap. Do
 * not wrap AUDIT. Do not mix range_for. Do not open a new lane.
 * body_let_bracket is P2d (separate BRACKET_FROM_X).
 */
#[no_mangle]
export function parser_asm_parse_cond_expr_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let kind2: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let q0: usize = 0;
  let np: usize = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  let rc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_INT) {
      q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
      np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
      if (q0 == 0 as usize) {
        if (np > 0 as usize) {
          q0 = np - (1 as usize);
        }
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind2 = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind2 == TOKEN_AS) {
        parser_asm_lex_set_pos_c(lex_inout, q0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        rc = parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref);
        if (rc == 0) {
          return 0;
        }
        out_ok[0] = eok;
        out_expr_ref[0] = eref;
        return 1;
      }
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
    }
    rc = parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref);
    if (rc == 0) {
      return 0;
    }
    out_ok[0] = eok;
    out_expr_ref[0] = eref;
    return 1;
  }
  return 0;
}

/**
 * let init `[..] op [..]`：rewind to bracket_start, parse_expr.
 * Entry line/col stay; pos becomes bracket_start before parse_expr.
 * Success parks lex after the expr; out_ok/out_expr_ref from shim.
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param bracket_start usize — byte offset of `[`
 * @param lex_inout *u8 — entry cursor (line/col); success after expr
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — 1 when parse_expr succeeded
 * @param out_expr_ref *i32 — expr ref from parse_expr
 * @return i32 — 1 handled (ok may still be 0); 0 null args
 * PLATFORM: SHARED — product P2d B-minus. expr = primary ptr shim
 * (G.7). Do not wrap AUDIT. Do not migrate glue_tail. Do not open a
 * new lane. C trampoline does lex_out + lexer_next_into (P1d face).
 */
#[no_mangle]
export function parser_asm_parse_body_let_bracket_compound_init_ref_x_into_c(
    arena: *u8, bracket_start: usize, lex_inout: *u8, source: *u8, out_ok: *i32,
    out_expr_ref: *i32): i32 {
  let eok: i32 = 0;
  let eref: i32 = 0;
  let rc: i32 = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 ||
      out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    parser_asm_lex_set_pos_c(lex_inout, bracket_start);
    parser_asm_lex_set_line_c(lex_inout, line0);
    parser_asm_lex_set_col_c(lex_inout, col0);
    rc = parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref);
    if (rc == 0) {
      return 0;
    }
    out_ok[0] = eok;
    out_expr_ref[0] = eref;
    return 1;
  }
  return 0;
}
