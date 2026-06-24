/**
 * Cookbook JSON-01：skip_value 游标跳过整棵 JSON 值（STD-034）。
 */
const json = import("std.json");

function main(): i32 {
  /** {"a":1} */
  let doc: u8[7] = [123, 34, 97, 34, 58, 49, 125];
  let consumed: i32 = 0;
  if (json.skip_value(&doc[0], 7, &consumed) != 0) { return 1; }
  if (consumed != 7) { return 2; }
  return 0;
}
