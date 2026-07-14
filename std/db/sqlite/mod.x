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

// std.db.sqlite — SQLite 数据库访问（STD-057…070/084）
//
// 【路径】`import("std.db.sqlite")`。
//
// 【文件职责】open/close/exec/事务/游标；预编译 bind + stmt 缓存；连接池（STD-084）。
// 实现：sqlite.x + sqlite_glue.c（libsqlite3 胶层）；stub 构建见 sqlite-o-stub。
// 【设计层】D1 连接 / D2 查询执行 / D3 事务 / D4 后端抽象（见 analysis/std-sqlite-prereq-v1.md）。
// 【错误码】对齐 EXC-003 库级负数；0=成功，-9=未实现桩（仅 sqlite-o-stub 构建）。

/** 成功。 */
export const DB_OK: i32 = 0;
/** 空指针参数。 */
export const DB_ERR_NULL: i32 = -1;
/** 打开失败。 */
export const DB_ERR_OPEN: i32 = -2;
/** 执行失败。 */
export const DB_ERR_EXEC: i32 = -3;
/** 忙/无法关闭。 */
export const DB_ERR_BUSY: i32 = -4;
/** 预研桩：无后端实现（仅 stub 构建）。 */
export const DB_NOT_IMPL: i32 = -9;
/** 游标仍有行（next_row 返回）。 */
export const DB_ROW_OK: i32 = 1;
/** 游标已耗尽（next_row 返回）。 */
export const DB_ROW_DONE: i32 = 0;

/** 不透明连接句柄（映射 sqlite3*）。 */
export struct DbConn {
  handle: i64;
}

/** 库级错误快照。 */
allow(padding) struct DbError {
  code: i32;
  msg: *u8;
}

/** SELECT 列值游标（映射 sqlite3_stmt*）。 */
export struct DbRowCursor {
  cursor: i64;
}

/** 预编译语句句柄（映射 sqlite3_stmt*，可与 row_col_* 联用）。 */
export struct DbStmt {
  handle: i64;
}

/** 连接池句柄（C 层 db_pool_t*）。 */
export struct DbPool {
  handle: i64;
}

extern function db_open_c(path: *u8): i64;
extern function db_close_c(handle: i64): i32;
extern function db_exec_c(handle: i64, sql: *u8): i32;
extern function db_query_rows_c(handle: i64, sql: *u8): i32;
extern function db_query_begin_c(handle: i64, sql: *u8): i64;
extern function db_next_row_c(cursor: i64): i32;
extern function db_row_col_i32_c(cursor: i64, col: i32): i32;
extern function db_row_col_text_c(cursor: i64, col: i32, out_buf: *u8, out_cap: i32): i32;
extern function db_row_col_blob_c(cursor: i64, col: i32, out_buf: *u8, out_cap: i32): i32;
extern function db_row_col_blob_len_c(cursor: i64, col: i32): i32;
extern function db_row_col_blob_read_c(cursor: i64, col: i32, offset: i32, out_buf: *u8, out_cap: i32): i32;
extern function db_query_end_c(cursor: i64): i32;
extern function db_begin_tx_c(handle: i64): i32;
extern function db_commit_c(handle: i64): i32;
extern function db_rollback_c(handle: i64): i32;
extern function db_last_code_c(): i32;
extern function db_last_error_msg_c(): *u8;
extern function db_backend_name_c(): *u8;
extern function db_changes_c(handle: i64): i32;
extern function db_prepare_c(handle: i64, sql: *u8): i64;
extern function db_prepare_cached_c(handle: i64, sql: *u8): i64;
extern function db_stmt_bind_i32_c(stmt: i64, idx: i32, val: i32): i32;
extern function db_stmt_bind_text_c(stmt: i64, idx: i32, text: *u8): i32;
extern function db_stmt_step_c(stmt: i64): i32;
extern function db_stmt_reset_c(stmt: i64): i32;
extern function db_stmt_finalize_c(stmt: i64): i32;
extern function db_stmt_cache_clear_c(handle: i64): i32;
extern function db_pool_open_c(path: *u8, max_conns: i32): i64;
extern function db_pool_close_c(pool: i64): i32;
extern function db_pool_acquire_c(pool: i64): i64;
extern function db_pool_release_c(pool: i64, conn: i64): i32;
extern function db_pool_idle_c(pool: i64): i32;

