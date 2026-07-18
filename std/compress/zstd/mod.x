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
const lib = import("std.compress.zstd.lib");

/** Exported function `zstd_compress`.
 * Implements `zstd_compress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function zstd_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return lib.compress_zstd_compress_c(in, in_len, out, out_cap);
}

/** Exported function `zstd_decompress`.
 * Implements `zstd_decompress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function zstd_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return lib.compress_zstd_decompress_c(in, in_len, out, out_cap);
}

/** Exported function `zstd_available`.
 * Implements `zstd_available`.
 * @return i32
 */
export function zstd_available(): i32 {
  return lib.compress_zstd_available_c();
}

/** Exported function `zstd_smoke`.
 * Implements `zstd_smoke`.
 * @return i32
 */
export function zstd_smoke(): i32 {
  return lib.compress_zstd_smoke_c();
}

/** Exported function `zstd_stream_state_bytes`.
 * Implements `zstd_stream_state_bytes`.
 * @return i32
 */
export function zstd_stream_state_bytes(): i32 {
  return lib.compress_zstd_stream_state_bytes_c();
}

/** Exported function `zstd_stream_init_compress`.
 * Implements `zstd_stream_init_compress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function zstd_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return lib.compress_zstd_stream_init_compress_c(state, state_cap);
}

/** Exported function `zstd_stream_init_decompress`.
 * Implements `zstd_stream_init_decompress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function zstd_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return lib.compress_zstd_stream_init_decompress_c(state, state_cap);
}

/* See implementation. */
export function zstd_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return lib.compress_zstd_stream_compress_c(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/* See implementation. */
export function zstd_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return lib.compress_zstd_stream_decompress_c(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** Exported function `zstd_stream_end`.
 * Implements `zstd_stream_end`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function zstd_stream_end(state: *u8, state_cap: i32): i32 {
  return lib.compress_zstd_stream_end_c(state, state_cap);
}
