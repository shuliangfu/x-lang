// STD-010：std.db.sqlite API typeck 金样（仅校验签名）
const sqlite = import("std.db.sqlite");

function main(): i32 {
  let path: u8[8] = [116, 101, 115, 116, 46, 100, 98, 0];
  let sql: u8[9] = [83, 69, 76, 69, 67, 84, 32, 49, 0];
  let c: DbConn = sqlite.open(&path[0]);
  let ec: i32 = sqlite.exec(c, &sql[0]);
  ec = sqlite.rows(c, &sql[0]);
  let cur: DbRowCursor = sqlite.begin(c, &sql[0]);
  ec = sqlite.next_row(cur);
  ec = sqlite.end(cur);
  ec = sqlite.begin_tx(c);
  ec = sqlite.commit(c);
  ec = sqlite.rollback(c);
  ec = sqlite.close(c);
  let err: DbError = sqlite.last_error();
  let backend: *u8 = sqlite.backend_name();
  if (backend == 0) { return 1; }
  if (err.code != 0 && err.code != -9) { return 2; }
  return 0;
}
