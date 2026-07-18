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
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
extern function log_set_min_level_c(level: i32): void;
extern function log_write_c(level: i32, ptr: *u8, len: i32): i32;
extern function log_set_sink_mask_c(mask: i32): void;
extern function log_set_file_sink_c(path: *u8, len: i32): i32;
extern function log_close_file_sink_c(): void;
extern function log_write_structured_kv_c(comp: *u8, level: i32, kv: *u8): i32;
extern function log_set_rotate_c(max_bytes: i32, max_backups: i32): i32;
extern function log_set_async_enabled_c(enabled: i32): i32;
extern function log_async_flush_c(): i32;

/* See implementation. */
export const SINK_STDERR: i32 = 1;
/* See implementation. */
export const SINK_FILE: i32 = 2;

/** Exported function `level_debug`.
 * Implements `level_debug`.
 * @return i32
 */
export function level_debug(): i32 { return 0; }
/** Exported function `level_info`.
 * Implements `level_info`.
 * @return i32
 */
export function level_info(): i32 { return 1; }
/** Exported function `level_warn`.
 * Implements `level_warn`.
 * @return i32
 */
export function level_warn(): i32 { return 2; }
/** Exported function `level_error`.
 * Implements `level_error`.
 * @return i32
 */
export function level_error(): i32 { return 3; }

/** Exported function `set_min_level`.
 * Implements `set_min_level`.
 * @param level i32): void { unsafe { log_set_min_level_c(level
 * @return void
 */
export function set_min_level(level: i32): void { unsafe { log_set_min_level_c(level); } }

/** Exported function `set_sink_mask`.
 * Implements `set_sink_mask`.
 * @param mask i32): void { unsafe { log_set_sink_mask_c(mask
 * @return void
 */
export function set_sink_mask(mask: i32): void { unsafe { log_set_sink_mask_c(mask); } }

/** Exported function `set_file_sink`.
 * Implements `set_file_sink`.
 * @param path *u8
 * @param len i32
 * @return i32
 */
export function set_file_sink(path: *u8, len: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_set_file_sink_c(path, len); }
  return rc;
}

/** Exported function `close_file_sink`.
 * Implements `close_file_sink`.
 * @param ) void { unsafe { log_close_file_sink_c(
 * @return void
 */
export function close_file_sink(): void { unsafe { log_close_file_sink_c(); } }

/** Exported function `log`.
 * Implements `log`.
 * @param level i32
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function log(level: i32, ptr: *u8, len: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_write_c(level, ptr, len); }
  return rc;
}

/** Exported function `structured_kv`.
 * Implements `structured_kv`.
 * @param comp *u8
 * @param level i32
 * @param kv *u8
 * @return i32
 */
export function structured_kv(comp: *u8, level: i32, kv: *u8): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_write_structured_kv_c(comp, level, kv); }
  return rc;
}

/** Exported function `set_rotate_limit`.
 * Implements `set_rotate_limit`.
 * @param max_bytes i32
 * @param max_backups i32
 * @return i32
 */
export function set_rotate_limit(max_bytes: i32, max_backups: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_set_rotate_c(max_bytes, max_backups); }
  return rc;
}

/** Exported function `set_async_enabled`.
 * Implements `set_async_enabled`.
 * @param enabled i32
 * @return i32
 */
export function set_async_enabled(enabled: i32): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_set_async_enabled_c(enabled); }
  return rc;
}

/** Exported function `async_flush`.
 * Implements `async_flush`.
 * @return i32
 */
export function async_flush(): i32 {
  let rc: i32 = 0;
  unsafe { rc = log_async_flush_c(); }
  return rc;
}
