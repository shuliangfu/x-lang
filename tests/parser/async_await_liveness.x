// See implementation.
/* See implementation. */
async function liveness_demo(): i32 {
  let dead: i32 = 1;
  let keep: i32 = 2;
  let tmp: i32 = dead + 1;
  let mid: i32 = await tmp;
  return mid + keep;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return liveness_demo();
}
