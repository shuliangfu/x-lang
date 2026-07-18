/**
 * See implementation.
 * See implementation.
 */
allow(padding) struct Ring64 {
  align(64) head: u32
  align(64) tail: u32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r: Ring64 = Ring64 { head: 0, tail: 0 };
  r.head = 11 as u32;
  r.tail = 53 as u32;
  return r.head + r.tail;
}
