// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_sqlite_glue_darwin.x — Darwin arm64 body of runtime_sqlite_glue.o.
//
// Forwards to libsqlite3. SQLITE_TRANSIENT is the sqlite3.h expansion
// ((sqlite3_destructor_type)-1), passed as the pointer value -1.
// The row-count callback is loaded with dlsym because a function name
// used as a pointer value makes this compiler exit 139.
// The no-libsqlite3 stub is a different object and stays in
// runtime_sqlite_glue_stub_darwin.x. Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64. SHARED return codes with the C seed.

extern function sqlite3_open(path: *u8, out_db: **u8): i32;
extern function sqlite3_close(db: *u8): i32;
extern function sqlite3_exec(db: *u8, sql: *u8, cb: *u8, ctx: *i32, err: **u8): i32;
extern function sqlite3_free(p: *u8): void;
extern function sqlite3_prepare_v2(db: *u8, sql: *u8, n: i32, out_stmt: **u8, tail: *u8): i32;
extern function sqlite3_step(stmt: *u8): i32;
extern function sqlite3_finalize(stmt: *u8): i32;
extern function sqlite3_reset(stmt: *u8): i32;
extern function sqlite3_clear_bindings(stmt: *u8): i32;
extern function sqlite3_column_count(stmt: *u8): i32;
extern function sqlite3_column_int(stmt: *u8, col: i32): i32;
extern function sqlite3_column_text(stmt: *u8, col: i32): *u8;
extern function sqlite3_column_blob(stmt: *u8, col: i32): *u8;
extern function sqlite3_column_bytes(stmt: *u8, col: i32): i32;
extern function sqlite3_bind_int(stmt: *u8, idx: i32, val: i32): i32;
extern function sqlite3_bind_text(stmt: *u8, idx: i32, text: *u8, n: i32, dtor: *u8): i32;
extern function sqlite3_errmsg(db: *u8): *u8;
extern function sqlite3_db_handle(stmt: *u8): *u8;
extern function sqlite3_changes(db: *u8): i32;
extern function dlsym(h: *u8, name: *u8): *u8;

/**
 * Report that this object calls libsqlite3.
 * @return i32 — always 1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_db_use_sqlite3_c(): i32 {
  return 1;
}

/**
 * sqlite3_exec row counter. Each row adds one to the i32 at ctx.
 * ncol, row, and col are unused; sqlite still passes them.
 * @param ctx optional i32 slot
 * @param ncol column count, ignored
 * @param row row pointers, ignored
 * @param col column names, ignored
 * @return i32 — always 0 so sqlite keeps walking
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_count_cb(ctx: *i32, ncol: i32, row: *u8, col: *u8): i32 {
  if (ctx == 0) { return 0; }
  ctx[0] = ctx[0] + 1;
  return 0;
}

/**
 * Open a database. A null slot or path returns -1. On failure the
 * handle is stored only when sqlite allocated one.
 * @param path NUL-terminated path, or ":memory:"
 * @param out_db required i64 slot for the sqlite3 pointer
 * @return i32 — sqlite3_open result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_open_c(path: *u8, out_db: *i64): i32 {
  let db: *u8 = 0;
  let rc: i32 = 0;
  if (out_db == 0) { return 0 - 1; }
  out_db[0] = 0;
  if (path == 0) { return 0 - 1; }
  unsafe { rc = sqlite3_open(path, &db); }
  if (rc != 0) {
    if (db != 0) { out_db[0] = db as i64; }
    return rc;
  }
  out_db[0] = db as i64;
  return 0;
}

/**
 * Close a database. A zero handle returns -1.
 * @param db_h sqlite3 pointer
 * @return i32 — sqlite3_close result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_close_c(db_h: i64): i32 {
  let db: *u8 = 0;
  let rc: i32 = 0;
  if (db_h == 0) { return 0 - 1; }
  db = db_h as *u8;
  unsafe { rc = sqlite3_close(db); }
  return rc;
}

/**
 * Execute SQL with no row callback. errmsg is stored for the caller
 * to release with xlang_sqlite3_free_c. A missing slot frees it here.
 * @param db_h sqlite3 pointer
 * @param sql NUL-terminated statement
 * @param out_errmsg optional i64 slot
 * @return i32 — sqlite3_exec result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_exec_c(db_h: i64, sql: *u8, out_errmsg: *i64): i32 {
  let db: *u8 = 0;
  let errp: *u8 = 0;
  let none: *u8 = 0;
  let noctx: *i32 = 0;
  let rc: i32 = 0;
  if (out_errmsg != 0) { out_errmsg[0] = 0; }
  if (db_h == 0 || sql == 0) { return 0 - 1; }
  db = db_h as *u8;
  unsafe { rc = sqlite3_exec(db, sql, none, noctx, &errp); }
  if (out_errmsg != 0) {
    out_errmsg[0] = errp as i64;
  } else if (errp != 0) {
    unsafe { sqlite3_free(errp); }
  }
  return rc;
}

/**
 * Load the row-count callback. A function name used as a pointer
 * makes this compiler exit 139, so the address comes from dlsym.
 * RTLD_DEFAULT is the pointer value -2.
 * @return *u8 — callback, or 0
 * PLATFORM: MACOS|DARWIN
 */
