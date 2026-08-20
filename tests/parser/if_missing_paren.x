// Negative fixture: statement `if` missing condition entirely.
// Historical name kept for run-parser.sh; if-expr `return if 1 < 2 {…}` is legal.
/**
 * Internal function `main`.
 * Program/test entry point — must fail parse (incomplete if).
 * @return i32
 */
function main(): i32 {
  if {
    return 1;
  }
  return 0;
}
