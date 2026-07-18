// See implementation.
enum Color {
  Red,
  Green,
  Blue,
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let c: Color = Color.Green;
  return match c { Color.Green => 1; Color.Red => 0; _ => -1; }
}
