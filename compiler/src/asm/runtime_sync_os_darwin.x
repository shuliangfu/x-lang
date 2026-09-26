// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_sync_os_darwin.x — Darwin arm64 whole body of runtime_sync_os.o.
//
// The cold ensure path pure-asms this file and does not pass
// seeds/runtime_sync_os.from_x.c to host cc. Linux still compiles that
// seed, which inlines the futex helpers in include/xlang_sync_cap.h.
// Windows still compiles that seed, which inlines Win32 CRITICAL_SECTION.
// Those helpers are static inline, so this object cannot call them.
//
// src/asm/runtime_sync_os.x stays the shared thin: it forwards to the C
// _impl bridges. Compiling that thin still leaves the C rest on host cc.
// Darwin does not compile that thin. This file is the only Darwin body.
//
// Darwin Cap mutex, rwlock, and condvar are pthread objects. The sizes
// below match struct xlang_cap_mutex / xlang_cap_rwlock / xlang_cap_cond
// on Darwin arm64: 64, 200, and 48 bytes, with the pthread object at
// offset 0. malloc of that many bytes is the same storage the C seed
// allocates. Public _c names call the _impl in this file. Both stay strong.
//
// Lock diagnostics stay extern. They are defined by the sync companion,
// the same way the C seed declares them. This object does not define a
// second copy.
//
// A function name used as a pointer value makes this compiler exit 139.
// The condvar smoke looks the waiter up with dlsym(RTLD_DEFAULT) instead.
// RTLD_DEFAULT is the pointer value -2. The smoke also calls the waiter
// with a null argument so the symbol is a real reference and is not
// dropped by dead_strip. Darwin's Cap join ignores the waiter's return,
// so the waiter returns null on every path.
//
// Each function has one loop at most. Two loop headers in one function
// replace the length register with the compare result.
// Each function's frame must cover its slots. A slot past the frame stores
// through the caller's saved return address.
//
// This object is a user / STD_AND_PANIC companion. It is not in the g05
// compiler image. A missing object after three pure-asm faults falls back
// to the C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Two i64 words, matching Darwin arm64 struct timespec.
 * tv_sec at offset 0, tv_nsec at offset 8.
 * PLATFORM: MACOS|DARWIN arm64.
 */
struct SyncOsSpec {
  sec: i64;
  nsec: i64;
}

/**
 * Condvar smoke packet. cv and mu are the opaque heap objects.
 * ready is 0 until the parent publishes 1 under the mutex.
 * Layout is three 8-byte words, 24 bytes, matching a C struct of
 * two pointers and one i64.
 * PLATFORM: MACOS|DARWIN arm64.
 */
struct SyncSmoke {
  cv: *u8;
  mu: *u8;
  ready: i64;
}

