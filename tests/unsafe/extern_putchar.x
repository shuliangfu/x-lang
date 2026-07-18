// See implementation.
extern function putchar(c: i32): i32;

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  unsafe {
    putchar(65);
  }
  return 0;
}
