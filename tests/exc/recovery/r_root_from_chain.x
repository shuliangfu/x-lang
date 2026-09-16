// See implementation.
const result = import("core.result");
const err = import("std.error");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* Nested CALL-as-MEMORY host-indirect (no intermediate ErrorChain let). */
  let wrapped: ErrorChain = err.chain_wrap(
    err.chain_from_code(fs_err_not_found()),
    io_err_timeout());
  let root: i32 = err.chain_root(wrapped);
  if (root != io_err_timeout()) { return 1; }
  let recovered: i32 = 0;
  if (root == io_err_timeout()) { recovered = 200; }
  if (recovered != 200) { return 2; }
  return 0;
}
