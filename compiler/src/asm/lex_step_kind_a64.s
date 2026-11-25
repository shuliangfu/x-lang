	.globl	_parser_asm_lex_step_kind_c
	.p2align	2
_parser_asm_lex_step_kind_c:
	sub	sp, sp, #0xd0
	stp	x29, x30, [sp]
	mov	x29, sp
	stp	x19, x20, [sp, #0xa0]
	str	x21, [sp, #0xb0]
	cbz	x0, Lsk0
	cbz	x1, Lsk0
	mov	x19, x0
	mov	x20, x1
	ldr	x21, [x19]         // start pos
	// line/col at token start (skip ws from start)
	mov	x0, x20
	mov	x1, x21
	bl	_parser_asm_lex_skip_ws_line_col
	// save start line/col on stack
	str	w0, [sp, #0xb8]
	str	w1, [sp, #0xbc]
	add	x0, x29, #0x20
	ldr	x2, [x19]
	ldr	x3, [x19, #8]
	mov	x1, x2
	mov	x2, x3
	mov	x3, x20
	bl	_lexer_next_into
	ldr	x1, [x29, #0x20]
	str	x1, [x19]
	// cursor line/col at new pos
	mov	x0, x20
	bl	_parser_asm_lex_recount_line_col
	str	w0, [x19, #8]
	str	w1, [x19, #12]
	// patch result next_lex.line/col and tok.line/col with START coords
	ldp	w2, w3, [sp, #0xb8]
	str	w2, [x29, #0x28]   // next_lex.line @8 — actually keep cursor? 
	// For consumers of last tok: tok.line@20 col@24 = start
	str	w2, [x29, #0x34]   // tok.line @20 = 0x20+20=0x34
	str	w3, [x29, #0x38]   // tok.col @24
	// also fix next_lex.line in result to start? Prefer cursor for next_lex:
	// leave next_lex line as cursor already in lex; result next_lex for write_next consumers
	str	w0, [x29, #0x28]
	str	w1, [x29, #0x2c]
	ldrsw	x0, [x29, #0x30]
	b	Lsk1
Lsk0:
	mov	w0, #0
Lsk1:
	ldr	x21, [sp, #0xb0]
	ldp	x19, x20, [sp, #0xa0]
	ldp	x29, x30, [sp]
	add	sp, sp, #0xd0
	ret
