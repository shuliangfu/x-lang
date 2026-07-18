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
//
// See implementation.
// See implementation.
// See implementation.

/* See implementation. */

/* See implementation. */
extern function compress2(dest: *u8, destLen: *u64, source: *u8, sourceLen: u64, level: i32): i32;

/* See implementation. */
extern function uncompress(dest: *u8, destLen: *u64, source: *u8, sourceLen: u64): i32;

/* See implementation. */
let shu_compress_zlib_marker: u8 = 1;

/**
 * See implementation.
 * See implementation.
 */
export function compress_deflate_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) {
    return -1;
  }
  let dest_len: u64 = out_cap as u64;
  let ret: i32 = 0;
  unsafe { ret = compress2(out, &dest_len, in, in_len as u64, -1); }
  if (ret == 0) {
    return dest_len as i32;
  }
  return -1;
}

/**
 * See implementation.
 * See implementation.
 */
export function compress_inflate_c(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  if (in == 0 || out == 0 || in_len < 0 || out_cap <= 0) {
    return -1;
  }
  let dest_len: u64 = out_cap as u64;
  let ret: i32 = 0;
  unsafe { ret = uncompress(out, &dest_len, in, in_len as u64); }
  if (ret == 0) {
    return dest_len as i32;
  }
  return -1;
}
