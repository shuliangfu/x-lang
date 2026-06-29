/**
 * Cookbook SYS-01：std.sys freestanding stdout（BOOT-029）。
 * 须 Linux x86_64 + shux -freestanding -backend asm。
 */
const sys = import("std.sys");

function main(): i32 {
  let msg: u8[6] = [79, 75, 10, 0, 0, 0];
  let n: i32 = sys.write_stdout(&msg[0], 3);
  if (n != 3) {
    return 1;
  }
  return 0;
}
