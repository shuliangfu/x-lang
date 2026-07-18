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

/** Exported function `utf8_valid`.
 * Implements `utf8_valid`.
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function utf8_valid(ptr: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_valid_c(ptr, len); }
  return _rc;
}

/** Exported function `utf8_len_chars`.
 * Implements `utf8_len_chars`.
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function utf8_len_chars(ptr: *u8, len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_len_chars_c(ptr, len); }
  return _rc;
}

/** Exported function `utf8_encode_rune`.
 * Implements `utf8_encode_rune`.
 * @param r u32
 * @param out *u8
 * @return i32
 */
export function utf8_encode_rune(r: u32, out: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_encode_rune_c(r, out); }
  return _rc;
}

/** Exported function `utf8_decode_rune`.
 * Implements `utf8_decode_rune`.
 * @param ptr *u8
 * @param len i32
 * @param out_r *u32
 * @return i32
 */
export function utf8_decode_rune(ptr: *u8, len: i32, out_r: *u32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_utf8_decode_rune_c(ptr, len, out_r); }
  return _rc;
}

/** Exported function `ascii_is_alpha`.
 * Implements `ascii_is_alpha`.
 * @param c u8
 * @return i32
 */
export function ascii_is_alpha(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_alpha_c(c); }
  return _rc;
}

/** Exported function `ascii_is_digit`.
 * Implements `ascii_is_digit`.
 * @param c u8
 * @return i32
 */
export function ascii_is_digit(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_digit_c(c); }
  return _rc;
}

/** Exported function `ascii_is_alnum`.
 * Implements `ascii_is_alnum`.
 * @param c u8
 * @return i32
 */
export function ascii_is_alnum(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_alnum_c(c); }
  return _rc;
}

/** Exported function `ascii_is_lower`.
 * Implements `ascii_is_lower`.
 * @param c u8
 * @return i32
 */
export function ascii_is_lower(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_lower_c(c); }
  return _rc;
}

/** Exported function `ascii_is_upper`.
 * Implements `ascii_is_upper`.
 * @param c u8
 * @return i32
 */
export function ascii_is_upper(c: u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_ascii_is_upper_c(c); }
  return _rc;
}

/** Exported function `ascii_to_lower`.
 * Implements `ascii_to_lower`.
 * @param c u8
 * @return u8
 */
export function ascii_to_lower(c: u8): u8 {
  let _rc: u8 = 0;
  unsafe { _rc = encoding_ascii_to_lower_c(c); }
  return _rc;
}

/** Exported function `ascii_to_upper`.
 * Implements `ascii_to_upper`.
 * @param c u8
 * @return u8
 */
export function ascii_to_upper(c: u8): u8 {
  let _rc: u8 = 0;
  unsafe { _rc = encoding_ascii_to_upper_c(c); }
  return _rc;
}

/** Exported function `hex_encode`.
 * Implements `hex_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hex_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_hex_encode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `hex_decode`.
 * Implements `hex_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function hex_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_hex_decode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `hex_encoded_len`.
 * Query helper `hex_encoded_len`.
 * @param src_len i32
 * @return i32
 */
export function hex_encoded_len(src_len: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_hex_encoded_len_c(src_len); }
  return _rc;
}

/** Exported function `hex_decoded_len`.
 * Query helper `hex_decoded_len`.
 * @param hex_len i32
 * @return i32
 */
export function hex_decoded_len(hex_len: i32): i32 {
  if (hex_len < 0 || (hex_len & 1) != 0) {
    return -1;
  }
  return hex_len / 2;
}

/** Exported function `encode_hex_string`.
 * Implements `encode_hex_string`.
 * @param src *u8
 * @param src_len i32
 * @param out *String
 * @return i32
 */
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

/** Exported function `decode_hex_string`.
 * Implements `decode_hex_string`.
 * @param hex StrView
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_hex_string(hex: StrView, out: *u8, out_cap: i32): i32 {
  return hex_decode(hex.ptr, hex.len, out, out_cap);
}

/** Exported function `encode_base64_string`.
 * Implements `encode_base64_string`.
 * @param src *u8
 * @param src_len i32
 * @param out *String
 * @return i32
 */
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

/** Exported function `decode_base64_string`.
 * Implements `decode_base64_string`.
 * @param b64 StrView
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_base64_string(b64: StrView, out: *u8, out_cap: i32): i32 {
  return base64_mod.decode_standard(b64.ptr, b64.len, out, out_cap);
}

/* See implementation. */

/** Exported function `base32_encode`.
 * Implements `base32_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function base32_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_base32_encode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `base32_decode`.
 * Implements `base32_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function base32_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_base32_decode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `percent_encode`.
 * Implements `percent_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function percent_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_percent_encode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `percent_decode`.
 * Implements `percent_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function percent_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_percent_decode_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `encode_base32_string`.
 * Implements `encode_base32_string`.
 * @param src *u8
 * @param src_len i32
 * @param out *String
 * @return i32
 */
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

/** Exported function `decode_base32_string`.
 * Implements `decode_base32_string`.
 * @param b32 StrView
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_base32_string(b32: StrView, out: *u8, out_cap: i32): i32 {
  return base32_decode(b32.ptr, b32.len, out, out_cap);
}

/** Exported function `encode_url_base64_string`.
 * Implements `encode_url_base64_string`.
 * @param src *u8
 * @param src_len i32
 * @param out *String
 * @return i32
 */
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

/** Exported function `decode_url_base64_string`.
 * Implements `decode_url_base64_string`.
 * @param b64 StrView
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_url_base64_string(b64: StrView, out: *u8, out_cap: i32): i32 {
  return base64_mod.decode_url(b64.ptr, b64.len, out, out_cap);
}

/** Exported function `extra_smoke`.
 * Implements `extra_smoke`.
 * @return i32
 */
export function extra_smoke(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = encoding_extra_smoke_c(); }
  return _rc;
}
