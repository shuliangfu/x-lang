/** Test method call returning struct.
 * PLATFORM: SHARED.
 */

trait Incrementable {
  function increment(self): Counter;
  function get(self): i32;
}

struct Counter { value: i32, }

impl Incrementable for Counter {
  function increment(self: Counter): Counter {
    return { value: self.value + 1 };
  }
  function get(self: Counter): i32 {
    return self.value;
  }
}

function main(): i32 {
  let c: Counter = { value: 10 };
  let d: Counter = c.increment();
  return d.get();
}
