// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// parser_asm_parse_expr_link_darwin.x — Darwin arm64 body of
// src/asm/parser_asm_parse_expr_link.o under SKIP_X.
//
// debug stays off. The snippet does not write. parse_expr_into copies
// the 16-byte lexer in two registers, forwards the source slice, and
// copies the 24-byte result back. The weak parse stubs stay out of this
// object. Linux and Windows build parser_asm_parse_expr_link.x (w1514).
// PLATFORM: MACOS|DARWIN arm64.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;
extern function parser_parse_expr_into(arena: *u8, lo: u64, hi: u64, source: *u8, out: *u8): void;

/**
 * Anchor for this Darwin parse-expr bridge.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function parser_asm_parse_expr_link_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Parser-asm debug gate. This leaf stays off.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function parser_asm_parse_expr_debug_enabled(): i32 {
  return 0;
}

/**
 * Retired debug snippet. Arguments stay in the C ABI and are not written.
 * @param source source slice, unused
 * @param pos lexer position, unused
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function parser_asm_parse_expr_debug_snippet_c(source: *u8, pos: u64): void {
  let keep_src: *u8 = source;
  let keep_pos: u64 = pos;
  if (keep_src == keep_src) {
    if (keep_pos == keep_pos) {
      return;
    }
  }
}

/**
 * Load an 8-byte pointer.
 * @param p address of the pointer slot
 * @return *u8 — the loaded pointer
 * PLATFORM: MACOS|DARWIN
 */
function pel_load_ptr(p: *u8): *u8 {
  let v: *u8 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 8);
  }
  return v;
}

/**
 * Load an 8-byte integer.
 * @param p address of the integer slot
 * @return u64 — the loaded value
 * PLATFORM: MACOS|DARWIN
 */
function pel_load_u64(p: *u8): u64 {
  let v: u64 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 8);
  }
  return v;
}

/**
 * Store an 8-byte pointer.
 * @param dst destination
 * @param v pointer value
 * PLATFORM: MACOS|DARWIN
 */
function pel_store_ptr(dst: *u8, v: *u8): void {
  unsafe {
    let src: *u8 = &v as *u8;
    memcpy(dst, src, 8);
  }
}

/**
 * Store an 8-byte integer.
 * @param dst destination
 * @param v integer value
 * PLATFORM: MACOS|DARWIN
 */
function pel_store_u64(dst: *u8, v: u64): void {
  unsafe {
    let src: *u8 = &v as *u8;
    memcpy(dst, src, 8);
  }
}

/**
 * Copy n bytes.
 * @param dst destination
 * @param src source
 * @param n byte count
 * PLATFORM: MACOS|DARWIN
 */
function pel_copy(dst: *u8, src: *u8, n: u64): void {
  unsafe {
    memcpy(dst, src, n);
  }
}

/**
 * One call into the parser. The lexer occupies the next two registers.
 * @param arena arena pointer
 * @param lo lexer position
 * @param hi line in the low half and column in the high half
 * @param source packed source slice
 * @param out result buffer
 * PLATFORM: MACOS|DARWIN
 */
function pel_call(arena: *u8, lo: u64, hi: u64, source: *u8, out: *u8): void {
  unsafe {
    parser_parse_expr_into(arena, lo, hi, source, out);
  }
}

/**
 * Forward a parser-asm expression parse.
 * A null source or result returns without writing.
 * @param arena arena pointer
 * @param lo lexer position
 * @param hi line in the low half and column in the high half
 * @param source pointer to data and length
 * @param out pointer to the 24-byte result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function parse_expr_into(arena: *u8, lo: u64, hi: u64, source: *u8, out: *u8): void {
  if (source == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  let data: *u8 = pel_load_ptr(source);
  let lenp: *u8 = source + 8;
  let len: u64 = pel_load_u64(lenp);
  let srcbuf: u8[16] = [];
  let srcp: *u8 = &srcbuf[0];
  pel_store_ptr(srcp, data);
  let lenat: *u8 = srcp + 8;
  pel_store_u64(lenat, len);
  let outbuf: u8[24] = [];
  let outp: *u8 = &outbuf[0];
  pel_call(arena, lo, hi, srcp, outp);
  pel_copy(out, outp, 24);
}
