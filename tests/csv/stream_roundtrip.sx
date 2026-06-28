// STD-128：流式 CSV reader/writer 往返烟测
const csv = import("std.csv");

function main(): i32 {
  let blob: u8[16] = [97, 108, 105, 99, 101, 98, 111, 98, 49, 50, 51, 0, 0, 0, 0, 0];
  let starts: i32[3] = [0, 5, 8];
  let lens: i32[3] = [5, 3, 3];
  let out: u8[128] = [];
  let w: StreamCsvWriter = csv.writer(&out[0], 128);
  if (csv.append_row(&w, &blob[0], &starts[0], &lens[0], 3) != 0) { return 1; }
  let starts2: i32[3] = [10, 11, 12];
  let lens2: i32[3] = [1, 0, 1];
  if (csv.append_row(&w, &blob[0], &starts2[0], &lens2[0], 3) != 0) { return 2; }
  let total: i32 = csv.len(w);
  if (total <= 0) { return 3; }
  let r: StreamCsvReader = csv.reader(&out[0], total);
  let pstarts: i32[4] = [0, 0, 0, 0];
  let plens: i32[4] = [0, 0, 0, 0];
  let cnt: i32 = 0;
  if (csv.next_row(&r, &pstarts[0], &plens[0], 4, &cnt) != 0) { return 4; }
  if (cnt != 3 || plens[0] != 5 || plens[1] != 3 || plens[2] != 3) { return 5; }
  cnt = 0;
  if (csv.next_row(&r, &pstarts[0], &plens[0], 4, &cnt) != 0) { return 6; }
  if (cnt != 3 || plens[1] != 0) { return 7; }
  if (csv.next_row(&r, &pstarts[0], &plens[0], 4, &cnt) != 1) { return 8; }
  if (csv.eof(r) != 1) { return 9; }
  if (csv.smoke() != 0) { return 10; }
  return 0;
}
