// 边界：import 不存在的模块，应报错且退出非 0
const bad = import("std.this_module_does_not_exist_zzz");

function main(): i32 {
  return 0;
}
