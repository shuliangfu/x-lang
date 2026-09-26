// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_sqlite_glue_stub_darwin.x — Darwin arm64 body of
// runtime_sqlite_glue_stub.o.
//
// This is the no-libsqlite3 face. Every call returns the stub code -9,
// or 0 for the column and handle readers. xlang_db_use_sqlite3_c returns
// 0 so the product does not pull libsqlite3. The real sqlite3 forwards
// stay in seeds/runtime_sqlite_glue.from_x.c under XLANG_DB_USE_SQLITE3.
// Linux and Windows keep that seed for the stub object too.
// PLATFORM: MACOS|DARWIN arm64 product. SHARED return codes.

/**
 * Report that this object is the stub, not libsqlite3.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_db_use_sqlite3_c(): i32 {
  return 0;
}

/**
 * Refuse to open a database. Clears the caller's handle slot when present.
 * @param path ignored path
 * @param out_db optional i64 slot for the handle
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_open_c(path: *u8, out_db: *i64): i32 {
  if (out_db != 0) {
    out_db[0] = 0;
  }
  return 0 - 9;
}

/**
 * Refuse to close a database.
 * @param db_h ignored handle
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_close_c(db_h: i64): i32 {
  return 0 - 9;
}

/**
 * Refuse to execute SQL. Clears the error-message slot when present.
 * @param db_h ignored handle
 * @param sql ignored statement
 * @param out_errmsg optional i64 slot
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_exec_c(db_h: i64, sql: *u8, out_errmsg: *i64): i32 {
  if (out_errmsg != 0) {
    out_errmsg[0] = 0;
  }
  return 0 - 9;
}

/**
 * Refuse to execute SQL with a row count. Clears both out slots.
 * @param db_h ignored handle
 * @param sql ignored statement
 * @param out_count optional i32 slot
 * @param out_errmsg optional i64 slot
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_exec_count_c(db_h: i64, sql: *u8, out_count: *i32, out_errmsg: *i64): i32 {
  if (out_count != 0) {
    out_count[0] = 0;
  }
  if (out_errmsg != 0) {
    out_errmsg[0] = 0;
  }
  return 0 - 9;
}

/**
 * Refuse to prepare a statement. Clears the statement slot when present.
 * @param db_h ignored handle
 * @param sql ignored statement
 * @param out_stmt optional i64 slot
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_prepare_v2_c(db_h: i64, sql: *u8, out_stmt: *i64): i32 {
  if (out_stmt != 0) {
    out_stmt[0] = 0;
  }
  return 0 - 9;
}

/**
 * Refuse to step a statement.
 * @param stmt_h ignored handle
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_step_c(stmt_h: i64): i32 {
  return 0 - 9;
}

/**
 * Refuse to finalize a statement.
 * @param stmt_h ignored handle
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_finalize_c(stmt_h: i64): i32 {
  return 0 - 9;
}

/**
 * Refuse to reset a statement.
 * @param stmt_h ignored handle
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_reset_c(stmt_h: i64): i32 {
  return 0 - 9;
}

/**
 * Refuse to clear bindings.
 * @param stmt_h ignored handle
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_clear_bindings_c(stmt_h: i64): i32 {
  return 0 - 9;
}

/**
 * Column count on the stub is 0.
 * @param stmt_h ignored handle
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_count_c(stmt_h: i64): i32 {
  return 0;
}

/**
 * Integer column on the stub is 0.
 * @param stmt_h ignored handle
 * @param col ignored index
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_int_c(stmt_h: i64, col: i32): i32 {
  return 0;
}

/**
 * Text column pointer on the stub is 0.
 * @param stmt_h ignored handle
 * @param col ignored index
 * @return i64 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_text_c(stmt_h: i64, col: i32): i64 {
  return 0;
}

/**
 * Blob column pointer on the stub is 0.
 * @param stmt_h ignored handle
 * @param col ignored index
 * @return i64 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_blob_c(stmt_h: i64, col: i32): i64 {
  return 0;
}

/**
 * Blob byte count on the stub is 0.
 * @param stmt_h ignored handle
 * @param col ignored index
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_bytes_c(stmt_h: i64, col: i32): i32 {
  return 0;
}

/**
 * Refuse to bind an integer.
 * @param stmt_h ignored handle
 * @param idx ignored index
 * @param val ignored value
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_bind_int_c(stmt_h: i64, idx: i32, val: i32): i32 {
  return 0 - 9;
}

/**
 * Refuse to bind text.
 * @param stmt_h ignored handle
 * @param idx ignored index
 * @param text ignored bytes
 * @return i32 — always -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_bind_text_c(stmt_h: i64, idx: i32, text: *u8): i32 {
  return 0 - 9;
}

/**
 * Error-message pointer on the stub is 0.
 * @param db_h ignored handle
 * @return i64 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_errmsg_c(db_h: i64): i64 {
  return 0;
}

/**
 * Database handle of a statement on the stub is 0.
 * @param stmt_h ignored handle
 * @return i64 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_db_handle_c(stmt_h: i64): i64 {
  return 0;
}

/**
 * Change count on the stub is 0.
 * @param db_h ignored handle
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_changes_c(db_h: i64): i32 {
  return 0;
}

/**
 * Free is a no-op on the stub. There is no sqlite3_free to call.
 * @param ptr ignored pointer
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_free_c(ptr: i64): void {
  return;
}
