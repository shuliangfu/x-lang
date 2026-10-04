// See implementation.
const string = import("std.string");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // See implementation.
  let buf: u8[16] = [97, 98, 114, 97, 99, 97, 100, 97, 98, 114, 97, 0, 0, 0, 0, 0];
  let s: String = { length: 0 };
  if (string.string_from_slice(&buf[0], 11, &s) != 0) { return 1; }
  let ab: u8[2] = [97, 98];
  if (string.string_contains(s, &ab[0], 2) != 1) { return 1; }
  let xz: u8[2] = [120, 122];
  if (string.string_contains(s, &xz[0], 2) != 0) { return 2; }
  if (string.string_find_slice(s, &ab[0], 2) != 0) { return 3; }
  let ra: u8[2] = [114, 97];
  if (string.string_find_slice(s, &ra[0], 2) != 2) { return 4; }
  if (string.string_find_slice(s, &xz[0], 2) != -1) { return 5; }
  if (string.string_rfind_char(s, 97 as u8) != 10) { return 6; }
  if (string.string_rfind_char(s, 98 as u8) != 8) { return 7; }
  if (string.string_rfind_char(s, 122 as u8) != -1) { return 8; }
  // trim: "  hi  " -> "hi"
  let with_sp: u8[8] = [32, 32, 104, 105, 32, 32, 0, 0];
  let st: String = { length: 0 };
  if (string.string_from_slice(&with_sp[0], 6, &st) != 0) { return 9; }
  let out: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = string.trim(st, &out[0], 8);
  if (n != 2) { return 9; }
  if (out[0] != (104 as u8) || out[1] != (105 as u8)) { return 10; }
  // replace_char
  let ss: String = { length: 0 };
  if (string.string_from_slice(&buf[0], 11, &ss) != 0) { return 11; }
  let cnt: i32 = string.replace(&ss, 97 as u8, 65 as u8);
  if (cnt != 5) { return 11; }
  if (string.string_get(ss, 0) != (65 as u8)) { return 12; }
  if (string.string_get(ss, 3) != (65 as u8)) { return 13; }
  return 0;
}
