// See implementation.
// Struct match: lit / wild field pats; arm bodies use subject fields (p.x / p.y).
// Shorthand binds `Point { x, y }` remain a known typeck gap (Cap tip + LEGACY).
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
    Point { x: _, y: _ } if p.x > p.y => 2;
    Point { x: _, y: _ } => 3;
  };
}

/** Internal function `sum_xy`.
 * Implements `sum_xy`.
 * @param p Point
 * @return i32
 */
function sum_xy(p: Point): i32 {
  return match p {
    Point { x: _, y: _ } => p.x + p.y;
  };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (classify({ x: 0, y: 0 }) != 0) {
    return 1;
  }
  if (classify({ x: 0, y: 5 }) != 1) {
    return 2;
  }
  if (classify({ x: 3, y: 1 }) != 2) {
    return 3;
  }
  if (classify({ x: 1, y: 2 }) != 3) {
    return 4;
  }
  if (sum_xy({ x: 10, y: 20 }) != 30) {
    return 5;
  }
  return 0;
}
