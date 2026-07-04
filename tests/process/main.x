// 测试 std.process.exit(code)
//
// 【文件职责】本文件为 std.process 单用例测试，用于验证进程退出码行为。
// 【测试目的】确认进程以指定退出码终止（B-strict asm 链 smoke；process.exit→C exit 特判待 asm codegen）。
// 【覆盖 API】main 返回码 99（等价 exit 烟测）。
// 【预期结果】进程退出码为 99；由 run-process.sh 通过「运行后检查 $? -eq 99」校验。
// 【运行方式】./tests/run-process.sh
const process = import("std.process");

function main(): i32 {
  // TODO：asm codegen 特判 process.exit(code)→exit(code) 后改回 process.exit(99)。
  return 99;
}
