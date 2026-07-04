/**
 * Cookbook ASYNC-04：async net/fs fd 集成烟测（STD-079 #79）。
 * 调用 C 层 pipe 烟测；失败返回非 0。
 */
const async_mod = import("std.async");

function main(): i32 {
  if (async_mod.net_fs_async_smoke() != 0) {
    return 1;
  }
  return 0;
}
