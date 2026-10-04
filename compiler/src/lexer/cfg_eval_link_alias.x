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

// cfg_eval_link_alias — Darwin arm64 product body for the six symbols
// host cc of seeds/cfg_eval_link_alias.from_x.c emits. Four names forward
// to the lexer_cfg_* callees. The two host literals are the Darwin strings
// macos and aarch64. Both pointers stay at the same address across calls.
// This object is not cfg_eval.o and not cfg_eval_x.o.
// Linux and Windows keep host cc of the C seed, which picks the host
// strings with the preprocessor.
// PLATFORM: MACOS|DARWIN for this object path. SHARED symbol names.

extern "C" function lexer_cfg_eval_expr_c(start: *u8, len: i32): i32;
extern "C" function lexer_cfg_apply_compile_target_from_triple(triple: *u8, len: i32): void;
extern "C" function lexer_cfg_reset_compile_target(): void;
extern "C" function lexer_cfg_set_freestanding(v: i32): void;

/**
 * Forward cfg expression evaluation to lexer_cfg_eval_expr_c.
 * @param start *u8 — expression bytes, forwarded unchanged; null is forwarded
 * @param len i32 — byte length, forwarded unchanged
 * @return i32 — the value lexer_cfg_eval_expr_c returns
 * PLATFORM: MACOS|DARWIN arm64. Linux and Windows stay on the C seed.
 */
function cfg_eval_expr_c(start: *u8, len: i32): i32 {
  unsafe {
    let r: i32 = lexer_cfg_eval_expr_c(start, len);
    return r;
  }
  return 0;
}

/**
 * Forward a target triple to lexer_cfg_apply_compile_target_from_triple.
 * @param triple *u8 — triple bytes, forwarded unchanged; null is forwarded
 * @param len i32 — byte length, forwarded unchanged
 * PLATFORM: MACOS|DARWIN arm64.
 */
function cfg_apply_compile_target_from_triple(triple: *u8, len: i32): void {
  unsafe { lexer_cfg_apply_compile_target_from_triple(triple, len); }
}

/**
 * Forward a target reset to lexer_cfg_reset_compile_target.
 * PLATFORM: MACOS|DARWIN arm64.
 */
function cfg_reset_compile_target(): void {
  unsafe { lexer_cfg_reset_compile_target(); }
}

/**
 * Forward the freestanding flag to lexer_cfg_set_freestanding.
 * @param v i32 — flag value, forwarded unchanged
 * PLATFORM: MACOS|DARWIN arm64.
 */
function cfg_set_freestanding(v: i32): void {
  unsafe { lexer_cfg_set_freestanding(v); }
}

/**
 * Darwin host OS literal for cfg evaluation.
 * @return i64 — pointer bits of the stable bytes macos in rax, including the
 *   trailing NUL. Two calls return the same address. Not a stack buffer.
 *   Link name unchanged.
 * PLATFORM: MACOS|DARWIN arm64. The installed product cannot asm-emit this *u8 return.
 */
function cfg_host_os_lit(): i64 {
  let p: *u8 = "macos";
  return p as i64;
}

/**
 * Darwin host architecture literal for cfg evaluation.
 * @return i64 — pointer bits of the stable bytes aarch64 in rax, including the
 *   trailing NUL. Two calls return the same address. Not a stack buffer.
 *   Link name unchanged.
 * PLATFORM: MACOS|DARWIN arm64. The installed product cannot asm-emit this *u8 return.
 */
function cfg_host_arch_lit(): i64 {
  let p: *u8 = "aarch64";
  return p as i64;
}
