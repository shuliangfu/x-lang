const csv = import("std.csv");

/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  let n: i32 = csv.escape(&line[0], 2, &buf[0], 64);
  if (n != 4) {
    return 100 + n;
  }
  return buf[1];
}
