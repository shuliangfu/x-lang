// See implementation.
/* See implementation. */
async function id_u32(x: u32): i32 {
  let v: u32 = await x;
  return v as i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let seed: u32 = 42;
  let r: i32 = run id_u32(seed);
  if (r != 42) {
    return 11;
  }
  return 0;
}
