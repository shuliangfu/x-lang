// knife256/10.2: recount line/col from source[0..pos].
// Cap tip leaves lex.line as pointer-sized garbage; diagnostics need
// path:line:col. source is *Slice { data:*u8 @0, len:usize @8 }.
	.globl	_parser_asm_lex_recount_line_col
	.p2align	2
// out: w0=line, w1=col. args: x0=source_slice_hdr, x1=pos
_parser_asm_lex_recount_line_col:
	mov	w2, #1              // line
	mov	w3, #1              // col
	cbz	x0, 9f
	ldr	x4, [x0]            // data
	ldr	x5, [x0, #8]        // len
	cbz	x4, 9f
	mov	x6, #0              // i
1:
	cmp	x6, x1
	b.hs	8f
	cmp	x6, x5
	b.hs	8f
	ldrb	w7, [x4, x6]
	add	x6, x6, #1
	cmp	w7, #10             // '\n'
	b.eq	2f
	add	w3, w3, #1
	b	1b
2:
	add	w2, w2, #1
	mov	w3, #1
	b	1b
8:
	mov	w0, w2
	mov	w1, w3
	ret
9:
	mov	w0, #1
	mov	w1, #1
	ret
