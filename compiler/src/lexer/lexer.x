// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

// Both imports stay. The const import keeps allow(padding) on Token for
// the installed compiler. The bare import is what the pin egg's library
// typeck uses to resolve Token and TokenKind.
// PLATFORM: SHARED.
const token = import("token");
import token;

/* See implementation. */

/**
 * Copy a Token and replace only kind.
 *
 * The pinned stage0 egg segfaults in glue_type_size_simple when codegen
 * emits an imported enum field store (assigning Token.kind).
 * Kind is written only inside this struct literal. Callers that used to
 * store kind go through here so line, col, and the ident payload stay.
 *
 * @param t Token — source value; not modified
 * @param k TokenKind — kind stored in the returned copy
 * @return Token — same payload as t, with kind replaced by k
 * PLATFORM: SHARED — pin egg emits this module. The installed compiler
 * still fails earlier, on a function that returns Lexer by value.
 */
// PLATFORM: SHARED — whole token is written through t. Kind is set only in the literal.
function lexer_tok_with_kind(t: *Token, k: TokenKind): void {
  if (t == 0) { return; }
  let cur: Token = { kind: (0 as TokenKind), line: 0, col: 0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
  unsafe { cur = *t; }
  let nxt: Token = {
    kind: k,
    line: cur.line,
    col: cur.col,
    int_val: cur.int_val,
    float_val: cur.float_val,
    ident: cur.ident,
    ident_len: cur.ident_len
  };
  unsafe { *t = nxt; }
}

export extern function cfg_eval_expr_c(start: *u8, len: i32): i32;

/** See implementation for details. */
allow(padding) struct Lexer {
  pos: usize;
  line: i32;
  col: i32;
}

/** See implementation for details. */
/** See implementation for details. */
allow(padding) struct LexerResult {
  next_lex: Lexer;
  tok: Token;
  token_start: usize;
}

/**
 * Fat source view. Same two words as SliceU8 / xlang_slice_uint8_t:
 * data pointer, then byte length. The linked body returns this as a
 * named 16-byte struct. On Windows x64 that return uses a hidden
 * pointer in rcx (w1545). A u8[] declaration made the caller put the
 * source pointer in rcx, so the callee wrote the header over the
 * first 16 source bytes.
 * PLATFORM: SHARED layout. WINDOWS is why the extern is not a slice.
 */
allow(padding) struct LexerBuf {
  data: *u8;
  length: usize;
}

/** Copy bytes. Token stores use 48; LexerBuf uses 16. */
export extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/**
 * Copy one Token image (48 bytes) onto dst.
 *
 * Layout, matching the product store: kind@0, line@4, col@8, int_val@16,
 * float_val@24, ident@32, ident_len@40, size 48. ident_len is the span
 * the parser accepts (1..255). A struct assignment (`*dst = src` or
 * `out.tok = t`) on the Windows bootstrap compiler keeps only the first
 * 8 bytes, so kind and line move and ident_len stays 0. The name check
 * then fails, the function is skipped, and the module stays at
 * num_funcs == 0.
 *
 * Field-by-field stores fault the pin egg. This copies the same 48-byte
 * image a correct struct assignment writes. The pointer is not retained.
 *
 * A caller that passes the address of a block-local Token together with
 * an outer *Token must wrap the call in unsafe. Bootstrap typeck rejects
 * that pair outside unsafe (T001 stack escape). A by-value parameter is
 * not a block local, so write_tok_into does not need the wrapper.
 *
 * @param dst *Token — destination token; caller does not pass null
 * @param src *Token — source image; caller does not pass null
 * @return void
 * PLATFORM: SHARED. WINDOWS is where the 8-byte assign was measured.
 */
function lexer_store_token(dst: *Token, src: *Token): void {
  unsafe {
    memcpy((dst as *u8), (src as *u8), (48 as usize));
  }
}

/**
 * Cross-TU constructor. Return type is LexerBuf so the Windows caller
 * passes the hidden return pointer. Negative len is clamped by the body.
 * @param data *u8 — first byte; null only when the length is 0
 * @param len i32 — byte count
 * @return LexerBuf — {data, length}
 * PLATFORM: SHARED symbol; WINDOWS return is the w1545 hidden pointer.
 */
export extern function lexer_parser_slice_from_buf(data: *u8, len: i32): LexerBuf;

/**
 * u8[] view of [data, data+len) for the rest of this file.
 * The extern returns a named struct (Windows hidden pointer). A slice
 * return from this function stays in rax:rdx, and this file's callers
 * are compiled with that same convention. The 16-byte copy is the
 * layout match proved by {pointer, length}, not a second constructor.
 * @param data *u8 — first byte; null only when the length is 0
 * @param len i32 — byte count; negative becomes an empty view
 * @return u8[] — fat pointer the lexer indexes
 * PLATFORM: SHARED
 */
export function lexer_slice_from_raw(data: *u8, len: i32): u8[] {
  let b: LexerBuf = LexerBuf { data: (0 as *u8), length: (0 as usize) };
  let sl: u8[] = [];
  unsafe {
    b = lexer_parser_slice_from_buf(data, len);
    memcpy((&sl as *u8), (&b as *u8), (16 as usize));
  }
  return sl;
}

/**
 * Fixed-message diagnostic sink for hard lexer errors (no va_list).
 * PLATFORM: SHARED — same surface as pipeline/preprocess diags.
 * @param file *u8 — path or null (uses diag context when null)
 * @param line i32 — 1-based source line of the diagnostic caret
 * @param col i32 — 1-based source column of the diagnostic caret
 * @param kind *u8 — NUL kind string (e.g. "lexer error")
 * @param code *u8 — NUL code string (e.g. "L001")
 * @param msg *u8 — NUL primary message
 * @param detail *u8 — optional detail or null
 * @return void
 */
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/** libc abort. Body of the weak xlang_panic_ below. PLATFORM: SHARED. */
export extern "C" function abort(): void;

/**
 * Panic target for x86_64 asm bounds checks (call xlang_panic_(1, code)).
 * arm64 does not emit those calls. Linux and Windows g05 links have no strong
 * xlang_panic_ (runtime_panic.o is the user-program twin), so this object
 * carries one. build_lexer_x weakens it; Darwin's strong runtime_panic.o wins.
 * @param has_msg i32 — 1 when msg_val carries a code
 * @param msg_val isize — panic code (1 = index out of bounds)
 * @return void — does not return
 * PLATFORM: SHARED
 */
#[no_mangle]
export function xlang_panic_(has_msg: i32, msg_val: isize): void {
  unsafe {
    abort();
  }
}

/**
 * wave269 Cap residual: sticky unclosed block-comment state for the current parse.
 * Set when skip_whitespace hits EOF with nesting depth > 0; cleared by
 * lexer_unclosed_block_comment_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_unclosed_bc: i32 = 0;
let g_lexer_unclosed_line: i32 = 0;
let g_lexer_unclosed_col: i32 = 0;
let g_lexer_unclosed_reported: i32 = 0;

/**
 * wave271 Cap residual: sticky unclosed string-literal state for the current parse.
 * Set when string lex hits EOF without a closing double-quote; cleared by
 * lexer_unclosed_string_reset at each product parse entry.
 * Prior behavior returned TOKEN_EOF silently → empty module / BLD001 or soft P001.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_unclosed_str: i32 = 0;
let g_lexer_unclosed_str_line: i32 = 0;
let g_lexer_unclosed_str_col: i32 = 0;
let g_lexer_unclosed_str_reported: i32 = 0;

/**
 * wave272 Cap residual: sticky illegal/unknown character state for the current parse.
 * Set when punct fallthrough sees a byte that is not a known operator/punct introducer
 * (e.g. `$`, bare `'`, backticks). Prior behavior returned TOKEN_EOF silently after
 * advancing past the byte → soft P001 "no functions" / empty module / BLD001.
 * Cleared by lexer_illegal_char_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_illegal_ch: i32 = 0;
let g_lexer_illegal_ch_line: i32 = 0;
let g_lexer_illegal_ch_col: i32 = 0;
let g_lexer_illegal_ch_reported: i32 = 0;

/**
 * wave273 Cap residual: sticky incomplete hex-literal state for the current parse.
 * Set when `0x`/`0X` is followed by zero hex digits (e.g. `0x;`, `0xGG` after the prefix).
 * Prior behavior emitted TOKEN_INT(0) silently → wrong program (`return 0x;` run=0) or soft
 * P001 "no functions" when a following non-hex letter derailed parse and dropped the function.
 * Cleared by lexer_incomplete_hex_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_incomplete_hex: i32 = 0;
let g_lexer_incomplete_hex_line: i32 = 0;
let g_lexer_incomplete_hex_col: i32 = 0;
let g_lexer_incomplete_hex_reported: i32 = 0;

/**
 * wave274 Cap residual: sticky incomplete float-exponent state for the current parse.
 * Set when a float exponent introducer `e`/`E` (optionally followed by `+`/`-`) has zero
 * decimal digits (e.g. `1e`, `1e+`, `1.5e-`, `2E`). Prior behavior treated missing digits as
 * exp=0 → silent TOKEN_FLOAT (e.g. `return (1e) as i32` ran as 1).
 * Cleared by lexer_incomplete_exp_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_incomplete_exp: i32 = 0;
let g_lexer_incomplete_exp_line: i32 = 0;
let g_lexer_incomplete_exp_col: i32 = 0;
let g_lexer_incomplete_exp_reported: i32 = 0;

/**
 * wave276 Cap residual: sticky incomplete binary-literal state for the current parse.
 * Set when `0b`/`0B` is followed by zero binary digits (e.g. `0b;`, `0b2` after the prefix).
 * Prior behavior lexed INT(0)+IDENT → soft XP003 parse-skip / no hard L00x.
 * Cleared by lexer_incomplete_bin_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_incomplete_bin: i32 = 0;
let g_lexer_incomplete_bin_line: i32 = 0;
let g_lexer_incomplete_bin_col: i32 = 0;
let g_lexer_incomplete_bin_reported: i32 = 0;

/**
 * wave276 Cap residual: sticky incomplete octal-literal state for the current parse.
 * Set when `0o`/`0O` is followed by zero octal digits (e.g. `0o;`, `0o9` after the prefix).
 * Prior behavior lexed INT(0)+IDENT → soft XP003 parse-skip / no hard L00x.
 * Cleared by lexer_incomplete_oct_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_incomplete_oct: i32 = 0;
let g_lexer_incomplete_oct_line: i32 = 0;
let g_lexer_incomplete_oct_col: i32 = 0;
let g_lexer_incomplete_oct_reported: i32 = 0;


/**
 * wave278 Cap residual: sticky invalid digit-separator state for the current parse.
 * Set when `_` appears in a numeric literal without a following valid radix digit
 * (trailing `_`, consecutive `__`, or `_` before a non-digit). Cleared by
 * lexer_invalid_digit_sep_reset at each product parse entry.
 * PLATFORM: SHARED
 */
let g_lexer_invalid_digit_sep: i32 = 0;
let g_lexer_invalid_digit_sep_line: i32 = 0;
let g_lexer_invalid_digit_sep_col: i32 = 0;
let g_lexer_invalid_digit_sep_reported: i32 = 0;

/**
 * wave279 Cap residual: sticky invalid/unsupported type-suffix state for the current parse.
 * Set when a complete numeric literal (INT/FLOAT, any radix) is immediately followed by
 * an alphabetic character (`42u32`, `0x2Ai64`, `1.5f32`, `42foo`). Language surface has
 * no C/Rust-style type suffixes — use context coerce or `as T`. Prior soft residual:
 * INT+IDENT → XP003 parse-skip. Cleared by lexer_invalid_type_suffix_reset at each entry.
 * PLATFORM: SHARED
 */
let g_lexer_invalid_type_suffix: i32 = 0;
let g_lexer_invalid_type_suffix_line: i32 = 0;
let g_lexer_invalid_type_suffix_col: i32 = 0;
let g_lexer_invalid_type_suffix_reported: i32 = 0;

/**
 * wave281 Cap residual: sticky invalid string-escape state for the current parse.
 * Set when a string escape is not one of the product set `\n \t \r \0 \\ \" \xHH`
 * (e.g. `\q`, incomplete `\x` / `\xG`). Prior: lexer blindly skipped `\`+next and
 * parser decode silently kept the second byte → wrong AST / silent green.
 * Cleared by lexer_invalid_escape_reset at each product parse entry.
 * PLATFORM: SHARED — language lexical contract.
 */
let g_lexer_invalid_escape: i32 = 0;
let g_lexer_invalid_escape_line: i32 = 0;
let g_lexer_invalid_escape_col: i32 = 0;
let g_lexer_invalid_escape_reported: i32 = 0;

/**
 * wave283 Cap residual: sticky string-literal capacity overflow for the current parse.
 * EXPR_STRING_LIT stores semantic bytes in Expr.var_name (first 127) plus
 * int_val-chained overflow chunks (cap 4095). Identifier name slots stay 127
 * (4.2.8 leave-off). Prior soft residual: decode loops clamped / stopped at
 * wi<63 and silently truncated. Set when a decode write would exceed 4095
 * semantic bytes; product parse must hard-fail.
 * Cleared by lexer_string_lit_overflow_reset at each product parse entry.
 * PLATFORM: SHARED — STRING_LIT overflow complete; ident layout raise leave-off.
 */
let g_lexer_string_lit_overflow: i32 = 0;
let g_lexer_string_lit_overflow_line: i32 = 0;
let g_lexer_string_lit_overflow_col: i32 = 0;
let g_lexer_string_lit_overflow_reported: i32 = 0;

/**
 * wave284 Cap residual: sticky identifier/name capacity overflow for the current parse.
 * AST name slots (Func.name, LetDecl.name, Expr.var_name for vars, field/method names)
 * are fixed `name[256]` with content cap 255 (primary_slice and name64 copies).
 * Prior soft residual: idents longer than 63 were TOKEN_IDENT with full span, then
 * silent clamp to 63 / XP003 / typeck mismatch without a hard L0xx → wrong or opaque fail.
 * Set when a non-keyword ident span length exceeds 63; product parse must hard-fail.
 * Cleared by lexer_ident_too_long_reset at each product parse entry.
 * PLATFORM: SHARED — layout raise is leave-off; this leaf only honest-fails.
 */
let g_lexer_ident_too_long: i32 = 0;
let g_lexer_ident_too_long_line: i32 = 0;
let g_lexer_ident_too_long_col: i32 = 0;
let g_lexer_ident_too_long_reported: i32 = 0;


/**
 * Clear unclosed block-comment sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_unclosed_block_comment_reset(): void {
  g_lexer_unclosed_bc = 0;
  g_lexer_unclosed_line = 0;
  g_lexer_unclosed_col = 0;
  g_lexer_unclosed_reported = 0;
}

/**
 * Whether the last skip saw an unclosed block comment (EOF with depth > 0).
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_unclosed_block_comment_pending(): i32 {
  return g_lexer_unclosed_bc;
}

/**
 * Clear unclosed string sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_unclosed_string_reset(): void {
  g_lexer_unclosed_str = 0;
  g_lexer_unclosed_str_line = 0;
  g_lexer_unclosed_str_col = 0;
  g_lexer_unclosed_str_reported = 0;
}

/**
 * Whether string lex hit EOF without a closing double-quote.
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_unclosed_string_pending(): i32 {
  return g_lexer_unclosed_str;
}

/**
 * Clear illegal-character sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_illegal_char_reset(): void {
  g_lexer_illegal_ch = 0;
  g_lexer_illegal_ch_line = 0;
  g_lexer_illegal_ch_col = 0;
  g_lexer_illegal_ch_reported = 0;
}

/**
 * Whether lex hit a byte that is not a recognized token introducer.
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_illegal_char_pending(): i32 {
  return g_lexer_illegal_ch;
}

/**
 * Clear incomplete-hex sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_incomplete_hex_reset(): void {
  g_lexer_incomplete_hex = 0;
  g_lexer_incomplete_hex_line = 0;
  g_lexer_incomplete_hex_col = 0;
  g_lexer_incomplete_hex_reported = 0;
}

/**
 * Whether lex saw `0x`/`0X` with zero following hex digits.
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_incomplete_hex_pending(): i32 {
  return g_lexer_incomplete_hex;
}

/**
 * Clear incomplete-float-exponent sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_incomplete_exp_reset(): void {
  g_lexer_incomplete_exp = 0;
  g_lexer_incomplete_exp_line = 0;
  g_lexer_incomplete_exp_col = 0;
  g_lexer_incomplete_exp_reported = 0;
}

/**
 * Whether lex saw `e`/`E` (optional sign) with zero following exponent digits.
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_incomplete_exp_pending(): i32 {
  return g_lexer_incomplete_exp;
}

/**
 * Clear incomplete-binary sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_incomplete_bin_reset(): void {
  g_lexer_incomplete_bin = 0;
  g_lexer_incomplete_bin_line = 0;
  g_lexer_incomplete_bin_col = 0;
  g_lexer_incomplete_bin_reported = 0;
}

/**
 * Whether lex saw `0b`/`0B` with zero following binary digits.
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_incomplete_bin_pending(): i32 {
  return g_lexer_incomplete_bin;
}

/**
 * Clear incomplete-octal sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_incomplete_oct_reset(): void {
  g_lexer_incomplete_oct = 0;
  g_lexer_incomplete_oct_line = 0;
  g_lexer_incomplete_oct_col = 0;
  g_lexer_incomplete_oct_reported = 0;
}

/**
 * Whether lex saw `0o`/`0O` with zero following octal digits.
 * @return i32 — 1 if pending hard fail, else 0
 * PLATFORM: SHARED
 */
export function lexer_incomplete_oct_pending(): i32 {
  return g_lexer_incomplete_oct;
}

/**
 * Clear invalid-digit-separator sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED — wave278 Cap residual pure
 */
export function lexer_invalid_digit_sep_reset(): void {
  g_lexer_invalid_digit_sep = 0;
  g_lexer_invalid_digit_sep_line = 0;
  g_lexer_invalid_digit_sep_col = 0;
  g_lexer_invalid_digit_sep_reported = 0;
}

/**
 * Non-zero if lexer saw an invalid numeric digit separator (`_`) this parse.
 * @return i32 — 1 when sticky L008 pending, else 0
 * PLATFORM: SHARED — wave278 Cap residual pure
 */
export function lexer_invalid_digit_sep_pending(): i32 {
  return g_lexer_invalid_digit_sep;
}

/**
 * Clear invalid-type-suffix sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED — wave279 Cap residual pure
 */
export function lexer_invalid_type_suffix_reset(): void {
  g_lexer_invalid_type_suffix = 0;
  g_lexer_invalid_type_suffix_line = 0;
  g_lexer_invalid_type_suffix_col = 0;
  g_lexer_invalid_type_suffix_reported = 0;
}

/**
 * Non-zero if lexer saw an alphabetic type suffix glued to a numeric literal this parse.
 * @return i32 — 1 when sticky L009 pending, else 0
 * PLATFORM: SHARED — wave279 Cap residual pure
 */
export function lexer_invalid_type_suffix_pending(): i32 {
  return g_lexer_invalid_type_suffix;
}

/**
 * Clear invalid string-escape sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED — wave281 Cap residual pure
 */
export function lexer_invalid_escape_reset(): void {
  g_lexer_invalid_escape = 0;
  g_lexer_invalid_escape_line = 0;
  g_lexer_invalid_escape_col = 0;
  g_lexer_invalid_escape_reported = 0;
}

/**
 * Non-zero if lexer saw an invalid/incomplete string escape this parse.
 * @return i32 — 1 when sticky L010 pending, else 0
 * PLATFORM: SHARED — wave281 Cap residual pure
 */
export function lexer_invalid_escape_pending(): i32 {
  return g_lexer_invalid_escape;
}

/**
 * Clear string-literal capacity-overflow sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED
 */
export function lexer_string_lit_overflow_reset(): void {
  g_lexer_string_lit_overflow = 0;
  g_lexer_string_lit_overflow_line = 0;
  g_lexer_string_lit_overflow_col = 0;
  g_lexer_string_lit_overflow_reported = 0;
}

/**
 * Whether a string-literal decode would exceed Expr.var_name capacity (127 bytes).
 * @return i32 — 1 when sticky L011 pending, else 0
 * PLATFORM: SHARED
 */
export function lexer_string_lit_overflow_pending(): i32 {
  return g_lexer_string_lit_overflow;
}

/**
 * Clear identifier-too-long sticky state (call once per parse entry).
 * @return void
 * PLATFORM: SHARED — wave284 Cap residual pure
 */
export function lexer_ident_too_long_reset(): void {
  g_lexer_ident_too_long = 0;
  g_lexer_ident_too_long_line = 0;
  g_lexer_ident_too_long_col = 0;
  g_lexer_ident_too_long_reported = 0;
}

/**
 * Whether a non-keyword identifier span exceeds AST name capacity (127 bytes).
 * @return i32 — 1 when sticky L012 pending, else 0
 * PLATFORM: SHARED — wave284 Cap residual pure
 */
export function lexer_ident_too_long_pending(): i32 {
  return g_lexer_ident_too_long;
}

/**
 * Record and report L001 once for an unclosed nested block comment at EOF.
 * @param line i32 — 1-based line of the outermost opening slash-star
 * @param col i32 — 1-based column of the outermost opening slash-star
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_unclosed_block_comment(line: i32, col: i32): void {
  if (g_lexer_unclosed_bc == 0) {
    g_lexer_unclosed_bc = 1;
    g_lexer_unclosed_line = line;
    g_lexer_unclosed_col = col;
  }
  if (g_lexer_unclosed_reported != 0) {
    return;
  }
  g_lexer_unclosed_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L001"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 49;
  code[4] = 0;
  // msg = "unclosed block comment"
  let msg: u8[32] = [];
  msg[0] = 117;
  msg[1] = 110;
  msg[2] = 99;
  msg[3] = 108;
  msg[4] = 111;
  msg[5] = 115;
  msg[6] = 101;
  msg[7] = 100;
  msg[8] = 32;
  msg[9] = 98;
  msg[10] = 108;
  msg[11] = 111;
  msg[12] = 99;
  msg[13] = 107;
  msg[14] = 32;
  msg[15] = 99;
  msg[16] = 111;
  msg[17] = 109;
  msg[18] = 109;
  msg[19] = 101;
  msg[20] = 110;
  msg[21] = 116;
  msg[22] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_unclosed_line,
      g_lexer_unclosed_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L002 once for an unclosed double-quoted string at EOF.
 * @param line i32 — 1-based line of the opening double-quote
 * @param col i32 — 1-based column of the opening double-quote
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_unclosed_string(line: i32, col: i32): void {
  if (g_lexer_unclosed_str == 0) {
    g_lexer_unclosed_str = 1;
    g_lexer_unclosed_str_line = line;
    g_lexer_unclosed_str_col = col;
  }
  if (g_lexer_unclosed_str_reported != 0) {
    return;
  }
  g_lexer_unclosed_str_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L002"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 50;
  code[4] = 0;
  // msg = "unclosed string literal"
  let msg: u8[32] = [];
  msg[0] = 117;
  msg[1] = 110;
  msg[2] = 99;
  msg[3] = 108;
  msg[4] = 111;
  msg[5] = 115;
  msg[6] = 101;
  msg[7] = 100;
  msg[8] = 32;
  msg[9] = 115;
  msg[10] = 116;
  msg[11] = 114;
  msg[12] = 105;
  msg[13] = 110;
  msg[14] = 103;
  msg[15] = 32;
  msg[16] = 108;
  msg[17] = 105;
  msg[18] = 116;
  msg[19] = 101;
  msg[20] = 114;
  msg[21] = 97;
  msg[22] = 108;
  msg[23] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_unclosed_str_line,
      g_lexer_unclosed_str_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L003 once for an illegal/unknown source byte.
 * @param line i32 — 1-based line of the illegal byte
 * @param col i32 — 1-based column of the illegal byte
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_illegal_char(line: i32, col: i32): void {
  if (g_lexer_illegal_ch == 0) {
    g_lexer_illegal_ch = 1;
    g_lexer_illegal_ch_line = line;
    g_lexer_illegal_ch_col = col;
  }
  if (g_lexer_illegal_ch_reported != 0) {
    return;
  }
  g_lexer_illegal_ch_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L003"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 51;
  code[4] = 0;
  // msg = "illegal character"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 108;
  msg[2] = 108;
  msg[3] = 101;
  msg[4] = 103;
  msg[5] = 97;
  msg[6] = 108;
  msg[7] = 32;
  msg[8] = 99;
  msg[9] = 104;
  msg[10] = 97;
  msg[11] = 114;
  msg[12] = 97;
  msg[13] = 99;
  msg[14] = 116;
  msg[15] = 101;
  msg[16] = 114;
  msg[17] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_illegal_ch_line,
      g_lexer_illegal_ch_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L004 once for an incomplete hex literal (`0x` / `0X` with no digits).
 * @param line i32 — 1-based line of the leading `0`
 * @param col i32 — 1-based column of the leading `0`
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_incomplete_hex(line: i32, col: i32): void {
  if (g_lexer_incomplete_hex == 0) {
    g_lexer_incomplete_hex = 1;
    g_lexer_incomplete_hex_line = line;
    g_lexer_incomplete_hex_col = col;
  }
  if (g_lexer_incomplete_hex_reported != 0) {
    return;
  }
  g_lexer_incomplete_hex_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L004"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 52;
  code[4] = 0;
  // msg = "incomplete hex literal"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 99;
  msg[3] = 111;
  msg[4] = 109;
  msg[5] = 112;
  msg[6] = 108;
  msg[7] = 101;
  msg[8] = 116;
  msg[9] = 101;
  msg[10] = 32;
  msg[11] = 104;
  msg[12] = 101;
  msg[13] = 120;
  msg[14] = 32;
  msg[15] = 108;
  msg[16] = 105;
  msg[17] = 116;
  msg[18] = 101;
  msg[19] = 114;
  msg[20] = 97;
  msg[21] = 108;
  msg[22] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_incomplete_hex_line,
      g_lexer_incomplete_hex_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L005 once for an incomplete float exponent (`e`/`E` with no digits).
 * @param line i32 — 1-based line of the `e`/`E` introducer
 * @param col i32 — 1-based column of the `e`/`E` introducer
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_incomplete_exp(line: i32, col: i32): void {
  if (g_lexer_incomplete_exp == 0) {
    g_lexer_incomplete_exp = 1;
    g_lexer_incomplete_exp_line = line;
    g_lexer_incomplete_exp_col = col;
  }
  if (g_lexer_incomplete_exp_reported != 0) {
    return;
  }
  g_lexer_incomplete_exp_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L005"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 53;
  code[4] = 0;
  // msg = "incomplete float exponent"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 99;
  msg[3] = 111;
  msg[4] = 109;
  msg[5] = 112;
  msg[6] = 108;
  msg[7] = 101;
  msg[8] = 116;
  msg[9] = 101;
  msg[10] = 32;
  msg[11] = 102;
  msg[12] = 108;
  msg[13] = 111;
  msg[14] = 97;
  msg[15] = 116;
  msg[16] = 32;
  msg[17] = 101;
  msg[18] = 120;
  msg[19] = 112;
  msg[20] = 111;
  msg[21] = 110;
  msg[22] = 101;
  msg[23] = 110;
  msg[24] = 116;
  msg[25] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_incomplete_exp_line,
      g_lexer_incomplete_exp_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L006 once for an incomplete binary literal (`0b` / `0B` with no digits).
 * @param line i32 — 1-based line of the leading `0`
 * @param col i32 — 1-based column of the leading `0`
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_incomplete_bin(line: i32, col: i32): void {
  if (g_lexer_incomplete_bin == 0) {
    g_lexer_incomplete_bin = 1;
    g_lexer_incomplete_bin_line = line;
    g_lexer_incomplete_bin_col = col;
  }
  if (g_lexer_incomplete_bin_reported != 0) {
    return;
  }
  g_lexer_incomplete_bin_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L006"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 54;
  code[4] = 0;
  // msg = "incomplete binary literal"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 99;
  msg[3] = 111;
  msg[4] = 109;
  msg[5] = 112;
  msg[6] = 108;
  msg[7] = 101;
  msg[8] = 116;
  msg[9] = 101;
  msg[10] = 32;
  msg[11] = 98;
  msg[12] = 105;
  msg[13] = 110;
  msg[14] = 97;
  msg[15] = 114;
  msg[16] = 121;
  msg[17] = 32;
  msg[18] = 108;
  msg[19] = 105;
  msg[20] = 116;
  msg[21] = 101;
  msg[22] = 114;
  msg[23] = 97;
  msg[24] = 108;
  msg[25] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_incomplete_bin_line,
      g_lexer_incomplete_bin_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L007 once for an incomplete octal literal (`0o` / `0O` with no digits).
 * @param line i32 — 1-based line of the leading `0`
 * @param col i32 — 1-based column of the leading `0`
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_incomplete_oct(line: i32, col: i32): void {
  if (g_lexer_incomplete_oct == 0) {
    g_lexer_incomplete_oct = 1;
    g_lexer_incomplete_oct_line = line;
    g_lexer_incomplete_oct_col = col;
  }
  if (g_lexer_incomplete_oct_reported != 0) {
    return;
  }
  g_lexer_incomplete_oct_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L007"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 55;
  code[4] = 0;
  // msg = "incomplete octal literal"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 99;
  msg[3] = 111;
  msg[4] = 109;
  msg[5] = 112;
  msg[6] = 108;
  msg[7] = 101;
  msg[8] = 116;
  msg[9] = 101;
  msg[10] = 32;
  msg[11] = 111;
  msg[12] = 99;
  msg[13] = 116;
  msg[14] = 97;
  msg[15] = 108;
  msg[16] = 32;
  msg[17] = 108;
  msg[18] = 105;
  msg[19] = 116;
  msg[20] = 101;
  msg[21] = 114;
  msg[22] = 97;
  msg[23] = 108;
  msg[24] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_incomplete_oct_line,
      g_lexer_incomplete_oct_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}


/**
 * Record and report L008 once for an invalid numeric digit separator.
 * Covers trailing `_` (`42_`), consecutive `__` (`1__000`), and `_` not followed
 * by a valid radix digit inside INT/FLOAT digit loops.
 * Prior soft residual: INT+IDENT → XP003 parse-skip.
 * @param line i32 — 1-based line of the invalid `_`
 * @param col i32 — 1-based column of the invalid `_`
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_invalid_digit_sep(line: i32, col: i32): void {
  if (g_lexer_invalid_digit_sep == 0) {
    g_lexer_invalid_digit_sep = 1;
    g_lexer_invalid_digit_sep_line = line;
    g_lexer_invalid_digit_sep_col = col;
  }
  if (g_lexer_invalid_digit_sep_reported != 0) {
    return;
  }
  g_lexer_invalid_digit_sep_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L008"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 56;
  code[4] = 0;
  // msg = "invalid digit separator"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 118;
  msg[3] = 97;
  msg[4] = 108;
  msg[5] = 105;
  msg[6] = 100;
  msg[7] = 32;
  msg[8] = 100;
  msg[9] = 105;
  msg[10] = 103;
  msg[11] = 105;
  msg[12] = 116;
  msg[13] = 32;
  msg[14] = 115;
  msg[15] = 101;
  msg[16] = 112;
  msg[17] = 97;
  msg[18] = 114;
  msg[19] = 97;
  msg[20] = 116;
  msg[21] = 111;
  msg[22] = 114;
  msg[23] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_invalid_digit_sep_line,
      g_lexer_invalid_digit_sep_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L009 once for an unsupported type suffix glued to a numeric literal.
 * Covers `42u32`, `0x2Ai64`, `1.5f32`, and arbitrary `42foo` after a complete INT/FLOAT.
 * Language has no type suffixes (use `as T` or context coerce). Prior soft residual:
 * INT+IDENT → XP003 parse-skip.
 * @param line i32 — 1-based line of the first alphabetic suffix character
 * @param col i32 — 1-based column of the first alphabetic suffix character
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_invalid_type_suffix(line: i32, col: i32): void {
  if (g_lexer_invalid_type_suffix == 0) {
    g_lexer_invalid_type_suffix = 1;
    g_lexer_invalid_type_suffix_line = line;
    g_lexer_invalid_type_suffix_col = col;
  }
  if (g_lexer_invalid_type_suffix_reported != 0) {
    return;
  }
  g_lexer_invalid_type_suffix_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L009"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 48;
  code[3] = 57;
  code[4] = 0;
  // msg = "invalid type suffix"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 118;
  msg[3] = 97;
  msg[4] = 108;
  msg[5] = 105;
  msg[6] = 100;
  msg[7] = 32;
  msg[8] = 116;
  msg[9] = 121;
  msg[10] = 112;
  msg[11] = 101;
  msg[12] = 32;
  msg[13] = 115;
  msg[14] = 117;
  msg[15] = 102;
  msg[16] = 102;
  msg[17] = 105;
  msg[18] = 120;
  msg[19] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_invalid_type_suffix_line,
      g_lexer_invalid_type_suffix_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L010 once for an invalid or incomplete string escape.
 * Covers unknown `\q`, incomplete `\x` / `\xG`, and any escape not in the product set
 * `\n \t \r \0 \\ \" \xHH`. Prior soft residual: silent keep of the second source byte.
 * @param line i32 — 1-based line of the backslash
 * @param col i32 — 1-based column of the backslash
 * @return void
 * PLATFORM: SHARED — stack byte lits only (no va_list); dual-host product matrix.
 */
function lexer_note_invalid_escape(line: i32, col: i32): void {
  if (g_lexer_invalid_escape == 0) {
    g_lexer_invalid_escape = 1;
    g_lexer_invalid_escape_line = line;
    g_lexer_invalid_escape_col = col;
  }
  if (g_lexer_invalid_escape_reported != 0) {
    return;
  }
  g_lexer_invalid_escape_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L010"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 49;
  code[3] = 48;
  code[4] = 0;
  // msg = "invalid escape sequence"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 110;
  msg[2] = 118;
  msg[3] = 97;
  msg[4] = 108;
  msg[5] = 105;
  msg[6] = 100;
  msg[7] = 32;
  msg[8] = 101;
  msg[9] = 115;
  msg[10] = 99;
  msg[11] = 97;
  msg[12] = 112;
  msg[13] = 101;
  msg[14] = 32;
  msg[15] = 115;
  msg[16] = 101;
  msg[17] = 113;
  msg[18] = 117;
  msg[19] = 101;
  msg[20] = 110;
  msg[21] = 99;
  msg[22] = 101;
  msg[23] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_invalid_escape_line,
      g_lexer_invalid_escape_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L011 once for string-literal content exceeding AST capacity.
 * Cap is 4095 semantic bytes (Expr.var_name[256] plus int_val overflow chunks).
 * Called from parser decode authorities (parser.x let-init, primary_slice,
 * parser_gen seed) when a write would exceed the cap — not silent truncate.
 * @param line i32 — 1-based line of the string literal (open quote / overflow site)
 * @param col i32 — 1-based column of the string literal
 * @return void
 * PLATFORM: SHARED — exported so parser/seed decode can call (G.7 sticky face).
 */
export function lexer_note_string_lit_overflow(line: i32, col: i32): void {
  if (g_lexer_string_lit_overflow == 0) {
    g_lexer_string_lit_overflow = 1;
    g_lexer_string_lit_overflow_line = line;
    g_lexer_string_lit_overflow_col = col;
  }
  if (g_lexer_string_lit_overflow_reported != 0) {
    return;
  }
  g_lexer_string_lit_overflow_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L011"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 49;
  code[3] = 49;
  code[4] = 0;
  // msg = "string literal too long"
  let msg: u8[32] = [];
  msg[0] = 115;
  msg[1] = 116;
  msg[2] = 114;
  msg[3] = 105;
  msg[4] = 110;
  msg[5] = 103;
  msg[6] = 32;
  msg[7] = 108;
  msg[8] = 105;
  msg[9] = 116;
  msg[10] = 101;
  msg[11] = 114;
  msg[12] = 97;
  msg[13] = 108;
  msg[14] = 32;
  msg[15] = 116;
  msg[16] = 111;
  msg[17] = 111;
  msg[18] = 32;
  msg[19] = 108;
  msg[20] = 111;
  msg[21] = 110;
  msg[22] = 103;
  msg[23] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_string_lit_overflow_line,
      g_lexer_string_lit_overflow_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/**
 * Record and report L012 once for an identifier longer than AST name capacity.
 * Cap is 255 bytes (name[256] slots; primary_slice / name64 copies use content max 255).
 * Called from try_keyword / try_keyword_buf when falling through to TOKEN_IDENT with
 * span length > 255 — produce-point authority (G.7); not silent clamp / XP003.
 * @param line i32 — 1-based line of the identifier start
 * @param col i32 — 1-based column of the identifier start
 * @return void
 * PLATFORM: SHARED — wave284 Cap residual pure
 */
function lexer_note_ident_too_long(line: i32, col: i32): void {
  if (g_lexer_ident_too_long == 0) {
    g_lexer_ident_too_long = 1;
    g_lexer_ident_too_long_line = line;
    g_lexer_ident_too_long_col = col;
  }
  if (g_lexer_ident_too_long_reported != 0) {
    return;
  }
  g_lexer_ident_too_long_reported = 1;
  // kind = "lexer error"
  let kind: u8[16] = [];
  kind[0] = 108;
  kind[1] = 101;
  kind[2] = 120;
  kind[3] = 101;
  kind[4] = 114;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  // code = "L012"
  let code: u8[8] = [];
  code[0] = 76;
  code[1] = 48;
  code[2] = 49;
  code[3] = 50;
  code[4] = 0;
  // msg = "identifier too long"
  let msg: u8[32] = [];
  msg[0] = 105;
  msg[1] = 100;
  msg[2] = 101;
  msg[3] = 110;
  msg[4] = 116;
  msg[5] = 105;
  msg[6] = 102;
  msg[7] = 105;
  msg[8] = 101;
  msg[9] = 114;
  msg[10] = 32;
  msg[11] = 116;
  msg[12] = 111;
  msg[13] = 111;
  msg[14] = 32;
  msg[15] = 108;
  msg[16] = 111;
  msg[17] = 110;
  msg[18] = 103;
  msg[19] = 0;
  unsafe {
    diag_report_with_code(
      0 as *u8,
      g_lexer_ident_too_long_line,
      g_lexer_ident_too_long_col,
      &kind[0],
      &code[0],
      &msg[0],
      0 as *u8);
  }
}

/** Exported function `lexer_init`.
 * Implements `lexer_init`.
 * @return Lexer
 */
// PLATFORM: SHARED
// The installed type checker rejects a function that returns Lexer.
// Callers pass a slot; the three fields are written there.
export function lexer_init(out: *Lexer): void {
  if (out == 0) { return; }
  let fresh: Lexer = Lexer { pos: 0, line: 1, col: 1 };
  unsafe { *out = fresh; }
}

/** Exported function `advance_one`.
 * Implements `advance_one`.
 * @param lex Lexer
 * @param c u8
 * @return Lexer
 */
// PLATFORM: SHARED — same cursor step as the by-value form. The slot is updated in place.
export function advance_one(lex: *Lexer, c: u8): void {
  if (lex == 0) { return; }
  let cur: Lexer = Lexer { pos: 0, line: 1, col: 1 };
  unsafe { cur = *lex; }
  if (c == 10) {
    let nxt: Lexer = Lexer { pos: cur.pos + 1, line: cur.line + 1, col: 1 };
    unsafe { *lex = nxt; }
    return;
  }
  let nxt2: Lexer = Lexer { pos: cur.pos + 1, line: cur.line, col: cur.col + 1 };
  unsafe { *lex = nxt2; }
}

/** Exported function `is_alpha`.
 * Query helper `is_alpha`.
 * @param c u8
 * @return i32
 */
// PLATFORM: SHARED — installed typeck rejects bool. 1 and 0 are returned in eax.
export function is_alpha(c: u8): i32 {
  if (c >= 97 && c <= 122) { return 1; }
  if (c >= 65 && c <= 90) { return 1; }
  if (c == 95) { return 1; }
  return 0;
}

/** Exported function `is_hex_digit`.
 * Query helper `is_hex_digit`.
 * @param c u8
 * @return i32
 */
export function is_hex_digit(c: u8): i32 {
  if (c >= 48 && c <= 57) { return 1; }
  if (c >= 97 && c <= 102) { return 1; }
  if (c >= 65 && c <= 70) { return 1; }
  return 0;
}

/**
 * wave276 Cap residual: binary digit test for `0b`/`0B` integer literals.
 * @param c u8 — source byte
 * @return i32 — 1 when c is '0' or '1', else 0
 * PLATFORM: SHARED
 */
export function is_bin_digit(c: u8): i32 {
  if (c == 48 || c == 49) { return 1; }
  return 0;
}

/**
 * wave276 Cap residual: octal digit test for `0o`/`0O` integer literals.
 * @param c u8 — source byte
 * @return i32 — 1 when c is in '0'..'7', else 0
 * PLATFORM: SHARED
 */
export function is_oct_digit(c: u8): i32 {
  if (c >= 48 && c <= 55) { return 1; }
  return 0;
}

/**
 * wave277 Cap residual: numeric digit separator `_` (Rust/Python-style).
 * True when `data[pos]` is `_` (ASCII 95) and the next byte is a valid digit for `kind`.
 * Callers advance past the `_` then consume the following digit in the normal loop.
 * Trailing `_`, consecutive `__`, and `_` not followed by a valid radix digit are not
 * separators: digit loops call lexer_note_invalid_digit_sep (sticky L008) instead of
 * leaving soft INT+IDENT XP003 (wave278).
 *
 * Prior wave277: `1_000` / `0x2_A` valid seps; trailing/`__` still soft residual until L008.
 *
 * @param data u8[] — full source buffer
 * @param pos usize — candidate underscore index
 * @param kind i32 — 0=decimal, 1=hex, 2=bin, 3=oct
 * @return i32 — 1 if a digit separator sits at pos, else 0
 * PLATFORM: SHARED — language lexical contract; mac + Ubuntu product matrix.
 */
export function lexer_is_digit_sep(data: u8[], pos: usize, kind: i32): i32 {
  if (pos >= data.length) {
    return 0;
  }
  if (data[pos] != 95) {
    return 0;
  }
  if (pos + 1 >= data.length) {
    return 0;
  }
  let n: u8 = data[pos + 1];
  if (kind == 1) {
    if ((is_hex_digit(n) != 0)) {
      return 1;
    }
    return 0;
  }
  if (kind == 2) {
    if ((is_bin_digit(n) != 0)) {
      return 1;
    }
    return 0;
  }
  if (kind == 3) {
    if ((is_oct_digit(n) != 0)) {
      return 1;
    }
    return 0;
  }
  if ((is_digit(n) != 0)) {
    return 1;
  }
  return 0;
}

/** Exported function `hex_digit_value`.
 * Implements `hex_digit_value`.
 * @param c u8
 * @return i32
 */
export function hex_digit_value(c: u8): i32 {
  if (c >= 48 && c <= 57) { return (c - 48) as i32; }
  if (c >= 97 && c <= 102) { return (c - 97 + 10) as i32; }
  if (c >= 65 && c <= 70) { return (c - 65 + 10) as i32; }
  return 0;
}

/** Exported function `is_digit`.
 * Query helper `is_digit`.
 * @param c u8
 * @return i32
 */
export function is_digit(c: u8): i32 {
  if (c >= 48 && c <= 57) { return 1; }
  return 0;
}

/**
 * wave275 Cap residual: after integer digits, whether `data[pos]` (a `.`) continues a float
 * literal with C-style empty fraction (`1.`, `1.e2`, `1.E-3`) rather than field access
 * (`1.foo`) or a following second dot (`1..`).
 *
 * Prior behavior required a digit immediately after `.`, so `1.e2` lexed as INT + DOT + IDENT
 * and product codegen emitted host C source `1.e2` (accidental float) or `1.e` (host cc error
 * "exponent has no digits") instead of a proper TOKEN_FLOAT / L005 incomplete-exp hard fail.
 *
 * @param data u8[] — full source buffer
 * @param pos usize — index of the candidate `.`
 * @return i32 — 1 if float continues at this `.`, else 0 (leave `.` for field/range)
 * PLATFORM: SHARED — language lexical contract; mac + Ubuntu product matrix.
 */
export function lexer_dot_continues_float(data: u8[], pos: usize): i32 {
  if (pos >= data.length) {
    return 0;
  }
  if (data[pos] != 46) {
    return 0;
  }
  // `1.` at EOF → trailing-dot float (C-style).
  if (pos + 1 >= data.length) {
    return 1;
  }
  let n: u8 = data[pos + 1];
  // `1..` — do not swallow the first dot into a float.
  if (n == 46) {
    return 0;
  }
  if ((is_digit(n) != 0)) {
    return 1;
  }
  // Scientific with empty fraction: `1.e2` / `1.E+10` (then L005 if zero exp digits).
  if (n == 101 || n == 69) {
    return 1;
  }
  // Ident field after int: `1.foo` — keep INT + DOT for suffix field-access chain.
  if ((is_alpha(n) != 0) || n == 95) {
    return 0;
  }
  // Delimiter (`)`, `;`, op, whitespace) after `.` → `1.` float.
  return 1;
}

/** Exported function `is_alnum_underscore`.
 * Query helper `is_alnum_underscore`.
 * @param c u8
 * @return i32
 */
export function is_alnum_underscore(c: u8): i32 {
  if (is_alpha(c) != 0) { return 1; }
  if (is_digit(c) != 0) { return 1; }
  return 0;
}

/** Exported function `match_keyword`.
 * Implements `match_keyword`.
 * @param data u8[]
 * @param start usize
 * @param len i32
 * @param keyword u8[]
 * @return i32
 */
export function match_keyword(data: u8[], start: usize, len: i32, keyword: *u8): i32 {
  let i: i32 = 0;
  if (keyword == 0 as *u8) { return 0; }
  while (i < len) {
    if (data[start + i] != keyword[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Exported function `match_keyword_buf`.
 * Implements `match_keyword_buf`.
 * @param data *u8
 * @param data_len i32
 * @param start usize
 * @param len i32
 * @param keyword u8[]
 * @return i32
 */
export function match_keyword_buf(data: *u8, data_len: i32, start: usize, len: i32, keyword: *u8): i32 {
  let i: i32 = 0;
  if (keyword == 0 as *u8) { return 0; }
  while (i < len) {
    if ((start as i32) + i >= data_len) { return 0; }
    if (data[start + i] != keyword[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Map scanned identifier (data, start, len) to a keyword Token, or
 * TOKEN_IDENT (ident null, ident_len = len) when not a keyword.
 *
 * The keyword chain is split across try_keyword_b/c/d. One function that
 * spells every Token literal trips typeck after the 22nd literal
 * (bogus "expected TokenKind, found i32" on a later field). Same limit
 * that split lexer_next_punct_into out of lexer_next_body_into.
 *
 * kind fields use TokenKind ordinal integers (see token.x export enum order:
 * 0=TOKEN_EOF, 1=TOKEN_FUNCTION, ...). Ordinals match the cold seed C
 * tags. PLATFORM: SHARED.
 */
// PLATFORM: SHARED — Token is written through out. Link name is unchanged.
export function try_keyword(out: *Token, data: u8[], start: usize, len: usize, line0: i32, col0: i32): void {
  let nlen: i32 = len as i32;
  if (nlen == 8 && (match_keyword(data, start, 8, "function" as *u8) != 0)) {
    let t: Token = {
      kind: (1 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "let" as *u8) != 0)) {
    let t: Token = {
      kind: (2 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "const" as *u8) != 0)) {
    let t: Token = {
      kind: (3 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 2 && (match_keyword(data, start, 2, "if" as *u8) != 0)) {
    let t: Token = {
      kind: (4 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "else" as *u8) != 0)) {
    let t: Token = {
      kind: (5 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "while" as *u8) != 0)) {
    let t: Token = {
      kind: (6 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "loop" as *u8) != 0)) {
    let t: Token = {
      kind: (7 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "for" as *u8) != 0)) {
    let t: Token = {
      kind: (8 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "break" as *u8) != 0)) {
    let t: Token = {
      kind: (9 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 8 && (match_keyword(data, start, 8, "continue" as *u8) != 0)) {
    let t: Token = {
      kind: (10 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "return" as *u8) != 0)) {
    let t: Token = {
      kind: (11 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "panic" as *u8) != 0)) {
    let t: Token = {
      kind: (12 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "defer" as *u8) != 0)) {
    let t: Token = {
      kind: (13 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "region" as *u8) != 0)) {
    let t: Token = {
      kind: (16 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 10 && (match_keyword(data, start, 10, "with_arena" as *u8) != 0)) {
    let t: Token = {
      kind: (17 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "match" as *u8) != 0)) {
    let t: Token = {
      kind: (18 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  try_keyword_b(out, data, start, len, line0, col0);
    return;
}

/**
 * Second slice of try_keyword. Returns the keyword token, or the next slice.
 * @param data u8[] — source bytes
 * @param start usize — first byte of the identifier
 * @param len usize — identifier length in bytes
 * @param line0 i32 — token line
 * @param col0 i32 — token column
 * @return Token — keyword token or the result of try_keyword_c
 * PLATFORM: SHARED
 */
function try_keyword_b(out: *Token, data: u8[], start: usize, len: usize, line0: i32, col0: i32): void {
  let nlen: i32 = len as i32;
  if (nlen == 6 && (match_keyword(data, start, 6, "struct" as *u8) != 0)) {
    let t: Token = {
      kind: (19 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "type" as *u8) != 0)) {
    let t: Token = {
      kind: (20 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "packed" as *u8) != 0)) {
    let t: Token = {
      kind: (21 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "soa" as *u8) != 0)) {
    let t: Token = {
      kind: (22 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "align" as *u8) != 0)) {
    let t: Token = {
      kind: (46 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "enum" as *u8) != 0)) {
    let t: Token = {
      kind: (47 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "goto" as *u8) != 0)) {
    let t: Token = {
      kind: (48 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "trait" as *u8) != 0)) {
    let t: Token = {
      kind: (49 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "impl" as *u8) != 0)) {
    let t: Token = {
      kind: (50 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "self" as *u8) != 0)) {
    let t: Token = {
      kind: (51 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 1 && data[start] == 95) {
    let t: Token = {
      kind: (52 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "import" as *u8) != 0)) {
    let t: Token = {
      kind: (53 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "extern" as *u8) != 0)) {
    let t: Token = {
      kind: (54 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "async" as *u8) != 0)) {
    let t: Token = {
      kind: (55 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "await" as *u8) != 0)) {
    let t: Token = {
      kind: (56 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "run" as *u8) != 0)) {
    let t: Token = {
      kind: (57 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  try_keyword_c(out, data, start, len, line0, col0);
    return;
}

/**
 * Third slice of try_keyword. Returns the keyword token, or the next slice.
 * @param data u8[] — source bytes
 * @param start usize — first byte of the identifier
 * @param len usize — identifier length in bytes
 * @param line0 i32 — token line
 * @param col0 i32 — token column
 * @return Token — keyword token or the result of try_keyword_d
 * PLATFORM: SHARED
 */
function try_keyword_c(out: *Token, data: u8[], start: usize, len: usize, line0: i32, col0: i32): void {
  let nlen: i32 = len as i32;
  if (nlen == 5 && (match_keyword(data, start, 5, "spawn" as *u8) != 0)) {
    let t: Token = {
      kind: (58 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }
  /** export：e x p o r t */  if (nlen == 6 && (match_keyword(data, start, 6, "export" as *u8) != 0)) {
    let t: Token = {
      kind: (131 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "i32" as *u8) != 0)) {
    let t: Token = {
      kind: (60 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "bool" as *u8) != 0)) {
    let t: Token = {
      kind: (61 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 2 && (match_keyword(data, start, 2, "u8" as *u8) != 0)) {
    let t: Token = {
      kind: (62 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "u32" as *u8) != 0)) {
    let t: Token = {
      kind: (63 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "u64" as *u8) != 0)) {
    let t: Token = {
      kind: (64 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "i64" as *u8) != 0)) {
    let t: Token = {
      kind: (65 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "usize" as *u8) != 0)) {
    let t: Token = {
      kind: (66 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "isize" as *u8) != 0)) {
    let t: Token = {
      kind: (67 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "true" as *u8) != 0)) {
    let t: Token = {
      kind: (75 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "false" as *u8) != 0)) {
    let t: Token = {
      kind: (76 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }
  /*
   * wave668 Cap residual: keyword `null` → TOKEN_NULL (132, enum-end after EXPORT).
   * Bytes: n=110 u=117 l=108 l=108. G.7 single keyword table (try_keyword + buf twin).
   * PLATFORM: SHARED.
   */  if (nlen == 4 && (match_keyword(data, start, 4, "null" as *u8) != 0)) {
    let t: Token = {
      kind: (132 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "f32" as *u8) != 0)) {
    let t: Token = {
      kind: (77 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 3 && (match_keyword(data, start, 3, "f64" as *u8) != 0)) {
    let t: Token = {
      kind: (78 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 4 && (match_keyword(data, start, 4, "void" as *u8) != 0)) {
    let t: Token = {
      kind: (79 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  try_keyword_d(out, data, start, len, line0, col0);
    return;
}

/**
 * Last slice of try_keyword, including the TOKEN_IDENT fallback.
 * @param data u8[] — source bytes
 * @param start usize — first byte of the identifier
 * @param len usize — identifier length in bytes
 * @param line0 i32 — token line
 * @param col0 i32 — token column
 * @return Token — keyword token, or TOKEN_IDENT when nothing matches
 * PLATFORM: SHARED
 */
function try_keyword_d(out: *Token, data: u8[], start: usize, len: usize, line0: i32, col0: i32): void {
  let nlen: i32 = len as i32;
  if (nlen == 5 && (match_keyword(data, start, 5, "i3x4" as *u8) != 0)) {
    let t: Token = {
      kind: (68 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "i3x8" as *u8) != 0)) {
    let t: Token = {
      kind: (69 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "i3x16" as *u8) != 0)) {
    let t: Token = {
      kind: (70 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "u3x4" as *u8) != 0)) {
    let t: Token = {
      kind: (71 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 5 && (match_keyword(data, start, 5, "u3x8" as *u8) != 0)) {
    let t: Token = {
      kind: (72 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 6 && (match_keyword(data, start, 6, "u3x16" as *u8) != 0)) {
    let t: Token = {
      kind: (73 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }  if (nlen == 2 && (match_keyword(data, start, 2, "as" as *u8) != 0)) {
    let t: Token = {
      kind: (128 as TokenKind),
      line: line0,
      col: col0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = (t); }
    return;
  }
  // Cap 4.2.8: AST name slots are 255 bytes. Longer identifiers set the L012 sticky note.
  if (nlen > 255) {
    lexer_note_ident_too_long(line0, col0);
  }
  let t: Token = {
    kind: (59 as TokenKind),
    line: line0,
    col: col0,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: nlen };
  // Whole-token image. `*out = t` drops ident_len on the Windows bootstrap.
  // `&t` is a block local. Passing it with outer *Token is T001 unless
  // the call is in unsafe. The callee copies 48 bytes and drops the pointer.
  // PLATFORM: SHARED.
  unsafe { lexer_store_token(out, &t); }
  return;
}

/* See implementation. */
export function try_keyword_buf(out: *Token, data: *u8, data_len: i32, start: usize, len: usize, line0: i32, col0:
i32): void {
  let nlen: i32 = len as i32;
  if (nlen == 8 && (match_keyword_buf(data, data_len, start, 8, "function" as *u8) != 0)) {
    let t: Token = { kind: (1 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 3 && (match_keyword_buf(data, data_len, start, 3, "let" as *u8) != 0)) {
    let t: Token = { kind: (2 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "const" as *u8) != 0)) {
    let t: Token = { kind: (3 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 2 && (match_keyword_buf(data, data_len, start, 2, "if" as *u8) != 0)) {
    let t: Token = { kind: (4 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val:
      0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "else" as *u8) != 0)) {
    let t: Token = { kind: (5 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 6 && (match_keyword_buf(data, data_len, start, 6, "return" as *u8) != 0)) {
    let t: Token = { kind: (11 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 6 && (match_keyword_buf(data, data_len, start, 6, "struct" as *u8) != 0)) {
    let t: Token = { kind: (19 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "type" as *u8) != 0)) {
    let t: Token = { kind: (20 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "enum" as *u8) != 0)) {
    let t: Token = { kind: (47 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "match" as *u8) != 0)) {
    let t: Token = { kind: (18 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "true" as *u8) != 0)) {
    let t: Token = { kind: (75 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "false" as *u8) != 0)) {
    let t: Token = { kind: (76 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  /* wave668: `null` → TOKEN_NULL (132). G.7 ≡ try_keyword. PLATFORM: SHARED. */
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "null" as *u8) != 0)) {
    let t: Token = { kind: (132 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 3 && (match_keyword_buf(data, data_len, start, 3, "f64" as *u8) != 0)) {
    let t: Token = { kind: (78 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "void" as *u8) != 0)) {
    let t: Token = { kind: (79 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 3 && (match_keyword_buf(data, data_len, start, 3, "i32" as *u8) != 0)) {
    let t: Token = { kind: (60 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 4 && (match_keyword_buf(data, data_len, start, 4, "bool" as *u8) != 0)) {
    let t: Token = { kind: (61 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 2 && (match_keyword_buf(data, data_len, start, 2, "u8" as *u8) != 0)) {
    let t: Token = { kind: (62 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val:
      0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "usize" as *u8) != 0)) {
    let t: Token = { kind: (66 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "isize" as *u8) != 0)) {
    let t: Token = { kind: (67 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 2 && (match_keyword_buf(data, data_len, start, 2, "as" as *u8) != 0)) {
    let t: Token = { kind: (128 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val:
      0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 6 && (match_keyword_buf(data, data_len, start, 6, "import" as *u8) != 0)) {
    let t: Token = { kind: (53 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 6 && (match_keyword_buf(data, data_len, start, 6, "extern" as *u8) != 0)) {
    let t: Token = { kind: (54 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "async" as *u8) != 0)) {
    let t: Token = { kind: (55 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "await" as *u8) != 0)) {
    let t: Token = { kind: (56 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 3 && (match_keyword_buf(data, data_len, start, 3, "run" as *u8) != 0)) {
    let t: Token = { kind: (57 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 5 && (match_keyword_buf(data, data_len, start, 5, "spawn" as *u8) != 0)) {
    let t: Token = { kind: (58 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 6 && (match_keyword_buf(data, data_len, start, 6, "export" as *u8) != 0)) {
    let t: Token = { kind: (131 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  if (nlen == 1 && start < (data_len as usize) && data[start] == 95) {
    let t: Token = { kind: (52 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    unsafe { *out = (t); }
    return;
  }
  // wave Cap 4.2.8: G.7 mirror try_keyword — L012 when non-keyword span > 255.
  if (nlen > 255) {
    lexer_note_ident_too_long(line0, col0);
  }
  let t: Token = { kind: (59 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
    float_val: 0.0, ident: (0 as *u8), ident_len: nlen };
  // Whole-token image. `*out = t` drops ident_len on the Windows bootstrap.
  // `&t` is a block local. Passing it with outer *Token is T001 unless
  // the call is in unsafe. The callee copies 48 bytes and drops the pointer.
  // PLATFORM: SHARED.
  unsafe { lexer_store_token(out, &t); }
  return;
}

/**
 * See implementation.
 * See implementation.
 */
// PLATFORM: SHARED — result is written through out. Link name is unchanged.
export function skip_repr_c_attr_if_present(out: *Lexer, lex: Lexer, data: u8[]): void {
  let l: Lexer = lex;
  if (out == 0) { return; }
  if (l.pos + (10 as usize) > data.length) {
    unsafe { *out = l; }
    return;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    unsafe { *out = l; }
    return;
  }
  if (data[l.pos + (2 as usize)] != 114 || data[l.pos + (3 as usize)] != 101 || data[l.pos + (4 as usize)] != 112 ||
      data[l.pos + (5 as usize)] != 114) {
    unsafe { *out = l; }
    return;
  }
  if (data[l.pos + (6 as usize)] != 40 || data[l.pos + (7 as usize)] != 67 || data[l.pos + (8 as usize)] != 41 ||
      data[l.pos + (9 as usize)] != 93) {
    unsafe { *out = l; }
    return;
  }
  let nxt: Lexer = Lexer { pos: l.pos + (10 as usize), line: l.line, col: l.col };
  unsafe { *out = nxt; }
}

/**
 * See implementation.
 * See implementation.
 */
export function skip_cfg_attr_if_present(out: *Lexer, lex: Lexer, data: u8[]): void {
  let l: Lexer = lex;
  let p: usize = 0;
  let depth: i32 = 0;
  if (out == 0) { return; }
  if (l.pos + (6 as usize) > data.length) {
    unsafe { *out = l; }
    return;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    unsafe { *out = l; }
    return;
  }
  if (data[l.pos + (2 as usize)] != 99 || data[l.pos + (3 as usize)] != 102 || data[l.pos + (4 as usize)] != 103) {
    unsafe { *out = l; }
    return;
  }
  if (data[l.pos + (5 as usize)] != 40) {
    unsafe { *out = l; }
    return;
  }
  p = l.pos + (6 as usize);
  depth = 1;
  while (p < data.length && depth > 0) {
    if (data[p] == 40) {
      depth = depth + 1;
    } else if (data[p] == 41) {
      depth = depth - 1;
    }
    p = p + (1 as usize);
  }
  if (p >= data.length || data[p] != 93) {
    unsafe { *out = lex; }
    return;
  }
  p = p + (1 as usize);
  let nxt: Lexer = Lexer { pos: p, line: l.line, col: l.col };
  unsafe { *out = nxt; }
}

/**
 * B-01 v1: If `l` is at `#[cfg(...)]`, evaluate host match, write TOKEN_ATTR_CFG, return 1.
 * Copies the expression into a stack buffer before cfg_eval_expr_c (avoids C-frontend ambiguity).
 * PLATFORM: SHARED — LANG-007 S0: cfg_eval_expr_c is extern FFI inside unsafe (Cap-T001).
 */
export function lexer_try_cfg_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let p: usize = 0;
  let depth: i32 = 0;
  let expr_start: usize = 0;
  if (l.pos + (6 as usize) > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    return 0;
  }
  if (data[l.pos + (2 as usize)] != 99 || data[l.pos + (3 as usize)] != 102 || data[l.pos + (4 as usize)] != 103) {
    return 0;
  }
  if (data[l.pos + (5 as usize)] != 40) {
    return 0;
  }
  p = l.pos + (6 as usize);
  depth = 1;
  expr_start = p;
  while (p < data.length && depth > 0) {
    if (data[p] == 40) {
      depth = depth + 1;
    } else if (data[p] == 41) {
      depth = depth - 1;
    }
    p = p + (1 as usize);
  }
  if (p >= data.length || data[p] != 93) {
    return 0;
  }
  let expr_len: i32 = (p as i32) - (expr_start as i32) - 1;
  if (expr_len <= 0 || expr_len > 255) {
    return 0;
  }
  let tmp: u8[256] = [];
  let ti: i32 = 0;
  while (ti < expr_len) {
    tmp[ti] = data[expr_start + (ti as usize)];
    ti = ti + 1;
  }
  // PLATFORM: SHARED — LANG-007 S0: extern call requires unsafe (Cap-T001).
  let enabled: i32 = 0;
  unsafe {
    enabled = cfg_eval_expr_c(&tmp[0], expr_len) as i32;
  }
  p = p + (1 as usize);
  let l2: Lexer = { pos: p, line: l.line, col: l.col };
  let tok: Token = {
    kind: (24 as TokenKind),
    line: line0,
    col: col0,
    int_val: enabled as i64,
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
export function lexer_try_repr_c_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (10 as usize) > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    return 0;
  }
  if (data[l.pos + (2 as usize)] != 114 || data[l.pos + (3 as usize)] != 101 || data[l.pos + (4 as usize)] != 112 ||
      data[l.pos + (5 as usize)] != 114) {
    return 0;
  }
  if (data[l.pos + (6 as usize)] != 40 || data[l.pos + (7 as usize)] != 67 || data[l.pos + (8 as usize)] != 41 ||
      data[l.pos + (9 as usize)] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let np: usize = l.pos + (10 as usize);
  let l2: Lexer = { pos: np, line: line0, col: col0 };
  let tok: Token = {
    kind: (25 as TokenKind),
    line: line0,
    col: col0,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_repr_compatible_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (19 as usize) > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    return 0;
  }
  if (data[l.pos + (2 as usize)] != 114 || data[l.pos + (3 as usize)] != 101 || data[l.pos + (4 as usize)] != 112 ||
      data[l.pos + (5 as usize)] != 114) {
    return 0;
  }
  if (data[l.pos + (6 as usize)] != 40) {
    return 0;
  }
  if (data[l.pos + (7 as usize)] != 99 || data[l.pos + (8 as usize)] != 111 || data[l.pos + (9 as usize)] != 109 ||
      data[l.pos + (10 as usize)] != 112 || data[l.pos + (11 as usize)] != 97 || data[l.pos + (12 as usize)] != 116 ||
      data[l.pos + (13 as usize)] != 105 || data[l.pos + (14 as usize)] != 98 || data[l.pos + (15 as usize)] != 108 ||
      data[l.pos + (16 as usize)] != 101) {
    return 0;
  }
  if (data[l.pos + (17 as usize)] != 41 || data[l.pos + (18 as usize)] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let np: usize = l.pos + (19 as usize);
  let l2: Lexer = { pos: np, line: line0, col: col0 };
  let tok: Token = {
    kind: (26 as TokenKind),
    line: line0,
    col: col0,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_soa_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (6 as usize) > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    return 0;
  }
  if (data[l.pos + (2 as usize)] != 115 || data[l.pos + (3 as usize)] != 111 || data[l.pos + (4 as usize)] != 97 ||
      data[l.pos + (5 as usize)] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let l2: Lexer = l;
  advance_one(&l2, 35);
  advance_one(&l2, 91);
  advance_one(&l2, 115);
  advance_one(&l2, 111);
  advance_one(&l2, 97);
  advance_one(&l2, 93);
  let tok: Token = {
    kind: (23 as TokenKind),
    line: line0,
    col: col0,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_alloc_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (8 as usize) > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    return 0;
  }
  if (data[l.pos + (2 as usize)] != 97 || data[l.pos + (3 as usize)] != 108 || data[l.pos + (4 as usize)] != 108 ||
      data[l.pos + (5 as usize)] != 111 || data[l.pos + (6 as usize)] != 99 || data[l.pos + (7 as usize)] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let l2: Lexer = l;
  advance_one(&l2, 35);
  advance_one(&l2, 91);
  advance_one(&l2, 97);
  advance_one(&l2, 108);
  advance_one(&l2, 108);
  advance_one(&l2, 111);
  advance_one(&l2, 99);
  advance_one(&l2, 93);
  let tok: Token = {
    kind: (27 as TokenKind),
    line: line0,
    col: col0,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_used_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (7 as usize) > data.length) {
    return 0;
  }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) {
    return 0;
  }
  if (data[l.pos + (2 as usize)] != 117 || data[l.pos + (3 as usize)] != 115 ||
      data[l.pos + (4 as usize)] != 101 || data[l.pos + (5 as usize)] != 100 || data[l.pos + (6 as usize)] != 93) {
    return 0;
  }
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  let l2: Lexer = l;
  advance_one(&l2, 35);
  advance_one(&l2, 91);
  advance_one(&l2, 117);
  advance_one(&l2, 115);
  advance_one(&l2, 101);
  advance_one(&l2, 100);
  advance_one(&l2, 93);
  let tok: Token = {
    kind: (31 as TokenKind),
    line: line0,
    col: col0,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l2);
  write_tok_into(out, tok);
  out.token_start = (0 as usize);
  return 1;
}

/**
 * See implementation.
 */
export function lexer_try_naked_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (8 as usize) > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) { return 0; }
  if (data[l.pos + (2 as usize)] != 110 || data[l.pos + (3 as usize)] != 97 || data[l.pos + (4 as usize)] != 107 ||
      data[l.pos + (5 as usize)] != 101 || data[l.pos + (6 as usize)] != 100 || data[l.pos + (7 as usize)] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  advance_one(&l2, 35); advance_one(&l2, 91); advance_one(&l2, 110);
  advance_one(&l2, 97); advance_one(&l2, 107); advance_one(&l2, 101);
  advance_one(&l2, 100); advance_one(&l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, { kind: (29 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_entry_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (8 as usize) > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) { return 0; }
  if (data[l.pos + (2 as usize)] != 101 || data[l.pos + (3 as usize)] != 110 || data[l.pos + (4 as usize)] != 116 ||
      data[l.pos + (5 as usize)] != 114 || data[l.pos + (6 as usize)] != 121 || data[l.pos + (7 as usize)] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  advance_one(&l2, 35); advance_one(&l2, 91); advance_one(&l2, 101);
  advance_one(&l2, 110); advance_one(&l2, 116); advance_one(&l2, 114);
  advance_one(&l2, 101); advance_one(&l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, { kind: (30 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_no_mangle_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (12 as usize) > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) { return 0; }
  if (data[l.pos + (2 as usize)] != 110 || data[l.pos + (3 as usize)] != 111 || data[l.pos + (4 as usize)] != 95 ||
      data[l.pos + (5 as usize)] != 109 || data[l.pos + (6 as usize)] != 97 || data[l.pos + (7 as usize)] != 110 ||
      data[l.pos + (8 as usize)] != 103 || data[l.pos + (9 as usize)] != 108 || data[l.pos + (10 as usize)] != 101 || data[l.pos + (11 as usize)] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  advance_one(&l2, 35); advance_one(&l2, 91); advance_one(&l2, 110);
  advance_one(&l2, 111); advance_one(&l2, 95); advance_one(&l2, 109);
  advance_one(&l2, 97); advance_one(&l2, 110); advance_one(&l2, 103);
  advance_one(&l2, 108); advance_one(&l2, 101); advance_one(&l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, { kind: (32 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_interrupt_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (13 as usize) > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) { return 0; }
  if (data[l.pos + (2 as usize)] != 105 || data[l.pos + (3 as usize)] != 110 || data[l.pos + (4 as usize)] != 116 ||
      data[l.pos + (5 as usize)] != 101 || data[l.pos + (6 as usize)] != 114 || data[l.pos + (7 as usize)] != 114 ||
      data[l.pos + (8 as usize)] != 117 || data[l.pos + (9 as usize)] != 112 || data[l.pos + (10 as usize)] != 116 || data[l.pos + (11 as usize)] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  advance_one(&l2, 35); advance_one(&l2, 91); advance_one(&l2, 105);
  advance_one(&l2, 110); advance_one(&l2, 116); advance_one(&l2, 101);
  advance_one(&l2, 114); advance_one(&l2, 114); advance_one(&l2, 117);
  advance_one(&l2, 112); advance_one(&l2, 116); advance_one(&l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, { kind: (35 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_send_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (8 as usize) > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) { return 0; }
  if (data[l.pos + (2 as usize)] != 115 || data[l.pos + (3 as usize)] != 101 || data[l.pos + (4 as usize)] != 110 ||
      data[l.pos + (5 as usize)] != 100 || data[l.pos + (6 as usize)] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  advance_one(&l2, 35); advance_one(&l2, 91); advance_one(&l2, 115);
  advance_one(&l2, 101); advance_one(&l2, 110); advance_one(&l2, 100);
  advance_one(&l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, { kind: (36 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * See implementation.
 */
export function lexer_try_sync_attr_into(out: *LexerResult, l: Lexer, data: u8[]): i32 {
  if (l.pos + (8 as usize) > data.length) { return 0; }
  if (data[l.pos] != 35 || data[l.pos + (1 as usize)] != 91) { return 0; }
  if (data[l.pos + (2 as usize)] != 115 || data[l.pos + (3 as usize)] != 121 || data[l.pos + (4 as usize)] != 110 ||
      data[l.pos + (5 as usize)] != 99 || data[l.pos + (6 as usize)] != 93) { return 0; }
  let line0: i32 = l.line; let col0: i32 = l.col; let l2: Lexer = l;
  advance_one(&l2, 35); advance_one(&l2, 91); advance_one(&l2, 115);
  advance_one(&l2, 121); advance_one(&l2, 110); advance_one(&l2, 99);
  advance_one(&l2, 93);
  write_next_lex_into(out, l2);
  write_tok_into(out, { kind: (37 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 });
  out.token_start = (0 as usize); return 1;
}

/**
 * Whether `prev` continues a path/ident so an interior `/`+`*` is a path glob
 * (e.g. `src/*.x`, `arrow}/*.o`), not a nested block-comment opener.
 * @param prev u8 — byte immediately before a candidate slash of the nest-open sequence
 * @return i32 — 1 if path/ident continuum (suppress nest-open), else 0
 * PLATFORM: SHARED
 */
function lexer_block_comment_prev_is_path_like(prev: u8): i32 {
  // A-Z
  if (prev >= 65) {
    if (prev <= 90) {
      return 1;
    }
  }
  // a-z
  if (prev >= 97) {
    if (prev <= 122) {
      return 1;
    }
  }
  // 0-9
  if (prev >= 48) {
    if (prev <= 57) {
      return 1;
    }
  }
  // _ . } ) ] > " '
  if (prev == 95) {
    return 1;
  }
  if (prev == 46) {
    return 1;
  }
  if (prev == 125) {
    return 1;
  }
  if (prev == 41) {
    return 1;
  }
  if (prev == 93) {
    return 1;
  }
  if (prev == 62) {
    return 1;
  }
  if (prev == 34) {
    return 1;
  }
  if (prev == 39) {
    return 1;
  }
  return 0;
}

/**
 * Skip whitespace and comments from the current lexer position.
 *
 * Line comments: double-slash to end of line, and bare hash lines (not hash-bracket attrs).
 * Block comments (single-line and multi-line — one algorithm): nested block-comment
 * delimiters by head/tail depth balance (not C first-close). Below, OPEN means the
 * two-byte nest-open sequence (slash immediately followed by star) and CLOSE means
 * the two-byte nest-close sequence (star immediately followed by slash):
 *   - the outer OPEN sets depth=1; each true nest-OPEN does depth+1;
 *   - each CLOSE does depth-1; the block ends only when depth returns to 0.
 * Examples (all valid on one line): OPEN-body-CLOSE, OPEN-OPEN-CLOSE-CLOSE,
 * empty OPEN-CLOSE, and dense OPEN-OPEN-...-CLOSE-CLOSE nests.
 * Unbalanced OPENs alone leave depth>0 (unclosed) — need matching CLOSEs.
 *
 * Nest-open is path-safe (wave138 root fix):
 * - Intentional nests still open: space or star before OPEN, prose empties, dense nests.
 * - Path globs do NOT open: path-slash-star-ext, dir-slash-star-ext, brace-slash-star-ext,
 *   line-start slash-star-dot-ext (prev path-like, or next byte after OPEN is dot).
 * Unmatched bare CLOSE with no nested open still closes the outer block (depth 1 to 0).
 *
 * wave269: EOF with nesting depth > 0 is a hard diagnostic (L001 unclosed block
 * comment) at the outermost open site; sticky flag forces product parse fail.
 *
 * PLATFORM: SHARED — language lexical semantics; dual-host product matrix.
 *
 * @param lex Lexer — current position / line / col
 * @param data u8[] — full source buffer (not required to be NUL-terminated)
 * @return Lexer — advanced past whitespace and comments; unchanged on EOF
 */
// PLATFORM: SHARED — the advanced cursor is written through out.
export function skip_whitespace_and_comments(out: *Lexer, lex: Lexer, data: u8[]): void {
  let l: Lexer = lex;
  // Nesting depth for block comments; 0 means not inside a block comment.
  let depth: i32 = 0;
  while (l.pos < data.length) {
    let c: u8 = data[l.pos];
    if (c == 32 || c == 9 || c == 10 || c == 13) {
      advance_one(&l, c);
    } else if (c == 47 && l.pos + (1 as usize) < data.length && data[l.pos + (1 as usize)] == 47) {
      // Line comment // ...
      while (l.pos < data.length && data[l.pos] != 10) {
        advance_one(&l, data[l.pos]);
      }
    } else if (c == 47 && l.pos + (1 as usize) < data.length && data[l.pos + (1 as usize)] == 42) {
      // Block comment /* ... */ with nesting (depth counter).
      // Capture open caret before consuming the slash-star pair.
      let open_line: i32 = l.line;
      let open_col: i32 = l.col;
      advance_one(&l, 47);
      advance_one(&l, 42);
      depth = 1;
      while (l.pos < data.length && depth > 0) {
        // Prefer path-safe /* nest-open before */ nest-close when both could match.
        if (l.pos + (1 as usize) < data.length && data[l.pos] == 47 && data[l.pos + (1 as usize)] == 42) {
          // Decide whether this interior /* is a true nest or a path glob.
          let nest_ok: i32 = 1;
          if (l.pos > (0 as usize)) {
            let prev: u8 = data[l.pos - (1 as usize)];
            if (lexer_block_comment_prev_is_path_like(prev) != 0) {
              nest_ok = 0;
            }
          }
          // /*.ext path globs after newline / outer open (prev not path-like).
          if (nest_ok != 0) {
            if (l.pos + (2 as usize) < data.length) {
              if (data[l.pos + (2 as usize)] == 46) {
                nest_ok = 0;
              }
            }
          }
          if (nest_ok != 0) {
            advance_one(&l, 47);
            advance_one(&l, 42);
            depth = depth + 1;
          } else {
            // Path glob or non-nest: consume only '/' so '*' is ordinary body text.
            advance_one(&l, data[l.pos]);
          }
        } else if (l.pos + (1 as usize) < data.length && data[l.pos] == 42 && data[l.pos + (1 as usize)] == 47) {
          advance_one(&l, 42);
          advance_one(&l, 47);
          depth = depth - 1;
        } else {
          advance_one(&l, data[l.pos]);
        }
      }
      // EOF with depth > 0: unclosed block comment (body swallowed to EOF).
      // Hard diag L001 + sticky flag → product parse entry returns fail.
      if (depth > 0) {
        lexer_note_unclosed_block_comment(open_line, open_col);
      }
      depth = 0;
    } else if (c == 35) {
      // Bare # line comment; leave #[cfg]/attrs to the token scanner.
      if (l.pos + (1 as usize) < data.length && data[l.pos + (1 as usize)] == 91) {
        unsafe { *out = (l); }
        return;
      } else {
        while (l.pos < data.length && data[l.pos] != 10) {
          advance_one(&l, data[l.pos]);
        }
      }
    } else {
      unsafe { *out = (l); }
      return;
    }
  }
  unsafe { *out = (l); }
  return;
}

/** See implementation for details. */
/**
 * Same as skip_whitespace_and_comments for raw (data, len) buffers.
 * PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
 */
export function skip_whitespace_and_comments_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  unsafe {
    skip_whitespace_and_comments(out, lex, lexer_slice_from_raw(data, len));
  }
}

/**
 * Slice API for one token. Symbol is lexer_next_slice, matching the host-cc
 * seed. The name lexer_next belongs to the cold glue stub
 * (lexer_next(lex, out_tok) writes TOKEN_EOF); defining it here would replace
 * that stub at link.
 * @param lex Lexer — cursor before the next token
 * @param data u8[] — source bytes
 * @return LexerResult — next cursor, token, and token start
 * PLATFORM: SHARED
 */
// PLATFORM: SHARED — LexerResult is written through out. Link name is unchanged.
export function lexer_next_slice(out: *LexerResult, lex: Lexer, data: u8[]): void {
  let l: Lexer = lex;
  skip_whitespace_and_comments(&l, lex, data);
  if (l.pos >= data.length) {
    let t: Token = {
      kind: (0 as TokenKind),
      line: l.line,
      col: l.col,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = ({ next_lex: l, tok: t, token_start: (0 as usize) }); }
    return;
  }
  if (data[l.pos] == 0) {
    let t: Token = {
      kind: (0 as TokenKind),
      line: l.line,
      col: l.col,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    };
    unsafe { *out = ({ next_lex: l, tok: t, token_start: (0 as usize) }); }
    return;
  }
  /* See implementation. */
  let attr_out: LexerResult = {
    next_lex: l,
    tok: { kind: (0 as TokenKind), line: l.line, col: l.col, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 },
    token_start: (0 as usize)
  };
  if (lexer_try_cfg_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_repr_c_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_repr_compatible_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_soa_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_alloc_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_used_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_naked_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_entry_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_no_mangle_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_interrupt_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_send_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  if (lexer_try_sync_attr_into(&attr_out, l, data) != 0) {
    unsafe { *out = (attr_out); }
    return;
  }
  /* See implementation. */
  lexer_next_body_into(&attr_out, l, data);
  unsafe { *out = (attr_out); }
  return;
}

/**
* See implementation.
* See implementation.
*/
/**
 * Optionally consume a float exponent (`e`/`E` [+-]? digits) and scale `fval`.
 * wave274 Cap residual: zero digits after `e`/`E` (optional sign) is incomplete — sticky L005
 * and return -1 (caller must not emit a silent TOKEN_FLOAT with exp=0).
 * @param l Lexer — position at optional `e`/`E`
 * @param data u8[] — full source buffer
 * @param fval f64 — significand so far
 * @param out_l *Lexer — advanced lexer (always written; past incomplete e/sign too)
 * @param out_f *f64 — scaled value on success; unchanged significand on incomplete
 * @return i32 — 0 ok (no exp or complete exp), -1 incomplete exp (L005 sticky set)
 * PLATFORM: SHARED
 */
export function lexer_apply_optional_exponent(l: Lexer, data: u8[], fval: f64, out_l: *Lexer, out_f:
*f64): i32 {
  let lex: Lexer = l;
  let cur: f64 = fval;
  if (lex.pos < data.length && (data[lex.pos] == 101 || data[lex.pos] == 69)) {
    let e_line: i32 = lex.line;
    let e_col: i32 = lex.col;
    advance_one(&lex, data[lex.pos]);
    let exp_sign: i32 = 1;
    if (lex.pos < data.length && data[lex.pos] == 45) {
      exp_sign = -1;
      advance_one(&lex, 45);
    } else {
      if (lex.pos < data.length && data[lex.pos] == 43) { advance_one(&lex, 43); }
    }
    let exp: i32 = 0;
    let exp_digits: i32 = 0;
    // wave277: allow `_` digit separators in optional exponent digits.
    while (lex.pos < data.length) {
      if ((is_digit(data[lex.pos]) != 0)) {
        let d: u8 = data[lex.pos];
        advance_one(&lex, d);
        exp = exp * 10 + (d - 48);
        exp_digits = exp_digits + 1;
      } else if (lexer_is_digit_sep(data, lex.pos, 0) != 0) {
        advance_one(&lex, 95);
      } else {
        break;
      }
    }
    // wave278: invalid `_` in optional exp digits → sticky L008 (caller emits EOF).
    if (lex.pos < data.length && data[lex.pos] == 95) {
      lexer_note_invalid_digit_sep(lex.line, lex.col);
      out_l[0] = lex;
      out_f[0] = cur;
      return -1;
    }
    // wave274: `1e` / `1e+` / `1.5e-` with zero digits was silent exp=0 (wrong TOKEN_FLOAT).
    if (exp_digits == 0) {
      lexer_note_incomplete_exp(e_line, e_col);
      out_l[0] = lex;
      out_f[0] = cur;
      return -1;
    }
    exp = exp * exp_sign;
    let scale: f64 = 1.0;
    let e: i32 = 0;
    if (exp > 0) {
      while (e < exp) {
        scale = scale * 10.0;
        e = e + 1;
      }
    } else {
      while (e > exp) {
        scale = scale * 0.1;
        e = e - 1;
      }
    }
    cur = fval * scale;
  }
  out_l[0] = lex;
  out_f[0] = cur;
  return 0;
}

/** Exported function `lexer_next_body_into`.
 * Implements `lexer_next_body_into`.
 * @param out *LexerResult
 * @param l Lexer
 * @param data u8[]
 * @return void
 */
export function lexer_next_body_into(out: *LexerResult, l: Lexer, data: u8[]): void {
  let c: u8 = data[l.pos];
  /* See implementation. */
  if (lexer_try_cfg_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_repr_c_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_repr_compatible_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_soa_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_alloc_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_used_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_naked_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_entry_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_no_mangle_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_interrupt_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_send_attr_into(out, l, data) != 0) {
    return;
  }
  if (lexer_try_sync_attr_into(out, l, data) != 0) {
    return;
  }
  /* wave271 Cap residual: double-quoted string; EOF without closer → L002 hard diag.
   * Multi-line strings remain valid when a closing quote appears later in the file.
   * wave281: escape validation — product set `\n \t \r \0 \\ \" \xHH` only; else sticky L010. */
  if (c == 34) {
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    let start: usize = l.pos + (1 as usize);
    advance_one(&l, 34);
    while (l.pos < data.length && data[l.pos] != 34) {
      if (data[l.pos] == 92) {
        // Lone `\` at EOF (no next byte): fall through to L002 unclosed path below.
        if (l.pos + (1 as usize) >= data.length) {
          advance_one(&l, 92);
          continue;
        }
        // wave281: validate escape; invalid → sticky L010 + TOKEN_EOF (not silent keep).
        let esc_line: i32 = l.line;
        let esc_col: i32 = l.col;
        advance_one(&l, 92);
        let e: u8 = data[l.pos];
        // Single-char escapes: \n \t \r \0 \\ \"
        if (e == 110 || e == 116 || e == 114 || e == 48 || e == 92 || e == 34) {
          advance_one(&l, e);
          continue;
        }
        // Hex escape `\xHH` — require two hex digits after `x`.
        if (e == 120) {
          if (l.pos + (2 as usize) < data.length && (is_hex_digit(data[l.pos + (1 as usize)]) != 0) && (is_hex_digit(data[l.pos + (2 as usize)]) != 0)) {
            advance_one(&l, 120);
            advance_one(&l, data[l.pos]);
            advance_one(&l, data[l.pos]);
            continue;
          }
          lexer_note_invalid_escape(esc_line, esc_col);
          let tok_eof_hex: Token = { kind: (0 as TokenKind), line: esc_line, col: esc_col, int_val: (0 as i64),
            float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
          write_next_lex_into(out, l);
          write_tok_into(out, tok_eof_hex);
          out.token_start = start;
          return;
        }
        lexer_note_invalid_escape(esc_line, esc_col);
        let tok_eof_esc: Token = { kind: (0 as TokenKind), line: esc_line, col: esc_col, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_esc);
        out.token_start = start;
        return;
      }
      advance_one(&l, data[l.pos]);
    }
    if (l.pos >= data.length) {
      // wave271: silent TOKEN_EOF here swallowed the rest of the module (no main / soft P001).
      lexer_note_unclosed_string(line0, col0);
      let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_eof);
      out.token_start = start;
      return;
    }
    let slen: i32 = (l.pos - start) as i32;
    advance_one(&l, 34);
    let tok_str: Token = { kind: (130 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: slen };
    write_next_lex_into(out, l);
    write_tok_into(out, tok_str);
    out.token_start = start;
    return;
  }
  if ((is_alpha(c) != 0)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    advance_one(&l, c);
    while (l.pos < data.length && (is_alnum_underscore(data[l.pos]) != 0)) {
      advance_one(&l, data[l.pos]);
    }
    let len: usize = l.pos - start;
    let tok: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64), float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    try_keyword(&tok, data, start, len, line0, col0);
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if ((is_digit(c) != 0)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    let ival: i64 = 0;
    advance_one(&l, c);
    if (c == 48 && l.pos < data.length && (data[l.pos] == 120 || data[l.pos] == 88)) {
      // wave273 Cap residual: `0x`/`0X` requires ≥1 hex digit. Zero digits was silent
      // TOKEN_INT(0) (wrong) or left a following letter that soft-dropped the function (P001).
      advance_one(&l, data[l.pos]);
      let hval: u64 = (0 as u64);
      let hex_digits: i32 = 0;
      // wave277: allow `_` digit separators between hex digits (`0x2_A`, `0x_FF`).
      while (l.pos < data.length) {
        if ((is_hex_digit(data[l.pos]) != 0)) {
          let hd: u8 = data[l.pos];
          hval = hval * 16 + (hex_digit_value(hd) as u64);
          advance_one(&l, hd);
          hex_digits = hex_digits + 1;
        } else if (lexer_is_digit_sep(data, l.pos, 1) != 0) {
          advance_one(&l, 95);
        } else {
          break;
        }
      }
      // wave278: `_` not followed by hex digit → sticky L008 (not soft XP003 / L004-only).
      if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
      }
      if (hex_digits == 0) {
        lexer_note_incomplete_hex(line0, col0);
        let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof);
        out.token_start = start;
        return;
      }
      // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
      if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
        lexer_note_invalid_type_suffix(l.line, l.col);
        let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sfx);
        out.token_start = start;
        return;
      }
      let tok: Token = { kind: (80 as TokenKind), line: line0, col: col0, int_val: hval as i64,
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    // wave276 Cap residual: `0b`/`0B` binary integer (mirror hex L004 path).
    // Prior: INT(0)+IDENT → soft XP003 parse-skip. Zero bin digits → sticky L006.
    if (c == 48 && l.pos < data.length && (data[l.pos] == 98 || data[l.pos] == 66)) {
      advance_one(&l, data[l.pos]);
      let bval: u64 = (0 as u64);
      let bin_digits: i32 = 0;
      // wave277: allow `_` digit separators between binary digits (`0b_101010`).
      while (l.pos < data.length) {
        if ((is_bin_digit(data[l.pos]) != 0)) {
          let bd: u8 = data[l.pos];
          bval = bval * 2 + ((bd - 48) as u64);
          advance_one(&l, bd);
          bin_digits = bin_digits + 1;
        } else if (lexer_is_digit_sep(data, l.pos, 2) != 0) {
          advance_one(&l, 95);
        } else {
          break;
        }
      }
      // wave278: invalid `_` digit separator → sticky L008.
      if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
      }
      if (bin_digits == 0) {
        lexer_note_incomplete_bin(line0, col0);
        let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof);
        out.token_start = start;
        return;
      }
      // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
      if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
        lexer_note_invalid_type_suffix(l.line, l.col);
        let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sfx);
        out.token_start = start;
        return;
      }
      let tok_b: Token = { kind: (80 as TokenKind), line: line0, col: col0, int_val: bval as i64,
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_b);
      out.token_start = start;
      return;
    }
    // wave276 Cap residual: `0o`/`0O` octal integer (mirror hex L004 path).
    // Prior: INT(0)+IDENT → soft XP003 parse-skip. Zero oct digits → sticky L007.
    if (c == 48 && l.pos < data.length && (data[l.pos] == 111 || data[l.pos] == 79)) {
      advance_one(&l, data[l.pos]);
      let oval: u64 = (0 as u64);
      let oct_digits: i32 = 0;
      // wave277: allow `_` digit separators between octal digits (`0o5_2`).
      while (l.pos < data.length) {
        if ((is_oct_digit(data[l.pos]) != 0)) {
          let od: u8 = data[l.pos];
          oval = oval * 8 + ((od - 48) as u64);
          advance_one(&l, od);
          oct_digits = oct_digits + 1;
        } else if (lexer_is_digit_sep(data, l.pos, 3) != 0) {
          advance_one(&l, 95);
        } else {
          break;
        }
      }
      // wave278: invalid `_` digit separator → sticky L008.
      if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
      }
      if (oct_digits == 0) {
        lexer_note_incomplete_oct(line0, col0);
        let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof);
        out.token_start = start;
        return;
      }
      // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
      if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
        lexer_note_invalid_type_suffix(l.line, l.col);
        let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sfx);
        out.token_start = start;
        return;
      }
      let tok_o: Token = { kind: (80 as TokenKind), line: line0, col: col0, int_val: oval as i64,
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_o);
      out.token_start = start;
      return;
    }
    ival = ival * 10 + (c - 48);
    // wave277: allow `_` digit separators in decimal ints (`1_000`, `4_2`).
    while (l.pos < data.length) {
      if ((is_digit(data[l.pos]) != 0)) {
        let d: u8 = data[l.pos];
        advance_one(&l, d);
        ival = ival * 10 + (d - 48);
      } else if (lexer_is_digit_sep(data, l.pos, 0) != 0) {
        advance_one(&l, 95);
      } else {
        break;
      }
    }
    // wave278: trailing/invalid `_` after decimal digits → sticky L008.
    if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
    }
    // wave275 Cap residual: C-style empty fraction after `.` (`1.`, `1.e2`) → TOKEN_FLOAT.
    // Prior: required digit after `.` so `1.e2` became INT+DOT+IDENT and codegen leaked host C
    // float text (silent wrong / host "exponent has no digits"). Field `1.foo` and `1..` stay INT.
    if (l.pos < data.length && data[l.pos] == 46 && lexer_dot_continues_float(data, l.pos) != 0) {
      advance_one(&l, 46);
      let fval: f64 = (ival as f64);
      let frac: f64 = 0.1;
      // wave277: allow `_` digit separators in float fraction digits.
      while (l.pos < data.length) {
        if ((is_digit(data[l.pos]) != 0)) {
          let d: u8 = data[l.pos];
          advance_one(&l, d);
          fval = fval + frac * (d - 48);
          frac = frac * 0.1;
        } else if (lexer_is_digit_sep(data, l.pos, 0) != 0) {
          advance_one(&l, 95);
        } else {
          break;
        }
      }
      // wave278: invalid `_` in fraction digits → sticky L008.
      if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
      }
      // wave274: incomplete exp after fraction → L005 + TOKEN_EOF (not silent exp=0 float).
      // wave275: also covers empty-frac scientific `1.e` / `1.e+` (was host-cc soft residual).
      if (lexer_apply_optional_exponent(l, data, fval, &l, &fval) != 0) {
        let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof);
        out.token_start = start;
        return;
      }
      // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
      if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
        lexer_note_invalid_type_suffix(l.line, l.col);
        let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sfx);
        out.token_start = start;
        return;
      }
      let tok: Token = { kind: (81 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
        float_val: fval, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && (data[l.pos] == 101 || data[l.pos] == 69)) {
      // wave274 Cap residual: `1e`/`1e+`/`1E-` require ≥1 exp digit (mirror L004 hex digits).
      let e_line: i32 = l.line;
      let e_col: i32 = l.col;
      advance_one(&l, data[l.pos]);
      let exp_sign: i32 = 1;
      if (l.pos < data.length && data[l.pos] == 45) {
        exp_sign = -1;
        advance_one(&l, 45);
      } else {
        if (l.pos < data.length && data[l.pos] == 43) { advance_one(&l, 43); }
      }
      let exp: i32 = 0;
      let exp_digits: i32 = 0;
      // wave277: allow `_` digit separators in float exponent digits (`1e2_0`).
      while (l.pos < data.length) {
        if ((is_digit(data[l.pos]) != 0)) {
          let d: u8 = data[l.pos];
          advance_one(&l, d);
          exp = exp * 10 + (d - 48);
          exp_digits = exp_digits + 1;
        } else if (lexer_is_digit_sep(data, l.pos, 0) != 0) {
          advance_one(&l, 95);
        } else {
          break;
        }
      }
      // wave278: invalid `_` in exponent digits → sticky L008.
      if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
      }
      if (exp_digits == 0) {
        lexer_note_incomplete_exp(e_line, e_col);
        let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof);
        out.token_start = start;
        return;
      }
      exp = exp * exp_sign;
      let scale: f64 = 1.0;
      let e: i32 = 0;
      if (exp > 0) {
        while (e < exp) {
          scale = scale * 10.0;
          e = e + 1;
        }
      } else {
        while (e > exp) {
          scale = scale * 0.1;
          e = e - 1;
        }
      }
      let fval: f64 = (ival as f64) * scale;
      // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
      if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
        lexer_note_invalid_type_suffix(l.line, l.col);
        let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sfx);
        out.token_start = start;
        return;
      }
      let tok: Token = { kind: (81 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
        float_val: fval, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
    if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
      lexer_note_invalid_type_suffix(l.line, l.col);
      let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_eof_sfx);
      out.token_start = start;
      return;
    }
    let tok: Token = { kind: (80 as TokenKind), line: line0, col: col0, int_val: ival,
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    /* See implementation. */
    out.token_start = start;
    return;
  }
  if (c == 46 && l.pos + (1 as usize) < data.length && (is_digit(data[l.pos + (1 as usize)]) != 0)) {
    let start: usize = l.pos;
    let line0: i32 = l.line;
    let col0: i32 = l.col;
    advance_one(&l, 46);
    let fval: f64 = 0.0;
    let frac: f64 = 0.1;
    // wave277: allow `_` digit separators in float fraction digits.
    while (l.pos < data.length) {
      if ((is_digit(data[l.pos]) != 0)) {
        let d: u8 = data[l.pos];
        advance_one(&l, d);
        fval = fval + frac * (d - 48);
        frac = frac * 0.1;
      } else if (lexer_is_digit_sep(data, l.pos, 0) != 0) {
        advance_one(&l, 95);
      } else {
        break;
      }
    }
    // wave278: invalid `_` in leading-dot fraction → sticky L008.
    if (l.pos < data.length && data[l.pos] == 95) {
        lexer_note_invalid_digit_sep(l.line, l.col);
        let tok_eof_sep: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
          float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
        write_next_lex_into(out, l);
        write_tok_into(out, tok_eof_sep);
        out.token_start = start;
        return;
    }
    // wave274: incomplete exp after leading-dot float → L005 + TOKEN_EOF.
    if (lexer_apply_optional_exponent(l, data, fval, &l, &fval) != 0) {
      let tok_eof: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_eof);
      out.token_start = start;
      return;
    }
    // wave279: alphabetic type suffix after complete numeric → sticky L009 (not soft XP003).
    if (l.pos < data.length && (is_alpha(data[l.pos]) != 0)) {
      lexer_note_invalid_type_suffix(l.line, l.col);
      let tok_eof_sfx: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
        float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
      write_next_lex_into(out, l);
      write_tok_into(out, tok_eof_sfx);
      out.token_start = start;
      return;
    }
    let tok: Token = { kind: (81 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
      float_val: fval, ident: (0 as *u8), ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  // Punctuation/operators: dedicated helper keeps body_into under typeck limits.
  lexer_next_punct_into(out, l, data, c);

}

/**
 * Lex one punctuation/operator token at the current position.
 * Caller has observed first character `c` at data[l.pos] and has not advanced yet.
 * Split out of lexer_next_body_into so each function stays under typeck body limits
 * (large if-chain + fallthrough previously reported bogus TokenKind/? errors).
 * Stores use `(N as TokenKind)`. A bare i32 assigned to TokenKind fails
 * typeck in this chain. Struct-literal ordinals stay bare integers: spelling
 * `TokenKind.VARIANT` in a literal still hits codegen entry emission -6.
 * PLATFORM: SHARED — pure lex logic; no FFI.
 */
export function lexer_next_punct_into(out: *LexerResult, l: Lexer, data: u8[], c: u8): void {
  let start: usize = l.pos;
  let line0: i32 = l.line;
  let col0: i32 = l.col;
  advance_one(&l, c);
  let tok: Token = { kind: (0 as TokenKind), line: line0, col: col0, int_val: (0 as i64),
    float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
  if (c == 40) { lexer_tok_with_kind(&tok, (82 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 41) { lexer_tok_with_kind(&tok, (83 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 123) { lexer_tok_with_kind(&tok, (84 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 125) { lexer_tok_with_kind(&tok, (85 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 91) { lexer_tok_with_kind(&tok, (86 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 93) { lexer_tok_with_kind(&tok, (87 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 44) { lexer_tok_with_kind(&tok, (90 as TokenKind)); write_next_lex_into(out, l); write_tok_into(out,
    tok); out.token_start = start; return; }
  if (c == 58) { lexer_tok_with_kind(&tok, (91 as TokenKind)); write_next_lex_into(out, l); write_tok_into(out,
    tok); out.token_start = start; return; }
  if (c == 46) {
    /* See implementation. */
    if (l.pos + (1 as usize) < data.length && data[l.pos] == 46 && data[l.pos + (1 as usize)] == 46) {
      advance_one(&l, 46);
      advance_one(&l, 46);
      lexer_tok_with_kind(&tok, (94 as TokenKind));
    } else {
      lexer_tok_with_kind(&tok, (92 as TokenKind));
    }
    write_next_lex_into(out, l); write_tok_into(out,
    tok); out.token_start = start; return; }
  if (c == 59) { lexer_tok_with_kind(&tok, (95 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 43) {
    /* See implementation. */
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (106 as TokenKind));
    } else {
      lexer_tok_with_kind(&tok, (96 as TokenKind));
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 45) {
    if (l.pos < data.length && data[l.pos] == 62) {
      advance_one(&l, 62);
      lexer_tok_with_kind(&tok, (88 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (107 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (97 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 42) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (108 as TokenKind));
    } else {
      lexer_tok_with_kind(&tok, (98 as TokenKind));
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 47) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (109 as TokenKind));
    } else {
      lexer_tok_with_kind(&tok, (99 as TokenKind));
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 37) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (110 as TokenKind));
    } else {
      lexer_tok_with_kind(&tok, (100 as TokenKind));
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 94) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (113 as TokenKind));
    } else {
      lexer_tok_with_kind(&tok, (103 as TokenKind));
    }
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 126) { lexer_tok_with_kind(&tok, (116 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 38) {
    if (l.pos < data.length && data[l.pos] == 38) {
      advance_one(&l, 38);
      lexer_tok_with_kind(&tok, (124 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (111 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (101 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 124) {
    if (l.pos < data.length && data[l.pos] == 124) {
      advance_one(&l, 124);
      lexer_tok_with_kind(&tok, (125 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (112 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (102 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 60) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (122 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 60) {
      advance_one(&l, 60);
      if (l.pos < data.length && data[l.pos] == 61) {
        advance_one(&l, 61);
        lexer_tok_with_kind(&tok, (114 as TokenKind));
      } else {
        lexer_tok_with_kind(&tok, (104 as TokenKind));
      }
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (120 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 62) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (123 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 62) {
      advance_one(&l, 62);
      if (l.pos < data.length && data[l.pos] == 61) {
        advance_one(&l, 61);
        lexer_tok_with_kind(&tok, (115 as TokenKind));
      } else {
        lexer_tok_with_kind(&tok, (105 as TokenKind));
      }
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (121 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 33) {
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (119 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (126 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  if (c == 63) { lexer_tok_with_kind(&tok, (127 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 64) { lexer_tok_with_kind(&tok, (129 as TokenKind)); write_next_lex_into(out, l);
    write_tok_into(out, tok); out.token_start = start; return; }
  if (c == 61) {
    if (l.pos < data.length && data[l.pos] == 62) {
      advance_one(&l, 62);
      lexer_tok_with_kind(&tok, (89 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    if (l.pos < data.length && data[l.pos] == 61) {
      advance_one(&l, 61);
      lexer_tok_with_kind(&tok, (118 as TokenKind));
      write_next_lex_into(out, l);
      write_tok_into(out, tok);
      out.token_start = start;
      return;
    }
    lexer_tok_with_kind(&tok, (117 as TokenKind));
    write_next_lex_into(out, l);
    write_tok_into(out, tok);
    out.token_start = start;
    return;
  }
  // wave272 Cap residual: unknown byte was silent TOKEN_EOF → soft P001 / BLD001.
  // Hard diag L003 + sticky flag → product parse entry returns fail (mirror L001/L002).
  // Still advance past the byte and emit TOKEN_EOF so the token stream terminates.
  // wave1222: use current lexer position directly — line0/col0/start from if-blocks
  // above are block-scoped and may hold stale values from a prior parse file when
  // the X codegen hoists let-decls to function level. This ensures L003 reports the
  // actual illegal byte position, not a leftover from a previous file's token scan.
  let ill_line: i32 = l.line;
  let ill_col: i32 = l.col;
  let ill_start: usize = l.pos;
  lexer_note_illegal_char(ill_line, ill_col);
  let unk: Token = {
    kind: (0 as TokenKind),
    line: ill_line,
    col: ill_col,
    int_val: (0 as i64),
    float_val: 0.0,
    ident: (0 as *u8),
    ident_len: 0
  };
  write_next_lex_into(out, l);
  write_tok_into(out, unk);
  out.token_start = ill_start;
}

/** Exported function `write_next_lex_into`.
 * Write path helper `write_next_lex_into`.
 * @param out *LexerResult
 * @param l Lexer
 * @return void
 */
export function write_next_lex_into(out: *LexerResult, l: Lexer): void {
  out.next_lex.pos = l.pos;
  out.next_lex.line = l.line;
  out.next_lex.col = l.col;
  out.token_start = (0 as usize);
}
/** Exported function `write_tok_into`.
 * Write path helper `write_tok_into`.
 * @param out *LexerResult
 * @param t Token
 * @return void
 */
export function write_tok_into(out: *LexerResult, t: Token): void {
  // Whole-token store. Copying kind by field faults the pin egg.
  // Struct assign keeps 8 bytes on the Windows bootstrap; see lexer_store_token.
  // PLATFORM: SHARED.
  lexer_store_token(&out.tok, &t);
}

/** Exported function `lexer_next_impl`.
 * Implements `lexer_next_impl`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data u8[]
 * @return void
 */
export function lexer_next_impl(out: *LexerResult, lex: Lexer, data: u8[]): void {
  let l: Lexer = lex;
  skip_whitespace_and_comments(&l, lex, data);
  if (l.pos >= data.length) {
    let t: Token = { kind: (0 as TokenKind), line: l.line, col: l.col, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, t);
    return;
  }
  if (data[l.pos] == 0) {
    let t: Token = { kind: (0 as TokenKind), line: l.line, col: l.col, int_val: (0 as i64),
      float_val: 0.0, ident: (0 as *u8), ident_len: 0 };
    write_next_lex_into(out, l);
    write_tok_into(out, t);
    return;
  }
  lexer_next_body_into(out, l, data);
}

/** Exported function `lexer_next_into`.
 * Implements `lexer_next_into`.
 * @param out *LexerResult
 * @param lex Lexer
 * @param data u8[]
 * @return void
 */
export function lexer_next_into(out: *LexerResult, lex: Lexer, data: u8[]): void {
  lexer_next_impl(out, lex, data);
}

/** See implementation for details. */
/**
 * Buf + len path writing into out via lexer_next_into.
 * PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
 */
export function lexer_next_buf_into(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  unsafe {
    lexer_next_into(out, lex, lexer_slice_from_raw(data, len));
  }
}

/**
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
/**
 * Same as lexer_next for raw (data, len).
 * PLATFORM: SHARED — LANG-007 S0: slice glue is extern; call inside unsafe (Cap-T001).
 */
// PLATFORM: SHARED — LexerResult is written through out. The slice path is unchanged.
export function lexer_next_buf(out: *LexerResult, lex: Lexer, data: *u8, len: i32): void {
  unsafe {
    lexer_next_slice(out, lex, lexer_slice_from_raw(data, len));
  }
}
