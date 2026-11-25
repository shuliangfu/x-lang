/* Hand-asm core/slice/slice.o — Cap tip/LEGACY .x emit hollow. PLATFORM: MACOS|ARM64 leaf. */
	.section __TEXT,__text,regular,pure_instructions

	.globl	_runtime_slice_glue_x_doc_anchor
	.p2align	2
_runtime_slice_glue_x_doc_anchor:
	mov	w0, #0
	ret

	.globl	_slice_glue_clamp_len
	.p2align	2
_slice_glue_clamp_len:
	cmp	x1, x0
	b.hs	1f
	sub	x3, x0, x1
	cmp	x2, x3
	csel	x0, x3, x2, hi
	ret
1:	mov	x0, #0
	ret

	.globl	_core_slice_i32_from_ptr_c
	.p2align	2
_core_slice_i32_from_ptr_c:
	str	x1, [x0]
	str	x2, [x0, #8]
	ret

	.globl	_core_slice_u8_from_ptr_c
	.p2align	2
_core_slice_u8_from_ptr_c:
	str	x1, [x0]
	str	x2, [x0, #8]
	ret

	.globl	_core_slice_u64_from_ptr_c
	.p2align	2
_core_slice_u64_from_ptr_c:
	str	x1, [x0]
	str	x2, [x0, #8]
	ret

/* out=x0 data=x1 total=x2 start=x3 len=x4 */
	.globl	_core_subslice_i32_c
	.p2align	2
_core_subslice_i32_c:
	stp	x29, x30, [sp, #-48]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	stp	x21, x22, [sp, #32]
	mov	x19, x0
	mov	x20, x1
	mov	x21, x2
	mov	x22, x3
	mov	x0, x2
	mov	x1, x3
	mov	x2, x4
	bl	_slice_glue_clamp_len
	mov	x4, x0
	mov	x3, x22
	cmp	x3, x21
	csel	x3, xzr, x3, hs
	add	x1, x20, x3, lsl #2
	str	x1, [x19]
	str	x4, [x19, #8]
	ldp	x21, x22, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #48
	ret

	.globl	_core_subslice_u8_c
	.p2align	2
_core_subslice_u8_c:
	stp	x29, x30, [sp, #-48]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	stp	x21, x22, [sp, #32]
	mov	x19, x0
	mov	x20, x1
	mov	x21, x2
	mov	x22, x3
	mov	x0, x2
	mov	x1, x3
	mov	x2, x4
	bl	_slice_glue_clamp_len
	mov	x4, x0
	mov	x3, x22
	cmp	x3, x21
	csel	x3, xzr, x3, hs
	add	x1, x20, x3
	str	x1, [x19]
	str	x4, [x19, #8]
	ldp	x21, x22, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #48
	ret

	.globl	_core_subslice_u64_c
	.p2align	2
_core_subslice_u64_c:
	stp	x29, x30, [sp, #-48]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	stp	x21, x22, [sp, #32]
	mov	x19, x0
	mov	x20, x1
	mov	x21, x2
	mov	x22, x3
	mov	x0, x2
	mov	x1, x3
	mov	x2, x4
	bl	_slice_glue_clamp_len
	mov	x4, x0
	mov	x3, x22
	cmp	x3, x21
	csel	x3, xzr, x3, hs
	add	x1, x20, x3, lsl #3
	str	x1, [x19]
	str	x4, [x19, #8]
	ldp	x21, x22, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #48
	ret
