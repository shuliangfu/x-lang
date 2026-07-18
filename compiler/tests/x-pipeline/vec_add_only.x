/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [1, 1, 1, 1];
  let c: i32x4 = a + b;
  return 0;
}
