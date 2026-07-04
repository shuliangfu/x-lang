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

// std.db.sqlite.sqlite — F-05 v3：SQLite3 后端与 stub 回退
//
// 【文件职责】
// db_open_c / db_close_c / db_exec_c / 事务 API；stmt 缓存；连接池；全量烟测。
// libsqlite3 调用见 sqlite_glue.c；无后端时 shu_db_use_sqlite3_c()==0 走 stub。
//
// 【所属模块】标准库 std.db.sqlite；与 std/db/sqlite/mod.x 同属一模块。

const DB_OK: i32 = 0;
const DB_ERR_NULL: i32 = -1;
const DB_ERR_OPEN: i32 = -2;
const DB_ERR_EXEC: i32 = -3;
const DB_ERR_BUSY: i32 = -4;
const DB_NOT_IMPL: i32 = -9;

const SHU_SQLITE_OK: i32 = 0;
const SHU_SQLITE_ROW: i32 = 100;
const SHU_SQLITE_DONE: i32 = 101;

const DB_STMT_CACHE_CAP: i32 = 16;
const DB_STMT_SQL_MAX: i32 = 240;
const DB_POOL_SLOT_MAX: i32 = 8;
const DB_POOL_PATH_MAX: i32 = 512;
const DB_ERR_MSG_MAX: i32 = 160;

/** C 字符串常量（解析器不支持 &SQL_LIT_EMPTY[0] as *u8）。 */
const SQL_LIT_ALICE: u8[6] = [97, 108, 105, 99, 101, 0];
const SQL_LIT_ALPHA: u8[6] = [97, 108, 112, 104, 97, 0];
const SQL_LIT_BAD_OFFSET: u8[11] = [98, 97, 100, 32, 111, 102, 102, 115, 101, 116, 0];
const SQL_LIT_BEGIN_IMMEDIATE: u8[17] = [66, 69, 71, 73, 78, 32, 73, 77, 77, 69, 68, 73, 65, 84, 69, 59, 0];
const SQL_LIT_BETA: u8[5] = [98, 101, 116, 97, 0];
const SQL_LIT_BIND_IDX: u8[9] = [98, 105, 110, 100, 32, 105, 100, 120, 0];
const SQL_LIT_BOB: u8[4] = [98, 111, 98, 0];
const SQL_LIT_BUF_SMALL: u8[10] = [98, 117, 102, 32, 115, 109, 97, 108, 108, 0];
const SQL_LIT_COL_INDEX: u8[10] = [99, 111, 108, 32, 105, 110, 100, 101, 120, 0];
const SQL_LIT_COMMIT: u8[8] = [67, 79, 77, 77, 73, 84, 59, 0];
const SQL_LIT_CREATE_TABLE_T_DATA_BLOB: u8[27] = [67, 82, 69, 65, 84, 69, 32, 84, 65, 66, 76, 69, 32, 116, 40, 100, 97, 116, 97, 32, 66, 76, 79, 66, 41, 59, 0];
const SQL_LIT_CREATE_TABLE_T_K_INTEGER: u8[27] = [67, 82, 69, 65, 84, 69, 32, 84, 65, 66, 76, 69, 32, 116, 40, 107, 32, 73, 78, 84, 69, 71, 69, 82, 41, 59, 0];
const SQL_LIT_CREATE_TABLE_T_K_INTEGER_DATA_BLOB: u8[38] = [67, 82, 69, 65, 84, 69, 32, 84, 65, 66, 76, 69, 32, 116, 40, 107, 32, 73, 78, 84, 69, 71, 69, 82, 44, 32, 100, 97, 116, 97, 32, 66, 76, 79, 66, 41, 59, 0];
const SQL_LIT_CREATE_TABLE_T_K_INTEGER_NAME_TEXT: u8[38] = [67, 82, 69, 65, 84, 69, 32, 84, 65, 66, 76, 69, 32, 116, 40, 107, 32, 73, 78, 84, 69, 71, 69, 82, 44, 32, 110, 97, 109, 101, 32, 84, 69, 88, 84, 41, 59, 0];
const SQL_LIT_EMPTY: u8[4] = [39, 41, 59, 0];
const SQL_LIT_EXEC_FAILED: u8[12] = [101, 120, 101, 99, 32, 102, 97, 105, 108, 101, 100, 0];
const SQL_LIT_FINALIZE_FAILED: u8[16] = [102, 105, 110, 97, 108, 105, 122, 101, 32, 102, 97, 105, 108, 101, 100, 0];
const SQL_LIT_INSERT_INTO_T_DATA_VALUES_X: u8[31] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 100, 97, 116, 97, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 120, 39, 0];
const SQL_LIT_INSERT_INTO_T_K_DATA_VALUES_1_X_010203: u8[44] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44, 100, 97, 116, 97, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 49, 44, 120, 39, 48, 49, 48, 50, 48, 51, 39, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_DATA_VALUES_2_X_0A0B0C0D: u8[46] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44, 100, 97, 116, 97, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 50, 44, 120, 39, 48, 97, 48, 98, 48, 99, 48, 100, 39, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_NAME_VALUES: u8[35] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44, 110, 97, 109, 101, 41, 32, 86, 65, 76, 85, 69, 83, 40, 63, 44, 63, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_NAME_VALUES_1_ALPHA: u8[42] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44, 110, 97, 109, 101, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 49, 44, 39, 97, 108, 112, 104, 97, 39, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_NAME_VALUES_2_BETA: u8[41] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44, 110, 97, 109, 101, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 50, 44, 39, 98, 101, 116, 97, 39, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_VALUES_1: u8[29] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 49, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_VALUES_2: u8[29] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 50, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_VALUES_42: u8[30] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 52, 50, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_VALUES_42_NOSPACE: u8[29] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 41, 32, 86, 65, 76, 85, 69, 83, 40, 52, 50, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_VALUES_7: u8[29] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 55, 41, 59, 0];
const SQL_LIT_INSERT_INTO_T_K_VALUES_99: u8[30] = [73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 57, 57, 41, 59, 0];
const SQL_LIT_MEMORY: u8[9] = [58, 109, 101, 109, 111, 114, 121, 58, 0];
const SQL_LIT_NULL_BUF: u8[9] = [110, 117, 108, 108, 32, 98, 117, 102, 0];
const SQL_LIT_NULL_CONN: u8[10] = [110, 117, 108, 108, 32, 99, 111, 110, 110, 0];
const SQL_LIT_NULL_CURSOR: u8[12] = [110, 117, 108, 108, 32, 99, 117, 114, 115, 111, 114, 0];
const SQL_LIT_NULL_HANDLE: u8[12] = [110, 117, 108, 108, 32, 104, 97, 110, 100, 108, 101, 0];
const SQL_LIT_NULL_PATH: u8[10] = [110, 117, 108, 108, 32, 112, 97, 116, 104, 0];
const SQL_LIT_NULL_POOL: u8[10] = [110, 117, 108, 108, 32, 112, 111, 111, 108, 0];
const SQL_LIT_NULL_SQL: u8[9] = [110, 117, 108, 108, 32, 115, 113, 108, 0];
const SQL_LIT_NULL_STMT: u8[10] = [110, 117, 108, 108, 32, 115, 116, 109, 116, 0];
const SQL_LIT_POOL_ALLOC: u8[11] = [112, 111, 111, 108, 32, 97, 108, 108, 111, 99, 0];
const SQL_LIT_POOL_EXHAUSTED: u8[15] = [112, 111, 111, 108, 32, 101, 120, 104, 97, 117, 115, 116, 101, 100, 0];
const SQL_LIT_POOL_IN_USE: u8[12] = [112, 111, 111, 108, 32, 105, 110, 32, 117, 115, 101, 0];
const SQL_LIT_QUERY_FAILED: u8[13] = [113, 117, 101, 114, 121, 32, 102, 97, 105, 108, 101, 100, 0];
const SQL_LIT_ROLLBACK: u8[10] = [82, 79, 76, 76, 66, 65, 67, 75, 59, 0];
const SQL_LIT_SELECT_1: u8[10] = [83, 69, 76, 69, 67, 84, 32, 49, 59, 0];
const SQL_LIT_SELECT_DATA_FROM_T: u8[20] = [83, 69, 76, 69, 67, 84, 32, 100, 97, 116, 97, 32, 70, 82, 79, 77, 32, 116, 59, 0];
const SQL_LIT_SELECT_DATA_FROM_T_ORDER_BY_K: u8[31] = [83, 69, 76, 69, 67, 84, 32, 100, 97, 116, 97, 32, 70, 82, 79, 77, 32, 116, 32, 79, 82, 68, 69, 82, 32, 66, 89, 32, 107, 59, 0];
const SQL_LIT_SELECT_K_FROM_T: u8[17] = [83, 69, 76, 69, 67, 84, 32, 107, 32, 70, 82, 79, 77, 32, 116, 59, 0];
const SQL_LIT_SELECT_K_FROM_T_ORDER_BY_K: u8[28] = [83, 69, 76, 69, 67, 84, 32, 107, 32, 70, 82, 79, 77, 32, 116, 32, 79, 82, 68, 69, 82, 32, 66, 89, 32, 107, 59, 0];
const SQL_LIT_SELECT_K_FROM_T_WHERE_K_1: u8[27] = [83, 69, 76, 69, 67, 84, 32, 107, 32, 70, 82, 79, 77, 32, 116, 32, 87, 72, 69, 82, 69, 32, 107, 61, 49, 59, 0];
const SQL_LIT_SELECT_NAME_FROM_T_ORDER_BY_K: u8[31] = [83, 69, 76, 69, 67, 84, 32, 110, 97, 109, 101, 32, 70, 82, 79, 77, 32, 116, 32, 79, 82, 68, 69, 82, 32, 66, 89, 32, 107, 59, 0];
const SQL_LIT_SELECT_NAME_FROM_T_WHERE_K: u8[30] = [83, 69, 76, 69, 67, 84, 32, 110, 97, 109, 101, 32, 70, 82, 79, 77, 32, 116, 32, 87, 72, 69, 82, 69, 32, 107, 61, 63, 59, 0];
const SQL_LIT_SQLITE3: u8[8] = [115, 113, 108, 105, 116, 101, 51, 0];
const SQL_LIT_SQLITE3_OPEN_FAILED: u8[20] = [115, 113, 108, 105, 116, 101, 51, 95, 111, 112, 101, 110, 32, 102, 97, 105, 108, 101, 100, 0];
const SQL_LIT_SQL_TOO_LONG_FOR_CACHE: u8[23] = [115, 113, 108, 32, 116, 111, 111, 32, 108, 111, 110, 103, 32, 102, 111, 114, 32, 99, 97, 99, 104, 101, 0];
const SQL_LIT_STUB: u8[5] = [115, 116, 117, 98, 0];
const SQL_LIT_STUB_BACKEND: u8[13] = [115, 116, 117, 98, 32, 98, 97, 99, 107, 101, 110, 100, 0];

