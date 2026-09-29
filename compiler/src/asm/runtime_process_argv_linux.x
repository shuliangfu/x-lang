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

// runtime_process_argv_linux.x — Linux x86_64 whole body of
// runtime_process_argv.o.
//
// One pure-asm shot. No seed rest, no gcc -E, no host cc, no retry.
// There is no constructor syntax, so the getters call bind when the
// globals are still clear. That replaces the C constructor(65535).
// A codegen write of both globals still wins: bind returns immediately.
//
// /proc/self/cmdline is not seekable. The read fills a 1 MiB heap
// buffer (never a stack array), NUL-terminates, and returns -2 when
// one more byte exists past cap-1. The buffer stays allocated because
// the argv vector points into it.
//
// Stores go through pointer slots. Hex and sizes are constants. There
// is no variable divisor, so this file does not pull in xlang_panic_.
// process_args_count_c and process_arg_c are weakened after emit so
// std/process strong faces win.
//
// PLATFORM: LINUX x86_64. This file is compiled only on Linux.
// Do not put a sole cfg(target_arch) here.

/**
 * Argument count. Codegen may store here. Zero with a null vector
 * means the getters should bind from /proc/self/cmdline.
 * PLATFORM: LINUX x86_64.
 */
export let xlang_process_argc: i32 = 0;

/**
 * Argument vector. Null with a zero count means unbound.
 * Entries point into the cmdline buffer, which is never freed.
 * PLATFORM: LINUX x86_64.
 */
export let xlang_process_argv: **u8 = 0;

// libc. O_RDONLY is 0. The third open argument is the mode.
// read's third argument is a byte count. Pointer width for calloc is 8.
// PLATFORM: LINUX x86_64.
extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
extern "C" function read(fd: i32, buf: *u8, n: usize): i64;
extern "C" function close(fd: i32): i32;
extern "C" function malloc(n: usize): *u8;
extern "C" function free(p: *u8): void;
extern "C" function calloc(count: usize, size: usize): *u8;

/**
 * Doc anchor for this translation unit.
 * @return i32 — always 0
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function runtime_process_argv_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Wave anchor. g05 rejects an object that lacks this symbol, so a
 * host-cc of the C seed cannot be linked in its place.
 * @return i32 — always 0
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function runtime_process_argv_x_w1529_anchor(): i32 {
  return 0;
}

/**
 * Read path into buf, at most cap-1 bytes, then write a trailing NUL.
 * Locals are declared before the libc calls. A file that still has a
 * byte after cap-1 returns -2 and does not pretend the prefix is complete.
 * @param buf *u8 — caller buffer; not null; capacity is cap
 * @param cap i32 — buffer capacity in bytes, including the trailing NUL
 * @return i32 — bytes stored before the NUL, -1 on open or read error, -2 if the file does not fit
 * PLATFORM: LINUX x86_64.
 */
function rpa_read_cmdline(buf: *u8, cap: i32): i32 {
  let path: *u8 = "/proc/self/cmdline";
  let fd: i32 = 0;
  let n: i64 = 0;
  let off: i32 = 0;
  let room: i32 = 0;
  let cr: i32 = 0;
  let probe: u8 = 0;
  if (buf == 0) {
    return -1;
  }
  if (cap < 2) {
    return -1;
  }
  unsafe {
    fd = open(path, 0, 0);
  }
  if (fd < 0) {
    return -1;
  }
  // Chunked seek-free fill. Stop with one byte reserved for the NUL.
  while (off + 1 < cap) {
    room = (cap - 1) - off;
    unsafe {
      n = read(fd, &buf[off], room as usize);
    }
    if (n < 0) {
      unsafe {
        cr = close(fd);
      }
      if (cr < 0) {
        cr = 0;
      }
      return -1;
    }
    if (n == 0) {
      break;
    }
    off = off + (n as i32);
  }
  // One probe byte past a full buffer means the cmdline exceeds the bound.
  if (off + 1 >= cap) {
    unsafe {
      n = read(fd, &probe, 1 as usize);
    }
    if (n > 0) {
      unsafe {
        cr = close(fd);
      }
      if (cr < 0) {
        cr = 0;
      }
      return -2;
    }
  }
  unsafe {
    cr = close(fd);
  }
  if (cr < 0) {
    cr = 0;
  }
  buf[off] = 0;
  return off;
}

/**
 * Count NUL-separated arguments in the first n bytes.
 * The trailing NUL that rpa_read_cmdline writes at index n is not counted.
 * @param buf *u8 — cmdline bytes
 * @param n i32 — byte count excluding the extra NUL
 * @return i32 — number of arguments, or 0
 * PLATFORM: LINUX x86_64.
 */
function rpa_count_args(buf: *u8, n: i32): i32 {
  let i: i32 = 0;
  let argc: i32 = 0;
  let b: u8 = 0;
  if (buf == 0 || n <= 0) {
    return 0;
  }
  while (i < n) {
    b = buf[i];
    if (b == 0) {
      argc = argc + 1;
      if (i + 1 >= n) {
        break;
      }
    }
    i = i + 1;
  }
  return argc;
}

