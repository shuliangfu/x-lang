/** Internal function `main`.
 * Program/test entry point. Compare results are bool; cast to i32 for sum
 * (wave677 forbids bool arithmetic). Expected exit: 3.
 * @return i32
 */
function main(): i32 {
  return ((3 == 3) as i32) + ((2 < 5) as i32) + ((5 > 2) as i32);
}
