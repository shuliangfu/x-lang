// See implementation.
extern function putchar(c: i32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 0;
  unsafe {
    n = putchar(66);
  }
  if (n < 0) {
    return 1;
  }
  return 0;
}
