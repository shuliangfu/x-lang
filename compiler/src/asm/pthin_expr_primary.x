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

/* Primary literal wave: token ordinals (token.h enum, validated
 * ELSE=5/IF=4) and bridges. */
const TOKEN_EOF: i32 = 0;
const TOKEN_IF: i32 = 4;
const TOKEN_BREAK: i32 = 9;
const TOKEN_CONTINUE: i32 = 10;
const TOKEN_RETURN: i32 = 11;
const TOKEN_PANIC: i32 = 12;
const TOKEN_MATCH: i32 = 18;
const TOKEN_TRUE: i32 = 75;
const TOKEN_FALSE: i32 = 76;
const TOKEN_NULL: i32 = 132;
const TOKEN_FLOAT: i32 = 81;
const TOKEN_INT: i32 = 80;
const TOKEN_SELF: i32 = 51;
const TOKEN_FATARROW: i32 = 89;
const TOKEN_SEMICOLON: i32 = 95;
const TOKEN_AT: i32 = 129;
const TOKEN_STRING: i32 = 130;
const EXPR_VAR_LIT: i32 = 3;
export extern "C" function parser_asm_ident_pre_dispatch_ptr_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
const EXPR_LIT: i32 = 0;
const EXPR_FLOAT_LIT: i32 = 1;
const EXPR_BOOL_LIT: i32 = 2;

