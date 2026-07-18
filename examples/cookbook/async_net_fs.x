/**
 * See implementation.
 * See implementation.
 */
const async_mod = import("std.async");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (async_mod.net_fs_async_smoke() != 0) {
    return 1;
  }
  return 0;
}
