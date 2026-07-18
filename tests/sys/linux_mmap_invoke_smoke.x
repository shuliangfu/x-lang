// See implementation.
const linux = import("std.sys.linux");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (linux.linux_syscall_invoke_available() != 1) {
    return 1;
  }
  let prot: i32 = 1 | 2;
  let flags: i32 = 2 | 0x20;
  let p: *u8 = linux.linux_anonymous_mmap(4096 as usize, prot, flags);
  let p_i: i64 = p as i64;
  if (p_i <= 0) {
    return 2;
  }
  p[0] = 77 as u8;
  p[1] = 65 as u8;
  if (p[0] != 77 as u8 || p[1] != 65 as u8) {
    return 3;
  }
  if (linux.linux_syscall_munmap(p, 4096 as usize) != 0) {
    return 4;
  }
  return 0;
}
