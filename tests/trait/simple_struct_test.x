/** Test simple struct return.
 * PLATFORM: SHARED.
 */

struct Counter { value: i32, }

function main(): i32 {
  let c: Counter = { value: 10 };
  let d: Counter = { value: c.value + 1 };
  return d.value;
}
