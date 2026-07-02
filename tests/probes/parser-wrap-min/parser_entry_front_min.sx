const lexer = import("lexer");

extern function std_fs_open(path: *u8): i32;
extern function std_fs_read(fd: i32, buf: *u8, count: usize): isize;
extern function std_fs_close(fd: i32): i32;
extern function parser_parse_peek_function_name_buf_glue(lex: Lexer, data: *u8, len: i32, out: *u8): i32;

function parse_peek_function_name_buf(lex: Lexer, data: *u8, len: i32, out: *u8): i32 {
  return parser_parse_peek_function_name_buf_glue(lex, data, len, out);
}

function main(): i32 {
  return 0;
}
