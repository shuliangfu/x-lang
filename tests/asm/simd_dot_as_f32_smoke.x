// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let i: i32 = 0;
  while (i < 10) {
    let t: f32 = (i % 256) as f32;
    let _unused: f32 = t;
    i = i + 1;
  }
  return 0;
}
