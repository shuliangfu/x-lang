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

// runtime_queue_contention_darwin.x — Darwin arm64 OS bridges for
// runtime_queue_contention.o.
//
// The cold ensure path pure-asms src/asm/runtime_queue_contention.x
// (the shared smoke and the public wrappers) and this file (the five
// _impl bridges), then ld -r. It does not pass
// seeds/runtime_queue_contention.from_x.c to host cc. Linux keeps the
// futex seed. Windows keeps the Win32 seed.
//
// Mutex bytes are a 64-byte pthread_mutex_t, the same size sync_os
// uses on Darwin arm64. Two workers are pthread_create plus
// pthread_join. The start routine is queue_os_worker_trampoline,
// which lives in the shared thin. A bare function name used as a
// pointer makes this compiler exit 139, so the spawn looks the
// trampoline up with dlsym(RTLD_DEFAULT). A null call keeps the
// symbol referenced. A null argument returns at once.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Heap buffer. 64 bytes holds one Darwin pthread_mutex_t.
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
 * libSystem pthread_mutex_init. attr null selects the default mutex.
 * @param m *u8 — 64-byte mutex
 * @param attr *u8 — attributes, or null
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_mutex_init(m: *u8, attr: *u8): i32;

/**
 * libSystem pthread_mutex_destroy.
 * @param m *u8 — mutex from pthread_mutex_init
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_mutex_destroy(m: *u8): i32;

/**
 * libSystem pthread_mutex_lock.
 * @param m *u8 — mutex
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_mutex_lock(m: *u8): i32;

/**
 * libSystem pthread_mutex_unlock.
 * @param m *u8 — mutex
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_mutex_unlock(m: *u8): i32;

/**
 * libSystem pthread_create. start is a function pointer from dlsym,
 * never a bare function name.
 * @param t *i64 — pthread_t storage
 * @param attr *u8 — attributes, or null
 * @param start *u8 — thread start address
 * @param arg *u8 — thread argument
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_create(t: *i64, attr: *u8, start: *u8, arg: *u8): i32;

/**
 * libSystem pthread_join. The thread id is passed by value.
 * @param t i64 — pthread_t
 * @param ret *u8 — optional void* out slot; null discards it
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_join(t: i64, ret: *u8): i32;

/**
 * libSystem dlsym. RTLD_DEFAULT is the pointer value -2.
 * @param handle *u8 — RTLD_DEFAULT or a dlopen handle
 * @param name *u8 — NUL-terminated symbol, without a leading underscore
 * @return *u8 — symbol address, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlsym(handle: *u8, name: *u8): *u8;

/**
 * Worker entry defined by the shared thin. A null arg returns null.
 * @param arg *u8 — null, or the smoke state
 * @return *u8 — null
 * PLATFORM: SHARED
 */
export extern "C" function queue_os_worker_trampoline(arg: *u8): *u8;

/**
 * Darwin RTLD_DEFAULT.
 * @return *u8 — pointer value -2
 * PLATFORM: MACOS|DARWIN
 */
function queue_os_rtld_default(): *u8 {
  let n: i64 = 0 - 2;
  return n as *u8;
}

/**
 * Address of the shared trampoline. A null call keeps the symbol
 * referenced so dead_strip does not drop it. dlsym avoids using the
 * function name as a pointer value.
 * @return *u8 — trampoline, or null
 * PLATFORM: MACOS|DARWIN
 */
function queue_os_trampoline_fp(): *u8 {
  unsafe {
    queue_os_worker_trampoline(0);
    let handle: *u8 = queue_os_rtld_default();
    let name: *u8 = "queue_os_worker_trampoline";
    return dlsym(handle, name);
  }
}

/**
 * Create a mutex. Null when malloc or init fails. The caller only
 * passes this pointer back to the other queue_os_mutex functions.
 * @return *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function queue_os_mutex_create_impl(): *u8 {
  unsafe {
    let m: *u8 = malloc(64);
    if (m == 0) {
      return 0;
    }
    if (pthread_mutex_init(m, 0) != 0) {
      free(m);
      return 0;
    }
    return m;
  }
}

/**
 * Destroy and free mu. Null is a no-op.
 * @param mu *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function queue_os_mutex_destroy_impl(mu: *u8): void {
  if (mu == 0) {
    return;
  }
  unsafe {
    pthread_mutex_destroy(mu);
    free(mu);
  }
}

/**
 * Lock mu. Null is a no-op. The pthread result is ignored, matching
 * the C seed.
 * @param mu *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function queue_os_mutex_lock_impl(mu: *u8): void {
  if (mu == 0) {
    return;
  }
  unsafe {
    pthread_mutex_lock(mu);
  }
}

/**
 * Unlock mu. Null is a no-op.
 * @param mu *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function queue_os_mutex_unlock_impl(mu: *u8): void {
  if (mu == 0) {
    return;
  }
  unsafe {
    pthread_mutex_unlock(mu);
  }
}

/**
 * Start one worker. tid_out receives the pthread_t. A null start
 * pointer returns -1 and does not create a thread.
 * @param tid_out *i64 — pthread_t storage
 * @param start *u8 — trampoline address
 * @param ctx *u8 — smoke state
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
function queue_os_spawn_one(tid_out: *i64, start: *u8, ctx: *u8): i32 {
  if (start == 0 || tid_out == 0) {
    return -1;
  }
  unsafe {
    if (pthread_create(tid_out, 0, start, ctx) != 0) {
      return -1;
    }
  }
  return 0;
}

/**
 * Launch two workers on ctx and join both. The trampoline is the
 * shared queue_os_worker_trampoline. Returns -1 if lookup, spawn, or
 * join fails. A failed second spawn still joins the first.
 * @param ctx *u8 — smoke state shared by both workers
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function queue_os_run_two_workers_impl(ctx: *u8): i32 {
  let fp: *u8 = queue_os_trampoline_fp();
  if (fp == 0) {
    return -1;
  }
  let t0: i64 = 0;
  let t1: i64 = 0;
  if (queue_os_spawn_one(&t0, fp, ctx) != 0) {
    return -1;
  }
  if (queue_os_spawn_one(&t1, fp, ctx) != 0) {
    unsafe {
      pthread_join(t0, 0);
    }
    return -1;
  }
  unsafe {
    if (pthread_join(t0, 0) != 0) {
      pthread_join(t1, 0);
      return -1;
    }
    if (pthread_join(t1, 0) != 0) {
      return -1;
    }
  }
  return 0;
}
