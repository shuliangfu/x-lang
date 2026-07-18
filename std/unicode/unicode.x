// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// category、to_lower/to_upper、is_whitespace、is_ascii；
// See implementation.
// See implementation.
//
// See implementation.

export const U_CAT_LETTER: u8 = 1;
export const U_CAT_NUMBER: u8 = 2;
export const U_CAT_WHITESPACE: u8 = 3;

/* See implementation. */
export const ASCII_CATEGORY_TABLE: u8[128] = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
];

extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/** Exported function `unicode_f_unicode_v1_marker_c`.
 * Implements `unicode_f_unicode_v1_marker_c`.
 * @return i32
 */
export function unicode_f_unicode_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `unicode_f_unicode_v2_marker_c`.
 * Implements `unicode_f_unicode_v2_marker_c`.
 * @return i32
 */
export function unicode_f_unicode_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `unicode_ascii_cat_lookup`.
 * Implements `unicode_ascii_cat_lookup`.
 * @param rune u32
 * @return u8
 */
export function unicode_ascii_cat_lookup(rune: u32): u8 {
  if (rune >= 128 as u32) { return 0 as u8; }
  return ASCII_CATEGORY_TABLE[rune] as u8;
}

/** Exported function `unicode_is_alpha_ascii`.
 * Implements `unicode_is_alpha_ascii`.
 * @param rune u32
 * @return i32
 */
export function unicode_is_alpha_ascii(rune: u32): i32 {
  if ((rune >= 65 as u32 && rune <= 90 as u32)
    || (rune >= 97 as u32 && rune <= 122 as u32)) {
    return 1;
  }
  return 0;
}

/** Exported function `unicode_utf8_decode_at`.
 * Implements `unicode_utf8_decode_at`.
 * @param s *u8
 * @param len i32
 * @param off i32
 * @param out *u32
 * @return i32
 */
export function unicode_utf8_decode_at(s: *u8, len: i32, off: i32, out: *u32): i32 {
  let c0: u8 = 0;
  let rune: u32 = 0;
  if (s == 0 || off < 0 || off >= len || out == 0) { return 0; }
  c0 = s[off];
  if (c0 <= 0x7F) {
    out[0] = c0 as u32;
    return 1;
  }
  if ((c0 & 0xE0) == 0xC0 && off + 1 < len) {
    rune = ((c0 as u32 & 0x1F) << 6) | (s[(off + 1)] as u32 & 0x3F);
    out[0] = rune;
    return 2;
  }
  if ((c0 & 0xF0) == 0xE0 && off + 2 < len) {
    rune = ((c0 as u32 & 0x0F) << 12)
      | ((s[(off + 1)] as u32 & 0x3F) << 6)
      | (s[(off + 2)] as u32 & 0x3F);
    out[0] = rune;
    return 3;
  }
  if ((c0 & 0xF8) == 0xF0 && off + 3 < len) {
    rune = ((c0 as u32 & 0x07) << 18)
      | ((s[(off + 1)] as u32 & 0x3F) << 12)
      | ((s[(off + 2)] as u32 & 0x3F) << 6)
      | (s[(off + 3)] as u32 & 0x3F);
    out[0] = rune;
    return 4;
  }
  out[0] = c0 as u32;
  return 1;
}

/** Exported function `unicode_utf8_encode`.
 * Implements `unicode_utf8_encode`.
 * @param rune u32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function unicode_utf8_encode(rune: u32, out: *u8, cap: i32): i32 {
  if (out == 0 || cap <= 0) { return 0; }
  if (rune <= 0x7F) {
    out[0] = rune as u8;
    return 1;
  }
  if (rune <= 0x7FF && cap >= 2) {
    out[0] = (0xC0 | (rune >> 6)) as u8;
    out[1] = (0x80 | (rune & 0x3F)) as u8;
    return 2;
  }
  if (rune <= 0xFFFF && cap >= 3) {
    out[0] = (0xE0 | (rune >> 12)) as u8;
    out[1] = (0x80 | ((rune >> 6) & 0x3F)) as u8;
    out[2] = (0x80 | (rune & 0x3F)) as u8;
    return 3;
  }
  if (cap >= 4) {
    out[0] = (0xF0 | (rune >> 18)) as u8;
    out[1] = (0x80 | ((rune >> 12) & 0x3F)) as u8;
    out[2] = (0x80 | ((rune >> 6) & 0x3F)) as u8;
    out[3] = (0x80 | (rune & 0x3F)) as u8;
    return 4;
  }
  return 0;
}

/** Exported function `unicode_nfc_compose_acute`.
 * Implements `unicode_nfc_compose_acute`.
 * @param base u32
 * @return u32
 */
export function unicode_nfc_compose_acute(base: u32): u32 {
  if (base == 97 as u32) { return 0x00E1; }
  if (base == 65 as u32) { return 0x00C1; }
  if (base == 101 as u32) { return 0x00E9; }
  if (base == 69 as u32) { return 0x00C9; }
  if (base == 105 as u32) { return 0x00ED; }
  if (base == 73 as u32) { return 0x00CD; }
  if (base == 111 as u32) { return 0x00F3; }
  if (base == 79 as u32) { return 0x00D3; }
  if (base == 117 as u32) { return 0x00FA; }
  if (base == 85 as u32) { return 0x00DA; }
  if (base == 121 as u32) { return 0x00FD; }
  if (base == 89 as u32) { return 0x00DD; }
  return 0 as u32;
}

/** Exported function `unicode_is_combining_mark`.
 * Implements `unicode_is_combining_mark`.
 * @param rune u32
 * @return i32
 */
export function unicode_is_combining_mark(rune: u32): i32 {
  if (rune >= 0x0300 as u32 && rune <= 0x036F as u32) { return 1; }
  return 0;
}

