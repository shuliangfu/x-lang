// See implementation.
const lib = import("lib_export");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return lib.private_mul(2, 3);
}
