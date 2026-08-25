// See implementation.
const result = import("core.result");
const err = import("std.error");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let leaf: ErrorChain = err.chain_from_code(fs_err_not_found());
  let wrapped: ErrorChain = err.chain_wrap(leaf, io_err_timeout());
  let root: i32 = err.chain_root(wrapped);
  if (root != io_err_timeout()) { return 1; }
  let recovered: i32 = 0;
  if (root == io_err_timeout()) { recovered = 200; }
  if (recovered != 200) { return 2; }
  return 0;
}
