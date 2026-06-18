/**
 * std/sqlite/sqlite.c — SQLite3 后端与 stub 回退（STD-057）
 *
 * 【文件职责】
 * db_open_c / db_close_c / db_exec_c / 事务 API；默认 SHU_DB_USE_SQLITE3（SQLite3 后端）。
 * 无 SHU_DB_USE_SQLITE3（make sqlite-o-stub）时返回 DB_NOT_IMPL。
 * STD-065：db_sqlite_tx_exec_smoke_c 事务 exec 烟测（begin/commit/rollback）。
 * STD-066：db_query_rows_c 返回 SELECT 行数；db_sqlite_query_rows_smoke_c 行迭代烟测。
 * STD-067：db_query_begin_c / db_next_row_c / db_row_col_i32_c 列值游标；db_sqlite_next_row_smoke_c 烟测。
 * STD-068：db_row_col_text_c 文本列拷贝；db_sqlite_row_col_text_smoke_c 烟测。
 * STD-069：db_row_col_blob_c BLOB 列拷贝；db_sqlite_row_col_blob_smoke_c 烟测。
 * STD-070：db_prepare_c / db_prepare_cached_c / stmt_bind / stmt_cache；db_sqlite_stmt_bind_smoke_c 烟测。
 * STD-084：db_pool_* 连接池 acquire/release；db_sqlite_pool_smoke_c 烟测。
 * 【所属模块】标准库 std.sqlite；与 std/sqlite/mod.su 同属一模块。
 * 【依赖】可选 -lsqlite3（gate 与 sqlite-o 目标）。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** 与 mod.su DB_* 常量一致。 */
enum {
  DB_OK = 0,
  DB_ERR_NULL = -1,
  DB_ERR_OPEN = -2,
  DB_ERR_EXEC = -3,
  DB_ERR_BUSY = -4,
  DB_NOT_IMPL = -9,
};

/** 线程局部错误快照（v1 原型用进程静态缓冲）。 */
typedef struct {
  int32_t code;
  char msg[160];
} db_err_slot_t;

static db_err_slot_t g_db_last_err;

static void db_set_err(int32_t code, const char *msg) {
  g_db_last_err.code = code;
  if (!msg || !msg[0]) {
    g_db_last_err.msg[0] = '\0';
    return;
  }
  snprintf(g_db_last_err.msg, sizeof(g_db_last_err.msg), "%s", msg);
}

static void db_clear_err(void) {
  g_db_last_err.code = DB_OK;
  g_db_last_err.msg[0] = '\0';
}

#ifdef SHU_DB_USE_SQLITE3
#include <sqlite3.h>

static sqlite3 *db_handle_ptr(int64_t handle) {
  if (handle == 0) return NULL;
  return (sqlite3 *)(uintptr_t)handle;
}

/** STD-070：连接级预编译语句缓存（v1 线性表，最多 16 条）。 */
#define DB_STMT_CACHE_CAP 16
#define DB_STMT_SQL_MAX 240

typedef struct {
  int64_t conn;
  char sql[DB_STMT_SQL_MAX];
  sqlite3_stmt *stmt;
} db_cached_stmt_t;

static db_cached_stmt_t g_db_stmt_cache[DB_STMT_CACHE_CAP];

/** 释放指定连接上的全部缓存语句。 */
static void db_stmt_cache_drop_conn(int64_t conn) {
  int i;
  for (i = 0; i < DB_STMT_CACHE_CAP; i++) {
    if (g_db_stmt_cache[i].conn == conn && g_db_stmt_cache[i].stmt) {
      sqlite3_finalize(g_db_stmt_cache[i].stmt);
      g_db_stmt_cache[i].conn = 0;
      g_db_stmt_cache[i].sql[0] = '\0';
      g_db_stmt_cache[i].stmt = NULL;
    }
  }
}

/** 按连接 + SQL 查找缓存项。 */
static db_cached_stmt_t *db_stmt_cache_find(int64_t conn, const char *sql) {
  int i;
  for (i = 0; i < DB_STMT_CACHE_CAP; i++) {
    if (g_db_stmt_cache[i].conn == conn && g_db_stmt_cache[i].stmt &&
        strcmp(g_db_stmt_cache[i].sql, sql) == 0) {
      return &g_db_stmt_cache[i];
    }
  }
  return NULL;
}

/** 分配缓存槽；满则驱逐首项。 */
static db_cached_stmt_t *db_stmt_cache_alloc_slot(void) {
  int i;
  for (i = 0; i < DB_STMT_CACHE_CAP; i++) {
    if (g_db_stmt_cache[i].stmt == NULL) {
      return &g_db_stmt_cache[i];
    }
  }
  if (g_db_stmt_cache[0].stmt) {
    sqlite3_finalize(g_db_stmt_cache[0].stmt);
    g_db_stmt_cache[0].conn = 0;
    g_db_stmt_cache[0].sql[0] = '\0';
    g_db_stmt_cache[0].stmt = NULL;
  }
  return &g_db_stmt_cache[0];
}

