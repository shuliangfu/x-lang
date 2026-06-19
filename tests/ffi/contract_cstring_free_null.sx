// SAFE-004 C5：ffi.cstring_free(null) 为 no-op，不得崩溃。
const ffi = import("std.ffi");

function main(): i32 {
  ffi.cstring_free(0 as *u8);
  return 0;
}
