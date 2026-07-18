// See implementation.
const regex = import("std.regex");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pat: u8[4] = [94, 104, 105, 36];
  let re: *u8 = regex.compile(&pat[0], 4);
  if (re == 0) { return 1; }
  let ok: u8[2] = [104, 105];
  if (regex.match(re, &ok[0], 2) != 0) { regex.free(re); return 2; }
  let bad: u8[3] = [120, 104, 105];
  if (regex.match(re, &bad[0], 3) == 0) { regex.free(re); return 3; }
  regex.free(re);
  return 0;
}
