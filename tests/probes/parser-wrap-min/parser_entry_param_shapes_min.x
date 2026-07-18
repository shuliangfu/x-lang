const lexer = import("lexer");

/** Internal function `plain_i32`.
 * Implements `plain_i32`.
 * @param x i32
 * @return i32
 */
function plain_i32(x: i32): i32 {
  return x;
}

/** Internal function `plain_ptr`.
 * Implements `plain_ptr`.
 * @param p *u8
 * @return i32
 */
function plain_ptr(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  return 1;
}

/** Internal function `imported_lexer`.
 * Implements `imported_lexer`.
 * @param lex Lexer
 * @return i32
 */
function imported_lexer(lex: Lexer): i32 {
  let pos: usize = lex.pos;
  if (pos > 0) {
    return 1;
  }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
