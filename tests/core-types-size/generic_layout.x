// See implementation.
const types = import("core.types");

struct Pair {
  a: i32;
  b: i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  if (types.size_of<i32>() != 4) { return 1; }
  if (types.align_of<i32>() != 4) { return 2; }
  if (types.size_of<u8>() != 1) { return 3; }
  // See implementation.
  if (types.size_of<*u8>() != 8) { return 4; }
  if (types.align_of<*u8>() != 8) { return 5; }
  // See implementation.
  if (types.size_of<Pair>() != 8) { return 6; }
  if (types.align_of<Pair>() != 4) { return 7; }
  // See implementation.
  if (types.size_of<u8[4]>() != 4) { return 8; }
  if (types.align_of<u8[4]>() != 1) { return 9; }
  return 0;
}
