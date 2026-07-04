// 负例：import 模块顶层 const 不得裸名访问（须 binding.CONST）
const async_mod = import("std.async");

function main(): i32 {
  if (POLL_PENDING != 0) { return 1; }
  if (POLL_READY != 1) { return 2; }
  return 0;
}