/** 线程局部错误快照（v1 原型用进程静态缓冲）。 */
allow(padding) struct DbErrSlot {
  code: i32;
  msg: u8[160];
}

/** 连接级预编译语句缓存项。 */
allow(padding) struct DbCachedStmt {
  conn: i64;
  sql: u8[240];
  stmt: i64;
}

/** 连接池堆对象（与 C db_pool_t ABI 一致）。 */
allow(padding) struct DbPoolMem {
  path: u8[512];
  max_conns: i32;
  live_count: i32;
  idle_count: i32;
  idle: i64[8];
}

let g_db_last_err_bytes: u8[168] = [];
let g_db_last_err: *DbErrSlot = &g_db_last_err_bytes[0] as *DbErrSlot;
let g_db_stmt_cache_bytes: u8[4224] = [];

/** 返回语句缓存槽 i 的指针（4224 = 16 × 264 字节/槽）。 */
function db_stmt_cache_slot(i: i32): *DbCachedStmt {
  return (&g_db_stmt_cache_bytes[(i * 264) as i32] as *DbCachedStmt);
}

extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern function memcmp(a: *u8, b: *u8, n: usize): i32;
extern function memset(s: *u8, c: i32, n: usize): *u8;
extern function calloc(nmemb: usize, size: usize): *u8;
extern function free(ptr: *u8): void;
extern function malloc(size: usize): *u8;
extern function snprintf(buf: *u8, size: usize, fmt: *u8): i32;
extern function strlen(s: *u8): usize;

extern function shu_db_use_sqlite3_c(): i32;
extern function shu_sqlite3_open_c(path: *u8, out_db: *i64): i32;
extern function shu_sqlite3_close_c(db_h: i64): i32;
extern function shu_sqlite3_exec_c(db_h: i64, sql: *u8, out_errmsg: *i64): i32;
extern function shu_sqlite3_exec_count_c(db_h: i64, sql: *u8, out_count: *i32, out_errmsg: *i64): i32;
extern function shu_sqlite3_prepare_v2_c(db_h: i64, sql: *u8, out_stmt: *i64): i32;
extern function shu_sqlite3_step_c(stmt_h: i64): i32;
extern function shu_sqlite3_finalize_c(stmt_h: i64): i32;
extern function shu_sqlite3_reset_c(stmt_h: i64): i32;
extern function shu_sqlite3_clear_bindings_c(stmt_h: i64): i32;
extern function shu_sqlite3_column_count_c(stmt_h: i64): i32;
extern function shu_sqlite3_column_int_c(stmt_h: i64, col: i32): i32;
extern function shu_sqlite3_column_text_c(stmt_h: i64, col: i32): i64;
extern function shu_sqlite3_column_blob_c(stmt_h: i64, col: i32): i64;
extern function shu_sqlite3_column_bytes_c(stmt_h: i64, col: i32): i32;
extern function shu_sqlite3_bind_int_c(stmt_h: i64, idx: i32, val: i32): i32;
extern function shu_sqlite3_bind_text_c(stmt_h: i64, idx: i32, text: *u8): i32;
extern function shu_sqlite3_errmsg_c(db_h: i64): i64;
extern function shu_sqlite3_db_handle_c(stmt_h: i64): i64;
extern function shu_sqlite3_changes_c(db_h: i64): i32;
extern function shu_sqlite3_free_c(ptr: i64): void;

