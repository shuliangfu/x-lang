/* knife256 / 10.2 + note743y.4: lexer_init dual ABI for tip cold.
 * Return-by-value (tip parser_parse_into_buf): 16-byte Lexer in rax+rdx.
 * Pointer ABI (pipeline_source_slice): also store through rdi when it is a
 * real out-pointer. Tip mistakenly leaves rdi=source after stash; refuse to
 * smash parked g_lex_src_data. PLATFORM: LINUX/MACOS x86_64
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
	testq	%rdi, %rdi
	jz	.Lret
	cmpq	$0x1000, %rdi
	jb	.Lret
	movq	g_lex_src_data(%rip), %rcx
	testq	%rcx, %rcx
	jz	.Lstore
	cmpq	%rcx, %rdi
	je	.Lret
.Lstore:
	movq	%rax, (%rdi)
	movq	%rdx, 8(%rdi)
.Lret:
	ret

	.extern	g_lex_src_data
