// Named `Type { fields }` is accepted as a value (LANG-009), alongside
// anonymous `let x: Type = { fields }`. Match-arm patterns may write
// `{ fields } =>` (type from subject) or `Type { fields } =>`.
// Expected: typeck OK; run returns 1.
// PLATFORM: SHARED — Ubuntu gold.

struct Point {
  x: i32
  y: i32
}

/**
 * Named struct literal typecks and runs.
 * @return i32 — Point.x
 */
function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  return p.x;
}
