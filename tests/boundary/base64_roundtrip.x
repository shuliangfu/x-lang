// See implementation.
const base64 = import("std.base64");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let src: u8[3] = [102, 111, 111];
  let enc: u8[8] = [];
  let dec: u8[8] = [];
  let n: i32 = base64.encode_standard(&src[0], 3, &enc[0], 8);
  if (n != 4) {
    return 1;
  }
  let dn: i32 = base64.decode_standard(&enc[0], n, &dec[0], 8);
  if (dn != 3 || dec[0] != 102 || dec[1] != 111 || dec[2] != 111) {
    return 2;
  }
  return 0;
}
