/**
 * Cookbook PROC-01：getpid 当前进程 ID 查询（STD-023）。
 */
const process = import("std.process");

function main(): i32 {
  let pid: i32 = process.getpid();
  if (pid <= 0) { return 1; }
  return 0;
}