/** 从缓存移除指定 stmt（finalize 前调用）。 */
static void db_stmt_cache_remove_stmt(sqlite3_stmt *stmt) {
  int i;
  if (!stmt) return;
  for (i = 0; i < DB_STMT_CACHE_CAP; i++) {
    if (g_db_stmt_cache[i].stmt == stmt) {
      g_db_stmt_cache[i].conn = 0;
      g_db_stmt_cache[i].sql[0] = '\0';
      g_db_stmt_cache[i].stmt = NULL;
      return;
    }
  }
}

/** 打开数据库；失败返回 handle=0。 */
int64_t db_open_c(const uint8_t *path) {
  sqlite3 *db = NULL;
  int rc;
  if (!path) {
    db_set_err(DB_ERR_NULL, "null path");
    return 0;
  }
  db_clear_err();
  rc = sqlite3_open((const char *)path, &db);
  if (rc != SQLITE_OK) {
    const char *em = db ? sqlite3_errmsg(db) : "sqlite3_open failed";
    db_set_err(DB_ERR_OPEN, em);
    if (db) sqlite3_close(db);
    return 0;
  }
  return (int64_t)(uintptr_t)db;
}

/** 关闭连接（并释放该连接 stmt 缓存）。 */
int32_t db_close_c(int64_t handle) {
  sqlite3 *db = db_handle_ptr(handle);
  int rc;
  if (!db) {
    db_set_err(DB_ERR_NULL, "null handle");
    return DB_ERR_NULL;
  }
  db_stmt_cache_drop_conn(handle);
  rc = sqlite3_close(db);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_BUSY, sqlite3_errmsg(db));
    return DB_ERR_BUSY;
  }
  db_clear_err();
  return DB_OK;
}

/** 执行无结果集 SQL。 */
int32_t db_exec_c(int64_t handle, const uint8_t *sql) {
  sqlite3 *db = db_handle_ptr(handle);
  char *errmsg = NULL;
  int rc;
  if (!db) {
    db_set_err(DB_ERR_NULL, "null handle");
    return DB_ERR_NULL;
  }
  if (!sql) {
    db_set_err(DB_ERR_NULL, "null sql");
    return DB_ERR_NULL;
  }
  rc = sqlite3_exec(db, (const char *)sql, NULL, NULL, &errmsg);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, errmsg ? errmsg : "exec failed");
    sqlite3_free(errmsg);
    return DB_ERR_EXEC;
  }
  sqlite3_free(errmsg);
  db_clear_err();
  return DB_OK;
}

/** 查询行集：v1 原型返回 SELECT 匹配行数（sqlite3 回调计数）。 */
static int db_query_count_cb(void *ctx, int ncol, char **row, char **col) {
  (void)ncol;
  (void)row;
  (void)col;
  if (ctx) {
    (*(int32_t *)ctx) += 1;
  }
  return 0;
}

int32_t db_query_rows_c(int64_t handle, const uint8_t *sql) {
  sqlite3 *db = db_handle_ptr(handle);
  char *errmsg = NULL;
  int32_t count = 0;
  int rc;
  if (!db) {
    db_set_err(DB_ERR_NULL, "null handle");
    return DB_ERR_NULL;
  }
  if (!sql) {
    db_set_err(DB_ERR_NULL, "null sql");
    return DB_ERR_NULL;
  }
  rc = sqlite3_exec(db, (const char *)sql, db_query_count_cb, &count, &errmsg);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, errmsg ? errmsg : "query failed");
    sqlite3_free(errmsg);
    return DB_ERR_EXEC;
  }
  sqlite3_free(errmsg);
  db_clear_err();
  return count;
}

/** 游标句柄：映射 sqlite3_stmt*。 */
static sqlite3_stmt *db_cursor_stmt(int64_t cursor) {
  if (cursor == 0) return NULL;
  return (sqlite3_stmt *)(uintptr_t)cursor;
}

/** 准备 SELECT 游标；失败返回 cursor=0。 */
int64_t db_query_begin_c(int64_t handle, const uint8_t *sql) {
  sqlite3 *db = db_handle_ptr(handle);
  sqlite3_stmt *stmt = NULL;
  int rc;
  if (!db) {
    db_set_err(DB_ERR_NULL, "null handle");
    return 0;
  }
  if (!sql) {
    db_set_err(DB_ERR_NULL, "null sql");
    return 0;
  }
  rc = sqlite3_prepare_v2(db, (const char *)sql, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, sqlite3_errmsg(db));
    return 0;
  }
  db_clear_err();
  return (int64_t)(uintptr_t)stmt;
}

/** 推进游标：1=有行，0=结束，<0=错误。 */
int32_t db_next_row_c(int64_t cursor) {
  sqlite3_stmt *stmt = db_cursor_stmt(cursor);
  int rc;
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null cursor");
    return DB_ERR_NULL;
  }
  rc = sqlite3_step(stmt);
  if (rc == SQLITE_ROW) return 1;
  if (rc == SQLITE_DONE) {
    db_clear_err();
    return 0;
  }
  db_set_err(DB_ERR_EXEC, sqlite3_errmsg(sqlite3_db_handle(stmt)));
  return DB_ERR_EXEC;
}

