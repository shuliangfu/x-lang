// BOOT-029 B-21：FreeBSD POSIX write 烟测（FreeBSD host + 常规 -o exe）。
const sys = import("std.sys");

function main(): i32 {
  if (sys.freebsd_write_available() != 1) {
    return 1;
  }
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 83, 104, 117, 33, 10, 0];
  let n: i32 = sys.freebsd_write_stdout(&msg[0], 11);
  if (n != 11) {
    return 2;
  }
  return 0;
}
