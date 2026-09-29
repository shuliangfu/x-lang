// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// parser_asm_lex_step_bridge.x — checklist 6.1 / w1534.
// One peek/step face for the P9a lexer bridge. Callers in pthin_*.x keep
// the opaque pointer ABI. This file owns the single call to lexer_next_into
// and the scalar field reads. It does not walk tokens and it does not
// replace the stretch skip helpers.
//
// Layout matches seeds/parser_asm_lex_step_bridge.from_x.c and the lexer
// authority: Lexer is 16 bytes, Token is 48, LexerResult is 72, slice is 16.
// A 16-byte lexer is passed in two GPRs on SysV (Darwin arm64 verified
// against clang; Linux x86_64 is the same shape). Write-back of the next
// lexer is field stores. A whole-struct store keeps only the low 8 bytes.
// The wrap ring stores its data pointer with memcpy of 8 bytes. A store
// through *u8 emits one byte.
//
// The C seed stays on disk for the prove harnesses. Product g05 must not
// host-cc it. Chapter 9 deletes the seed.
// PLATFORM: SHARED. Windows x64 passes a struct larger than 8 bytes by
// address. If that host's product matrix is red, split the calls the way
// parser_asm_parse_expr_link.x does. Do not host-cc the seed to go green.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

extern function lexer_next_into(out: *ParserAsmLexResult, lex: ParserAsmLexLexer, data: *u8): void;

extern function parser_asm_stretch_is_type_start_kind_c(kind: i32): i32;
extern function parser_asm_stretch_skip_balanced_brackets_into_c(lex_inout: *u8, source: *u8): i32;
extern function parser_asm_stretch_skip_type_suffix_c(lex_inout: *u8, source: *u8): i32;
extern function parser_asm_stretch_skip_one_param_type_c(lex_inout: *u8, source: *u8): i32;
extern function parser_asm_skip_balanced_parens_into_slice_c(out: *ParserAsmLexLexer, lex: ParserAsmLexLexer, source: *u8): void;
extern function parser_asm_skip_balanced_braces_into_slice_c(out: *ParserAsmLexLexer, lex: ParserAsmLexLexer, source: *u8): void;
extern function parser_asm_skip_one_struct_slice_c(lex: ParserAsmLexLexer, source: *u8): ParserAsmLexLexer;
extern function parser_asm_skip_imports_slice_c(lex: ParserAsmLexLexer, source: *u8): ParserAsmLexLexer;

// 16 bytes. pos at 0, line at 8, col at 12. Same as struct parser_asm_lexer.
allow(padding) struct ParserAsmLexLexer {
  pos: usize;
  line: i32;
  col: i32;
}

// 48 bytes. int_val at 16, float_val at 24, ident at 32, ident_len at 40.
allow(padding) struct ParserAsmLexToken {
  kind: i32;
  line: i32;
  col: i32;
  int_val: i64;
  float_val: f64;
  ident: *u8;
  ident_len: i32;
}

// 72 bytes. next_lex at 0, tok at 16, token_start at 64.
allow(padding) struct ParserAsmLexResult {
  next_lex: ParserAsmLexLexer;
  tok: ParserAsmLexToken;
  token_start: usize;
}

// 16 bytes. data at 0, length at 8.
allow(padding) struct ParserAsmLexSlice {
  data: *u8;
  length: usize;
}

// Sixteen scratch slices. 16 * 16 = 256 bytes. The pipeline is one thread
// and audit nesting stays inside this ring. PLATFORM: SHARED.
let g_lex_wrap_bytes: u8[256] = [];
let g_lex_wrap_i: i32[1] = [0];

/**
 * Copy 8 pointer bytes. A store through *u8 writes one byte, so the wrap
 * ring cannot use it for the slice data field.
 * @param dst *u8 — destination slot; caller owns; not null
 * @param v *u8 — pointer value to store
 * @return void
 * PLATFORM: SHARED.
 */
function parser_asm_lex_bridge_store_ptr(dst: *u8, v: *u8): void {
  unsafe {
    let src: *u8 = &v as *u8;
    memcpy(dst, src, 8);
  }
}

/**
 * Copy 8 integer bytes into the wrap ring length slot.
 * @param dst *u8 — destination slot; caller owns; not null
 * @param v u64 — length
 * @return void
 * PLATFORM: SHARED.
 */
function parser_asm_lex_bridge_store_u64(dst: *u8, v: u64): void {
  unsafe {
    let src: *u8 = &v as *u8;
    memcpy(dst, src, 8);
  }
}

/**
 * Copy one f64 as 8 bytes. The peek face is pointer-out so the lane never
 * returns f64.
 * @param dst *u8 — destination; caller owns; not null
 * @param v f64 — token float payload
 * @return void
 * PLATFORM: SHARED.
 */
