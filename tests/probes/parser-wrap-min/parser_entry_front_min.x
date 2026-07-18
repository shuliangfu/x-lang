const lexer = import("lexer");

extern "C" function std_fs_open(path: *u8): i32;
extern "C" function std_fs_read(fd: i32, buf: *u8, count: usize): isize;
extern "C" function std_fs_close(fd: i32): i32;
extern function parser_parse_peek_function_name_buf_glue(lex: Lexer, data: *u8, len: i32, out: *u8): i32;

/** Internal function `parse_peek_function_name_buf`.
 * Implements `parse_peek_function_name_buf`.
 * @param lex Lexer
 * @param data *u8
 * @param len i32
 * @param out *u8
 * @return i32
 */
function parse_peek_function_name_buf(lex: Lexer, data: *u8, len: i32, out: *u8): i32 {
  return parser_parse_peek_function_name_buf_glue(lex, data, len, out);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
