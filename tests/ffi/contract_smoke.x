// SAFE-004 聚合烟测：串联 std.ffi 契约用例（无 extern）。
const ffi = import("std.ffi");

function main(): i32 {
  if (ffi.cstr_len(0 as *u8) != (0 - 1)) {
    return 1;
  }
  let s: u8[4] = [97, 98, 99, 0];
  if (ffi.cstr_len(&s[0]) != 3) {
    return 2;
  }
  let p: *u8 = ffi.cstring_new(&s[0], 3);
  if (p == 0 as *u8) {
    return 3;
  }
  if (ffi.cstr_len(p) != 3) {
    ffi.cstring_free(p);
    return 4;
  }
  ffi.cstring_free(p);
  ffi.cstring_free(0 as *u8);
  return 0;
}
