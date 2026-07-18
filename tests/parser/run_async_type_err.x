// See implementation.
async function id_u32(x: u32): i32 {
  let v: u32 = await x;
  return v as i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let bad: i32 = 1;
  return run id_u32(bad);
}
