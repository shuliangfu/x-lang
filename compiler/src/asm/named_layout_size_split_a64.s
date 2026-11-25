/* Cap tip soft: Split_*→32; Result_i32/u8 + Option_u64→16. Not Option_i32 (8B). */
	.section __TEXT,__cstring,cstring_literals
_nl_split_i32:	.asciz	"Split_i32"
_nl_split_u8:	.asciz	"Split_u8"
_nl_split_u64:	.asciz	"Split_u64"
_nl_result_i32:	.asciz	"Result_i32"
_nl_result_u8:	.asciz	"Result_u8"
_nl_option_u64:	.asciz	"Option_u64"

	.section __TEXT,__text,regular,pure_instructions
	.globl	_glue_type_named_layout_size_any_module_elf_c
	.p2align	2
_glue_type_named_layout_size_any_module_elf_c:
	stp	x29, x30, [sp, #-64]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	str	x21, [sp, #32]
	mov	x19, x0
	mov	w20, w1
	cbz	x19, 9f
	cmp	w20, #1
	b.lt	9f
	mov	x0, x19
	mov	w1, w20
	bl	_pipeline_type_kind_ord_at
	cmp	w0, #8
	b.ne	8f
	add	x21, sp, #40
	mov	x0, x19
	mov	w1, w20
	mov	x2, x21
	bl	_pipeline_type_named_name_into
	mov	w2, w0
	mov	x1, x21
	mov	w3, wzr
	mov	w4, wzr
60:	cmp	w4, w2
	b.ge	61f
	ldrb	w5, [x1, w4, uxtw]
	cmp	w5, #46
	b.ne	62f
	add	w3, w4, #1
62:	add	w4, w4, #1
	b	60b
61:	sub	w2, w2, w3
	add	x1, x21, w3, uxtw
	cmp	w2, #9
	b.ne	1f
	adrp	x0, _nl_split_i32@PAGE
	add	x0, x0, _nl_split_i32@PAGEOFF
	mov	x6, x1
	mov	w3, #9
2:	ldrb	w4, [x0], #1
	ldrb	w5, [x6], #1
	cmp	w4, w5
	b.ne	1f
	subs	w3, w3, #1
	b.ne	2b
	mov	w0, #32
	b	10f
1:	cmp	w2, #9
	b.ne	3f
	adrp	x0, _nl_split_u64@PAGE
	add	x0, x0, _nl_split_u64@PAGEOFF
	mov	x6, x1
	mov	w3, #9
4:	ldrb	w4, [x0], #1
	ldrb	w5, [x6], #1
	cmp	w4, w5
	b.ne	3f
	subs	w3, w3, #1
	b.ne	4b
	mov	w0, #32
	b	10f
3:	cmp	w2, #8
	b.ne	20f
	adrp	x0, _nl_split_u8@PAGE
	add	x0, x0, _nl_split_u8@PAGEOFF
	mov	x6, x1
	mov	w3, #8
5:	ldrb	w4, [x0], #1
	ldrb	w5, [x6], #1
	cmp	w4, w5
	b.ne	20f
	subs	w3, w3, #1
	b.ne	5b
	mov	w0, #32
	b	10f
20:	cmp	w2, #10
	b.ne	21f
	adrp	x0, _nl_result_i32@PAGE
	add	x0, x0, _nl_result_i32@PAGEOFF
	mov	x6, x1
	mov	w3, #10
22:	ldrb	w4, [x0], #1
	ldrb	w5, [x6], #1
	cmp	w4, w5
	b.ne	25f
	subs	w3, w3, #1
	b.ne	22b
	mov	w0, #16
	b	10f
25:	adrp	x0, _nl_option_u64@PAGE
	add	x0, x0, _nl_option_u64@PAGEOFF
	mov	x6, x1
	mov	w3, #10
26:	ldrb	w4, [x0], #1
	ldrb	w5, [x6], #1
	cmp	w4, w5
	b.ne	21f
	subs	w3, w3, #1
	b.ne	26b
	mov	w0, #16
	b	10f
21:	cmp	w2, #9
	b.ne	8f
	adrp	x0, _nl_result_u8@PAGE
	add	x0, x0, _nl_result_u8@PAGEOFF
	mov	x6, x1
	mov	w3, #9
27:	ldrb	w4, [x0], #1
	ldrb	w5, [x6], #1
	cmp	w4, w5
	b.ne	8f
	subs	w3, w3, #1
	b.ne	27b
	mov	w0, #16
	b	10f
8:	mov	x0, x19
	mov	w1, w20
	bl	_glue_type_named_layout_size_any_module_elf_c__demoted
	b	10f
9:	mov	w0, #0
10:	ldr	x21, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #64
	ret
