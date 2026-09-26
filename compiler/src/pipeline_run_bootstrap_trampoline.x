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

// pipeline_run_bootstrap_trampoline — Darwin arm64 product body.
// pipeline_run_x_pipeline_impl forwards six arguments to
// pipeline_impl_run_all. That is the symbol the host cc of
// seeds/pipeline_run_bootstrap_trampoline.from_x.c emits.
// This object is not pipeline_run_impl_alias.o.
// Linux and Windows keep host cc of the C seed.
// PLATFORM: MACOS|DARWIN for this object path. SHARED symbol names.

extern "C" function pipeline_impl_run_all(module: *u8, arena: *u8, source: *u8, source_len: u64, out_buf: *u8, ctx: *u8): i32;

/**
 * Forward the runtime entry to pipeline_impl_run_all.
 * @param module *u8 — module pointer, forwarded unchanged
 * @param arena *u8 — arena pointer, forwarded unchanged
 * @param source *u8 — source bytes, forwarded unchanged
 * @param source_len u64 — source length, forwarded unchanged
 * @param out_buf *u8 — codegen output buffer, forwarded unchanged
 * @param ctx *u8 — dependency context, forwarded unchanged
 * @return i32 — the value pipeline_impl_run_all returns
 * Null pointers are forwarded. This function does not write them.
 * PLATFORM: MACOS|DARWIN arm64. Linux and Windows stay on the C seed.
 */
function pipeline_run_x_pipeline_impl(module: *u8, arena: *u8, source: *u8, source_len: u64, out_buf: *u8, ctx: *u8): i32 {
  unsafe {
    let r: i32 = pipeline_impl_run_all(module, arena, source, source_len, out_buf, ctx);
    return r;
  }
  return 0;
}
