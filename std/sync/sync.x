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
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

export const SYNC_LOCK_DIAG_ERR_RECURSIVE: i32 = -1;
export const SYNC_LOCK_DIAG_ERR_ORDER: i32 = -2;
export const SYNC_LOCK_DIAG_ERR_UNLOCK: i32 = -3;
export const SYNC_LOCK_DIAG_ERR_TABLE: i32 = -4;
export const SYNC_LOCK_DIAG_MAX_META: i32 = 64;

/* See implementation. */
extern function sync_lock_diag_tls_push_c(m: *u8, order_id: i32): i32;
extern function sync_lock_diag_tls_pop_c(): void;
extern function sync_lock_diag_tls_has_c(m: *u8): i32;
extern function sync_lock_diag_tls_max_order_c(): i32;
extern function sync_lock_diag_tls_count_c(): i32;
extern function sync_lock_diag_tls_clear_c(): void;

/* See implementation. */
extern function sync_lock_diag_before_lock(m: *u8): i32;
extern function sync_lock_diag_after_lock(m: *u8): void;
extern function sync_lock_diag_before_unlock(m: *u8): i32;
extern function sync_lock_diag_after_unlock(m: *u8): void;

/* See implementation. */
extern function sync_lock_diag_set_enabled_c(on: i32): void;
extern function sync_lock_diag_is_enabled_c(): i32;
extern function sync_lock_diag_mutex_set_id_c(m: *u8, id: i32): i32;
extern function sync_lock_diag_last_err_c(): i32;
extern function sync_lock_diag_clear_c(): void;
extern function sync_lock_diag_snapshot_c(out: *u8, cap: i32): i32;
extern function sync_lock_diag_smoke_c(): i32;

/** Exported function `sync_f_sync_v1_marker_c`.
 * Implements `sync_f_sync_v1_marker_c`.
 * @return i32
 */
export function sync_f_sync_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `sync_f_sync_lock_diag_v2_marker_c`.
 * Implements `sync_f_sync_lock_diag_v2_marker_c`.
 * @return i32
 */
export function sync_f_sync_lock_diag_v2_marker_c(): i32 {
  return 1;
}
