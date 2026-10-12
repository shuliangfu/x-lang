// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// pipeline_fill_dep_strict_alias — Darwin arm64 and Linux product body for
// the one symbol host cc of seeds/pipeline_fill_dep_strict_alias.from_x.c
// emits. Forwards to run_x_pipeline_fill_dep_import_path_c. The emit passes
// -lib-name "" so the export stays bare (without it the name gains a
// pipeline_ prefix). This object is not pipeline_run_x_link_alias.o.
// A Linux miss returns 1 and does not exec cc.
// Windows keeps host cc of the C seed.
// PLATFORM: MACOS|DARWIN arm64 | LINUX. WINDOWS stays on the C seed.
// SHARED symbol names.

extern "C" function run_x_pipeline_fill_dep_import_path_c(
  module: *u8,
  ctx: *u8,
  dep_j: i32
): i32;

/**
 * Forward fill-dep import path to run_x_pipeline_fill_dep_import_path_c.
 * @param module *u8 — module pointer, forwarded unchanged; null is forwarded
 * @param ctx *u8 — dependency context, forwarded unchanged; null is forwarded
 * @param dep_j i32 — dependency index, forwarded unchanged
 * @return i32 — the value run_x_pipeline_fill_dep_import_path_c returns
 * PLATFORM: MACOS|DARWIN arm64 | LINUX. WINDOWS stays on the C seed.
 */
function run_x_pipeline_fill_dep_import_path(module: *u8, ctx: *u8, dep_j: i32): i32 {
  unsafe {
    let r: i32 = run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j);
    return r;
  }
  return 0;
}
