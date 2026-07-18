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

// std.crypto.chacha20_poly1305 — F-04 v18：ChaCha20 核心锚点（G-03 seed asm）
//
// 【文件职责】
// ChaCha20 块函数锚点；完整 quarter-round 实现待迁 C 胶层或与 aead 一并链接。
//
// 【导出】shu_chacha20_block（供 mod / aead extern）。

/** seed asm 可 emit 的版本标记。 */
export function crypto_chacha_core_marker_c(): i32 {
  return 0x43484132;
}

/** ChaCha20 单块 keystream 锚点。 */
export function shu_chacha20_block(key: *u8, nonce: *u8, counter: u32, out: *u8): void {
  return;
}
