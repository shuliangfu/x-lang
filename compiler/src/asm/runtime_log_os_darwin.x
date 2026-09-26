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

// runtime_log_os_darwin.x — Darwin arm64 OS bridges for runtime_log_os.o.
//
// The cold ensure path pure-asms src/asm/runtime_log_os.x (public
// wrappers) and this file (the _impl bridges and the two smokes), then
// ld -r. It does not pass seeds/runtime_log_os.from_x.c to host cc.
// Linux keeps the POSIX seed. Windows keeps the Win32 seed.
//
// File-level slots start as zero commons. The first call sets the
// file descriptor to -1 and the sink mask to STDERR (1) by memcpy
// into the let. A direct store to a file-level let does not emit on
// this compiler. Passing &let as a call argument makes this compiler
// exit 139, so the address is loaded into a local first.
//
// Darwin xlang_io_write / xlang_io_open_write are static-inline svc
// sequences. This compiler cannot emit svc. Open goes through
// libsystem_kernel ___open, the same symbol runtime_kv_mmap uses,
// with the Darwin flag values from xlang_io_cap.h plus O_APPEND.
// Measured on this host: O_WRONLY=1, O_CREAT=0x200, O_TRUNC=0x400,
// O_APPEND=8, so append-create is 0x209 and trunc-create is 0x601.
// Mode is decimal 420 (0644). struct stat is 144 bytes and st_size
// is the i64 at offset 96.
//
// Rotate names are path + '.' + one digit. max_backups is at most 8,
// so the suffix is one byte. xlang_snprintf is static inline and is
// not called.
//
// The async queue is two heap buffers (32 lengths and 32*512 data
// bytes). A 512-byte stack array does not fit this compiler's frame.
// A parameter used as an index extra-derefs on load, so the index is
// copied into a local first. Slot bytes are copied by index. Taking
// &base[off] is not that byte's address.
//
// The two smokes live here because the C seed is not linked on this
// path. They call log_write_c / log_write_structured_kv_c from the
// std log object. The read-back uses one libSystem read of cap-1
// bytes, which covers the smoke files.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Byte copy. Used to publish file-level slots this compiler cannot
 * store directly.
 * @param d *u8 — destination
 * @param s *u8 — source
 * @param n i64 — byte count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memcpy(d: *u8, s: *u8, n: i64): *u8;

/**
 * Byte length of a NUL-terminated string.
 * @param s *u8 — string, not null
 * @return i64 — bytes before the NUL
 * PLATFORM: POSIX
 */
export extern "C" function strlen(s: *u8): i64;

/**
 * Heap buffer.
 * @param n i64 — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * Release a buffer from malloc.
 * @param p *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function free(p: *u8): void;

/**
 * libsystem_kernel open. The variadic libc open drops the mode.
 * @param path *u8 — NUL-terminated path
 * @param flags i32 — Darwin open flags
 * @param mode i32 — create mode, decimal 420
 * @return i32 — file descriptor, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function ___open(path: *u8, flags: i32, mode: i32): i32;

/**
 * libSystem close.
 * @param fd i32 — descriptor
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function close(fd: i32): i32;

/**
 * libSystem write. Same declaration as runtime_panic_arm64.x.
 * @param fd i32 — descriptor
 * @param buf *u8 — bytes
 * @param n usize — count
 * @return isize — bytes written, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function write(fd: i32, buf: *u8, n: usize): isize;

/**
 * libSystem read.
 * @param fd i32 — descriptor
 * @param buf *u8 — destination
 * @param n usize — capacity
 * @return isize — bytes read, 0 at EOF, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function read(fd: i32, buf: *u8, n: usize): isize;

/**
 * libSystem unlink.
 * @param path *u8 — path
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function unlink(path: *u8): i32;

/**
 * libSystem rename.
 * @param oldp *u8 — existing path
 * @param newp *u8 — new path
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function rename(oldp: *u8, newp: *u8): i32;

/**
 * libSystem stat. The buffer is 144 bytes on this Darwin.
 * @param path *u8 — NUL-terminated path
 * @param buf *u8 — 144-byte struct stat
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function stat(path: *u8, buf: *u8): i32;

/**
 * User-domain getenv face. Defined by runtime_link_abi_user_env.x.
 * @param name *u8 — NUL-terminated key
 * @return *u8 — value, or null
 * PLATFORM: SHARED
 */
