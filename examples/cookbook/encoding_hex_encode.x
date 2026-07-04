/**
 * Cookbook ENC-01：hex_encode 原始缓冲编码（STD-040）。
 */
const encoding = import("std.encoding");

function main(): i32 {
  let raw: u8[2] = [222, 173];
  let out: u8[8] = [];
  let n: i32 = encoding.hex_encode(&raw[0], 2, &out[0], 8);
  if (n != 4) { return 1; }
  if (out[0] != 100 || out[1] != 101) { return 2; }
  return 0;
}
