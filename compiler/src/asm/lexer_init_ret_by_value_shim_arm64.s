/* knife256 / 10.2: return-by-value lexer_init for Track L parser + tip lexer hybrid.
 * Apple ARM64: 16-byte struct in x0 (pos) + x1 (line | col<<32).
 * PLATFORM: MACOS arm64
 */
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	mov	x0, #0
	mov	x1, #0x100000001
	ret
