// tests/std/error_semantics_smoke.x — STD-158：跨模块错误语义类烟测
const err = import("std.error");

function main(): i32 {
  if (semantic_class(io_err_timeout()) != sem_timeout()) { return 1; }
  if (semantic_class(net_err_cancelled()) != sem_cancelled()) { return 2; }
  if (semantic_class(http_err_timeout()) != sem_timeout()) { return 3; }
  if (semantic_class(fs_err_not_found()) != sem_not_found()) { return 4; }
  if (is_timeout(io_err_timeout()) != 1) { return 5; }
  if (is_cancelled(net_err_cancelled()) != 1) { return 6; }
  if (is_not_found(code_not_found()) != 1) { return 7; }
  if (recommend_retry(io_err_timeout()) != 1) { return 8; }
  if (recommend_retry(fs_err_not_found()) != 0) { return 9; }
  if (code_to_module_base(io_err_timeout()) != base_io()) { return 10; }
  if (code_to_module_base(http_err_cancelled()) != base_net()) { return 11; }
  return 0;
}
