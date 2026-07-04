// 正例：import 模块顶层 const 须通过 binding 限定访问
const async_mod = import("std.async");

function main(): i32 {
  if (async_mod.POLL_PENDING != 0) { return 1; }
  if (async_mod.POLL_READY != 1) { return 2; }
  return 0;
}
