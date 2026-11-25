/* Win tip-cold: lexer_next_into dual-ABI shim (DIG 2026-11-09).
 *
 * Tip PE parser_parse_one_function_impl (~110 call sites) passes:
 *   rcx=out, rdx=*Lexer, r8=*Fat{ptr,len}   (pointer ABI)
 * Tip PE lexer_next_buf_into / correct callers pass:
 *   rcx=out, rdx=lex.pos, r8=line|col, r9=*Fat  (by-value ABI)
 *
 * Heuristic: rdx >= 0x10000 => pointer ABI (source pos is always smaller
 * for practical inputs); else by-value. Then tail-call lexer_next_impl.
 * PLATFORM: WINDOWS|X86_64
 */
	.text
	.globl lexer_next_into
	.def lexer_next_into; .scl 2; .type 32; .endef

	.p2align 4
lexer_next_into:
	cmpq	$0x10000, %rdx
	jb	1f
	/* pointer ABI -> convert to by-value */
	movq	%r8, %r9
	movq	(%rdx), %rax
	movq	8(%rdx), %r8
	movq	%rax, %rdx
1:
	jmp	lexer_next_impl