export extern "C" function parser_asm_lex_peek_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_line_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_tok_col_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_float_val_into_c(lex_inout: *u8, source: *u8, out: *f64): void;
export extern "C" function parser_asm_lex_peek_int64_val_into_c(lex_inout: *u8, source: *u8, out: *i64): void;
export extern "C" function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function ast_ast_arena_expr_alloc(arena: *u8): i32;
export extern "C" function pipeline_expr_set_kind(a: *u8, er: i32, kind: i32): void;
export extern "C" function pipeline_expr_set_line_col(a: *u8, er: i32, line: i32, col: i32): void;
export extern "C" function pipeline_expr_set_int_val(a: *u8, er: i32, v: i64): void;
export extern "C" function pipeline_expr_set_float_val(a: *u8, er: i32, v: f64): void;
export extern "C" function pipeline_expr_set_common_zeros_c(a: *u8, er: i32): void;
export extern "C" function pipeline_expr_tag_null_keyword_c(arena: *u8, er: i32): void;
export extern "C" function parser_parse_expr_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
export extern "C" function parser_finish_struct_lit_ptr_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void;
export extern "C" function pipeline_expr_kind_ord_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_len(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_var_name_into(a: *u8, er: i32, dst: *u8): void;
export extern "C" function pipeline_expr_set_index_c(a: *u8, er: i32, base_ref: i32, index_ref: i32, is_slice: i32): void;
export extern "C" function pipeline_expr_set_call_c(a: *u8, er: i32, callee_ref: i32, num_type_args: i32): void;
export extern "C" function pipeline_expr_set_struct_lit_finish_c(a: *u8, er: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_set_method_call_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_set_field_access_c(a: *u8, er: i32, base_ref: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_set_var_name(a: *u8, er: i32, nm: *u8, nlen: i32): void;
export extern "C" function pipeline_expr_field_name_len_at(a: *u8, er: i32): i32;
export extern "C" function pipeline_expr_field_name_into(a: *u8, er: i32, dst: *u8): void;
export extern "C" function parser_asm_lex_line_c(lex: *u8): i32;
export extern "C" function parser_asm_lex_col_c(lex: *u8): i32;
export extern "C" function parser_asm_lbrace_looks_like_block_ptr_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_parse_struct_lit_fields_ptr_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void;
export extern "C" function parser_asm_struct_lit_append_field_src_c(arena: *u8, lit_ref: i32, source: *u8, start: usize, nlen: i32, init_ref: i32): i32;
export extern "C" function parser_asm_struct_lit_append_shorthand_src_c(arena: *u8, lit_ref: i32, source: *u8, start: usize, nlen: i32): i32;
export extern "C" function parser_asm_struct_lit_parse_field_value_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
export extern "C" function parser_asm_parse_anonymous_struct_lit_ptr_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): void;
export extern "C" function parser_asm_string_lit_decode_span_ptr_c(arena: *u8, head_ref: i32, source: *u8, q0: usize, nlen: i32, line: i32, col: i32): i32;
export extern "C" function parser_asm_string_lit_append_byte_ptr_c(arena: *u8, head_ref: i32, b: i32, line: i32, col: i32): i32;
export extern "C" function parser_parse_match_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
export extern "C" function parser_parse_at_simd_builtin_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32;
export extern "C" function parser_parse_block_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8, type_ref: i32, out_ok: *i32, out_block_ref: *i32): i32;
export extern "C" function parser_asm_parse_if_expr_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, type_ref: i32, out_ok: *i32, out_expr_ref: *i32): i32;
export extern "C" function parser_asm_wrap_block_ref_as_expr_into_c(arena: *u8, block_ref: i32, type_ref: i32): i32;
export extern "C" function ast_ast_arena_block_alloc(arena: *u8): i32;
export extern "C" function pipeline_block_append_unsafe(arena: *u8, br: i32, body_ref: i32): i32;
export extern "C" function pipeline_block_append_stmt_order(arena: *u8, br: i32, kind: i32, idx: i32): i32;
export extern "C" function pipeline_expr_set_unary_operand_c(a: *u8, er: i32, operand_ref: i32): void;
export extern "C" function pipeline_expr_append_array_lit_elem(a: *u8, er: i32, elem_ref: i32): i32;
export extern "C" function lexer_note_string_lit_overflow(line: i32, col: i32): void;
const EXPR_BLOCK: i32 = 26;
const EXPR_BREAK: i32 = 39;
const EXPR_CONTINUE: i32 = 40;
const EXPR_RETURN: i32 = 41;
const EXPR_PANIC: i32 = 42;
const EXPR_FIELD_ACCESS: i32 = 44;
const EXPR_ARRAY_LIT: i32 = 46;
const EXPR_STRING_LIT: i32 = 59;
const EXPR_ASM: i32 = 60;
const TOKEN_UNDERSCORE: i32 = 52;
const TOKEN_BANG: i32 = 126;
export extern "C" function parser_asm_parse_type_ref_ptr_into_c(arena: *u8, lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_skip_angle_count_ptr_into_c(lex_inout: *u8, source: *u8, out_count: *i32): void;
export extern "C" function parser_asm_lex_peek_token_start_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_peek_ident_len_c(lex_inout: *u8, source: *u8): i32;
export extern "C" function parser_asm_lex_peek_next_pos_c(lex_inout: *u8, source: *u8): usize;
export extern "C" function parser_asm_lex_pos_c(lex: *u8): usize;
export extern "C" function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void;
export extern "C" function parser_asm_lex_set_line_c(lex: *u8, line: i32): void;
export extern "C" function parser_asm_lex_set_col_c(lex: *u8, col: i32): void;
export extern "C" function parser_asm_lex_at_token_pos_c(kind: i32, token_start: usize, ident_len: i32, next_pos: usize): usize;
export extern "C" function parser_asm_lex_source_data_c(source: *u8): *u8;
export extern "C" function parser_asm_lex_source_length_c(source: *u8): usize;
export extern "C" function pipeline_expr_append_method_call_arg(a: *u8, er: i32, arg: i32): i32;
export extern "C" function pipeline_expr_append_call_arg(a: *u8, er: i32, arg: i32): i32;
export extern "C" function pipeline_expr_append_call_type_arg(a: *u8, er: i32, tr: i32): i32;
export extern "C" function parser_asm_append_type_inst_mangle_c(arena: *u8, nm: *u8, nlen: i32, refs: *i32, n: i32, out: *u8, cap: i32): i32;
const TOKEN_TYPE: i32 = 20;
const TOKEN_IDENT: i32 = 59;
const TOKEN_LPAREN: i32 = 82;
const TOKEN_RPAREN: i32 = 83;
const TOKEN_LBRACE: i32 = 84;
const TOKEN_RBRACE: i32 = 85;
const TOKEN_DOT: i32 = 92;
const TOKEN_LBRACKET: i32 = 86;
const TOKEN_RBRACKET: i32 = 87;
const TOKEN_COMMA: i32 = 90;
const TOKEN_COLON: i32 = 91;
const TOKEN_LT: i32 = 120;
const TOKEN_GT: i32 = 121;
const TOKEN_RSHIFT: i32 = 105;
const TOKEN_SOA: i32 = 22;
const TOKEN_PACKED: i32 = 21;
const EXPR_VAR: i32 = 3;
const EXPR_INDEX: i32 = 47;
const EXPR_CALL: i32 = 48;
const EXPR_METHOD_CALL: i32 = 49;
const EXPR_FINISH_STRUCT_LIT: i32 = 45;

// pthin_expr_primary.x — G-02f-282 P4 parser thin primary product bodies.
//
// 7.2.1 P4b Route C productize (2026-09-13): after P19b helpers, primary.inc
// is the next still-host-cc product slice with a portable buf-path region.
// IDENT spelling probes (unsafe/asm/in/out/lateout/options) and the asm!
// options bit table are Route C (*u8 + length + start + ident_len). Arena
// expr alloc, lexer by-value, and parse_primary_into stay C. parse_primary
// already-T AUDIT_CALL padding is gated in the .inc under
// XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is already ((void)0);
// compiling ~770 lexer-init nops is dead preprocess, not combinator logic).
//
// Hybrid P4b/P4be/P4bf/P4bg/P4bh/P4bi: g05_try_x_to_o this file;
// XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X skips the portable .inc region
// (spelling probes + suffix_loop + IDENT/INT heads + remaining
// parse_primary dest-buffer + parse_struct_lit_fields dest-buffer).
// Cold: no define, full .inc stays.
// 7.2.1 P4be (2026-09-15): suffix_loop / IDENT already lived in this file
// but `-E` XT001'd on check_block of suffix_loop because TOKEN_IDENT /
// LPAREN / RPAREN / LBRACE / TYPE and the method/field/var-name writers
// were used without local pins / externs (typeck treats unknown names as
// check_block fail). Completing the pins makes `-E` typeck OK
// (num_funcs=61).
// 7.2.1 P4bf (2026-09-15): P4be parked BODIES because the C trampoline
// voided r/first_suffix and did not publish lex into out->next_lex.
// IDENT/INT callers then returned a stale cursor; binop/stmt re-parsed
// the same import method (`fmt.println` / `option.none_i32()`) until RSS
// blew up. Root fix is the trampoline copy (C-twin stop contract).
// 7.2.1 P4bg (2026-09-15): IDENT head dispatch. P4be "hello typeck-broke"
// was not a second suffix algorithm — ident_x wrote var_name then called
// pipeline_expr_set_common_zeros_c, which zeros var_name_len (arena twin
// of the C local wipe, which does NOT touch the name slot). typeck then
// saw empty `fmt` / module heads. Fill order is now zeros THEN name, the
// same contract wrap_prep sites already use. The C trampoline copies
// lex_inout into out->next_lex (P4bf stop contract). Do not take
// pending_n's address. Do not FORCE pabi mega.
// 7.2.1 P4bh B-minus (2026-09-16): 有则补全 remaining parse_primary
// dest-buffer (STRING concat, RETURN, PANIC, paren, array lit, LBRACE
// block-vs-struct, plus IF via P5f and MATCH/AT via zero-algorithm
// ptr shims). Dispatcher is a new function — do not grow suffix_loop
// (XT001). Decode is P4bm. match parse / simd parse stay C helpers
// (extra lexer_next / 16-pattern arrays).
// 7.2.1 P4bk (2026-09-16): 有则补全 TOKEN_BREAK / TOKEN_CONTINUE primary
// dest-buffer that P4bh missed. The C twin still had the arm, but the
// .x dispatcher returns 1 with out_ok=0 for unhandled tokens so the
// C arm is unreachable under BODIES. Missing EXPR_BREAK poisoned the
// next function (T001 arity 0:0) — that is the pipeline_abi mega
// "hang/CG002" typeck wall on LARGE xlang. Do not use `break` inside
// this file's nested while (P4bh parse-drop). Do not grow suffix_loop.
// 7.2.1 P4bm B-minus (2026-09-16): 有则补全 STRING decode dest-buffer.
// The escape walk was still host-cc after P4bh (append_byte chunk
// overflow stays C: Expr by-value + var_name[N]). Decode itself has
// no local u8[N]. Independent STRING_DECODE gate so a missing
// decode_x keeps the C loop without dropping P4bh/P4bj. Do not
// dest-buffer append_byte. Do not dest-buffer parse_type_ref.
// Do not FORCE pabi mega.
// 7.2.1 P4bn B-minus (2026-09-16): 有则补全 finish_struct_lit_from_type_ident
// dest-buffer. IDENT VAR placeholder -> EXPR_STRUCT_LIT (kind 45) via
// existing var_name_len / var_name_into + set_common_zeros +
// set_struct_lit_finish (same writer as suffix FIELD_ACCESS and P4bj).
// C trampoline holds name[256] (language has no local u8[N]). Fields
// stay P4bi. Independent FINISH_TYPE_IDENT gate so a missing finish_x
// keeps the C twin without dropping P4bh/P4bj/P4bm. Do not dest-buffer
// append_byte. Do not dest-buffer parse_type_ref. Do not FORCE pabi mega.
// 7.2.1 P4bo B-minus (2026-09-16): 有则补全 parse_asm_bang dest-buffer.
// ident_pre_dispatch still C (thin compositor). Template decode writes
// a C-owned tmpl[256] (cap 127 + overflow note, same as the C twin;
// do NOT reuse STRING decode_span — invalid-escape fallthrough writes
// the backslash, STRING consumed the follower). Register spellings pack
// into C-owned regs[128] then set_method_call_c (does not change kind).
// Option bits go through set_call_c(callee=0, bits) onto
// call_num_type_args. n_in is set_int_val. Independent ASM_BANG gate
// so a missing asm_x keeps the C twin without dropping
// P4bh/P4bj/P4bm/P4bn. Nested while uses flags (no break). Do not
// dest-buffer append_byte / parse_type_ref. Do not FORCE pabi mega.
// 7.2.1 P4bp B-minus (2026-09-16): 有则补全 parse_unsafe dest-buffer.
// ident_pre_dispatch still C (thin compositor). Entry cursor is
// unconsumed TOKEN_LBRACE (caller already matched IDENT unsafe).
// Inner block = parse_block_ptr (lex after `{`, same as P4bh LBRACE
// block). Wrapper block holds one unsafe stmt (order kind=6) whose
// body is the inner block; wrap as EXPR_BLOCK via P5f wrap_block_ref
// (G.7; type_ref=0). Independent UNSAFE gate so a missing unsafe_x
// keeps the C twin without dropping P4bh/P4bj/P4bm/P4bn/P4bo.
// Do not dest-buffer lbrace_looks_like_block / empty_ident_braces.
// Do not dest-buffer append_byte / parse_type_ref. Do not FORCE pabi mega.
// 7.2.1 P4bl (2026-09-16): suffix_loop TOKEN_LT relcompare rewind.
// C twin keeps *lex at `<` until follower is `(` / committed `{` struct
// lit. .x type_ref walk and count-only skip both advance lex_inout;
// without restore, `nfuncs < 150 || nfuncs > 1450` ate the later `>`
// as a generic closer and silently dropped the function (mega T001 on
// asm_module_is_compiler_selfhost because parser_selfhost vanished).
// Restore pos/line/col to `<` and return — leave relcompare to binop.
// Do not dest-buffer IDENT generic type-arg. Do not FORCE pabi mega.
// Block wrap reuses P5f wrap_block_ref (G.7; type_ref=0). Unary
// operand reuses P4uc set_unary_operand_c. C trampoline keeps AUDIT
// and publishes next_lex. Do not dest-buffer parse_type_ref /
// parse_match. Do not merge suffix_loop. Do not FORCE pabi mega.
// pending_n stays a local i32 by value (do not take its address).
// Do not FORCE pabi mega — writers already T.
// 7.2.1 P4bi B-minus (2026-09-16): 有则补全 parse_struct_lit_fields
// dest-buffer. Field names go through a C trampoline that holds
// name[256] (language has no local u8[N]) and forwards
// pipeline_expr_append_struct_lit_field / shorthand VAR alloc.
// Field-value parse_expr bumps struct_field_value_depth in C
// (wave367 empty Type {} vs prefer-block). ident_len<=0 or >255
// fails (C twin; do not clamp 127). P4bj anonymous-struct alloc
// (set_struct_lit_finish nlen=0 + fields). P4bn finish_from_type_ident
// (IDENT placeholder name + same writer). Do not grow
// suffix_loop. Do not merge wrap. Do not dest-buffer
// parse_type_ref / parse_match_into. Do not FORCE pabi mega.
// Helpers ident_is_unsafe_stmt (by-value lexer_result) stays C this wave
// (different ABI: kind==IDENT plus token_start fallback); do not merge
// into these buf probes as a side effect.
// PLATFORM: SHARED freestanding.

/**
 * Bounds check shared by every IDENT spelling probe.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @param want_len i32 — required spelling length
 * @return i32 — 1 if data is live, ident_len==want_len, and the span fits
 */
function parser_asm_primary_ident_span_ok(data: *u8, length: usize, token_start: usize, ident_len: i32, want_len: i32): i32 {
  if (data == 0 as *u8 || ident_len != want_len || ident_len <= 0) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  return 1;
}

/**
 * Read one already-in-span source byte.
 * @param data *u8 — source bytes (non-null; caller checked)
 * @param token_start usize — IDENT start
 * @param i i32 — byte offset within the IDENT
 * @return u8 — data[token_start + i]
 */
function parser_asm_primary_ident_byte(data: *u8, token_start: usize, i: i32): u8 {
  let c: u8 = 0;
  unsafe {
    c = data[token_start + i as usize];
  }
  return c;
}

/**
 * True when IDENT spelling is exactly `unsafe`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the six bytes are `unsafe`; 0 otherwise
 * PLATFORM: SHARED — buf-path authority; slice wrapper stays a C trampoline.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_unsafe_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 6) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 117 && parser_asm_primary_ident_byte(data, token_start, 1) == 110
      && parser_asm_primary_ident_byte(data, token_start, 2) == 115 && parser_asm_primary_ident_byte(data, token_start, 3) == 97
      && parser_asm_primary_ident_byte(data, token_start, 4) == 102 && parser_asm_primary_ident_byte(data, token_start, 5) == 101) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `asm` (stage10 `asm!(...)`).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the three bytes are `asm`; 0 otherwise
 * PLATFORM: SHARED — G.7 primary authority.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_asm_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 3) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 97 && parser_asm_primary_ident_byte(data, token_start, 1) == 115
      && parser_asm_primary_ident_byte(data, token_start, 2) == 109) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `in` (asm operand dir).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the two bytes are `in`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_in_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 2) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 105 && parser_asm_primary_ident_byte(data, token_start, 1) == 110) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `out`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the three bytes are `out`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_out_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 3) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 111 && parser_asm_primary_ident_byte(data, token_start, 1) == 117
      && parser_asm_primary_ident_byte(data, token_start, 2) == 116) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `lateout`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the seven bytes are `lateout`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_lateout_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 7) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 108 && parser_asm_primary_ident_byte(data, token_start, 1) == 97
      && parser_asm_primary_ident_byte(data, token_start, 2) == 116 && parser_asm_primary_ident_byte(data, token_start, 3) == 101
      && parser_asm_primary_ident_byte(data, token_start, 4) == 111 && parser_asm_primary_ident_byte(data, token_start, 5) == 117
      && parser_asm_primary_ident_byte(data, token_start, 6) == 116) {
    return 1;
  }
  return 0;
}

/**
 * True when IDENT spelling is exactly `options`.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if the seven bytes are `options`; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_options_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_ident_span_ok(data, length, token_start, ident_len, 7) == 0) {
    return 0;
  }
  if (parser_asm_primary_ident_byte(data, token_start, 0) == 111 && parser_asm_primary_ident_byte(data, token_start, 1) == 112
      && parser_asm_primary_ident_byte(data, token_start, 2) == 116 && parser_asm_primary_ident_byte(data, token_start, 3) == 105
      && parser_asm_primary_ident_byte(data, token_start, 4) == 111 && parser_asm_primary_ident_byte(data, token_start, 5) == 110
      && parser_asm_primary_ident_byte(data, token_start, 6) == 115) {
    return 1;
  }
  return 0;
}

/**
 * Map IDENT to an asm! options bit, or 0 if unknown.
 * Bits: nostack=1, preserves_flags=2, nomem=4, readonly=8, pure=16, noreturn=32.
 * Stored on EXPR_ASM.call_num_type_args (ASM has no type-args).
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — option bit, or 0
 * PLATFORM: SHARED — G.7 single bit table for parse+emit.
 */
#[no_mangle]
export function parser_asm_primary_asm_option_bit_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (data == 0 as *u8 || ident_len <= 0) {
    return 0;
  }
  if (token_start + ident_len as usize > length) {
    return 0;
  }
  // nostack = 1
  if (ident_len == 7 && parser_asm_primary_ident_byte(data, token_start, 0) == 110
      && parser_asm_primary_ident_byte(data, token_start, 1) == 111 && parser_asm_primary_ident_byte(data, token_start, 2) == 115
      && parser_asm_primary_ident_byte(data, token_start, 3) == 116 && parser_asm_primary_ident_byte(data, token_start, 4) == 97
      && parser_asm_primary_ident_byte(data, token_start, 5) == 99 && parser_asm_primary_ident_byte(data, token_start, 6) == 107) {
    return 1;
  }
  // preserves_flags = 2
  if (ident_len == 15 && parser_asm_primary_ident_byte(data, token_start, 0) == 112
      && parser_asm_primary_ident_byte(data, token_start, 1) == 114 && parser_asm_primary_ident_byte(data, token_start, 2) == 101
      && parser_asm_primary_ident_byte(data, token_start, 3) == 115 && parser_asm_primary_ident_byte(data, token_start, 4) == 101
      && parser_asm_primary_ident_byte(data, token_start, 5) == 114 && parser_asm_primary_ident_byte(data, token_start, 6) == 118
      && parser_asm_primary_ident_byte(data, token_start, 7) == 101 && parser_asm_primary_ident_byte(data, token_start, 8) == 115
      && parser_asm_primary_ident_byte(data, token_start, 9) == 95 && parser_asm_primary_ident_byte(data, token_start, 10) == 102
      && parser_asm_primary_ident_byte(data, token_start, 11) == 108 && parser_asm_primary_ident_byte(data, token_start, 12) == 97
      && parser_asm_primary_ident_byte(data, token_start, 13) == 103 && parser_asm_primary_ident_byte(data, token_start, 14) == 115) {
    return 2;
  }
  // nomem = 4
  if (ident_len == 5 && parser_asm_primary_ident_byte(data, token_start, 0) == 110
      && parser_asm_primary_ident_byte(data, token_start, 1) == 111 && parser_asm_primary_ident_byte(data, token_start, 2) == 109
      && parser_asm_primary_ident_byte(data, token_start, 3) == 101 && parser_asm_primary_ident_byte(data, token_start, 4) == 109) {
    return 4;
  }
  // readonly = 8
  if (ident_len == 8 && parser_asm_primary_ident_byte(data, token_start, 0) == 114
      && parser_asm_primary_ident_byte(data, token_start, 1) == 101 && parser_asm_primary_ident_byte(data, token_start, 2) == 97
      && parser_asm_primary_ident_byte(data, token_start, 3) == 100 && parser_asm_primary_ident_byte(data, token_start, 4) == 111
      && parser_asm_primary_ident_byte(data, token_start, 5) == 110 && parser_asm_primary_ident_byte(data, token_start, 6) == 108
      && parser_asm_primary_ident_byte(data, token_start, 7) == 121) {
    return 8;
  }
  // pure = 16
  if (ident_len == 4 && parser_asm_primary_ident_byte(data, token_start, 0) == 112
      && parser_asm_primary_ident_byte(data, token_start, 1) == 117 && parser_asm_primary_ident_byte(data, token_start, 2) == 114
      && parser_asm_primary_ident_byte(data, token_start, 3) == 101) {
    return 16;
  }
  // noreturn = 32
  if (ident_len == 8 && parser_asm_primary_ident_byte(data, token_start, 0) == 110
      && parser_asm_primary_ident_byte(data, token_start, 1) == 111 && parser_asm_primary_ident_byte(data, token_start, 2) == 114
      && parser_asm_primary_ident_byte(data, token_start, 3) == 101 && parser_asm_primary_ident_byte(data, token_start, 4) == 116
      && parser_asm_primary_ident_byte(data, token_start, 5) == 117 && parser_asm_primary_ident_byte(data, token_start, 6) == 114
      && parser_asm_primary_ident_byte(data, token_start, 7) == 110) {
    return 32;
  }
  return 0;
}

