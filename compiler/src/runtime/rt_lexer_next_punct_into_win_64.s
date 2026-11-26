/* Win tip-cold: lexer_next_punct_into dig_min puncts, natural Token layout.
 *
 * Soft Cap s241 (PLATFORM: WINDOWS|X86_64): tipU lexer_next_body_into calls
 * with POINTER ABI — rcx=out *LexerResult, rdx=*Lexer {pos@0,line@8,col@12},
 * r8=*Fat (ignored), r9=c. Older Soft Cap expected by-value (rdx=pos,
 * r8=line|col<<32, r9=*Fat, c on stack); tipU &Lexer was read as pos →
 * huge offset / memmove hang after export path reached `{`.
 *
 * Writes next_lex@0, tok@16 (kind@0 line@4 col@8 of product Token),
 * token_start@64. tipU peek_kind reads kind at +0x10 of the result buffer
 * (= tok.kind).
 */
	.text
	.globl lexer_next_punct_into
	.def lexer_next_punct_into; .scl 2; .type 32; .endef

	.p2align 4
lexer_next_punct_into:
	/* Load Lexer fields from *rdx (tipU pointer ABI). */
	movq	(%rdx), %rax			/* pos */
	movl	8(%rdx), %r10d			/* line */
	movl	12(%rdx), %r11d			/* col */
	movzbl	%r9b, %r9d			/* c (already in r9) */
	/* token col0 = current col; then advance pos/col */
	movl	%r11d, %r8d			/* col0 */
	addq	$1, %rax			/* pos++ */
	addl	$1, %r11d			/* col++ */
	/* map c -> kind (keep c in dl; kind in r9d) */
	movl	%r9d, %edx			/* c in edx */
	movl	$0, %r9d
	cmpb	$40, %dl
	jne	.Lp1
	movl	$82, %r9d
	jmp	.Lpdone
.Lp1:	cmpb	$41, %dl
	jne	.Lp2
	movl	$83, %r9d
	jmp	.Lpdone
.Lp2:	cmpb	$123, %dl
	jne	.Lp3
	movl	$84, %r9d
	jmp	.Lpdone
.Lp3:	cmpb	$125, %dl
	jne	.Lp4
	movl	$85, %r9d
	jmp	.Lpdone
.Lp4:	cmpb	$58, %dl
	jne	.Lp5
	movl	$91, %r9d
	jmp	.Lpdone
.Lp5:	cmpb	$59, %dl
	jne	.Lp6
	movl	$95, %r9d
	jmp	.Lpdone
.Lp6:	cmpb	$91, %dl
	jne	.Lp7
	movl	$86, %r9d
	jmp	.Lpdone
.Lp7:	cmpb	$93, %dl
	jne	.Lp8
	movl	$87, %r9d
	jmp	.Lpdone
.Lp8:	cmpb	$44, %dl
	jne	.Lp8a
	movl	$90, %r9d
	jmp	.Lpdone
.Lp8a:	cmpb	$61, %dl
	jne	.Lp8b
	movl	$117, %r9d
	jmp	.Lpdone
.Lp8b:	cmpb	$46, %dl
	jne	.Lp8c
	movl	$92, %r9d
	jmp	.Lpdone
.Lp8c:	cmpb	$42, %dl
	jne	.Lpdone
	movl	$98, %r9d
.Lpdone:
	/* write next_lex: pos in rax, line r10d, col r11d */
	movq	%rax, (%rcx)
	movl	%r10d, 8(%rcx)
	movl	%r11d, 12(%rcx)
	/* zero tok 48B */
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movq	$0, 32(%rcx)
	movq	$0, 40(%rcx)
	movq	$0, 48(%rcx)
	movq	$0, 56(%rcx)
	/* kind line col natural at tok@16 */
	movl	%r9d, 16(%rcx)
	movl	%r10d, 20(%rcx)
	movl	%r8d, 24(%rcx)
	/* token_start = pos-1 */
	subq	$1, %rax
	movq	%rax, 64(%rcx)
	ret
