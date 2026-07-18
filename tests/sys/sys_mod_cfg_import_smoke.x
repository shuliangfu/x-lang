// See implementation.
#[cfg(target_os = "linux")]
const linux = import("std.sys.linux");

#[cfg(target_os = "macos")]
const macos = import("std.sys.macos");

/** Internal function `probe_platform`.
 * Implements `probe_platform`.
 * @return i32
 */
#[cfg(target_os = "macos")]
function probe_platform(): i32 {
  return macos.macos_write_available();
}

/** Internal function `probe_platform`.
 * Implements `probe_platform`.
 * @return i32
 */
#[cfg(target_os = "linux")]
function probe_platform(): i32 {
  return linux.linux_syscall_table_available();
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (probe_platform() != 1) {
    return 1;
  }
  return 0;
}