/** 打开数据库文件路径（UTF-8 C 串）；失败 handle=0。 */
export function open(path: *u8): DbConn {
  let _rc: DbConn = 0;
  unsafe { _rc = DbConn { handle: db_open_c(path) }; }
  return _rc;
}

/** 关闭连接。 */
export function close(conn: DbConn): i32 {
  unsafe { return db_close_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 执行无结果集 SQL（DDL/DML）。 */
export function exec(conn: DbConn, sql: *u8): i32 {
  unsafe { return db_exec_c(conn.handle, sql); }
  return 0; // unreachable — typeck workaround
}

/** 执行查询并返回匹配行数（v1 原型：sqlite3 回调迭代计数）。 */
export function rows(conn: DbConn, sql: *u8): i32 {
  unsafe { return db_query_rows_c(conn.handle, sql); }
  return 0; // unreachable — typeck workaround
}

/** 准备 SELECT 游标；失败 cursor=0。 */
export function begin(conn: DbConn, sql: *u8): DbRowCursor {
  let _rc: DbRowCursor = 0;
  unsafe { _rc = DbRowCursor { cursor: db_query_begin_c(conn.handle, sql) }; }
  return _rc;
}

/** 推进游标：DB_ROW_OK=有行，DB_ROW_DONE=结束，<0=错误。 */
export function next_row(cur: DbRowCursor): i32 {
  unsafe { return db_next_row_c(cur.cursor); }
  return 0; // unreachable — typeck workaround
}

/** 读取当前行列值（i32）。 */
export function col(cur: DbRowCursor, col: i32): i32 {
  unsafe { return db_row_col_i32_c(cur.cursor, col); }
  return 0; // unreachable — typeck workaround
}

/** 读取当前行文本列到 out（UTF-8）；成功返回字节长度，<0 为错误。 */
export function col_text(cur: DbRowCursor, col: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_text_c(cur.cursor, col, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** 读取当前行 BLOB 列到 out；成功返回字节长度，<0 为错误。 */
export function col_blob(cur: DbRowCursor, col: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_blob_c(cur.cursor, col, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** 返回当前行 BLOB 列总字节数（NULL/空列返回 0）。 */
export function col_blob_len(cur: DbRowCursor, col: i32): i32 {
  unsafe { return db_row_col_blob_len_c(cur.cursor, col); }
  return 0; // unreachable — typeck workaround
}

/** 分块读取 BLOB 列：从 offset 起最多 cap 字节；返回写入字节数。 */
export function col_blob_read(cur: DbRowCursor, col: i32, offset: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_blob_read_c(cur.cursor, col, offset, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** 释放游标。 */
export function end(cur: DbRowCursor): i32 {
  unsafe { return db_query_end_c(cur.cursor); }
  return 0; // unreachable — typeck workaround
}

/** 开始显式事务。 */
export function begin_tx(conn: DbConn): i32 {
  unsafe { return db_begin_tx_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 提交事务。 */
export function commit(conn: DbConn): i32 {
  unsafe { return db_commit_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 回滚事务。 */
export function rollback(conn: DbConn): i32 {
  unsafe { return db_rollback_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 读取线程局部最后一次库错误。 */
export function last_error(): DbError {
  let _rc: DbError = 0;
  unsafe { _rc = DbError {
      code: db_last_code_c(),
      msg: db_last_error_msg_c(),
    }; }
  return _rc;
}

/** 当前链接后端名称（"sqlite3" 或 "stub"）。 */
export function backend_name(): *u8 {
  unsafe { return db_backend_name_c(); }
  return 0; // unreachable — typeck workaround
}

/** 最近一次 exec 影响行数（SQLite 路径）。 */
export function changes(conn: DbConn): i32 {
  unsafe { return db_changes_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 预编译 SQL（须 stmt_finalize 释放；不入连接缓存）。 */
export function prepare(conn: DbConn, sql: *u8): DbStmt {
  let _rc: DbStmt = 0;
  unsafe { _rc = DbStmt { handle: db_prepare_c(conn.handle, sql) }; }
  return _rc;
}

/** 预编译并缓存（同连接同 SQL 复用；关闭连接或 stmt_cache_clear 失效）。 */
export function prepare_cached(conn: DbConn, sql: *u8): DbStmt {
  let _rc: DbStmt = 0;
  unsafe { _rc = DbStmt { handle: db_prepare_cached_c(conn.handle, sql) }; }
  return _rc;
}

/** 绑定整型参数（idx 从 1 起，SQLite 约定）。 */
export function bind(stmt: DbStmt, idx: i32, val: i32): i32 {
  unsafe { return db_stmt_bind_i32_c(stmt.handle, idx, val); }
  return 0; // unreachable — typeck workaround
}

/** 绑定 UTF-8 文本参数（idx 从 1 起）。 */
export function bind(stmt: DbStmt, idx: i32, text: *u8): i32 {
  unsafe { return db_stmt_bind_text_c(stmt.handle, idx, text); }
  return 0; // unreachable — typeck workaround
}

/** 执行预编译一步：DB_ROW_OK=有行，DB_ROW_DONE=完成，<0=错误。 */
export function step(stmt: DbStmt): i32 {
  unsafe { return db_stmt_step_c(stmt.handle); }
  return 0; // unreachable — typeck workaround
}

/** 重置预编译语句以便再次 bind/step。 */
export function reset(stmt: DbStmt): i32 {
  unsafe { return db_stmt_reset_c(stmt.handle); }
  return 0; // unreachable — typeck workaround
}

/** 释放预编译语句（缓存项一并移除）。 */
export function finalize(stmt: DbStmt): i32 {
  unsafe { return db_stmt_finalize_c(stmt.handle); }
  return 0; // unreachable — typeck workaround
}

/** 清空连接上全部 stmt 缓存（不关闭连接）。 */
export function cache_clear(conn: DbConn): i32 {
  unsafe { return db_stmt_cache_clear_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 读预编译当前行列值（i32）；须先 step 返回 DB_ROW_OK。 */
export function col(stmt: DbStmt, col: i32): i32 {
  unsafe { return db_row_col_i32_c(stmt.handle, col); }
  return 0; // unreachable — typeck workaround
}

/** 读预编译当前行文本列；须先 step 返回 DB_ROW_OK。 */
export function col_text(stmt: DbStmt, col: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_text_c(stmt.handle, col, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** 读预编译当前行 BLOB 列总字节数。 */
export function col_blob_len(stmt: DbStmt, col: i32): i32 {
  unsafe { return db_row_col_blob_len_c(stmt.handle, col); }
  return 0; // unreachable — typeck workaround
}

/** 分块读预编译当前行 BLOB 列。 */
export function col_blob_read(stmt: DbStmt, col: i32, offset: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_blob_read_c(stmt.handle, col, offset, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** 打开连接池（惰性建连；max_conns 上限 8）。 */
export function open(path: *u8, max_conns: i32): DbPool {
  let _rc: DbPool = 0;
  unsafe { _rc = DbPool { handle: db_pool_open_c(path, max_conns) }; }
  return _rc;
}

/** 关闭连接池（须先 release 全部借出连接）。 */
export function close(pool: DbPool): i32 {
  unsafe { return db_pool_close_c(pool.handle); }
  return 0; // unreachable — typeck workaround
}

/** 从池借连接；失败 handle=0（池耗尽时为 DB_ERR_BUSY）。 */
export function acquire(pool: DbPool): DbConn {
  let _rc: DbConn = 0;
  unsafe { _rc = DbConn { handle: db_pool_acquire_c(pool.handle) }; }
  return _rc;
}

/** 归还连接到池 idle 队列。 */
export function release(pool: DbPool, conn: DbConn): i32 {
  unsafe { return db_pool_release_c(pool.handle, conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** 当前 idle 连接数（烟测/诊断）。 */
export function idle(pool: DbPool): i32 {
  unsafe { return db_pool_idle_c(pool.handle); }
  return 0; // unreachable — typeck workaround
}

/** STD-167：SQLite 后端是否可用（"sqlite3" 全量 vs "stub"）；1 可用，0 桩。 */
export function is_available(): i32 {
  let n: *u8 = backend_name();
  if (n[0] == 115 && n[1] == 113 && n[2] == 108 && n[3] == 105 && n[4] == 116 && n[5] == 101 && n[6] == 51) {
    return 1;
  }
  return 0;
}
