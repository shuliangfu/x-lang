// See implementation.
const ffi = import("std.ffi");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: *u8 = ffi.cstring_new(0 as *u8, 0);
  if (p == 0 as *u8) {
    return 1;
  }
  let n: i32 = ffi.cstr_len(p);
  if (n != 0) {
    ffi.cstring_free(p);
    return 2;
  }
  ffi.cstring_free(p);
  return 0;
}
