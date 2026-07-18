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

// std.encoding — UTF-8/ASCII 编解码与校验（对标 Zig/Rust，性能压榨）
//
// 【文件职责】UTF-8 单遍校验/码点计数/rune 编解码；ASCII
// 分类与大小写；hex 编解码与 std.string 门面（STD-040）。无堆分配，表驱动。
// 【依赖】core；std.base64；std.string；与 std/encoding/encoding.x 同属一模块（F-encoding v1）。

const base64_mod = import("std.base64");
const string_mod = import("std.string");

extern function encoding_utf8_valid_c(p: *u8, len: i32): i32;
extern function encoding_utf8_len_chars_c(p: *u8, len: i32): i32;
extern function encoding_utf8_encode_rune_c(r: u32, out: *u8): i32;
extern function encoding_utf8_decode_rune_c(p: *u8, len: i32, out_r: *u32): i32;
extern function encoding_ascii_is_alpha_c(c: u8): i32;
extern function encoding_ascii_is_digit_c(c: u8): i32;
extern function encoding_ascii_is_alnum_c(c: u8): i32;
extern function encoding_ascii_is_lower_c(c: u8): i32;
extern function encoding_ascii_is_upper_c(c: u8): i32;
extern function encoding_ascii_to_lower_c(c: u8): u8;
extern function encoding_ascii_to_upper_c(c: u8): u8;
extern function encoding_hex_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_hex_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_hex_encoded_len_c(src_len: i32): i32;
extern function encoding_base32_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_base32_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_percent_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_percent_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function encoding_extra_smoke_c(): i32;

/** UTF-8 校验 ptr[0..len)；合法返回 1，非法返回 0。单遍、表驱动。 */
export function utf8_valid(ptr: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_valid_c(ptr, len); }
  return _rc;
}

/** UTF-8 码点个数；非法序列返回 -1。 */
export function utf8_len_chars(ptr: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_len_chars_c(ptr, len); }
  return _rc;
}

/** 将码点 r 编码到 out，返回写入字节数 1..4，非法 r 返回 0。 */
export function utf8_encode_rune(r: u32, out: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_encode_rune_c(r, out); }
  return _rc;
}

/** 从 ptr 解码一个 rune 到 *out_r，返回消费字节数 1..4，非法返回 0。 */
export function utf8_decode_rune(ptr: *u8, len: i32, out_r: *u32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_decode_rune_c(ptr, len, out_r); }
  return _rc;
}

/** ASCII 字母判定。 */
export function ascii_is_alpha(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_alpha_c(c); }
  return _rc;
}

/** ASCII 数字判定。 */
export function ascii_is_digit(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_digit_c(c); }
  return _rc;
}

/** ASCII 字母或数字判定。 */
export function ascii_is_alnum(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_alnum_c(c); }
  return _rc;
}

/** ASCII 小写字母判定。 */
export function ascii_is_lower(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_lower_c(c); }
  return _rc;
}

/** ASCII 大写字母判定。 */
export function ascii_is_upper(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_upper_c(c); }
  return _rc;
}

/** ASCII 转小写。 */
export function ascii_to_lower(c: u8): u8 {
  let _rc: u8 = 0;
  unsafe { _rc = encoding_ascii_to_lower_c(c); }
  return _rc;
}

/** ASCII 转大写。 */
export function ascii_to_upper(c: u8): u8 {
  let _rc: u8 = 0;
  unsafe { _rc = encoding_ascii_to_upper_c(c); }
  return _rc;
}

/** 原始字节缓冲 hex 编码（小写）；返回写入字符数或 -1（STD-040）。 */
export function hex_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_hex_encode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** hex 解码；返回写入字节数，非法输入 -1。 */
export function hex_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_hex_decode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** hex 编码输出长度上界（src_len 为输入字节数）。 */
export function hex_encoded_len(src_len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_hex_encoded_len_c(src_len); }
  return _rc;
}

/** hex 解码输出字节数上界（hex_len 为 hex 字符数；奇数或负返回 -1）。 */
export function hex_decoded_len(hex_len: i32): i32 {
  if (hex_len < 0 || (hex_len & 1) != 0) {
    return -1;
  }
  return hex_len / 2;
}

