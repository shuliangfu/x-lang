// wave709: struct field wildcard value `Point { x: 0, y: _ }`.
// `y: _` skips guard for that field; only `x == 0` is the implicit guard.
// Multi-arm classify with mixed literal + wildcard field values.
#[repr(C)]
struct Point { x: i32; y: i32; }

/** Internal function `classify`.
 * @param p Point
 * @return i32
 */
function classify(p: Point): i32 {
  return match p {
    Point { x: 0, y: 0 } => 1;
    Point { x: 0, y: _ } => 2;
    _ => 0;
  };
}

/** Internal function `main`.
 * @return i32
 */
function main(): i32 {
  let origin: Point = { x: 0, y: 0 };
  let xAxis: Point = { x: 0, y: 5 };
  let other: Point = { x: 3, y: 4 };
  if (classify(origin) != 1) { return 1; }
  if (classify(xAxis) != 2) { return 2; }
  if (classify(other) != 0) { return 3; }
  return 0;
}
