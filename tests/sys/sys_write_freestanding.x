// BOOT-029：std.sys freestanding stdout 烟测（Linux x86_64 + -freestanding）。
const sys = import("std.sys");

function main(): i32 {
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 83, 104, 117, 33, 10, 0];
  let n: i32 = sys.write_stdout(&msg[0], 11);
  if (n != 11) {
    return 1;
  }
  return 0;
}
