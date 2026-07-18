/**
 * See implementation.
 */
struct BadShare {
  head: u32
  data: u32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: BadShare = BadShare { head: 0, data: 0 };
  s.head = 1 as u32;
  s.data = 2 as u32;
  return s.head + s.data;
}