/** 读取当前行列值（i32）；列越界返回 DB_ERR_EXEC。 */
int32_t db_row_col_i32_c(int64_t cursor, int32_t col) {
  sqlite3_stmt *stmt = db_cursor_stmt(cursor);
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null cursor");
    return DB_ERR_NULL;
  }
  if (col < 0 || col >= sqlite3_column_count(stmt)) {
    db_set_err(DB_ERR_EXEC, "col index");
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return (int32_t)sqlite3_column_int(stmt, col);
}

/** 读取当前行文本列到 out_buf；成功返回字节长度（不含 NUL），NULL 列返回 0。 */
int32_t db_row_col_text_c(int64_t cursor, int32_t col, uint8_t *out_buf, int32_t out_cap) {
  sqlite3_stmt *stmt = db_cursor_stmt(cursor);
  const unsigned char *txt;
  int32_t n;
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null cursor");
    return DB_ERR_NULL;
  }
  if (col < 0 || col >= sqlite3_column_count(stmt)) {
    db_set_err(DB_ERR_EXEC, "col index");
    return DB_ERR_EXEC;
  }
  if (!out_buf || out_cap <= 0) {
    db_set_err(DB_ERR_NULL, "null buf");
    return DB_ERR_NULL;
  }
  txt = sqlite3_column_text(stmt, col);
  if (!txt) {
    out_buf[0] = '\0';
    db_clear_err();
    return 0;
  }
  n = (int32_t)strlen((const char *)txt);
  if (n + 1 > out_cap) {
    db_set_err(DB_ERR_EXEC, "buf small");
    return DB_ERR_EXEC;
  }
  memcpy(out_buf, txt, (size_t)n + 1);
  db_clear_err();
  return n;
}

/** 读取当前行 BLOB 列到 out_buf；成功返回字节长度，NULL 列返回 0。 */
int32_t db_row_col_blob_c(int64_t cursor, int32_t col, uint8_t *out_buf, int32_t out_cap) {
  sqlite3_stmt *stmt = db_cursor_stmt(cursor);
  const void *blob;
  int32_t n;
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null cursor");
    return DB_ERR_NULL;
  }
  if (col < 0 || col >= sqlite3_column_count(stmt)) {
    db_set_err(DB_ERR_EXEC, "col index");
    return DB_ERR_EXEC;
  }
  if (!out_buf || out_cap <= 0) {
    db_set_err(DB_ERR_NULL, "null buf");
    return DB_ERR_NULL;
  }
  n = (int32_t)sqlite3_column_bytes(stmt, col);
  if (n <= 0) {
    db_clear_err();
    return 0;
  }
  blob = sqlite3_column_blob(stmt, col);
  if (!blob) {
    db_clear_err();
    return 0;
  }
  if (n > out_cap) {
    db_set_err(DB_ERR_EXEC, "buf small");
    return DB_ERR_EXEC;
  }
  memcpy(out_buf, blob, (size_t)n);
  db_clear_err();
  return n;
}

/** 释放游标（finalize，并从 stmt 缓存移除）。 */
int32_t db_query_end_c(int64_t cursor) {
  sqlite3_stmt *stmt = db_cursor_stmt(cursor);
  int rc;
  if (!stmt) return DB_OK;
  db_stmt_cache_remove_stmt(stmt);
  rc = sqlite3_finalize(stmt);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_BUSY, "finalize failed");
    return DB_ERR_BUSY;
  }
  db_clear_err();
  return DB_OK;
}

/** STD-070：预编译 SQL（独立 finalize，不入缓存）。 */
int64_t db_prepare_c(int64_t handle, const uint8_t *sql) {
  return db_query_begin_c(handle, sql);
}

/** STD-070：预编译并缓存（同 SQL 复用 sqlite3_stmt*）。 */
int64_t db_prepare_cached_c(int64_t handle, const uint8_t *sql) {
  sqlite3 *db = db_handle_ptr(handle);
  db_cached_stmt_t *slot;
  sqlite3_stmt *stmt = NULL;
  int rc;
  const char *sql_c;
  if (!db) {
    db_set_err(DB_ERR_NULL, "null handle");
    return 0;
  }
  if (!sql) {
    db_set_err(DB_ERR_NULL, "null sql");
    return 0;
  }
  sql_c = (const char *)sql;
  if (strlen(sql_c) >= DB_STMT_SQL_MAX) {
    db_set_err(DB_ERR_EXEC, "sql too long for cache");
    return 0;
  }
  slot = db_stmt_cache_find(handle, sql_c);
  if (slot) {
    sqlite3_reset(slot->stmt);
    sqlite3_clear_bindings(slot->stmt);
    db_clear_err();
    return (int64_t)(uintptr_t)slot->stmt;
  }
  rc = sqlite3_prepare_v2(db, sql_c, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, sqlite3_errmsg(db));
    return 0;
  }
  slot = db_stmt_cache_alloc_slot();
  slot->conn = handle;
  snprintf(slot->sql, sizeof(slot->sql), "%s", sql_c);
  slot->stmt = stmt;
  db_clear_err();
  return (int64_t)(uintptr_t)stmt;
}

