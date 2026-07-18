/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let line: u8[8] = [0, 0, 0, 10, 0, 0, 0, 0];
  let ptr: *u8 = &line[0];
  let off: i32 = 3;
  let v: i32 = 0;
  v = ptr[off];
  return v;
}
