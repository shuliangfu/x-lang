// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.
// API：new_mutex、lock、try_lock、unlock、free_mutex。
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
extern function sync_mutex_new_c(): *u8;
extern function sync_mutex_lock_c(m: *u8): i32;
extern function sync_mutex_try_lock_c(m: *u8): i32;
extern function sync_mutex_unlock_c(m: *u8): i32;
extern function sync_mutex_free_c(m: *u8): void;
/** Exported function `new_mutex`.
 * Implements `new_mutex`.
 * @return *u8
 */
export function new_mutex(): *u8 {
  unsafe {
  return sync_mutex_new_c();
  }
}
/** Exported function `lock`.
 * Implements `lock`.
 * @param m *u8
 * @return i32
 */
export function lock(m: *u8): i32 {
  unsafe {
  return sync_mutex_lock_c(m);
  }
}
/** Exported function `try_lock`.
 * Implements `try_lock`.
 * @param m *u8
 * @return i32
 */
export function try_lock(m: *u8): i32 {
  unsafe {
  return sync_mutex_try_lock_c(m);
  }
}
/** Exported function `unlock`.
 * Implements `unlock`.
 * @param m *u8
 * @return i32
 */
export function unlock(m: *u8): i32 {
  unsafe {
  return sync_mutex_unlock_c(m);
  }
}
/** Exported function `free_mutex`.
 * Memory management helper `free_mutex`.
 * @param m *u8
 * @return void
 */
export function free_mutex(m: *u8): void {
  unsafe {
  sync_mutex_free_c(m);
  }
}

/* --- STD-045：RwLock / Condvar --- */

extern function sync_rwlock_new_c(): *u8;
extern function sync_rwlock_read_lock_c(rw: *u8): i32;
extern function sync_rwlock_write_lock_c(rw: *u8): i32;
extern function sync_rwlock_read_unlock_c(rw: *u8): i32;
extern function sync_rwlock_write_unlock_c(rw: *u8): i32;
extern function sync_rwlock_free_c(rw: *u8): void;
extern function sync_condvar_new_c(): *u8;
extern function sync_condvar_wait_c(cv: *u8, mutex: *u8): i32;
extern function sync_condvar_signal_c(cv: *u8): i32;
extern function sync_condvar_broadcast_c(cv: *u8): i32;
extern function sync_condvar_free_c(cv: *u8): void;
extern function sync_rwlock_contention_smoke_c(): i32;
extern function sync_condvar_contention_smoke_c(): i32;

/** Exported function `new_rwlock`.
 * Implements `new_rwlock`.
 * @return *u8
 */
export function new_rwlock(): *u8 {
  unsafe {
  return sync_rwlock_new_c();
  }
}

/** Exported function `free_rwlock`.
 * Memory management helper `free_rwlock`.
 * @param rw *u8
 * @return void
 */
export function free_rwlock(rw: *u8): void {
  unsafe {
  sync_rwlock_free_c(rw);
  }
}

/** Exported function `read_lock`.
 * Read path helper `read_lock`.
 * @param rw *u8
 * @return i32
 */
export function read_lock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_read_lock_c(rw);
  }
}

/** Exported function `write_lock`.
 * Write path helper `write_lock`.
 * @param rw *u8
 * @return i32
 */
export function write_lock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_write_lock_c(rw);
  }
}

/** Exported function `read_unlock`.
 * Read path helper `read_unlock`.
 * @param rw *u8
 * @return i32
 */
export function read_unlock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_read_unlock_c(rw);
  }
}

/** Exported function `write_unlock`.
 * Write path helper `write_unlock`.
 * @param rw *u8
 * @return i32
 */
export function write_unlock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_write_unlock_c(rw);
  }
}

/** Exported function `new_condvar`.
 * Implements `new_condvar`.
 * @return *u8
 */
export function new_condvar(): *u8 {
  unsafe {
  return sync_condvar_new_c();
  }
}

/** Exported function `wait`.
 * Implements `wait`.
 * @param cv *u8
 * @param mutex *u8
 * @return i32
 */
export function wait(cv: *u8, mutex: *u8): i32 {
  unsafe {
  return sync_condvar_wait_c(cv, mutex);
  }
}

