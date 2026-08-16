// wave708: struct field literal pattern — stmt path (RETURN arms → codegen_emit_match_as_stmt).
// `return match p { Point { x: 0, y: 0 } => return 1; ... }` triggers stmt path.
#[repr(C)]
struct Point { x: i32; y: i32; }

/** Internal function `classify_stmt`.
 * @param p Point
 * @return i32
 */
function classify_stmt(p: Point): i32 {
  return match p {
    Point { x: 0, y: 0 } => return 1;
    Point { x: 1, y: 1 } => return 2;
    _ => return 0;
  }
}

/** Internal function `main`.
 * @return i32
 */
function main(): i32 {
  let origin: Point = { x: 0, y: 0 };
  let diag: Point = { x: 1, y: 1 };
  let other: Point = { x: 3, y: 4 };
  if (classify_stmt(origin) != 1) { return 1; }
  if (classify_stmt(diag) != 2) { return 2; }
  if (classify_stmt(other) != 0) { return 3; }
  return 0;
}
