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

// runtime_process_argv_darwin.x — Darwin arm64 whole body of
// runtime_process_argv.o.
//
// The cold ensure path pure-asms this file and does not pass
// seeds/runtime_process_argv.from_x.c to host cc. Linux still reads
// /proc/self/cmdline in that seed. Windows still uses the Win32 CRT
// path in that seed. src/asm/runtime_process_argv.x stays the shared
// thin: it forwards to the C _impl. Darwin does not compile that thin.
//
// Darwin argc and argv come from libSystem _NSGetArgc and _NSGetArgv.
// The Mach-O names are __NSGetArgc and __NSGetArgv.
//
// This compiler cannot emit a store to a file-level let: the Mach-O
// writer returns elf_ec=-1 and writes no object. It also cannot emit
// a constructor, so there is no __mod_init_func. The two globals are
// still defined here so a link that names them resolves. A store from
// another translation unit (codegen writing main's argc/argv) is
// visible to the getters. When both globals are still clear, the
// getters read the CRT slots and do not write the globals back.
// xlang_process_argv_bind_from_crt is the same no-op for that reason.
// Callers that need the values use the getters.
//
// The global symbols are emitted as Lxml_* commons. The ensure path
// renames them to xlang_process_argc and xlang_process_argv.
//
// process_args_count_c and process_arg_c are weakened after emit.
// std/process/process.x defines the same two names as strong symbols.
// When a user link includes both objects, the strong process faces win.
//
// This object is a user companion. It is not in the g05 compiler image.
// A missing object after a pure-asm fault falls back to the C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Process argument count. Another translation unit may store here.
 * Zero with a null argv means the getters should read the CRT.
 * This file never stores it. The ensure path renames the Lxml common.
 * PLATFORM: SHARED
 */
export let xlang_process_argc: i32 = 0;

/**
 * Process argument vector. Null with a zero argc means unbound.
 * This file never stores it. The ensure path renames the Lxml common.
 * PLATFORM: SHARED
 */
export let xlang_process_argv: **u8 = 0;

/**
 * Darwin CRT argc slot.
 * @return *i32 — pointer to the process argc, or null
 * PLATFORM: MACOS|DARWIN — libSystem, symbol __NSGetArgc
 */
export extern "C" function __NSGetArgc(): *i32;

/**
 * Darwin CRT argv slot.
 * @return ***u8 — pointer to the process argv, or null
 * PLATFORM: MACOS|DARWIN — libSystem, symbol __NSGetArgv
 */
export extern "C" function __NSGetArgv(): ***u8;

/**
 * Doc anchor for this translation unit.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_process_argv_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Public bind name. This compiler cannot store the file-level lets,
 * so this does not copy the CRT into the globals. The getters read
 * the CRT themselves when the globals are still clear.
 * @return void
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_process_argv_bind_from_crt_impl(): void {
  return;
}

/**
 * Public bind. Same no-op as the _impl. The shared thin calls the
 * _impl name; Darwin defines both.
 * @return void
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_process_argv_bind_from_crt(): void {
  xlang_process_argv_bind_from_crt_impl();
}

/**
 * Read the process argc. A positive global count with a non-null
 * global vector is returned as-is, so a codegen write wins. Otherwise
 * the value is *_NSGetArgc(), or 0 when that slot is null.
 * @return i32 — argument count
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_xlang_argc_get(): i32 {
  if (xlang_process_argc > 0 && xlang_process_argv != 0) {
    return xlang_process_argc;
  }
  unsafe {
    let argc_p: *i32 = __NSGetArgc();
    if (argc_p == 0) {
      return 0;
    }
    return argc_p[0];
  }
}

/**
 * Read argv[i]. A negative index returns null. When the globals are
 * already bound, the vector is the global. Otherwise it is *_NSGetArgv().
 * An index at or past argc returns null.
 * @param i i32 — argument index; negative is rejected
 * @return *u8 — NUL-terminated argument, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_xlang_argv_get(i: i32): *u8 {
  if (i < 0) {
    return 0;
  }
  if (xlang_process_argc > 0 && xlang_process_argv != 0) {
    if (i >= xlang_process_argc) {
      return 0;
    }
    let bound: **u8 = xlang_process_argv;
    return bound[i];
  }
  unsafe {
    let argc_p: *i32 = __NSGetArgc();
    let argv_p: ***u8 = __NSGetArgv();
    if (argc_p == 0 || argv_p == 0) {
      return 0;
    }
    let n: i32 = argc_p[0];
    if (i >= n) {
      return 0;
    }
    let argv: **u8 = argv_p[0];
    if (argv == 0) {
      return 0;
    }
    return argv[i];
  }
}

/**
 * Weak fallback for std/process/process.x process_args_count_c.
 * The ensure path weakens this name so the strong process.x body wins.
 * @return i32 — process_xlang_argc_get
 * PLATFORM: MACOS|DARWIN
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
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_arg_c(i: i32): *u8 {
  return process_xlang_argv_get(i);
}
