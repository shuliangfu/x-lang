// See implementation.
//
// See implementation.
const process = import("std.process");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  if (process.getpid() <= 0) { return 1; }
  // See implementation.
  let pp: i32 = process.getppid();
  if (pp < -1) { return 2; }
  // See implementation.
  let cwd: u8[128] = [];
  if (process.getcwd(&cwd[0], 128) <= 0) { return 3; }
  // See implementation.
  if (process.getcwd_ptr() == 0 as *u8) { return 4; }
  if (process.getcwd_cached_len() <= 0) { return 5; }
  // case 5：self_exe_path
  let exe: u8[256] = [];
  if (process.self_exe_path(&exe[0], 256) <= 0) { return 6; }
  // See implementation.
  let rd: i32 = 0;
  let wr: i32 = 0;
  if (process.pipe(&rd, &wr) != 0) { return 7; }
  if (rd < 0 || wr < 0) { return 8; }
  // See implementation.
  let dot: u8[2] = [46, 0];
  if (process.chdir(&dot[0]) != 0) { return 9; }
  // See implementation.
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
