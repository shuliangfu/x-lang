// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-423/424/425/426/427 + wave257: L2 hybrid thin — lsp_fmt pure leaves.
// PREFER_X_O: thin.o + seed-rest (-DXLANG_L2_LSP_FMT_THIN_FROM_X) ld -r -> lsp_diag.o
// (product path: src/lsp/lsp_diag.o from runtime_lsp_glue seed rest + this thin).
//
// Thin provides every symbol the seed stubs under XLANG_L2_LSP_FMT_THIN_FROM_X:
//   lsp_char_in_range / lsp_fmt_is_inline_ws / lsp_fmt_is_src_ws / lsp_store_i32
//   lsp_match_bytes_at
//   lsp_fmt_is_atom_tail / lsp_fmt_is_atom_head / lsp_fmt_unary_lhs
//   lsp_fmt_last_out / lsp_fmt_prev_src
//   lsp_fmt_src_ws_before / lsp_fmt_src_ws_after
//   lsp_fmt_space_before / lsp_fmt_space_after
//   lsp_json_escape_ident
//   col_in_ident_span / lsp_find_key_after / lsp_parse_bool_after
//   lsp_line_has_block_comment_end / lsp_line_is_block_comment
//   lsp_load_i32_at / lsp_load_ptr_at / func_name_covers
//   lsp_hash_source
// PLATFORM: SHARED — layout loads assume LE host (mac arm64 + Ubuntu x86_64).
// wave257: close soft residual "PREFER=1 hybrid thin missing 3 seed-stubbed symbols"
//          (func_name_covers / lsp_hash_source / lsp_line_is_block_comment).
// lsp_char_in_range: see function docblock below.

/** Exported function `lsp_char_in_range`.
 * Implements `lsp_char_in_range`.
 * @param c u8
 * @param lo u8
 * @param hi u8
 * @return i32
 */
export function lsp_char_in_range(c: u8, lo: u8, hi: u8): i32 {
  if (c < lo) { return 0; }
  if (c > hi) { return 0; }
  return 1;
}

/** Exported function `lsp_fmt_is_inline_ws`.
 * Implements `lsp_fmt_is_inline_ws`.
 * @param c u8
 * @return i32
 */
export function lsp_fmt_is_inline_ws(c: u8): i32 {
  if (c == 32) { return 1; }
  if (c == 9) { return 1; }
  return 0;
}

/** Exported function `lsp_fmt_is_src_ws`.
 * Implements `lsp_fmt_is_src_ws`.
 * @param c u8
 * @return i32
 */
export function lsp_fmt_is_src_ws(c: u8): i32 {
  if (lsp_fmt_is_inline_ws(c) != 0) { return 1; }
  if (c == 13) { return 1; }
  return 0;
}

/** Exported function `lsp_store_i32`.
 * Implements `lsp_store_i32`.
 * @param dst *i32
 * @param value i32
 * @return void
 */
export function lsp_store_i32(dst: *i32, value: i32): void {
  if (dst == 0) { return; }
  unsafe {
    dst[0] = value;
  }
}

/** Exported function `lsp_match_bytes_at`.
 * Implements `lsp_match_bytes_at`.
 * @param buf *u8
 * @param off i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 */
