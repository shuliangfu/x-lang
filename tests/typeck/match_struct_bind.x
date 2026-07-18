struct Point { x: i32; y: i32; }

/** Internal function `sum_xy`.
 * Implements `sum_xy`.
 * @param p Point
 * @return i32
 */
function sum_xy(p: Point): i32 {
  return match p {
    Point { x, y } => x + y;
  };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return sum_xy(Point { x: 10, y: 20 });
}
