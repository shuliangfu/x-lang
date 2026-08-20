// wave708: struct field literal pattern — expression form (return match → ternary path).
// Point { x: 0, y: 0 } generates implicit guard `p.x == 0 && p.y == 0`.
#[repr(C)]
struct Point { x: i32; y: i32; }

/** Internal function `classify`.
 * @param p Point
 * @return i32
 */
function classify(p: Point): i32 {
  return match p {
    Point { x: 0, y: 0 } => 1;
    Point { x: 1, y: 1 } => 2;
    _ => 0;
  };
}

/** Internal function `main`.
 * @return i32
 */
function main(): i32 {
  let origin: Point = { x: 0, y: 0 };
  let diag: Point = { x: 1, y: 1 };
  let other: Point = { x: 3, y: 4 };
  if (classify(origin) != 1) { return 1; }
  if (classify(diag) != 2) { return 2; }
  if (classify(other) != 0) { return 3; }
  return 0;
}
