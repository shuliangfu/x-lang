/** Internal function `main`.
 * Program/test entry point. Logical ops require bool operands; cast results
 * to i32 for exit-code sum. Expected exit: 2.
 * @return i32
 */
function main(): i32 {
  return ((true && true) as i32) + ((false || true) as i32);
}