/** STD-070：绑定整型参数（idx 为 1 起始 SQLite 约定）。 */
int32_t db_stmt_bind_i32_c(int64_t stmt_h, int32_t idx, int32_t val) {
  sqlite3_stmt *stmt = db_cursor_stmt(stmt_h);
  int rc;
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null stmt");
    return DB_ERR_NULL;
  }
  if (idx < 1) {
    db_set_err(DB_ERR_EXEC, "bind idx");
    return DB_ERR_EXEC;
  }
  rc = sqlite3_bind_int(stmt, idx, val);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, sqlite3_errmsg(sqlite3_db_handle(stmt)));
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return DB_OK;
}

/** STD-070：绑定文本参数（idx 为 1 起始）。 */
int32_t db_stmt_bind_text_c(int64_t stmt_h, int32_t idx, const uint8_t *text) {
  sqlite3_stmt *stmt = db_cursor_stmt(stmt_h);
  int rc;
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null stmt");
    return DB_ERR_NULL;
  }
  if (idx < 1) {
    db_set_err(DB_ERR_EXEC, "bind idx");
    return DB_ERR_EXEC;
  }
  rc = sqlite3_bind_text(stmt, idx, text ? (const char *)text : NULL, -1, SQLITE_TRANSIENT);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, sqlite3_errmsg(sqlite3_db_handle(stmt)));
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return DB_OK;
}

/** STD-070：执行一步：1=有行，0=完成，<0=错误。 */
int32_t db_stmt_step_c(int64_t stmt_h) {
  return db_next_row_c(stmt_h);
}

/** STD-070：重置预编译语句以便复用。 */
int32_t db_stmt_reset_c(int64_t stmt_h) {
  sqlite3_stmt *stmt = db_cursor_stmt(stmt_h);
  int rc;
  if (!stmt) {
    db_set_err(DB_ERR_NULL, "null stmt");
    return DB_ERR_NULL;
  }
  rc = sqlite3_reset(stmt);
  if (rc != SQLITE_OK) {
    db_set_err(DB_ERR_EXEC, sqlite3_errmsg(sqlite3_db_handle(stmt)));
    return DB_ERR_EXEC;
  }
  db_clear_err();
  return DB_OK;
}

/** STD-070：释放预编译语句（并从缓存移除）。 */
int32_t db_stmt_finalize_c(int64_t stmt_h) {
  return db_query_end_c(stmt_h);
}

/** STD-070：清空连接上全部 stmt 缓存（不关闭连接）。 */
int32_t db_stmt_cache_clear_c(int64_t handle) {
  if (!db_handle_ptr(handle)) {
    db_set_err(DB_ERR_NULL, "null handle");
    return DB_ERR_NULL;
  }
  db_stmt_cache_drop_conn(handle);
  db_clear_err();
  return DB_OK;
}

/** 开始事务（BEGIN IMMEDIATE）。 */
int32_t db_begin_tx_c(int64_t handle) {
  return db_exec_c(handle, (const uint8_t *)"BEGIN IMMEDIATE;");
}

/** 提交事务。 */
int32_t db_commit_c(int64_t handle) {
  return db_exec_c(handle, (const uint8_t *)"COMMIT;");
}

/** 回滚事务。 */
int32_t db_rollback_c(int64_t handle) {
  return db_exec_c(handle, (const uint8_t *)"ROLLBACK;");
}

/** 读取最后一次库错误码。 */
int32_t db_last_error_code_c(void) {
  return g_db_last_err.code;
}

/** 读取最后一次库错误消息（静态缓冲）。 */
const uint8_t *db_last_error_msg_c(void) {
  if (!g_db_last_err.msg[0]) return NULL;
  return (const uint8_t *)g_db_last_err.msg;
}

/** 当前后端名称。 */
const uint8_t *db_backend_name_c(void) {
  static const uint8_t name[] = "sqlite3";
  return name;
}

/** 返回最近一次 exec 影响行数（仅 SQLite 路径有效）。 */
int32_t db_changes_c(int64_t handle) {
  sqlite3 *db = db_handle_ptr(handle);
  if (!db) return 0;
  return (int32_t)sqlite3_changes(db);
}

/** C 烟测：内存库 exec 往返（CREATE / INSERT / changes）。 */
int32_t db_sqlite_exec_smoke_c(void) {
  int64_t h;
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (42);") != DB_OK) {
    db_close_c(h);
    return 4;
  }
  if (db_changes_c(h) != 1) {
    db_close_c(h);
    return 5;
  }
  if (db_close_c(h) != DB_OK) return 6;
  return 0;
}

