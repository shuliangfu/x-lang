/* note743y.6.22 + dual-ABI (Linux twin):
 * Ret-by-value: Lexer in x0+x1. Out-ptr: &Lex in x0, caller reads *x0.
 * On entry save out ptr; return empty Lexer; if out!=0 AND out looks like
 * a stack slot (out >= sp), also store 16 bytes. Skip heap/mmap source
 * pointers left in x0 by ret-by-value callers (source smash → P001).
 * PLATFORM: MACOS/LINUX arm64
 */
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	mov	x2, x0
	mov	x0, #0
	mov	x1, #0x100000001
	cbz	x2, 1f
	cmp	x2, sp
	b.lo	1f
	str	x0, [x2]
	str	x1, [x2, #8]
1:
	ret
