// knife256/10.2: Cap tip rewrites lexer_next_buf_into → lexer_next_into
// in .x emits (same prefix). Distinct peel name keeps the 4-arg buf_into.
// PLATFORM: MACOS arm64 Cap tip.
	.globl	_parser_asm_lex_peel_next_buf_into
	.p2align	2
_parser_asm_lex_peel_next_buf_into:
	b	_lexer_next_buf_into
