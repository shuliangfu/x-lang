/**
 * Cookbook CSV-01：write_row / parse_row 三列往返（STD-036）。
 */
const csv = import("std.csv");

function main(): i32 {
  let blob: u8[16] = [97, 108, 105, 99, 101, 98, 111, 98, 49, 0, 0, 0, 0, 0, 0, 0];
  let starts: i32[4] = [0, 5, 8, 0];
  let lens: i32[4] = [5, 3, 1, 0];
  let out: u8[64] = [];
  let nw: i32 = csv.write_row(&blob[0], &starts[0], &lens[0], 3, &out[0], 64);
  if (nw < 10) { return 1; }
  let pstarts: i32[4] = [0, 0, 0, 0];
  let plens: i32[4] = [0, 0, 0, 0];
  let cnt: i32 = 0;
  let next: i32 = csv.parse_row(&out[0], nw, 0, &pstarts[0], &plens[0], 4, &cnt);
  if (cnt != 3) { return 2; }
  if (next != nw) { return 3; }
  return 0;
}
