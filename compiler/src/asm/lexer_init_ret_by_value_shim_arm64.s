/* note743y.6.21g: tip Soft Cap parser passes out-ptr in x0; a ret-by-value
 * shim that returns 0 in x0 makes callers deref NULL → product L2 SEGV.
 * Write Track L {0,1,1} through out-ptr when x0!=0 and leave x0 unchanged
 * (Cap tip Soft Cap #0x80 identity). Null x0 → ret-by-value in x0/x1.
 * PLATFORM: MACOS arm64
 */
	.globl	_lexer_init
	.p2align	2
_lexer_init:
	cbz	x0, 1f
	str	xzr, [x0]
	mov	w9, #1
	str	w9, [x0, #8]
	str	w9, [x0, #12]
	ret
1:
	mov	x0, #0
	mov	x1, #0x100000001
	ret
