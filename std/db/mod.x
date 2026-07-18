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

// std.db — 数据库与存储门面（sqlite / kv / arrow）
//
// 【子模块】
// - std.db.sqlite — SQLite3（SQL 关系型，可选 -lsqlite3）
// - std.db.kv     — mmap LSM Append-Only 键值/时序底座（无 SQL）
// - std.db.arrow  — 零拷贝列式内存（Apache Arrow 风格布局）
//
// 【STD-120 兼容层】
// `import("std.db")` 仍可用但已废弃；open/exec/close/changes 转发 std.db.sqlite，
// 与 std/db/sqlite/sqlite.o 共享 C 实现（db_open_c 等符号）。
//
// 【用法】
//   const db = import("std.db");          // deprecated
//   const sqlite = import("std.db.sqlite"); // 推荐

const sqlite_m = import("std.db.sqlite");
const kv_m = import("std.db.kv");
const arrow_m = import("std.db.arrow");

/** 不透明连接句柄（与 std.db.sqlite.DbConn 布局一致）。 */
export struct DbConn {
  handle: i64;
}

extern function db_open_c(path: *u8): i64;
extern function db_close_c(handle: i64): i32;
extern function db_exec_c(handle: i64, sql: *u8): i32;
extern function db_changes_c(handle: i64): i32;

/** STD-120：import("std.db") 已废弃；恒 1。 */
export function is_deprecated(): i32 {
  return 1;
}

/** 打开数据库（转发 std.db.sqlite / db_open_c）。 */
export function open(path: *u8): DbConn {
  let _rc: DbConn = 0;
  unsafe { _rc = DbConn { handle: db_open_c(path) }; }
  return _rc;
}

/** 关闭连接。 */
export function close(conn: DbConn): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = db_close_c(conn.handle); }
  return _rc;
}

/** 执行无结果集 SQL。 */
export function exec(conn: DbConn, sql: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = db_exec_c(conn.handle, sql); }
  return _rc;
}

/** 最近一次 exec 影响行数。 */
export function changes(conn: DbConn): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = db_changes_c(conn.handle); }
  return _rc;
}

/** SQLite 后端是否可用（委托 std.db.sqlite）。 */
export function sqlite_is_available(): i32 {
  return sqlite_m.is_available();
}

/** KV mmap 引擎是否导出（委托 std.db.kv）。 */
export function kv_mmap_available(): i32 {
  return kv_m.mmap_available();
}

/** Arrow 列式模块是否导出（恒 1）。 */
export function arrow_available(): i32 {
  return 1;
}

/** SIMD 是否可用于 Arrow 列计算（委托 std.db.arrow）。 */
export function arrow_simd_hw_available(): i32 {
  return arrow_m.simd_hw_available();
}
