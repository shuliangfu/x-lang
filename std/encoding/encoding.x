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
// See implementation.

/* See implementation. */
export const UTF8_CONT_MASK: u8 = 0xC0;
export const UTF8_CONT_VAL: u8 = 0x80;

/* See implementation. */
export const HEX_LOWER: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102];
/* See implementation. */
export const HEX_UPPER: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
/* See implementation. */
export const B32_ALPHABET: u8[32] = [
  65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
  81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 50, 51, 52, 53, 54, 55
];

/** Exported function `utf8_first_byte_len`.
 * Query helper `utf8_first_byte_len`.
 * @param b u8
 * @return u32
 */
export function utf8_first_byte_len(b: u8): u32 {
  if (b <= 127) { return 1; }
  if (b >= 128 && b <= 191) { return 255; }
  if (b >= 192 && b <= 223) { return 2; }
  if (b >= 224 && b <= 239) { return 3; }
  if (b >= 240 && b <= 247) { return 4; }
  return 255;
}

/** Exported function `encoding_utf8_valid_c`.
 * Implements `encoding_utf8_valid_c`.
 * @param p *u8
 * @param len i32
 * @return i32
 */
export function encoding_utf8_valid_c(p: *u8, len: i32): i32 {
  let pi: i32 = 0;
  let b: u8 = 0;
  let n: u32 = 0;
  let j: i32 = 0;
  if (p == 0 || len < 0) { return 0; }
  while (pi < len) {
    b = p[pi];
    n = utf8_first_byte_len(b);
    if (n == 255) { return 0; }
    if (n > 1) {
      if (pi + (n as i32) > len) { return 0; }
      j = 1;
      while (j < (n as i32)) {
        if ((p[pi + j] & UTF8_CONT_MASK) != UTF8_CONT_VAL) { return 0; }
        j = j + 1;
      }
      if (n == 2 && b < 194) { return 0; }
      if (n == 3 && b == 224 && p[pi + 1] < 160) { return 0; }
      if (n == 3 && b == 237 && p[pi + 1] > 159) { return 0; }
      if (n == 4 && b == 240 && p[pi + 1] < 144) { return 0; }
      if (n == 4 && b == 244 && p[pi + 1] > 143) { return 0; }
      pi = pi + (n as i32);
    } else {
      pi = pi + 1;
    }
  }
  return 1;
}

/** Exported function `encoding_utf8_len_chars_c`.
 * Implements `encoding_utf8_len_chars_c`.
 * @param p *u8
 * @param len i32
 * @return i32
 */
export function encoding_utf8_len_chars_c(p: *u8, len: i32): i32 {
  let count: i32 = 0;
  let pi: i32 = 0;
  let n: u32 = 0;
  if (p == 0 || len <= 0) { return 0; }
  while (pi < len) {
    n = utf8_first_byte_len(p[pi]);
    if (n == 255) { return -1; }
    if ((n as i32) > len - pi) { return -1; }
    pi = pi + (n as i32);
    count = count + 1;
  }
  return count;
}

/** Exported function `encoding_utf8_encode_rune_c`.
 * Implements `encoding_utf8_encode_rune_c`.
 * @param r u32
 * @param out *u8
 * @return i32
 */
export function encoding_utf8_encode_rune_c(r: u32, out: *u8): i32 {
  if (out == 0) { return 0; }
  if (r <= 0x7F) {
    out[0] = r as u8;
    return 1;
  }
  if (r <= 0x7FF) {
    if (r < 0x80) { return 0; }
    out[0] = (0xC0 | (r >> 6)) as u8;
    out[1] = (0x80 | (r & 0x3F)) as u8;
    return 2;
  }
  if (r <= 0xFFFF) {
    if (r < 0x800 || (r >= 0xD800 && r <= 0xDFFF)) { return 0; }
    out[0] = (0xE0 | (r >> 12)) as u8;
    out[1] = (0x80 | ((r >> 6) & 0x3F)) as u8;
    out[2] = (0x80 | (r & 0x3F)) as u8;
    return 3;
  }
  if (r <= 0x10FFFF) {
    out[0] = (0xF0 | (r >> 18)) as u8;
    out[1] = (0x80 | ((r >> 12) & 0x3F)) as u8;
    out[2] = (0x80 | ((r >> 6) & 0x3F)) as u8;
    out[3] = (0x80 | (r & 0x3F)) as u8;
    return 4;
  }
  return 0;
}