/**
 * libSystem malloc. n is a byte count, passed as i64 so the arm64
 * register holds the full size_t bits.
 * @param n i64 — byte count; non-positive still goes to libSystem
 * @return *u8 — heap block, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * libSystem free. Null is a no-op in libSystem; callers still skip null.
 * @param p *u8 — block from malloc, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function free(p: *u8): void;

/**
 * libSystem pthread_mutex_init. attr null selects the default mutex.
 * @param m *u8 — 64-byte Darwin pthread_mutex_t
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
 * libSystem pthread_mutex_trylock. A non-zero result means busy or error.
 * @param m *u8 — mutex
 * @return i32 — 0 when acquired
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_mutex_trylock(m: *u8): i32;

/**
 * libSystem pthread_mutex_unlock.
 * @param m *u8 — mutex
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_mutex_unlock(m: *u8): i32;

/**
 * libSystem pthread_rwlock_init. attr null selects the default rwlock.
 * @param rw *u8 — 200-byte Darwin pthread_rwlock_t
 * @param attr *u8 — attributes, or null
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_rwlock_init(rw: *u8, attr: *u8): i32;

/**
 * libSystem pthread_rwlock_destroy.
 * @param rw *u8 — rwlock
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_rwlock_destroy(rw: *u8): i32;

/**
 * libSystem pthread_rwlock_rdlock.
 * @param rw *u8 — rwlock
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_rwlock_rdlock(rw: *u8): i32;

/**
 * libSystem pthread_rwlock_wrlock.
 * @param rw *u8 — rwlock
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_rwlock_wrlock(rw: *u8): i32;

/**
 * libSystem pthread_rwlock_unlock. Used for both read and write release.
 * @param rw *u8 — rwlock
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_rwlock_unlock(rw: *u8): i32;

/**
 * libSystem pthread_cond_init. attr null selects the default condvar.
 * @param cv *u8 — 48-byte Darwin pthread_cond_t
 * @param attr *u8 — attributes, or null
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_cond_init(cv: *u8, attr: *u8): i32;

/**
 * libSystem pthread_cond_destroy.
 * @param cv *u8 — condvar
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_cond_destroy(cv: *u8): i32;

/**
 * libSystem pthread_cond_wait. The caller holds mu. The wait releases
 * mu and reacquires it before returning.
 * @param cv *u8 — condvar
 * @param mu *u8 — mutex held by the caller
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_cond_wait(cv: *u8, mu: *u8): i32;

/**
 * libSystem pthread_cond_signal. Wakes one waiter.
 * @param cv *u8 — condvar
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_cond_signal(cv: *u8): i32;

/**
 * libSystem pthread_cond_broadcast. Wakes every waiter.
 * @param cv *u8 — condvar
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pthread_cond_broadcast(cv: *u8): i32;

/**
 * libSystem pthread_create. start is a function pointer from dlsym,
 * never a bare function name (that form exits 139).
 * @param t *i64 — pthread_t storage (8 bytes)
 * @param attr *u8 — attributes, or null for the default stack
 * @param start *u8 — waiter address
 * @param arg *u8 — waiter argument
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
 * libSystem nanosleep. rem may be null. EINTR is not retried.
 * @param req *i64 — first word of a SyncOsSpec
 * @param rem *i64 — remainder, or null
 * @return i32 — 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function nanosleep(req: *i64, rem: *i64): i32;

/**
 * Lock-order hook. Defined by the sync companion, not by this file.
 * @param m *u8 — mutex about to be locked
 * @return i32 — 0 to continue, non-zero to refuse
 * PLATFORM: SHARED — same symbol the C seed calls
 */
export extern "C" function sync_lock_diag_before_lock(m: *u8): i32;

/**
 * Lock-order hook after a successful lock.
 * @param m *u8 — mutex now held
 * PLATFORM: SHARED
 */
export extern "C" function sync_lock_diag_after_lock(m: *u8): void;

/**
 * Lock-order hook before unlock.
 * @param m *u8 — mutex about to be released
 * @return i32 — 0 to continue, non-zero to refuse
 * PLATFORM: SHARED
 */
export extern "C" function sync_lock_diag_before_unlock(m: *u8): i32;

/**
 * Lock-order hook after a successful unlock.
 * @param m *u8 — mutex now released
 * PLATFORM: SHARED
 */
export extern "C" function sync_lock_diag_after_unlock(m: *u8): void;

/**
 * Read path helper for codegen discovery.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_sync_os_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Darwin RTLD_DEFAULT. dlsym searches the process with this handle.
 * @return *u8 — pointer value -2
 * PLATFORM: MACOS|DARWIN
 */
function sync_os_rtld_default(): *u8 {
  let n: i64 = 0 - 2;
  return n as *u8;
}

/**
 * Sleep 20 milliseconds. One nanosleep, matching the C smoke's pause
 * before it publishes the condvar flag. Split out so the smoke frame
 * does not also hold the timespec.
 * PLATFORM: MACOS|DARWIN
 */
function sync_os_sleep_20ms(): void {
  let req: SyncOsSpec = { sec: 0, nsec: 0 };
  req.sec = 0;
  req.nsec = 20000000;
  unsafe {
    nanosleep(&req.sec, 0);
  }
}

