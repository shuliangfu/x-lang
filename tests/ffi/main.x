// See implementation.
const ffi = import("std.ffi");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: u8[8] = [97, 98, 99, 0, 0, 0, 0, 0];
  let n: i32 = ffi.cstr_len(&s[0]);
  if (n != 3) { return 1; }
  let owned: *u8 = ffi.cstring_new(&s[0], 3);
  if (owned == 0) { return 2; }
  let n2: i32 = ffi.cstr_len(owned);
  if (n2 != 3) { ffi.cstring_free(owned); return 3; }
  ffi.cstring_free(owned);
  return 0;
}
