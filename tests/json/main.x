// tests/json/main.x — std.json 最小烟测（parse null/bool/number；append/escape 待 co-emit 稳定）

const json = import("std.json");

function main(): i32 {
  let consumed: i32 = 0;
  let out_val: f64 = 0.0;
  let out_bool: i32 = 0;
  let buf: u8[128] = [];

  if (json.parse_null(&buf[0], 0, &consumed) != 0) { return 1; }
  let null_ok: u8[5] = [110, 117, 108, 108, 0];
  if (json.parse_null(&null_ok[0], 4, &consumed) != 1) { return 2; }
  if (consumed != 4) { return 3; }

  let true_ok: u8[5] = [116, 114, 117, 101, 0];
  if (json.parse(&true_ok[0], 4, &out_bool, &consumed) != 1) { return 4; }
  if (out_bool != 1 || consumed != 4) { return 5; }
  let false_ok: u8[6] = [102, 97, 108, 115, 101, 0];
  if (json.parse(&false_ok[0], 5, &out_bool, &consumed) != 1) { return 6; }
  if (out_bool != 0 || consumed != 5) { return 7; }
  if (json.parse(&buf[0], 2, &out_bool, &consumed) != 0) { return 8; }

  let num_int: u8[3] = [49, 50, 0];
  if (json.parse_number(&num_int[0], 2, &out_val, &consumed) != 0) { return 9; }
  if (consumed != 2) { return 10; }

  return 0;
}
