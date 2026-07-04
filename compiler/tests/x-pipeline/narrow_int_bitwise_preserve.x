const ast = import("ast");

function main(): i32 {
  let bytes: u8[4] = [];
  bytes[0] = 1;
  bytes[0] = bytes[0] ^ 1;
  bytes[1] = (bytes[1] & 15) | 64;
  bytes[2] = bytes[2] << 1;
  bytes[3] = bytes[3] >> 1;
  return 0;
}
