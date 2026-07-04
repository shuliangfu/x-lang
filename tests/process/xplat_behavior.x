// STD-142：std.process 跨平台行为聚合烟测
//
// 覆盖 pid/cwd/self_exe/pipe/spawn 可移植子集；spawn 失败时退出 0（Windows 无 /bin/true）。
const process = import("std.process");

function main(): i32 {
  // case 1：getpid 为正
  if (process.getpid() <= 0) { return 1; }
  // case 2：getppid 合法（Windows 为 -1）
  let pp: i32 = process.getppid();
  if (pp < -1) { return 2; }
  // case 3：getcwd 缓冲
  let cwd: u8[128] = [];
  if (process.getcwd(&cwd[0], 128) <= 0) { return 3; }
  // case 4：getcwd_ptr 零拷贝
  if (process.getcwd_ptr() == 0 as *u8) { return 4; }
  if (process.getcwd_cached_len() <= 0) { return 5; }
  // case 5：self_exe_path
  let exe: u8[256] = [];
  if (process.self_exe_path(&exe[0], 256) <= 0) { return 6; }
  // case 6：pipe 创建
  let rd: i32 = 0;
  let wr: i32 = 0;
  if (process.pipe(&rd, &wr) != 0) { return 7; }
  if (rd < 0 || wr < 0) { return 8; }
  // case 7：process.chdir(".") 不失败
  let dot: u8[2] = [46, 0];
  if (process.chdir(&dot[0]) != 0) { return 9; }
  // case 8：spawn_simple（POSIX true；失败则 skip）；内联 helper 避免 asm WPO 未导出子函数。
  let usr_true: u8[20] = [47, 117, 115, 114, 47, 98, 105, 110, 47, 116, 114, 117, 101, 0, 0, 0, 0, 0, 0, 0];
  let bin_true: u8[16] = [47, 98, 105, 110, 47, 116, 114, 117, 101, 0, 0, 0, 0, 0, 0, 0];
  let pid8: i32 = process.spawn_simple(&usr_true[0]);
  if (pid8 > 0) {
    let code8: i32 = process.waitpid(pid8);
    if (code8 != 0) { return 10; }
    return 0;
  }
  pid8 = process.spawn_simple(&bin_true[0]);
  if (pid8 > 0) {
    let code8b: i32 = process.waitpid(pid8);
    if (code8b != 0) { return 10; }
    return 0;
  }
  return 0;
}
