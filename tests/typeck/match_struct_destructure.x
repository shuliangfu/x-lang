// See implementation.
struct Point { x: i32; y: i32; }

/** Internal function `classify`.
 * Implements `classify`.
 * @param p Point
 * @return i32
 */
function classify(p: Point): i32 {
  return match p {
    Point { x: 0, y: 0 } => 0;
    Point { x: 0, y: _ } => 1;
    Point { x, y } if x > y => 2;
    Point { x, y } => 3;
  };
}

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
  if (classify(Point { x: 0, y: 0 }) != 0) {
    return 1;
  }
  if (sum_xy(Point { x: 10, y: 20 }) != 30) {
    return 5;
  }
  return 0;
}
