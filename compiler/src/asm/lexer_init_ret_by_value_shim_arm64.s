/* note743y.6.22 + dual-ABI:
 * Ret-by-value: Lexer in x0+x1. Out-ptr: &Lex in x0.
 * Store 16 bytes when out!=0 and out >= sp-128 (stack/red-zone). Skip
 * heap source pointers left in x0. PLATFORM: MACOS/LINUX arm64
 */
#if defined(__APPLE__)
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	mov	x2, x0
	mov	x0, #0
	mov	x1, #0x100000001
	cbz	x2, 1f
	mov	x3, sp
	sub	x3, x3, #128
	cmp	x2, x3
	b.lo	1f
	str	x0, [x2]
	str	x1, [x2, #8]
1:
	ret
#else
	.globl	lexer_init
	.p2align	2
lexer_init:
	mov	x2, x0
	mov	x0, #0
	mov	x1, #0x100000001
	cbz	x2, 1f
	mov	x3, sp
	sub	x3, x3, #128
	cmp	x2, x3
	b.lo	1f
	str	x0, [x2]
	str	x1, [x2, #8]
1:
	ret
#endif
