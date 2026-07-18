// See implementation.
// See implementation.

/* See implementation. */
struct Pair {
  a: i32
  b: i32
}

/* See implementation. */
async function struct_across_await(): i32 {
  let p: Pair = Pair { a: 3, b: 4 };
  let kick: i32 = p.a;
  let mid: i32 = await kick;
  return p.a + p.b + mid;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let suspended: i32 = 1095980800;
  let r: i32 = struct_across_await();
  if (r == suspended) {
    r = struct_across_await();
  }
  if (r != 10) {
    return 11;
  }
  return 0;
}