/**
 * True when IDENT is a known Rust-style asm! option name.
 * @param data *u8 — source bytes; null is 0
 * @param length usize — source length
 * @param token_start usize — first IDENT byte
 * @param ident_len i32 — IDENT payload length
 * @return i32 — 1 if option_bit != 0; 0 otherwise
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_primary_ident_is_asm_option_name_buf_c(data: *u8, length: usize, token_start: usize, ident_len: i32): i32 {
  if (parser_asm_primary_asm_option_bit_buf_c(data, length, token_start, ident_len) != 0) {
    return 1;
  }
  return 0;
}

/**
 * Literal-arm handler (primary literal wave): FLOAT / TRUE / FALSE / NULL
 * tokens fill a fresh arena Expr through the wave-0 writer family (no Expr
 * by-value). Peeks the next token; when it is one of the four literal kinds
 * the payload is read FIRST, the cursor is then advanced in place (step
 * keeps pos+line+col exact), and the Expr is filled + common-zeroed.
 * The INT arm is NOT handled here (it shares the ident suffix chain and
 * migrates with that wave).
 * @param arena *u8 — opaque ASTArena
 * @param lex_inout *u8 — cursor; advanced only when the token is handled
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — 1 when handled (expr written), 0 otherwise
 * @param out_expr_ref *i32 — fresh Expr ref on success
 * @return i32 — 1 handled (check out_ok for alloc failure); 0 not a
 *   literal token (caller falls through to the C arms)
 * PLATFORM: SHARED — product primary literal wave; dispatched from
 * parser_asm_parse_primary_into_slice_c under
 * XLANG_PTHIN_EXPR_PRIMARY_BODIES_FROM_X. NULL keeps the keyword tag via
 * pipeline_expr_tag_null_keyword_c (G.7 single primary path).
 */
#[no_mangle]
export function parser_asm_primary_literal_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let fval: f64 = 0 as f64;
  let tl: i32 = 0;
  let tc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_FLOAT && kind != TOKEN_TRUE && kind != TOKEN_FALSE && kind != TOKEN_NULL && kind != TOKEN_INT) {
      return 0;
    }
    let iv: i64 = 0;
    if (kind == TOKEN_INT) {
      parser_asm_lex_peek_int64_val_into_c(lex_inout, source, &iv);
    } else if (kind == TOKEN_FLOAT) {
      parser_asm_lex_peek_float_val_into_c(lex_inout, source, &fval);
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (kind == TOKEN_INT) {
      /* INT head + suffix chain (`.method()`/`[i]`/`<T>()`) — the C arm
       * steps past the literal once then enters the suffix loop; the .x
       * loop re-peeks purely. The step above already consumed INT; do
       * not step again (that would swallow the first suffix token). */
      pipeline_expr_set_kind(arena, ref, EXPR_LIT);
      pipeline_expr_set_line_col(arena, ref, tl, tc);
      pipeline_expr_set_int_val(arena, ref, iv);
      pipeline_expr_set_common_zeros_c(arena, ref);
      out_ok[0] = 1;
      out_expr_ref[0] = ref;
      parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
      return 1;
    }
    if (kind == TOKEN_FLOAT) {
      pipeline_expr_set_kind(arena, ref, EXPR_FLOAT_LIT);
      pipeline_expr_set_float_val(arena, ref, fval);
      pipeline_expr_set_line_col(arena, ref, 0, 0);
      pipeline_expr_set_common_zeros_c(arena, ref);
    } else if (kind == TOKEN_TRUE || kind == TOKEN_FALSE) {
      pipeline_expr_set_kind(arena, ref, EXPR_BOOL_LIT);
      if (kind == TOKEN_TRUE) {
        pipeline_expr_set_int_val(arena, ref, 1);
      } else {
        pipeline_expr_set_int_val(arena, ref, 0);
      }
      pipeline_expr_set_line_col(arena, ref, 0, 0);
      pipeline_expr_set_common_zeros_c(arena, ref);
    } else {
      pipeline_expr_set_kind(arena, ref, EXPR_LIT);
      pipeline_expr_set_line_col(arena, ref, tl, tc);
      pipeline_expr_set_int_val(arena, ref, 0);
      pipeline_expr_set_common_zeros_c(arena, ref);
      pipeline_expr_tag_null_keyword_c(arena, ref);
    }
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    return 1;
  }
  return 0;
}

/**
 * The primary suffix chain loop (.x mirror of
 * parser_asm_primary_ident_suffix_loop_c): repeatedly wraps out_expr_ref in
 * FIELD_ACCESS / METHOD_CALL / INDEX / CALL / turbofish-pending /
 * qualified-STRUCT_LIT nodes for `.name`, `name(`, `[i]`, `<T>(`, `{`
 * followers. Shared by the INT and IDENT arms via the gated C wrapper.
 *
 * Cursor model: the C loop caches a peeked lexer_result in `r`; peeks are
 * pure, so this body re-peeks at need and consumes with lex_step_kind
 * (pos+line+col exact). The field path's `lex_at_token(*r)` realign maps to
 * the five-peek + at_token_pos idiom.
 *
 * Buffers (trampoline-owned; the language has no local arrays):
 *   mc_arg_buf[256] arg_buf[256] parsed_refs[8] pending_refs[8]
 *   mangled[128] name_buf[256]
 *
 * Semantic invariants mirrored verbatim (see the C comments):
 *   - args parse fully into staging, THEN append (nested-call slot safety)
 *   - turbofish: real type_refs first; count-only fallback leaves refs empty
 *   - LT with neither `{` nor `(` after the angles leaves `<` for relcompare
 *   - LBRACE converts FIELD_ACCESS only, after the two block-pref checks
 *   - wave607: qualified struct lit continues the chain
 *   - stall guard: same pos+kind 4096 times -> hard fail
 * @return void — failures write out_ok=0; stop leaves the cursor at the
 *   first non-suffix token. The C trampoline (not this body) copies
 *   lex_inout into out->next_lex; that is the C-twin stop contract.
 * PLATFORM: SHARED — product primary suffix loop (EXPR_PRIMARY gate).
 */
