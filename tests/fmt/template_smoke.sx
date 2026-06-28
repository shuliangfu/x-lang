// STD-166：format_template_1_i32 烟测
const fmt = import("std.fmt");

function main(): i32 {
  let pat: u8[5] = [120, 123, 125, 121, 0];
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.format_template(&buf[0], 32, &pat[0], 4, 42);
  if (n < 3) { return 1; }
  if (buf[0] != 120 || buf[1] != 52 || buf[2] != 50) { return 2; }
  return 0;
}
