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

/** Exported function `crypto_aes_gcm_marker_c`.
 * Implements `crypto_aes_gcm_marker_c`.
 * @return i32
 */
export function crypto_aes_gcm_marker_c(): i32 {
  return 0x41455347;
}

/* See implementation. */
export function crypto_aes_gcm_seal_c(key: *u8, key_len: i32, iv: *u8, iv_len: i32,
  aad: *u8, aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32 {
  return -1;
}

/* See implementation. */
export function crypto_aes_gcm_open_c(key: *u8, key_len: i32, iv: *u8, iv_len: i32,
  aad: *u8, aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32 {
  return -1;
}
