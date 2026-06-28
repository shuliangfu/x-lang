/**
 * Cookbook ERR-02：跨模块错误语义类（STD-158）。
 */
const err = import("std.error");

function main(): i32 {
  let io_to: i32 = err.io_err_timeout();
  if (err.semantic_class(io_to) != err.sem_timeout()) { return 1; }
  if (err.is_timeout(io_to) != 1) { return 2; }
  if (err.recommend_retry(io_to) != 1) { return 3; }
  let net_cn: i32 = err.net_err_cancelled();
  if (err.semantic_class(net_cn) != err.sem_cancelled()) { return 4; }
  if (err.is_cancelled(net_cn) != 1) { return 5; }
  return 0;
}
