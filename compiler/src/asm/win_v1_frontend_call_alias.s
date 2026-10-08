/* w2084: call names the Oct 6 Windows xlang_asm emits.
 *
 * parser_x.o defines parser_parse_one_function_impl and relocates calls
 * to parse_one_function_impl. lexer_x.o defines lexer_init and the same
 * parser object calls lexer_lexer_init. typeck_x.o defines
 * typeck_get_dep_return_type_in_caller_arena and calls the bare name.
 * COFF `.set` did not keep a global. A jmp thunk does.
 * g2 is built by g1, whose call-symbol builder is the current .x, so
 * g2 and g3 do not emit these spellings. The thunks stay so every
 * Windows generation links the same object.
 * PLATFORM: WINDOWS x86_64.
 */
	.text
	.globl	parse_one_function_impl
parse_one_function_impl:
	jmp	parser_parse_one_function_impl
	.globl	get_dep_return_type_in_caller_arena
get_dep_return_type_in_caller_arena:
	jmp	typeck_get_dep_return_type_in_caller_arena
	.globl	lexer_lexer_init
lexer_lexer_init:
	jmp	lexer_init
	.globl	lexer_lexer_next_into
lexer_lexer_next_into:
	jmp	lexer_next_into
	.globl	lexer_lexer_next_buf
lexer_lexer_next_buf:
	jmp	lexer_next_buf
	.globl	lexer_lexer_note_string_lit_overflow
lexer_lexer_note_string_lit_overflow:
	jmp	lexer_note_string_lit_overflow
	.globl	lexer_lexer_unclosed_block_comment_pending
lexer_lexer_unclosed_block_comment_pending:
	jmp	lexer_unclosed_block_comment_pending
	.globl	lexer_lexer_unclosed_block_comment_reset
lexer_lexer_unclosed_block_comment_reset:
	jmp	lexer_unclosed_block_comment_reset
	.globl	lexer_lexer_unclosed_string_pending
lexer_lexer_unclosed_string_pending:
	jmp	lexer_unclosed_string_pending
	.globl	lexer_lexer_unclosed_string_reset
lexer_lexer_unclosed_string_reset:
	jmp	lexer_unclosed_string_reset
	.globl	lexer_lexer_illegal_char_pending
lexer_lexer_illegal_char_pending:
	jmp	lexer_illegal_char_pending
	.globl	lexer_lexer_illegal_char_reset
lexer_lexer_illegal_char_reset:
	jmp	lexer_illegal_char_reset
	.globl	lexer_lexer_incomplete_hex_pending
lexer_lexer_incomplete_hex_pending:
	jmp	lexer_incomplete_hex_pending
	.globl	lexer_lexer_incomplete_hex_reset
lexer_lexer_incomplete_hex_reset:
	jmp	lexer_incomplete_hex_reset
	.globl	lexer_lexer_incomplete_exp_pending
lexer_lexer_incomplete_exp_pending:
	jmp	lexer_incomplete_exp_pending
	.globl	lexer_lexer_incomplete_exp_reset
lexer_lexer_incomplete_exp_reset:
	jmp	lexer_incomplete_exp_reset
	.globl	lexer_lexer_incomplete_bin_pending
lexer_lexer_incomplete_bin_pending:
	jmp	lexer_incomplete_bin_pending
	.globl	lexer_lexer_incomplete_bin_reset
lexer_lexer_incomplete_bin_reset:
	jmp	lexer_incomplete_bin_reset
	.globl	lexer_lexer_incomplete_oct_pending
lexer_lexer_incomplete_oct_pending:
	jmp	lexer_incomplete_oct_pending
	.globl	lexer_lexer_incomplete_oct_reset
lexer_lexer_incomplete_oct_reset:
	jmp	lexer_incomplete_oct_reset
	.globl	lexer_lexer_invalid_digit_sep_pending
lexer_lexer_invalid_digit_sep_pending:
	jmp	lexer_invalid_digit_sep_pending
	.globl	lexer_lexer_invalid_digit_sep_reset
lexer_lexer_invalid_digit_sep_reset:
	jmp	lexer_invalid_digit_sep_reset
	.globl	lexer_lexer_invalid_type_suffix_pending
lexer_lexer_invalid_type_suffix_pending:
	jmp	lexer_invalid_type_suffix_pending
	.globl	lexer_lexer_invalid_type_suffix_reset
lexer_lexer_invalid_type_suffix_reset:
	jmp	lexer_invalid_type_suffix_reset
	.globl	lexer_lexer_invalid_escape_pending
lexer_lexer_invalid_escape_pending:
	jmp	lexer_invalid_escape_pending
	.globl	lexer_lexer_invalid_escape_reset
lexer_lexer_invalid_escape_reset:
	jmp	lexer_invalid_escape_reset
	.globl	lexer_lexer_string_lit_overflow_pending
lexer_lexer_string_lit_overflow_pending:
	jmp	lexer_string_lit_overflow_pending
	.globl	lexer_lexer_string_lit_overflow_reset
lexer_lexer_string_lit_overflow_reset:
	jmp	lexer_string_lit_overflow_reset
	.globl	lexer_lexer_ident_too_long_pending
lexer_lexer_ident_too_long_pending:
	jmp	lexer_ident_too_long_pending
	.globl	lexer_lexer_ident_too_long_reset
lexer_lexer_ident_too_long_reset:
	jmp	lexer_ident_too_long_reset
