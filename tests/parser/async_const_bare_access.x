// 负例（parser/typeck）：async 模块 const 不得裸名 POLL_*（须 async_mod.POLL_*）
const async_mod = import("std.async");

function main(): i32 {
  if (POLL_PENDING != 0) { return 1; }
  if (POLL_READY != 1) { return 2; }
  return 0;
}
