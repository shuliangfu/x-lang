// See implementation.
async function add_two(a: i32, b: i32): i32 {
  let x: i32 = await a;
  return x + b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return run add_two(1);
}