/** Exported function `encoding_utf8_decode_rune_c`.
 * Implements `encoding_utf8_decode_rune_c`.
 * @param p *u8
 * @param len i32
 * @param out_r *u32
 * @return i32
 */
export function encoding_utf8_decode_rune_c(p: *u8, len: i32, out_r: *u32): i32 {
  let b: u8 = 0;
  let n: u32 = 0;
  let r: u32 = 0;
  let i: u32 = 0;
  if (p == 0 || len <= 0 || out_r == 0) { return 0; }
  b = p[0];
  n = utf8_first_byte_len(b);
  if (n == 255 || (n as i32) > len) { return 0; }
  if (n == 1) {
    out_r[0] = b as u32;
    return 1;
  }
  r = (b as u32) & (0xFF >> (n + 1));
  i = 1;
  while (i < n) {
    if ((p[i] & UTF8_CONT_MASK) != UTF8_CONT_VAL) { return 0; }
    r = (r << 6) | ((p[i] as u32) & 0x3F);
    i = i + 1;
  }
  if (n == 2 && r < 0x80) { return 0; }
  if (n == 3 && (r < 0x800 || (r >= 0xD800 && r <= 0xDFFF))) { return 0; }
  if (n == 4 && (r < 0x10000 || r > 0x10FFFF)) { return 0; }
  out_r[0] = r;
  return n as i32;
}

/** Exported function `encoding_ascii_is_alpha_c`.
 * Implements `encoding_ascii_is_alpha_c`.
 * @param c u8
 * @return i32
 */
export function encoding_ascii_is_alpha_c(c: u8): i32 {
  if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) { return 1; }
  return 0;
}

/** Exported function `encoding_ascii_is_digit_c`.
 * Implements `encoding_ascii_is_digit_c`.
 * @param c u8
 * @return i32
 */
export function encoding_ascii_is_digit_c(c: u8): i32 {
  if (c >= 48 && c <= 57) { return 1; }
  return 0;
}

/** Exported function `encoding_ascii_is_alnum_c`.
 * Implements `encoding_ascii_is_alnum_c`.
 * @param c u8
 * @return i32
 */
export function encoding_ascii_is_alnum_c(c: u8): i32 {
  if (encoding_ascii_is_alpha_c(c) != 0 || encoding_ascii_is_digit_c(c) != 0) { return 1; }
  return 0;
}

/** Exported function `encoding_ascii_is_lower_c`.
 * Implements `encoding_ascii_is_lower_c`.
 * @param c u8
 * @return i32
 */
export function encoding_ascii_is_lower_c(c: u8): i32 {
  if (c >= 97 && c <= 122) { return 1; }
  return 0;
}

/** Exported function `encoding_ascii_is_upper_c`.
 * Implements `encoding_ascii_is_upper_c`.
 * @param c u8
 * @return i32
 */
export function encoding_ascii_is_upper_c(c: u8): i32 {
  if (c >= 65 && c <= 90) { return 1; }
  return 0;
}

/** Exported function `encoding_ascii_to_lower_c`.
 * Implements `encoding_ascii_to_lower_c`.
 * @param c u8
 * @return u8
 */
export function encoding_ascii_to_lower_c(c: u8): u8 {
  if (c >= 65 && c <= 90) { return (c + 32) as u8; }
  return c;
}

/** Exported function `encoding_ascii_to_upper_c`.
 * Implements `encoding_ascii_to_upper_c`.
 * @param c u8
 * @return u8
 */
