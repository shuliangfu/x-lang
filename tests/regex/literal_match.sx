// STD-051：字面量子串匹配
const regex = import("std.regex");

function main(): i32 {
  let pat: u8[5] = [104, 101, 108, 108, 111];
  let re: *u8 = regex.compile(&pat[0], 5);
  if (re == 0) { return 1; }
  let hay: u8[9] = [115, 97, 121, 32, 104, 101, 108, 108, 111];
  if (regex.match(re, &hay[0], 9) != 0) { regex.free(re); return 2; }
  regex.free(re);
  return 0;
}
