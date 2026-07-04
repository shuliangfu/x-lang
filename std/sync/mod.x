// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// std.sync — 互斥锁与同步原语（对标 Rust std::sync::Mutex、Zig Thread.Mutex）
//
// 【文件职责】
// 对外暴露 std.sync 的 Mutex
// API：new_mutex、lock、try_lock、unlock、free_mutex。
// 互斥体句柄为不透明指针（*u8），与 std.thread
// 配合实现多线程互斥。RwLock/Once 见 P2 可选或 P3。
//
// 【所属模块/组件】
// 标准库 std.sync；用户通过 import("std.sync") 使用。依赖 core；实现见 sync.x + sync_os_glue.c +
// sync_lock_diag_tls_glue.c。Unix 链接时需 -lpthread。
extern function sync_mutex_new_c(): *u8;
extern function sync_mutex_lock_c(m: *u8): i32;
extern function sync_mutex_try_lock_c(m: *u8): i32;
extern function sync_mutex_unlock_c(m: *u8): i32;
extern function sync_mutex_free_c(m: *u8): void;
/** 创建新的互斥体；成功返回句柄（不透明指针），失败返回 0。对标
* Mutex::new()。 */
function new_mutex(): *u8 {
  unsafe {
  return sync_mutex_new_c();
  }
}
/** 加锁；阻塞直到获取。返回 0 成功，-1 失败（如 m 为
* 0）。获取后需在相同线程内调用 unlock。 */
function lock(m: *u8): i32 {
  unsafe {
  return sync_mutex_lock_c(m);
  }
}
/** 尝试加锁；不阻塞。返回 0 表示已获取，非 0 表示未获取（忙或 m 为
* 0）。 */
function try_lock(m: *u8): i32 {
  unsafe {
  return sync_mutex_try_lock_c(m);
  }
}
/** 解锁；必须在已持有锁的线程内调用。返回 0 成功，-1 失败。 */
function unlock(m: *u8): i32 {
  unsafe {
  return sync_mutex_unlock_c(m);
  }
}
/** 销毁并释放互斥体；调用后 m
* 不可再使用。不得在已加锁状态下调用（先 unlock 再 free）。 */
function free_mutex(m: *u8): void {
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

/** 创建 RwLock；失败 0。 */
function new_rwlock(): *u8 {
  unsafe {
  return sync_rwlock_new_c();
  }
}

/** 销毁 RwLock。 */
function free_rwlock(rw: *u8): void {
  unsafe {
  sync_rwlock_free_c(rw);
  }
}

/** 获取读锁；成功 0。 */
function read_lock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_read_lock_c(rw);
  }
}

/** 获取写锁；成功 0。 */
function write_lock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_write_lock_c(rw);
  }
}

/** 释放读锁；成功 0。 */
function read_unlock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_read_unlock_c(rw);
  }
}

/** 释放写锁；成功 0。 */
function write_unlock(rw: *u8): i32 {
  unsafe {
  return sync_rwlock_write_unlock_c(rw);
  }
}

/** 创建 Condvar；失败 0。 */
function new_condvar(): *u8 {
  unsafe {
  return sync_condvar_new_c();
  }
}

/** 在已持有 mutex 时等待 condvar；唤醒后重新持有 mutex。 */
function wait(cv: *u8, mutex: *u8): i32 {
  unsafe {
  return sync_condvar_wait_c(cv, mutex);
  }
}

/** 唤醒一个等待线程。 */
function notify_one(cv: *u8): i32 {
  unsafe {
  return sync_condvar_signal_c(cv);
  }
}

/** 唤醒全部等待线程。 */
function notify_all(cv: *u8): i32 {
  unsafe {
  return sync_condvar_broadcast_c(cv);
  }
}

/** 销毁 Condvar。 */
function free_condvar(cv: *u8): void {
  unsafe {
  sync_condvar_free_c(cv);
  }
}

/** RwLock 竞争烟测；成功 0。 */
function rwlock_contention_smoke(): i32 {
  unsafe {
  return sync_rwlock_contention_smoke_c();
  }
}

/** Condvar 竞争烟测；成功 0。 */
function condvar_contention_smoke(): i32 {
  unsafe {
  return sync_condvar_contention_smoke_c();
  }
}

/* --- STD-111：调试模式锁诊断 --- */

extern function sync_lock_diag_set_enabled_c(on: i32): void;
extern function sync_lock_diag_is_enabled_c(): i32;
extern function sync_lock_diag_mutex_set_id_c(m: *u8, id: i32): i32;
extern function sync_lock_diag_last_err_c(): i32;
extern function sync_lock_diag_clear_c(): void;
extern function sync_lock_diag_snapshot_c(out: *u8, cap: i32): i32;
extern function sync_lock_diag_smoke_c(): i32;

/** 递归加锁错误码 -1。 */
function lock_diag_err_recursive(): i32 { return -1; }
/** 锁序违规错误码 -2。 */
function lock_diag_err_order(): i32 { return -2; }
/** 解锁顺序错误码 -3。 */
function lock_diag_err_unlock(): i32 { return -3; }

/** 开启/关闭锁诊断。 */
function lock_diag_set_enabled(on: i32): void {
  unsafe {
  sync_lock_diag_set_enabled_c(on);
  }
}

/** 查询锁诊断是否开启。 */
function lock_diag_is_enabled(): i32 {
  unsafe {
  return sync_lock_diag_is_enabled_c();
  }
}

/** 为 mutex 绑定锁序 id。 */
function lock_diag_mutex_set_id(m: *u8, id: i32): i32 {
  unsafe {
  return sync_lock_diag_mutex_set_id_c(m, id);
  }
}

/** 最近诊断错误码。 */
function lock_diag_last_err(): i32 {
  unsafe {
  return sync_lock_diag_last_err_c();
  }
}

/** 清空诊断状态。 */
function lock_diag_clear(): void {
  unsafe {
  sync_lock_diag_clear_c();
  }
}

/** 写入文本快照；返回写入字节数。 */
function lock_diag_snapshot(out: *u8, cap: i32): i32 {
  unsafe {
  return sync_lock_diag_snapshot_c(out, cap);
  }
}

/** C 烟测门面。 */
function lock_diag_smoke(): i32 {
  unsafe {
  return sync_lock_diag_smoke_c();
  }
}
