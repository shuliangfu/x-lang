/** Minimal test for trait default method without Self.
 * PLATFORM: SHARED.
 */

trait Getable {
  function get(self): i32 { return 42; }
}

struct Counter { value: i32, }

impl Getable for Counter {
}

function main(): i32 {
  let c: Counter = Counter { value: 10 };
  return c.get();
}