/** C 烟测：事务 exec 往返（begin/commit + rollback）。 */
int32_t db_sqlite_tx_exec_smoke_c(void) {
  int64_t h;
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  if (db_begin_tx_c(h) != DB_OK) {
    db_close_c(h);
    return 4;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (7);") != DB_OK) {
    db_rollback_c(h);
    db_close_c(h);
    return 5;
  }
  if (db_changes_c(h) != 1) {
    db_rollback_c(h);
    db_close_c(h);
    return 6;
  }
  if (db_commit_c(h) != DB_OK) {
    db_close_c(h);
    return 7;
  }
  if (db_begin_tx_c(h) != DB_OK) {
    db_close_c(h);
    return 8;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (99);") != DB_OK) {
    db_rollback_c(h);
    db_close_c(h);
    return 9;
  }
  if (db_rollback_c(h) != DB_OK) {
    db_close_c(h);
    return 10;
  }
  if (db_close_c(h) != DB_OK) return 11;
  return 0;
}

/** C 烟测：query_rows 行迭代计数（SELECT 匹配行数）。 */
int32_t db_sqlite_query_rows_smoke_c(void) {
  int64_t h;
  int32_t rows;
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (1);") != DB_OK) {
    db_close_c(h);
    return 4;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (2);") != DB_OK) {
    db_close_c(h);
    return 5;
  }
  rows = db_query_rows_c(h, (const uint8_t *)"SELECT k FROM t;");
  if (rows != 2) {
    db_close_c(h);
    return 6;
  }
  rows = db_query_rows_c(h, (const uint8_t *)"SELECT k FROM t WHERE k=1;");
  if (rows != 1) {
    db_close_c(h);
    return 7;
  }
  if (db_close_c(h) != DB_OK) return 8;
  return 0;
}

/** C 烟测：next_row 列值游标迭代（ORDER BY k 读 1、2）。 */
int32_t db_sqlite_next_row_smoke_c(void) {
  int64_t h;
  int64_t cur;
  int32_t st;
  int32_t v;
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (2);") != DB_OK) {
    db_close_c(h);
    return 4;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k) VALUES (1);") != DB_OK) {
    db_close_c(h);
    return 5;
  }
  cur = db_query_begin_c(h, (const uint8_t *)"SELECT k FROM t ORDER BY k;");
  if (!cur) {
    db_close_c(h);
    return 6;
  }
  st = db_next_row_c(cur);
  if (st != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 7;
  }
  v = db_row_col_i32_c(cur, 0);
  if (v != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 8;
  }
  st = db_next_row_c(cur);
  if (st != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 9;
  }
  v = db_row_col_i32_c(cur, 0);
  if (v != 2) {
    db_query_end_c(cur);
    db_close_c(h);
    return 10;
  }
  st = db_next_row_c(cur);
  if (st != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 11;
  }
  if (db_query_end_c(cur) != DB_OK) {
    db_close_c(h);
    return 12;
  }
  if (db_close_c(h) != DB_OK) return 13;
  return 0;
}

/** C 烟测：row_col_text 文本列游标（ORDER BY k 读 alpha、beta）。 */
int32_t db_sqlite_row_col_text_smoke_c(void) {
  int64_t h;
  int64_t cur;
  int32_t st;
  int32_t n;
  uint8_t buf[32];
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER, name TEXT);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k,name) VALUES (2,'beta');") != DB_OK) {
    db_close_c(h);
    return 4;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k,name) VALUES (1,'alpha');") != DB_OK) {
    db_close_c(h);
    return 5;
  }
  cur = db_query_begin_c(h, (const uint8_t *)"SELECT name FROM t ORDER BY k;");
  if (!cur) {
    db_close_c(h);
    return 6;
  }
  st = db_next_row_c(cur);
  if (st != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 7;
  }
  n = db_row_col_text_c(cur, 0, buf, (int32_t)sizeof(buf));
  if (n != 5 || strcmp((const char *)buf, "alpha") != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 8;
  }
  st = db_next_row_c(cur);
  if (st != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 9;
  }
  n = db_row_col_text_c(cur, 0, buf, (int32_t)sizeof(buf));
  if (n != 4 || strcmp((const char *)buf, "beta") != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 10;
  }
  st = db_next_row_c(cur);
  if (st != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 11;
  }
  if (db_query_end_c(cur) != DB_OK) {
    db_close_c(h);
    return 12;
  }
  if (db_close_c(h) != DB_OK) return 13;
  return 0;
}

/** C 烟测：row_col_blob BLOB 列游标（ORDER BY k 读 3/4 字节）。 */
int32_t db_sqlite_row_col_blob_smoke_c(void) {
  int64_t h;
  int64_t cur;
  int32_t st;
  int32_t n;
  uint8_t buf[32];
  static const uint8_t expect3[] = {1, 2, 3};
  static const uint8_t expect4[] = {10, 11, 12, 13};
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER, data BLOB);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k,data) VALUES (2,x'0a0b0c0d');") != DB_OK) {
    db_close_c(h);
    return 4;
  }
  if (db_exec_c(h, (const uint8_t *)"INSERT INTO t(k,data) VALUES (1,x'010203');") != DB_OK) {
    db_close_c(h);
    return 5;
  }
  cur = db_query_begin_c(h, (const uint8_t *)"SELECT data FROM t ORDER BY k;");
  if (!cur) {
    db_close_c(h);
    return 6;
  }
  st = db_next_row_c(cur);
  if (st != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 7;
  }
  n = db_row_col_blob_c(cur, 0, buf, (int32_t)sizeof(buf));
  if (n != 3 || memcmp(buf, expect3, 3) != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 8;
  }
  st = db_next_row_c(cur);
  if (st != 1) {
    db_query_end_c(cur);
    db_close_c(h);
    return 9;
  }
  n = db_row_col_blob_c(cur, 0, buf, (int32_t)sizeof(buf));
  if (n != 4 || memcmp(buf, expect4, 4) != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 10;
  }
  st = db_next_row_c(cur);
  if (st != 0) {
    db_query_end_c(cur);
    db_close_c(h);
    return 11;
  }
  if (db_query_end_c(cur) != DB_OK) {
    db_close_c(h);
    return 12;
  }
  if (db_close_c(h) != DB_OK) return 13;
  return 0;
}

