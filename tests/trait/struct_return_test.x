/** Test function returning struct.
 * PLATFORM: SHARED.
 */

struct Counter { value: i32, }

function make_counter(v: i32): Counter {
  return { value: v };
}

function main(): i32 {
  let c: Counter = make_counter(10);
  return c.value;
}
