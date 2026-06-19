// BOOT-029 v1：Linux syscall 号表烟测（仅 typeck + 常量断言）。
// mod 层 linux_syscall_* 仅 #[cfg(target_os=linux)]；跨 host 只测 std.sys.linux 子模块。
const linux = import("std.sys.linux");

function main(): i32 {
  if (linux.linux_syscall_table_available() != 1) {
    return 1;
  }
  // x86_64：与 freestanding_io_x86_64.s mov $1, %eax 一致
  if (linux.syscall_nr_write_amd64() != 1) {
    return 3;
  }
  if (linux.syscall_nr_exit_amd64() != 60) {
    return 4;
  }
  // aarch64：与内核 unistd.h 一致
  if (linux.syscall_nr_write_arm64() != 64) {
    return 5;
  }
  if (linux.syscall_nr_openat_arm64() != 56) {
    return 6;
  }
  return 0;
}