#[no_mangle]
export function parser_asm_primary_suffix_loop_x_into_c(arena: *u8, source: *u8, lex_inout: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): void {
  let kind: i32 = 0;
  let k2: i32 = 0;
  let k3: i32 = 0;
  let prev_kind: i32 = -1;
  let prev_pos: usize = 0;
  let stall: i32 = 0;
  let mname_len: i32 = 0;
  let mname_start: usize = 0;
  let mc_ref: i32 = 0;
  let fa_ref: i32 = 0;
  let idx_ref: i32 = 0;
  let call_ref: i32 = 0;
  let callee_ref: i32 = 0;
  let base_ref: i32 = 0;
  let n: i32 = 0;
  let ai: i32 = 0;
  let ok2: i32 = 0;
  let eref2: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  let pending_n: i32 = 0;
  let pi: i32 = 0;
  let parse_ok: i32 = 0;
  let tr: i32 = 0;
  let count: i32 = 0;
  let tlen: i32 = 0;
  let mlen: i32 = 0;
  let prefer_block: i32 = 0;
  let ts: usize = 0;
  let il: i32 = 0;
  let np: usize = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let lt_line: i32 = 0;
  let lt_col: i32 = 0;
  if (arena == 0 as *u8 || source == 0 as *u8 || lex_inout == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return;
  }
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    pi = 0;
    while (pi < 8) {
      pending_refs[pi] = 0;
      pi = pi + 1;
    }
    loop {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (parser_asm_lex_pos_c(lex_inout) == prev_pos && kind == prev_kind) {
        stall = stall + 1;
        if (stall >= 4096) {
          out_ok[0] = 0;
          return;
        }
      } else {
        stall = 0;
      }
      prev_pos = parser_asm_lex_pos_c(lex_inout);
      prev_kind = kind;
      if (kind == TOKEN_DOT) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        mname_len = -1;
        if (k2 == TOKEN_IDENT) {
          mname_len = parser_asm_lex_peek_ident_len_c(lex_inout, source);
          if (mname_len <= 0) {
            mname_len = -1;
          }
        } else if (k2 == TOKEN_TYPE) {
          mname_len = 4;
        } else if (k2 == TOKEN_SOA) {
          mname_len = 3;
        } else if (k2 == TOKEN_PACKED) {
          mname_len = 6;
        }
        if (mname_len < 0) {
          return;
        }
        if (mname_len > 255) {
          mname_len = 127;
        }
        mname_start = parser_asm_lex_peek_token_start_c(lex_inout, source);
        parser_asm_lex_step_kind_c(lex_inout, source);
        k3 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k3 == TOKEN_LPAREN) {
          mc_ref = ast_ast_arena_expr_alloc(arena);
          if (mc_ref == 0) {
            out_ok[0] = 0;
            return;
          }
          pipeline_expr_set_common_zeros_c(arena, mc_ref);
          pipeline_expr_set_kind(arena, mc_ref, EXPR_METHOD_CALL);
          pipeline_expr_set_method_call_c(arena, mc_ref, out_expr_ref[0], data + mname_start, mname_len);
          pipeline_expr_set_line_col(arena, mc_ref, 0, 0);
          out_expr_ref[0] = mc_ref;
          parser_asm_lex_step_kind_c(lex_inout, source);
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (k2 != TOKEN_RPAREN) {
            n = 0;
            loop {
              if (n >= 256) {
                out_ok[0] = 0;
                return;
              }
              ok2 = 0;
              eref2 = 0;
              if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2, &eref2) == 0) {
                out_ok[0] = 0;
                return;
              }
              if (ok2 == 0) {
                out_ok[0] = 0;
                return;
              }
              mc_arg_buf[n] = eref2;
              n = n + 1;
              k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
              if (k2 == TOKEN_COMMA) {
                parser_asm_lex_step_kind_c(lex_inout, source);
                continue;
              }
              if (k2 == TOKEN_RPAREN) {
                parser_asm_lex_step_kind_c(lex_inout, source);
                ai = 0;
                while (ai < n) {
                  if (pipeline_expr_append_method_call_arg(arena, mc_ref, mc_arg_buf[ai]) < 0) {
                    out_ok[0] = 0;
                    return;
                  }
                  ai = ai + 1;
                }
                break;
              }
              out_ok[0] = 0;
              return;
            }
          } else {
            parser_asm_lex_step_kind_c(lex_inout, source);
          }
        } else {
          fa_ref = ast_ast_arena_expr_alloc(arena);
          if (fa_ref == 0) {
            out_ok[0] = 0;
            return;
          }
          pipeline_expr_set_common_zeros_c(arena, fa_ref);
          pipeline_expr_set_kind(arena, fa_ref, EXPR_FIELD_ACCESS);
          pipeline_expr_set_field_access_c(arena, fa_ref, out_expr_ref[0], data + mname_start, mname_len);
          pipeline_expr_set_line_col(arena, fa_ref, 0, 0);
          out_expr_ref[0] = fa_ref;
          /* Field path realigns the cursor AT the follower token start
           * (C: lex_at_token_from_result(*r)) — the five-peek idiom. */
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
          il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
          np = parser_asm_lex_peek_next_pos_c(lex_inout, source);
          tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
          tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
          parser_asm_lex_set_pos_c(lex_inout, parser_asm_lex_at_token_pos_c(k2, ts, il, np));
          parser_asm_lex_set_line_c(lex_inout, tl);
          parser_asm_lex_set_col_c(lex_inout, tc);
        }
      } else if (kind == TOKEN_LT) {
        /* Turbofish: real type_refs first; on unparsable fall back count-only.
         * Neither `{` nor `(` after the angles leaves `<` for relcompare.
         * P4bl: save `<` pos/line/col (prev_pos is already the `<` byte)
         * BEFORE step. C twin never moves *lex until follower is `(`. */
        parse_ok = 1;
        n = 0;
        pi = 0;
        lt_line = parser_asm_lex_line_c(lex_inout);
        lt_col = parser_asm_lex_col_c(lex_inout);
        while (pi < 8) {
          parsed_refs[pi] = 0;
          pi = pi + 1;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        if (parser_asm_lex_peek_kind_c(lex_inout, source) == TOKEN_GT || parser_asm_lex_peek_kind_c(lex_inout, source) == TOKEN_RSHIFT) {
          parse_ok = 0;
        }
        if (parse_ok != 0) {
          loop {
            if (n >= 8) {
              parse_ok = 0;
              break;
            }
            tr = parser_asm_parse_type_ref_ptr_into_c(arena, lex_inout, source);
            if (tr <= 0) {
              parse_ok = 0;
              break;
            }
            parsed_refs[n] = tr;
            n = n + 1;
            k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (k2 == TOKEN_COMMA) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (k2 == TOKEN_GT) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              break;
            }
            if (k2 == TOKEN_RSHIFT) {
              /* Nested `>>`: close this level, leave one `>` — set cursor
               * past the FIRST '>' only (C: lex.pos+1 style split). */
              parser_asm_lex_set_pos_c(lex_inout, parser_asm_lex_pos_c(lex_inout) + 1);
              break;
            }
            parse_ok = 0;
            break;
          }
        }
        if (parse_ok != 0) {
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (k2 == TOKEN_LBRACE) {
            /* Generic struct lit `Type<T>{...}` on a VAR head.
             * P4bl: do not rewind these returns — cursor stays past `>`
             * so finish_struct_lit / prefer-block can see `{`. Rewinding
             * here P001'd `Wrap<i32>{ val: 1 }` (P4bk parsed that head). */
            if (pipeline_expr_kind_ord_at(arena, out_expr_ref[0]) != EXPR_VAR) {
              return;
            }
            if (pipeline_expr_var_name_len(arena, out_expr_ref[0]) <= 0) {
              return;
            }
            prefer_block = 0;
            if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
              prefer_block = 1;
            } else if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) == 1) {
              prefer_block = 1;
            }
            if (prefer_block != 0) {
              return;
            }
            tlen = pipeline_expr_var_name_len(arena, out_expr_ref[0]);
            pipeline_expr_var_name_into(arena, out_expr_ref[0], name_buf);
            mlen = parser_asm_append_type_inst_mangle_c(arena, name_buf, tlen, parsed_refs, n, mangled, 128);
            if (mlen <= 0 || mlen > 255) {
              out_ok[0] = 0;
              return;
            }
            pipeline_expr_set_var_name(arena, out_expr_ref[0], mangled, mlen);
            parser_asm_lex_step_kind_c(lex_inout, source);
            ok2 = 0;
            eref2 = 0;
            parser_finish_struct_lit_ptr_into_c(arena, out_expr_ref[0], lex_inout, source, &ok2, &eref2);
            if (ok2 == 0) {
              out_ok[0] = 0;
              return;
            }
            out_expr_ref[0] = eref2;
            pending_n = 0;
            pi = 0;
            while (pi < 8) {
              pending_refs[pi] = 0;
              pi = pi + 1;
            }
            continue;
          }
          if (k2 != TOKEN_LPAREN) {
            /* P4bl: not a turbofish call — restore `<` for relcompare
             * (C: out->next_lex = *lex still at TOKEN_LT). */
            parser_asm_lex_set_pos_c(lex_inout, prev_pos);
            parser_asm_lex_set_line_c(lex_inout, lt_line);
            parser_asm_lex_set_col_c(lex_inout, lt_col);
            return;
          }
          pending_n = n;
          pi = 0;
          while (pi < n && pi < 8) {
            pending_refs[pi] = parsed_refs[pi];
            pi = pi + 1;
          }
          while (pi < 8) {
            pending_refs[pi] = 0;
            pi = pi + 1;
          }
          /* Cursor stays past the '>' (already consumed above). */
        } else {
          /* Count-only fallback: restart from '<'. */
          parser_asm_lex_set_pos_c(lex_inout, prev_pos);
          parser_asm_skip_angle_count_ptr_into_c(lex_inout, source, &count);
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (k2 != TOKEN_LPAREN) {
            /* P4bl: skip found a later `>` (often `a < x || a > y`).
             * C twin leaves *lex at `<`; commit only when follower is `(`. */
            parser_asm_lex_set_pos_c(lex_inout, prev_pos);
            parser_asm_lex_set_line_c(lex_inout, lt_line);
            parser_asm_lex_set_col_c(lex_inout, lt_col);
            return;
          }
          pending_n = count;
          pi = 0;
          while (pi < 8) {
            pending_refs[pi] = 0;
            pi = pi + 1;
          }
        }
      } else if (kind == TOKEN_LBRACKET) {
        base_ref = out_expr_ref[0];
        parser_asm_lex_step_kind_c(lex_inout, source);
        ok2 = 0;
        eref2 = 0;
        if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2, &eref2) == 0) {
          out_ok[0] = 0;
          return;
        }
        if (ok2 == 0) {
          out_ok[0] = 0;
          return;
        }
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k2 != TOKEN_RBRACKET) {
          out_ok[0] = 0;
          return;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        idx_ref = ast_ast_arena_expr_alloc(arena);
        if (idx_ref == 0) {
          out_ok[0] = 0;
          return;
        }
        pipeline_expr_set_common_zeros_c(arena, idx_ref);
        pipeline_expr_set_kind(arena, idx_ref, EXPR_INDEX);
        pipeline_expr_set_index_c(arena, idx_ref, base_ref, eref2, 0);
        pipeline_expr_set_line_col(arena, idx_ref, 0, 0);
        out_expr_ref[0] = idx_ref;
      } else if (kind == TOKEN_LPAREN) {
        callee_ref = out_expr_ref[0];
        parser_asm_lex_step_kind_c(lex_inout, source);
        call_ref = ast_ast_arena_expr_alloc(arena);
        if (call_ref == 0) {
          out_ok[0] = 0;
          return;
        }
        pipeline_expr_set_common_zeros_c(arena, call_ref);
        pipeline_expr_set_kind(arena, call_ref, EXPR_CALL);
        pipeline_expr_set_line_col(arena, call_ref, 0, 0);
        pipeline_expr_set_call_c(arena, call_ref, callee_ref, pending_n);
        if (pending_n > 0 && pending_refs[0] > 0) {
          ai = 0;
          while (ai < pending_n && ai < 8) {
            if (pending_refs[ai] <= 0) {
              break;
            }
            if (pipeline_expr_append_call_type_arg(arena, call_ref, pending_refs[ai]) < 0) {
              out_ok[0] = 0;
              return;
            }
            ai = ai + 1;
          }
        }
        pending_n = 0;
        pi = 0;
        while (pi < 8) {
          pending_refs[pi] = 0;
          pi = pi + 1;
        }
        n = 0;
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k2 != TOKEN_RPAREN) {
          loop {
            if (n >= 256) {
              out_ok[0] = 0;
              return;
            }
            ok2 = 0;
            eref2 = 0;
            if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &ok2, &eref2) == 0) {
              out_ok[0] = 0;
              return;
            }
            if (ok2 == 0) {
              out_ok[0] = 0;
              return;
            }
            arg_buf[n] = eref2;
            n = n + 1;
            k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
            if (k2 == TOKEN_COMMA) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              continue;
            }
            if (k2 == TOKEN_RPAREN) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              break;
            }
            out_ok[0] = 0;
            return;
          }
        } else {
          parser_asm_lex_step_kind_c(lex_inout, source);
        }
        ai = 0;
        while (ai < n) {
          if (pipeline_expr_append_call_arg(arena, call_ref, arg_buf[ai]) < 0) {
            out_ok[0] = 0;
            return;
          }
          ai = ai + 1;
        }
        out_expr_ref[0] = call_ref;
      } else if (kind == TOKEN_LBRACE) {
        /* Qualified struct lit `Mod.Type { ... }` — FIELD_ACCESS heads only,
         * after the two block-pref authorities; wave607 continues the chain. */
        if (pipeline_expr_kind_ord_at(arena, out_expr_ref[0]) != EXPR_FIELD_ACCESS) {
          return;
        }
        prefer_block = 0;
        if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
          prefer_block = 1;
        } else if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) == 1) {
          prefer_block = 1;
        }
        if (prefer_block != 0) {
          return;
        }
        /* Convert: field name -> struct-lit head (kind 45 + name), then
         * parse fields. Name source = the live field_access name buffer. */
        tlen = 0;
        /* field name length lives on the expr; read via the writer family's
         * twin (no reader for field name) — reuse var_name reader is wrong;
         * the C reads fae.field_access_field_name directly. Read bridge:
         * none staged, so keep the conversion on the C side via the staged
         * conversion writer taking the SOURCE bytes: rebuild from mname. */
        /* The C copies fae.field_access_field_name[128] out then into
         * struct_lit_struct_name. Without a field-name reader, mirror by
         * re-deriving the name bytes is unsafe; instead call the arena-side
         * conversion helper that reads in place. */
        tlen = pipeline_expr_field_name_len_at(arena, out_expr_ref[0]);
        if (tlen <= 0 || tlen > 255) {
          out_ok[0] = 0;
          return;
        }
        pipeline_expr_field_name_into(arena, out_expr_ref[0], name_buf);
        parser_asm_lex_step_kind_c(lex_inout, source);
        pipeline_expr_set_common_zeros_c(arena, out_expr_ref[0]);
        pipeline_expr_set_struct_lit_finish_c(arena, out_expr_ref[0], name_buf, tlen);
        pipeline_expr_set_line_col(arena, out_expr_ref[0], 0, 0);
        ok2 = 0;
        eref2 = 0;
        parser_asm_parse_struct_lit_fields_ptr_c(arena, out_expr_ref[0], lex_inout, source, &ok2, &eref2);
        if (ok2 == 0) {
          out_ok[0] = 0;
          return;
        }
        out_expr_ref[0] = eref2;
        continue;
      } else {
        return;
      }
    }
  }
}

