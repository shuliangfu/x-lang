/**
 * See implementation.
 */
const tar = import("std.tar");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  // Header (512) + one padded data block (512). A 512-byte buffer cannot hold both.
  let arc: u8[1024] = [];
  let off: i32 = 0;
  /** "a.txt" */
  let name: u8[5] = [97, 46, 116, 120, 116];
  let data: u8[1] = [120];
  if (tar.append_entry(&arc[0], 1024, &off, &name[0], 5, &data[0], 1, 0) != 0) { return 1; }
  if (off <= 0) { return 2; }
  return 0;
}
