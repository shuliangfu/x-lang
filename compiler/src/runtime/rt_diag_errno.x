// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Runtime diag/errno helpers (G.9 English; body is authoritative).
// Runtime diag/errno helpers (G.9 English; body is authoritative).
// Runtime diag/errno helpers (G.9 English; body is authoritative).
// Runtime diag/errno helpers (G.9 English; body is authoritative).
// Runtime diag/errno helpers (G.9 English; body is authoritative).
// Runtime diag/errno helpers (G.9 English; body is authoritative).
//
// PLATFORM: SHARED — errno TLS accessors are declared on every host; only the
// matching rt_diag_get_errno body (#[cfg]) references one of them. Do NOT wrap
// these two export-externs in #[cfg]: a kept cfg-extern followed by a skipped
// cfg-extern poisons later global assigns (rt_diag_ensure_codes → XT001
// check_block) on the host where the second attr is false. Typeck residual
// tracked separately; leaf uses always-on decls so dual-host prove stays green.
// w1136: stores to the file-level lets go through a pointer slot. A direct
// store does not emit (elf_ec=-1).

export extern "C" function __errno_location(): *i32;
export extern "C" function __error(): *i32;
export extern "C" function _errno(): *i32;

export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function strerror(e: i32): *u8;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/* See signature and body for contracts. */
export let g_rt_diag_codes_ready: i32 = 0;
export let g_rt_diag_io001: *u8 = 0 as *u8;
export let g_rt_diag_prc001: *u8 = 0 as *u8;
export let g_rt_diag_bld001: *u8 = 0 as *u8;

/** Read the thread-local errno for Linux.
 * Calls libc `__errno_location` and returns `*p`, or 0 if the pointer is null.
 * Track-L: #[no_mangle] keeps the short surface name (not rt_diag_errno_rt_diag_get_errno).
 * PLATFORM: LINUX — errno TLS via __errno_location; macOS uses the sibling below. */
#[cfg(target_os = "linux")]
#[no_mangle]
export function rt_diag_get_errno(): i32 {
  let p: *i32 = 0 as *i32;
  // FFI: TLS errno lives behind a function pointer from libc.
  unsafe {
    p = __errno_location();
  }
  if (p == 0 as *i32) {
    return 0;
  }
  return p[0];
}

/** Read the thread-local errno for macOS/Darwin.
 * Calls libc `__error` and returns `*p`, or 0 if the pointer is null.
 * Track-L: #[no_mangle] keeps the short surface name (not module-prefixed mangle).
 * PLATFORM: MACOS — errno TLS via __error; Linux uses the sibling above. */
#[cfg(target_os = "macos")]
#[no_mangle]
export function rt_diag_get_errno(): i32 {
  let p: *i32 = 0 as *i32;
  // FFI: Darwin errno accessor (not __errno_location).
  unsafe {
    p = __error();
  }
  if (p == 0 as *i32) {
    return 0;
  }
  return p[0];
}

/** Read the thread-local errno for Windows (MinGW / msvcrt).
 * Calls `_errno` and returns `*p`, or 0 if the pointer is null.
 * Track-L: #[no_mangle] keeps the short surface name.
 * PLATFORM: WINDOWS — errno via msvcrt _errno (w1498: the no_c runtime needs
 * this body on Windows; before, only the stale LEGACY runtime_driver.o had it). */
#[cfg(target_os = "windows")]
#[no_mangle]
export function rt_diag_get_errno(): i32 {
  let p: *i32 = 0 as *i32;
  // FFI: msvcrt errno accessor.
  unsafe {
    p = _errno();
  }
  if (p == 0 as *i32) {
    return 0;
  }
  return p[0];
}

/** One-shot malloc of stable diagnostic code strings: "IO001", "PRC001", "BLD001".
 * After the first successful ensure, `g_rt_diag_codes_ready` is 1 and pointers are
 * read-only for the process lifetime (avoids returning stack/compound-literal *u8 from -E).
 * Each code is allocated as an 8-byte NUL-terminated buffer (ASCII digits written bytewise).
 * Track-L: #[no_mangle] matches surface short name rt_diag_ensure_codes.
 * PLATFORM: SHARED — link-name contract; verify with mac + Ubuntu prove. */
#[no_mangle]
export function rt_diag_ensure_codes(): void {
  let p: *u8 = 0 as *u8;
  let ready_slot: *i32 = &g_rt_diag_codes_ready;
  if (ready_slot[0] != 0) {
    return;
  }
  // "IO001" — I/O family diagnostic code.
  unsafe {
    p = malloc(8 as usize);
  }
  if (p != 0 as *u8) {
    p[0] = 73;
    p[1] = 79;
    p[2] = 48;
    p[3] = 48;
    p[4] = 49;
    p[5] = 0;
    let io_slot: **u8 = &g_rt_diag_io001;
    io_slot[0] = p;
  }
  // "PRC001" — process family diagnostic code.
  unsafe {
    p = malloc(8 as usize);
  }
  if (p != 0 as *u8) {
    p[0] = 80;
    p[1] = 82;
    p[2] = 67;
    p[3] = 48;
    p[4] = 48;
    p[5] = 49;
    p[6] = 0;
    let prc_slot: **u8 = &g_rt_diag_prc001;
    prc_slot[0] = p;
  }
  // "BLD001" — build family diagnostic code (default for unknown kinds).
  unsafe {
    p = malloc(8 as usize);
  }
  if (p != 0 as *u8) {
    p[0] = 66;
    p[1] = 76;
    p[2] = 68;
    p[3] = 48;
    p[4] = 48;
    p[5] = 49;
    p[6] = 0;
    let bld_slot: **u8 = &g_rt_diag_bld001;
    bld_slot[0] = p;
  }
  ready_slot[0] = 1;
}

