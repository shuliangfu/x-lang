/**
 * Cookbook DB-02：sqlite 大 BLOB 分块读（STD-082 #82）。
 * 无 libsqlite3（stub）时 `sqlite_is_available()==0`，直接 exit 0。
 */
const sqlite = import("std.db.sqlite");

function main(): i32 {
  if (sqlite.is_available() == 0) {
    return 0;
  }
  let mem: u8[9] = [58, 109, 101, 109, 111, 114, 121, 58, 0];
  let sql_create: u8[28] = [
    67, 82, 69, 65, 84, 69, 32, 84, 65, 66, 76, 69, 32, 116, 40, 100,
    97, 116, 97, 32, 66, 76, 79, 66, 41, 59, 0
  ];
  let sql_ins: u8[52] = [
    73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 100, 97,
    116, 97, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 120, 39, 48, 49,
    48, 50, 48, 51, 39, 41, 59, 0
  ];
  let sql_sel: u8[22] = [
    83, 69, 76, 69, 67, 84, 32, 100, 97, 116, 97, 32, 70, 82, 79, 77,
    32, 116, 59, 0
  ];
  let chunk: u8[8] = [];
  let c: DbConn = sqlite.open(&mem[0]);
  let cur: DbRowCursor = DbRowCursor { cursor: 0 };
  if (c.handle == 0) {
    return 1;
  }
  if (sqlite.exec(c, &sql_create[0]) != 0) {
    sqlite.close(c);
    return 2;
  }
  if (sqlite.exec(c, &sql_ins[0]) != 0) {
    sqlite.close(c);
    return 3;
  }
  cur = sqlite.begin(c, &sql_sel[0]);
  if (cur.cursor == 0) {
    sqlite.close(c);
    return 4;
  }
  if (sqlite.next_row(cur) != 1) {
    sqlite.end(cur);
    sqlite.close(c);
    return 5;
  }
  if (sqlite.col_blob_len(cur, 0) != 3) {
    sqlite.end(cur);
    sqlite.close(c);
    return 6;
  }
  if (sqlite.col_blob_read(cur, 0, 0, &chunk[0], 8) != 3) {
    sqlite.end(cur);
    sqlite.close(c);
    return 7;
  }
  if (chunk[0] != 1 || chunk[1] != 2 || chunk[2] != 3) {
    sqlite.end(cur);
    sqlite.close(c);
    return 8;
  }
  sqlite.end(cur);
  sqlite.close(c);
  return 0;
}
