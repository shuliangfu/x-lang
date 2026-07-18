allow(padding) struct Lexer {
  pos: i32;
}

allow(padding) struct WrapResult {
  lex: Lexer;
  skipped: i32;
  _pad: u8[4];
}

extern function parser_slice_from_buf(data: *u8, len: i32): u8[];
extern function skip_balanced_parens_into(out: *Lexer, lex: Lexer, source: u8[]): void;
extern function parse_into_try_skip_allow_buf(lex: Lexer, data: *u8, len: i32): WrapResult;

/** Internal function `skip_balanced_parens_slice_into_buf`.
 * Implements `skip_balanced_parens_slice_into_buf`.
 * @param out *Lexer
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return void
 */
function skip_balanced_parens_slice_into_buf(out: *Lexer, lex: Lexer, data: *u8, len: i32): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  skip_balanced_parens_into(out, lex, slice);
}

/** Internal function `parse_into_try_skip_allow_from_buf`.
 * Implements `parse_into_try_skip_allow_from_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @return WrapResult
 */
function parse_into_try_skip_allow_from_buf(lex: Lexer, data: *u8, len: i32): WrapResult {
  return parse_into_try_skip_allow_buf(lex, data, len);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
