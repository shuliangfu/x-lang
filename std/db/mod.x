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
// See implementation.
//
// See implementation.
//   const db = import("std.db");          // deprecated
// See implementation.

const sqlite_m = import("std.db.sqlite");
const kv_m = import("std.db.kv");
const arrow_m = import("std.db.arrow");

/* See implementation. */
export struct DbConn {
  handle: i64;
}

extern function db_open_c(path: *u8): i64;
extern function db_close_c(handle: i64): i32;
extern function db_exec_c(handle: i64, sql: *u8): i32;
extern function db_changes_c(handle: i64): i32;

/** Exported function `is_deprecated`.
 * Query helper `is_deprecated`.
 * @return i32
 */
export function is_deprecated(): i32 {
  return 1;
}

/** Exported function `open`.
 * Implements `open`.
 * @param path *u8
 * @return DbConn
 */
export function open(path: *u8): DbConn {
  let _rc: DbConn = 0;
  unsafe { _rc = DbConn { handle: db_open_c(path) }; }
  return _rc;
}

/** Exported function `close`.
 * Implements `close`.
 * @param conn DbConn
 * @return i32
 */
export function close(conn: DbConn): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = db_close_c(conn.handle); }
  return _rc;
}

/** Exported function `exec`.
 * Implements `exec`.
 * @param conn DbConn
 * @param sql *u8
 * @return i32
 */
export function exec(conn: DbConn, sql: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = db_exec_c(conn.handle, sql); }
  return _rc;
}

/** Exported function `changes`.
 * Implements `changes`.
 * @param conn DbConn
 * @return i32
 */
export function changes(conn: DbConn): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = db_changes_c(conn.handle); }
  return _rc;
}

/** Exported function `sqlite_is_available`.
 * Implements `sqlite_is_available`.
 * @return i32
 */
export function sqlite_is_available(): i32 {
  return sqlite_m.is_available();
}

/** Exported function `kv_mmap_available`.
 * Implements `kv_mmap_available`.
 * @return i32
 */
export function kv_mmap_available(): i32 {
  return kv_m.mmap_available();
}

/** Exported function `arrow_available`.
 * Implements `arrow_available`.
 * @return i32
 */
export function arrow_available(): i32 {
  return 1;
}

/** Exported function `arrow_simd_hw_available`.
 * Implements `arrow_simd_hw_available`.
 * @return i32
 */
export function arrow_simd_hw_available(): i32 {
  return arrow_m.simd_hw_available();
}