/** C 烟测：预编译 bind + stmt 缓存（INSERT ? / SELECT WHERE k=?）。 */
int32_t db_sqlite_stmt_bind_smoke_c(void) {
  int64_t h;
  int64_t ins;
  int64_t sel;
  int64_t sel2;
  int32_t st;
  int32_t n;
  uint8_t buf[32];
  if (db_backend_name_c()[0] != 's') return 1;
  h = db_open_c((const uint8_t *)":memory:");
  if (!h) return 2;
  if (db_exec_c(h, (const uint8_t *)"CREATE TABLE t(k INTEGER, name TEXT);") != DB_OK) {
    db_close_c(h);
    return 3;
  }
  ins = db_prepare_c(h, (const uint8_t *)"INSERT INTO t(k,name) VALUES(?,?);");
  if (!ins) {
    db_close_c(h);
    return 4;
  }
  if (db_stmt_bind_i32_c(ins, 1, 10) != DB_OK ||
      db_stmt_bind_text_c(ins, 2, (const uint8_t *)"alice") != DB_OK) {
    db_stmt_finalize_c(ins);
    db_close_c(h);
    return 5;
  }
  if (db_stmt_step_c(ins) != 0) {
    db_stmt_finalize_c(ins);
    db_close_c(h);
    return 6;
  }
  if (db_stmt_reset_c(ins) != DB_OK) {
    db_stmt_finalize_c(ins);
    db_close_c(h);
    return 7;
  }
  if (db_stmt_bind_i32_c(ins, 1, 20) != DB_OK ||
      db_stmt_bind_text_c(ins, 2, (const uint8_t *)"bob") != DB_OK) {
    db_stmt_finalize_c(ins);
    db_close_c(h);
    return 8;
  }
  if (db_stmt_step_c(ins) != 0) {
    db_stmt_finalize_c(ins);
    db_close_c(h);
    return 9;
  }
  if (db_stmt_finalize_c(ins) != DB_OK) {
    db_close_c(h);
    return 10;
  }
  sel = db_prepare_cached_c(h, (const uint8_t *)"SELECT name FROM t WHERE k=?;");
  if (!sel) {
    db_close_c(h);
    return 11;
  }
  sel2 = db_prepare_cached_c(h, (const uint8_t *)"SELECT name FROM t WHERE k=?;");
  if (sel2 != sel) {
    db_close_c(h);
    return 12;
  }
  if (db_stmt_bind_i32_c(sel, 1, 10) != DB_OK) {
    db_close_c(h);
    return 13;
  }
  st = db_stmt_step_c(sel);
  if (st != 1) {
    db_close_c(h);
    return 14;
  }
  n = db_row_col_text_c(sel, 0, buf, (int32_t)sizeof(buf));
  if (n != 5 || buf[0] != 'a' || buf[4] != 'e') {
    db_close_c(h);
    return 15;
  }
  if (db_stmt_reset_c(sel) != DB_OK ||
      db_stmt_bind_i32_c(sel, 1, 20) != DB_OK) {
    db_close_c(h);
    return 16;
  }
  st = db_stmt_step_c(sel);
  if (st != 1) {
    db_close_c(h);
    return 17;
  }
  n = db_row_col_text_c(sel, 0, buf, (int32_t)sizeof(buf));
  if (n != 3 || buf[0] != 'b' || buf[2] != 'b') {
    db_close_c(h);
    return 18;
  }
  if (db_stmt_cache_clear_c(h) != DB_OK) {
    db_close_c(h);
    return 19;
  }
  if (db_close_c(h) != DB_OK) return 20;
  return 0;
}

/** STD-084：连接池（v1 单线程、惰性建连、idle 复用）。 */
#define DB_POOL_SLOT_MAX 8
#define DB_POOL_PATH_MAX 512

typedef struct {
  char path[DB_POOL_PATH_MAX];
  int32_t max_conns;
  int32_t live_count;
  int32_t idle_count;
  int64_t idle[DB_POOL_SLOT_MAX];
} db_pool_t;

/** 将 pool handle 转为池指针。 */
static db_pool_t *db_pool_ptr(int64_t pool_h) {
  if (pool_h == 0) return NULL;
  return (db_pool_t *)(uintptr_t)pool_h;
}