/**
 * Allocate a mutex and init it. 64 bytes is sizeof(pthread_mutex_t)
 * and sizeof(struct xlang_cap_mutex) on Darwin arm64.
 * @return *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_new_impl(): *u8 {
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
 * Create a mutex. Same body as sync_mutex_new_impl.
 * @return *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_new_c(): *u8 {
  return sync_mutex_new_impl();
}

/**
 * Lock m. Diagnostics run around the pthread call, as in the C seed.
 * A refused diagnostic does not lock. A failed pthread lock does not
 * call the after-lock hook.
 * @param m *u8 — opaque mutex; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_lock_impl(m: *u8): i32 {
  if (m == 0) {
    return 0 - 1;
  }
  unsafe {
    if (sync_lock_diag_before_lock(m) != 0) {
      return 0 - 1;
    }
    if (pthread_mutex_lock(m) != 0) {
      return 0 - 1;
    }
    sync_lock_diag_after_lock(m);
  }
  return 0;
}

/**
 * Lock m. Same body as sync_mutex_lock_impl.
 * @param m *u8 — opaque mutex; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_lock_c(m: *u8): i32 {
  return sync_mutex_lock_impl(m);
}

/**
 * Try to lock m without waiting. Busy returns 1, matching the C seed.
 * A refused diagnostic returns -1 and does not lock.
 * @param m *u8 — opaque mutex; null returns -1
 * @return i32 — 0 acquired, 1 busy, -1 refused or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_try_lock_impl(m: *u8): i32 {
  if (m == 0) {
    return 0 - 1;
  }
  unsafe {
    if (sync_lock_diag_before_lock(m) != 0) {
      return 0 - 1;
    }
    if (pthread_mutex_trylock(m) != 0) {
      return 1;
    }
    sync_lock_diag_after_lock(m);
  }
  return 0;
}

/**
 * Try to lock m. Same body as sync_mutex_try_lock_impl.
 * @param m *u8 — opaque mutex; null returns -1
 * @return i32 — 0 acquired, 1 busy, -1 refused or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_try_lock_c(m: *u8): i32 {
  return sync_mutex_try_lock_impl(m);
}

/**
 * Unlock m. A refused diagnostic does not unlock.
 * @param m *u8 — opaque mutex; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_unlock_impl(m: *u8): i32 {
  if (m == 0) {
    return 0 - 1;
  }
  unsafe {
    if (sync_lock_diag_before_unlock(m) != 0) {
      return 0 - 1;
    }
    if (pthread_mutex_unlock(m) != 0) {
      return 0 - 1;
    }
    sync_lock_diag_after_unlock(m);
  }
  return 0;
}

/**
 * Unlock m. Same body as sync_mutex_unlock_impl.
 * @param m *u8 — opaque mutex; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_unlock_c(m: *u8): i32 {
  return sync_mutex_unlock_impl(m);
}

/**
 * Destroy and free m. Null is a no-op.
 * @param m *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_free_impl(m: *u8): void {
  if (m == 0) {
    return;
  }
  unsafe {
    pthread_mutex_destroy(m);
    free(m);
  }
}

/**
 * Destroy and free m. Same body as sync_mutex_free_impl.
 * @param m *u8 — opaque mutex, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_mutex_free_c(m: *u8): void {
  sync_mutex_free_impl(m);
}

/**
 * Allocate an rwlock and init it. 200 bytes is sizeof(pthread_rwlock_t)
 * and sizeof(struct xlang_cap_rwlock) on Darwin arm64.
 * @return *u8 — opaque rwlock, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_new_impl(): *u8 {
  unsafe {
    let rw: *u8 = malloc(200);
    if (rw == 0) {
      return 0;
    }
    if (pthread_rwlock_init(rw, 0) != 0) {
      free(rw);
      return 0;
    }
    return rw;
  }
}

/**
 * Create an rwlock. Same body as sync_rwlock_new_impl.
 * @return *u8 — opaque rwlock, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_new_c(): *u8 {
  return sync_rwlock_new_impl();
}

/**
 * Acquire the shared lock.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_read_lock_impl(rw: *u8): i32 {
  if (rw == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_rwlock_rdlock(rw) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Acquire the shared lock. Same body as sync_rwlock_read_lock_impl.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_read_lock_c(rw: *u8): i32 {
  return sync_rwlock_read_lock_impl(rw);
}

/**
 * Acquire the exclusive lock.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_write_lock_impl(rw: *u8): i32 {
  if (rw == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_rwlock_wrlock(rw) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Acquire the exclusive lock. Same body as sync_rwlock_write_lock_impl.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_write_lock_c(rw: *u8): i32 {
  return sync_rwlock_write_lock_impl(rw);
}

/**
 * Release a shared lock.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_read_unlock_impl(rw: *u8): i32 {
  if (rw == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_rwlock_unlock(rw) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Release a shared lock. Same body as sync_rwlock_read_unlock_impl.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_read_unlock_c(rw: *u8): i32 {
  return sync_rwlock_read_unlock_impl(rw);
}

/**
 * Release an exclusive lock.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_write_unlock_impl(rw: *u8): i32 {
  if (rw == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_rwlock_unlock(rw) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Release an exclusive lock. Same body as sync_rwlock_write_unlock_impl.
 * @param rw *u8 — opaque rwlock; null returns -1
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_write_unlock_c(rw: *u8): i32 {
  return sync_rwlock_write_unlock_impl(rw);
}

/**
 * Destroy and free rw. Null is a no-op.
 * @param rw *u8 — opaque rwlock, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_free_impl(rw: *u8): void {
  if (rw == 0) {
    return;
  }
  unsafe {
    pthread_rwlock_destroy(rw);
    free(rw);
  }
}

/**
 * Destroy and free rw. Same body as sync_rwlock_free_impl.
 * @param rw *u8 — opaque rwlock, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_free_c(rw: *u8): void {
  sync_rwlock_free_impl(rw);
}

/**
 * Allocate a condvar and init it. 48 bytes is sizeof(pthread_cond_t)
 * and sizeof(struct xlang_cap_cond) on Darwin arm64.
 * @return *u8 — opaque condvar, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_new_impl(): *u8 {
  unsafe {
    let cv: *u8 = malloc(48);
    if (cv == 0) {
      return 0;
    }
    if (pthread_cond_init(cv, 0) != 0) {
      free(cv);
      return 0;
    }
    return cv;
  }
}

/**
 * Create a condvar. Same body as sync_condvar_new_impl.
 * @return *u8 — opaque condvar, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_new_c(): *u8 {
  return sync_condvar_new_impl();
}

/**
 * Wait on cv while holding mutex. Null arguments return -1.
 * @param cv *u8 — opaque condvar
 * @param mutex *u8 — opaque mutex held by the caller
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_wait_impl(cv: *u8, mutex: *u8): i32 {
  if (cv == 0) {
    return 0 - 1;
  }
  if (mutex == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_cond_wait(cv, mutex) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Wait on cv. Same body as sync_condvar_wait_impl.
 * @param cv *u8 — opaque condvar
 * @param mutex *u8 — opaque mutex held by the caller
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_wait_c(cv: *u8, mutex: *u8): i32 {
  return sync_condvar_wait_impl(cv, mutex);
}

/**
 * Wake one waiter. Null returns -1.
 * @param cv *u8 — opaque condvar
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_signal_impl(cv: *u8): i32 {
  if (cv == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_cond_signal(cv) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Wake one waiter. Same body as sync_condvar_signal_impl.
 * @param cv *u8 — opaque condvar
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_signal_c(cv: *u8): i32 {
  return sync_condvar_signal_impl(cv);
}

/**
 * Wake every waiter. Null returns -1.
 * @param cv *u8 — opaque condvar
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_broadcast_impl(cv: *u8): i32 {
  if (cv == 0) {
    return 0 - 1;
  }
  unsafe {
    if (pthread_cond_broadcast(cv) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Wake every waiter. Same body as sync_condvar_broadcast_impl.
 * @param cv *u8 — opaque condvar
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_broadcast_c(cv: *u8): i32 {
  return sync_condvar_broadcast_impl(cv);
}

/**
 * Destroy and free cv. Null is a no-op.
 * @param cv *u8 — opaque condvar, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_free_impl(cv: *u8): void {
  if (cv == 0) {
    return;
  }
  unsafe {
    pthread_cond_destroy(cv);
    free(cv);
  }
}

/**
 * Destroy and free cv. Same body as sync_condvar_free_impl.
 * @param cv *u8 — opaque condvar, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_free_c(cv: *u8): void {
  sync_condvar_free_impl(cv);
}

/**
 * Address of a SyncSmoke as a byte pointer for pthread_create.
 * The address of the first field is not itself a *u8.
 * @param p *SyncSmoke — packet living in the parent frame
 * @return *u8 — same address
 * PLATFORM: MACOS|DARWIN
 */
