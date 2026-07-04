// STD-006：SHA-256("abc") 金样向量（与 std/crypto/crypto.c 输出一致）
const crypto = import("std.crypto");

function main(): i32 {
  let msg: u8[3] = [97, 98, 99];
  let out: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let expect: u8[32] = [
    186, 120, 22, 191, 143, 1, 207, 234, 65, 65, 64, 222, 93, 174, 34, 35,
    176, 3, 97, 163, 150, 23, 122, 156, 180, 16, 255, 97, 242, 0, 21, 173];
  crypto.sha256(&msg[0], 3, &out[0]);
  if (crypto.mem_eq(&out[0], &expect[0], 32) != 1) { return 1; }
  return 0;
}
