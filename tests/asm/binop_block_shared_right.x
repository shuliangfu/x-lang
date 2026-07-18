// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: i32 = 10;
  let b: i32 = 20;
  let c: i32 = a + b;
  let d: i32 = a & b;
  let e: i32 = a | b;
  let f: i32 = a ^ b;
  return c + d + e + f;
}
