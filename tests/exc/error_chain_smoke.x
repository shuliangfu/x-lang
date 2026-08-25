// See implementation.
const result = import("core.result");
const err = import("std.error");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let leaf: ErrorChain = err.chain_from_code(fs_err_not_found());
  if (err.chain_depth(leaf) != 1) { return 1; }
  if (err.chain_leaf(leaf) != fs_err_not_found()) { return 2; }
  if (err.chain_root(leaf) != fs_err_not_found()) { return 3; }
  let wrapped: ErrorChain = err.chain_wrap(leaf, io_err_timeout());
  if (err.chain_depth(wrapped) != 2) { return 4; }
  if (err.chain_root(wrapped) != io_err_timeout()) { return 5; }
  if (err.chain_leaf(wrapped) != fs_err_not_found()) { return 6; }
  if (err.chain_code_at(wrapped, 0) != io_err_timeout()) { return 7; }
  if (err.chain_code_at(wrapped, 1) != fs_err_not_found()) { return 8; }
  let bad: Result_i32 = result.err(fs_err_not_found());
  let from_r: ErrorChain = err.chain_from_result(bad);
  if (err.chain_leaf(from_r) != fs_err_not_found()) { return 9; }
  /* Nested CALL-as-MEMORY (host-indirect + x8 save) — no intermediate lets. */
  let deep: ErrorChain = err.chain_wrap(
    err.chain_wrap(
      err.chain_wrap(
        err.chain_wrap(leaf, io_err_generic()),
        io_err_timeout()),
      io_err_cancelled()),
    code_invalid());
  if (err.chain_depth(deep) != err.chain_max_depth()) { return 10; }
  if (err.chain_root(deep) != code_invalid()) { return 11; }
  let out: Result_i32 = result.err(err.chain_root(wrapped));
  if (!result.is_err(out)) { return 12; }
  return 0;
}
