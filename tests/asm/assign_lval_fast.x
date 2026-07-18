// See implementation.
struct Point {
  x: i32
  y: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  p.x = 10;
  let arr: u8[3] = [5, 10, 15];
  let i: i32 = 1;
  arr[i] = 42;
  // See implementation.
  return 52;
}
