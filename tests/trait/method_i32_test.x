/** Test method call returning i32.
 * PLATFORM: SHARED.
 */

trait Getable {
  function get(self): i32;
}

struct Counter { value: i32, }

impl Getable for {
  function get(self: Counter): i32 {
    return self.value;
  }
}

function main(): i32 {
  let c: Counter = { value: 42 };
  return c.get();
}
