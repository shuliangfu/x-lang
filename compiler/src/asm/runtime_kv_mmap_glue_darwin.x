// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_kv_mmap_glue_darwin.x — Darwin arm64 whole body of
// runtime_kv_mmap_glue.o.
//
// The cold ensure path pure-asms this file and does not pass
// seeds/runtime_kv_mmap_glue.from_x.c to host cc. Linux and Windows still
// compile that C seed. Their open and mmap flag numbers differ, and Windows
// does not use this mapping path.
//
// Contract, matching the C seed: open the path read-write and create it when
// missing; if the file is shorter than min_size, grow it; map it shared and
// writable; close the descriptor; write the mapped length through out_size;
// return the address, or 0 on failure. munmap and msync return 0 or -1.
// A null path or a null out_size returns 0. Address 0 is rejected by munmap
// and msync.
//
// File length is lseek SEEK_END, which equals st_size for a regular file.
// struct stat is not placed on the stack: this compiler's frame can be
// shorter than the highest slot, and a Darwin stat is larger than the
// frames this TU is willing to use. The C seed remains the fstat authority
// on Linux and on the Darwin backup path. A usize value is not cast to i64:
// that cast makes this compiler exit 139. ftruncate takes the usize bits,
// which match off_t for a non-negative length, and the grown length is read
// back with a second lseek.
//
// Darwin libc numbers used below: O_RDWR is 2, O_CREAT is 0x200, so the
// open flags word is 514. The create mode is decimal 420 (octal 0644).
// SEEK_END is 2. PROT_READ|PROT_WRITE is 3. MAP_SHARED is 1. MAP_FAILED is
// all-bits-one, which is negative as i64. MS_SYNC is 16.
//
// Calls are libSystem. Create uses the ___open syscall stub because
// variadic open keeps the mode on the stack. errno is not consulted, so this
// object does not reference __error. Public names stay strong. The shared
// anchor file runtime_kv_mmap_glue.x is not compiled on Darwin; this file
// defines the same anchor so the symbol still exists.
//
// This object is a user companion for std/db/kv. It is not in the g05
// compiler image. A missing object after a pure-asm fault falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * libsystem_kernel __open. The public open is variadic: Darwin puts the
 * mode on the stack, and this compiler passes a third argument in x2, so
 * calling open drops the mode. The libsystem_kernel stub C name is __open,
 * Mach-O symbol ___open. This compiler does not add a leading underscore
 * when the source name already has one, so the source name is ___open.
 * @param path *u8 — NUL-terminated path; caller owns; null is rejected by the wrapper
 * @param flags i32 — Darwin O_RDWR|O_CREAT, numeric 514
 * @param mode i32 — create mode; decimal 420
 * @return i32 — file descriptor, or -1 on failure
 * PLATFORM: MACOS|DARWIN — libsystem_kernel __open, not the variadic open
 */
export extern "C" function ___open(path: *u8, flags: i32, mode: i32): i32;

/**
 * libSystem close.
 * @param fd i32 — descriptor from open
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function close(fd: i32): i32;

/**
 * libSystem ftruncate.
 * @param fd i32 — writable descriptor
 * @param length usize — new file length in bytes; non-negative, same bits as off_t
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN — declared usize so the length is not cast from usize to i64
 */
export extern "C" function ftruncate(fd: i32, length: usize): i32;

