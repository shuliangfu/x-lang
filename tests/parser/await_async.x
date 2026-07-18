// See implementation.
/* See implementation. */
async function step(n: i32): i32 {
  return await n + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return step(41);
}
