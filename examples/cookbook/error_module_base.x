/**
 * See implementation.
 */
const err = import("std.error");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let base_io: i32 = err.code_to_module_base(err.io_err_timeout());
  if (base_io != err.base_io()) { return 1; }
  if (err.mod_tag_from_base(base_io) != err.mod_tag_io()) { return 2; }
  if (err.module_sidecar_kind(err.mod_tag_fs()) != err.sidecar_errno()) { return 3; }
  return 0;
}
