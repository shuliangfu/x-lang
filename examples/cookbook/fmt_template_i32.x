/**
 * Cookbook FMT-02：format_template_1_i32 模板填充（STD-166）。
 */
const fmt = import("std.fmt");

function main(): i32 {
  let pat: u8[5] = [120, 123, 125, 121, 0];
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = fmt.format_template(&buf[0], 32, &pat[0], 4, 42);
  if (n < 3 || buf[1] != 52) { return 1; }
  return 0;
}
