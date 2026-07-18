// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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
const elf = import("platform.elf");

export extern function pipeline_asm_arm64_cset_cond_enc_from_cc(cc: i32): i32;

/** Exported function `enc_a`.
 * Implements `enc_a`.
 * @param ctx *ElfCodegenCtx
 * @param val i32
 * @return i32
 */
export function enc_a(ctx: *ElfCodegenCtx, val: i32): i32 {
  return 0;
}

/** Exported function `enc_b`.
 * Implements `enc_b`.
 * @param ctx *ElfCodegenCtx
 * @param frame_size i32
 * @return i32
 */
export function enc_b(ctx: *ElfCodegenCtx, frame_size: i32): i32 {
  return 0;
}
