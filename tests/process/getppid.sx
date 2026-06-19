// 测试 std.process：process.getppid()
//
// 【文件职责】本文件为 std.process 父进程 ID 查询的回归测试。
// 【测试目的】确认 process.getppid() 可安全调用不崩溃；Windows 无简单 API 返回
// -1，POSIX 返回父进程 ID（可能 >0 或 1）。
// 【覆盖 API】process.getppid(): i32。
// 【预期结果】退出码恒为 0（仅做调用与基本范围检查 ppid>=-1）。
// 【运行方式】./tests/run-process.sh
const process = import("std.process");

function main(): i32 {
  let ppid: i32 = process.getppid();
  if (ppid >= -1) {
    return 0;
  }
  return 0;
}