/**
 * IDENT/SELF primary head (.x mirror of the IDENT arm): pre-dispatch fat
 * shim (unsafe-expr / asm-bang sub-parsers stay C), then the VAR fill
 * (kind 3 + token line/col + zeros + source name copy), the Type{...}
 * struct-lit LBRACE dance (two block-pref authorities; on prefer-block
 * restore the cursor AT the '{' and stop), and the .x suffix loop
 * (wave607 continuation). Keyword `self` skips the struct-lit path.
 * P4bg: pipeline_expr_set_common_zeros_c zeros var_name_len; the name
 * copy MUST follow zeros (C local wipe does not touch the name slot, so
 * the C arm could copy-then-zero). The C trampoline publishes next_lex.
 * @param buffers — the six suffix-loop trampoline buffers (dispatcher-owned)
 * @return i32 — 1 handled (check out_ok for inner failures); 0 not IDENT/SELF
 * PLATFORM: SHARED — product primary IDENT arm (EXPR_PRIMARY gate).
 */
#[no_mangle]
export function parser_asm_primary_ident_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32 {
  let kind: i32 = 0;
  let vlen: i32 = 0;
  let name_was_self: i32 = 0;
  let ref: i32 = 0;
  let ts: usize = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let pos0: usize = 0;
  let line0: i32 = 0;
  let col0: i32 = 0;
  let data: *u8 = 0 as *u8;
  let ok2: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT && kind != TOKEN_SELF) {
      return 0;
    }
    /* unsafe-expr / asm! sub-parsers (whole-sale C via the fat shim). */
    ok2 = 0;
    ref = 0;
    if (parser_asm_ident_pre_dispatch_ptr_c(arena, lex_inout, source, &ok2, &ref) != 0) {
      out_ok[0] = ok2;
      out_expr_ref[0] = ref;
      return 1;
    }
    name_was_self = 0;
    vlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind == TOKEN_SELF) {
      name_was_self = 1;
      vlen = 4;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    pipeline_expr_set_kind(arena, ref, EXPR_VAR_LIT);
    pipeline_expr_set_line_col(arena, ref, tl, tc);
    /* Arena zeros wipe var_name_len (count field). Write the IDENT
     * payload AFTER the wipe so typeck still sees `fmt` / module heads.
     * C local zeros skip the name slot, which is why copy-then-zero
     * worked on the C arm and failed here. */
    pipeline_expr_set_common_zeros_c(arena, ref);
    pipeline_expr_set_var_name(arena, ref, data + ts, vlen);
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LBRACE && name_was_self == 0) {
      /* Type { ... } struct lit — but bare if/while bodies win per the two
       * authorities. Snapshot, step past '{', predicate on the after-brace
       * cursor; on prefer-block restore AT the '{' and stop (leave it). */
      pos0 = parser_asm_lex_pos_c(lex_inout);
      line0 = parser_asm_lex_line_c(lex_inout);
      col0 = parser_asm_lex_col_c(lex_inout);
      parser_asm_lex_step_kind_c(lex_inout, source);
      if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      if (parser_asm_empty_ident_braces_prefer_block_ptr_c(lex_inout, source) == 1) {
        parser_asm_lex_set_pos_c(lex_inout, pos0);
        parser_asm_lex_set_line_c(lex_inout, line0);
        parser_asm_lex_set_col_c(lex_inout, col0);
        return 1;
      }
      ok2 = 0;
      ref = 0;
      parser_finish_struct_lit_ptr_into_c(arena, out_expr_ref[0], lex_inout, source, &ok2, &ref);
      if (ok2 == 0) {
        out_ok[0] = 0;
        return 1;
      }
      out_expr_ref[0] = ref;
    }
    parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    return 1;
  }
  return 0;
}

/**
 * Decode one TOKEN_STRING span (product escapes) onto an existing
 * STRING_LIT head, appending (adjacent concat). G.7 ≡ parser.x
 * parser_string_lit_decode_span / C twin parser_asm_string_lit_decode_span_c.
 * Byte walk has no local u8[N]. Chunk overflow writes stay C
 * (parser_asm_string_lit_append_byte_ptr_c: Expr by-value + var_name[N]).
 * @param arena *u8 — opaque AST arena; null → -1
 * @param head_ref i32 — STRING_LIT head; <=0 → -1
 * @param source *u8 — opaque slice; null → -1
 * @param q0 usize — token_start (first payload byte after the open quote)
 * @param nlen i32 — token ident_len; <0 treated as 0
 * @param line i32 — overflow diag line (forwarded to append_byte)
 * @param col i32 — overflow diag col
 * @return i32 — 0 ok; -1 L011 / null
 * PLATFORM: SHARED — P4bm dest-buffer of the former host-cc decode loop.
 * Do not dest-buffer append_byte. Do not dest-buffer parse_type_ref.
 * Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_string_lit_decode_span_x_into_c(arena: *u8, head_ref: i32, source: *u8, q0: usize, nlen: i32, line: i32, col: i32): i32 {
  let ri: i32 = 0;
  let c: u8 = 0;
  let b: u8 = 0;
  let n: u8 = 0;
  let consumed: i32 = 0;
  let h1: u8 = 0;
  let h2: u8 = 0;
  let v1: i32 = 0;
  let v2: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  if (arena == 0 as *u8 || source == 0 as *u8 || head_ref <= 0) {
    return 0 - 1;
  }
  if (nlen < 0) {
    nlen = 0;
  }
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    if (data == 0 as *u8) {
      return 0 - 1;
    }
    ri = 0;
    while (ri < nlen) {
      c = 0;
      consumed = 1;
      if (q0 + (ri as usize) < slen) {
        c = parser_asm_primary_ident_byte(data, q0, ri);
      }
      b = c;
      if (c == 92 && (ri + 1) < nlen) {
        n = 0;
        if (q0 + ((ri + 1) as usize) < slen) {
          n = parser_asm_primary_ident_byte(data, q0, ri + 1);
        }
        if (n == 110) {
          b = 10;
          consumed = 2;
        } else if (n == 116) {
          b = 9;
          consumed = 2;
        } else if (n == 114) {
          b = 13;
          consumed = 2;
        } else if (n == 48) {
          b = 0;
          consumed = 2;
        } else if (n == 92 || n == 34) {
          b = n;
          consumed = 2;
        } else if (n == 120 && (ri + 3) < nlen) {
          h1 = 0;
          h2 = 0;
          v1 = 0 - 1;
          v2 = 0 - 1;
          if (q0 + ((ri + 2) as usize) < slen) {
            h1 = parser_asm_primary_ident_byte(data, q0, ri + 2);
          }
          if (q0 + ((ri + 3) as usize) < slen) {
            h2 = parser_asm_primary_ident_byte(data, q0, ri + 3);
          }
          if (h1 >= 48 && h1 <= 57) {
            v1 = (h1 as i32) - 48;
          }
          if (h1 >= 97 && h1 <= 102) {
            v1 = (h1 as i32) - 97 + 10;
          }
          if (h1 >= 65 && h1 <= 70) {
            v1 = (h1 as i32) - 65 + 10;
          }
          if (h2 >= 48 && h2 <= 57) {
            v2 = (h2 as i32) - 48;
          }
          if (h2 >= 97 && h2 <= 102) {
            v2 = (h2 as i32) - 97 + 10;
          }
          if (h2 >= 65 && h2 <= 70) {
            v2 = (h2 as i32) - 65 + 10;
          }
          if (v1 >= 0 && v2 >= 0) {
            b = ((v1 * 16) + v2) as u8;
            consumed = 4;
          } else {
            b = n;
            consumed = 2;
          }
        } else {
          b = n;
          consumed = 2;
        }
      }
      if (parser_asm_string_lit_append_byte_ptr_c(arena, head_ref, b as i32, line, col) != 0) {
        return 0 - 1;
      }
      ri = ri + consumed;
    }
    return 0;
  }
  return 0;
}

/**
 * STRING primary: decode the first TOKEN_STRING span, then concatenate
 * adjacent STRING tokens (wave282). Decode is P4bm dest-buffer
 * (append_byte chunk overflow stays C).
 * @param arena *u8 — opaque AST arena
 * @param lex_inout *u8 — cursor at STRING; parked after the last concat
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — 1 on success
 * @param out_expr_ref *i32 — EXPR_STRING_LIT head
 * @return i32 — 1 handled; 0 not STRING
 * PLATFORM: SHARED — P4bh STRING arm. Decode authority is P4bm.
 */
function parser_asm_primary_string_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let q0: usize = 0;
  let nlen: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRING) {
      return 0;
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    pipeline_expr_set_kind(arena, ref, EXPR_STRING_LIT);
    pipeline_expr_set_line_col(arena, ref, tl, tc);
    pipeline_expr_set_common_zeros_c(arena, ref);
    if (parser_asm_string_lit_decode_span_ptr_c(arena, ref, source, q0, nlen, tl, tc) != 0) {
      out_ok[0] = 0;
      return 1;
    }
    while (1 == 1) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_STRING) {
        break;
      }
      q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
      nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      if (parser_asm_string_lit_decode_span_ptr_c(arena, ref, source, q0, nlen, tl, tc) != 0) {
        out_ok[0] = 0;
        return 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    return 1;
  }
  return 0;
}

/**
 * BREAK / CONTINUE primary (`break;` / `continue;` as a statement expr).
 * Mirrors the C twin in parser_asm_primary_slice.inc (PARSER_ASM_EXPR_BREAK=39
 * / CONTINUE=40). Peek, step the keyword, alloc, set kind + line/col +
 * common zeros. No operand. Semicolon stays for parse_block.
 * @param arena *u8 — opaque ASTArena; null → 0
 * @param lex_inout *u8 — cursor; advanced only when the token is handled
 * @param source *u8 — opaque source slice
 * @param out_ok *i32 — 1 on success, 0 on alloc failure
 * @param out_expr_ref *i32 — fresh Expr ref on success
 * @return i32 — 1 handled (BREAK or CONTINUE); 0 not those tokens
 * PLATFORM: SHARED — P4bk 有则补全 of P4bh remaining parse_primary.
 * Do not `break` out of a while in this helper (P4bh parse-drop).
 */
function parser_asm_primary_break_continue_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let ek: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_BREAK && kind != TOKEN_CONTINUE) {
      return 0;
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    if (kind == TOKEN_BREAK) {
      ek = EXPR_BREAK;
    } else {
      ek = EXPR_CONTINUE;
    }
    pipeline_expr_set_kind(arena, ref, ek);
    pipeline_expr_set_line_col(arena, ref, tl, tc);
    pipeline_expr_set_common_zeros_c(arena, ref);
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    return 1;
  }
  return 0;
}

/**
 * RETURN primary (`return` / `return expr`) for match-arm results.
 * Terminator peek does not consume (`;` `}` EOF `,` `=>` stay for the
 * caller). Operand parse reuses parse_expr_ptr (G.7).
 * @return i32 — 1 handled; 0 not RETURN
 * PLATFORM: SHARED — P4bh RETURN arm.
 */
