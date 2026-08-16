// Official gate: dest-typed match patterns `{ fields } =>`.
// Type comes from the match subject. Named `Type { fields } =>`
// still accepted (same field loop).
// PLATFORM: SHARED — Ubuntu gold.

struct Point {
  x: i32
  y: i32
}

/**
 * Field-bind + field-lit + field-wild + explicit guard, all anonymous.
 * @param p Point — match subject
 * @return i32 — 0 origin, 1 x-zero, 2 x>y, else 3
 */
function classify(p: Point): i32 {
  return match p {
    { x: 0, y: 0 } => 0;
    { x: 0, y: _ } => 1;
    { x, y } if x > y => 2;
    { x, y } => 3;
  };
}

/**
 * Field-bind sum. Named pattern kept as neighborhood.
 * @param p Point — match subject
 * @return i32 — x + y
 */
function sum_xy(p: Point): i32 {
  return match p {
    { x, y } => x + y;
  };
}

/**
 * Named pattern still works (same field-pattern authority).
 * @param p Point — match subject
 * @return i32 — x + y
 */
function sum_named(p: Point): i32 {
  return match p {
    Point { x, y } => x + y;
  };
}

/**
 * Official entry: anonymous bind / lit / wild / guard + named neighborhood.
 * @return i32 — 0 on success
 */
function main(): i32 {
  if (classify({ x: 0, y: 0 }) != 0) {
    return 1;
  }
  if (classify({ x: 0, y: 9 }) != 1) {
    return 2;
  }
  if (classify({ x: 8, y: 3 }) != 2) {
    return 3;
  }
  if (classify({ x: 1, y: 4 }) != 3) {
    return 4;
  }
  if (sum_xy({ x: 10, y: 20 }) != 30) {
    return 5;
  }
  if (sum_named({ x: 10, y: 20 }) != 30) {
    return 6;
  }
  return 0;
}