/**
 * libSystem lseek.
 * @param fd i32 — open descriptor
 * @param offset i64 — byte offset; 0 with SEEK_END asks for the file length
 * @param whence i32 — Darwin SEEK_END is 2
 * @return i64 — resulting offset, or -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function lseek(fd: i32, offset: i64, whence: i32): i64;

/**
 * libSystem mmap. A null address is integer 0. MAP_FAILED is i64 -1.
 * @param addr i64 — hint; 0 lets the kernel choose
 * @param length usize — byte length; must be positive
 * @param prot i32 — Darwin PROT_READ|PROT_WRITE, numeric 3
 * @param flags i32 — Darwin MAP_SHARED, numeric 1
 * @param fd i32 — descriptor of the file
 * @param offset i64 — file offset; 0 for the kv mapping
 * @return i64 — mapped address, or -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function mmap(addr: i64, length: usize, prot: i32, flags: i32, fd: i32, offset: i64): i64;

/**
 * libSystem munmap.
 * @param addr i64 — address previously returned by mmap
 * @param length usize — byte length of that mapping
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function munmap(addr: i64, length: usize): i32;

/**
 * libSystem msync.
 * @param addr i64 — mapped address
 * @param length usize — byte length
 * @param flags i32 — Darwin MS_SYNC, numeric 16
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function msync(addr: i64, length: usize, flags: i32): i32;

/**
 * Read path helper for codegen discovery.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_kv_mmap_glue_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Length to map. SEEK_END matches st_size for a regular file. A shorter
 * file is grown with one ftruncate. Failure is -1.
 * @param fd i32 — descriptor opened read-write
 * @param min_size usize — minimum length in bytes
 * @return i64 — length in bytes, or -1 when lseek or ftruncate fails
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_kv_darwin_file_len(fd: i32, min_size: usize): i64 {
  let cur: i64 = 0;
  unsafe {
    cur = lseek(fd, 0, 2);
  }
  if (cur < 0) {
    return -1;
  }
  let cur_u: usize = cur as usize;
  if (cur_u >= min_size) {
    return cur;
  }
  let trunc_rc: i32 = 0;
  unsafe {
    trunc_rc = ftruncate(fd, min_size);
  }
  if (trunc_rc != 0) {
    return -1;
  }
  // Read the grown length back. Do not cast min_size to i64.
  let grown: i64 = 0;
  unsafe {
    grown = lseek(fd, 0, 2);
  }
  if (grown < 0) {
    return -1;
  }
  return grown;
}

/**
 * Map len bytes of fd. MAP_FAILED and a null result both become 0.
 * @param fd i32 — descriptor of the file
 * @param len i64 — positive byte length
 * @return i64 — mapped address, or 0 on failure
 * PLATFORM: MACOS|DARWIN — PROT_READ|PROT_WRITE and MAP_SHARED
 */
#[no_mangle]
export function xlang_kv_darwin_map(fd: i32, len: i64): i64 {
  let n: usize = len as usize;
  let p: i64 = 0;
  unsafe {
    p = mmap(0, n, 3, 1, fd, 0);
  }
  // MAP_FAILED is all-bits-one. A Darwin user mapping is not negative.
  if (p < 0) {
    return 0;
  }
  if (p == 0) {
    return 0;
  }
  return p;
}

/**
 * Store the mapped length. Isolated so the store slot stays inside this
 * function's frame.
 * @param out_size *usize — caller-owned slot; the wrapper already rejected null
 * @param len i64 — positive mapped length
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_kv_darwin_store_size(out_size: *usize, len: i64): i32 {
  let n: usize = len as usize;
  unsafe {
    *out_size = n;
  }
  return 0;
}

/**
 * Map path, creating and growing it when needed.
 * @param path *u8 — NUL-terminated path; null returns 0
 * @param min_size usize — minimum file length in bytes
 * @param out_size *usize — receives the mapped length; null returns 0
 * @return i64 — mapped address, or 0 on failure
 * PLATFORM: MACOS|DARWIN — libSystem open, lseek, ftruncate, mmap
 */
#[no_mangle]
export function xlang_kv_mmap_file_c(path: *u8, min_size: usize, out_size: *usize): i64 {
  if (path == 0) {
    return 0;
  }
  if (out_size == 0) {
    return 0;
  }
  let fd: i32 = 0;
  unsafe {
    // 514 = O_RDWR|O_CREAT. 420 = mode 0644.
    // ___open takes the mode in a register. Variadic open would not.
    fd = ___open(path, 514, 420);
  }
  if (fd < 0) {
    return 0;
  }
  let len: i64 = xlang_kv_darwin_file_len(fd, min_size);
  if (len <= 0) {
    unsafe {
      close(fd);
    }
    return 0;
  }
  let mapped: i64 = xlang_kv_darwin_map(fd, len);
  unsafe {
    close(fd);
  }
  if (mapped == 0) {
    return 0;
  }
  xlang_kv_darwin_store_size(out_size, len);
  return mapped;
}

/**
 * Drop a mapping. Address 0 returns -1 and does not call munmap.
 * @param addr i64 — mapped address
 * @param len usize — byte length passed to mmap
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_kv_munmap_c(addr: i64, len: usize): i32 {
  if (addr == 0) {
    return -1;
  }
  let rc: i32 = 0;
  unsafe {
    rc = munmap(addr, len);
  }
  if (rc == 0) {
    return 0;
  }
  return -1;
}

/**
 * Flush a mapping with MS_SYNC. Address 0 returns -1.
 * @param addr i64 — mapped address
 * @param len usize — byte length passed to mmap
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN — flags word 16 is MS_SYNC
 */
#[no_mangle]
export function xlang_kv_msync_c(addr: i64, len: usize): i32 {
  if (addr == 0) {
    return -1;
  }
  let rc: i32 = 0;
  unsafe {
    rc = msync(addr, len, 16);
  }
  if (rc == 0) {
    return 0;
  }
  return -1;
}
