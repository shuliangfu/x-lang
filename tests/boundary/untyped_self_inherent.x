// Isolated compile-fail: inherent impl untyped self is not product syntax.
// 4.2.1 / wave493: write `self: Point`. `self.x` with type_ref 0 was `?`.
// Expected: compile != 0 (P011). Do not -o / run.
// PLATFORM: SHARED — Ubuntu gold.

struct Point {
  x: i32
  y: i32
}

impl Point {
  /**
   * Must not parse: inherent method receiver without `: Type`.
   * @param self — untyped; P011
   * @return i32 — unused (compile must fail)
   */
  function get_x(self): i32 {
    return self.x;
  }
}

function main(): i32 {
  let p: Point = { x: 7, y: 9 };
  return p.get_x();
}
