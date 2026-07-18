// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: i32 = 0;
  defer { acc = acc + 100; }
  if (1 == 1) {
    defer { acc = acc + 1; }
    acc = 10;
  }
  return acc;
}
