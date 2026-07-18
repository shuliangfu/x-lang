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

// build.x — Shux project build strategy (what to build, in what order, which
// products). Written in Shux; intended as the single build-policy source so
// the toolchain can retire Makefile-centric workflows over time.
// Entry: `shux build` / `build_tool` / `shux-build.sh`.
// Bootstrap layers, Target B, and acceptance gates: compiler/docs/SELFHOST.md
// (complements src/asm/README.md Goal 2).
//
//
// ========================================================================
// ========================================================================
// ========================================================================
// See implementation.
//
// ========================================================================
// ========================================================================
// ========================================================================
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// compiler/shux_asm。
// See implementation.
// See implementation.
// See implementation.
//
//
// ========================================================================
// ========================================================================
// ========================================================================
// See implementation.
//
// ========================================================================
// ========================================================================
// ========================================================================
//
// See implementation.
//       cd compiler && sh bootstrap.sh
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
//       ./build_tool ./shux
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
//
//
// ========================================================================
// ========================================================================
// ========================================================================
// See implementation.
//
// ========================================================================
// ========================================================================
// ========================================================================
//
// See implementation.
//       cd compiler && ./build_tool ./shux
// See implementation.
//
// See implementation.
//       ./build_tool /path/to/shux
//
// See implementation.
// scripts/build_shux_asm.sh）：
//       ./build_tool ./shux asm
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
//
// ========================================================================
// ========================================================================
// ========================================================================
// See implementation.
//
// ========================================================================
// ========================================================================
// ========================================================================
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
//
// ========================================================================
// ========================================================================
// ========================================================================
// See implementation.
//
// ========================================================================
// ========================================================================
// ========================================================================
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
//
//
// ========================================================================
// ========================================================================
// ========================================================================
// See implementation.
//
// ========================================================================
// ========================================================================
// ========================================================================
//
// See implementation.
// See implementation.
// See implementation.
// parser/typeck/codegen/ast/token/lexer/preprocess → _x.o
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

/**
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
* See implementation.
*/
function build_use_asm_only(): i32 {
  return 1;
}

/** Internal function `build_get_step_at`.
 * Implements `build_get_step_at`.
 * @param i i32
 * @return i32
 */
function build_get_step_at(i: i32): i32 {
  if (i == 0) { return 0; }
  if (i == 1) { return 6; }
  if (i == 2) { return 1; }
  if (i == 3) { return 2; }
  if (i == 4) { return 3; }
  if (i == 5) { return 4; }
  if (i == 6) { return 5; }
  return -1;
}

/** Internal function `build_get_step_count`.
 * Implements `build_get_step_count`.
 * @return i32
 */
function build_get_step_count(): i32 {
  return 7;
}
