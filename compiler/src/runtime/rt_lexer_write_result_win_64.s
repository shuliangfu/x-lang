/* Win tip-cold: lexer_write_next_lex_into + lexer_write_tok_into.
 * Tip PE Win: write_next col@+0x10 wild; write_tok ignored rdx=*Token and used out+8.
 * Leaf: next rcx=out rdx=pos r8=linecol; tok rcx=out rdx=*Token memcpy(out+16,,48).
 * PLATFORM: WINDOWS|X86_64.
 */
	.text
	.globl lexer_write_next_lex_into
	.def lexer_write_next_lex_into; .scl 2; .type 32; .endef
	.globl write_next_lex_into
	.def write_next_lex_into; .scl 2; .type 32; .endef
	.globl lexer_write_tok_into
	.def lexer_write_tok_into; .scl 2; .type 32; .endef
	.globl write_tok_into
	.def write_tok_into; .scl 2; .type 32; .endef
	.globl memcpy
	.p2align 4
lexer_write_next_lex_into:
write_next_lex_into:
	movq	%rdx, (%rcx)
	movl	%r8d, 8(%rcx)
	movq	%r8, %rax
	shrq	$32, %rax
	movl	%eax, 12(%rcx)
	movq	$0, 64(%rcx)
	ret
	.p2align 4
lexer_write_tok_into:
write_tok_into:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0x20, %rsp
	leaq	16(%rcx), %rcx
	movl	$48, %r8d
	call	memcpy
	addq	$0x20, %rsp
	popq	%rbp
	ret
