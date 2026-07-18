// See implementation.
// fmt_test_tight_semicolons: see function docblock below.

/** Internal function `fmt_test_tight_semicolons`.
 * Implements `fmt_test_tight_semicolons`.
 * @return i32
 */
function fmt_test_tight_semicolons(): i32 {
  let prefix: u8[16] = [];
  prefix[0]=1; prefix[1]=2; prefix[2]=3; prefix[3]=4;
  let s: u8[8] = [];
  s[0]=97; s[1]=59; s[2]=98;
  return prefix[0] + prefix[3];
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return fmt_test_tight_semicolons();
}
