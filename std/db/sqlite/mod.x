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

/**
 * SQLite3 C ABI wrappers.
 *
 * All `db_*_c` functions below are thin wrappers over the SQLite3 C
 * library (libsqlite3) connection / statement / cursor / pool
 * management intrinsics. They are implemented in C (see seeds) and
 * exposed to SHUX via `extern "C"` declarations.
 *
 * ABI: C (System V / AAPCS). Calling convention matches the C runtime
 * and libsqlite3's published C ABI (sqlite3_open / sqlite3_prepare_v2
 * / sqlite3_step / sqlite3_bind_* / sqlite3_column_* etc.).
 * PLATFORM: SHARED — libsqlite3 is available on all targets
 * (macOS arm64 / Ubuntu x86_64 / Windows MSYS2); when libsqlite3 is
 * absent, a stub backend is substituted by ensure_std_c_o (see
 * tests/lib/build-std-c-o.sh).
 *
 * Handle model:
 *   - DbConn   wraps a sqlite3* connection (i64 opaque)
 *   - DbStmt   wraps a sqlite3_stmt* prepared statement (i64 opaque)
 *   - DbRowCursor wraps a query cursor (i64 opaque)
 *   - DbPool   wraps a connection pool (i64 opaque)
 *   - DbError  {code: i32, msg: *u8} last-error snapshot
 *
 * Error codes (DB_*): DB_OK=0, DB_ERR_NULL=-1, DB_ERR_OPEN=-2,
 * DB_ERR_EXEC=-3, DB_ERR_BUSY=-4, DB_NOT_IMPL=-9; row codes:
 * DB_ROW_OK=1, DB_ROW_DONE=0.
 *
 * Unsafe contract: callers must wrap `db_*_c` calls in `unsafe { }`
 * blocks. P0a semantic downgrade currently allows unwrapped calls; P1
 * typeck enforcement (post-bootstrap) will reject unwrapped calls.
 */

/* See implementation. */
export const DB_OK: i32 = 0;
/* See implementation. */
export const DB_ERR_NULL: i32 = -1;
/* See implementation. */
export const DB_ERR_OPEN: i32 = -2;
/* See implementation. */
export const DB_ERR_EXEC: i32 = -3;
/* See implementation. */
export const DB_ERR_BUSY: i32 = -4;
/* See implementation. */
export const DB_NOT_IMPL: i32 = -9;
/* See implementation. */
export const DB_ROW_OK: i32 = 1;
/* See implementation. */
export const DB_ROW_DONE: i32 = 0;

/* See implementation. */
export struct DbConn {
  handle: i64;
}

/* See implementation. */
allow(padding) struct DbError {
  code: i32;
  msg: *u8;
}

/* See implementation. */
export struct DbRowCursor {
  cursor: i64;
}

/* See implementation. */
export struct DbStmt {
  handle: i64;
}

/* See implementation. */
export struct DbPool {
  handle: i64;
}