export function encoding_ascii_to_upper_c(c: u8): u8 {
  if (c >= 97 && c <= 122) { return (c - 32) as u8; }
  return c;
}

/** Exported function `xlang_hex_nibble`.
 * Implements `xlang_hex_nibble`.
 * @param c u8
 * @return i32
 */
export function xlang_hex_nibble(c: u8): i32 {
  if (c >= 48 && c <= 57) { return (c - 48) as i32; }
  if (c >= 97 && c <= 102) { return (c - 97 + 10) as i32; }
  if (c >= 65 && c <= 70) { return (c - 65 + 10) as i32; }
  return -1;
}

/** Exported function `encoding_hex_encode_c`.
 * Implements `encoding_hex_encode_c`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoding_hex_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  if (src == 0 || out == 0 || src_len < 0) { return -1; }
  if (out_cap < src_len * 2) { return -1; }
  while (i < src_len) {
    out[i * 2] = HEX_LOWER[((src[i] >> 4) & 15) as usize];
    out[i * 2 + 1] = HEX_LOWER[(src[i] & 15)];
    i = i + 1;
  }
  return src_len * 2;
}

/** Exported function `encoding_hex_encoded_len_c`.
 * Implements `encoding_hex_encoded_len_c`.
 * @param src_len i32
 * @return i32
 */
export function encoding_hex_encoded_len_c(src_len: i32): i32 {
  if (src_len < 0) { return -1; }
  return src_len * 2;
}

/** Exported function `encoding_hex_decode_c`.
 * Implements `encoding_hex_decode_c`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoding_hex_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let out_len: i32 = 0;
  let i: i32 = 0;
  let hi: i32 = 0;
  let lo: i32 = 0;
  if (src == 0 || out == 0 || src_len < 0 || (src_len & 1) != 0) { return -1; }
  out_len = src_len / 2;
  if (out_cap < out_len) { return -1; }
  while (i < out_len) {
    hi = xlang_hex_nibble(src[i * 2]);
    lo = xlang_hex_nibble(src[i * 2 + 1]);
    if (hi < 0 || lo < 0) { return -1; }
    out[i] = ((hi << 4) | lo) as u8;
    i = i + 1;
  }
  return out_len;
}

/** Exported function `xlang_b32_value`.
 * Implements `xlang_b32_value`.
 * @param c u8
 * @return i32
 */
export function xlang_b32_value(c: u8): i32 {
  if (c >= 65 && c <= 90) { return (c - 65) as i32; }
  if (c >= 50 && c <= 55) { return (c - 50 + 26) as i32; }
  if (c >= 97 && c <= 122) { return (c - 97) as i32; }
  return -1;
}

/** Exported function `encoding_base32_encode_c`.
 * Implements `encoding_base32_encode_c`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoding_base32_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let o: i32 = 0;
  let idx: i32 = 0;
  let buffer: i32 = 0;
  let bits: i32 = 0;
  let val: i32 = 0;
  if (src == 0 || out == 0 || src_len < 0) { return -1; }
  if (out_cap < ((src_len + 4) / 5) * 8) { return -1; }
  while (idx < src_len || bits > 0) {
    if (bits < 5) {
      if (idx < src_len) {
        buffer = (buffer << 8) | (src[idx] as i32);
        idx = idx + 1;
        bits = bits + 8;
      } else if (bits > 0) {
        buffer = buffer << (5 - bits);
        bits = 5;
      } else {
        break;
      }
    }
    if (bits >= 5) {
      val = (buffer >> (bits - 5)) & 0x1F;
      bits = bits - 5;
      out[o] = B32_ALPHABET[val];
      o = o + 1;
    }
  }
  while ((o % 8) != 0) {
    out[o] = 61;
    o = o + 1;
  }
  return o;
}

/** Exported function `encoding_base32_decode_c`.
 * Implements `encoding_base32_decode_c`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoding_base32_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  let buffer: i32 = 0;
  let bits: i32 = 0;
  let c: u8 = 0;
  let v: i32 = 0;
  if (src == 0 || out == 0 || src_len < 0) { return -1; }
  while (i < src_len) {
    c = src[i];
    if (c == 61) { break; }
    v = xlang_b32_value(c);
    if (v < 0) { return -1; }
    buffer = (buffer << 5) | v;
    bits = bits + 5;
    if (bits >= 8) {
      bits = bits - 8;
      if (o >= out_cap) { return -1; }
      out[o] = ((buffer >> bits) & 0xFF) as u8;
      o = o + 1;
    }
    i = i + 1;
  }
  return o;
}

/** Exported function `xlang_percent_unreserved`.
 * Implements `xlang_percent_unreserved`.
 * @param c u8
 * @return i32
 */
