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

// std/crypto/chacha20_aead.x — ChaCha20-Poly1305 AEAD API 锚点（G-03 seed asm）
//
// 【文件职责】
// seal/open/smoke C ABI 锚点；完整 AEAD 参考实现保留于 chacha20_poly1305 历史分单元（待迁 C 胶层）。
//
// 【导出】crypto_chacha20_poly1305_seal_c、open_c、smoke_c。

/** seed asm 可 emit 的版本标记。 */
export function crypto_chacha_aead_marker_c(): i32 {
  return 0x43484143;
}

/** ChaCha20-Poly1305 加密锚点。 */
export function crypto_chacha20_poly1305_seal_c(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32,
  aad: *u8, aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32 {
  return -1;
}

/** ChaCha20-Poly1305 解密锚点。 */
export function crypto_chacha20_poly1305_open_c(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32,
  aad: *u8, aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32 {
  return -1;
}

/** ChaCha20-Poly1305 烟测锚点。 */
export function crypto_chacha20_poly1305_smoke_c(): i32 {
  return -1;
}
