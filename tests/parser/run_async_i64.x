// See implementation.
/* See implementation. */
async function id_i64(x: i64): i64 {
  let v: i64 = await x;
  return v;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let seed: i64 = 10000000000;
  let r: i64 = run id_i64(seed);
  if (r != 10000000000) {
    return 11;
  }
  return 0;
}