function parser_asm_primary_return_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RETURN) {
      return 0;
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    parser_asm_lex_step_kind_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    pipeline_expr_set_kind(arena, ref, EXPR_RETURN);
    pipeline_expr_set_line_col(arena, ref, tl, tc);
    pipeline_expr_set_common_zeros_c(arena, ref);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_SEMICOLON && kind != TOKEN_RBRACE && kind != TOKEN_EOF && kind != TOKEN_COMMA && kind != TOKEN_FATARROW) {
      eok = 0;
      eref = 0;
      if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0) {
        out_ok[0] = 0;
        return 1;
      }
      pipeline_expr_set_unary_operand_c(arena, ref, eref);
    }
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    return 1;
  }
  return 0;
}

/**
 * PANIC primary (`panic` / `panic(expr)`). Line/col stay 0,0 (C twin).
 * @return i32 — 1 handled; 0 not PANIC
 * PLATFORM: SHARED — P4bh PANIC arm.
 */
function parser_asm_primary_panic_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  let panic_op: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_PANIC) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_RPAREN) {
        eok = 0;
        eref = 0;
        if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0) {
          out_ok[0] = 0;
          return 1;
        }
        panic_op = eref;
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_RPAREN) {
          out_ok[0] = 0;
          return 1;
        }
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
    }
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    pipeline_expr_set_kind(arena, ref, EXPR_PANIC);
    pipeline_expr_set_common_zeros_c(arena, ref);
    pipeline_expr_set_unary_operand_c(arena, ref, panic_op);
    pipeline_expr_set_line_col(arena, ref, 0, 0);
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    return 1;
  }
  return 0;
}

/**
 * `(expr)` grouping primary, then the shared suffix loop.
 * @return i32 — 1 handled; 0 not LPAREN
 * PLATFORM: SHARED — P4bh paren arm. Suffix loop is P4bf (G.7).
 */
function parser_asm_primary_paren_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32 {
  let kind: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    eok = 0;
    eref = 0;
    if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0) {
      out_ok[0] = 0;
      return 1;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RPAREN) {
      out_ok[0] = 0;
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    out_ok[0] = 1;
    out_expr_ref[0] = eref;
    parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    return 1;
  }
  return 0;
}

/**
 * `[ e0, ... ]` / `[]` array-lit primary, then the shared suffix loop.
 * @return i32 — 1 handled; 0 not LBRACKET
 * PLATFORM: SHARED — P4bh array arm.
 */
function parser_asm_primary_array_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32 {
  let kind: i32 = 0;
  let ref: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACKET) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out_ok[0] = 0;
      return 1;
    }
    pipeline_expr_set_kind(arena, ref, EXPR_ARRAY_LIT);
    pipeline_expr_set_common_zeros_c(arena, ref);
    pipeline_expr_set_line_col(arena, ref, 0, 0);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RBRACKET) {
      while (1 == 1) {
        eok = 0;
        eref = 0;
        if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0 || eref == 0) {
          out_ok[0] = 0;
          return 1;
        }
        if (pipeline_expr_append_array_lit_elem(arena, ref, eref) < 0) {
          out_ok[0] = 0;
          return 1;
        }
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_COMMA) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          kind = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (kind == TOKEN_RBRACKET) {
            break;
          }
        } else {
          break;
        }
      }
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RBRACKET) {
      out_ok[0] = 0;
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    out_ok[0] = 1;
    out_expr_ref[0] = ref;
    parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    return 1;
  }
  return 0;
}

/**
 * Bare `{` primary: block expression vs anonymous struct lit, then
 * suffix loop on the struct path only (C twin). Block wrap is P5f
 * (G.7; type_ref=0). Anonymous fields stay the C ptr shim.
 * @return i32 — 1 handled; 0 not LBRACE
 * PLATFORM: SHARED — P4bh LBRACE arm.
 */
function parser_asm_primary_lbrace_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32 {
  let kind: i32 = 0;
  let bok: i32 = 0;
  let bref: i32 = 0;
  let wrap: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    if (parser_asm_lbrace_looks_like_block_ptr_c(lex_inout, source) != 0) {
      bok = 0;
      bref = 0;
      if (parser_parse_block_ptr_into_c(arena, lex_inout, source, 0, &bok, &bref) == 0 || bok == 0) {
        out_ok[0] = 0;
        return 1;
      }
      wrap = parser_asm_wrap_block_ref_as_expr_into_c(arena, bref, 0);
      if (wrap == 0) {
        out_ok[0] = 0;
        return 1;
      }
      out_ok[0] = 1;
      out_expr_ref[0] = wrap;
      return 1;
    }
    eok = 0;
    eref = 0;
    parser_asm_parse_anonymous_struct_lit_ptr_c(arena, lex_inout, source, &eok, &eref);
    if (eok == 0) {
      out_ok[0] = 0;
      return 1;
    }
    out_ok[0] = 1;
    out_expr_ref[0] = eref;
    parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    return 1;
  }
  return 0;
}

/**
 * parse_primary dest-buffer dispatcher (.x mirror of
 * parser_asm_parse_primary_into_slice_c after AUDIT). Peek-dispatch
 * remaining arms; INT/IDENT reuse existing literal_x / ident_x;
 * IF reuses P5f; MATCH/AT are zero-algorithm C ptr shims.
 * @param buffers — suffix-loop trampoline buffers (dispatcher-owned)
 * @return i32 — 1 attempted (check out_ok); 0 null args
 * PLATFORM: SHARED — product P4bh B-minus. C trampoline keeps AUDIT
 * and copies lex_inout into out->next_lex. Do not grow suffix_loop.
 */
#[no_mangle]
export function parser_asm_parse_primary_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32, mc_arg_buf: *i32, arg_buf: *i32, parsed_refs: *i32, pending_refs: *i32, mangled: *u8, name_buf: *u8): i32 {
  let kind: i32 = 0;
  let rc: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    rc = parser_asm_primary_string_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc != 0) {
      return 1;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_AT) {
      rc = parser_parse_at_simd_builtin_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
      if (rc == 0) {
        out_ok[0] = 0;
      }
      return 1;
    }
    rc = parser_asm_primary_literal_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    if (rc != 0) {
      return 1;
    }
    rc = parser_asm_primary_break_continue_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc != 0) {
      return 1;
    }
    rc = parser_asm_primary_return_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc != 0) {
      return 1;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_MATCH) {
      rc = parser_parse_match_ptr_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
      if (rc == 0) {
        out_ok[0] = 0;
      }
      return 1;
    }
    rc = parser_asm_primary_panic_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref);
    if (rc != 0) {
      return 1;
    }
    rc = parser_asm_primary_ident_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    if (rc != 0) {
      return 1;
    }
    rc = parser_asm_primary_paren_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    if (rc != 0) {
      return 1;
    }
    rc = parser_asm_primary_array_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    if (rc != 0) {
      return 1;
    }
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_IF) {
      rc = parser_asm_parse_if_expr_x_into_c(arena, lex_inout, source, 0, out_ok, out_expr_ref);
      if (rc == 0) {
        out_ok[0] = 0;
      }
      return 1;
    }
    rc = parser_asm_primary_lbrace_x_into_c(arena, lex_inout, source, out_ok, out_expr_ref, mc_arg_buf, arg_buf, parsed_refs, pending_refs, mangled, name_buf);
    if (rc != 0) {
      return 1;
    }
    out_ok[0] = 0;
    return 1;
  }
  return 0;
}

/**
 * Parse `{ field: expr, field, ... }` after TOKEN_LBRACE is consumed.
 * .x mirror of parser_asm_parse_struct_lit_fields_c. Entry cursor is
 * after `{` (caller already consumed LBRACE); first peek is the first
 * token inside the braces. IDENT field names go through the C
 * name-buffer trampoline (language has no local u8[N]). `field: expr`
 * bumps struct_field_value_depth around parse_expr (wave367 empty
 * Type {} vs prefer-block). `{ fd }` / `{ fd, x: 1 }` shorthand
 * allocs EXPR_VAR then appends. ident_len<=0 or >255 fails (C twin;
 * do not clamp 127). EOF without RBRACE fails (C twin). Empty `{}`
 * succeeds. Do not `break` out of the field while.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param lit_ref i32 — EXPR_STRUCT_LIT already allocated; 0 → 0
 * @param lex_inout *u8 — cursor after `{`; on success parked after `}`
 * @param source *u8 — opaque slice
 * @param out_ok *i32 — 1 on parse success; null → 0
 * @param out_expr_ref *i32 — lit_ref on success; null → 0
 * @return i32 — 1 success (out_ok=1); 0 failure (out_ok=0)
 * PLATFORM: SHARED — product P4bi B-minus. C trampoline keeps AUDIT
 * and the by-value parse_expr_result face. Do not dest-buffer
 * parse_type_ref / parse_match_into. Do not merge wrap. Do not
 * grow suffix_loop. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_parse_struct_lit_fields_x_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let k2: i32 = 0;
  let ts: usize = 0;
  let il: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  let arc: i32 = 0;
  let done: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32 || lit_ref == 0) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    /* Do not `break` out of this while: P4bh parse silently drops the
     * whole function (num_funcs stays N, no XP003). */
    while (done == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_RBRACE) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        out_ok[0] = 1;
        out_expr_ref[0] = lit_ref;
        done = 1;
      } else {
        if (kind != TOKEN_IDENT) {
          return 0;
        }
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        il = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (il <= 0 || il > 255) {
          return 0;
        }
        parser_asm_lex_step_kind_c(lex_inout, source);
        k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (k2 == TOKEN_COLON) {
          parser_asm_lex_step_kind_c(lex_inout, source);
          eok = 0;
          eref = 0;
          if (parser_asm_struct_lit_parse_field_value_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0 || eref <= 0) {
            return 0;
          }
          arc = parser_asm_struct_lit_append_field_src_c(arena, lit_ref, source, ts, il, eref);
          if (arc < 0) {
            return 0;
          }
          k2 = parser_asm_lex_peek_kind_c(lex_inout, source);
          if (k2 == TOKEN_COMMA) {
            parser_asm_lex_step_kind_c(lex_inout, source);
          } else {
            if (k2 == TOKEN_RBRACE) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              out_ok[0] = 1;
              out_expr_ref[0] = lit_ref;
              done = 1;
            } else {
              return 0;
            }
          }
        } else {
          if (k2 == TOKEN_COMMA || k2 == TOKEN_RBRACE) {
            arc = parser_asm_struct_lit_append_shorthand_src_c(arena, lit_ref, source, ts, il);
            if (arc < 0) {
              return 0;
            }
            if (k2 == TOKEN_RBRACE) {
              parser_asm_lex_step_kind_c(lex_inout, source);
              out_ok[0] = 1;
              out_expr_ref[0] = lit_ref;
              done = 1;
            } else {
              parser_asm_lex_step_kind_c(lex_inout, source);
            }
          } else {
            return 0;
          }
        }
      }
    }
    return 1;
  }
  return 0;
}

/**
 * Anonymous `{ field: expr, ... }` alloc + fields. lex_inout sits after `{`.
 * @param arena *u8
 * @param lex_inout *u8 — C lexer blob; fields walk advances it
 * @param source *u8 — source slice
 * @param out_ok *i32
 * @param out_expr_ref *i32
 * @return i32 — 1 success; 0 failure
 * PLATFORM: SHARED — product P4bj. Do not dest-buffer whole primary.
 * Do not merge wrap. Do not open a new lane. Named Type { } finish
 * is P4bn (same writer, IDENT placeholder name).
 */
