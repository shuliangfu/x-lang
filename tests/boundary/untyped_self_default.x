// Isolated green: trait default body may write bare `self`; hoist stamps
// the impl for-type (wave477) so UFCS and field access see Point, not `?`.
// Neighborhood: `self: Self` default and typed impl stay green.
// Expected: compile = 0, run = 7.
// PLATFORM: SHARED — Ubuntu gold.

struct Point {
  x: i32
  y: i32
}

trait GetX {
  /**
   * Default body: bare self is rewritten to Point at hoist commit.
   * @param self Point — stamped from `impl GetX for Point`
   * @return i32 — self.x
   */
  function get_x(self): i32 {
    return self.x;
  }
}

impl GetX for Point {
}

function main(): i32 {
  let p: Point = { x: 7, y: 9 };
  return p.get_x();
}
