// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let save: *i32 = 0 as *i32;
  region inner {
    let x: i32 = 7;
    save = &x;
  }
  return 0;
}
