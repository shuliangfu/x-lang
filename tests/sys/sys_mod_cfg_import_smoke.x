// B-19：std.sys/mod.x #[cfg] 分平台 import 烟测 — 非 host 子模块须被 parse 剪枝。
#[cfg(target_os = "linux")]
const linux = import("std.sys.linux");

#[cfg(target_os = "macos")]
const macos = import("std.sys.macos");

/** 按 host OS 探测对应子模块可用性；剪枝失败时会 typeck/link 报错。 */
#[cfg(target_os = "macos")]
function probe_platform(): i32 {
  return macos.macos_write_available();
}

#[cfg(target_os = "linux")]
function probe_platform(): i32 {
  return linux.linux_syscall_table_available();
}

function main(): i32 {
  if (probe_platform() != 1) {
    return 1;
  }
  return 0;
}
