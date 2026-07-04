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
// 【文件职责】category、to_lower/to_upper、is_whitespace、is_ascii；
// nfc_buf（v1 拉丁预组合）；grapheme_next、case_fold_*。
// 【依赖】core、std.encoding；算法在 std/unicode/unicode.x（F-unicode v2 纯 .x）。
extern function category(rune: u32): i32;
extern function is_whitespace(rune: u32): i32;
extern function is_ascii(rune: u32): i32;
extern function to_lower(rune: u32): u32;
extern function to_upper(rune: u32): u32;
extern function is_supplementary(rune: u32): i32;
extern function nfc_buf(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function grapheme_next(s: *u8, len: i32, off: i32): i32;
extern function case_fold_rune(rune: u32): u32;
extern function case_fold_buf(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function grapheme_case_smoke(): i32;

/** rune 编码为 UTF-8 所需的字节数（1..4）；非法高位 surrogate 区间按 3 处理。 */
function rune_utf8_len(rune: u32): i32 {
  if (rune <= 127 as u32) { return 1; }
  if (rune <= 2047 as u32) { return 2; }
  if (rune <= 65535 as u32) { return 3; }
  return 4;
}