/**
 * Point argv[i] at each NUL-separated argument. argv[argc] stays null
 * because the vector came from calloc.
 * @param argv **u8 — destination vector; not null
 * @param buf *u8 — cmdline buffer that must stay allocated
 * @param n i32 — byte count excluding the extra NUL
 * @param argc i32 — argument count from rpa_count_args
 * @return void
 * PLATFORM: LINUX x86_64.
 */
function rpa_fill_argv(argv: **u8, buf: *u8, n: i32, argc: i32): void {
  let i: i32 = 0;
  let p: i32 = 0;
  let b: u8 = 0;
  if (argv == 0 || buf == 0 || n <= 0 || argc <= 0) {
    return;
  }
  while (p < n && i < argc) {
    argv[i] = buf + p;
    i = i + 1;
    while (p < n) {
      b = buf[p];
      if (b == 0) {
        break;
      }
      p = p + 1;
    }
    p = p + 1;
  }
}

/**
 * Publish argc and argv. Pointer-slot stores match the form that
 * target_cpu uses for its file-level word.
 * @param argc i32 — argument count, already greater than zero
 * @param argv **u8 — vector; the cmdline buffer it points at stays alive
 * @return void
 * PLATFORM: LINUX x86_64.
 */
function rpa_linux_store(argc: i32, argv: **u8): void {
  let argc_slot: *i32 = &xlang_process_argc;
  let argv_slot: ***u8 = &xlang_process_argv;
  argc_slot[0] = argc;
  argv_slot[0] = argv;
}

/**
 * Bind from /proc/self/cmdline. No-op when both globals are already set.
 * The 1 MiB buffer is heap, not stack. On success it is intentionally
 * not freed. Failure frees it and leaves the globals clear.
 * @return void
 * PLATFORM: LINUX x86_64.
 */
function rpa_bind_linux(): void {
  let argc_now: i32 = 0;
  let argv_now: **u8 = 0;
  let raw: *u8 = 0;
  let argv_raw: *u8 = 0;
  let argv: **u8 = 0;
  let n: i32 = 0;
  let argc: i32 = 0;
  argc_now = xlang_process_argc;
  argv_now = xlang_process_argv;
  if (argc_now > 0 && argv_now != 0) {
    return;
  }
  unsafe {
    raw = malloc(1048576 as usize);
  }
  if (raw == 0) {
    return;
  }
  n = rpa_read_cmdline(raw, 1048576);
  if (n <= 0) {
    unsafe {
      free(raw);
    }
    return;
  }
  argc = rpa_count_args(raw, n);
  if (argc <= 0) {
    unsafe {
      free(raw);
    }
    return;
  }
  unsafe {
    argv_raw = calloc((argc + 1) as usize, 8 as usize);
  }
  if (argv_raw == 0) {
    unsafe {
      free(raw);
    }
    return;
  }
  argv = argv_raw as **u8;
  rpa_fill_argv(argv, raw, n, argc);
  rpa_linux_store(argc, argv);
}

/**
 * Public bind name. Same body as xlang_process_argv_bind_from_crt.
 * @return void
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function xlang_process_argv_bind_from_crt_impl(): void {
  rpa_bind_linux();
}

/**
 * Public bind. The shared thin calls this name.
 * @return void
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function xlang_process_argv_bind_from_crt(): void {
  xlang_process_argv_bind_from_crt_impl();
}

/**
 * Read the process argc. Binds from /proc when the globals are clear.
 * @return i32 — argument count, or 0 when unbound
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function process_xlang_argc_get(): i32 {
  let n: i32 = 0;
  // Load the count first. The ensure rename treats the first Lxml
  // relocation in this function as xlang_process_argc.
  n = xlang_process_argc;
  if (n > 0 && xlang_process_argv != 0) {
    return n;
  }
  xlang_process_argv_bind_from_crt();
  return xlang_process_argc;
}

/**
 * Read argv[i]. A negative index or an index past argc returns null.
 * Binds from /proc when the globals are clear.
 * @param i i32 — argument index; negative is rejected
 * @return *u8 — NUL-terminated argument, or null
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function process_xlang_argv_get(i: i32): *u8 {
  let bound: **u8 = 0;
  if (i < 0) {
    return 0;
  }
  if (xlang_process_argc <= 0 || xlang_process_argv == 0) {
    xlang_process_argv_bind_from_crt();
  }
  if (xlang_process_argv == 0 || i >= xlang_process_argc) {
    return 0;
  }
  bound = xlang_process_argv;
  return bound[i];
}

/**
 * Weak fallback for std/process/process.x process_args_count_c.
 * The ensure path weakens this name so the strong process.x body wins.
 * @return i32 — process_xlang_argc_get
 * PLATFORM: LINUX x86_64.
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
 * PLATFORM: LINUX x86_64.
 */
#[no_mangle]
export function process_arg_c(i: i32): *u8 {
  return process_xlang_argv_get(i);
}
