// See implementation.
allow(padding)
struct WithGap {
  a: u8
  b: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: WithGap = WithGap { a: 1, b: 2 };
  return x.b;
}