#[no_mangle]
export function parser_asm_parse_anonymous_struct_lit_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let lit_ref: i32 = 0;
  let empty: *u8 = 0 as *u8;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    lit_ref = ast_ast_arena_expr_alloc(arena);
    if (lit_ref == 0) {
      return 0;
    }
    /* kind=45 + empty struct name + field_base/num_fields=0 */
    pipeline_expr_set_struct_lit_finish_c(arena, lit_ref, empty, 0);
    if (parser_asm_parse_struct_lit_fields_x_into_c(arena, lit_ref, lex_inout, source, out_ok, out_expr_ref) == 0 || out_ok[0] == 0) {
      out_ok[0] = 0;
      out_expr_ref[0] = 0;
      return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * Convert an IDENT VAR placeholder into EXPR_STRUCT_LIT and parse fields.
 * lex_inout sits after `{` (caller already consumed LBRACE). Mirror of
 * parser_asm_finish_struct_lit_from_type_ident_into_c. Copy the live
 * var_name into the C-owned name_buf BEFORE arena zeros wipe
 * var_name_len (P4bg contract: arena zeros DO wipe the count; C local
 * zeros did not). Writer is the existing set_struct_lit_finish (G.7;
 * same as suffix FIELD_ACCESS conversion and P4bj nlen=0). Fields stay
 * P4bi. Name copy uses the 256-byte Cap 4.2.8 face (C twin still
 * truncated through a 128-byte stack copy).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param lit_ref i32 — IDENT VAR placeholder already allocated; 0 → 0
 * @param lex_inout *u8 — C lexer blob after `{`; fields walk advances it
 * @param source *u8 — source slice
 * @param name_buf *u8 — C trampoline 256-byte scratch (language has no
 *   local u8[N]); var_name_into writes here before zeros
 * @param out_ok *i32 — 1 on parse success
 * @param out_expr_ref *i32 — lit_ref on success
 * @return i32 — 1 success; 0 failure
 * PLATFORM: SHARED — product P4bn. Do not dest-buffer append_byte.
 * Do not dest-buffer parse_type_ref. Do not FORCE pabi mega.
 * Do not grow suffix_loop. Do not open a new lane.
 */
#[no_mangle]
export function parser_asm_finish_struct_lit_from_type_ident_x_into_c(arena: *u8, lit_ref: i32, lex_inout: *u8, source: *u8, name_buf: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let tlen: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8 || name_buf == 0 as *u8 || out_ok == 0 as *i32 || out_expr_ref == 0 as *i32 || lit_ref == 0) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    tlen = pipeline_expr_var_name_len(arena, lit_ref);
    if (tlen <= 0 || tlen > 255) {
      return 0;
    }
    /* Copy IDENT placeholder name first: set_common_zeros wipes var_name_len. */
    pipeline_expr_var_name_into(arena, lit_ref, name_buf);
    pipeline_expr_set_common_zeros_c(arena, lit_ref);
    pipeline_expr_set_struct_lit_finish_c(arena, lit_ref, name_buf, tlen);
    pipeline_expr_set_line_col(arena, lit_ref, 0, 0);
    pipeline_expr_set_int_val(arena, lit_ref, 0);
    pipeline_expr_set_float_val(arena, lit_ref, 0.0);
    if (parser_asm_parse_struct_lit_fields_x_into_c(arena, lit_ref, lex_inout, source, out_ok, out_expr_ref) == 0 || out_ok[0] == 0) {
      out_ok[0] = 0;
      out_expr_ref[0] = 0;
      return 0;
    }
    return 1;
  }
  return 0;
}

/**
 * Hex nibble for asm! template `\xHH` (and the STRING walk). 0..15 or -1.
 * @param h u8 — ASCII hex digit
 * @return i32 — nibble, or -1 if not hex
 * PLATFORM: SHARED — G.7 single nibble table.
 */
function parser_asm_primary_hex_val_x(h: u8): i32 {
  if (h >= 48 && h <= 57) {
    return (h as i32) - 48;
  }
  if (h >= 97 && h <= 102) {
    return (h as i32) - 97 + 10;
  }
  if (h >= 65 && h <= 70) {
    return (h as i32) - 65 + 10;
  }
  return 0 - 1;
}

/**
 * Decode one TOKEN_STRING span into a C-owned buffer (asm! template).
 * Cap 127 + overflow note then stop (C twin; do not raise to 255).
 * Invalid `\x` / unknown escape write the backslash and consume 1
 * (C twin; STRING decode_span consumes the follower — do not reuse).
 * @param source *u8 — opaque slice
 * @param q0 usize — first payload byte
 * @param nlen i32 — payload length; <0 treated as 0
 * @param tmpl_buf *u8 — C trampoline scratch; NUL-terminated when wi<256
 * @param line i32 — overflow diag line
 * @param col i32 — overflow diag col
 * @return i32 — decoded length wi (>=0); 0 on null buf
 * PLATFORM: SHARED — P4bo template face. Do not dest-buffer append_byte.
 */
function parser_asm_primary_asm_template_decode_x(source: *u8, q0: usize, nlen: i32, tmpl_buf: *u8, line: i32, col: i32): i32 {
  let ri: i32 = 0;
  let wi: i32 = 0;
  let c: u8 = 0;
  let n: u8 = 0;
  let h1: u8 = 0;
  let h2: u8 = 0;
  let v1: i32 = 0;
  let v2: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  let consumed: i32 = 0;
  let b: u8 = 0;
  if (source == 0 as *u8 || tmpl_buf == 0 as *u8) {
    return 0;
  }
  if (nlen < 0) {
    nlen = 0;
  }
  unsafe {
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    ri = 0;
    wi = 0;
    while (ri < nlen) {
      if (wi >= 127) {
        lexer_note_string_lit_overflow(line, col);
        if (wi < 256) {
          tmpl_buf[wi] = 0;
        }
        return wi;
      }
      c = 0;
      consumed = 1;
      if (q0 + (ri as usize) < slen && data != 0 as *u8) {
        c = parser_asm_primary_ident_byte(data, q0, ri);
      }
      b = c;
      if (c == 92 && (ri + 1) < nlen) {
        n = 0;
        if (q0 + ((ri + 1) as usize) < slen && data != 0 as *u8) {
          n = parser_asm_primary_ident_byte(data, q0, ri + 1);
        }
        if (n == 110) {
          b = 10;
          consumed = 2;
        } else if (n == 116) {
          b = 9;
          consumed = 2;
        } else if (n == 114) {
          b = 13;
          consumed = 2;
        } else if (n == 48) {
          b = 0;
          consumed = 2;
        } else if (n == 92 || n == 34) {
          b = n;
          consumed = 2;
        } else if (n == 120 && (ri + 3) < nlen) {
          h1 = 0;
          h2 = 0;
          v1 = 0 - 1;
          v2 = 0 - 1;
          if (q0 + ((ri + 2) as usize) < slen && data != 0 as *u8) {
            h1 = parser_asm_primary_ident_byte(data, q0, ri + 2);
          }
          if (q0 + ((ri + 3) as usize) < slen && data != 0 as *u8) {
            h2 = parser_asm_primary_ident_byte(data, q0, ri + 3);
          }
          v1 = parser_asm_primary_hex_val_x(h1);
          v2 = parser_asm_primary_hex_val_x(h2);
          if (v1 >= 0 && v2 >= 0) {
            b = ((v1 * 16) + v2) as u8;
            consumed = 4;
          }
        }
      }
      tmpl_buf[wi] = b;
      wi = wi + 1;
      ri = ri + consumed;
    }
    if (wi < 256) {
      tmpl_buf[wi] = 0;
    }
    return wi;
  }
  return 0;
}

/**
 * Pack one TOKEN_STRING register spelling into regs_buf (comma-separated,
 * first operand has no leading comma). rlen capped at 16 (C twin).
 * @param source *u8 — opaque slice
 * @param lex_inout *u8 — cursor on TOKEN_STRING (not consumed)
 * @param regs_buf *u8 — C trampoline 128-byte scratch
 * @param regs_len i32 — live packed length
 * @return i32 — new packed length, or -1 if base+1+rlen >= 128
 * PLATFORM: SHARED — P4bo register pack. Do not FORCE pabi mega.
 */
function parser_asm_primary_asm_pack_reg_x(source: *u8, lex_inout: *u8, regs_buf: *u8, regs_len: i32): i32 {
  let kind: i32 = 0;
  let q0: usize = 0;
  let rlen: i32 = 0;
  let rwi: i32 = 0;
  let slen: usize = 0;
  let data: *u8 = 0 as *u8;
  let rc: u8 = 0;
  let base: i32 = 0;
  if (source == 0 as *u8 || lex_inout == 0 as *u8 || regs_buf == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRING) {
      return 0 - 1;
    }
    q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
    rlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (rlen < 0) {
      rlen = 0;
    }
    if (rlen > 16) {
      rlen = 16;
    }
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    if (regs_len == 0) {
      rwi = 0;
      while (rwi < rlen) {
        rc = 0;
        if (data != 0 as *u8 && q0 + (rwi as usize) < slen) {
          rc = parser_asm_primary_ident_byte(data, q0, rwi);
        }
        regs_buf[rwi] = rc;
        rwi = rwi + 1;
      }
      if (rwi < 128) {
        regs_buf[rwi] = 0;
      }
      return rwi;
    }
    base = regs_len;
    if (base + 1 + rlen >= 128) {
      return 0 - 1;
    }
    regs_buf[base] = 44;
    rwi = 0;
    while (rwi < rlen) {
      rc = 0;
      if (data != 0 as *u8 && q0 + (rwi as usize) < slen) {
        rc = parser_asm_primary_ident_byte(data, q0, rwi);
      }
      regs_buf[base + 1 + rwi] = rc;
      rwi = rwi + 1;
    }
    base = base + 1 + rlen;
    if (base < 128) {
      regs_buf[base] = 0;
    }
    return base;
  }
  return 0 - 1;
}

/**
 * Parse `options(name[, name…])` after the opening `(` is consumed.
 * Empty `()` returns 0. Unknown names fail. Single while (no nested
 * break — P4bh parse-drop).
 * @param lex_inout *u8 — cursor inside `(`; parked after `)` on success
 * @param source *u8 — opaque slice
 * @return i32 — bitmask, or -1 on failure
 * PLATFORM: SHARED — P4bo options list. G.7 bit table = asm_option_bit_buf.
 */
function parser_asm_primary_asm_parse_options_x(lex_inout: *u8, source: *u8): i32 {
  let kind: i32 = 0;
  let bits: i32 = 0;
  let done: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  let ts: usize = 0;
  let ilen: i32 = 0;
  let obit: i32 = 0;
  if (lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_RPAREN) {
      parser_asm_lex_step_kind_c(lex_inout, source);
      return 0;
    }
    bits = 0;
    done = 0;
    while (done == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_IDENT) {
        return 0 - 1;
      }
      data = parser_asm_lex_source_data_c(source);
      slen = parser_asm_lex_source_length_c(source);
      ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
      ilen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
      obit = parser_asm_primary_asm_option_bit_buf_c(data, slen, ts, ilen);
      if (obit == 0) {
        return 0 - 1;
      }
      bits = bits | obit;
      parser_asm_lex_step_kind_c(lex_inout, source);
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_RPAREN) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        done = 1;
      } else if (kind != TOKEN_COMMA) {
        return 0 - 1;
      } else {
        parser_asm_lex_step_kind_c(lex_inout, source);
      }
    }
    return bits;
  }
  return 0 - 1;
}

/**
 * Parse one in/out/lateout operand. Entry cursor is the direction IDENT.
 * Underscore discard reuses tmpl_buf[0] after the template is copied.
 * @param arena *u8 — opaque AST arena
 * @param lex_inout *u8 — cursor on in/out/lateout
 * @param source *u8 — opaque slice
 * @param regs_buf *u8 — register pack buffer; underscore writes 95 at packed end
 * @param regs_len_io *i32 — in/out packed length
 * @param pref i32 — EXPR_ASM ref to append call_args onto
 * @return i32 — 1=in, 2=out/lateout, 0=fail
 * PLATFORM: SHARED — P4bo one operand. No nested while.
 */
