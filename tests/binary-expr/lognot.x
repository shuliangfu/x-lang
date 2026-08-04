/** Internal function `main`.
 * Program/test entry point. `!` requires bool operand; cast to i32 for
 * exit code. Expected exit: 1 (`!false`).
 * @return i32
 */
function main(): i32 {
  return (!false) as i32;
}
