/**
 * See implementation.
 */
const mem = import("core.mem");
const types = import("core.types");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = types.size_of_i32();
  if (n != 4) {
    return 1;
  }
  return 0;
}
