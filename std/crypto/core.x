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
//
// See implementation.

/** Exported function `crypto_mem_eq_c`.
 * Implements `crypto_mem_eq_c`.
 * @param a *u8
 * @param b *u8
 * @param len i32
 * @return i32
 */
export function crypto_mem_eq_c(a: *u8, b: *u8, len: i32): i32 {
  let diff: u8 = 0 as u8;
  let i: i32 = 0;
  if (a == 0 || b == 0) {
    if (a == b) { return 1; }
    return 0;
  }
  while (i < len) {
    diff = (diff | (a[i] ^ b[i])) as u8;
    i = i + 1;
  }
  if (diff == 0 as u8) { return 1; }
  return 0;
}

/** Exported function `crypto_sha256_c`.
 * Implements `crypto_sha256_c`.
 * @param msg *u8
 * @param len i32
 * @param out *u8
 * @return void
 */
export function crypto_sha256_c(msg: *u8, len: i32, out: *u8): void {
  return;
}

/** Exported function `crypto_hmac_sha256_c`.
 * Implements `crypto_hmac_sha256_c`.
 * @param key *u8
 * @param key_len i32
 * @param msg *u8
 * @param msg_len i32
 * @param out *u8
 * @return void
 */
export function crypto_hmac_sha256_c(key: *u8, key_len: i32, msg: *u8, msg_len: i32, out: *u8): void {
  return;
}

/** Exported function `crypto_f_sha256_marker_c`.
 * Implements `crypto_f_sha256_marker_c`.
 * @return i32
 */
export function crypto_f_sha256_marker_c(): i32 {
  return 0x53484132;
}