function parser_asm_lex_bridge_store_f64(dst: *u8, v: f64): void {
  unsafe {
    let src: *u8 = &v as *u8;
    memcpy(dst, src, 8);
  }
}

/**
 * Copy one i64 as 8 bytes.
 * @param dst *u8 — destination; caller owns; not null
 * @param v i64 — token integer payload
 * @return void
 * PLATFORM: SHARED.
 */
function parser_asm_lex_bridge_store_i64(dst: *u8, v: i64): void {
  unsafe {
    let src: *u8 = &v as *u8;
    memcpy(dst, src, 8);
  }
}

/**
 * Run lexer_next_into on a copy of the caller's lexer and field-copy the
 * 72-byte result into raw. Does not advance the caller's lexer. A null
 * argument returns 0 and leaves raw unchanged.
 * The result is not returned by value: a 72-byte return is a wide-return
 * crash on this compiler. Whole-struct assignment keeps only 8 bytes, so
 * each field is stored on its own.
 * @param lex_in *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @param raw *u8 — 72-byte caller buffer; null returns 0
 * @return i32 — 1 when the lexer ran, 0 when an argument was null
 * PLATFORM: SHARED.
 */
function parser_asm_lex_bridge_fill(lex_in: *u8, source: *u8, raw: *u8): i32 {
  if (lex_in == 0) {
    return 0;
  }
  if (source == 0) {
    return 0;
  }
  if (raw == 0) {
    return 0;
  }
  let r: ParserAsmLexResult = {
    next_lex: { pos: 0, line: 0, col: 0 },
    tok: {
      kind: 0,
      line: 0,
      col: 0,
      int_val: (0 as i64),
      float_val: 0.0,
      ident: (0 as *u8),
      ident_len: 0
    },
    token_start: 0
  };
  unsafe {
    let p: *ParserAsmLexLexer = lex_in as *ParserAsmLexLexer;
    // Two-register load of the 16-byte lexer. The call overwrites r.
    let cur: ParserAsmLexLexer = *p;
    lexer_next_into(&r, cur, source);
    let dst: *ParserAsmLexResult = raw as *ParserAsmLexResult;
    dst.next_lex.pos = r.next_lex.pos;
    dst.next_lex.line = r.next_lex.line;
    dst.next_lex.col = r.next_lex.col;
    dst.tok.kind = r.tok.kind;
    dst.tok.line = r.tok.line;
    dst.tok.col = r.tok.col;
    dst.tok.int_val = r.tok.int_val;
    dst.tok.float_val = r.tok.float_val;
    dst.tok.ident = r.tok.ident;
    dst.tok.ident_len = r.tok.ident_len;
    dst.token_start = r.token_start;
  }
  return 1;
}

