// See implementation.
async function add_one(x: i32): i32 {
  let v: i32 = await x;
  return v + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return run add_one(1, 2, 3);
}
