// STD-006：HMAC-SHA256 金样（key=1,2,3,4 msg=msg，与 crypto.c 一致）
const crypto = import("std.crypto");

function main(): i32 {
  let key: u8[4] = [1, 2, 3, 4];
  let msg: u8[3] = [109, 115, 103];
  let out: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let expect: u8[32] = [
    22, 112, 245, 112, 253, 113, 197, 174, 208, 253, 119, 28, 54, 243, 29, 45,
    229, 213, 89, 43, 187, 248, 188, 91, 172, 216, 188, 249, 190, 188, 9, 64];
  crypto.hmac_sha256(&key[0], 4, &msg[0], 3, &out[0]);
  if (crypto.mem_eq(&out[0], &expect[0], 32) != 1) { return 1; }
  return 0;
}
