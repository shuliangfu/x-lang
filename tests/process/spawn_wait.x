// 测试 std.process：process.spawn_simple(program)、process.waitpid(pid)
//
// 【文件职责】本文件为 std.process 子进程创建与等待的回归测试。
// 【测试目的】确认 spawn_simple 与 waitpid 得到退出码 0。macOS 用
// /usr/bin/true，否则用 /bin/true（Alpine/Linux）。
// 【覆盖 API】process.spawn_simple(program: *u8): i32、process.waitpid(pid: i32): i32。
// 【预期结果】退出码 0 表示通过；1 表示 spawn_simple 失败；2 表示 waitpid
// 得到的 status≠0。Windows 上无 true，run-process.sh 会 SKIP。
// 【运行方式】./tests/run-process.sh
//
// 支持绑定 import：const process = import("std.process"); → process.getenv / process.spawn_simple 等
const process = import("std.process");

function run_true(path: *u8): i32 {
  let pid: i32 = process.spawn_simple(path);
  if (pid <= 0) { return -1; }
  // asm typeck：勿直接 return call()，先赋给 let 再 return（与 setenv 用例同因）。
  let rc: i32 = process.waitpid(pid);
  return rc;
}

function main(): i32 {
  let usr_true: u8[20] = [47, 117, 115, 114, 47, 98, 105, 110, 47, 116, 114, 117, 101, 0, 0, 0, 0,
  0, 0, 0];
  let bin_true: u8[16] = [47, 98, 105, 110, 47, 116, 114, 117, 101, 0, 0, 0, 0, 0, 0, 0];
  let status: i32 = 0;
  // OSTYPE=darwin 时优先 /usr/bin/true；勿拆成独立函数（asm WPO 可能未导出 is_darwin 符号）。
  let ostype_key: u8[8] = [79, 83, 84, 89, 80, 69, 0, 0];
  let ostype_val: *u8 = process.getenv(&ostype_key[0]);
  let on_darwin: bool = false;
  if (ostype_val != 0) {
    if (ostype_val[0] == 100 && ostype_val[1] == 97 && ostype_val[2] == 114 && ostype_val[3] == 119
        && ostype_val[4] == 105 && ostype_val[5] == 110) {
      on_darwin = true;
    }
  }
  if (on_darwin) {
    status = run_true(&usr_true[0]);
    if (status == 127) { status = run_true(&bin_true[0]); }
  } else {
    status = run_true(&bin_true[0]);
    if (status == 127) { status = run_true(&usr_true[0]); }
  }
  if (status == 0) { return 0; }
  return 2;
}