export extern "C" function link_abi_getenv(name: *u8): *u8;

/**
 * First match of needle in hay, or null.
 * @param h *u8 — haystack
 * @param n *u8 — needle
 * @return *u8 — match, or null
 * PLATFORM: POSIX
 */
export extern "C" function strstr(h: *u8, n: *u8): *u8;

/**
 * Formatted log line. Defined by std/log/log.x, not this TU.
 * @param level i32 — 0..3
 * @param ptr *u8 — message bytes
 * @param len i32 — byte count
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
export extern "C" function log_write_c(level: i32, ptr: *u8, len: i32): i32;

/**
 * Structured log line. Defined by std/log, not this TU.
 * @param component *u8 — component name
 * @param level i32 — 0..3
 * @param kv *u8 — key=value body
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
export extern "C" function log_write_structured_kv_c(component: *u8, level: i32, kv: *u8): i32;

/**
 * Thin public setter. Defined by runtime_log_os.x.
 * @param level i32 — 0..3
 * PLATFORM: SHARED
 */
export extern "C" function log_set_min_level_c(level: i32): void;

/**
 * Thin public mask setter. Defined by runtime_log_os.x.
 * @param mask i32 — STDERR=1, FILE=2
 * PLATFORM: SHARED
 */
export extern "C" function log_set_sink_mask_c(mask: i32): void;

/**
 * Thin public file-sink opener. Defined by runtime_log_os.x.
 * @param path *u8 — path bytes
 * @param len i32 — byte count
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
export extern "C" function log_set_file_sink_c(path: *u8, len: i32): i32;

/**
 * Thin public file-sink closer. Defined by runtime_log_os.x.
 * PLATFORM: SHARED
 */
export extern "C" function log_close_file_sink_c(): void;

/**
 * Thin public rotate setter. Defined by runtime_log_os.x.
 * @param max_bytes i32 — threshold
 * @param max_backups i32 — 0..8
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
export extern "C" function log_set_rotate_c(max_bytes: i32, max_backups: i32): i32;

/**
 * Thin public async switch. Defined by runtime_log_os.x.
 * @param enabled i32 — non-zero enables
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
export extern "C" function log_set_async_enabled_c(enabled: i32): i32;

/**
 * Thin public async flush. Defined by runtime_log_os.x.
 * @return i32 — 0, or -1
 * PLATFORM: SHARED
 */
export extern "C" function log_async_flush_c(): i32;

/**
 * 1 after the zero commons have been given their C initial values.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_ready: i32 = 0;

/**
 * Minimum level, 0..3. Zero until set.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_min_level: i32 = 0;

/**
 * Sink mask. Init writes 1 (STDERR).
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_sink_mask: i32 = 0;

/**
 * Open file sink, or -1. Init writes -1. A zero common would be stdin.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_file_fd: i32 = 0;

/**
 * 1 after XLANG_LOG_MIN_LEVEL has been read once.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_env_applied: i32 = 0;

/**
 * Heap path, 512 bytes, allocated on init.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_path_buf: *u8 = 0;

/**
 * Path length excluding the NUL.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_path_len: i32 = 0;

/**
 * Bytes written to the current file sink.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_file_bytes: i64 = 0;

/**
 * Rotate when the next write would pass this size. 0 disables.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_rotate_max_bytes: i32 = 0;

/**
 * Backup count, 0..8.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_rotate_max_backups: i32 = 0;

/**
 * Non-zero when emit goes through the async queue.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_async_enabled: i32 = 0;

/**
 * Occupied async slots, 0..32.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_async_count: i32 = 0;

/**
 * 32*512 data bytes. Null until async is enabled.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_async_data: *u8 = 0;

/**
 * 32 i32 lengths. Null until async is enabled.
 * PLATFORM: MACOS|DARWIN
 */
export let log_os_async_lens: *i32 = 0;

/**
 * Copy 4 bytes into an i32 slot.
 * @param slot *i32 — destination
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function log_os_set_i32(slot: *i32, v: i32): void {
  let tmp: i32 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 4);
  }
}

/**
 * Copy 8 bytes into an i64 slot.
 * @param slot *i64 — destination
 * @param v i64 — value
 * PLATFORM: MACOS|DARWIN
 */
