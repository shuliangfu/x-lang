// See implementation.
const ffi = import("std.ffi");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = ffi.cstr_len(0 as *u8);
  if (n != (0 - 1)) {
    return 1;
  }
  return 0;
}
