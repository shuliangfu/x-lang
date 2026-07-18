// See implementation.
#[repr(C)]
struct Point {
  x: i32
  y: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = Point { x: 4, y: 6 };
  return p.x + p.y;
}
