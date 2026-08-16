/** Debug test: simplest default method.
 * PLATFORM: SHARED.
 */

trait Getable {
  function get(self): i32 { return 42; }
}

struct Counter { value: i32, }

impl Getable for {
}

function main(): i32 {
  let c: Counter = { value: 10 };
  return c.get();
}
