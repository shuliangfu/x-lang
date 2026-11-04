/* note743y.6.22 + dual-ABI (Linux twin):
 * Ret-by-value: Lexer in x0+x1. Out-ptr: &Lex in x0, caller reads *x0.
 * On entry save out ptr; return empty Lexer; if out!=0 also store 16 bytes.
 * PLATFORM: MACOS arm64
 */
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	mov	x2, x0
	mov	x0, #0
	mov	x1, #0x100000001
	cbz	x2, 1f
	str	x0, [x2]
	str	x1, [x2, #8]
1:
	ret
