// See implementation.
// See implementation.
const linux = import("std.sys.linux");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (linux.linux_syscall_table_available() != 1) {
    return 1;
  }
  // See implementation.
  if (linux.linux_syscall_nr_write_amd64() != 1) {
    return 3;
  }
  if (linux.linux_syscall_nr_exit_amd64() != 60) {
    return 4;
  }
  // See implementation.
  if (linux.linux_syscall_nr_write_arm64() != 64) {
    return 5;
  }
  if (linux.linux_syscall_nr_openat_arm64() != 56) {
    return 6;
  }
  return 0;
}
