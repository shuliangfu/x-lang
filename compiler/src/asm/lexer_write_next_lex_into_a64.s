	.globl	_lexer_write_next_lex_into
	.p2align	2
_lexer_write_next_lex_into:
	cbz	x0, 1f
	str	x1, [x0]
	str	w2, [x0, #8]
	lsr	x3, x2, #32
	str	w3, [x0, #12]
1:	ret
