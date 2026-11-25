/* Win tip-cold dual-ABI trampoline for lexer_next_buf_into.
 * Callers pass *Lexer (Type A bridge: rdx=r8=&Lex, r9=data, stack=len;
 * Type B parse_into: rdx=&Lex, r8=data, r9=len).
 *
 * The tip body in the product image (and any Win64 lowering of a 16-byte
 * Lexer) uses pointer ABI: it loads lex.pos / line|col from (%rdx) and
 * 8(%rdx), takes data in r8 and i32 len in r9. An earlier revision of
 * this trampoline peeled *Lexer into by-value (rdx=pos, r8=line|col,
 * r9=data, len on the stack) for a g05/host-cc tip. That peel feeds
 * pos=0 (or a small source offset) to a pointer-ABI tip as if it were
 * &Lex, which SEGV at the first load, and leaves the real source pointer
 * in r9 where the tip sign-extends it as len. r8=0x100000001 after the
 * old peel is line=1,col=1 packed, not a length.
 *
 * Discriminant: rdx==r8 → Type A (both &Lex). Do NOT use r9>=0x10000 —
 * Type B len for large tip monofiles (e.g. backend_call_dispatch.x
 * 432162 bytes) exceeds 64KiB and was misclassified as Type A, feeding
 * the length as a data pointer into skip_whitespace (SEGV / EXIT139).
 * Frame 0x40 keeps 16-byte align after push (0x40≡0 mod 16) and keeps
 * the Type A 5th arg at 0x30(%rbp).
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
	/* Type A: rdx=r8=&Lex, r9=data, 0x30(%rbp)=len.
	 * Forward pointer ABI: rdx stays &Lex, r8=data, r9=len. */
	movq %r9, %r8
	movslq 0x30(%rbp), %r9
.Ltype_b:
	/* Type B: already rdx=&Lex, r8=data, r9=len. */
	call lexer_next_buf_into_tip
	addq $0x40, %rsp
	popq %rbp
	ret
