// See implementation.
/* See implementation. */
async function yield_demo(): i32 {
  let a: i32 = 1;
  let b: i32 = await a;
  return b + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let suspended: i32 = 1095980800;
  let r: i32 = yield_demo();
  if (r == suspended) {
    r = yield_demo();
  }
  if (r != 2) {
    return 11;
  }
  return 0;
}
