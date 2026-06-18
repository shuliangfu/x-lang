/**
 * Cookbook UNI-01：unicode is_supplementary / rune_utf8_len（STD-037）。
 */
const unicode = import("std.unicode");

function main(): i32 {
  if (unicode.is_supplementary(128512 as u32) != 1) { return 1; }
  if (unicode.is_supplementary(233 as u32) != 0) { return 2; }
  if (unicode.rune_utf8_len(128512 as u32) != 4) { return 3; }
  if (unicode.rune_utf8_len(233 as u32) != 2) { return 4; }
  return 0;
}