/** 设置最后一次库错误码与消息（截断至 159 字节）。 */
function db_set_err(code: i32, msg: *u8): void {
  let i: i32 = 0;
  g_db_last_err.code = code;
  if (msg == 0 || msg[0] == 0) {
    g_db_last_err.msg[0] = 0;
    return;
  }
  while (i < 159 && msg[i] != 0) {
    g_db_last_err.msg[i] = msg[i];
    i = i + 1;
  }
  g_db_last_err.msg[i] = 0;
}

/** 清除错误槽。 */
function db_clear_err(): void {
  g_db_last_err.code = DB_OK;
  g_db_last_err.msg[0] = 0;
}

/** C 串相等比较。 */
function db_str_eq(a: *u8, b: *u8): i32 {
  let i: usize = 0;
  if (a == 0 || b == 0) { return 0; }
  while (a[i] != 0 && b[i] != 0) {
    if (a[i] != b[i]) { return 0; }
    i = i + 1;
  }
  return a[i] == b[i] ? 1 : 0;
}

/** 拷贝 C 串到固定缓冲（cap 含 NUL）。 */
function db_str_copy(dst: *u8, cap: i32, src: *u8): void {
  let i: i32 = 0;
  if (dst == 0 || cap <= 0) { return; }
  if (src == 0) { dst[0] = 0; return; }
  while (i < cap - 1 && src[i] != 0) {
    dst[i] = src[i];
    i = i + 1;
  }
  dst[i] = 0;
}

/** 释放指定连接上的全部缓存语句。 */
function db_stmt_cache_drop_conn(conn: i64): void {
  let i: i32 = 0;
  let slot: *DbCachedStmt = 0 as *DbCachedStmt;
  while (i < DB_STMT_CACHE_CAP) {
    slot = db_stmt_cache_slot(i);
    if (slot.conn == conn && slot.stmt != 0 as i64) {
      unsafe { shu_sqlite3_finalize_c(slot.stmt); }
      slot.conn = 0;
      slot.sql[0] = 0;
      slot.stmt = 0;
    }
    i = i + 1;
  }
}

/** 按连接 + SQL 查找缓存项。 */
function db_stmt_cache_find(conn: i64, sql: *u8): *DbCachedStmt {
  let i: i32 = 0;
  let slot: *DbCachedStmt = 0 as *DbCachedStmt;
  while (i < DB_STMT_CACHE_CAP) {
    slot = db_stmt_cache_slot(i);
    if (slot.conn == conn && slot.stmt != 0 as i64 &&
        db_str_eq(&slot.sql[0], sql) != 0) {
      return slot;
    }
    i = i + 1;
  }
  return 0;
}

/** 分配缓存槽；满则驱逐首项。 */
function db_stmt_cache_alloc_slot(): *DbCachedStmt {
  let i: i32 = 0;
  let slot: *DbCachedStmt = 0 as *DbCachedStmt;
  while (i < DB_STMT_CACHE_CAP) {
    slot = db_stmt_cache_slot(i);
    if (slot.stmt == 0 as i64) {
      return slot;
    }
    i = i + 1;
  }
  slot = db_stmt_cache_slot(0);
  if (slot.stmt != 0 as i64) {
    unsafe { shu_sqlite3_finalize_c(slot.stmt); }
    slot.conn = 0;
    slot.sql[0] = 0;
    slot.stmt = 0;
  }
  return slot;
}

/** 从缓存移除指定 stmt（finalize 前调用）。 */
function db_stmt_cache_remove_stmt(stmt_h: i64): void {
  let i: i32 = 0;
  let slot: *DbCachedStmt = 0 as *DbCachedStmt;
  if (stmt_h == 0 as i64) { return; }
  while (i < DB_STMT_CACHE_CAP) {
    slot = db_stmt_cache_slot(i);
    if (slot.stmt == stmt_h) {
      slot.conn = 0;
      slot.sql[0] = 0;
      slot.stmt = 0;
      return;
    }
    i = i + 1;
  }
}

/** stub 后端统一入口：设置 DB_NOT_IMPL 并返回 1 表示 stub。 */
function db_stub_active(): i32 {
  unsafe { return shu_db_use_sqlite3_c() == 0 ? 1 : 0; }
}

/** 打开数据库；失败返回 handle=0。 */
function db_open_c(path: *u8): i64 {
  let db: i64 = 0;
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return 0;
  }
  if (path == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_PATH[0]);
    return 0;
  }
  db_clear_err();
  unsafe { rc = shu_sqlite3_open_c(path, &db); }
  if (rc != SHU_SQLITE_OK) {
    let em: *u8 = 0 as *u8;
    if (db != 0 as i64) {
      unsafe { em = shu_sqlite3_errmsg_c(db) as *u8; }
    }
    if (em == 0) { em = &SQL_LIT_SQLITE3_OPEN_FAILED[0]; }
    db_set_err(DB_ERR_OPEN, em);
    unsafe { if (db != 0 as i64) { shu_sqlite3_close_c(db); } }
    return 0;
  }
  return db;
}

/** 关闭连接（并释放该连接 stmt 缓存）。 */
function db_close_c(handle: i64): i32 {
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (handle == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_HANDLE[0]);
    return DB_ERR_NULL;
  }
  db_stmt_cache_drop_conn(handle);
  unsafe { rc = shu_sqlite3_close_c(handle); }
  if (rc != SHU_SQLITE_OK) {
    unsafe { db_set_err(DB_ERR_BUSY, shu_sqlite3_errmsg_c(handle) as *u8); }
    return DB_ERR_BUSY;
  }
  db_clear_err();
  return DB_OK;
}

/** 执行无结果集 SQL。 */
function db_exec_c(handle: i64, sql: *u8): i32 {
  let errmsg: i64 = 0;
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (handle == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_HANDLE[0]);
    return DB_ERR_NULL;
  }
  if (sql == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_SQL[0]);
    return DB_ERR_NULL;
  }
  unsafe { rc = shu_sqlite3_exec_c(handle, sql, &errmsg); }
  if (rc != SHU_SQLITE_OK) {
    let em: *u8 = &SQL_LIT_EXEC_FAILED[0];
    if (errmsg != 0 as i64) { em = errmsg as *u8; }
    db_set_err(DB_ERR_EXEC, em);
    unsafe { if (errmsg != 0 as i64) { shu_sqlite3_free_c(errmsg); } }
    return DB_ERR_EXEC;
  }
  unsafe { if (errmsg != 0 as i64) { shu_sqlite3_free_c(errmsg); } }
  db_clear_err();
  return DB_OK;
}

