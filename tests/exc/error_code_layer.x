// tests/exc/code_layer.x — EXC-003：错误码分层区间与 helper 烟测
const result = import("core.result");
const err = import("std.error");

function main(): i32 {
  if (ok() != 0) { return 1; }
  if (code_in_global_range(code_alloc_fail()) != 1) { return 2; }
  if (code_in_global_range(io_err_timeout()) != 0) { return 3; }
  if (base_io() <= base_fs()) { return 4; }
  if (base_fs() <= base_net()) { return 5; }
  if (code_in_module_span(io_err_timeout(), base_io()) != 1) { return 6; }
  if (code_in_module_span(fs_err_not_found(), base_fs()) != 1) { return 7; }
  if (code_is_platform_errno(-1) != 0) { return 8; }
  if (code_is_platform_errno(2) != 1) { return 9; }
  let r: Result_i32 = result.err_i32(fs_err_not_found());
  if (!result.is_err_i32(r) || r.err != fs_err_not_found()) { return 10; }
  return 0;
}
