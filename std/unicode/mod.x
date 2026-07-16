// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// std.unicode — Unicode 分类、大小写、NFC、字素簇（对标 Zig std.unicode、Rust char）
//
// 【文件职责】对外 API 前缀 std_unicode_*；ASCII 分类/大小写在此实现。
// NFC/grapheme 等扩展算法在 unicode.x，由预编 unicode.o 或后续 import 接入。
// 【产品轨】勿 link_only 仅链 unicode.o：.o 符号为 std_unicode_unicode_*，与 API 名不一致。
//   本文件 co-emit 提供 std_unicode_category 等权威符号。

export const U_CAT_LETTER: u8 = 1;
export const U_CAT_NUMBER: u8 = 2;
export const U_CAT_WHITESPACE: u8 = 3;

/** ASCII 分类表：0 未知，1 Letter，2 Number，3 Whitespace。 */
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

/** 查 ASCII 分类表；越界返回 0。 */
export function ascii_cat_lookup(rune: u32): u8 {
  if (rune >= 128 as u32) { return 0 as u8; }
  return ASCII_CATEGORY_TABLE[rune] as u8;
}

/** Unicode 分类（简化）：0 未知，1 Letter，2 Number，3 Whitespace。 */
export function category(rune: u32): i32 {
  return ascii_cat_lookup(rune) as i32;
}

/** 是否为空白（\t \n \v \f \r 空格）。 */
export function is_whitespace(rune: u32): i32 {
  if (ascii_cat_lookup(rune) == U_CAT_WHITESPACE) { return 1; }
  return 0;
}

/** 是否为 ASCII（rune <= 127）。 */
export function is_ascii(rune: u32): i32 {
  if (rune <= 127 as u32) { return 1; }
  return 0;
}

/** rune 转小写；非 ASCII 暂返回原 rune。 */
export function to_lower(rune: u32): u32 {
  if (rune >= 65 as u32 && rune <= 90 as u32) { return rune + 32; }
  return rune;
}

/** rune 转大写；非 ASCII 暂返回原 rune。 */
export function to_upper(rune: u32): u32 {
  if (rune >= 97 as u32 && rune <= 122 as u32) { return rune - 32; }
  return rune;
}

/** 是否为 Unicode 增补平面码点（U+10000 及以上）。 */
export function is_supplementary(rune: u32): i32 {
  if (rune > 65535 as u32) { return 1; }
  return 0;
}

/** 缓冲 NFC（v1 占位；完整实现见 unicode.x / unicode.o）。 */
export function nfc_buf(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return 0 - 1;
}

/** 下一字素簇字节数（v1 占位）。 */
export function grapheme_next(s: *u8, len: i32, off: i32): i32 {
  return 0;
}

/** case fold 单码点（v1 委托 to_lower）。 */
export function case_fold_rune(rune: u32): u32 {
  return to_lower(rune);
}

/** case fold 缓冲（v1 占位）。 */
export function case_fold_buf(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return 0 - 1;
}

/** C 烟测入口（STD-114）。 */
export function grapheme_case_smoke(): i32 {
  return 1;
}

/** rune 编码为 UTF-8 所需的字节数（1..4）；非法高位 surrogate 区间按 3 处理。 */
export function rune_utf8_len(rune: u32): i32 {
  if (rune <= 127 as u32) { return 1; }
  if (rune <= 2047 as u32) { return 2; }
  if (rune <= 65535 as u32) { return 3; }
  return 4;
}