/** 查询行集：返回 SELECT 匹配行数。 */
function db_query_rows_c(handle: i64, sql: *u8): i32 {
  let count: i32 = 0;
  let errmsg: i64 = 0;
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (handle == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_HANDLE[0]);
    return DB_ERR_NULL;
  }
  if (sql == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_SQL[0]);
    return DB_ERR_NULL;
  }
  unsafe { rc = shu_sqlite3_exec_count_c(handle, sql, &count, &errmsg); }
  if (rc != SHU_SQLITE_OK) {
    let em: *u8 = &SQL_LIT_QUERY_FAILED[0];
    if (errmsg != 0 as i64) { em = errmsg as *u8; }
    db_set_err(DB_ERR_EXEC, em);
    unsafe { if (errmsg != 0 as i64) { shu_sqlite3_free_c(errmsg); } }
    return DB_ERR_EXEC;
  }
  unsafe { if (errmsg != 0 as i64) { shu_sqlite3_free_c(errmsg); } }
  db_clear_err();
  return count;
}

/** 准备 SELECT 游标；失败返回 cursor=0。 */
function db_query_begin_c(handle: i64, sql: *u8): i64 {
  let stmt: i64 = 0;
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return 0;
  }
  if (handle == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_HANDLE[0]);
    return 0;
  }
  if (sql == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_SQL[0]);
    return 0;
  }
  unsafe { rc = shu_sqlite3_prepare_v2_c(handle, sql, &stmt); }
  if (rc != SHU_SQLITE_OK) {
    unsafe { db_set_err(DB_ERR_EXEC, shu_sqlite3_errmsg_c(handle) as *u8); }
    return 0;
  }
  db_clear_err();
  return stmt;
}

/** 推进游标：1=有行，0=结束，<0=错误。 */
function db_next_row_c(cursor: i64): i32 {
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CURSOR[0]);
    return DB_ERR_NULL;
  }
  unsafe { rc = shu_sqlite3_step_c(cursor); }
  if (rc == SHU_SQLITE_ROW) { return 1; }
  if (rc == SHU_SQLITE_DONE) {
    db_clear_err();
    return 0;
  }
  unsafe { db_set_err(DB_ERR_EXEC, shu_sqlite3_errmsg_c(shu_sqlite3_db_handle_c(cursor)) as *u8); }
  return DB_ERR_EXEC;
}

/** 读取当前行列值（i32）；列越界返回 DB_ERR_EXEC。 */
function db_row_col_i32_c(cursor: i64, col: i32): i32 {
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CURSOR[0]);
    return DB_ERR_NULL;
  }
  unsafe { if (col < 0 || col >= shu_sqlite3_column_count_c(cursor)) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_COL_INDEX[0]);
    return DB_ERR_EXEC;
  } }
  db_clear_err();
  unsafe { return shu_sqlite3_column_int_c(cursor, col); }
}

/** 读取当前行文本列到 out_buf；成功返回字节长度（不含 NUL），NULL 列返回 0。 */
function db_row_col_text_c(cursor: i64, col: i32, out_buf: *u8, out_cap: i32): i32 {
  let txt: i64 = 0;
  let n: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CURSOR[0]);
    return DB_ERR_NULL;
  }
  unsafe { if (col < 0 || col >= shu_sqlite3_column_count_c(cursor)) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_COL_INDEX[0]);
    return DB_ERR_EXEC;
  } }
  if (out_buf == 0 || out_cap <= 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_BUF[0]);
    return DB_ERR_NULL;
  }
  unsafe { txt = shu_sqlite3_column_text_c(cursor, col); }
  if (txt == 0 as i64) {
    out_buf[0] = 0;
    db_clear_err();
    return 0;
  }
  unsafe { n = strlen(txt as *u8) as i32; }
  if (n + 1 > out_cap) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_BUF_SMALL[0]);
    return DB_ERR_EXEC;
  }
  unsafe { memcpy(out_buf, txt as *u8, (n + 1)); }
  db_clear_err();
  return n;
}

/** 读取当前行 BLOB 列到 out_buf；成功返回字节长度，NULL 列返回 0。 */
function db_row_col_blob_c(cursor: i64, col: i32, out_buf: *u8, out_cap: i32): i32 {
  let blob: i64 = 0;
  let n: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CURSOR[0]);
    return DB_ERR_NULL;
  }
  unsafe { if (col < 0 || col >= shu_sqlite3_column_count_c(cursor)) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_COL_INDEX[0]);
    return DB_ERR_EXEC;
  } }
  if (out_buf == 0 || out_cap <= 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_BUF[0]);
    return DB_ERR_NULL;
  }
  unsafe { n = shu_sqlite3_column_bytes_c(cursor, col); }
  if (n <= 0) {
    db_clear_err();
    return 0;
  }
  unsafe { blob = shu_sqlite3_column_blob_c(cursor, col); }
  if (blob == 0 as i64) {
    db_clear_err();
    return 0;
  }
  if (n > out_cap) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_BUF_SMALL[0]);
    return DB_ERR_EXEC;
  }
  unsafe { memcpy(out_buf, blob as *u8, n); }
  db_clear_err();
  return n;
}

/** 返回当前行 BLOB 列字节长度（NULL / 空列返回 0）。 */
function db_row_col_blob_len_c(cursor: i64, col: i32): i32 {
  let n: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CURSOR[0]);
    return DB_ERR_NULL;
  }
  unsafe { if (col < 0 || col >= shu_sqlite3_column_count_c(cursor)) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_COL_INDEX[0]);
    return DB_ERR_EXEC;
  } }
  unsafe { n = shu_sqlite3_column_bytes_c(cursor, col); }
  if (n < 0) { n = 0; }
  db_clear_err();
  return n;
}

/** 分块读取 BLOB 列：从 offset 起最多 out_cap 字节；offset>=len 返回 0。 */
function db_row_col_blob_read_c(cursor: i64, col: i32, offset: i32, out_buf: *u8, out_cap: i32): i32 {
  let blob: i64 = 0;
  let n: i32 = 0;
  let avail: i32 = 0;
  let to_copy: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CURSOR[0]);
    return DB_ERR_NULL;
  }
  unsafe { if (col < 0 || col >= shu_sqlite3_column_count_c(cursor)) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_COL_INDEX[0]);
    return DB_ERR_EXEC;
  } }
  if (offset < 0) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_BAD_OFFSET[0]);
    return DB_ERR_EXEC;
  }
  if (out_buf == 0 || out_cap <= 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_BUF[0]);
    return DB_ERR_NULL;
  }
  unsafe { n = shu_sqlite3_column_bytes_c(cursor, col); }
  if (n <= 0 || offset >= n) {
    db_clear_err();
    return 0;
  }
  unsafe { blob = shu_sqlite3_column_blob_c(cursor, col); }
  if (blob == 0 as i64) {
    db_clear_err();
    return 0;
  }
  avail = n - offset;
  to_copy = avail;
  if (to_copy > out_cap) { to_copy = out_cap; }
  unsafe { memcpy(out_buf, (blob as *u8) + (offset), to_copy); }
  db_clear_err();
  return to_copy;
}