/** Exported function `notify_one`.
 * Implements `notify_one`.
 * @param cv *u8
 * @return i32
 */
export function notify_one(cv: *u8): i32 {
  unsafe {
  return sync_condvar_signal_c(cv);
  }
}

/** Exported function `notify_all`.
 * Implements `notify_all`.
 * @param cv *u8
 * @return i32
 */
export function notify_all(cv: *u8): i32 {
  unsafe {
  return sync_condvar_broadcast_c(cv);
  }
}

/** Exported function `free_condvar`.
 * Memory management helper `free_condvar`.
 * @param cv *u8
 * @return void
 */
export function free_condvar(cv: *u8): void {
  unsafe {
  sync_condvar_free_c(cv);
  }
}

/** Exported function `rwlock_contention_smoke`.
 * Implements `rwlock_contention_smoke`.
 * @return i32
 */
export function rwlock_contention_smoke(): i32 {
  unsafe {
  return sync_rwlock_contention_smoke_c();
  }
}

/** Exported function `condvar_contention_smoke`.
 * Implements `condvar_contention_smoke`.
 * @return i32
 */
export function condvar_contention_smoke(): i32 {
  unsafe {
  return sync_condvar_contention_smoke_c();
  }
}

/* See implementation. */

extern function sync_lock_diag_set_enabled_c(on: i32): void;
extern function sync_lock_diag_is_enabled_c(): i32;
extern function sync_lock_diag_mutex_set_id_c(m: *u8, id: i32): i32;
extern function sync_lock_diag_last_err_c(): i32;
extern function sync_lock_diag_clear_c(): void;
extern function sync_lock_diag_snapshot_c(out: *u8, cap: i32): i32;
extern function sync_lock_diag_smoke_c(): i32;

/** Exported function `lock_diag_err_recursive`.
 * Implements `lock_diag_err_recursive`.
 * @return i32
 */
export function lock_diag_err_recursive(): i32 { return -1; }
/** Exported function `lock_diag_err_order`.
 * Implements `lock_diag_err_order`.
 * @return i32
 */
export function lock_diag_err_order(): i32 { return -2; }
/** Exported function `lock_diag_err_unlock`.
 * Implements `lock_diag_err_unlock`.
 * @return i32
 */
export function lock_diag_err_unlock(): i32 { return -3; }

/** Exported function `lock_diag_set_enabled`.
 * Implements `lock_diag_set_enabled`.
 * @param on i32
 * @return void
 */
export function lock_diag_set_enabled(on: i32): void {
  unsafe {
  sync_lock_diag_set_enabled_c(on);
  }
}

/** Exported function `lock_diag_is_enabled`.
 * Implements `lock_diag_is_enabled`.
 * @return i32
 */
export function lock_diag_is_enabled(): i32 {
  unsafe {
  return sync_lock_diag_is_enabled_c();
  }
}

/** Exported function `lock_diag_mutex_set_id`.
 * Implements `lock_diag_mutex_set_id`.
 * @param m *u8
 * @param id i32
 * @return i32
 */
export function lock_diag_mutex_set_id(m: *u8, id: i32): i32 {
  unsafe {
  return sync_lock_diag_mutex_set_id_c(m, id);
  }
}

/** Exported function `lock_diag_last_err`.
 * Implements `lock_diag_last_err`.
 * @return i32
 */
export function lock_diag_last_err(): i32 {
  unsafe {
  return sync_lock_diag_last_err_c();
  }
}

/** Exported function `lock_diag_clear`.
 * Implements `lock_diag_clear`.
 * @return void
 */
export function lock_diag_clear(): void {
  unsafe {
  sync_lock_diag_clear_c();
  }
}

/** Exported function `lock_diag_snapshot`.
 * Implements `lock_diag_snapshot`.
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function lock_diag_snapshot(out: *u8, cap: i32): i32 {
  unsafe {
  return sync_lock_diag_snapshot_c(out, cap);
  }
}

/** Exported function `lock_diag_smoke`.
 * Implements `lock_diag_smoke`.
 * @return i32
 */
export function lock_diag_smoke(): i32 {
  unsafe {
  return sync_lock_diag_smoke_c();
  }
}
