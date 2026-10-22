/* note743y.6.22: return-by-value only (twin note743y.4 Linux). Track L
 * parser expects Lexer in x0+x1; out-ptr write smashes source → no _main.
 * tip Soft Cap out-ptr face stays demoted. PLATFORM: MACOS arm64
 */
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	mov	x0, #0
	mov	x1, #0x100000001
	ret