/** 释放游标（finalize，并从 stmt 缓存移除）。 */
function db_query_end_c(cursor: i64): i32 {
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (cursor == 0 as i64) { return DB_OK; }
  db_stmt_cache_remove_stmt(cursor);
  unsafe { rc = shu_sqlite3_finalize_c(cursor); }
  if (rc != SHU_SQLITE_OK) {
    db_set_err(DB_ERR_BUSY, &SQL_LIT_FINALIZE_FAILED[0]);
    return DB_ERR_BUSY;
  }
  db_clear_err();
  return DB_OK;
}

/** 预编译 SQL（独立 finalize，不入缓存）。 */
function db_prepare_c(handle: i64, sql: *u8): i64 {
  return db_query_begin_c(handle, sql);
}

/** 预编译并缓存（同 SQL 复用 sqlite3_stmt*）。 */
function db_prepare_cached_c(handle: i64, sql: *u8): i64 {
  let slot: *DbCachedStmt = 0 as *DbCachedStmt;
  let stmt: i64 = 0;
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return 0;
  }
  if (handle == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_HANDLE[0]);
    return 0;
  }
  if (sql == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_SQL[0]);
    return 0;
  }
  unsafe { if (strlen(sql) >= DB_STMT_SQL_MAX as usize) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_SQL_TOO_LONG_FOR_CACHE[0]);
    return 0;
  } }
  slot = db_stmt_cache_find(handle, sql);
  if (slot != 0) {
    unsafe { shu_sqlite3_reset_c(slot.stmt); }
    unsafe { shu_sqlite3_clear_bindings_c(slot.stmt); }
    db_clear_err();
    return slot.stmt;
  }
  unsafe { rc = shu_sqlite3_prepare_v2_c(handle, sql, &stmt); }
  if (rc != SHU_SQLITE_OK) {
    unsafe { db_set_err(DB_ERR_EXEC, shu_sqlite3_errmsg_c(handle) as *u8); }
    return 0;
  }
  slot = db_stmt_cache_alloc_slot();
  slot.conn = handle;
  db_str_copy(&slot.sql[0], DB_STMT_SQL_MAX, sql);
  slot.stmt = stmt;
  db_clear_err();
  return stmt;
}

/** 绑定整型参数（idx 为 1 起始 SQLite 约定）。 */
function db_stmt_bind_i32_c(stmt_h: i64, idx: i32, val: i32): i32 {
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (stmt_h == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_STMT[0]);
    return DB_ERR_NULL;
  }
  if (idx < 1) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_BIND_IDX[0]);
    return DB_ERR_EXEC;
  }
  unsafe { rc = shu_sqlite3_bind_int_c(stmt_h, idx, val); }
  if (rc != SHU_SQLITE_OK) {
    unsafe { db_set_err(DB_ERR_EXEC, shu_sqlite3_errmsg_c(shu_sqlite3_db_handle_c(stmt_h)) as *u8); }
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return DB_OK;
}

/** 绑定文本参数（idx 为 1 起始）。 */
function db_stmt_bind_text_c(stmt_h: i64, idx: i32, text: *u8): i32 {
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (stmt_h == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_STMT[0]);
    return DB_ERR_NULL;
  }
  if (idx < 1) {
    db_set_err(DB_ERR_EXEC, &SQL_LIT_BIND_IDX[0]);
    return DB_ERR_EXEC;
  }
  unsafe { rc = shu_sqlite3_bind_text_c(stmt_h, idx, text); }
  if (rc != SHU_SQLITE_OK) {
    unsafe { db_set_err(DB_ERR_EXEC, shu_sqlite3_errmsg_c(shu_sqlite3_db_handle_c(stmt_h)) as *u8); }
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return DB_OK;
}

/** 执行一步：1=有行，0=完成，<0=错误。 */
function db_stmt_step_c(stmt_h: i64): i32 {
  return db_next_row_c(stmt_h);
}

/** 重置预编译语句以便复用。 */
function db_stmt_reset_c(stmt_h: i64): i32 {
  let rc: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (stmt_h == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_STMT[0]);
    return DB_ERR_NULL;
  }
  unsafe { rc = shu_sqlite3_reset_c(stmt_h); }
  if (rc != SHU_SQLITE_OK) {
    unsafe { db_set_err(DB_ERR_EXEC, shu_sqlite3_errmsg_c(shu_sqlite3_db_handle_c(stmt_h)) as *u8); }
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return DB_OK;
}

/** 释放预编译语句（并从缓存移除）。 */
function db_stmt_finalize_c(stmt_h: i64): i32 {
  return db_query_end_c(stmt_h);
}

/** 清空连接上全部 stmt 缓存（不关闭连接）。 */
function db_stmt_cache_clear_c(handle: i64): i32 {
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (handle == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_HANDLE[0]);
    return DB_ERR_NULL;
  }
  db_stmt_cache_drop_conn(handle);
  db_clear_err();
  return DB_OK;
}

/** 开始事务（BEGIN IMMEDIATE）。 */
function db_begin_tx_c(handle: i64): i32 {
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  return db_exec_c(handle, &SQL_LIT_BEGIN_IMMEDIATE[0]);
}

/** 提交事务。 */
function db_commit_c(handle: i64): i32 {
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  return db_exec_c(handle, &SQL_LIT_COMMIT[0]);
}

/** 回滚事务。 */
function db_rollback_c(handle: i64): i32 {
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  return db_exec_c(handle, &SQL_LIT_ROLLBACK[0]);
}

/** 读取最后一次库错误码。 */
function db_last_code_c(): i32 {
  if (db_stub_active() != 0) {
    return g_db_last_err.code != 0 ? g_db_last_err.code : DB_NOT_IMPL;
  }
  return g_db_last_err.code;
}

/** 读取最后一次库错误消息（静态缓冲）。 */
function db_last_error_msg_c(): *u8 {
  if (g_db_last_err.msg[0] == 0) { return 0; }
  return &g_db_last_err.msg[0];
}

/** 当前后端名称（&SQL_LIT_SQLITE3[0] 或 &SQL_LIT_STUB[0]）。 */
function db_backend_name_c(): *u8 {
  if (db_stub_active() != 0) {
    return &SQL_LIT_STUB[0];
  }
  return &SQL_LIT_SQLITE3[0];
}

/** 返回最近一次 exec 影响行数（仅 SQLite 路径有效）。 */
function db_changes_c(handle: i64): i32 {
  if (db_stub_active() != 0) { return 0; }
  if (handle == 0 as i64) { return 0; }
  unsafe { return shu_sqlite3_changes_c(handle); }
}

/** 单字节转两位十六进制（小写）。 */
function db_byte_to_hex2(b: u8, out: *u8): void {
  let hi: u8 = (b >> 4) & 0x0f;
  let lo: u8 = b & 0x0f;
  out[0] = (hi < 10) ? ((48 + hi) as u8) : ((87 + hi) as u8);
  out[1] = (lo < 10) ? ((48 + lo) as u8) : ((87 + lo) as u8);
  out[2] = 0;
}

