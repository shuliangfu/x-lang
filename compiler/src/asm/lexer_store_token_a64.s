	.globl	_lexer_store_token
	.p2align	2
_lexer_store_token:
	cbz	x0, 2f
	cbz	x1, 2f
	mov	x2, #48
1:
	ldrb	w3, [x1], #1
	strb	w3, [x0], #1
	subs	x2, x2, #1
	b.ne	1b
2:	ret
