// B-14 v1：Linux freestanding syscall invoke 烟测（read(0,NULL,0) + stdout write）。
const sys = import("std.sys");
const linux = import("std.sys.linux");

function main(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 1;
  }
  /** read(2) len=0 应返回 0（不读入字节）。 */
  let z: i32 = linux.linux_syscall_read(0, 0 as *u8, 0);
  if (z != 0) {
    return 2;
  }
  let msg: u8[12] = [72, 101, 108, 108, 111, 32, 83, 104, 117, 33, 10, 0];
  let n: i32 = sys.os_write_stdout(&msg[0], 11);
  if (n != 11) {
    return 3;
  }
  return 0;
}