/** 创建连接池（不预建连接）；max_conns 上限 8。 */
int64_t db_pool_open_c(const uint8_t *path, int32_t max_conns) {
  db_pool_t *p;
  if (!path) {
    db_set_err(DB_ERR_NULL, "null path");
    return 0;
  }
  if (max_conns <= 0) max_conns = 1;
  if (max_conns > DB_POOL_SLOT_MAX) max_conns = DB_POOL_SLOT_MAX;
  p = (db_pool_t *)calloc(1, sizeof(*p));
  if (!p) {
    db_set_err(DB_ERR_OPEN, "pool alloc");
    return 0;
  }
  snprintf(p->path, sizeof(p->path), "%s", (const char *)path);
  p->max_conns = max_conns;
  db_clear_err();
  return (int64_t)(uintptr_t)p;
}

/** 关闭池并释放全部 idle 连接；仍有借出连接时返回 DB_ERR_BUSY。 */
int32_t db_pool_close_c(int64_t pool_h) {
  db_pool_t *p = db_pool_ptr(pool_h);
  int i;
  if (!p) {
    db_set_err(DB_ERR_NULL, "null pool");
    return DB_ERR_NULL;
  }
  if (p->live_count > p->idle_count) {
    db_set_err(DB_ERR_BUSY, "pool in use");
    return DB_ERR_BUSY;
  }
  for (i = 0; i < p->idle_count; i++) {
    db_close_c(p->idle[i]);
  }
  p->idle_count = 0;
  p->live_count = 0;
  free(p);
  db_clear_err();
  return DB_OK;
}

/** 从池获取连接；池耗尽返回 handle=0（DB_ERR_BUSY）。 */
int64_t db_pool_acquire_c(int64_t pool_h) {
  db_pool_t *p = db_pool_ptr(pool_h);
  int64_t h;
  if (!p) {
    db_set_err(DB_ERR_NULL, "null pool");
    return 0;
  }
  if (p->idle_count > 0) {
    p->idle_count--;
    h = p->idle[p->idle_count];
    if (db_exec_c(h, (const uint8_t *)"SELECT 1;") != DB_OK) {
      db_close_c(h);
      p->live_count--;
      return 0;
    }
    db_clear_err();
    return h;
  }
  if (p->live_count >= p->max_conns) {
    db_set_err(DB_ERR_BUSY, "pool exhausted");
    return 0;
  }
  h = db_open_c((const uint8_t *)p->path);
  if (!h) return 0;
  p->live_count++;
  db_clear_err();
  return h;
}

/** 归还连接到 idle 队列（不关闭 sqlite3）。 */
int32_t db_pool_release_c(int64_t pool_h, int64_t conn_h) {
  db_pool_t *p = db_pool_ptr(pool_h);
  if (!p) {
    db_set_err(DB_ERR_NULL, "null pool");
    return DB_ERR_NULL;
  }
  if (!conn_h) {
    db_set_err(DB_ERR_NULL, "null conn");
    return DB_ERR_NULL;
  }
  if (p->idle_count >= DB_POOL_SLOT_MAX) {
    db_close_c(conn_h);
    if (p->live_count > 0) p->live_count--;
    db_clear_err();
    return DB_OK;
  }
  p->idle[p->idle_count++] = conn_h;
  db_clear_err();
  return DB_OK;
}

/** 当前 idle 连接数（诊断/烟测）。 */
int32_t db_pool_idle_c(int64_t pool_h) {
  db_pool_t *p = db_pool_ptr(pool_h);
  if (!p) return DB_ERR_NULL;
  return p->idle_count;
}

/** C 烟测：acquire 上限、release 复用、pool_close（:memory: max=1）。 */
int32_t db_sqlite_pool_smoke_c(void) {
  int64_t pool;
  int64_t c1;
  int64_t c2;
  int64_t c3;
  int64_t c4;
  if (db_backend_name_c()[0] != 's') return 1;
  pool = db_pool_open_c((const uint8_t *)":memory:", 1);
  if (!pool) return 2;
  c1 = db_pool_acquire_c(pool);
  if (!c1) {
    db_pool_close_c(pool);
    return 3;
  }
  if (db_exec_c(c1, (const uint8_t *)"CREATE TABLE t(k INTEGER);") != DB_OK) {
    db_pool_release_c(pool, c1);
    db_pool_close_c(pool);
    return 4;
  }
  if (db_pool_release_c(pool, c1) != DB_OK) {
    db_pool_close_c(pool);
    return 5;
  }
  if (db_pool_idle_c(pool) != 1) {
    db_pool_close_c(pool);
    return 6;
  }
  c2 = db_pool_acquire_c(pool);
  if (!c2 || c2 != c1) {
    if (c2) db_pool_release_c(pool, c2);
    db_pool_close_c(pool);
    return 7;
  }
  if (db_exec_c(c2, (const uint8_t *)"INSERT INTO t(k) VALUES(42);") != DB_OK) {
    db_pool_release_c(pool, c2);
    db_pool_close_c(pool);
    return 8;
  }
  if (db_pool_release_c(pool, c2) != DB_OK) {
    db_pool_close_c(pool);
    return 9;
  }
  c3 = db_pool_acquire_c(pool);
  if (!c3) {
    db_pool_close_c(pool);
    return 10;
  }
  c4 = db_pool_acquire_c(pool);
  if (c4 != 0) {
    db_pool_release_c(pool, c3);
    if (c4) db_pool_release_c(pool, c4);
    db_pool_close_c(pool);
    return 11;
  }
  if (db_last_error_code_c() != DB_ERR_BUSY) {
    db_pool_release_c(pool, c3);
    db_pool_close_c(pool);
    return 12;
  }
  if (db_pool_release_c(pool, c3) != DB_OK) {
    db_pool_close_c(pool);
    return 13;
  }
  if (db_pool_close_c(pool) != DB_OK) return 14;
  return 0;
}

