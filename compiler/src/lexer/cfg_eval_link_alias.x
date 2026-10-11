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

// cfg_eval_link_alias — Darwin arm64 and Linux product body for the six
// symbols host cc of seeds/cfg_eval_link_alias.from_x.c emits. Four names
// forward to the lexer_cfg_* callees. The two host literals are selected by
// target_os the same way cfg_eval_host_lit.x does (product pairs:
// linux/x86_64, macos/aarch64, windows/x86_64, freebsd/x86_64). #[no_mangle]
// keeps the link names bare under src/lexer/ (otherwise the module prefix
// turns cfg_* into lexer_cfg_* and collapses the forwards). This object is
// not cfg_eval.o and not cfg_eval_x.o. A Linux miss returns 1 and does not
// exec cc. Windows keeps host cc of the C seed.
// PLATFORM: MACOS|DARWIN arm64 | LINUX. WINDOWS stays on the C seed.
// SHARED symbol names.

extern "C" function lexer_cfg_eval_expr_c(start: *u8, len: i32): i32;
extern "C" function lexer_cfg_apply_compile_target_from_triple(triple: *u8, len: i32): void;
extern "C" function lexer_cfg_reset_compile_target(): void;
extern "C" function lexer_cfg_set_freestanding(v: i32): void;

#[cfg(target_os = "linux")]
let CFG_ALIAS_HOST_OS_LIT: u8[6] = [108, 105, 110, 117, 120, 0];
#[cfg(target_os = "macos")]
let CFG_ALIAS_HOST_OS_LIT: u8[6] = [109, 97, 99, 111, 115, 0];
#[cfg(target_os = "windows")]
let CFG_ALIAS_HOST_OS_LIT: u8[8] = [119, 105, 110, 100, 111, 119, 115, 0];
#[cfg(target_os = "freebsd")]
let CFG_ALIAS_HOST_OS_LIT: u8[8] = [102, 114, 101, 101, 98, 115, 100, 0];

#[cfg(target_os = "linux")]
let CFG_ALIAS_HOST_ARCH_LIT: u8[7] = [120, 56, 54, 95, 54, 52, 0];
#[cfg(target_os = "macos")]
let CFG_ALIAS_HOST_ARCH_LIT: u8[8] = [97, 97, 114, 99, 104, 54, 52, 0];
#[cfg(target_os = "windows")]
let CFG_ALIAS_HOST_ARCH_LIT: u8[7] = [120, 56, 54, 95, 54, 52, 0];
#[cfg(target_os = "freebsd")]
let CFG_ALIAS_HOST_ARCH_LIT: u8[7] = [120, 56, 54, 95, 54, 52, 0];

/**
 * Forward cfg expression evaluation to lexer_cfg_eval_expr_c.
 * @param start *u8 — expression bytes, forwarded unchanged; null is forwarded
 * @param len i32 — byte length, forwarded unchanged
 * @return i32 — the value lexer_cfg_eval_expr_c returns
 * PLATFORM: MACOS|DARWIN arm64 | LINUX. WINDOWS stays on the C seed.
 */
#[no_mangle]
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
 * PLATFORM: MACOS|DARWIN arm64 | LINUX.
 */
#[no_mangle]
function cfg_apply_compile_target_from_triple(triple: *u8, len: i32): void {
  unsafe { lexer_cfg_apply_compile_target_from_triple(triple, len); }
}

/**
 * Forward a target reset to lexer_cfg_reset_compile_target.
 * PLATFORM: MACOS|DARWIN arm64 | LINUX.
 */
#[no_mangle]
function cfg_reset_compile_target(): void {
  unsafe { lexer_cfg_reset_compile_target(); }
}

/**
 * Forward the freestanding flag to lexer_cfg_set_freestanding.
 * @param v i32 — flag value, forwarded unchanged
 * PLATFORM: MACOS|DARWIN arm64 | LINUX.
 */
#[no_mangle]
function cfg_set_freestanding(v: i32): void {
  unsafe { lexer_cfg_set_freestanding(v); }
}

/**
 * Host OS literal for cfg evaluation.
 * @return i64 — pointer bits of CFG_ALIAS_HOST_OS_LIT in rax, including the
 *   trailing NUL. Two calls return the same address. Not a stack buffer.
 *   Link name unchanged.
 * PLATFORM: MACOS|DARWIN arm64 | LINUX. The installed product cannot asm-emit
 *   this *u8 return.
 */
#[no_mangle]
function cfg_host_os_lit(): i64 {
  return (&CFG_ALIAS_HOST_OS_LIT[0]) as i64;
}

/**
 * Host architecture literal for the product pair of this OS.
 * @return i64 — pointer bits of CFG_ALIAS_HOST_ARCH_LIT in rax, including the
 *   trailing NUL. Two calls return the same address. Not a stack buffer.
 *   Link name unchanged.
 * PLATFORM: MACOS|DARWIN arm64 | LINUX. The installed product cannot asm-emit
 *   this *u8 return.
 */
#[no_mangle]
function cfg_host_arch_lit(): i64 {
  return (&CFG_ALIAS_HOST_ARCH_LIT[0]) as i64;
}
