/* Cap tip INDEX-only assign (knife256/10.2). Non-INDEX: return 0, no side calls.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _pipeline_asm_emit_assign_elf_c
	.p2align 2
_pipeline_asm_emit_assign_elf_c:
	stp	x29, x30, [sp, #-0x50]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	str	x25, [sp, #0x40]
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	x22, x3
	mov	w23, w4
	cbz	x19, Lfail
	cbz	x20, Lfail
	cbz	x22, Lfail
	cmp	w21, #0
	b.le	Lfail
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_expr_binop_left_ref_at
	mov	w24, w0
	cmp	w24, #0
	b.le	Lfail
	mov	x0, x19
	mov	w1, w24
	bl	_pipeline_expr_kind_ord_at
	cmp	w0, #47
	b.ne	Lnoop
	/* INDEX only: peel right and emit */
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_expr_binop_right_ref_at
	mov	w25, w0
	cmp	w25, #0
	b.le	Lfail
	mov	x0, x19
	mov	w1, w25
	bl	_glue_peel_as_array_slice_ascription_c
	mov	w25, w0
	cmp	w25, #0
	b.le	Lfail
	mov	x0, x19
	mov	x1, x20
	mov	w2, w21
	mov	w3, w24
	mov	w4, w25
	mov	x5, x22
	mov	w6, w23
	bl	_glue_emit_assign_index_elf_c
	b	Lret
Lnoop:
	mov	w0, #0
	b	Lret
Lfail:
	mov	w0, #-1
Lret:
	ldr	x25, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x50
	ret
