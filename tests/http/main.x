// See implementation.
// See implementation.
// See implementation.

const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let url: u8[32] = [104, 116, 116, 112, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111,
  109, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let out_buf: u8[4096] = [];
  let n: i32 = http.get(&url[0], 19, &out_buf[0], 4096);
  if (n < 0) {
    return 0;
  }
  if (n < 4) { return 1; }
  if (out_buf[0] != 72 || out_buf[1] != 84 || out_buf[2] != 84 || out_buf[3] != 80) { return 2; }
  return 0;
}
