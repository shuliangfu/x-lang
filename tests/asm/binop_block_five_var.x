// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let vol0: i32 = 40;
  let vol1: i32 = 41;
  let a: i32 = 10;
  let b: i32 = 20;
  let c: i32 = 30;
  let d: i32 = 40;
  let e: i32 = 50;
  let t0: i32 = a + b;
  let t1: i32 = c + d;
  let t2: i32 = e + vol0;
  return t0 + t1 + t2 + vol1;
}
