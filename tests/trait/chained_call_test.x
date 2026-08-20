/** Test chained method calls with struct return.
 * PLATFORM: SHARED.
 */

struct Counter { value: i32, }

function increment(c: Counter): Counter {
  return { value: c.value + 1 };
}

function get_value(c: Counter): i32 {
  return c.value;
}

function main(): i32 {
  let c: Counter = { value: 10 };
  return get_value(increment(c));
}
