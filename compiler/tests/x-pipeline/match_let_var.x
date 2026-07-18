/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let x: i32 = 1;
  return match x { 1 => 2; _ => 0; }
}