/** Return the index of the first 0 in `dst`, or `cap` when none fits.
 * The pointer and the index are copied to locals before the subscript.
 * PLATFORM: SHARED. */
function rt_diag_scan_nul(dst: *u8, cap: i32): i32 {
  let d: *u8 = dst;
  let i: i32 = 0;
  while (i < cap) {
    let k: i32 = i;
    if (d[k] == 0) {
      return i;
    }
    i = i + 1;
  }
  return cap;
}

/** Copy `src` onto `dst` starting at `i0`, leaving one byte for the NUL.
 * Returns the new length excluding that NUL. Stops at a 0 in `src`.
 * PLATFORM: SHARED. */
function rt_diag_copy_src(dst: *u8, cap: i32, src: *u8, i0: i32): i32 {
  let d: *u8 = dst;
  let s: *u8 = src;
  let i: i32 = i0;
  let j: i32 = 0;
  while (i + 1 < cap) {
    let kj: i32 = j;
    let c: u8 = s[kj];
    if (c == 0) {
      break;
    }
    let ki: i32 = i;
    d[ki] = c;
    i = i + 1;
    j = j + 1;
  }
  let ke: i32 = i;
  d[ke] = 0;
  return i;
}

/** Force a NUL at the last byte of a full buffer and return `cap - 1`.
 * PLATFORM: SHARED. */
function rt_diag_force_nul(dst: *u8, cap: i32): i32 {
  let d: *u8 = dst;
  let last: i32 = cap - 1;
  d[last] = 0;
  return cap - 1;
}

/** Length of `dst` when `src` is null: 0 if no NUL fits in `cap`.
 * PLATFORM: SHARED. */
function rt_diag_len_or_zero(dst: *u8, cap: i32): i32 {
  let n: i32 = rt_diag_scan_nul(dst, cap);
  if (n == cap) {
    return 0;
  }
  return n;
}

/** Append after the existing NUL, or clamp when the buffer is already full.
 * PLATFORM: SHARED. */
function rt_diag_append_body(dst: *u8, cap: i32, src: *u8): i32 {
  let i: i32 = rt_diag_scan_nul(dst, cap);
  if (i >= cap) {
    return rt_diag_force_nul(dst, cap);
  }
  return rt_diag_copy_src(dst, cap, src, i);
}

/** Append NUL-terminated `src` onto `dst` within capacity `cap` (cap includes room for the trailing NUL).
 * Returns the new length of `dst` excluding the trailing NUL.
 * - null `dst` → 0
 * - null `src` → length of existing `dst` content (or 0 if no NUL found within cap)
 * - if `dst` is already full (no room for a char + NUL), force-NUL at cap-1 and return cap-1
 * - copy stops at src NUL or when only one byte remains for the destination NUL
 * Track-L: #[no_mangle] keeps short surface name (not rt_diag_errno_rt_diag_append).
 * PLATFORM: SHARED — link-name contract; dual-host prove.
 * The scans live in helpers so this frame does not store into the saved x19 slot. */
#[no_mangle]
export function rt_diag_append(dst: *u8, cap: i32, src: *u8): i32 {
  if (dst == 0 as *u8) {
    return 0;
  }
  if (src == 0 as *u8) {
    return rt_diag_len_or_zero(dst, cap);
  }
  return rt_diag_append_body(dst, cap, src);
}

/** Exported function `runtime_diag_code_for_kind`.
 * Implements `runtime_diag_code_for_kind`.
 * @param kind *u8
 * @return *u8
 */
#[no_mangle]
export function runtime_diag_code_for_kind(kind: *u8): *u8 {
  let io_slot: **u8 = &g_rt_diag_io001;
  let prc_slot: **u8 = &g_rt_diag_prc001;
  let bld_slot: **u8 = &g_rt_diag_bld001;
  rt_diag_ensure_codes();
  if (kind == 0 as *u8) {
    return bld_slot[0];
  }
  unsafe {
    if (strcmp(kind, "io error") == 0) {
      return io_slot[0];
    }
    if (strcmp(kind, "process error") == 0) {
      return prc_slot[0];
    }
    if (strcmp(kind, "build error") == 0) {
      return bld_slot[0];
    }
  }
  return 0 as *u8;
}

/** Exported function `runtime_diag_errno`.
 * Implements `runtime_diag_errno`.
 * @param file *u8
 * @param kind *u8
 * @param op *u8
 * @return void
 */