/** 将原始字节 hex 编码写入 String（清空后写入）；成功 0，失败 -1（STD-040）。 */
export function encode_hex_string(src: *u8, src_len: i32, out: *String): i32 {
  let need: i32 = hex_encoded_len(src_len);
  let cap: i32 = string_mod.string_capacity();
  if (need < 0 || need > cap) {
    return -1;
  }
  string_mod.string_clear(out);
  let n: i32 = hex_encode(src, src_len, string_mod.string_data_ptr(out), cap);
  if (n < 0) {
    return -1;
  }
  unsafe {
    out.len = n;
  }
  return 0;
}

/** 从 StrView hex 解码到 out 缓冲；返回写入字节数，非法 -1（STD-040）。 */
export function decode_hex_string(hex: StrView, out: *u8, out_cap: i32): i32 {
  return hex_decode(hex.ptr, hex.len, out, out_cap);
}

/** 将原始字节标准 Base64 编码写入 String；成功 0，失败 -1（委托 std.base64）。 */
export function encode_base64_string(src: *u8, src_len: i32, out: *String): i32 {
  let cap: i32 = string_mod.string_capacity();
  if (src_len < 0) {
    return -1;
  }
  string_mod.string_clear(out);
  let n: i32 = base64_mod.encode_standard(src, src_len, string_mod.string_data_ptr(out), cap);
  if (n < 0) {
    return -1;
  }
  unsafe {
    out.len = n;
  }
  return 0;
}

/** 从 StrView 标准 Base64 解码；返回写入字节数，非法 -1（委托 std.base64）。 */
export function decode_base64_string(b64: StrView, out: *u8, out_cap: i32): i32 {
  return base64_mod.decode_standard(b64.ptr, b64.len, out, out_cap);
}

/* --- STD-127：Base32 / percent / URL-Base64 门面 --- */

/** RFC 4648 Base32 编码（含填充）；返回写入字符数，失败 -1。 */
export function base32_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_base32_encode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** RFC 4648 Base32 解码；返回写入字节数，非法 -1。 */
export function base32_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_base32_decode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** percent 编码（unreserved 保留）；返回写入长度，失败 -1。 */
export function percent_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_percent_encode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** percent 解码；返回写入字节数，非法 -1。 */
export function percent_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_percent_decode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** 将原始字节 Base32 编码写入 String；成功 0，失败 -1。 */
export function encode_base32_string(src: *u8, src_len: i32, out: *String): i32 {
  let cap: i32 = string_mod.string_capacity();
  if (src_len < 0) {
    return -1;
  }
  string_mod.string_clear(out);
  let n: i32 = base32_encode(src, src_len, string_mod.string_data_ptr(out), cap);
  if (n < 0) {
    return -1;
  }
  unsafe {
    out.len = n;
  }
  return 0;
}

/** 从 StrView Base32 解码；返回写入字节数，非法 -1。 */
export function decode_base32_string(b32: StrView, out: *u8, out_cap: i32): i32 {
  return base32_decode(b32.ptr, b32.len, out, out_cap);
}

/** 将原始字节 URL Base64 编码写入 String；成功 0，失败 -1。 */
export function encode_url_base64_string(src: *u8, src_len: i32, out: *String): i32 {
  let cap: i32 = string_mod.string_capacity();
  if (src_len < 0) {
    return -1;
  }
  string_mod.string_clear(out);
  let n: i32 = base64_mod.encode_url(src, src_len, string_mod.string_data_ptr(out), cap);
  if (n < 0) {
    return -1;
  }
  unsafe {
    out.len = n;
  }
  return 0;
}

/** 从 StrView URL Base64 解码；返回写入字节数，非法 -1。 */
export function decode_url_base64_string(b64: StrView, out: *u8, out_cap: i32): i32 {
  return base64_mod.decode_url(b64.ptr, b64.len, out, out_cap);
}

/** STD-127 C 烟测门面；成功 0。 */
export function extra_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_extra_smoke_c(); }
  return _rc;
}
