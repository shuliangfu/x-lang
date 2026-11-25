/* Cap tip diag_report* overlay (knife256/10.2).
 * Cap tip diag.o report/human/with_code/print_header X-codegen-clobber → SEGV.
 * Write via asm_diag_stderr_write. Demote Cap tip T; this .o first-wins.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions

	.globl _diag_report_with_code
	.p2align 2
_diag_report_with_code:
	b	_diag_report_human

	/* diag_report(file,line,col,kind,msg,detail) → human(..., code=0, ...) */
	.globl _diag_report
	.p2align 2
_diag_report:
	mov	x6, x5
	mov	x5, x4
	mov	x4, xzr
	b	_diag_report_human

	.globl _diag_report_human
	.p2align 2
_diag_report_human:
	stp	x29, x30, [sp, #-0x80]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	stp	x25, x26, [sp, #0x40]
	mov	x19, x0
	mov	w20, w1
	mov	w21, w2
	mov	x22, x3
	mov	x23, x4
	mov	x24, x5
	cbz	x24, Ldone
	/* kind may be null: driver_diag_report_prefixed embeds kind in msg */
	cbz	x22, Lmsg
	mov	x0, x22
	bl	Lputs
	cbz	x23, Lno_code
	adrp	x0, Lbrack@PAGE
	add	x0, x0, Lbrack@PAGEOFF
	bl	Lputs
	mov	x0, x23
	bl	Lputs
	adrp	x0, Lrbrack@PAGE
	add	x0, x0, Lrbrack@PAGEOFF
	bl	Lputs
	adrp	x0, Lcolon_sp@PAGE
	add	x0, x0, Lcolon_sp@PAGEOFF
	bl	Lputs
	b	Lmsg
Lno_code:
	adrp	x0, Lcolon_sp@PAGE
	add	x0, x0, Lcolon_sp@PAGEOFF
	bl	Lputs
Lmsg:
	mov	x0, x24
	bl	Lputs
	adrp	x0, Lnl@PAGE
	add	x0, x0, Lnl@PAGEOFF
	bl	Lputs
	/* Null file still prints " --> line:col" when line>0 or col>0.
	 * Do not call diag_ctx_get_file (Cap tip SEGV). A null file with
	 * both halves <= 0 stays header-only. Same bytes as
	 * diag_io_fprint_loc_line_col. PLATFORM: MACOS|ARM64. */
	cbnz	x19, Lloc_file
	cmp	w20, #0
	b.gt	Lloc_nums
	cmp	w21, #0
	b.le	Ldone
Lloc_nums:
	adrp	x0, Larrow@PAGE
	add	x0, x0, Larrow@PAGEOFF
	bl	Lputs
	mov	w0, w20
	bl	Lput_i32
	adrp	x0, Lcolonly@PAGE
	add	x0, x0, Lcolonly@PAGEOFF
	bl	Lputs
	mov	w0, w21
	bl	Lput_i32
	adrp	x0, Lnl@PAGE
	add	x0, x0, Lnl@PAGEOFF
	bl	Lputs
	b	Ldone
Lloc_file:
	adrp	x0, Larrow@PAGE
	add	x0, x0, Larrow@PAGEOFF
	bl	Lputs
	mov	x0, x19
	bl	Lputs
	adrp	x0, Lcolonly@PAGE
	add	x0, x0, Lcolonly@PAGEOFF
	bl	Lputs
	mov	w0, w20
	bl	Lput_i32
	adrp	x0, Lcolonly@PAGE
	add	x0, x0, Lcolonly@PAGEOFF
	bl	Lputs
	mov	w0, w21
	bl	Lput_i32
	adrp	x0, Lnl@PAGE
	add	x0, x0, Lnl@PAGEOFF
	bl	Lputs
Ldone:
	ldp	x25, x26, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x80
	ret

	.p2align 2
Lputs:
	stp	x29, x30, [sp, #-0x20]!
	stp	x19, x20, [sp, #0x10]
	mov	x19, x0
	cbz	x19, Lputs_done
	bl	_strlen
	mov	w1, w0
	cbz	w1, Lputs_done
	mov	x0, x19
	bl	_asm_diag_stderr_write
Lputs_done:
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x20
	ret

	.p2align 2
Lput_i32:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	add	x19, sp, #0x20
	mov	w20, w0
	cmp	w20, #0
	b.ge	Lput_nonneg
	neg	w20, w20
	adrp	x0, Lminus@PAGE
	add	x0, x0, Lminus@PAGEOFF
	bl	Lputs
Lput_nonneg:
	mov	w1, w20
	cbnz	w1, Lput_digits
	mov	w0, #'0'
	strb	w0, [x19, #-1]!
	b	Lput_emit
Lput_digits:
	mov	w2, #10
Lput_loop:
	udiv	w3, w1, w2
	msub	w4, w3, w2, w1
	add	w4, w4, #'0'
	strb	w4, [x19, #-1]!
	mov	w1, w3
	cbnz	w1, Lput_loop
Lput_emit:
	mov	x0, x19
	add	x1, sp, #0x20
	sub	x1, x1, x19
	mov	w1, w1
	bl	_asm_diag_stderr_write
	ldp	x29, x30, [sp], #0x30
	ret

	.section __TEXT,__cstring,cstring_literals
Lbrack:		.asciz "["
Lrbrack:	.asciz "]"
Lcolon_sp:	.asciz ": "
Lnl:		.asciz "\n"
Larrow:		.asciz " --> "
Lcolonly:	.asciz ":"
Lminus:		.asciz "-"