#[no_mangle]
export function runtime_diag_errno(file: *u8, kind: *u8, op: *u8): void {
  let saved: i32 = 0;
  let err: *u8 = 0 as *u8;
  let rk: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[256] = [];
  let s: *u8 = 0 as *u8;
  saved = rt_diag_get_errno();
  unsafe {
    err = strerror(saved);
  }
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  if (kind != 0 as *u8) {
    rk = kind;
  } else {
    rk = "build error";
  }
  code = runtime_diag_code_for_kind(rk);
  if (op != 0 as *u8) {
    s = op;
  } else {
    s = "system call";
  }
  msg[0] = 0;
  rt_diag_append(&msg[0], 256, s);
  rt_diag_append(&msg[0], 256, " failed: ");
  rt_diag_append(&msg[0], 256, err);
  unsafe {
    diag_report_with_code(file, 0, 0, rk, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `runtime_diag_errno_path`.
 * Implements `runtime_diag_errno_path`.
 * @param file *u8
 * @param kind *u8
 * @param op *u8
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function runtime_diag_errno_path(file: *u8, kind: *u8, op: *u8, path: *u8): void {
  let saved: i32 = 0;
  let err: *u8 = 0 as *u8;
  let rk: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[384] = [];
  let s: *u8 = 0 as *u8;
  if (path == 0 as *u8) {
    runtime_diag_errno(file, kind, op);
    return;
  }
  if (path[0 as usize] == 0 as u8) {
    runtime_diag_errno(file, kind, op);
    return;
  }
  saved = rt_diag_get_errno();
  unsafe {
    err = strerror(saved);
  }
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  if (kind != 0 as *u8) {
    rk = kind;
  } else {
    rk = "build error";
  }
  code = runtime_diag_code_for_kind(rk);
  if (op != 0 as *u8) {
    s = op;
  } else {
    s = "system call";
  }
  msg[0] = 0;
  rt_diag_append(&msg[0], 384, s);
  rt_diag_append(&msg[0], 384, " failed for '");
  rt_diag_append(&msg[0], 384, path);
  rt_diag_append(&msg[0], 384, "': ");
  rt_diag_append(&msg[0], 384, err);
  unsafe {
    diag_report_with_code(file, 0, 0, rk, code, &msg[0], 0 as *u8);
  }
}

/* See signature and body for contracts. */
#[no_mangle]
export function runtime_diag_errno_path_pair(
  file: *u8, kind: *u8, op: *u8, from_path: *u8, to_path: *u8): void {
  let saved: i32 = 0;
  let err: *u8 = 0 as *u8;
  let rk: *u8 = 0 as *u8;
  let code: *u8 = 0 as *u8;
  let msg: u8[512] = [];
  let s: *u8 = 0 as *u8;
  let from_s: *u8 = 0 as *u8;
  let to_s: *u8 = 0 as *u8;
  saved = rt_diag_get_errno();
  unsafe {
    err = strerror(saved);
  }
  if (err == 0 as *u8) {
    err = "unknown error";
  }
  if (kind != 0 as *u8) {
    rk = kind;
  } else {
    rk = "build error";
  }
  code = runtime_diag_code_for_kind(rk);
  if (op != 0 as *u8) {
    s = op;
  } else {
    s = "system call";
  }
  if (from_path != 0 as *u8) {
    from_s = from_path;
  } else {
    from_s = "?";
  }
  if (to_path != 0 as *u8) {
    to_s = to_path;
  } else {
    to_s = "?";
  }
  msg[0] = 0;
  rt_diag_append(&msg[0], 512, s);
  rt_diag_append(&msg[0], 512, " failed for '");
  rt_diag_append(&msg[0], 512, from_s);
  rt_diag_append(&msg[0], 512, "' -> '");
  rt_diag_append(&msg[0], 512, to_s);
  rt_diag_append(&msg[0], 512, "': ");
  rt_diag_append(&msg[0], 512, err);
  unsafe {
    diag_report_with_code(file, 0, 0, rk, code, &msg[0], 0 as *u8);
  }
}

/** Exported function `runtime_diag_cli_usage_note`.
 * Implements `runtime_diag_cli_usage_note`.
 * @param argv0 *u8
 * @return void
 */
#[no_mangle]
export function runtime_diag_cli_usage_note(argv0: *u8): void {
  let msg: u8[256] = [];
  let name: *u8 = 0 as *u8;
  let note_kind: *u8 = 0 as *u8;
  if (argv0 != 0 as *u8) {
    name = argv0;
  } else {
    name = "xlang";
  }
  note_kind = "note";
  msg[0] = 0;
  rt_diag_append(&msg[0], 256, "usage: ");
  rt_diag_append(&msg[0], 256, name);
  rt_diag_append(&msg[0], 256, " [ -L <lib> ] [ -target <triple> ] [ -D <sym> ] ");
  rt_diag_append(&msg[0], 256, "[ -O 0|1|2|3|s ] [ -flto ] <file.x> [ -o <out> ]");
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, note_kind, 0 as *u8, &msg[0], 0 as *u8);
  }
}
