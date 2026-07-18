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

// std.crypto.aes_gcm — F-04 v17：AES-128-GCM API 锚点（G-03 seed asm）
//
// 【文件职责】
// seal/open C ABI 锚点；完整 GCM 参考实现见 analysis/std-crypto-aes-gcm-v1.md（待迁 C 胶层）。
//
// 【导出】crypto_aes_gcm_seal_c、crypto_aes_gcm_open_c（与 mod.x extern 一致）。

/** seed asm 可 emit 的版本标记。 */
export function crypto_aes_gcm_marker_c(): i32 {
  return 0x41455347;
}

/** AES-128-GCM 加密锚点（key_len=16、iv_len=12、tag 16B）；完整实现待 runtime_crypto_inc_glue.c。 */
export function crypto_aes_gcm_seal_c(key: *u8, key_len: i32, iv: *u8, iv_len: i32,
  aad: *u8, aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32 {
  return -1;
}

/** AES-128-GCM 解密锚点。 */
export function crypto_aes_gcm_open_c(key: *u8, key_len: i32, iv: *u8, iv_len: i32,
  aad: *u8, aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32 {
  return -1;
}
