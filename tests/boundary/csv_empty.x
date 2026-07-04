// boundary/csv_empty.x — 空输入 next_field 不崩溃
// seed asm：call 后紧跟 if 会触发栈/续延问题，用 out 参数断言代替 if+return。
const csv = import("std.csv");

function main(): i32 {
  let empty: u8[1] = [0];
  let start: i32 = 0;
  let flen: i32 = 0;
  csv.next_field(&empty[0], 0, 0, &start, &flen);
  return start + flen;
}
