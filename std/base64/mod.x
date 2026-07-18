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

extern function base64_encode_standard_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function base64_encode_url_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function base64_decode_standard_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;
extern function base64_decode_url_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32;

/** Exported function `encode_standard`.
 * Implements `encode_standard`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encode_standard(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_encode_standard_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `encode_url`.
 * Implements `encode_url`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encode_url(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_encode_url_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `decode_standard`.
 * Implements `decode_standard`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_standard(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_decode_standard_c(src, src_len, out, out_cap); }
  return _rc;
}

/** Exported function `decode_url`.
 * Implements `decode_url`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decode_url(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_decode_url_c(src, src_len, out, out_cap); }
  return _rc;
}

extern function base64_stream_state_bytes_c(): i32;
extern function base64_stream_enc_init_c(state: *u8, state_cap: i32, url: i32): i32;
extern function base64_stream_dec_init_c(state: *u8, state_cap: i32, url: i32): i32;
extern function base64_stream_enc_update_c(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8,
  out_cap: i32, is_last: i32, in_consumed: *i32): i32;
extern function base64_stream_dec_update_c(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8,
  out_cap: i32, is_last: i32, in_consumed: *i32): i32;

/** Exported function `state_bytes`.
 * Implements `state_bytes`.
 * @return i32
 */
export function state_bytes(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_stream_state_bytes_c(); }
  return _rc;
}

/** Exported function `enc_init`.
 * Implements `enc_init`.
 * @param state *u8
 * @param state_cap i32
 * @param url i32
 * @return i32
 */
export function enc_init(state: *u8, state_cap: i32, url: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_stream_enc_init_c(state, state_cap, url); }
  return _rc;
}

/** Exported function `dec_init`.
 * Implements `dec_init`.
 * @param state *u8
 * @param state_cap i32
 * @param url i32
 * @return i32
 */
export function dec_init(state: *u8, state_cap: i32, url: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_stream_dec_init_c(state, state_cap, url); }
  return _rc;
}

/* See implementation. */
export function enc_update(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_stream_enc_update_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed); }
  return _rc;
}

/* See implementation. */
export function dec_update(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = base64_stream_dec_update_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed); }
  return _rc;
}
