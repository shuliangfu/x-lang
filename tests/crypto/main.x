// 测试 std.crypto：mem_eq、sha256、hmac_sha256
const crypto = import("std.crypto");

function main(): i32 {
  let a: u8[4] = [1, 2, 3, 4];
  let b: u8[4] = [1, 2, 3, 4];
  if (crypto.mem_eq(&a[0], &b[0], 4) != 1) { return 1; }
  b[3] = 5;
  if (crypto.mem_eq(&a[0], &b[0], 4) != 0) { return 2; }
  let msg: u8[3] = [97, 98, 99];
  let out: u8[32] = [];
  crypto.sha256(&msg[0], 3, &out[0]);
  if (out[0] == 0 && out[1] == 0) { return 3; }
  let key: u8[4] = [107, 101, 121, 0];
  crypto.hmac_sha256(&key[0], 4, &msg[0], 3, &out[0]);
  if (out[0] == 0 && out[1] == 0) { return 4; }
  return 0;
}
