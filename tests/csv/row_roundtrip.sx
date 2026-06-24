// STD-036：std.csv parse_row / write_row round-trip 金样（RFC 4180 边界）
const csv = import("std.csv");

/** 比较 buf 从 off 起 n 字节是否等于 a,b,c,d,e（按 n 使用前若干字节）。 */
function bytes_eq_at(buf: *u8, off: i32, n: i32, a: u8, b: u8, c: u8, d: u8, e: u8): i32 {
  if (n == 1) { return buf[off] == a ? 1 : 0; }
  if (n == 2) { return buf[off] == a && buf[off + 1] == b ? 1 : 0; }
  if (n == 3) { return buf[off] == a && buf[off + 1] == b && buf[off + 2] == c ? 1 : 0; }
  if (n == 5) {
    return buf[off] == a && buf[off + 1] == b && buf[off + 2] == c && buf[off + 3] == d
      && buf[off + 4] == e ? 1 : 0;
  }
  return 0;
}

function main(): i32 {
  // case 1：简单三列 write_row → parse_row
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
  if (plens[0] != 5 || plens[1] != 3 || plens[2] != 1) { return 4; }
  if (bytes_eq_at(&out[0], pstarts[0], 5, 97, 108, 105, 99, 101) == 0) { return 5; }
  if (bytes_eq_at(&out[0], pstarts[1], 3, 98, 111, 98, 0, 0) == 0) { return 6; }
  if (out[pstarts[2]] != 49) { return 7; }

  // case 2：含逗号字段须引号包裹
  let blob2: u8[8] = [97, 44, 98, 0, 0, 0, 0, 0];
  let starts2: i32[2] = [0, 0];
  let lens2: i32[2] = [3, 0];
  let out2: u8[32] = [];
  nw = csv.write_row(&blob2[0], &starts2[0], &lens2[0], 1, &out2[0], 32);
  if (nw <= 0) { return 8; }
  cnt = 0;
  next = csv.parse_row(&out2[0], nw, 0, &pstarts[0], &plens[0], 4, &cnt);
  if (cnt != 1 || plens[0] != 3) { return 9; }
  if (bytes_eq_at(&out2[0], pstarts[0], 3, 97, 44, 98, 0, 0) == 0) { return 10; }

  // case 3：空字段 a,,b
  let blob3: u8[4] = [97, 98, 0, 0];
  let starts3: i32[3] = [0, 1, 1];
  let lens3: i32[3] = [1, 0, 1];
  let out3: u8[32] = [];
  nw = csv.write_row(&blob3[0], &starts3[0], &lens3[0], 3, &out3[0], 32);
  if (nw <= 0) { return 11; }
  cnt = 0;
  next = csv.parse_row(&out3[0], nw, 0, &pstarts[0], &plens[0], 4, &cnt);
  if (cnt != 3) { return 12; }
  if (plens[1] != 0) { return 13; }
  if (plens[0] != 1 || plens[2] != 1) { return 14; }
  if (out3[pstarts[0]] != 97 || out3[pstarts[2]] != 98) { return 15; }

  return 0;
}
