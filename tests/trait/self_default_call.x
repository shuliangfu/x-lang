/** Probe wave491: Self return default method with method_call.
 * A trait default method returns Self; call another method on the result.
 * PLATFORM: SHARED.
 */

trait Incrementable {
  function increment(self): Self {
    return { value: self.value + 1 };
  }
  function get(self): i32;
}

struct Counter { value: i32, }

impl Incrementable for {
  function get(self: Counter): i32 {
    return self.value;
  }
}

function main(): i32 {
  let c: Counter = { value: 10 };
  return c.increment().get();
}
