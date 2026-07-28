// main: see function docblock below.
// Negative: return operand then INT_LIT is not a statement head — ASI refuses
// (wave656). Bare `return 0 return 1` is Cap-T001 + ASI (first return final).
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0 1;
}
