// SAFE-004 C1：ffi.cstr_len(null) 须返回 -1，不得崩溃。
const ffi = import("std.ffi");

function main(): i32 {
  let n: i32 = ffi.cstr_len(0 as *u8);
  if (n != (0 - 1)) {
    return 1;
  }
  return 0;
}