/** 构建 blob_stream 烟测 INSERT SQL（96 字节递增 BLOB）。 */
function db_blob_stream_build_sql(sql: *u8, cap: i32): void {
  let prefix: *u8 = &SQL_LIT_INSERT_INTO_T_DATA_VALUES_X[0];
  let suffix: *u8 = &SQL_LIT_EMPTY[0];
  let pos: i32 = 0;
  let pi: i32 = 0;
  let i: i32 = 0;
  let hx: u8[3] = [];
  while (prefix[pi] != 0 && pos < cap - 1) {
    sql[pos] = prefix[pi];
    pos = pos + 1;
    pi = pi + 1;
  }
  i = 0;
  while (i < 96 && pos + 2 < cap - 1) {
    db_byte_to_hex2(i as u8, &hx[0]);
    sql[pos] = hx[0];
    sql[(pos + 1)] = hx[1];
    pos = pos + 2;
    i = i + 1;
  }
  i = 0;
  while (suffix[i] != 0 && pos < cap - 1) {
    sql[pos] = suffix[i];
    pos = pos + 1;
    i = i + 1;
  }
  sql[pos] = 0;
}

/** 烟测辅助：后端名首字符是否为 's'（sqlite3）。 */
function db_smoke_is_sqlite(): i32 {
  let n: *u8 = db_backend_name_c();
  return n[0] == 115 ? 1 : 0;
}

/** C 烟测：内存库 exec 往返（CREATE / INSERT / changes）。 */
function db_sqlite_exec_smoke_c(): i32 {
  let h: i64 = 0;
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER[0]) != DB_OK) { db_close_c(h); return 3; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_42[0]) != DB_OK) { db_close_c(h); return 4; }
  if (db_changes_c(h) != 1) { db_close_c(h); return 5; }
  if (db_close_c(h) != DB_OK) { return 6; }
  return 0;
}

/** C 烟测：事务 exec 往返（begin/commit + rollback）。 */
function db_sqlite_tx_exec_smoke_c(): i32 {
  let h: i64 = 0;
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER[0]) != DB_OK) { db_close_c(h); return 3; }
  if (db_begin_tx_c(h) != DB_OK) { db_close_c(h); return 4; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_7[0]) != DB_OK) { db_rollback_c(h); db_close_c(h); return 5; }
  if (db_changes_c(h) != 1) { db_rollback_c(h); db_close_c(h); return 6; }
  if (db_commit_c(h) != DB_OK) { db_close_c(h); return 7; }
  if (db_begin_tx_c(h) != DB_OK) { db_close_c(h); return 8; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_99[0]) != DB_OK) { db_rollback_c(h); db_close_c(h); return 9; }
  if (db_rollback_c(h) != DB_OK) { db_close_c(h); return 10; }
  if (db_close_c(h) != DB_OK) { return 11; }
  return 0;
}

/** C 烟测：query_rows 行迭代计数。 */
function db_sqlite_query_rows_smoke_c(): i32 {
  let h: i64 = 0;
  let rows: i32 = 0;
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER[0]) != DB_OK) { db_close_c(h); return 3; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_1[0]) != DB_OK) { db_close_c(h); return 4; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_2[0]) != DB_OK) { db_close_c(h); return 5; }
  rows = db_query_rows_c(h, &SQL_LIT_SELECT_K_FROM_T[0]);
  if (rows != 2) { db_close_c(h); return 6; }
  rows = db_query_rows_c(h, &SQL_LIT_SELECT_K_FROM_T_WHERE_K_1[0]);
  if (rows != 1) { db_close_c(h); return 7; }
  if (db_close_c(h) != DB_OK) { return 8; }
  return 0;
}

/** C 烟测：next_row 列值游标迭代（ORDER BY k 读 1、2）。 */
function db_sqlite_next_row_smoke_c(): i32 {
  let h: i64 = 0;
  let cur: i64 = 0;
  let st: i32 = 0;
  let v: i32 = 0;
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER[0]) != DB_OK) { db_close_c(h); return 3; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_2[0]) != DB_OK) { db_close_c(h); return 4; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_VALUES_1[0]) != DB_OK) { db_close_c(h); return 5; }
  cur = db_query_begin_c(h, &SQL_LIT_SELECT_K_FROM_T_ORDER_BY_K[0]);
  if (cur == 0 as i64) { db_close_c(h); return 6; }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 7; }
  v = db_row_col_i32_c(cur, 0);
  if (v != 1) { db_query_end_c(cur); db_close_c(h); return 8; }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 9; }
  v = db_row_col_i32_c(cur, 0);
  if (v != 2) { db_query_end_c(cur); db_close_c(h); return 10; }
  st = db_next_row_c(cur);
  if (st != 0) { db_query_end_c(cur); db_close_c(h); return 11; }
  if (db_query_end_c(cur) != DB_OK) { db_close_c(h); return 12; }
  if (db_close_c(h) != DB_OK) { return 13; }
  return 0;
}

/** C 烟测：row_col_text 文本列游标（ORDER BY k 读 alpha、beta）。 */
function db_sqlite_row_col_text_smoke_c(): i32 {
  let h: i64 = 0;
  let cur: i64 = 0;
  let st: i32 = 0;
  let n: i32 = 0;
  let buf: u8[32] = [];
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER_NAME_TEXT[0]) != DB_OK) { db_close_c(h); return 3; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_NAME_VALUES_2_BETA[0]) != DB_OK) { db_close_c(h); return 4; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_NAME_VALUES_1_ALPHA[0]) != DB_OK) { db_close_c(h); return 5; }
  cur = db_query_begin_c(h, &SQL_LIT_SELECT_NAME_FROM_T_ORDER_BY_K[0]);
  if (cur == 0 as i64) { db_close_c(h); return 6; }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 7; }
  n = db_row_col_text_c(cur, 0, &buf[0], 32);
  if (n != 5 || db_str_eq(&buf[0], &SQL_LIT_ALPHA[0]) == 0) { db_query_end_c(cur); db_close_c(h); return 8; }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 9; }
  n = db_row_col_text_c(cur, 0, &buf[0], 32);
  if (n != 4 || db_str_eq(&buf[0], &SQL_LIT_BETA[0]) == 0) { db_query_end_c(cur); db_close_c(h); return 10; }
  st = db_next_row_c(cur);
  if (st != 0) { db_query_end_c(cur); db_close_c(h); return 11; }
  if (db_query_end_c(cur) != DB_OK) { db_close_c(h); return 12; }
  if (db_close_c(h) != DB_OK) { return 13; }
  return 0;
}