/* See implementation. */
/** Exported function `category`.
 * Implements `category`.
 * @param rune u32
 * @return i32
 */
#[no_mangle]
export function category(rune: u32): i32 {
  return unicode_ascii_cat_lookup(rune) as i32;
}

/** Exported function `is_whitespace`.
 * Query helper `is_whitespace`.
 * @param rune u32
 * @return i32
 */
export function is_whitespace(rune: u32): i32 {
  if (unicode_ascii_cat_lookup(rune) == U_CAT_WHITESPACE) { return 1; }
  return 0;
}

/** Exported function `is_ascii`.
 * Query helper `is_ascii`.
 * @param rune u32
 * @return i32
 */
export function is_ascii(rune: u32): i32 {
  if (rune <= 127 as u32) { return 1; }
  return 0;
}

/* See implementation. */
/** Exported function `to_lower`.
 * Implements `to_lower`.
 * @param rune u32
 * @return u32
 */
#[no_mangle]
export function to_lower(rune: u32): u32 {
  if (rune >= 65 as u32 && rune <= 90 as u32) { return rune + 32; }
  return rune;
}

/* See implementation. */
/** Exported function `to_upper`.
 * Implements `to_upper`.
 * @param rune u32
 * @return u32
 */
#[no_mangle]
export function to_upper(rune: u32): u32 {
  if (rune >= 97 as u32 && rune <= 122 as u32) { return rune - 32; }
  return rune;
}

/** Exported function `is_supplementary`.
 * Query helper `is_supplementary`.
 * @param rune u32
 * @return i32
 */
export function is_supplementary(rune: u32): i32 {
  if (rune > 0xFFFF as u32) { return 1; }
  return 0;
}

/** Exported function `nfc_buf`.
 * Implements `nfc_buf`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function nfc_buf(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let in_off: i32 = 0;
  let out_off: i32 = 0;
  let rune: u32 = 0;
  let rune2: u32 = 0;
  let n: i32 = 0;
  let n2: i32 = 0;
  let next_off: i32 = 0;
  let composed: u32 = 0;
  let w: i32 = 0;
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) { return -1; }
  while (in_off < in_len) {
    n = unicode_utf8_decode_at(in, in_len, in_off, &rune);
    if (n <= 0) { return -1; }
    next_off = in_off + n;
    n2 = 0;
    rune2 = 0;
    if (next_off < in_len) {
      n2 = unicode_utf8_decode_at(in, in_len, next_off, &rune2);
    }
    /* See implementation. */
    if (n2 > 0 && rune2 == 0x0301 as u32 && rune <= 127 as u32
      && unicode_is_alpha_ascii(rune) != 0) {
      composed = unicode_nfc_compose_acute(rune);
      if (composed != 0) {
        w = unicode_utf8_encode(composed, &out[out_off], out_cap - out_off);
        if (w <= 0) { return -1; }
        out_off = out_off + w;
        in_off = next_off + n2;
        continue;
      }
    }
    if (out_off + n > out_cap) { return -1; }
    let k: i32 = 0;
    while (k < n) {
      out[out_off + k] = in[in_off + k];
      k = k + 1;
    }
    out_off = out_off + n;
    in_off = in_off + n;
  }
  return out_off;
}

/** Exported function `grapheme_next`.
 * Implements `grapheme_next`.
 * @param s *u8
 * @param len i32
 * @param off i32
 * @return i32
 */
export function grapheme_next(s: *u8, len: i32, off: i32): i32 {
  let rune: u32 = 0;
  let mark: u32 = 0;
  let n: i32 = 0;
  let mn: i32 = 0;
  let total: i32 = 0;
  let pos: i32 = 0;
  if (s == 0 || off < 0 || off >= len) { return 0; }
  n = unicode_utf8_decode_at(s, len, off, &rune);
  if (n <= 0) { return 0; }
  total = n;
  pos = off + n;
  while (pos < len) {
    mn = unicode_utf8_decode_at(s, len, pos, &mark);
    if (mn <= 0 || unicode_is_combining_mark(mark) == 0) { break; }
    total = total + mn;
    pos = pos + mn;
  }
  return total;
}

/** Exported function `case_fold_rune`.
 * Implements `case_fold_rune`.
 * @param rune u32
 * @return u32
 */
export function case_fold_rune(rune: u32): u32 {
  return to_lower(rune);
}

/** Exported function `case_fold_buf`.
 * Implements `case_fold_buf`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function case_fold_buf(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let in_off: i32 = 0;
  let out_off: i32 = 0;
  let rune: u32 = 0;
  let folded: u32 = 0;
  let n: i32 = 0;
  let w: i32 = 0;
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) { return -1; }
  while (in_off < in_len) {
    n = unicode_utf8_decode_at(in, in_len, in_off, &rune);
    if (n <= 0) { return -1; }
    folded = case_fold_rune(rune);
    w = unicode_utf8_encode(folded, &out[out_off], out_cap - out_off);
    if (w <= 0) { return -1; }
    out_off = out_off + w;
    in_off = in_off + n;
  }
  return out_off;
}

/** Exported function `grapheme_case_smoke`.
 * Implements `grapheme_case_smoke`.
 * @return i32
 */
export function grapheme_case_smoke(): i32 {
  let decomposed: u8[3] = [101, 0xCC, 0x81];
  let hello: u8[5] = [72, 101, 108, 108, 111];
  let fold: u8[8] = [];
  let n: i32 = 0;
  if (grapheme_next(&decomposed[0], 3, 0) != 3) { return 1; }
  if (grapheme_next(&hello[0], 5, 0) != 1) { return 2; }
  n = case_fold_buf(&hello[0], 5, &fold[0], 8);
  if (n != 5 || fold[0] != 104) { return 3; }
  return 0;
}
