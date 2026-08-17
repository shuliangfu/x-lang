/** Ultra-minimal probe: simple Self return.
 * Just increment and return value, no chain call.
 * PLATFORM: SHARED.
 */

trait Incrementable {
  function increment(self): Self;
}

struct Counter { value: i32, }

impl Incrementable for Counter {
  function increment(self: Counter): Counter {
    return { value: self.value + 1 };
  }
}

function main(): i32 {
  let c: Counter = { value: 10 };
  let d: Counter = c.increment();
  return d.value;
}