function parser_asm_primary_asm_parse_operand_x(arena: *u8, lex_inout: *u8, source: *u8, regs_buf: *u8, regs_len_io: *i32, pref: i32): i32 {
  let kind: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  let ts: usize = 0;
  let ilen: i32 = 0;
  let is_out_op: i32 = 0;
  let eok: i32 = 0;
  let eref: i32 = 0;
  if (arena == 0 as *u8 || lex_inout == 0 as *u8 || source == 0 as *u8) {
    return 0;
  }
  if (regs_buf == 0 as *u8 || regs_len_io == 0 as *i32 || pref == 0) {
    return 0;
  }
  unsafe {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT) {
      return 0;
    }
    data = parser_asm_lex_source_data_c(source);
    slen = parser_asm_lex_source_length_c(source);
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    ilen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    is_out_op = 0;
    if (parser_asm_primary_ident_is_in_buf_c(data, slen, ts, ilen) != 0) {
      is_out_op = 0;
    } else if (parser_asm_primary_ident_is_out_buf_c(data, slen, ts, ilen) != 0) {
      is_out_op = 1;
    } else if (parser_asm_primary_ident_is_lateout_buf_c(data, slen, ts, ilen) != 0) {
      is_out_op = 1;
    } else {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRING) {
      return 0;
    }
    ilen = regs_len_io[0];
    kind = parser_asm_primary_asm_pack_reg_x(source, lex_inout, regs_buf, ilen);
    if (kind < 0) {
      return 0;
    }
    regs_len_io[0] = kind;
    pipeline_expr_set_method_call_c(arena, pref, 0, regs_buf, kind);
    parser_asm_lex_step_kind_c(lex_inout, source);
    ilen = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (ilen != TOKEN_RPAREN) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    ilen = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (is_out_op != 0 && ilen == TOKEN_UNDERSCORE) {
      eok = ast_ast_arena_expr_alloc(arena);
      if (eok == 0) {
        return 0;
      }
      pipeline_expr_set_kind(arena, eok, EXPR_VAR);
      pipeline_expr_set_line_col(arena, eok, parser_asm_lex_peek_tok_line_c(lex_inout, source), parser_asm_lex_peek_tok_col_c(lex_inout, source));
      pipeline_expr_set_common_zeros_c(arena, eok);
      eref = regs_len_io[0];
      if (eref < 0) {
        eref = 0;
      }
      if (eref > 126) {
        eref = 126;
      }
      regs_buf[eref] = 95;
      pipeline_expr_set_var_name(arena, eok, regs_buf + eref, 1);
      regs_buf[eref] = 0;
      parser_asm_lex_step_kind_c(lex_inout, source);
      if (pipeline_expr_append_call_arg(arena, pref, eok) < 0) {
        return 0;
      }
      return 2;
    }
    eok = 0;
    eref = 0;
    if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) == 0 || eok == 0 || eref <= 0) {
      return 0;
    }
    if (pipeline_expr_append_call_arg(arena, pref, eref) < 0) {
      return 0;
    }
    if (is_out_op != 0) {
      return 2;
    }
    return 1;
  }
  return 0;
}

/**
 * Parse asm-bang (template STRING, optional in/out/lateout operands,
 * optional trailing options). Entry cursor is unconsumed TOKEN_BANG
 * (caller already matched IDENT asm).
 * GNU colon operands fail-closed (C twin). Options/operand walks live in
 * helpers so this function has a single comma while (P4bh nested-while
 * parse-drop).
 * @param arena *u8 — opaque AST arena; null → 0
 * @param lex_inout *u8 — cursor at `!`; parked after closing `)` on success
 * @param source *u8 — opaque slice
 * @param tmpl_buf *u8 — C trampoline 256-byte template scratch
 * @param regs_buf *u8 — C trampoline 128-byte register-name scratch
 * @param out_ok *i32 — 1 on parse success
 * @param out_expr_ref *i32 — EXPR_ASM ref on success
 * @return i32 — 1 handled (check out_ok); 0 not BANG / null args
 * PLATFORM: SHARED — product P4bo. Writers = set_kind / set_var_name /
 * set_method_call_c / set_call_c / set_int_val / append_call_arg (G.7).
 * Do not dest-buffer append_byte. Do not dest-buffer parse_type_ref.
 * Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_primary_parse_asm_bang_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, tmpl_buf: *u8, regs_buf: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let pref: i32 = 0;
  let tl: i32 = 0;
  let tc: i32 = 0;
  let q0: usize = 0;
  let nlen: i32 = 0;
  let wi: i32 = 0;
  let nops: i32 = 0;
  let n_in: i32 = 0;
  let saw_out: i32 = 0;
  let saw_options: i32 = 0;
  let opt_bits: i32 = 0;
  let comma_done: i32 = 0;
  let fail: i32 = 0;
  let data: *u8 = 0 as *u8;
  let slen: usize = 0;
  let ts: usize = 0;
  let ilen: i32 = 0;
  let regs_len: i32 = 0;
  let opc: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  if (lex_inout == 0 as *u8) {
    return 0;
  }
  if (source == 0 as *u8) {
    return 0;
  }
  if (tmpl_buf == 0 as *u8) {
    return 0;
  }
  if (regs_buf == 0 as *u8) {
    return 0;
  }
  if (out_ok == 0 as *i32) {
    return 0;
  }
  if (out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_BANG) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LPAREN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_STRING) {
      return 1;
    }
    tl = parser_asm_lex_peek_tok_line_c(lex_inout, source);
    tc = parser_asm_lex_peek_tok_col_c(lex_inout, source);
    q0 = parser_asm_lex_peek_token_start_c(lex_inout, source);
    nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    pref = ast_ast_arena_expr_alloc(arena);
    if (pref == 0) {
      return 1;
    }
    pipeline_expr_set_kind(arena, pref, EXPR_ASM);
    pipeline_expr_set_line_col(arena, pref, tl, tc);
    pipeline_expr_set_common_zeros_c(arena, pref);
    wi = parser_asm_primary_asm_template_decode_x(source, q0, nlen, tmpl_buf, tl, tc);
    pipeline_expr_set_var_name(arena, pref, tmpl_buf, wi);
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_COLON) {
      return 1;
    }
    nops = 0;
    n_in = 0;
    saw_out = 0;
    saw_options = 0;
    regs_len = 0;
    fail = 0;
    comma_done = 0;
    while (comma_done == 0) {
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind != TOKEN_COMMA) {
        comma_done = 1;
      } else {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind != TOKEN_IDENT) {
          fail = 1;
          comma_done = 1;
        } else {
          data = parser_asm_lex_source_data_c(source);
          slen = parser_asm_lex_source_length_c(source);
          ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
          ilen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
          if (parser_asm_primary_ident_is_options_buf_c(data, slen, ts, ilen) != 0) {
            if (saw_options != 0) {
              fail = 1;
              comma_done = 1;
            } else {
              parser_asm_lex_step_kind_c(lex_inout, source);
              kind = parser_asm_lex_peek_kind_c(lex_inout, source);
              if (kind != TOKEN_LPAREN) {
                fail = 1;
                comma_done = 1;
              } else {
                parser_asm_lex_step_kind_c(lex_inout, source);
                opt_bits = parser_asm_primary_asm_parse_options_x(lex_inout, source);
                if (opt_bits < 0) {
                  fail = 1;
                  comma_done = 1;
                } else {
                  saw_options = 1;
                  pipeline_expr_set_call_c(arena, pref, 0, opt_bits);
                }
              }
            }
          } else if (saw_options != 0) {
            fail = 1;
            comma_done = 1;
          } else if (nops >= 6) {
            fail = 1;
            comma_done = 1;
          } else if (parser_asm_primary_ident_is_in_buf_c(data, slen, ts, ilen) != 0 && saw_out != 0) {
            fail = 1;
            comma_done = 1;
          } else {
            opc = parser_asm_primary_asm_parse_operand_x(arena, lex_inout, source, regs_buf, &regs_len, pref);
            if (opc == 0) {
              fail = 1;
              comma_done = 1;
            } else {
              if (opc == 1) {
                n_in = n_in + 1;
              } else {
                saw_out = 1;
              }
              nops = nops + 1;
            }
          }
        }
      }
    }
    if (fail != 0) {
      return 1;
    }
    pipeline_expr_set_int_val(arena, pref, n_in);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_RPAREN) {
      return 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    out_ok[0] = 1;
    out_expr_ref[0] = pref;
    return 1;
  }
  return 0;
}

/**
 * Parse expression-position `unsafe { ... }`. Caller already matched
 * IDENT `unsafe`; entry cursor is the unconsumed TOKEN_LBRACE.
 * Inner block is parse_block_ptr (lex after `{`, same as P4bh LBRACE
 * block). A fresh wrapper block holds one unsafe stmt (order kind=6)
 * whose body is that inner block; wrap the wrapper as EXPR_BLOCK via
 * P5f wrap_block_ref (G.7; type_ref=0). Fail-closed: missing `{`,
 * block parse fail, alloc fail, or append fail leave out_ok=0.
 * @param arena *u8 — opaque AST arena; null → 0
 * @param lex_inout *u8 — cursor at `{`; parked after the inner block on success
 * @param source *u8 — opaque source slice
 * @param out_ok *i32 — 1 on parse success
 * @param out_expr_ref *i32 — EXPR_BLOCK wrapper ref on success
 * @return i32 — 1 handled (check out_ok); 0 not LBRACE / null args
 * PLATFORM: SHARED — product P4bp. Writers = parse_block_ptr /
 * ast_ast_arena_block_alloc / pipeline_block_append_unsafe /
 * pipeline_block_append_stmt_order / wrap_block_ref (G.7).
 * ident_pre_dispatch stays C compositor. Do not dest-buffer
 * lbrace_looks_like_block / empty_ident_braces. Do not dest-buffer
 * append_byte. Do not dest-buffer parse_type_ref. Do not FORCE pabi mega.
 */
#[no_mangle]
export function parser_asm_primary_parse_unsafe_x_into_c(arena: *u8, lex_inout: *u8, source: *u8, out_ok: *i32, out_expr_ref: *i32): i32 {
  let kind: i32 = 0;
  let bok: i32 = 0;
  let bref: i32 = 0;
  let wrap: i32 = 0;
  let wref: i32 = 0;
  let uidx: i32 = 0;
  if (arena == 0 as *u8) {
    return 0;
  }
  if (lex_inout == 0 as *u8) {
    return 0;
  }
  if (source == 0 as *u8) {
    return 0;
  }
  if (out_ok == 0 as *i32) {
    return 0;
  }
  if (out_expr_ref == 0 as *i32) {
    return 0;
  }
  unsafe {
    out_ok[0] = 0;
    out_expr_ref[0] = 0;
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_LBRACE) {
      return 0;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
    bok = 0;
    bref = 0;
    if (parser_parse_block_ptr_into_c(arena, lex_inout, source, 0, &bok, &bref) == 0 || bok == 0) {
      return 1;
    }
    wref = ast_ast_arena_block_alloc(arena);
    if (wref == 0) {
      return 1;
    }
    uidx = pipeline_block_append_unsafe(arena, wref, bref);
    if (uidx < 0) {
      return 1;
    }
    if (pipeline_block_append_stmt_order(arena, wref, 6, uidx) < 0) {
      return 1;
    }
    wrap = parser_asm_wrap_block_ref_as_expr_into_c(arena, wref, 0);
    if (wrap == 0) {
      return 1;
    }
    out_ok[0] = 1;
    out_expr_ref[0] = wrap;
    return 1;
  }
  return 0;
}

