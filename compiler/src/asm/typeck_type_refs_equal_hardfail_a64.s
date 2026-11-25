/* Cap tip typeck_type_refs_equal soft (knife256/10.2 LANG-004).
 * Both CONCRETE TYPE_NAMED return demoted (last-segment / mangle). Blank-accept
 * made Set_i32 ≡ Set_u64, so the first same-arity *Struct overload always won
 * and the struct-pointer check then rejected the stamped callee.
 * One free type-param XOR the other: name length 1..2 rejects (struct A / B).
 * Longer concrete names on that one-free path, and both-free, stay blank-equal
 * (free T vs Result_i32 / Option_i32 / StrView).
 * pipe_ar_ty_name_len may be storage width; use strlen(slot+4).
 * PLATFORM: MACOS|ARM64 Cap tip. Contract is SHARED named equality. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _typeck_type_refs_equal
	.p2align 2
_typeck_type_refs_equal:
	stp	x29, x30, [sp, #-0x60]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	stp	x25, x26, [sp, #0x40]
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
	bl	_pipeline_type_kind_ord_at
	mov	w22, w0
	mov	x0, x19
	mov	w1, w21
	bl	_pipeline_type_kind_ord_at
	mov	w23, w0
	cmp	w22, #8
	b.ne	Lnot_both
	cmp	w23, #8
	b.ne	Lnot_both
	bl	_pipeline_typeck_active_module_c
	cbz	x0, Lblank
	mov	x22, x0
	mov	x0, x22
	mov	x1, x19
	mov	w2, w20
	bl	_typeck_type_is_free_type_param
	mov	w23, w0
	mov	x0, x22
	mov	x1, x19
	mov	w2, w21
	bl	_typeck_type_is_free_type_param
	mov	w24, w0
	eor	w25, w23, w24
	cbz	w25, Lboth_class
	/* non-free side */
	cmp	w23, #0
	b.eq	1f
	mov	w26, w21
	b	2f
1:
	mov	w26, w20
2:
	mov	x0, x19
	mov	w1, w26
	bl	_pipe_ty_slot_at
	cbz	x0, Lblank
	add	x0, x0, #4
	mov	w1, #0
3:
	cmp	w1, #64
	b.ge	4f
	ldrb	w2, [x0, w1, uxtw]
	cbz	w2, 4f
	add	w1, w1, #1
	b	3b
4:
	cmp	w1, #1
	b.lt	Lblank
	cmp	w1, #2
	b.gt	Lblank
	b	Lret0
Lboth_class:
	/* w23/w24 are is_free(a)/is_free(b). Both concrete → demoted result.
	 * Both free → blank-equal (Lblank forces 1). */
	cbnz	w23, Lblank
	cbnz	w24, Lblank
	mov	x0, x19
	mov	w1, w20
	mov	w2, w21
	bl	_typeck_type_refs_equal__demoted
	b	Ldone
Lblank:
	mov	x0, x19
	mov	w1, w20
	mov	w2, w21
	bl	_typeck_type_refs_equal__demoted
	b	Lret1

Lnot_both:
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
	b.ne	5f
	mov	w24, w20
	b	Lcheck
5:
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
	ldrb	w5, [x0]
	cbz	w5, Lret0
	cmp	w1, #6
	b.lt	Lret1
	cmp	w1, #64
	b.ls	0f
	mov	w1, #64
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
	ldp	x25, x26, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x60
	ret
