/* Win tip-cold: lexer_park_token_start + lexer_parked_token_start.
 *
 * Tip PE bug (DIG 2026-11-09): parked_token_start memcpy"s out.token_start
 * into a local then returns *Lxml_global instead of the parked value →
 * start_parked always wrong (0), span_len=l.pos, re-match "function".
 *
 * LexerResult.token_start @ +64 (0x40).
 * park:   memcpy(out+0x40, &start, 8) with start in rdx
 * parked: return *(u64*)(out+0x40)
 * PLATFORM: WINDOWS|X86_64
 */
	.text
	.globl lexer_park_token_start
	.def lexer_park_token_start; .scl 2; .type 32; .endef
	.globl lexer_parked_token_start
	.def lexer_parked_token_start; .scl 2; .type 32; .endef

	.p2align 4
lexer_park_token_start:
	movq	%rdx, 0x40(%rcx)
	ret

	.p2align 4
lexer_parked_token_start:
	movq	0x40(%rcx), %rax
	ret
