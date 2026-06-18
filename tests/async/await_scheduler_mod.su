// STD-041：import("std.async") 门面与 scheduler 链入烟测
//
// 【文件职责】验证 scheduler_reset / coop_pingpong 与按需链入 scheduler.o。
// 【运行方式】tests/run-std-async-language-gate.sh
const async_mod = import("std.async");

function main(): i32 {
  async_mod.scheduler_reset();
  let n: i64 = async_mod.coop_pingpong(1000);
  if (n != 2000) {
    return 1;
  }
  return 0;
}
