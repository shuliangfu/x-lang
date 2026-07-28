/** Probe wave491: Self return literal method_call.
 * A trait default method returns Self; call another method on the result.
 * PLATFORM: SHARED.
 */

trait Incrementable {
  function increment(self): Self;
  function get(self): i32;
}

struct Counter { value: i32, }

impl Incrementable for Counter {
  function increment(self: Counter): Counter {
    return Counter { value: self.value + 1 };
  }
  function get(self: Counter): i32 {
    return self.value;
  }
}

function main(): i32 {
  let c: Counter = Counter { value: 10 };
  return c.increment().get();
}
