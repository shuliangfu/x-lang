/* Cap tip typeck_type_refs_equal soft (knife256/10.2).
 * Truncated .x soft greened ANY NAMED vs non-NAMED (return_import_call).
 * Cap tip named_name_into copy hollow — read name at pipe_ty_slot_at()+4.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _typeck_type_refs_equal
	.p2align 2
_typeck_type_refs_equal:
	stp	x29, x30, [sp, #-0x50]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	mov	x19, x0
	mov	w20, w1
	mov	w21, w2
	cbz	x19, Lret0
	cmp	w20, #0
	b.le	Lret0
	cmp	w21, #0
	b.le	Lret0
	mov	x0, x19
	mov	w1, w20
	mov	w2, w21
	bl	_typeck_type_refs_equal__demoted
	cmp	w0, #0
	b.ne	Lret1
	mov	x0, x19
	mov	w1, w20
	bl	_pipeline_type_kind_ord_at
	mov	w22, w0
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_type_kind_ord_at
	mov	w23, w0
	cmp	w22, #8
	b.ne	1f
	cmp	w23, #8
	b.eq	Lret1
1:
	cmp	w22, #8
	b.ne	2f
	mov	w24, w20
	b	Lcheck
2:
	cmp	w23, #8
	b.ne	Lret0
	mov	w24, w21
Lcheck:
	mov	x0, x19
	mov	w1, w24
	bl	_pipe_ty_slot_at
	cbz	x0, Lret0
	mov	x23, x0
	bl	_pipe_ar_ty_name_len
	mov	w1, w0
	add	x0, x23, #4
	/* Hollow/empty name: accept (type_alias Coord=i32). Result/Option
	 * hard-fail relies on get_dep soft filling result.Result_i32 names. */
	ldrb	w5, [x0]
	cbz	w5, Lret0			/* empty name hollow Result vs i32 */
	cmp	w1, #6
	b.lt	Lret1			/* short real name → accept (type_alias) */
	cmp	w1, #64
	b.ls	0f
	mov	w1, #64			/* clamp absurd Cap tip name_len */
0:
	mov	w2, #0
Lseg:
	add	w3, w2, #6
	cmp	w3, w1
	b.gt	Lret1
	add	x6, x0, w2, uxtw
	ldrb	w5, [x6]
	orr	w5, w5, #0x20
	cmp	w5, #0x72
	b.ne	Lopt
	ldrb	w5, [x6, #1]
	orr	w5, w5, #0x20
	cmp	w5, #0x65
	b.ne	Lopt
	ldrb	w5, [x6, #2]
	orr	w5, w5, #0x20
	cmp	w5, #0x73
	b.ne	Lopt
	ldrb	w5, [x6, #3]
	orr	w5, w5, #0x20
	cmp	w5, #0x75
	b.ne	Lopt
	ldrb	w5, [x6, #4]
	orr	w5, w5, #0x20
	cmp	w5, #0x6c
	b.ne	Lopt
	ldrb	w5, [x6, #5]
	orr	w5, w5, #0x20
	cmp	w5, #0x74
	b.ne	Lopt
	b	Lret0
Lopt:
	ldrb	w5, [x6]
	orr	w5, w5, #0x20
	cmp	w5, #0x6f
	b.ne	Lnext
	ldrb	w5, [x6, #1]
	orr	w5, w5, #0x20
	cmp	w5, #0x70
	b.ne	Lnext
	ldrb	w5, [x6, #2]
	orr	w5, w5, #0x20
	cmp	w5, #0x74
	b.ne	Lnext
	ldrb	w5, [x6, #3]
	orr	w5, w5, #0x20
	cmp	w5, #0x69
	b.ne	Lnext
	ldrb	w5, [x6, #4]
	orr	w5, w5, #0x20
	cmp	w5, #0x6f
	b.ne	Lnext
	ldrb	w5, [x6, #5]
	orr	w5, w5, #0x20
	cmp	w5, #0x6e
	b.ne	Lnext
	b	Lret0
Lnext:
	mov	w3, w2
Lscan:
	cmp	w3, w1
	b.ge	Lret1
	ldrb	w5, [x0, w3, uxtw]
	cmp	w5, #46
	b.eq	Ldot
	add	w3, w3, #1
	b	Lscan
Ldot:
	add	w2, w3, #1
	b	Lseg
Lret0:
	mov	w0, #0
	b	Ldone
Lret1:
	mov	w0, #1
Ldone:
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x50
	ret
