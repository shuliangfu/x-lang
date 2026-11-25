/* knife256 / 10.2 + note743y.4 + note743y.5 + dual-ABI:
 * Ret-by-value: Lexer in rax+rdx. Out-ptr: &Lex in rdi, caller reads *rdi.
 * Always return empty Lexer in rax+rdx. If rdi looks like a stack out-ptr
 * (rdi >= rsp-128, covering the SysV red zone), also store 16 bytes to *rdi.
 * Skip heap/mmap source pointers left in rdi by ret-by-value callers
 * (parser_parse_into_buf) — storing there smashed the first 16 source bytes
 * → P001 / missing main. A strict rdi>=rsp guard skipped red-zone out-ptrs
 * and SEGV'd in lexer_next_body_into. PLATFORM: LINUX/MACOS x86_64
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
	jz	1f
	leaq	-128(%rsp), %rcx
	cmpq	%rcx, %rdi
	jb	1f
	movq	%rax, (%rdi)
	movq	%rdx, 8(%rdi)
1:
	ret
