// See implementation.
struct Header packed {
  tag: u8;
  length: u32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let h: Header = Header { tag: 1, length: 42 };
  return 0;
}
