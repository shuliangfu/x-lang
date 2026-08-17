/** Probe wave491: simplest Self return default.
 * Just return self to test if Self return works.
 * PLATFORM: SHARED.
 */

trait Getable {
  function get(self): i32 { return 42; }
}

struct Counter { value: i32, }

impl Getable for Counter {
}

function main(): i32 {
  let c: Counter = { value: 10 };
  return c.get();
}
