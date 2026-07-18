/** Internal function `add2`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function add2(a: i32, b: i32): i32 { return a + b; }
/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  return add2(1, 2);
}
