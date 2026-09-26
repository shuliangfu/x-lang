// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_lexer_glue_darwin.x — Darwin arm64 body of src/lexer/lexer.o.
//
// Lexer is 536 bytes: src at 0, end at 8, line at 16, col at 20,
// then a 512-byte string buffer the creator leaves untouched.
// end is source plus strlen(source). line and col start at 1.
// malloc failure returns null. lexer_free is free.
// Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64.

extern function malloc(n: u64): *u8;
extern function free(p: *u8): void;
extern function strlen(s: *u8): u64;
extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/**
 * Anchor for this Darwin lexer object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lexer_glue_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Address of a field inside the lexer block.
 * @param p block address
 * @param off byte offset
 * @return *u8 — field address
 * PLATFORM: MACOS|DARWIN
 */
function lex_at(p: *u8, off: i32): *u8 {
  return p + off;
}

/**
 * Store a pointer into the lexer block.
 * @param p destination
 * @param v pointer value
 * PLATFORM: MACOS|DARWIN
 */
function lex_store_ptr(p: *u8, v: *u8): void {
  let x: *u8 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 8);
  }
}

/**
 * Store an i32 into the lexer block.
 * @param p destination
 * @param v value
 * PLATFORM: MACOS|DARWIN
 */
function lex_store_i32(p: *u8, v: i32): void {
  let x: i32 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 4);
  }
}

/**
 * Allocate a lexer over source. The block is 536 bytes.
 * @param source NUL-terminated source, not null
 * @return *u8 — the lexer, or null when malloc fails
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lexer_new(source: *u8): *u8 {
  let bytes: u64 = 536;
  let l: *u8 = 0;
  unsafe {
    l = malloc(bytes);
  }
  if (l == 0) {
    return 0;
  }
  lex_store_ptr(l, source);
  let n: u64 = 0;
  unsafe {
    n = strlen(source);
  }
  let end: *u8 = source + (n as i32);
  let p8: *u8 = lex_at(l, 8);
  lex_store_ptr(p8, end);
  let p16: *u8 = lex_at(l, 16);
  lex_store_i32(p16, 1);
  let p20: *u8 = lex_at(l, 20);
  lex_store_i32(p20, 1);
  return l;
}

/**
 * Release a lexer. A null pointer is a no-op, same as free.
 * @param l lexer from lexer_new, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function lexer_free(l: *u8): void {
  unsafe {
    free(l);
  }
}
