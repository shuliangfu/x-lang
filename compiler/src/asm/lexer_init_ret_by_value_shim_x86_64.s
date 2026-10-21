/* knife256 / 10.2 + note743y.4 + note743y.5: lexer_init return-by-value only.
 * Tip parser_parse_into_buf (entry + dep) passes source in rdi under the
 * mistaken leftover ABI and expects Lexer in rax+rdx. Writing through rdi
 * smashes any source that is not the single parked g_lex_src_data (deps),
 * leaving num_funcs=0 → import method T001. Out-ptr tip faces stay demoted;
 * this shim is the sole lexer_init. PLATFORM: LINUX/MACOS x86_64
 */
#if defined(__APPLE__)
	.globl	_lexer_init
_lexer_init:
#else
	.globl	lexer_init
lexer_init:
#endif
	xorq	%rax, %rax
	movq	$0x100000001, %rdx
	ret
