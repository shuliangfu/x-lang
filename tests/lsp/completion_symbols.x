/**
 * See implementation.
 */
const mem = import("core.mem");

struct Point {
  x: i32
  y: i32
}

enum Kind {
  Alpha
  Beta
}

/** Internal function `add_one`.
 * Implements `add_one`.
 * @param v i32
 * @return i32
 */
function add_one(v: i32): i32 {
  return v + 1;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  return add_one(p.x);
}
