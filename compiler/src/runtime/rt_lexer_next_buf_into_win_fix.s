/* Win tip-cold dual-ABI trampoline for lexer_next_buf_into.
 * Callers pass *Lexer (Type A bridge: rdx=r8=&Lex, r9=data, stack=len;
 * Type B parse_into: rdx=&Lex, r8=data, r9=len). Tip body wants by-value
 * Lex in rdx+r8 + data r9 + len stack. Convert then call demoted tip body
 * lexer_next_buf_into_tip (g05 objcopy redefine on lexer_x.o).
 *
 * Discriminant: rdx==r8 → Type A (both &Lex). Do NOT use r9>=0x10000 —
 * Type B len for large tip monofiles (e.g. backend_call_dispatch.x
 * 432162 bytes) exceeds 64KiB and was misclassified as Type A, feeding
 * the length as a data pointer into skip_whitespace (SEGV / EXIT139).
 * Frame 0x40 keeps 16-byte align after push (0x40≡0 mod 16).
 * PLATFORM: WINDOWS|X86_64. */
	.text
	.globl lexer_next_buf_into
	.def lexer_next_buf_into; .scl 2; .type 32; .endef
	.globl lexer_next_buf_into_tip
	.p2align 4
lexer_next_buf_into:
	pushq %rbp
	movq %rsp, %rbp
	subq $0x40, %rsp
	cmpq %r8, %rdx
	jne .Ltype_b
	/* Type A: rdx=r8=&Lex, r9=data, 0x30(%rbp)=len */
	movq %r9, %r10
	movslq 0x30(%rbp), %r11
	jmp .Lload
.Ltype_b:
	/* Type B: rdx=&Lex, r8=data, r9=len */
	movq %r8, %r10
	movslq %r9d, %r11
.Lload:
	movq 8(%rdx), %r8
	movq (%rdx), %rdx
	movq %r10, %r9
	movq %r11, 0x20(%rsp)
	call lexer_next_buf_into_tip
	addq $0x40, %rsp
	popq %rbp
	ret