/** C 烟测：大 BLOB 分块读（96 字节，32×3 块）。 */
function db_sqlite_blob_stream_smoke_c(): i32 {
  let h: i64 = 0;
  let cur: i64 = 0;
  let st: i32 = 0;
  let total: i32 = 0;
  let off: i32 = 0;
  let chunk: i32 = 0;
  let got: i32 = 0;
  let buf: u8[32] = [];
  let acc: u8[96] = [];
  let acc_len: i32 = 0;
  let sql: u8[512] = [];
  let i: i32 = 0;
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_DATA_BLOB[0]) != DB_OK) { db_close_c(h); return 3; }
  db_blob_stream_build_sql(&sql[0], 512);
  if (db_exec_c(h, &sql[0]) != DB_OK) { db_close_c(h); return 4; }
  cur = db_query_begin_c(h, &SQL_LIT_SELECT_DATA_FROM_T[0]);
  if (cur == 0 as i64) { db_close_c(h); return 5; }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 6; }
  total = db_row_col_blob_len_c(cur, 0);
  if (total != 96) { db_query_end_c(cur); db_close_c(h); return 7; }
  off = 0;
  acc_len = 0;
  while (off < total) {
    got = db_row_col_blob_read_c(cur, 0, off, &buf[0], 32);
    if (got <= 0) { db_query_end_c(cur); db_close_c(h); return 8; }
    chunk = got;
    i = 0;
    while (i < chunk) {
      acc[acc_len] = buf[i];
      acc_len = acc_len + 1;
      i = i + 1;
    }
    off = off + chunk;
  }
  if (acc_len != 96) { db_query_end_c(cur); db_close_c(h); return 9; }
  i = 0;
  while (i < 96) {
    if (acc[i] != (i as u8)) { db_query_end_c(cur); db_close_c(h); return 10; }
    i = i + 1;
  }
  if (db_query_end_c(cur) != DB_OK) { db_close_c(h); return 11; }
  if (db_close_c(h) != DB_OK) { return 12; }
  return 0;
}

/** C 烟测：row_col_blob BLOB 列游标（ORDER BY k 读 3/4 字节）。 */
function db_sqlite_row_col_blob_smoke_c(): i32 {
  let h: i64 = 0;
  let cur: i64 = 0;
  let st: i32 = 0;
  let n: i32 = 0;
  let buf: u8[32] = [];
  let expect3: u8[3] = [1, 2, 3];
  let expect4: u8[4] = [10, 11, 12, 13];
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER_DATA_BLOB[0]) != DB_OK) { db_close_c(h); return 3; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_DATA_VALUES_2_X_0A0B0C0D[0]) != DB_OK) { db_close_c(h); return 4; }
  if (db_exec_c(h, &SQL_LIT_INSERT_INTO_T_K_DATA_VALUES_1_X_010203[0]) != DB_OK) { db_close_c(h); return 5; }
  cur = db_query_begin_c(h, &SQL_LIT_SELECT_DATA_FROM_T_ORDER_BY_K[0]);
  if (cur == 0 as i64) { db_close_c(h); return 6; }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 7; }
  n = db_row_col_blob_c(cur, 0, &buf[0], 32);
  unsafe { if (n != 3 || memcmp(&buf[0], &expect3[0], 3) != 0) { db_query_end_c(cur); db_close_c(h); return 8; } }
  st = db_next_row_c(cur);
  if (st != 1) { db_query_end_c(cur); db_close_c(h); return 9; }
  n = db_row_col_blob_c(cur, 0, &buf[0], 32);
  unsafe { if (n != 4 || memcmp(&buf[0], &expect4[0], 4) != 0) { db_query_end_c(cur); db_close_c(h); return 10; } }
  st = db_next_row_c(cur);
  if (st != 0) { db_query_end_c(cur); db_close_c(h); return 11; }
  if (db_query_end_c(cur) != DB_OK) { db_close_c(h); return 12; }
  if (db_close_c(h) != DB_OK) { return 13; }
  return 0;
}

/** C 烟测：预编译 bind + stmt 缓存。 */
function db_sqlite_stmt_bind_smoke_c(): i32 {
  let h: i64 = 0;
  let ins: i64 = 0;
  let sel: i64 = 0;
  let sel2: i64 = 0;
  let st: i32 = 0;
  let n: i32 = 0;
  let buf: u8[32] = [];
  if (db_smoke_is_sqlite() == 0) { return 1; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h == 0 as i64) { return 2; }
  if (db_exec_c(h, &SQL_LIT_CREATE_TABLE_T_K_INTEGER_NAME_TEXT[0]) != DB_OK) { db_close_c(h); return 3; }
  ins = db_prepare_c(h, &SQL_LIT_INSERT_INTO_T_K_NAME_VALUES[0]);
  if (ins == 0 as i64) { db_close_c(h); return 4; }
  if (db_stmt_bind_i32_c(ins, 1, 10) != DB_OK || db_stmt_bind_text_c(ins, 2, &SQL_LIT_ALICE[0]) != DB_OK) {
    db_stmt_finalize_c(ins); db_close_c(h); return 5;
  }
  if (db_stmt_step_c(ins) != 0) { db_stmt_finalize_c(ins); db_close_c(h); return 6; }
  if (db_stmt_reset_c(ins) != DB_OK) { db_stmt_finalize_c(ins); db_close_c(h); return 7; }
  if (db_stmt_bind_i32_c(ins, 1, 20) != DB_OK || db_stmt_bind_text_c(ins, 2, &SQL_LIT_BOB[0]) != DB_OK) {
    db_stmt_finalize_c(ins); db_close_c(h); return 8;
  }
  if (db_stmt_step_c(ins) != 0) { db_stmt_finalize_c(ins); db_close_c(h); return 9; }
  if (db_stmt_finalize_c(ins) != DB_OK) { db_close_c(h); return 10; }
  sel = db_prepare_cached_c(h, &SQL_LIT_SELECT_NAME_FROM_T_WHERE_K[0]);
  if (sel == 0 as i64) { db_close_c(h); return 11; }
  sel2 = db_prepare_cached_c(h, &SQL_LIT_SELECT_NAME_FROM_T_WHERE_K[0]);
  if (sel2 != sel) { db_close_c(h); return 12; }
  if (db_stmt_bind_i32_c(sel, 1, 10) != DB_OK) { db_close_c(h); return 13; }
  st = db_stmt_step_c(sel);
  if (st != 1) { db_close_c(h); return 14; }
  n = db_row_col_text_c(sel, 0, &buf[0], 32);
  if (n != 5 || buf[0] != 97 || buf[4] != 101) { db_close_c(h); return 15; }
  if (db_stmt_reset_c(sel) != DB_OK || db_stmt_bind_i32_c(sel, 1, 20) != DB_OK) { db_close_c(h); return 16; }
  st = db_stmt_step_c(sel);
  if (st != 1) { db_close_c(h); return 17; }
  n = db_row_col_text_c(sel, 0, &buf[0], 32);
  if (n != 3 || buf[0] != 98 || buf[2] != 98) { db_close_c(h); return 18; }
  if (db_stmt_cache_clear_c(h) != DB_OK) { db_close_c(h); return 19; }
  if (db_close_c(h) != DB_OK) { return 20; }
  return 0;
}

