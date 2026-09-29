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

// runtime_process_argv_windows.x — Windows x86_64 whole body of
// runtime_process_argv.o.
//
// One pure-asm shot. No seed rest, no gcc -E, no host cc, no retry.
// The C seed's bind has no Win32 branch: it returns without reading
// the CRT. There is no constructor syntax and nothing to bind, so
// both bind functions return immediately. Getters read the globals.
// Codegen in another translation unit may store them.
//
// This file does not call malloc and does not put a buffer on the stack.
// process_args_count_c and process_arg_c are weakened after emit so
// std/process strong faces win.
//
// PLATFORM: WINDOWS x86_64. This file is compiled only on Windows.

/**
 * Argument count. Codegen may store here. This file never stores it.
 * PLATFORM: WINDOWS x86_64.
 */
export let xlang_process_argc: i32 = 0;

/**
 * Argument vector. Codegen may store here. This file never stores it.
 * PLATFORM: WINDOWS x86_64.
 */
export let xlang_process_argv: **u8 = 0;

/**
 * Doc anchor for this translation unit.
 * @return i32 — always 0
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function runtime_process_argv_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Wave anchor. g05 rejects an object that lacks this symbol, so a
 * host-cc of the C seed cannot be linked in its place.
 * @return i32 — always 0
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function runtime_process_argv_x_w1529_anchor(): i32 {
  return 0;
}

/**
 * Public bind name. The C body does not read a Win32 CRT, so this
 * returns without touching the globals.
 * @return void
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function xlang_process_argv_bind_from_crt_impl(): void {
  return;
}

/**
 * Public bind. Same no-op as the _impl.
 * @return void
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function xlang_process_argv_bind_from_crt(): void {
  xlang_process_argv_bind_from_crt_impl();
}

/**
 * Read the process argc from the global.
 * @return i32 — argument count, or 0 when unset
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function process_xlang_argc_get(): i32 {
  return xlang_process_argc;
}

/**
 * Read argv[i]. A negative index, a null vector, or an index past
 * argc returns null.
 * @param i i32 — argument index; negative is rejected
 * @return *u8 — NUL-terminated argument, or null
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function process_xlang_argv_get(i: i32): *u8 {
  let bound: **u8 = 0;
  if (xlang_process_argv == 0 || i < 0 || i >= xlang_process_argc) {
    return 0;
  }
  bound = xlang_process_argv;
  return bound[i];
}

/**
 * Weak fallback for std/process/process.x process_args_count_c.
 * The ensure path weakens this name so the strong process.x body wins.
 * @return i32 — process_xlang_argc_get
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function process_args_count_c(): i32 {
  return process_xlang_argc_get();
}

/**
 * Weak fallback for std/process/process.x process_arg_c.
 * The ensure path weakens this name so the strong process.x body wins.
 * @param i i32 — argument index
 * @return *u8 — process_xlang_argv_get
 * PLATFORM: WINDOWS x86_64.
 */
#[no_mangle]
export function process_arg_c(i: i32): *u8 {
  return process_xlang_argv_get(i);
}
