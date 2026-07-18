/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let aa: i32 = 2;
  let bb: i32 = 2;
  if (aa != bb) { return 1; }
  return 0;
}
