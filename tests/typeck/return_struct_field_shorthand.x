// See implementation.
struct Point { x: i32; y: i32; }

/** Internal function `make_point`.
 * Implements `make_point`.
 * @param x i32
 * @return Point
 */
function make_point(x: i32): Point {
  return { x, y: 2 };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = make_point(7);
  if (p.x != 7 || p.y != 2) {
    return 1;
  }
  return 0;
}
