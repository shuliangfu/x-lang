/* Cap tip: slice/mod.o needs core_option_* but ondemand scans user.o only.
 * Extend simple-group 6 (option) with slice API needles so subslice pulls
 * option.o. PLATFORM: MACOS|ARM64. */
	.section __TEXT,__cstring,cstring_literals
_g_cap_tip_slice_sub_i32:
	.asciz	"core_slice_subslice_i32"
_g_cap_tip_slice_split_i32:
	.asciz	"core_slice_split_at_i32"

	.section __TEXT,__text,regular,pure_instructions
	.globl	_labi_od_simple_group_sym_count
	.p2align	2
_labi_od_simple_group_sym_count:
	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	str	x19, [sp, #16]
	mov	w19, w0
	bl	_labi_od_simple_group_sym_count__demoted
	cmp	w19, #6
	b.ne	1f
	add	w0, w0, #2
1:
	ldr	x19, [sp, #16]
	ldp	x29, x30, [sp], #32
	ret

	.globl	_labi_od_simple_group_sym_at
	.p2align	2
_labi_od_simple_group_sym_at:
	stp	x29, x30, [sp, #-48]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	str	x21, [sp, #32]
	mov	w19, w0
	mov	w20, w1
	cmp	w19, #6
	b.ne	2f
	mov	w0, #6
	bl	_labi_od_simple_group_sym_count__demoted
	mov	w21, w0
	cmp	w20, w21
	b.lt	2f
	sub	w3, w20, w21
	cmp	w3, #0
	b.ne	3f
	adrp	x0, _g_cap_tip_slice_sub_i32@PAGE
	add	x0, x0, _g_cap_tip_slice_sub_i32@PAGEOFF
	b	9f
3:
	cmp	w3, #1
	b.ne	2f
	adrp	x0, _g_cap_tip_slice_split_i32@PAGE
	add	x0, x0, _g_cap_tip_slice_split_i32@PAGEOFF
	b	9f
2:
	mov	w0, w19
	mov	w1, w20
	bl	_labi_od_simple_group_sym_at__demoted
9:
	ldr	x21, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #48
	ret