function sync_os_pack_ptr(p: *SyncSmoke): *u8 {
  return p as *u8;
}

/**
 * Condvar smoke waiter. arg null returns immediately so the parent can
 * reference this symbol without starting a wait. Otherwise arg is a
 * SyncSmoke. The waiter locks, waits until ready is non-zero, and unlocks.
 * One loop. The parent join ignores this return on Darwin.
 * @param arg *u8 — null, or the address of a SyncSmoke
 * @return *u8 — null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_os_cond_waiter(arg: *u8): *u8 {
  if (arg == 0) {
    return 0;
  }
  let s: *SyncSmoke = arg as *SyncSmoke;
  if (sync_mutex_lock_c(s.mu) != 0) {
    return 0;
  }
  // One loop. The bound is the ready flag, reloaded each header.
  while (s.ready == 0) {
    if (sync_condvar_wait_c(s.cv, s.mu) != 0) {
      sync_mutex_unlock_c(s.mu);
      return 0;
    }
  }
  sync_mutex_unlock_c(s.mu);
  return 0;
}

/**
 * Take and drop the write lock 1000 times. Success is a count of 1000.
 * One loop. No second loop header in this function.
 * @return i32 — 0 on success, 1 if create fails, 2 if the count is short
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_rwlock_contention_smoke_c(): i32 {
  let rw: *u8 = sync_rwlock_new_c();
  if (rw == 0) {
    return 1;
  }
  let i: i32 = 0;
  let counter: i32 = 0;
  while (i < 1000) {
    sync_rwlock_write_lock_c(rw);
    counter = counter + 1;
    sync_rwlock_write_unlock_c(rw);
    i = i + 1;
  }
  sync_rwlock_free_c(rw);
  if (counter == 1000) {
    return 0;
  }
  return 2;
}

/**
 * Cross-thread condvar smoke. The waiter is found with dlsym because a
 * bare function name used as a pointer exits 139. A direct null call keeps
 * the waiter in the link. Returns 0 when the parent publishes ready and
 * joins the waiter. 1 means create failed, 2 means spawn failed, 3 means
 * the parent lock failed, 4 means join failed.
 * @return i32 — 0 on success, otherwise 1 through 4
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function sync_condvar_contention_smoke_c(): i32 {
  // Real reference. dead_strip keeps the waiter. Null returns at once.
  sync_os_cond_waiter(0);
  let cv: *u8 = sync_condvar_new_c();
  let mu: *u8 = sync_mutex_new_c();
  if (cv == 0) {
    sync_condvar_free_c(cv);
    sync_mutex_free_c(mu);
    return 1;
  }
  if (mu == 0) {
    sync_condvar_free_c(cv);
    sync_mutex_free_c(mu);
    return 1;
  }
  let pack: SyncSmoke = { cv: 0, mu: 0, ready: 0 };
  pack.cv = cv;
  pack.mu = mu;
  pack.ready = 0;
  let tid: i64 = 0;
  let slot: *i64 = &tid;
  let raw: *u8 = sync_os_pack_ptr(&pack);
  unsafe {
    let handle: *u8 = sync_os_rtld_default();
    let name: *u8 = "sync_os_cond_waiter";
    let fp: *u8 = dlsym(handle, name);
    if (fp == 0) {
      sync_condvar_free_c(cv);
      sync_mutex_free_c(mu);
      return 2;
    }
    if (pthread_create(slot, 0, fp, raw) != 0) {
      sync_condvar_free_c(cv);
      sync_mutex_free_c(mu);
      return 2;
    }
  }
  sync_os_sleep_20ms();
  if (sync_mutex_lock_c(mu) != 0) {
    unsafe {
      pthread_join(tid, 0);
    }
    sync_condvar_free_c(cv);
    sync_mutex_free_c(mu);
    return 3;
  }
  pack.ready = 1;
  sync_condvar_signal_c(cv);
  sync_mutex_unlock_c(mu);
  unsafe {
    if (pthread_join(tid, 0) != 0) {
      sync_condvar_free_c(cv);
      sync_mutex_free_c(mu);
      return 4;
    }
  }
  sync_condvar_free_c(cv);
  sync_mutex_free_c(mu);
  return 0;
}