function sqlite_count_cb_ptr(): *u8 {
  let cb: *u8 = 0;
  let rtld: i64 = 0;
  rtld = 0 - 2;
  unsafe { cb = dlsym(rtld as *u8, "xlang_sqlite3_count_cb"); }
  return cb;
}

/**
 * Execute SQL and count rows. The callback lives in this object.
 * @param db_h sqlite3 pointer
 * @param sql NUL-terminated statement
 * @param out_count optional i32 slot
 * @param out_errmsg optional i64 slot
 * @return i32 — sqlite3_exec result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_exec_count_c(db_h: i64, sql: *u8, out_count: *i32, out_errmsg: *i64): i32 {
  let db: *u8 = 0;
  let errp: *u8 = 0;
  let cb: *u8 = 0;
  let count: i32 = 0;
  let rc: i32 = 0;
  if (out_count != 0) { out_count[0] = 0; }
  if (out_errmsg != 0) { out_errmsg[0] = 0; }
  if (db_h == 0 || sql == 0) { return 0 - 1; }
  cb = sqlite_count_cb_ptr();
  if (cb == 0) { return 0 - 1; }
  db = db_h as *u8;
  unsafe { rc = sqlite3_exec(db, sql, cb, &count, &errp); }
  if (out_count != 0) { out_count[0] = count; }
  if (out_errmsg != 0) {
    out_errmsg[0] = errp as i64;
  } else if (errp != 0) {
    unsafe { sqlite3_free(errp); }
  }
  return rc;
}

/**
 * Prepare one statement. The tail pointer is null.
 * @param db_h sqlite3 pointer
 * @param sql NUL-terminated statement
 * @param out_stmt optional i64 slot
 * @return i32 — sqlite3_prepare_v2 result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_prepare_v2_c(db_h: i64, sql: *u8, out_stmt: *i64): i32 {
  let db: *u8 = 0;
  let stmt: *u8 = 0;
  let tail: *u8 = 0;
  let rc: i32 = 0;
  if (out_stmt != 0) { out_stmt[0] = 0; }
  if (db_h == 0 || sql == 0) { return 0 - 1; }
  db = db_h as *u8;
  unsafe { rc = sqlite3_prepare_v2(db, sql, 0 - 1, &stmt, tail); }
  if (rc == 0 && out_stmt != 0) { out_stmt[0] = stmt as i64; }
  return rc;
}

/**
 * Step a prepared statement. A zero handle returns -1.
 * @param stmt_h sqlite3_stmt pointer
 * @return i32 — sqlite3_step result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_step_c(stmt_h: i64): i32 {
  let stmt: *u8 = 0;
  let rc: i32 = 0;
  if (stmt_h == 0) { return 0 - 1; }
  stmt = stmt_h as *u8;
  unsafe { rc = sqlite3_step(stmt); }
  return rc;
}

/**
 * Finalize a prepared statement. A zero handle returns -1.
 * @param stmt_h sqlite3_stmt pointer
 * @return i32 — sqlite3_finalize result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_finalize_c(stmt_h: i64): i32 {
  let stmt: *u8 = 0;
  let rc: i32 = 0;
  if (stmt_h == 0) { return 0 - 1; }
  stmt = stmt_h as *u8;
  unsafe { rc = sqlite3_finalize(stmt); }
  return rc;
}

/**
 * Reset a prepared statement. A zero handle returns -1.
 * @param stmt_h sqlite3_stmt pointer
 * @return i32 — sqlite3_reset result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_reset_c(stmt_h: i64): i32 {
  let stmt: *u8 = 0;
  let rc: i32 = 0;
  if (stmt_h == 0) { return 0 - 1; }
  stmt = stmt_h as *u8;
  unsafe { rc = sqlite3_reset(stmt); }
  return rc;
}

/**
 * Clear bindings. A zero handle returns -1.
 * @param stmt_h sqlite3_stmt pointer
 * @return i32 — sqlite3_clear_bindings result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_clear_bindings_c(stmt_h: i64): i32 {
  let stmt: *u8 = 0;
  let rc: i32 = 0;
  if (stmt_h == 0) { return 0 - 1; }
  stmt = stmt_h as *u8;
  unsafe { rc = sqlite3_clear_bindings(stmt); }
  return rc;
}

/**
 * Column count. A zero handle returns 0.
 * @param stmt_h sqlite3_stmt pointer
 * @return i32 — column count, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_count_c(stmt_h: i64): i32 {
  let stmt: *u8 = 0;
  let n: i32 = 0;
  if (stmt_h == 0) { return 0; }
  stmt = stmt_h as *u8;
  unsafe { n = sqlite3_column_count(stmt); }
  return n;
}

/**
 * Integer column. A zero handle returns 0.
 * @param stmt_h sqlite3_stmt pointer
 * @param col zero-based column
 * @return i32 — column value, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_int_c(stmt_h: i64, col: i32): i32 {
  let stmt: *u8 = 0;
  let n: i32 = 0;
  if (stmt_h == 0) { return 0; }
  stmt = stmt_h as *u8;
  unsafe { n = sqlite3_column_int(stmt, col); }
  return n;
}

/**
 * Text column pointer. A null column returns 0.
 * @param stmt_h sqlite3_stmt pointer
 * @param col zero-based column
 * @return i64 — pointer, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_text_c(stmt_h: i64, col: i32): i64 {
  let stmt: *u8 = 0;
  let txt: *u8 = 0;
  if (stmt_h == 0) { return 0; }
  stmt = stmt_h as *u8;
  unsafe { txt = sqlite3_column_text(stmt, col); }
  if (txt == 0) { return 0; }
  return txt as i64;
}

/**
 * Blob column pointer. A null column returns 0.
 * @param stmt_h sqlite3_stmt pointer
 * @param col zero-based column
 * @return i64 — pointer, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_blob_c(stmt_h: i64, col: i32): i64 {
  let stmt: *u8 = 0;
  let blob: *u8 = 0;
  if (stmt_h == 0) { return 0; }
  stmt = stmt_h as *u8;
  unsafe { blob = sqlite3_column_blob(stmt, col); }
  if (blob == 0) { return 0; }
  return blob as i64;
}

/**
 * Blob or text byte count. A zero handle returns 0.
 * @param stmt_h sqlite3_stmt pointer
 * @param col zero-based column
 * @return i32 — byte count, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_column_bytes_c(stmt_h: i64, col: i32): i32 {
  let stmt: *u8 = 0;
  let n: i32 = 0;
  if (stmt_h == 0) { return 0; }
  stmt = stmt_h as *u8;
  unsafe { n = sqlite3_column_bytes(stmt, col); }
  return n;
}

/**
 * Bind an integer. Index starts at 1. A zero handle returns -1.
 * @param stmt_h sqlite3_stmt pointer
 * @param idx one-based index
 * @param val integer value
 * @return i32 — sqlite3_bind_int result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_bind_int_c(stmt_h: i64, idx: i32, val: i32): i32 {
  let stmt: *u8 = 0;
  let rc: i32 = 0;
  if (stmt_h == 0) { return 0 - 1; }
  stmt = stmt_h as *u8;
  unsafe { rc = sqlite3_bind_int(stmt, idx, val); }
  return rc;
}

/**
 * Bind text. Length -1 asks sqlite to measure the C string.
 * The destructor argument is SQLITE_TRANSIENT, the pointer value -1,
 * so sqlite copies the bytes before this function returns.
 * @param stmt_h sqlite3_stmt pointer
 * @param idx one-based index
 * @param text NUL-terminated text, or null
 * @return i32 — sqlite3_bind_text result, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_bind_text_c(stmt_h: i64, idx: i32, text: *u8): i32 {
  let stmt: *u8 = 0;
  let dtor: i64 = 0;
  let rc: i32 = 0;
  if (stmt_h == 0) { return 0 - 1; }
  stmt = stmt_h as *u8;
  dtor = 0 - 1;
  unsafe { rc = sqlite3_bind_text(stmt, idx, text, 0 - 1, dtor as *u8); }
  return rc;
}

/**
 * Error message pointer. A zero handle returns 0.
 * @param db_h sqlite3 pointer
 * @return i64 — pointer, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_errmsg_c(db_h: i64): i64 {
  let db: *u8 = 0;
  let em: *u8 = 0;
  if (db_h == 0) { return 0; }
  db = db_h as *u8;
  unsafe { em = sqlite3_errmsg(db); }
  if (em == 0) { return 0; }
  return em as i64;
}

/**
 * Database that owns a statement. A zero handle returns 0.
 * @param stmt_h sqlite3_stmt pointer
 * @return i64 — sqlite3 pointer, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_db_handle_c(stmt_h: i64): i64 {
  let stmt: *u8 = 0;
  let db: *u8 = 0;
  if (stmt_h == 0) { return 0; }
  stmt = stmt_h as *u8;
  unsafe { db = sqlite3_db_handle(stmt); }
  if (db == 0) { return 0; }
  return db as i64;
}

/**
 * Rows changed by the last statement. A zero handle returns 0.
 * @param db_h sqlite3 pointer
 * @return i32 — change count, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_changes_c(db_h: i64): i32 {
  let db: *u8 = 0;
  let n: i32 = 0;
  if (db_h == 0) { return 0; }
  db = db_h as *u8;
  unsafe { n = sqlite3_changes(db); }
  return n;
}

/**
 * Release a pointer from sqlite3_exec's errmsg slot.
 * A zero pointer is a no-op.
 * @param ptr sqlite-allocated pointer
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_sqlite3_free_c(ptr: i64): void {
  let p: *u8 = 0;
  if (ptr == 0) { return; }
  p = ptr as *u8;
  unsafe { sqlite3_free(p); }
}
