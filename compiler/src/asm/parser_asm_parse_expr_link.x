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

// parser_asm_parse_expr_link.x — G-02f-333 / Class AG, w1514 (终局待办 5.6)
// Whole body of src/asm/parser_asm_parse_expr_link.o on Linux and Windows.
// g05 builds it with the product's pure asm; the C seed rest is no longer
// compiled there. Darwin arm64 keeps parser_asm_parse_expr_link_darwin.x.
// debug stays off and the snippet does not write. parse_expr_into copies
// the source slice and the 24-byte result through local buffers. The
// 16-byte lexer comes in two registers on SysV and by address on Win64
// (the C seed's by-value struct), and goes on to parser_parse_expr_into
// the same way. The weak parse stubs stay out of this object.
// PLATFORM: LINUX x86_64 SysV and WINDOWS x64.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

#[cfg(target_os = "windows")]
extern function parser_parse_expr_into(arena: *u8, lexp: *u8, source: *u8, out: *u8): void;
#[cfg(not(target_os = "windows"))]
extern function parser_parse_expr_into(arena: *u8, lo: u64, hi: u64, source: *u8, out: *u8): void;

/** Doc anchor (keeps TU non-empty for cold tooling). */
export function parser_asm_parse_expr_link_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Whether XLANG_PARSER_ASM_DEBUG enables parser-asm parse_expr debug.
 * Class AG: always 0 — Cap link_abi_getenv face retired from this leaf.
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
#[no_mangle]
export function parser_asm_parse_expr_debug_enabled(): i32 {
  return 0;
}

/**
 * Retired debug snippet. Arguments stay in the C ABI and are not written.
 * @param source source slice, unused
 * @param pos lexer position, unused
 * PLATFORM: SHARED
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
 * PLATFORM: SHARED
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
 * PLATFORM: SHARED
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
 * PLATFORM: SHARED
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
 * PLATFORM: SHARED
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
 * PLATFORM: SHARED
 */
function pel_copy(dst: *u8, src: *u8, n: u64): void {
  unsafe {
    memcpy(dst, src, n);
  }
}

/**
 * Copy the source slice (data, length) into a 16-byte local buffer.
 * @param dst 16-byte buffer
 * @param source pointer to data and length
 * PLATFORM: SHARED
 */
function pel_copy_slice(dst: *u8, source: *u8): void {
  let data: *u8 = pel_load_ptr(source);
  let lenp: *u8 = source + 8;
  let len: u64 = pel_load_u64(lenp);
  pel_store_ptr(dst, data);
  let lenat: *u8 = dst + 8;
  pel_store_u64(lenat, len);
}

/**
 * Win64 forward. The C caller passes the 16-byte lexer by address; the
 * parser takes it the same way, so it goes on as the address of a copy.
 * A null lexer, source or result returns without writing.
 * @param arena arena pointer
 * @param lexp address of the lexer (position, line, column)
 * @param source pointer to data and length
 * @param out pointer to the 24-byte result
 * PLATFORM: WINDOWS x64
 */
#[cfg(target_os = "windows")]
#[no_mangle]
export function parse_expr_into(arena: *u8, lexp: *u8, source: *u8, out: *u8): void {
  if (lexp == 0) {
    return;
  }
  if (source == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  let lexbuf: u8[16] = [];
  let lp: *u8 = &lexbuf[0];
  pel_copy(lp, lexp, 16);
  let srcbuf: u8[16] = [];
  let srcp: *u8 = &srcbuf[0];
  pel_copy_slice(srcp, source);
  let outbuf: u8[24] = [];
  let outp: *u8 = &outbuf[0];
  unsafe {
    parser_parse_expr_into(arena, lp, srcp, outp);
  }
  pel_copy(out, outp, 24);
}

/**
 * SysV forward. The 16-byte lexer occupies two registers on both sides.
 * A null source or result returns without writing.
 * @param arena arena pointer
 * @param lo lexer position
 * @param hi line in the low half and column in the high half
 * @param source pointer to data and length
 * @param out pointer to the 24-byte result
 * PLATFORM: LINUX x86_64 SysV
 */
#[cfg(not(target_os = "windows"))]
#[no_mangle]
export function parse_expr_into(arena: *u8, lo: u64, hi: u64, source: *u8, out: *u8): void {
  if (source == 0) {
    return;
  }
  if (out == 0) {
    return;
  }
  let srcbuf: u8[16] = [];
  let srcp: *u8 = &srcbuf[0];
  pel_copy_slice(srcp, source);
  let outbuf: u8[24] = [];
  let outp: *u8 = &outbuf[0];
  unsafe {
    parser_parse_expr_into(arena, lo, hi, srcp, outp);
  }
  pel_copy(out, outp, 24);
}