/**
 * Advance the lexer one step and return the next token kind.
 * @param lex_inout *u8 — opaque lexer; updated in place; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return i32 — next token kind, or 0 when an argument is null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_step_kind_c(lex_inout: *u8, source: *u8): i32 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex_inout, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    // Field stores. A whole-struct store drops line and col.
    p.pos = r.next_lex.pos;
    p.line = r.next_lex.line;
    p.col = r.next_lex.col;
    return r.tok.kind;
  }
}

/**
 * Read the lexer cursor offset.
 * @param lex *u8 — opaque lexer; null returns 0
 * @return usize — pos
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_pos_c(lex: *u8): usize {
  if (lex == 0) {
    return 0;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex as *ParserAsmLexLexer;
    return p.pos;
  }
}

/**
 * Write the lexer cursor. With set_line_c and set_col_c this is the restore
 * trio for a by-value audit that must not keep the stepped cursor.
 * @param lex *u8 — opaque lexer; null is a no-op
 * @param pos usize — new cursor
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_set_pos_c(lex: *u8, pos: usize): void {
  if (lex == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex as *ParserAsmLexLexer;
    p.pos = pos;
  }
}

/**
 * Write the lexer line. Second field of the restore trio.
 * @param lex *u8 — opaque lexer; null is a no-op
 * @param line i32 — new line
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_set_line_c(lex: *u8, line: i32): void {
  if (lex == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex as *ParserAsmLexLexer;
    p.line = line;
  }
}

/**
 * Write the lexer column. Third field of the restore trio.
 * @param lex *u8 — opaque lexer; null is a no-op
 * @param col i32 — new column
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_set_col_c(lex: *u8, col: i32): void {
  if (lex == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex as *ParserAsmLexLexer;
    p.col = col;
  }
}

/**
 * Read the lexer line.
 * @param lex *u8 — opaque lexer; null returns 0
 * @return i32 — line
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_line_c(lex: *u8): i32 {
  if (lex == 0) {
    return 0;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex as *ParserAsmLexLexer;
    return p.line;
  }
}

/**
 * Read the lexer column.
 * @param lex *u8 — opaque lexer; null returns 0
 * @return i32 — column
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_col_c(lex: *u8): i32 {
  if (lex == 0) {
    return 0;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex as *ParserAsmLexLexer;
    return p.col;
  }
}

/**
 * Read the source slice data pointer.
 * @param source *u8 — opaque slice; null returns null
 * @return *u8 — data bytes; may be null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_source_data_c(source: *u8): *u8 {
  if (source == 0) {
    return 0;
  }
  unsafe {
    let s: *ParserAsmLexSlice = source as *ParserAsmLexSlice;
    return s.data;
  }
}

/**
 * Read the source slice length.
 * @param source *u8 — opaque slice; null returns 0
 * @return usize — byte length
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_source_length_c(source: *u8): usize {
  if (source == 0) {
    return 0;
  }
  unsafe {
    let s: *ParserAsmLexSlice = source as *ParserAsmLexSlice;
    return s.length;
  }
}

/**
 * Peek the next token kind. The caller's lexer is not written.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return i32 — next token kind
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_kind_c(lex: *u8, source: *u8): i32 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.tok.kind;
  }
}

/**
 * Peek the next token float payload into out. The caller's lexer is not written.
 * @param lex *u8 — opaque lexer; read-only; null returns
 * @param source *u8 — opaque slice; null returns
 * @param out *u8 — receives the 8-byte f64; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_float_val_into_c(lex: *u8, source: *u8, out: *u8): void {
  if (out == 0) {
    return;
  }
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    parser_asm_lex_bridge_store_f64(out, r.tok.float_val);
  }
}

/**
 * Peek the next token's full i64 payload into out.
 * @param lex *u8 — opaque lexer; read-only; null returns
 * @param source *u8 — opaque slice; null returns
 * @param out *u8 — receives the 8-byte i64; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_int64_val_into_c(lex: *u8, source: *u8, out: *u8): void {
  if (out == 0) {
    return;
  }
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    parser_asm_lex_bridge_store_i64(out, r.tok.int_val);
  }
}

/**
 * Peek the next token int_val truncated to i32.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return i32 — truncated int_val
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_int_val_c(lex: *u8, source: *u8): i32 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.tok.int_val as i32;
  }
}

/**
 * Peek the next token ident_len. The caller's lexer is not written.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return i32 — ident_len, or 0 when the token has no ident
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_ident_len_c(lex: *u8, source: *u8): i32 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.tok.ident_len;
  }
}

/**
 * Peek the next token's start offset in the source bytes.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return usize — token_start
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_token_start_c(lex: *u8, source: *u8): usize {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.token_start;
  }
}

/**
 * Peek the next token's own line. This is tok.line, not the cursor line.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return i32 — tok.line
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_tok_line_c(lex: *u8, source: *u8): i32 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.tok.line;
  }
}

/**
 * Peek the next token's own column. This is tok.col, not the cursor column.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return i32 — tok.col
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_tok_col_c(lex: *u8, source: *u8): i32 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.tok.col;
  }
}

/**
 * Peek the cursor position after the next token. The caller's lexer is not written.
 * @param lex *u8 — opaque lexer; read-only; null returns 0
 * @param source *u8 — opaque slice; null returns 0
 * @return usize — next_lex.pos
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_next_pos_c(lex: *u8, source: *u8): usize {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    return r.next_lex.pos;
  }
}

/**
 * Forward the stretch type-start predicate. One authority, no second table.
 * @param kind i32 — token kind
 * @return i32 — 1 when the kind may start a type
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_is_type_start_kind_c(kind: i32): i32 {
  unsafe {
    return parser_asm_stretch_is_type_start_kind_c(kind);
  }
}

/**
 * In-place skip of a balanced bracket group. The caller already consumed '['.
 * @param lex_inout *u8 — opaque lexer; advanced past the matching ']'; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_balanced_brackets_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    parser_asm_stretch_skip_balanced_brackets_into_c(lex_inout, source);
  }
}

/**
 * In-place skip of a type suffix after a type start.
 * @param lex_inout *u8 — opaque lexer; advanced past the suffix; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_type_suffix_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    parser_asm_stretch_skip_type_suffix_c(lex_inout, source);
  }
}

/**
 * In-place skip of one parameter type, starting at the type token.
 * @param lex_inout *u8 — opaque lexer; advanced past the type; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_one_param_type_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    parser_asm_stretch_skip_one_param_type_c(lex_inout, source);
  }
}

/**
 * Peek the next token's ident bytes. Prefer tok.ident when it is set.
 * Otherwise return source data plus token_start. The lexer often leaves
 * tok.ident null while still filling token_start and ident_len.
 * @param lex *u8 — opaque lexer; read-only; null returns null
 * @param source *u8 — opaque slice; null returns null
 * @return *u8 — ident bytes, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_peek_ident_ptr_c(lex: *u8, source: *u8): *u8 {
  let raw: u8[72] = [];
  if (parser_asm_lex_bridge_fill(lex, source, &raw[0]) == 0) {
    return 0;
  }
  unsafe {
    let r: *ParserAsmLexResult = &raw[0] as *ParserAsmLexResult;
    if (r.tok.ident != 0) {
      return r.tok.ident;
    }
    let s: *ParserAsmLexSlice = source as *ParserAsmLexSlice;
    let data: *u8 = s.data;
    if (data == 0) {
      return 0;
    }
    return data + r.token_start;
  }
}

/**
 * Wrap a raw buffer as an opaque slice in a 16-deep ring. Null data or a
 * non-positive length returns null. The slot stays valid across nested wraps
 * until sixteen newer wraps reuse it.
 * @param data *u8 — source bytes; null returns null
 * @param len i32 — byte length; len <= 0 returns null
 * @return *u8 — opaque slice slot, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_wrap_buf_c(data: *u8, len: i32): *u8 {
  if (data == 0) {
    return 0;
  }
  if (len <= 0) {
    return 0;
  }
  let idx: i32 = g_lex_wrap_i[0];
  let slot: i32 = idx & 15;
  // Offset is i32. Pointer addition rejects a u64 offset.
  let off: i32 = slot * 16;
  unsafe {
    let base: *u8 = &g_lex_wrap_bytes[0];
    let p: *u8 = base + off;
    // Pointer slot is 8 bytes. memcpy, not a byte store.
    parser_asm_lex_bridge_store_ptr(p, data);
    let lp: *u8 = p + 8;
    parser_asm_lex_bridge_store_u64(lp, len as u64);
    g_lex_wrap_i[0] = (idx + 1) & 15;
    return p;
  }
}

/**
 * In-place skip of a balanced paren group. The caller already consumed '('.
 * The callee writes the out lexer. This wrapper does not store it again.
 * @param lex_inout *u8 — opaque lexer; advanced past the matching ')'; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_balanced_parens_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    let cur: ParserAsmLexLexer = *p;
    parser_asm_skip_balanced_parens_into_slice_c(p, cur, source);
  }
}

/**
 * In-place skip of a balanced brace group. The caller already consumed '{'.
 * The callee writes the out lexer.
 * @param lex_inout *u8 — opaque lexer; advanced past the matching '}'; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_balanced_braces_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    let cur: ParserAsmLexLexer = *p;
    parser_asm_skip_balanced_braces_into_slice_c(p, cur, source);
  }
}

/**
 * In-place skip of one top-level struct. The suite helper returns the next
 * lexer in both registers. The return is kept in a local and written back
 * field by field. A store of the whole struct through the pointer keeps
 * only pos.
 * @param lex_inout *u8 — opaque lexer; advanced past the struct; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_one_struct_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    let cur: ParserAsmLexLexer = *p;
    // Keep the 16-byte return in a local, then store each field.
    // Assigning the call through *p keeps only the low 8 bytes.
    let got: ParserAsmLexLexer = parser_asm_skip_one_struct_slice_c(cur, source);
    p.pos = got.pos;
    p.line = got.line;
    p.col = got.col;
  }
}

/**
 * In-place skip of leading const-import statements. Same return shape as
 * skip_one_struct: field stores write pos, line, and col.
 * @param lex_inout *u8 — opaque lexer; advanced to the first non-import; null returns
 * @param source *u8 — opaque slice; null returns
 * @return void
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_skip_imports_inplace_c(lex_inout: *u8, source: *u8): void {
  if (lex_inout == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  unsafe {
    let p: *ParserAsmLexLexer = lex_inout as *ParserAsmLexLexer;
    let cur: ParserAsmLexLexer = *p;
    // Same 16-byte return as skip_one_struct. Field stores keep line and col.
    let got: ParserAsmLexLexer = parser_asm_skip_imports_slice_c(cur, source);
    p.pos = got.pos;
    p.line = got.line;
    p.col = got.col;
  }
}

/**
 * Anchor so g05 can tell this pure-asm object from a host-cc seed.
 * @return i32 — always 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_lex_step_bridge_w1534_anchor(): i32 {
  return 0;
}
