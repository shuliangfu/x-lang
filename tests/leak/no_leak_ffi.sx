// SAFE-005：std.ffi cstring_new(null,0)/free 无泄漏（避开 ASAN 路径 &arr[0] codegen 问题）。
const ffi = import("std.ffi");

function main(): i32 {
  let p: *u8 = ffi.cstring_new(0 as *u8, 0);
  if (p == 0 as *u8) {
    return 1;
  }
  ffi.cstring_free(p);
  return 0;
}