#else /* !SHU_DB_USE_SQLITE3 */

int64_t db_open_c(const uint8_t *path) {
  (void)path;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return 0;
}

int32_t db_close_c(int64_t handle) {
  (void)handle;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_exec_c(int64_t handle, const uint8_t *sql) {
  (void)handle;
  (void)sql;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_query_rows_c(int64_t handle, const uint8_t *sql) {
  (void)handle;
  (void)sql;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int64_t db_query_begin_c(int64_t handle, const uint8_t *sql) {
  (void)handle;
  (void)sql;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return 0;
}

int32_t db_next_row_c(int64_t cursor) {
  (void)cursor;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_row_col_i32_c(int64_t cursor, int32_t col) {
  (void)cursor;
  (void)col;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_row_col_text_c(int64_t cursor, int32_t col, uint8_t *out_buf, int32_t out_cap) {
  (void)cursor;
  (void)col;
  (void)out_buf;
  (void)out_cap;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_row_col_blob_c(int64_t cursor, int32_t col, uint8_t *out_buf, int32_t out_cap) {
  (void)cursor;
  (void)col;
  (void)out_buf;
  (void)out_cap;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_query_end_c(int64_t cursor) {
  (void)cursor;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int64_t db_prepare_c(int64_t handle, const uint8_t *sql) {
  (void)handle;
  (void)sql;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return 0;
}

int64_t db_prepare_cached_c(int64_t handle, const uint8_t *sql) {
  (void)handle;
  (void)sql;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return 0;
}

int32_t db_stmt_bind_i32_c(int64_t stmt_h, int32_t idx, int32_t val) {
  (void)stmt_h;
  (void)idx;
  (void)val;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_stmt_bind_text_c(int64_t stmt_h, int32_t idx, const uint8_t *text) {
  (void)stmt_h;
  (void)idx;
  (void)text;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_stmt_step_c(int64_t stmt_h) {
  (void)stmt_h;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_stmt_reset_c(int64_t stmt_h) {
  (void)stmt_h;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_stmt_finalize_c(int64_t stmt_h) {
  (void)stmt_h;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_stmt_cache_clear_c(int64_t handle) {
  (void)handle;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_begin_tx_c(int64_t handle) {
  (void)handle;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_commit_c(int64_t handle) {
  (void)handle;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_rollback_c(int64_t handle) {
  (void)handle;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_last_error_code_c(void) {
  return g_db_last_err.code ? g_db_last_err.code : DB_NOT_IMPL;
}

const uint8_t *db_last_error_msg_c(void) {
  if (!g_db_last_err.msg[0]) return NULL;
  return (const uint8_t *)g_db_last_err.msg;
}

const uint8_t *db_backend_name_c(void) {
  static const uint8_t name[] = "stub";
  return name;
}

int32_t db_changes_c(int64_t handle) {
  (void)handle;
  return 0;
}

int32_t db_sqlite_exec_smoke_c(void) {
  return DB_NOT_IMPL;
}

int32_t db_sqlite_tx_exec_smoke_c(void) {
  return DB_NOT_IMPL;
}

int32_t db_sqlite_query_rows_smoke_c(void) {
  return DB_NOT_IMPL;
}

int32_t db_sqlite_next_row_smoke_c(void) {
  return DB_NOT_IMPL;
}

int32_t db_sqlite_stmt_bind_smoke_c(void) {
  return DB_NOT_IMPL;
}

int64_t db_pool_open_c(const uint8_t *path, int32_t max_conns) {
  (void)path;
  (void)max_conns;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return 0;
}

int32_t db_pool_close_c(int64_t pool_h) {
  (void)pool_h;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int64_t db_pool_acquire_c(int64_t pool_h) {
  (void)pool_h;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return 0;
}

int32_t db_pool_release_c(int64_t pool_h, int64_t conn_h) {
  (void)pool_h;
  (void)conn_h;
  db_set_err(DB_NOT_IMPL, "stub backend");
  return DB_NOT_IMPL;
}

int32_t db_pool_idle_c(int64_t pool_h) {
  (void)pool_h;
  return DB_NOT_IMPL;
}

int32_t db_sqlite_pool_smoke_c(void) {
  return DB_NOT_IMPL;
}

#endif /* SHU_DB_USE_SQLITE3 */
