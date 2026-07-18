// See implementation.
const regex = import("std.regex");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let pat: u8[5] = [91, 48, 45, 57, 93];
  let re: *u8 = regex.compile(&pat[0], 5);
  if (re == 0) { return 1; }
  let hay: u8[3] = [120, 53, 121];
  if (regex.match(re, &hay[0], 3) != 0) { regex.free(re); return 2; }
  regex.free(re);
  return 0;
}
