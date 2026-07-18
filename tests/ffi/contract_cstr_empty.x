// See implementation.
const ffi = import("std.ffi");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: u8[1] = [0];
  let n: i32 = ffi.cstr_len(&s[0]);
  if (n != 0) {
    return 1;
  }
  return 0;
}
