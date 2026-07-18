/*
* See implementation.
* See implementation.
* See implementation.
*/
enum ShapeKind {
  SK_I32,
  SK_PTR,
  SK_SLICE
}

struct Shape {
  kind: ShapeKind;
  tag: i32;
}

/** Internal function `shape_is_ptr`.
 * Implements `shape_is_ptr`.
 * @param s Shape
 * @return bool
 */
function shape_is_ptr(s: Shape): bool {
  return s.kind == ShapeKind.SK_PTR;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
