/* Win tip-cold: lexer_next_punct_into dig_min puncts, natural Token layout.
 * rcx=out LexerResult*, rdx=pos, r8=line|(col<<32), r9=&Fat (ignored),
 * [rsp+0x28]=c (after retaddr; at entry before push).
 * Writes next_lex@0, tok@16 (kind@0 line@4 col@8 of Token), token_start@64.
 */
	.text
	.globl lexer_next_punct_into
	.def lexer_next_punct_into; .scl 2; .type 32; .endef

	.p2align 4
lexer_next_punct_into:
	movzbl	0x28(%rsp), %eax		/* c */
	movl	%r8d, %r10d			/* line */
	movq	%r8, %r11
	shrq	$32, %r11			/* col */
	/* token col0 = current col; then advance */
	movl	%r11d, %r8d			/* col0 */
	addq	$1, %rdx			/* pos++ */
	addl	$1, %r11d			/* col++ */
	/* map c -> kind */
	movl	$0, %r9d
	cmpb	$40, %al
	jne	1f
	movl	$82, %r9d
	jmp	9f
1:	cmpb	$41, %al
	jne	2f
	movl	$83, %r9d
	jmp	9f
2:	cmpb	$123, %al
	jne	3f
	movl	$84, %r9d
	jmp	9f
3:	cmpb	$125, %al
	jne	4f
	movl	$85, %r9d
	jmp	9f
4:	cmpb	$58, %al
	jne	5f
	movl	$91, %r9d
	jmp	9f
5:	cmpb	$59, %al
	jne	6f
	movl	$95, %r9d
	jmp	9f
6:	cmpb	$91, %al
	jne	7f
	movl	$86, %r9d
	jmp	9f
7:	cmpb	$93, %al
	jne	8f
	movl	$87, %r9d
	jmp	9f
8:	cmpb	$44, %al
	jne	9f
	movl	$90, %r9d
9:	/* write next_lex */
	movq	%rdx, (%rcx)
	movl	%r10d, 8(%rcx)
	movl	%r11d, 12(%rcx)
	/* zero tok 48B */
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movq	$0, 32(%rcx)
	movq	$0, 40(%rcx)
	movq	$0, 48(%rcx)
	movq	$0, 56(%rcx)
	/* kind line col natural */
	movl	%r9d, 16(%rcx)
	movl	%r10d, 20(%rcx)
	movl	%r8d, 24(%rcx)
	/* token_start = pos-1 */
	movq	%rdx, %rax
	subq	$1, %rax
	movq	%rax, 64(%rcx)
	ret
