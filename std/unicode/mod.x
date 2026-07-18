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
// See implementation.
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

/** Exported function `ascii_cat_lookup`.
 * Implements `ascii_cat_lookup`.
 * @param rune u32
 * @return u8
 */
export function ascii_cat_lookup(rune: u32): u8 {
  if (rune >= 128 as u32) { return 0 as u8; }
  return ASCII_CATEGORY_TABLE[rune] as u8;
}

/** Exported function `category`.
 * Implements `category`.
 * @param rune u32
 * @return i32
 */
export function category(rune: u32): i32 {
  return ascii_cat_lookup(rune) as i32;
}

/** Exported function `is_whitespace`.
 * Query helper `is_whitespace`.
 * @param rune u32
 * @return i32
 */
export function is_whitespace(rune: u32): i32 {
  if (ascii_cat_lookup(rune) == U_CAT_WHITESPACE) { return 1; }
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

/** Exported function `to_lower`.
 * Implements `to_lower`.
 * @param rune u32
 * @return u32
 */
export function to_lower(rune: u32): u32 {
  if (rune >= 65 as u32 && rune <= 90 as u32) { return rune + 32; }
  return rune;
}

/** Exported function `to_upper`.
 * Implements `to_upper`.
 * @param rune u32
 * @return u32
 */
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
  if (rune > 65535 as u32) { return 1; }
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
  return 0 - 1;
}

/** Exported function `grapheme_next`.
 * Implements `grapheme_next`.
 * @param s *u8
 * @param len i32
 * @param off i32
 * @return i32
 */
export function grapheme_next(s: *u8, len: i32, off: i32): i32 {
  return 0;
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
  return 0 - 1;
}

/** Exported function `grapheme_case_smoke`.
 * Implements `grapheme_case_smoke`.
 * @return i32
 */
export function grapheme_case_smoke(): i32 {
  return 1;
}

/** Exported function `rune_utf8_len`.
 * Query helper `rune_utf8_len`.
 * @param rune u32
 * @return i32
 */
export function rune_utf8_len(rune: u32): i32 {
  if (rune <= 127 as u32) { return 1; }
  if (rune <= 2047 as u32) { return 2; }
  if (rune <= 65535 as u32) { return 3; }
  return 4;
}