/** 创建连接池（不预建连接）；max_conns 上限 8。 */
function db_pool_open_c(path: *u8, max_conns: i32): i64 {
  let p: *DbPoolMem = 0 as *DbPoolMem;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return 0;
  }
  if (path == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_PATH[0]);
    return 0;
  }
  if (max_conns <= 0) { max_conns = 1; }
  if (max_conns > DB_POOL_SLOT_MAX) { max_conns = DB_POOL_SLOT_MAX; }
  unsafe { p = calloc(1, 592) as *DbPoolMem; }
  if (p == 0) {
    db_set_err(DB_ERR_OPEN, &SQL_LIT_POOL_ALLOC[0]);
    return 0;
  }
  db_str_copy(&p.path[0], DB_POOL_PATH_MAX, path);
  p.max_conns = max_conns;
  db_clear_err();
  return p as i64;
}

/** 关闭池并释放全部 idle 连接；仍有借出连接时返回 DB_ERR_BUSY。 */
function db_pool_close_c(pool_h: i64): i32 {
  let p: *DbPoolMem = pool_h as *DbPoolMem;
  let i: i32 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (p == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_POOL[0]);
    return DB_ERR_NULL;
  }
  if (p.live_count > p.idle_count) {
    db_set_err(DB_ERR_BUSY, &SQL_LIT_POOL_IN_USE[0]);
    return DB_ERR_BUSY;
  }
  i = 0;
  while (i < p.idle_count) {
    db_close_c(p.idle[i]);
    i = i + 1;
  }
  p.idle_count = 0;
  p.live_count = 0;
  unsafe { free(p as *u8); }
  db_clear_err();
  return DB_OK;
}

/** 从池获取连接；池耗尽返回 handle=0（DB_ERR_BUSY）。 */
function db_pool_acquire_c(pool_h: i64): i64 {
  let p: *DbPoolMem = pool_h as *DbPoolMem;
  let h: i64 = 0;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return 0;
  }
  if (p == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_POOL[0]);
    return 0;
  }
  if (p.idle_count > 0) {
    p.idle_count = p.idle_count - 1;
    h = p.idle[p.idle_count];
    if (db_exec_c(h, &SQL_LIT_SELECT_1[0]) != DB_OK) {
      db_close_c(h);
      p.live_count = p.live_count - 1;
      return 0;
    }
    db_clear_err();
    return h;
  }
  if (p.live_count >= p.max_conns) {
    db_set_err(DB_ERR_BUSY, &SQL_LIT_POOL_EXHAUSTED[0]);
    return 0;
  }
  h = db_open_c(&p.path[0]);
  if (h == 0 as i64) { return 0; }
  p.live_count = p.live_count + 1;
  db_clear_err();
  return h;
}

/** 归还连接到 idle 队列（不关闭 sqlite3）。 */
function db_pool_release_c(pool_h: i64, conn_h: i64): i32 {
  let p: *DbPoolMem = pool_h as *DbPoolMem;
  if (db_stub_active() != 0) {
    db_set_err(DB_NOT_IMPL, &SQL_LIT_STUB_BACKEND[0]);
    return DB_NOT_IMPL;
  }
  if (p == 0) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_POOL[0]);
    return DB_ERR_NULL;
  }
  if (conn_h == 0 as i64) {
    db_set_err(DB_ERR_NULL, &SQL_LIT_NULL_CONN[0]);
    return DB_ERR_NULL;
  }
  if (p.idle_count >= DB_POOL_SLOT_MAX) {
    db_close_c(conn_h);
    if (p.live_count > 0) { p.live_count = p.live_count - 1; }
    db_clear_err();
    return DB_OK;
  }
  p.idle[p.idle_count] = conn_h;
  p.idle_count = p.idle_count + 1;
  db_clear_err();
  return DB_OK;
}

/** 当前 idle 连接数（诊断/烟测）。 */
function db_pool_idle_c(pool_h: i64): i32 {
  let p: *DbPoolMem = pool_h as *DbPoolMem;
  if (db_stub_active() != 0) { return DB_NOT_IMPL; }
  if (p == 0) { return DB_ERR_NULL; }
  return p.idle_count;
}

/** C 烟测：acquire 上限、release 复用、pool_close（:memory: max=1）。 */
function db_sqlite_pool_smoke_c(): i32 {
  let pool: i64 = 0;
  let c1: i64 = 0;
  let c2: i64 = 0;
  let c3: i64 = 0;
  let c4: i64 = 0;
  if (db_smoke_is_sqlite() == 0) { return 1; }
  pool = db_pool_open_c(&SQL_LIT_MEMORY[0], 1);
  if (pool == 0 as i64) { return 2; }
  c1 = db_pool_acquire_c(pool);
  if (c1 == 0 as i64) { db_pool_close_c(pool); return 3; }
  if (db_exec_c(c1, &SQL_LIT_CREATE_TABLE_T_K_INTEGER[0]) != DB_OK) { db_pool_release_c(pool, c1); db_pool_close_c(pool); return 4; }
  if (db_pool_release_c(pool, c1) != DB_OK) { db_pool_close_c(pool); return 5; }
  if (db_pool_idle_c(pool) != 1) { db_pool_close_c(pool); return 6; }
  c2 = db_pool_acquire_c(pool);
  if (c2 == 0 as i64 || c2 != c1) { if (c2 != 0 as i64) { db_pool_release_c(pool, c2); } db_pool_close_c(pool); return 7; }
  if (db_exec_c(c2, &SQL_LIT_INSERT_INTO_T_K_VALUES_42[0]) != DB_OK) { db_pool_release_c(pool, c2); db_pool_close_c(pool); return 8; }
  if (db_pool_release_c(pool, c2) != DB_OK) { db_pool_close_c(pool); return 9; }
  c3 = db_pool_acquire_c(pool);
  if (c3 == 0 as i64) { db_pool_close_c(pool); return 10; }
  c4 = db_pool_acquire_c(pool);
  if (c4 != 0 as i64) {
    db_pool_release_c(pool, c3);
    if (c4 != 0 as i64) { db_pool_release_c(pool, c4); }
    db_pool_close_c(pool);
    return 11;
  }
  if (db_last_code_c() != DB_ERR_BUSY) { db_pool_release_c(pool, c3); db_pool_close_c(pool); return 12; }
  if (db_pool_release_c(pool, c3) != DB_OK) { db_pool_close_c(pool); return 13; }
  if (db_pool_close_c(pool) != DB_OK) { return 14; }
  return 0;
}

/** C 烟测：stub 语义；真实 sqlite3 后端时跳过（返回 0）。 */
function db_sqlite_stub_smoke_c(): i32 {
  let h: i64 = 0;
  let ec: i32 = 0;
  if (db_str_eq(db_backend_name_c(), &SQL_LIT_STUB[0]) == 0) { return 0; }
  h = db_open_c(&SQL_LIT_MEMORY[0]);
  if (h != 0 as i64) { return 1; }
  ec = db_last_code_c();
  if (ec != DB_NOT_IMPL) { return 2; }
  if (db_pool_open_c(&SQL_LIT_MEMORY[0], 1) != 0 as i64) { return 3; }
  if (db_last_code_c() != DB_NOT_IMPL) { return 4; }
  return 0;
}
