// 测试 std.process：零拷贝 getcwd_ptr / self_exe_path_ptr
//
// 【文件职责】本文件为 std.process 零拷贝接口的回归测试。
// 【测试目的】确认 process.getcwd_ptr()、process.getcwd_cached_len()、process.self_exe_path_ptr()、process.self_exe_path_cached_len() 行为正确，无拷贝路径可用。
// 【覆盖 API】process.getcwd_ptr(): *u8、process.getcwd_cached_len(): i32、process.self_exe_path_ptr(): *u8、process.self_exe_path_cached_len(): i32。
// 【预期结果】退出码 0 表示两套指针与长度均有效；1/2 表示 getcwd 零拷贝失败；3/4 表示 self_exe_path 零拷贝失败。
// 【运行方式】./tests/run-process.sh
const process = import("std.process");

function main(): i32 {
  let p_cwd: *u8 = process.getcwd_ptr();
  if (p_cwd == 0) {
    return 1;
  }
  if (process.getcwd_cached_len() <= 0) {
    return 2;
  }
  let p_exe: *u8 = process.self_exe_path_ptr();
  if (p_exe == 0) {
    return 3;
  }
  if (process.self_exe_path_cached_len() <= 0) {
    return 4;
  }
  return 0;
}
