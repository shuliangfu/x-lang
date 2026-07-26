/** Test struct construction.
 * PLATFORM: SHARED.
 */

struct Counter { value: i32, }

function main(): i32 {
  let c: Counter = Counter { value: 10 };
  return c.value;
}