export function lsp_match_bytes_at(buf: *u8, off: i32, lit: *u8, lit_len: i32): i32 {
  let j: i32 = 0;
  while (j < lit_len) {
    if (buf[off + j] != lit[j]) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

/** Exported function `lsp_fmt_is_atom_tail`.
 * Implements `lsp_fmt_is_atom_tail`.
 * @param c u8
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_is_atom_tail(c: u8): i32 {
  if (lsp_char_in_range(c, 97 as u8, 122 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 65 as u8, 90 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 48 as u8, 57 as u8) != 0) { return 1; }
  if (c == 95) { return 1; }
  if (c == 41) { return 1; }
  if (c == 93) { return 1; }
  if (c == 125) { return 1; }
  return 0;
}

/** Exported function `lsp_fmt_is_atom_head`.
 * Implements `lsp_fmt_is_atom_head`.
 * @param c u8
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_is_atom_head(c: u8): i32 {
  if (lsp_char_in_range(c, 97 as u8, 122 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 65 as u8, 90 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 48 as u8, 57 as u8) != 0) { return 1; }
  if (c == 95) { return 1; }
  if (c == 40) { return 1; }
  if (c == 91) { return 1; }
  if (c == 123) { return 1; }
  return 0;
}

/** Exported function `lsp_fmt_unary_lhs`.
 * Implements `lsp_fmt_unary_lhs`.
 * @param prev u8
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_unary_lhs(prev: u8): i32 {
  if (prev == 0) { return 1; }
  if (prev == 40) { return 1; }
  if (prev == 91) { return 1; }
  if (prev == 123) { return 1; }
  if (prev == 44) { return 1; }
  if (prev == 58) { return 1; }
  if (prev == 59) { return 1; }
  if (prev == 61) { return 1; }
  if (prev == 43) { return 1; }
  if (prev == 45) { return 1; }
  if (prev == 42) { return 1; }
  if (prev == 47) { return 1; }
  if (prev == 37) { return 1; }
  if (prev == 38) { return 1; }
  if (prev == 124) { return 1; }
  if (prev == 94) { return 1; }
  if (prev == 33) { return 1; }
  if (prev == 126) { return 1; }
  if (prev == 60) { return 1; }
  if (prev == 62) { return 1; }
  return 0;
}

/** Exported function `lsp_fmt_last_out`.
 * Implements `lsp_fmt_last_out`.
 * @param out_buf *u8
 * @param out_len i32
 * @return u8
 */
#[no_mangle]
export function lsp_fmt_last_out(out_buf: *u8, out_len: i32): u8 {
  let k: i32 = out_len - 1;
  while (k >= 0) {
    let c: u8 = out_buf[k];
    if (lsp_fmt_is_inline_ws(c) == 0) { return c; }
    k = k - 1;
  }
  return 0 as u8;
}

/** Exported function `lsp_fmt_prev_src`.
 * Implements `lsp_fmt_prev_src`.
 * @param doc *u8
 * @param start i32
 * @param j i32
 * @return u8
 */
#[no_mangle]
export function lsp_fmt_prev_src(doc: *u8, start: i32, j: i32): u8 {
  let k: i32 = j - 1;
  while (k >= 0) {
    let c: u8 = doc[start + k];
    if (lsp_fmt_is_src_ws(c) == 0) { return c; }
    k = k - 1;
  }
  return 0 as u8;
}

/** Exported function `lsp_fmt_src_ws_before`.
 * Implements `lsp_fmt_src_ws_before`.
 * @param doc *u8
 * @param start i32
 * @param j i32
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_src_ws_before(doc: *u8, start: i32, j: i32): i32 {
  let k: i32 = j - 1;
  if (k < 0) { return 0; }
  let c: u8 = doc[start + k];
  return lsp_fmt_is_inline_ws(c);
}

/** Exported function `lsp_fmt_src_ws_after`.
 * Implements `lsp_fmt_src_ws_after`.
 * @param doc *u8
 * @param start i32
 * @param len i32
 * @param j i32
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_src_ws_after(doc: *u8, start: i32, len: i32, j: i32): i32 {
  let k: i32 = j + 1;
  if (k >= len) { return 0; }
  let c: u8 = doc[start + k];
  return lsp_fmt_is_inline_ws(c);
}

/** Exported function `lsp_fmt_space_before`.
 * Implements `lsp_fmt_space_before`.
 * @param doc *u8
 * @param start i32
 * @param j i32
 * @param out_buf *u8
 * @param out_len *i32
 * @param out_cap i32
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_space_before(doc: *u8, start: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
  if (out_buf == 0) { return 0; }
  if (out_len == 0) { return 0; }
  if (lsp_fmt_src_ws_before(doc, start, j) != 0) { return 0; }
  unsafe {
    let olen: i32 = out_len[0];
    let last: u8 = lsp_fmt_last_out(out_buf, olen);
    if (last == 0) { return 0; }
    if (lsp_fmt_is_inline_ws(last) != 0) { return 0; }
    if (olen >= out_cap - 1) { return 0; }
    out_buf[olen] = 32;
    out_len[0] = olen + 1;
    return 1;
  }
  return 0;
}

/** Exported function `lsp_fmt_space_after`.
 * Implements `lsp_fmt_space_after`.
 * @param doc *u8
 * @param start i32
 * @param len i32
 * @param j i32
 * @param out_buf *u8
 * @param out_len *i32
 * @param out_cap i32
 * @return i32
 */
#[no_mangle]
export function lsp_fmt_space_after(doc: *u8, start: i32, len: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
  if (out_buf == 0) { return 0; }
  if (out_len == 0) { return 0; }
  if (lsp_fmt_src_ws_after(doc, start, len, j) != 0) { return 0; }
  let k: i32 = j + 1;
  while (k < len) {
    let n: u8 = doc[start + k];
    if (lsp_fmt_is_src_ws(n) != 0) { k = k + 1; continue; }
    if (lsp_fmt_is_atom_head(n) != 0) {
      unsafe {
        let olen: i32 = out_len[0];
        if (olen < out_cap - 1) {
          out_buf[olen] = 32;
          out_len[0] = olen + 1;
          return 1;
        }
      }
    }
    return 0;
  }
  return 0;
}

/** Exported function `lsp_json_escape_ident`.
 * Implements `lsp_json_escape_ident`.
 * @param s *u8
 * @param esc *u8
 * @param esc_cap i32
 * @return i32
 */
#[no_mangle]
export function lsp_json_escape_ident(s: *u8, esc: *u8, esc_cap: i32): i32 {
  if (s == 0) { return 0; }
  if (esc == 0) { return 0; }
  if (esc_cap < 4) { return 0; }
  let e: i32 = 0;
  let i: i32 = 0;
  while (s[i] != 0) {
    if (e >= esc_cap - 3) { break; }
    let c: u8 = s[i];
    if (c == 34) {
      esc[e] = 92;
      e = e + 1;
      if (e >= esc_cap - 1) { break; }
      esc[e] = c;
      e = e + 1;
    } else if (c == 92) {
      esc[e] = 92;
      e = e + 1;
      if (e >= esc_cap - 1) { break; }
      esc[e] = c;
      e = e + 1;
    } else {
      esc[e] = c;
      e = e + 1;
    }
    i = i + 1;
  }
  esc[e] = 0;
  return e;
}

// See implementation.

// col_in_ident_span: see function docblock below.
/** Exported function `col_in_ident_span`.
 * Implements `col_in_ident_span`.
 * @param line i32
 * @param col i32
 * @param sl i32
 * @param sc i32
 * @param name *u8
 * @return i32
 */
#[no_mangle]
export function col_in_ident_span(line: i32, col: i32, sl: i32, sc: i32, name: *u8): i32 {
  if (name == 0) { return 0; }
  if (sl != line) { return 0; }
  if (sc <= 0) { return 0; }
  let len: i32 = 0;
  while (len < 512) {
    if (name[len] == 0) { break; }
    len = len + 1;
  }
  if (len <= 0) { return 0; }
  if (col < sc) { return 0; }
  if (col >= sc + len) { return 0; }
  return 1;
}

// lsp_find_key_after: see function docblock below.
/** Exported function `lsp_find_key_after`.
 * Implements `lsp_find_key_after`.
 * @param body *u8
 * @param len i32
 * @param start i32
 * @param key *u8
 * @return i32
 */
#[no_mangle]
export function lsp_find_key_after(body: *u8, len: i32, start: i32, key: *u8): i32 {
  if (body == 0) { return 0 - 1; }
  if (key == 0) { return 0 - 1; }
  if (len < 0) { return 0 - 1; }
  if (start < 0) { return 0 - 1; }
  let key_len: i32 = 0;
  while (key_len < 256) {
    if (key[key_len] == 0) { break; }
    key_len = key_len + 1;
  }
  if (key_len <= 0) { return 0 - 1; }
  let s: i32 = start;
  while (s + key_len <= len) {
    let is_match: i32 = 1;
    let j: i32 = 0;
    while (j < key_len) {
      if (body[s + j] != key[j]) {
        is_match = 0;
        break;
      }
      j = j + 1;
    }
    if (is_match != 0) {
      return s + key_len;
    }
    s = s + 1;
  }
  return 0 - 1;
}

// lsp_parse_bool_after: see function docblock below.
/** Exported function `lsp_parse_bool_after`.
 * Implements `lsp_parse_bool_after`.
 * @param body *u8
 * @param len i32
 * @param start i32
 * @param key *u8
 * @param out_val *i32
 * @return i32
 */
#[no_mangle]
export function lsp_parse_bool_after(body: *u8, len: i32, start: i32, key: *u8, out_val: *i32): i32 {
  if (out_val == 0) { return 0 - 1; }
  let k: i32 = lsp_find_key_after(body, len, start, key);
  if (k < 0) { return 0 - 1; }
  let lit_true: u8[5] = [116, 114, 117, 101, 0];
  let lit_false: u8[6] = [102, 97, 108, 115, 101, 0];
  if (k + 4 <= len) {
    if (lsp_match_bytes_at(body, k, &lit_true[0], 4) != 0) {
      lsp_store_i32(out_val, 1);
      return 0;
    }
  }
  if (k + 5 <= len) {
    if (lsp_match_bytes_at(body, k, &lit_false[0], 5) != 0) {
      lsp_store_i32(out_val, 0);
      return 0;
    }
  }
  return 0 - 1;
}

// lsp_line_has_block_comment_end: see function docblock below.
/** Exported function `lsp_line_has_block_comment_end`.
 * Implements `lsp_line_has_block_comment_end`.
 * @param doc *u8
 * @param start i32
 * @param len i32
 * @return i32
 */
#[no_mangle]
export function lsp_line_has_block_comment_end(doc: *u8, start: i32, len: i32): i32 {
  let i: i32 = 0;
  while (i + 1 < len) {
    if (doc[start + i] == 42) {
      if (doc[start + i + 1] == 47) { return 1; }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * True when the line content starts a C-style block comment open (slash-star)
 * or continues one (leading star while in_block is set).
 * Seed-stubbed under XLANG_L2_LSP_FMT_THIN_FROM_X — must live in this thin.
 * @param doc *u8 — document bytes; null → 0
 * @param content_start i32 — first content byte offset of the line
 * @param content_len i32 — content length in bytes
 * @param in_block i32 — non-zero if a prior open block comment is still open
 * @return i32 — 1 if block-comment line, else 0
 * PLATFORM: SHARED — pure byte checks; no host I/O
 */
#[no_mangle]
export function lsp_line_is_block_comment(doc: *u8, content_start: i32, content_len: i32, in_block: i32): i32 {
  if (doc == 0) { return 0; }
  if (content_len >= 2) {
    if (doc[content_start] == 47) { // '/'
      if (doc[content_start + 1] == 42) { return 1; } // '*'
    }
  }
  if (in_block != 0) {
    if (content_len >= 1) {
      if (doc[content_start] == 42) { return 1; }
    }
  }
  return 0;
}

/**
 * Load a little-endian i32 at byte offset from an opaque struct base.
 * Used by func_name_covers for ASTFunc.line / ASTFunc.col (line@0, col@4).
 * @param p *u8 — base pointer; caller guarantees valid span
 * @param off i32 — byte offset from base
 * @return i32 — LE 32-bit value
 * PLATFORM: SHARED — LE hosts only (product mac arm64 + Ubuntu x86_64)
 */
export function lsp_load_i32_at(p: *u8, off: i32): i32 {
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

/**
 * Load a little-endian pointer-width value at byte offset from an opaque struct base.
 * Used by func_name_covers for ASTFunc.name (name@+8 on 64-bit).
 * @param p *u8 — base pointer; null → null
 * @param off i32 — byte offset from base
 * @return *u8 — reconstructed pointer (or null)
 * PLATFORM: SHARED — LE 64-bit pointer pack (product mac arm64 + Ubuntu x86_64)
 */
export function lsp_load_ptr_at(p: *u8, off: i32): *u8 {
  if (p == 0) { return 0 as *u8; }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = p[off] as usize;
  a = a + (p[off + 1] as usize) * m;
  a = a + (p[off + 2] as usize) * m2;
  a = a + (p[off + 3] as usize) * (m2 * m);
  a = a + (p[off + 4] as usize) * m4;
  a = a + (p[off + 5] as usize) * (m4 * m);
  a = a + (p[off + 6] as usize) * (m4 * m2);
  a = a + (p[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

/**
 * True when the cursor (line,col) falls inside the function name span of ASTFunc f.
 * Layout (G-02f-133 / ast.h): line@0, col@4, name@+8. Seed-stubbed under THIN_FROM_X.
 * @param f *u8 — opaque ASTFunc*; null → 0
 * @param line i32 — 1-based cursor line
 * @param col i32 — 1-based cursor column
 * @return i32 — 1 if name span covers the cursor, else 0
 * PLATFORM: SHARED — layout contract with compiler/include/ast.h ASTFunc
 */
#[no_mangle]
export function func_name_covers(f: *u8, line: i32, col: i32): i32 {
  if (f == 0) { return 0; }
  let name: *u8 = lsp_load_ptr_at(f, 8);
  if (name == 0) { return 0; }
  let sl: i32 = lsp_load_i32_at(f, 0);
  let sc: i32 = lsp_load_i32_at(f, 4);
  return col_in_ident_span(line, col, sl, sc, name);
}

/**
 * Fast 32-bit source hash: 64-bit state + 8-byte LE block mix, fold to 32 bits.
 * Used by document cache invalidation; seed-stubbed under THIN_FROM_X.
 * Golden ratio constant 0x9e3779b97f4a7c15 is built from two u32 halves so typeck
 * never sees a decimal literal above i64 max (11400714819323198485).
 * @param src *u8 — source bytes; null → 0
 * @param len i32 — byte length (may be 0)
 * @return u32 — hash (h ^ (h >> 32)) of mix with golden ratio constant
 * PLATFORM: SHARED — LE pack of 8-byte blocks (matches seed memcpy path on LE hosts)
 */
#[no_mangle]
export function lsp_hash_source(src: *u8, len: i32): u32 {
  if (src == 0) { return 0; }
  // 0x9e3779b97f4a7c15 = (0x9e3779b9 << 32) | 0x7f4a7c15
  let golden_hi: u64 = 2654435769 as u64;
  let golden_lo: u64 = 2135587861 as u64;
  let two32: u64 = 4294967296 as u64;
  let golden: u64 = golden_hi * two32 + golden_lo;
  let h: u64 = len as u64;
  let i: i32 = 0;
  while (i + 8 <= len) {
    let x: u64 = 0 as u64;
    let k: i32 = 0;
    while (k < 8) {
      let b: u64 = src[i + k] as u64;
      // little-endian pack of the 8-byte window
      let shift: u64 = 1 as u64;
      let s: i32 = 0;
      while (s < k) { shift = shift * (256 as u64); s = s + 1; }
      x = x + b * shift;
      k = k + 1;
    }
    h = h * golden + x;
    i = i + 8;
  }
  while (i < len) {
    h = h * golden + (src[i] as u64);
    i = i + 1;
  }
  return (h ^ (h / two32)) as u32;
}

