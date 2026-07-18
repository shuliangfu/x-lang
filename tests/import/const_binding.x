// See implementation.
const types = import("core.types");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = types.size_of_i32();
  return if (n == 4) { 0 } else { 1 };
}