extern "C" function db_open_c(path: *u8): i64;
extern "C" function db_close_c(handle: i64): i32;
extern "C" function db_exec_c(handle: i64, sql: *u8): i32;
extern "C" function db_query_rows_c(handle: i64, sql: *u8): i32;
extern "C" function db_query_begin_c(handle: i64, sql: *u8): i64;
extern "C" function db_next_row_c(cursor: i64): i32;
extern "C" function db_row_col_i32_c(cursor: i64, col: i32): i32;
extern "C" function db_row_col_text_c(cursor: i64, col: i32, out_buf: *u8, out_cap: i32): i32;
extern "C" function db_row_col_blob_c(cursor: i64, col: i32, out_buf: *u8, out_cap: i32): i32;
extern "C" function db_row_col_blob_len_c(cursor: i64, col: i32): i32;
extern "C" function db_row_col_blob_read_c(cursor: i64, col: i32, offset: i32, out_buf: *u8, out_cap: i32): i32;
extern "C" function db_query_end_c(cursor: i64): i32;
extern "C" function db_begin_tx_c(handle: i64): i32;
extern "C" function db_commit_c(handle: i64): i32;
extern "C" function db_rollback_c(handle: i64): i32;
extern "C" function db_last_code_c(): i32;
extern "C" function db_last_error_msg_c(): *u8;
extern "C" function db_backend_name_c(): *u8;
extern "C" function db_changes_c(handle: i64): i32;
extern "C" function db_prepare_c(handle: i64, sql: *u8): i64;
extern "C" function db_prepare_cached_c(handle: i64, sql: *u8): i64;
extern "C" function db_stmt_bind_i32_c(stmt: i64, idx: i32, val: i32): i32;
extern "C" function db_stmt_bind_text_c(stmt: i64, idx: i32, text: *u8): i32;
extern "C" function db_stmt_step_c(stmt: i64): i32;
extern "C" function db_stmt_reset_c(stmt: i64): i32;
extern "C" function db_stmt_finalize_c(stmt: i64): i32;
extern "C" function db_stmt_cache_clear_c(handle: i64): i32;
extern "C" function db_pool_open_c(path: *u8, max_conns: i32): i64;
extern "C" function db_pool_close_c(pool: i64): i32;
extern "C" function db_pool_acquire_c(pool: i64): i64;
extern "C" function db_pool_release_c(pool: i64, conn: i64): i32;
extern "C" function db_pool_idle_c(pool: i64): i32;

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
  unsafe { return db_close_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `exec`.
 * Implements `exec`.
 * @param conn DbConn
 * @param sql *u8
 * @return i32
 */
export function exec(conn: DbConn, sql: *u8): i32 {
  unsafe { return db_exec_c(conn.handle, sql); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `rows`.
 * Implements `rows`.
 * @param conn DbConn
 * @param sql *u8
 * @return i32
 */
export function rows(conn: DbConn, sql: *u8): i32 {
  unsafe { return db_query_rows_c(conn.handle, sql); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `begin`.
 * Implements `begin`.
 * @param conn DbConn
 * @param sql *u8
 * @return DbRowCursor
 */
export function begin(conn: DbConn, sql: *u8): DbRowCursor {
  let _rc: DbRowCursor = 0;
  unsafe { _rc = DbRowCursor { cursor: db_query_begin_c(conn.handle, sql) }; }
  return _rc;
}

/** Exported function `next_row`.
 * Implements `next_row`.
 * @param cur DbRowCursor
 * @return i32
 */
export function next_row(cur: DbRowCursor): i32 {
  unsafe { return db_next_row_c(cur.cursor); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col`.
 * Implements `col`.
 * @param cur DbRowCursor
 * @param col i32
 * @return i32
 */
export function col(cur: DbRowCursor, col: i32): i32 {
  unsafe { return db_row_col_i32_c(cur.cursor, col); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_text`.
 * Implements `col_text`.
 * @param cur DbRowCursor
 * @param col i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function col_text(cur: DbRowCursor, col: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_text_c(cur.cursor, col, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_blob`.
 * Implements `col_blob`.
 * @param cur DbRowCursor
 * @param col i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function col_blob(cur: DbRowCursor, col: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_blob_c(cur.cursor, col, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_blob_len`.
 * Query helper `col_blob_len`.
 * @param cur DbRowCursor
 * @param col i32
 * @return i32
 */
export function col_blob_len(cur: DbRowCursor, col: i32): i32 {
  unsafe { return db_row_col_blob_len_c(cur.cursor, col); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_blob_read`.
 * Read path helper `col_blob_read`.
 * @param cur DbRowCursor
 * @param col i32
 * @param offset i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function col_blob_read(cur: DbRowCursor, col: i32, offset: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_blob_read_c(cur.cursor, col, offset, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `end`.
 * Implements `end`.
 * @param cur DbRowCursor
 * @return i32
 */
export function end(cur: DbRowCursor): i32 {
  unsafe { return db_query_end_c(cur.cursor); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `begin_tx`.
 * Implements `begin_tx`.
 * @param conn DbConn
 * @return i32
 */
export function begin_tx(conn: DbConn): i32 {
  unsafe { return db_begin_tx_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `commit`.
 * Implements `commit`.
 * @param conn DbConn
 * @return i32
 */
export function commit(conn: DbConn): i32 {
  unsafe { return db_commit_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `rollback`.
 * Implements `rollback`.
 * @param conn DbConn
 * @return i32
 */
export function rollback(conn: DbConn): i32 {
  unsafe { return db_rollback_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `last_error`.
 * Implements `last_error`.
 * @return DbError
 */
export function last_error(): DbError {
  let _rc: DbError = 0;
  unsafe { _rc = DbError {
      code: db_last_code_c(),
      msg: db_last_error_msg_c(),
    }; }
  return _rc;
}

/** Exported function `backend_name`.
 * Implements `backend_name`.
 * @return *u8
 */
export function backend_name(): *u8 {
  unsafe { return db_backend_name_c(); }
  return 0 as *u8; // unreachable — typeck workaround
}

/** Exported function `changes`.
 * Implements `changes`.
 * @param conn DbConn
 * @return i32
 */
export function changes(conn: DbConn): i32 {
  unsafe { return db_changes_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `prepare`.
 * Implements `prepare`.
 * @param conn DbConn
 * @param sql *u8
 * @return DbStmt
 */
export function prepare(conn: DbConn, sql: *u8): DbStmt {
  let _rc: DbStmt = 0;
  unsafe { _rc = DbStmt { handle: db_prepare_c(conn.handle, sql) }; }
  return _rc;
}

/** Exported function `prepare_cached`.
 * Implements `prepare_cached`.
 * @param conn DbConn
 * @param sql *u8
 * @return DbStmt
 */
export function prepare_cached(conn: DbConn, sql: *u8): DbStmt {
  let _rc: DbStmt = 0;
  unsafe { _rc = DbStmt { handle: db_prepare_cached_c(conn.handle, sql) }; }
  return _rc;
}

/** Exported function `bind`.
 * Implements `bind`.
 * @param stmt DbStmt
 * @param idx i32
 * @param val i32
 * @return i32
 */
export function bind(stmt: DbStmt, idx: i32, val: i32): i32 {
  unsafe { return db_stmt_bind_i32_c(stmt.handle, idx, val); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `bind`.
 * Implements `bind`.
 * @param stmt DbStmt
 * @param idx i32
 * @param text *u8
 * @return i32
 */
export function bind(stmt: DbStmt, idx: i32, text: *u8): i32 {
  unsafe { return db_stmt_bind_text_c(stmt.handle, idx, text); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `step`.
 * Implements `step`.
 * @param stmt DbStmt
 * @return i32
 */
export function step(stmt: DbStmt): i32 {
  unsafe { return db_stmt_step_c(stmt.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `reset`.
 * Implements `reset`.
 * @param stmt DbStmt
 * @return i32
 */
export function reset(stmt: DbStmt): i32 {
  unsafe { return db_stmt_reset_c(stmt.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `finalize`.
 * Implements `finalize`.
 * @param stmt DbStmt
 * @return i32
 */
export function finalize(stmt: DbStmt): i32 {
  unsafe { return db_stmt_finalize_c(stmt.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `cache_clear`.
 * Implements `cache_clear`.
 * @param conn DbConn
 * @return i32
 */
export function cache_clear(conn: DbConn): i32 {
  unsafe { return db_stmt_cache_clear_c(conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col`.
 * Implements `col`.
 * @param stmt DbStmt
 * @param col i32
 * @return i32
 */
export function col(stmt: DbStmt, col: i32): i32 {
  unsafe { return db_row_col_i32_c(stmt.handle, col); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_text`.
 * Implements `col_text`.
 * @param stmt DbStmt
 * @param col i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function col_text(stmt: DbStmt, col: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_text_c(stmt.handle, col, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_blob_len`.
 * Query helper `col_blob_len`.
 * @param stmt DbStmt
 * @param col i32
 * @return i32
 */
export function col_blob_len(stmt: DbStmt, col: i32): i32 {
  unsafe { return db_row_col_blob_len_c(stmt.handle, col); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `col_blob_read`.
 * Read path helper `col_blob_read`.
 * @param stmt DbStmt
 * @param col i32
 * @param offset i32
 * @param out *u8
 * @param cap i32
 * @return i32
 */
export function col_blob_read(stmt: DbStmt, col: i32, offset: i32, out: *u8, cap: i32): i32 {
  unsafe { return db_row_col_blob_read_c(stmt.handle, col, offset, out, cap); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `open`.
 * Implements `open`.
 * @param path *u8
 * @param max_conns i32
 * @return DbPool
 */
export function open(path: *u8, max_conns: i32): DbPool {
  let _rc: DbPool = 0;
  unsafe { _rc = DbPool { handle: db_pool_open_c(path, max_conns) }; }
  return _rc;
}

/** Exported function `close`.
 * Implements `close`.
 * @param pool DbPool
 * @return i32
 */
export function close(pool: DbPool): i32 {
  unsafe { return db_pool_close_c(pool.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `acquire`.
 * Implements `acquire`.
 * @param pool DbPool
 * @return DbConn
 */
export function acquire(pool: DbPool): DbConn {
  let _rc: DbConn = 0;
  unsafe { _rc = DbConn { handle: db_pool_acquire_c(pool.handle) }; }
  return _rc;
}

/** Exported function `release`.
 * Implements `release`.
 * @param pool DbPool
 * @param conn DbConn
 * @return i32
 */
export function release(pool: DbPool, conn: DbConn): i32 {
  unsafe { return db_pool_release_c(pool.handle, conn.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `idle`.
 * Implements `idle`.
 * @param pool DbPool
 * @return i32
 */
export function idle(pool: DbPool): i32 {
  unsafe { return db_pool_idle_c(pool.handle); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `is_available`.
 * Query helper `is_available`.
 * @return i32
 */
export function is_available(): i32 {
  let n: *u8 = backend_name();
  if (n[0] == 115 && n[1] == 113 && n[2] == 108 && n[3] == 105 && n[4] == 116 && n[5] == 101 && n[6] == 51) {
    return 1;
  }
  return 0;
}
