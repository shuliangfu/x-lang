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
const libz = import("std.compress.zlib.libz");

/** Exported function `deflate`.
 * Implements `deflate`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function deflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_deflate_c(in, in_len, out, out_cap);
}

/** Exported function `inflate`.
 * Implements `inflate`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function inflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return libz.compress_inflate_c(in, in_len, out, out_cap);
}
