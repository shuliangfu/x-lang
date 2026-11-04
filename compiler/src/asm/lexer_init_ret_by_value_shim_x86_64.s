/* knife256 / 10.2 + note743y.4 + note743y.5 + dual-ABI:
 * - Ret-by-value callers (parser_parse archaeology): expect Lexer in rax+rdx.
 * - Out-ptr callers (pipeline_source_slice tip peel): pass &Lex in rdi and
 *   read the stack slot after the call (ignore rax).
 * Tip out-ptr-only init smashed rdi==source; nop ret-only left out-ptr
 * slots uninit. Dual: always return empty Lexer in rax+rdx; if rdi!=0
 * also memcpy 16 bytes to *rdi. PLATFORM: LINUX/MACOS x86_64
 */
#if defined(__APPLE__)
	.globl	_lexer_init
_lexer_init:
#else
	.globl	lexer_init
lexer_init:
#endif
	/* empty Lexer: pos=0 (rax), line=1|col=1 packed in rdx low 32+32 */
	xorq	%rax, %rax
	movq	$0x100000001, %rdx
	testq	%rdi, %rdi
	jz	1f
	movq	%rax, (%rdi)
	movq	%rdx, 8(%rdi)
1:
	ret
