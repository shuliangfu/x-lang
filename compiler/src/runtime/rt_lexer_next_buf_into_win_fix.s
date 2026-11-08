/* Win tip-cold dual-ABI trampoline for lexer_next_buf_into.
 * Type A (bridge): rdx=r8=&Lex, r9=data, 0x30(%rbp)=len
 * Type B (parse_into): rdx=&Lex, r8=data, r9=len
 * Tip wants by-value Lex in rdx+r8 + data r9 + len stack for body_into path;
 * we instead call lexer_next_into(out, lex_val, &slice_fat).
 * PLATFORM: WINDOWS|X86_64. */
	.text
	.globl lexer_next_buf_into
	.def lexer_next_buf_into; .scl 2; .type 32; .endef
	.p2align 4
lexer_next_buf_into:
	pushq %rbp
	movq %rsp, %rbp
	subq $0x68, %rsp                 /* keep 16-byte align after push */
	movq %rcx, -0x08(%rbp)           /* out */
	cmpq $0x10000, %r9
	jb .Ltype_b
	/* Type A */
	movq %rdx, -0x10(%rbp)           /* &lex */
	movq %r9, -0x18(%rbp)            /* data */
	movslq 0x30(%rbp), %rax          /* len */
	movq %rax, -0x20(%rbp)
	jmp .Lpark
.Ltype_b:
	movq %rdx, -0x10(%rbp)
	movq %r8, -0x18(%rbp)
	movslq %r9d, %rax
	movq %rax, -0x20(%rbp)
.Lpark:
	movq $0, -0x28(%rbp)             /* sp */
	movq $0, -0x30(%rbp)             /* slen */
	leaq -0x28(%rbp), %rcx
	call lexer_src_data_store
	leaq -0x30(%rbp), %rcx
	call lexer_src_len_store
	cmpq $0, -0x28(%rbp)
	je .Lclamp
	movq -0x28(%rbp), %rax
	movq %rax, -0x18(%rbp)
	movq -0x30(%rbp), %rax
	movq %rax, -0x20(%rbp)
.Lclamp:
	cmpq $0, -0x20(%rbp)
	jge .Lmkslice
	movq $0, -0x20(%rbp)
.Lmkslice:
	movq -0x18(%rbp), %rax
	movq %rax, -0x40(%rbp)
	movq -0x20(%rbp), %rax
	movq %rax, -0x38(%rbp)
	/* *lex → rdx/r8 by value */
	movq -0x10(%rbp), %rax
	movq (%rax), %rdx
	movq 8(%rax), %r8
	movq -0x08(%rbp), %rcx
	leaq -0x40(%rbp), %r9
	subq $0x20, %rsp
	call lexer_next_into
	addq $0x20, %rsp
	addq $0x68, %rsp
	popq %rbp
	ret