export function xlang_percent_unreserved(c: u8): i32 {
  if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || (c >= 48 && c <= 57)) { return 1; }
  if (c == 45 || c == 46 || c == 95 || c == 126) { return 1; }
  return 0;
}

/** Exported function `encoding_percent_encode_c`.
 * Implements `encoding_percent_encode_c`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoding_percent_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  let c: u8 = 0;
  if (src == 0 || out == 0 || src_len < 0) { return -1; }
  while (i < src_len) {
    c = src[i];
    if (xlang_percent_unreserved(c) != 0) {
      if (o + 1 > out_cap) { return -1; }
      out[o] = c;
      o = o + 1;
    } else {
      if (o + 3 > out_cap) { return -1; }
      out[o] = 37;
      out[o + 1] = HEX_UPPER[((c >> 4) & 15)];
      out[o + 2] = HEX_UPPER[(c & 15)];
      o = o + 3;
    }
    i = i + 1;
  }
  return o;
}

/** Exported function `encoding_percent_decode_c`.
 * Implements `encoding_percent_decode_c`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoding_percent_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  let o: i32 = 0;
  let c: u8 = 0;
  let hi: i32 = 0;
  let lo: i32 = 0;
  if (src == 0 || out == 0 || src_len < 0) { return -1; }
  while (i < src_len) {
    c = src[i];
    if (c == 37) {
      if (i + 2 >= src_len) { return -1; }
      hi = xlang_hex_nibble(src[i + 1]);
      lo = xlang_hex_nibble(src[i + 2]);
      if (hi < 0 || lo < 0) { return -1; }
      if (o >= out_cap) { return -1; }
      out[o] = ((hi << 4) | lo) as u8;
      o = o + 1;
      i = i + 3;
    } else {
      if (o >= out_cap) { return -1; }
      out[o] = c;
      o = o + 1;
      i = i + 1;
    }
  }
  return o;
}

/** Exported function `encoding_extra_smoke_c`.
 * Implements `encoding_extra_smoke_c`.
 * @return i32
 */
export function encoding_extra_smoke_c(): i32 {
  let foo: u8[3] = [102, 111, 111];
  let b32: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let dec: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let plain: u8[3] = [97, 32, 98];
  let pct: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let back: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = 0;
  let m: i32 = 0;
  let pn: i32 = 0;
  let pd: i32 = 0;
  n = encoding_base32_encode_c(&foo[0], 3, &b32[0], 16);
  if (n != 8 || b32[0] != 77 || b32[1] != 90 || b32[2] != 88 || b32[3] != 87 || b32[4] != 54) { return 1; }
  m = encoding_base32_decode_c(&b32[0], n, &dec[0], 8);
  if (m != 3 || dec[0] != 102 || dec[1] != 111 || dec[2] != 111) { return 2; }
  pn = encoding_percent_encode_c(&plain[0], 3, &pct[0], 16);
  if (pn != 5) { return 3; }
  pd = encoding_percent_decode_c(&pct[0], pn, &back[0], 8);
  if (pd != 3 || back[0] != 97 || back[1] != 32 || back[2] != 98) { return 4; }
  return 0;
}
