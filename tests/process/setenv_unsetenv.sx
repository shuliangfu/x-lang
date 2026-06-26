// 测试 std.process：setenv、getenv、unsetenv 全覆盖
//
// 【文件职责】本文件为 std.process 环境变量设置与删除的回归测试。
// 【测试目的】确认 setenv 后 getenv 能读到值、unsetenv 后 getenv 返回 0；覆盖
// process.setenv(name, value, overwrite) 与 process.unsetenv(name)。
// 【覆盖 API】process.setenv(name, value, overwrite)、process.getenv(name)、process.unsetenv(name)。
// 【测试步骤】process.setenv("X","v",1) → process.getenv("X") 得 "v"（首字节 118）→ process.unsetenv("X")
// → process.getenv("X") 得 0。
// 【预期结果】退出码 0 表示通过；1~5 分别表示 setenv 失败、getenv
// 空、值首字节非 'v'、unsetenv 失败、unset 后仍非空。
// 【运行方式】./tests/run-process.sh
const process = import("std.process");

function main(): i32 {
  // name "X" = [88, 0, ...], value "v" = [118, 0, ...]
  let name: u8[4] = [88, 0, 0, 0];
  let value: u8[4] = [118, 0, 0, 0];
  // asm codegen：if (call() != 0) 条件内调用可能不执行副作用；先赋给 let 再判断。
  let set_r: i32 = process.setenv(&name[0], &value[0], 1);
  if (set_r != 0) {
    return 1;
  }
  let v: *u8 = process.getenv(&name[0]);
  if (v == 0) {
    return 2;
  }
  if (v[0] != 118) {
    return 3;
  }
  let unset_r: i32 = process.unsetenv(&name[0]);
  if (unset_r != 0) {
    return 4;
  }
  let v2: *u8 = process.getenv(&name[0]);
  if (v2 != 0) {
    return 5;
  }
  return 0;
}
