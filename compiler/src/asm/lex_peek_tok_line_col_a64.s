// knife256/10.2: peek line/col after skipping space/tab/cr/lf from cursor.
	.globl	_parser_asm_lex_peek_tok_line_c
	.globl	_parser_asm_lex_peek_tok_col_c
	.globl	_parser_asm_lex_skip_ws_line_col
	.p2align	2
_parser_asm_lex_peek_tok_line_c:
	stp	x29, x30, [sp, #-32]!
	stp	x19, x20, [sp, #16]
	cbz	x0, Lpeof
	cbz	x1, Lpeof
	mov	x19, x0
	mov	x20, x1
	ldr	x1, [x19]
	mov	x0, x20
	bl	_parser_asm_lex_skip_ws_line_col
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #32
	ret
Lpeof:
	mov	w0, #0
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #32
	ret
_parser_asm_lex_peek_tok_col_c:
	stp	x29, x30, [sp, #-32]!
	stp	x19, x20, [sp, #16]
	cbz	x0, Lpeof2
	cbz	x1, Lpeof2
	mov	x19, x0
	mov	x20, x1
	ldr	x1, [x19]
	mov	x0, x20
	bl	_parser_asm_lex_skip_ws_line_col
	mov	w0, w1
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #32
	ret
Lpeof2:
	mov	w0, #0
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #32
	ret
_parser_asm_lex_skip_ws_line_col:
	mov	w2, #1
	mov	w3, #1
	cbz	x0, Lsw7
	ldr	x4, [x0]
	ldr	x5, [x0, #8]
	cbz	x4, Lsw7
	mov	x6, #0
Lsw1:
	cmp	x6, x1
	b.hs	Lsw2
	cmp	x6, x5
	b.hs	Lsw2
	ldrb	w7, [x4, x6]
	add	x6, x6, #1
	cmp	w7, #10
	b.eq	Lsw1a
	add	w3, w3, #1
	b	Lsw1
Lsw1a:
	add	w2, w2, #1
	mov	w3, #1
	b	Lsw1
Lsw2:
Lsw3:
	cmp	x6, x5
	b.hs	Lsw6
	ldrb	w7, [x4, x6]
	cmp	w7, #32
	b.eq	Lsw4
	cmp	w7, #9
	b.eq	Lsw4
	cmp	w7, #13
	b.eq	Lsw4
	cmp	w7, #10
	b.eq	Lsw5
	b	Lsw6
Lsw4:
	add	x6, x6, #1
	add	w3, w3, #1
	b	Lsw3
Lsw5:
	add	x6, x6, #1
	add	w2, w2, #1
	mov	w3, #1
	b	Lsw3
Lsw6:
	mov	w0, w2
	mov	w1, w3
	ret
Lsw7:
	mov	w0, #1
	mov	w1, #1
	ret
