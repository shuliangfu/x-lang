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

// std.crypto.chacha20_poly1305 — F-04 v18：ChaCha20 核心锚点（G-03 seed asm）
//
// 【文件职责】
// ChaCha20 块函数锚点；完整 quarter-round 实现待迁 C 胶层或与 aead 一并链接。
//
// 【导出】shu_chacha20_block（供 mod / aead extern）。

/** seed asm 可 emit 的版本标记。 */
function crypto_chacha_core_marker_c(): i32 {
  return 0x43484132;
}

/** ChaCha20 单块 keystream 锚点。 */
function shu_chacha20_block(key: *u8, nonce: *u8, counter: u32, out: *u8): void {
  return;
}
