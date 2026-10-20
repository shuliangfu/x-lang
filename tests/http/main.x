// Cap tip L4 leftover smoke: local loopback GET (not example.com).
// External example.com intermittently returns n==0 via Cap dial/recv_fill
// (empty EOF), which fails n<4. Local server is deterministic leftover gate.
// Prefer asm; no FORCE_CC / KEEP_C. PLATFORM: SHARED.

const http = import("std.http");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // "http://127.0.0.1:18765/" (23 bytes)
  let url: u8[32] = [104, 116, 116, 112, 58, 47, 47, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 49, 56, 55, 54, 53, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let out_buf: u8[4096] = [];
  let n: i32 = http.get(&url[0], 23, &out_buf[0], 4096);
  // Honest: error and empty both fail (no soft n<0→OK).
  if (n < 4) { return 1; }
  if (out_buf[0] != 72 || out_buf[1] != 84 || out_buf[2] != 84 || out_buf[3] != 80) { return 2; }
  return 0;
}
