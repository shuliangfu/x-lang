// See implementation.
//
// See implementation.
// See implementation.
/* See implementation. */
async function add_two(a: i32, b: i32): i32 {
  let x: i32 = await a;
  let y: i32 = await b;
  return x + y;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: i32 = run add_two(40, 2);
  if (r != 42) {
    return 1;
  }
  let r2: i32 = run add_two(10, 32);
  if (r2 != 42) {
    return 2;
  }
  return 0;
}