function log_os_set_i64(slot: *i64, v: i64): void {
  let tmp: i64 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Copy one pointer into a *u8 slot.
 * @param slot **u8 — destination
 * @param v *u8 — pointer
 * PLATFORM: MACOS|DARWIN
 */
function log_os_set_ptr(slot: **u8, v: *u8): void {
  let tmp: *u8 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Copy one pointer into a *i32 slot.
 * @param slot **i32 — destination
 * @param v *i32 — pointer
 * PLATFORM: MACOS|DARWIN
 */
function log_os_set_iptr(slot: **i32, v: *i32): void {
  let tmp: *i32 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Give the zero commons their C initial values, once.
 * File descriptor becomes -1 and the sink mask becomes STDERR.
 * The path buffer is 512 bytes on the heap.
 * PLATFORM: MACOS|DARWIN
 */
function log_os_init(): void {
  if (log_os_ready == 1) {
    return;
  }
  if (log_os_path_buf == 0) {
    let b: *u8 = 0;
    unsafe {
      b = malloc(512);
    }
    if (b != 0) {
      let slot: **u8 = &log_os_path_buf;
      log_os_set_ptr(slot, b);
    }
  }
  let fd_slot: *i32 = &log_os_file_fd;
  log_os_set_i32(fd_slot, 0 - 1);
  let mask_slot: *i32 = &log_os_sink_mask;
  log_os_set_i32(mask_slot, 1);
  let ready_slot: *i32 = &log_os_ready;
  log_os_set_i32(ready_slot, 1);
}

/**
 * Allocate the async queue once. 32 lengths and 32*512 data bytes.
 * @return i32 — 0 when both buffers exist, -1 on malloc failure
 * PLATFORM: MACOS|DARWIN
 */
function log_os_async_ready(): i32 {
  log_os_init();
  if (log_os_async_data != 0 && log_os_async_lens != 0) {
    return 0;
  }
  let data: *u8 = 0;
  let raw: *u8 = 0;
  unsafe {
    data = malloc(16384);
    raw = malloc(128);
  }
  if (data == 0 || raw == 0) {
    return 0 - 1;
  }
  let data_slot: **u8 = &log_os_async_data;
  log_os_set_ptr(data_slot, data);
  let lens: *i32 = raw as *i32;
  let lens_slot: **i32 = &log_os_async_lens;
  log_os_set_iptr(lens_slot, lens);
  return 0;
}

/**
 * Load the i64 at a byte offset. Used for st_size at offset 96.
 * The index is a local so the load is the byte, not an extra deref.
 * @param buf *u8 — source bytes
 * @param off i32 — start offset
 * @return i64 — little-endian value
 * PLATFORM: MACOS|DARWIN
 */
function log_os_load_i64_at(buf: *u8, off: i32): i64 {
  let tmp: i64 = 0;
  let p: *u8 = &tmp as *u8;
  let i: i32 = 0;
  while (i < 8) {
    let at: i32 = off + i;
    p[i] = buf[at];
    i = i + 1;
  }
  return tmp;
}

/**
 * st_size of path, or 0 when stat fails or the size is not positive.
 * @param path *u8 — NUL-terminated path
 * @return i64 — size, or 0
 * PLATFORM: MACOS|DARWIN
 */
function log_os_stat_size(path: *u8): i64 {
  let buf: *u8 = 0;
  unsafe {
    buf = malloc(144);
  }
  if (buf == 0) {
    return 0;
  }
  let rc: i32 = 0;
  unsafe {
    rc = stat(path, buf);
  }
  if (rc != 0) {
    unsafe {
      free(buf);
    }
    return 0;
  }
  let sz: i64 = log_os_load_i64_at(buf, 96);
  unsafe {
    free(buf);
  }
  if (sz > 0) {
    return sz;
  }
  return 0;
}

/**
 * Parse a leading optional minus and digits. Stops at the first
 * non-digit. Empty and non-numeric strings return 0, matching atoi.
 * @param s *u8 — NUL-terminated text, not null
 * @return i32 — parsed value
 * PLATFORM: MACOS|DARWIN
 */
function log_os_atoi(s: *u8): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let sign: i32 = 1;
  let c: u8 = s[0];
  if (c == 45 as u8) {
    sign = 0 - 1;
    i = 1;
  }
  while (i < 16) {
    c = s[i];
    if (c < 48 as u8) {
      return n * sign;
    }
    if (c > 57 as u8) {
      return n * sign;
    }
    n = n * 10 + ((c as i32) - 48);
    i = i + 1;
  }
  return n * sign;
}

/**
 * Write path + '.' + digit into dst. n is 1..8, so the suffix is one byte.
 * @param dst *u8 — at least path_len+3 bytes
 * @param n i32 — backup index, 1..8
 * PLATFORM: MACOS|DARWIN
 */
function log_os_fill_backup(dst: *u8, n: i32): void {
  let plen: i32 = log_os_path_len;
  let src: *u8 = log_os_path_buf;
  unsafe {
    memcpy(dst, src, plen as i64);
  }
  dst[plen] = 46 as u8;
  dst[plen + 1] = (48 + n) as u8;
  dst[plen + 2] = 0 as u8;
}

/**
 * Copy n bytes into async slot i. The index is a local.
 * @param slot i32 — 0..31
 * @param src *u8 — source bytes
 * @param n i32 — byte count, 0..512
 * PLATFORM: MACOS|DARWIN
 */
function log_os_slot_store(slot: i32, src: *u8, n: i32): void {
  let base: *u8 = log_os_async_data;
  let off: i32 = slot * 512;
  let i: i32 = 0;
  while (i < n) {
    let at: i32 = off + i;
    base[at] = src[i];
    i = i + 1;
  }
}

/**
 * Copy n bytes out of async slot i into dst.
 * @param dst *u8 — destination
 * @param slot i32 — 0..31
 * @param n i32 — byte count
 * PLATFORM: MACOS|DARWIN
 */
function log_os_slot_load(dst: *u8, slot: i32, n: i32): void {
  let base: *u8 = log_os_async_data;
  let off: i32 = slot * 512;
  let i: i32 = 0;
  while (i < n) {
    let at: i32 = off + i;
    dst[i] = base[at];
    i = i + 1;
  }
}

/**
 * Store one async slot length. The index is a local.
 * @param i i32 — slot
 * @param n i32 — length
 * PLATFORM: MACOS|DARWIN
 */
function log_os_len_store(i: i32, n: i32): void {
  let lens: *i32 = log_os_async_lens;
  let j: i32 = i;
  lens[j] = n;
}

/**
 * Read one async slot length. The index is a local.
 * @param i i32 — slot
 * @return i32 — length
 * PLATFORM: MACOS|DARWIN
 */
function log_os_len_load(i: i32): i32 {
  let lens: *i32 = log_os_async_lens;
  let j: i32 = i;
  return lens[j];
}

/**
 * Reopen the stored path and publish the descriptor.
 * @param flags i32 — Darwin open flags
 * @return i32 — descriptor, or -1
 * PLATFORM: MACOS|DARWIN
 */
function log_os_reopen(flags: i32): i32 {
  let path: *u8 = log_os_path_buf;
  let fd: i32 = 0 - 1;
  if (path != 0) {
    unsafe {
      fd = ___open(path, flags, 420);
    }
  }
  let slot: *i32 = &log_os_file_fd;
  log_os_set_i32(slot, fd);
  return fd;
}

/**
 * Read up to cap-1 bytes and write a NUL. One libSystem read.
 * Smoke files fit in the caller buffer.
 * @param path *u8 — NUL-terminated path
 * @param buf *u8 — destination
 * @param cap i32 — capacity including the NUL
 * @return i32 — bytes excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
function log_os_read_file(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap < 2) {
    return 0 - 1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = ___open(path, 0, 0);
  }
  if (fd < 0) {
    return 0 - 1;
  }
  let n: isize = 0;
  let room: i32 = cap - 1;
  unsafe {
    n = read(fd, buf, room as usize);
    close(fd);
  }
  if (n < 0) {
    return 0 - 1;
  }
  let ni: i32 = n as i32;
  buf[ni] = 0 as u8;
  return ni;
}

/**
 * Free two smoke buffers and return the code.
 * @param a *u8 — first buffer, or null
 * @param b *u8 — second buffer, or null
 * @param code i32 — smoke result
 * @return i32 — code
 * PLATFORM: MACOS|DARWIN
 */
function log_os_smoke_done(a: *u8, b: *u8, code: i32): i32 {
  unsafe {
    if (a != 0) {
      free(a);
    }
    if (b != 0) {
      free(b);
    }
  }
  return code;
}

/**
 * Write bytes to a descriptor.
 * @param fd i32 — descriptor
 * @param buf *u8 — bytes, null is rejected
 * @param len i32 — count
 * @return i32 — bytes written, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_write_fd_impl(fd: i32, buf: *u8, len: i32): i32 {
  if (buf == 0 || len < 0) {
    return 0 - 1;
  }
  if (len == 0) {
    return 0;
  }
  let n: isize = 0;
  unsafe {
    n = write(fd, buf, len as usize);
  }
  if (n < 0) {
    return 0 - 1;
  }
  return n as i32;
}

/**
 * Current minimum level.
 * @return i32 — 0..3
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_get_min_level_impl(): i32 {
  log_os_init();
  return log_os_min_level;
}

/**
 * Set the minimum level when it is in 0..3. Other values are ignored.
 * @param level i32 — requested level
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_set_min_level_impl(level: i32): void {
  log_os_init();
  if (level >= 0 && level <= 3) {
    let slot: *i32 = &log_os_min_level;
    log_os_set_i32(slot, level);
  }
}

/**
 * Replace the sink mask.
 * @param mask i32 — STDERR=1, FILE=2, or both
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_set_sink_mask_impl(mask: i32): void {
  log_os_init();
  let slot: *i32 = &log_os_sink_mask;
  log_os_set_i32(slot, mask);
}

/**
 * Close the file sink when it is open.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_close_file_sink_impl(): void {
  log_os_init();
  let fd: i32 = log_os_file_fd;
  if (fd >= 0) {
    unsafe {
      close(fd);
    }
    let slot: *i32 = &log_os_file_fd;
    log_os_set_i32(slot, 0 - 1);
  }
}

/**
 * Open path for append. Existing size becomes the byte counter.
 * @param path *u8 — path bytes, not necessarily NUL-terminated
 * @param len i32 — byte count
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_set_file_sink_impl(path: *u8, len: i32): i32 {
  log_os_init();
  log_close_file_sink_impl();
  if (path == 0 || len <= 0) {
    return 0 - 1;
  }
  let cap: i32 = len;
  if (cap >= 512) {
    cap = 511;
  }
  let dst: *u8 = log_os_path_buf;
  if (dst == 0) {
    return 0 - 1;
  }
  unsafe {
    memcpy(dst, path, cap as i64);
  }
  dst[cap] = 0 as u8;
  let len_slot: *i32 = &log_os_path_len;
  log_os_set_i32(len_slot, cap);
  let bytes_slot: *i64 = &log_os_file_bytes;
  log_os_set_i64(bytes_slot, 0);
  let sz: i64 = log_os_stat_size(dst);
  if (sz > 0) {
    log_os_set_i64(bytes_slot, sz);
  }
  // 521 = 0x209 = O_WRONLY|O_CREAT|O_APPEND, mode is applied inside reopen.
  let fd: i32 = log_os_reopen(521);
  if (fd >= 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Rotate the current file. max_backups 0 truncates. Otherwise the
 * highest backup is removed and names shift up by one.
 * @return i32 — 0, or -1 when the file cannot be reopened
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_do_rotate_impl(): i32 {
  log_os_init();
  if (log_os_rotate_max_bytes <= 0 || log_os_path_len <= 0) {
    return 0;
  }
  let max_b: i32 = log_os_rotate_max_backups;
  if (max_b < 0) {
    max_b = 0;
  }
  if (max_b > 8) {
    max_b = 8;
  }
  log_close_file_sink_impl();
  if (max_b == 0) {
    // 1537 = 0x601 = O_WRONLY|O_CREAT|O_TRUNC.
    log_os_reopen(1537);
  } else {
    let oldp: *u8 = 0;
    let newp: *u8 = 0;
    unsafe {
      oldp = malloc(520);
      newp = malloc(520);
    }
    if (oldp == 0 || newp == 0) {
      unsafe {
        if (oldp != 0) {
          free(oldp);
        }
        if (newp != 0) {
          free(newp);
        }
      }
      let slot: *i64 = &log_os_file_bytes;
      log_os_set_i64(slot, 0);
      return 0 - 1;
    }
    log_os_fill_backup(oldp, max_b);
    unsafe {
      unlink(oldp);
    }
    let i: i32 = max_b - 1;
    while (i >= 1) {
      log_os_fill_backup(oldp, i);
      log_os_fill_backup(newp, i + 1);
      unsafe {
        rename(oldp, newp);
      }
      i = i - 1;
    }
    log_os_fill_backup(newp, 1);
    let src: *u8 = log_os_path_buf;
    unsafe {
      rename(src, newp);
      free(oldp);
      free(newp);
    }
    // 521 = 0x209 = O_WRONLY|O_CREAT|O_APPEND.
    log_os_reopen(521);
  }
  let slot: *i64 = &log_os_file_bytes;
  log_os_set_i64(slot, 0);
  if (log_os_file_fd >= 0) {
    return 0;
  }
  return 0 - 1;
}

/**
 * Remember the rotate threshold. max_backups must be 0..8.
 * @param max_bytes i32 — size threshold, 0 disables
 * @param max_backups i32 — backup count
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_set_rotate_impl(max_bytes: i32, max_backups: i32): i32 {
  log_os_init();
  if (max_bytes < 0 || max_backups < 0 || max_backups > 8) {
    return 0 - 1;
  }
  let bslot: *i32 = &log_os_rotate_max_bytes;
  log_os_set_i32(bslot, max_bytes);
  let nslot: *i32 = &log_os_rotate_max_backups;
  log_os_set_i32(nslot, max_backups);
  return 0;
}

/**
 * Write to the file sink, rotating first when the next write would
 * pass the threshold.
 * @param buf *u8 — bytes
 * @param len usize — count
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_write_file_sync_impl(buf: *u8, len: usize): i32 {
  log_os_init();
  let mask: i32 = log_os_sink_mask;
  let fd: i32 = log_os_file_fd;
  if ((mask & 2) == 0 || fd < 0) {
    return 0;
  }
  let maxb: i32 = log_os_rotate_max_bytes;
  let bytes: i64 = log_os_file_bytes;
  let add: i64 = len as i64;
  if (maxb > 0 && bytes + add > (maxb as i64)) {
    if (log_do_rotate_impl() != 0) {
      return 0 - 1;
    }
    fd = log_os_file_fd;
  }
  if (log_write_fd_impl(fd, buf, len as i32) != (len as i32)) {
    return 0 - 1;
  }
  let slot: *i64 = &log_os_file_bytes;
  log_os_set_i64(slot, log_os_file_bytes + add);
  return 0;
}

/**
 * Write to stderr when that bit is set, then to the file sink.
 * @param buf *u8 — bytes
 * @param len usize — count
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_write_sync_impl(buf: *u8, len: usize): i32 {
  log_os_init();
  let mask: i32 = log_os_sink_mask;
  if ((mask & 1) != 0) {
    if (log_write_fd_impl(2, buf, len as i32) != (len as i32)) {
      return 0 - 1;
    }
  }
  return log_write_file_sync_impl(buf, len);
}

/**
 * Flush queued slots through the sync writer and clear the count.
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_async_flush_impl(): i32 {
  log_os_init();
  let nslots: i32 = log_os_async_count;
  if (nslots <= 0) {
    return 0;
  }
  let tmp: *u8 = 0;
  unsafe {
    tmp = malloc(512);
  }
  if (tmp == 0) {
    return 0 - 1;
  }
  let i: i32 = 0;
  while (i < nslots) {
    let ln: i32 = log_os_len_load(i);
    log_os_slot_load(tmp, i, ln);
    if (log_write_sync_impl(tmp, ln as usize) != 0) {
      unsafe {
        free(tmp);
      }
      return 0 - 1;
    }
    i = i + 1;
  }
  let slot: *i32 = &log_os_async_count;
  log_os_set_i32(slot, 0);
  unsafe {
    free(tmp);
  }
  return 0;
}

/**
 * Copy one record into the next free slot. A full queue is flushed first.
 * A length above 512 is rejected.
 * @param buf *u8 — bytes
 * @param len usize — count
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_async_enqueue_impl(buf: *u8, len: usize): i32 {
  log_os_init();
  if ((len as i64) > 512) {
    return 0 - 1;
  }
  if (log_os_async_ready() != 0) {
    return 0 - 1;
  }
  if (log_os_async_count >= 32) {
    if (log_async_flush_impl() != 0) {
      return 0 - 1;
    }
    if (log_os_async_count >= 32) {
      return 0 - 1;
    }
  }
  let slot_i: i32 = log_os_async_count;
  log_os_len_store(slot_i, len as i32);
  log_os_slot_store(slot_i, buf, len as i32);
  let slot: *i32 = &log_os_async_count;
  log_os_set_i32(slot, slot_i + 1);
  return 0;
}

/**
 * Queue when async is on, otherwise write immediately.
 * @param buf *u8 — bytes
 * @param len usize — count
 * @return i32 — 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_emit_bytes_impl(buf: *u8, len: usize): i32 {
  log_os_init();
  if (log_os_async_enabled != 0) {
    return log_async_enqueue_impl(buf, len);
  }
  return log_write_sync_impl(buf, len);
}

/**
 * Turn async on, or flush and turn it off.
 * @param enabled i32 — non-zero enables
 * @return i32 — 0, or -1 when the flush fails
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_set_async_enabled_impl(enabled: i32): i32 {
  log_os_init();
  if (enabled != 0) {
    if (log_os_async_ready() != 0) {
      return 0 - 1;
    }
    let slot: *i32 = &log_os_async_enabled;
    log_os_set_i32(slot, 1);
    return 0;
  }
  if (log_os_async_enabled != 0) {
    if (log_async_flush_impl() != 0) {
      return 0 - 1;
    }
    let slot: *i32 = &log_os_async_enabled;
    log_os_set_i32(slot, 0);
  }
  return 0;
}

/**
 * Read XLANG_LOG_MIN_LEVEL once. A value outside 0..3 is ignored.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_apply_env_once_impl(): void {
  log_os_init();
  if (log_os_env_applied != 0) {
    return;
  }
  let applied: *i32 = &log_os_env_applied;
  log_os_set_i32(applied, 1);
  let v: *u8 = 0;
  unsafe {
    v = link_abi_getenv("XLANG_LOG_MIN_LEVEL");
  }
  if (v == 0) {
    return;
  }
  if (v[0] == 0 as u8) {
    return;
  }
  let l: i32 = log_os_atoi(v);
  if (l >= 0 && l <= 3) {
    let slot: *i32 = &log_os_min_level;
    log_os_set_i32(slot, l);
  }
}

/**
 * STD-053 smoke. Return codes match the C seed.
 * @param path *u8 — file path, null returns 1
 * @return i32 — 0, or a step code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_multi_sink_smoke_c(path: *u8): i32 {
  if (path == 0) {
    return 1;
  }
  let buf: *u8 = 0;
  unsafe {
    buf = malloc(512);
  }
  if (buf == 0) {
    return 1;
  }
  let plen: i64 = 0;
  unsafe {
    plen = strlen(path);
  }
  unsafe {
    log_set_min_level_c(0);
    log_set_sink_mask_c(2);
  }
  let rc: i32 = 0;
  unsafe {
    rc = log_set_file_sink_c(path, plen as i32);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, 0, 2);
  }
  unsafe {
    rc = log_write_c(1, "sink_ok", 7);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, 0, 3);
  }
  unsafe {
    rc = log_write_structured_kv_c("std_log_smoke", 1, "event=smoke");
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, 0, 4);
  }
  unsafe {
    log_close_file_sink_c();
  }
  if (log_os_read_file(path, buf, 512) < 0) {
    return log_os_smoke_done(buf, 0, 5);
  }
  let hit: *u8 = 0;
  unsafe {
    hit = strstr(buf, "[INFO] sink_ok");
  }
  if (hit == 0) {
    return log_os_smoke_done(buf, 0, 6);
  }
  unsafe {
    hit = strstr(buf, "xlang: level=info component=std_log_smoke");
  }
  if (hit == 0) {
    return log_os_smoke_done(buf, 0, 7);
  }
  unsafe {
    unlink(path);
    log_set_min_level_c(2);
    log_set_sink_mask_c(2);
    rc = log_set_file_sink_c(path, plen as i32);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, 0, 8);
  }
  unsafe {
    log_write_c(1, "filtered", 8);
    rc = log_write_c(2, "sink_ok", 7);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, 0, 9);
  }
  unsafe {
    log_close_file_sink_c();
  }
  if (log_os_read_file(path, buf, 512) < 0) {
    return log_os_smoke_done(buf, 0, 10);
  }
  unsafe {
    unlink(path);
    hit = strstr(buf, "filtered");
  }
  if (hit != 0) {
    return log_os_smoke_done(buf, 0, 11);
  }
  unsafe {
    hit = strstr(buf, "[WARN] sink_ok");
  }
  if (hit == 0) {
    return log_os_smoke_done(buf, 0, 12);
  }
  unsafe {
    log_set_min_level_c(0);
    log_set_sink_mask_c(1);
  }
  return log_os_smoke_done(buf, 0, 0);
}

/**
 * STD-106 smoke. Return codes match the C seed.
 * @param path *u8 — file path, null returns 1
 * @return i32 — 0, or a step code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function log_rotate_async_smoke_c(path: *u8): i32 {
  if (path == 0) {
    return 1;
  }
  let buf: *u8 = 0;
  let path1: *u8 = 0;
  unsafe {
    buf = malloc(512);
    path1 = malloc(520);
  }
  if (buf == 0 || path1 == 0) {
    return log_os_smoke_done(buf, path1, 1);
  }
  let plen: i64 = 0;
  unsafe {
    plen = strlen(path);
  }
  if (plen > 516) {
    return log_os_smoke_done(buf, path1, 1);
  }
  unsafe {
    unlink(path);
    memcpy(path1, path, plen);
  }
  let ni: i32 = plen as i32;
  path1[ni] = 46 as u8;
  path1[ni + 1] = 49 as u8;
  path1[ni + 2] = 0 as u8;
  unsafe {
    unlink(path1);
    log_set_min_level_c(1);
    log_set_sink_mask_c(2);
  }
  let rc: i32 = 0;
  unsafe {
    rc = log_set_file_sink_c(path, plen as i32);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, path1, 2);
  }
  unsafe {
    rc = log_set_async_enabled_c(1);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, path1, 3);
  }
  unsafe {
    rc = log_write_c(1, "async1", 6);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, path1, 4);
  }
  if (log_os_read_file(path, buf, 512) >= 0) {
    let early: *u8 = 0;
    unsafe {
      early = strstr(buf, "async1");
    }
    if (early != 0) {
      return log_os_smoke_done(buf, path1, 5);
    }
  }
  unsafe {
    rc = log_async_flush_c();
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, path1, 6);
  }
  if (log_os_read_file(path, buf, 512) < 0) {
    return log_os_smoke_done(buf, path1, 7);
  }
  let hit: *u8 = 0;
  unsafe {
    hit = strstr(buf, "[INFO] async1");
  }
  if (hit == 0) {
    return log_os_smoke_done(buf, path1, 8);
  }
  unsafe {
    log_set_async_enabled_c(0);
    rc = log_set_rotate_c(48, 1);
  }
  if (rc != 0) {
    return log_os_smoke_done(buf, path1, 9);
  }
  let i: i32 = 0;
  while (i < 5) {
    unsafe {
      rc = log_write_c(1, "rotate_line_xx", 14);
    }
    if (rc != 0) {
      return log_os_smoke_done(buf, path1, 10);
    }
    i = i + 1;
  }
  unsafe {
    log_close_file_sink_c();
  }
  if (log_os_read_file(path1, buf, 512) < 0) {
    return log_os_smoke_done(buf, path1, 11);
  }
  unsafe {
    hit = strstr(buf, "rotate_line_xx");
  }
  if (hit == 0) {
    return log_os_smoke_done(buf, path1, 12);
  }
  unsafe {
    unlink(path);
    unlink(path1);
    log_set_rotate_c(0, 0);
    log_set_min_level_c(0);
    log_set_sink_mask_c(1);
  }
  return log_os_smoke_done(buf, path1, 0);
}
