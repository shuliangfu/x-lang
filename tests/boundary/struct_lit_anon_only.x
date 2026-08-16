// Named `Type { fields }` is rejected as a value. Dest type names the
// struct: `let x: Type = { fields }`. Match-arm patterns still use
// `Type { fields } =>` (anonymous `{ fields } =>` is T001).
// Expected: typeck T001 on the named let.
// PLATFORM: SHARED — Ubuntu gold.

struct Point {
  x: i32
  y: i32
}

/**
 * Named struct literal must not typeck.
 * @return i32 — not reached
 */
function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  return p.x;
}
