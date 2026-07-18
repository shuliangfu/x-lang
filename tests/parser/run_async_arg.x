// See implementation.
/* See implementation. */
async function add_one(x: i32): i32 {
  let v: i32 = await x;
  return v + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: i32 = run add_one(41);
  if (r != 42) {
    return 11;
  }
  let r2: i32 = run add_one(99);
  if (r2 != 100) {
    return 12;
  }
  return 0;
}
