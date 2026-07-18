// See implementation.
const sroa_lib = import("sroa_lib");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Pair = make_pair(3, 4);
  return sum_pair(p);
}
