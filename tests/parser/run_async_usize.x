// See implementation.
/* See implementation. */
async function id_usize(x: usize): i32 {
  let v: usize = await x;
  return v as i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let seed: usize = 99 as usize;
  let r: i32 = run id_usize(seed);
  if (r != 99) {
    return 11;
  }
  return 0;
}
