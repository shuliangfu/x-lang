/* note743y.6.22 + dual-ABI:
 * Ret-by-value: Lexer in x0+x1. Out-ptr: &Lex in x0, caller reads *x0.
 * Store 16 bytes to *out unless out==0 or out==parked g_lex_src_data.
 * PLATFORM: MACOS/LINUX arm64
 */
#if defined(__APPLE__)
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	mov	x2, x0
	mov	x0, #0
	mov	x1, #0x100000001
	cbz	x2, 1f
	adrp	x3, _g_lex_src_data@PAGE
	ldr	x3, [x3, _g_lex_src_data@PAGEOFF]
	cmp	x2, x3
	b.eq	1f
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
	adrp	x3, g_lex_src_data@PAGE
	ldr	x3, [x3, g_lex_src_data@PAGEOFF]
	cmp	x2, x3
	b.eq	1f
	str	x0, [x2]
	str	x1, [x2, #8]
1:
	ret
#endif
