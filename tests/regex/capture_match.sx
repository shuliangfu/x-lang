// STD-064：capture group 0/1 偏移与长度
const regex = import("std.regex");

function main(): i32 {
  let pat: u8[5] = [40, 97, 98, 41, 99];
  let re: *u8 = regex.compile(&pat[0], 5);
  if (re == 0) { return 1; }
  if (group_count(re) != 2) { regex.free(re); return 2; }
  let hay: u8[5] = [120, 97, 98, 99, 121];
  if (regex.match(re, &hay[0], 5) != 0) { regex.free(re); return 3; }
  if (group_offset(re, 0) != 1) { regex.free(re); return 4; }
  if (group_length(re, 0) != 3) { regex.free(re); return 5; }
  if (group_offset(re, 1) != 1) { regex.free(re); return 6; }
  if (group_length(re, 1) != 2) { regex.free(re); return 7; }
  regex.free(re);
  return 0;
}
