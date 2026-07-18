// See implementation.
// See implementation.

const stack_promote_lib = import("stack_promote_lib");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Pair = make_pair(3, 4);
  return read_pair_ptr(&p);
}
