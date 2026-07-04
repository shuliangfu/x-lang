allow(padding) struct Lexer {
  pos: i32;
}

allow(padding) struct ParseExprResult {
  ok: bool;
  _pad: u8[7];
}

extern function parser_slice_from_buf(data: *u8, len: i32): u8[];
extern function parse_primary_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_unary_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_cast_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_term_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_addsub_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_shift_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_relcompare_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_compare_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_bitand_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_bitxor_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_bitor_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_logor_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_ternary_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_assign_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;
extern function parse_expr_into(arena: *u8, lex: Lexer, source: u8[], out: *ParseExprResult): void;

function parse_primary_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_primary_into(arena, lex, slice, out);
}

function parse_unary_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_unary_into(arena, lex, slice, out);
}

function parse_cast_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_cast_into(arena, lex, slice, out);
}

function parse_term_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_term_into(arena, lex, slice, out);
}

function parse_addsub_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_addsub_into(arena, lex, slice, out);
}

function parse_shift_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_shift_into(arena, lex, slice, out);
}

function parse_relcompare_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_relcompare_into(arena, lex, slice, out);
}

function parse_compare_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_compare_into(arena, lex, slice, out);
}

function parse_bitand_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_bitand_into(arena, lex, slice, out);
}

function parse_bitxor_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_bitxor_into(arena, lex, slice, out);
}

function parse_bitor_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_bitor_into(arena, lex, slice, out);
}

function parse_logor_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_logor_into(arena, lex, slice, out);
}

function parse_ternary_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_ternary_into(arena, lex, slice, out);
}

function parse_assign_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_assign_into(arena, lex, slice, out);
}

function parse_expr_into_buf(arena: *u8, lex: Lexer, data: *u8, len: i32, out: *ParseExprResult): void {
  let slice: u8[] = parser_slice_from_buf(data, len);
  parse_expr_into(arena, lex, slice, out);
}

function main(): i32 {
  return 0;
}
