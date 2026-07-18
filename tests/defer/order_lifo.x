// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let acc: i32 = 0;
  defer { acc = acc * 10 + 1; }
  defer { acc = acc * 10 + 2; }
  return acc;
}
