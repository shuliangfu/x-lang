/* knife256 / 10.2: return-by-value lexer_init for Track L parser + tip lexer hybrid.
 * SysV x86_64: 16-byte struct in rax (pos) + rdx (line | col<<32).
 * PLATFORM: LINUX/MACOS x86_64
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
	ret
