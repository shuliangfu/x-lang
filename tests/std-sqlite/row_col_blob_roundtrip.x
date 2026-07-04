// STD-069：内存库 row_col_blob BLOB 列烟测（须 sqlite-o + -lsqlite3 链接）
const sqlite = import("std.db.sqlite");

/** 比较 buf 前 n 字节是否与三元组一致。 */
function bytes_eq3(buf: *u8, b0: u8, b1: u8, b2: u8, n: i32): i32 {
  if (n < 1) {
    return 0;
  }
  if (buf[0] != b0) {
    return 0;
  }
  if (n < 2) {
    return 1;
  }
  if (buf[1] != b1) {
    return 0;
  }
  if (n < 3) {
    return 1;
  }
  if (buf[2] != b2) {
    return 0;
  }
  return 1;
}

/** 比较 buf 前 n 字节是否与四元组一致。 */
function bytes_eq4(buf: *u8, b0: u8, b1: u8, b2: u8, b3: u8, n: i32): i32 {
  if (n < 1) {
    return 0;
  }
  if (buf[0] != b0) {
    return 0;
  }
  if (n < 2) {
    return 1;
  }
  if (buf[1] != b1) {
    return 0;
  }
  if (n < 3) {
    return 1;
  }
  if (buf[2] != b2) {
    return 0;
  }
  if (n < 4) {
    return 1;
  }
  if (buf[3] != b3) {
    return 0;
  }
  return 1;
}

function main(): i32 {
  let mem: u8[9] = [58, 109, 101, 109, 111, 114, 121, 58, 0];
  let sql_create: u8[38] = [
    67, 82, 69, 65, 84, 69, 32, 84, 65, 66, 76, 69, 32, 116, 40, 107,
    32, 73, 78, 84, 69, 71, 69, 82, 44, 32, 100, 97, 116, 97, 32, 66,
    76, 79, 66, 41, 59, 0
  ];
  let sql_ins2: u8[46] = [
    73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44,
    100, 97, 116, 97, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 50, 44,
    120, 39, 48, 97, 48, 98, 48, 99, 48, 100, 39, 41, 59, 0
  ];
  let sql_ins1: u8[44] = [
    73, 78, 83, 69, 82, 84, 32, 73, 78, 84, 79, 32, 116, 40, 107, 44,
    100, 97, 116, 97, 41, 32, 86, 65, 76, 85, 69, 83, 32, 40, 49, 44,
    120, 39, 48, 49, 48, 50, 48, 51, 39, 41, 59, 0
  ];
  let sql_order: u8[31] = [
    83, 69, 76, 69, 67, 84, 32, 100, 97, 116, 97, 32, 70, 82, 79, 77,
    32, 116, 32, 79, 82, 68, 69, 82, 32, 66, 89, 32, 107, 59, 0
  ];
  let out: u8[32] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let c: DbConn = sqlite.open(&mem[0]);
  let cur: DbRowCursor = DbRowCursor { cursor: 0 };
  let st: i32 = 0;
  let n: i32 = 0;
  if (c.handle == 0) {
    return 1;
  }
  if (sqlite.exec(c, &sql_create[0]) != 0) {
    sqlite.close(c);
    return 2;
  }
  if (sqlite.exec(c, &sql_ins2[0]) != 0) {
    sqlite.close(c);
    return 3;
  }
  if (sqlite.exec(c, &sql_ins1[0]) != 0) {
    sqlite.close(c);
    return 4;
  }
  cur = sqlite.begin(c, &sql_order[0]);
  if (cur.cursor == 0) {
    sqlite.close(c);
    return 5;
  }
  st = sqlite.next_row(cur);
  if (st != sqlite.DB_ROW_OK) {
    sqlite.end(cur);
    sqlite.close(c);
    return 6;
  }
  n = sqlite.col_blob(cur, 0, &out[0], 32);
  if (n != 3) {
    sqlite.end(cur);
    sqlite.close(c);
    return 7;
  }
  if (bytes_eq3(&out[0], 1, 2, 3, 3) == 0) {
    sqlite.end(cur);
    sqlite.close(c);
    return 8;
  }
  st = sqlite.next_row(cur);
  if (st != sqlite.DB_ROW_OK) {
    sqlite.end(cur);
    sqlite.close(c);
    return 9;
  }
  n = sqlite.col_blob(cur, 0, &out[0], 32);
  if (n != 4) {
    sqlite.end(cur);
    sqlite.close(c);
    return 10;
  }
  if (bytes_eq4(&out[0], 10, 11, 12, 13, 4) == 0) {
    sqlite.end(cur);
    sqlite.close(c);
    return 11;
  }
  st = sqlite.next_row(cur);
  if (st != sqlite.DB_ROW_DONE) {
    sqlite.end(cur);
    sqlite.close(c);
    return 12;
  }
  if (sqlite.end(cur) != 0) {
    sqlite.close(c);
    return 13;
  }
  if (sqlite.close(c) != 0) {
    return 14;
  }
  return 0;
}
