// tests/std/error_unify_smoke.x — STD-011：各模块 error_base 段与 B 层语义码烟测
const err = import("std.error");

function main(): i32 {
  if (code_in_module_span(io_err_timeout(), base_io()) != 1) { return 1; }
  if (code_in_module_span(fs_err_not_found(), base_fs()) != 1) { return 2; }
  if (code_in_module_span(net_err_generic(), base_net()) != 1) { return 3; }
  if (code_in_module_span(async_err_generic(), base_async()) != 1) { return 4; }
  if (code_in_module_span(coll_err_generic(), base_coll()) != 1) { return 5; }
  if (code_alloc_fail() != -1) { return 6; }
  if (code_in_global_range(code_invalid()) != 1) { return 7; }
  return 0;
}
