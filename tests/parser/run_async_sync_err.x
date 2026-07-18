// See implementation.
async function inner(): i32 {
  return run yield_demo();
}

async function yield_demo(): i32 {
  let a: i32 = await 1;
  return a;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
