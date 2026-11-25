/* Win tip-cold: lexer_write_ident_token — product Token layout (48B).
 * kind@0,line@4,col@8,int_val@16,float@24,ident@32,ident_len@40.
 * Tip PE used tip-stride (@0/@8/@16/.../ilen@0x30) so ilen never landed in
 * the 48B image → parser name check sees ident_len=0 → P001.
 * ABI: rcx=out *Token, edx=line0, r8d=col0, r9d=nlen
 * PLATFORM: WINDOWS|X86_64
 */
	.text
	.globl lexer_write_ident_token
	.def lexer_write_ident_token; .scl 2; .type 32; .endef

	.p2align 4
lexer_write_ident_token:
	testq	%rcx, %rcx
	je	1f
	/* zero 48 bytes */
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movq	$0, 32(%rcx)
	movq	$0, 40(%rcx)
	movl	$0x3b, (%rcx)		/* TOKEN_IDENT=59 */
	movl	%edx, 4(%rcx)		/* line */
	movl	%r8d, 8(%rcx)		/* col */
	movl	%r9d, 40(%rcx)		/* ident_len */
1:
	ret
