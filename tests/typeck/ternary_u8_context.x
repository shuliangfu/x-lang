// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let is_dir: i32 = 1;
  let typeflag: u8 = 48;
  typeflag = is_dir != 0 ? 53 : 48;
  if (typeflag != 53) {
    return 1;
  }
  typeflag = is_dir == 0 ? 53 : 48;
  if (typeflag != 48) {
    return 2;
  }
  return 0;
}
