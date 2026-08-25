// See implementation.
// PLATFORM: SHARED — bare ok() collides with core.result.ok(i32) (arity T001);
// use err.ok(). Prefer short Result API (is_err / unwrap_or), not *_i32 aliases.
const result = import("core.result");
const err = import("std.error");

/**
 * Program/test entry point.
 * @return i32 — 0 on success
 */
function main(): i32 {
  if (err.ok() != 0) { return 1; }
  if (code_in_global_range(code_alloc_fail()) != 1) { return 2; }
  if (code_in_global_range(io_err_timeout()) != 0) { return 3; }
  if (base_io() <= base_fs()) { return 4; }
  if (base_fs() <= base_net()) { return 5; }
  if (code_in_module_span(io_err_timeout(), base_io()) != 1) { return 6; }
  if (code_in_module_span(fs_err_not_found(), base_fs()) != 1) { return 7; }
  if (code_is_platform_errno(-1) != 0) { return 8; }
  if (code_is_platform_errno(2) != 1) { return 9; }
  let r: Result_i32 = result.err(fs_err_not_found());
  if (!result.is_err(r)) { return 10; }
  if (result.unwrap_or(r, 404) != 404) { return 10; }
  return 0;
}
