// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// std/crypto/chacha20_aead.x — ChaCha20-Poly1305 AEAD API 锚点（G-03 seed asm）
//
// 【文件职责】
// seal/open/smoke C ABI 锚点；完整 AEAD 参考实现保留于 chacha20_poly1305 历史分单元（待迁 C 胶层）。
//
// 【导出】crypto_chacha20_poly1305_seal_c、open_c、smoke_c。

/** seed asm 可 emit 的版本标记。 */
function crypto_chacha_aead_marker_c(): i32 {
  return 0x43484143;
}

/** ChaCha20-Poly1305 加密锚点。 */
function crypto_chacha20_poly1305_seal_c(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32,
  aad: *u8, aad_len: i32, pt: *u8, pt_len: i32, ct: *u8, tag: *u8): i32 {
  return -1;
}

/** ChaCha20-Poly1305 解密锚点。 */
function crypto_chacha20_poly1305_open_c(key: *u8, key_len: i32, nonce: *u8, nonce_len: i32,
  aad: *u8, aad_len: i32, ct: *u8, ct_len: i32, tag: *u8, pt: *u8): i32 {
  return -1;
}

/** ChaCha20-Poly1305 烟测锚点。 */
function crypto_chacha20_poly1305_smoke_c(): i32 {
  return -1;
}
