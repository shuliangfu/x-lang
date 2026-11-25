/* knife256/10.2: lex_out kept in x19 across into_c — stack slot at [sp,#0x30]
 * was clobbered by tip into_c's large frame / spill, writing 0x100000000.
 * PLATFORM: MACOS arm64
 */
	.globl	_parser_asm_parse_one_extern_and_add_into_slice_c
	.p2align	2
_parser_asm_parse_one_extern_and_add_into_slice_c:
	stp	x28, x27, [sp, #-0x30]!
	stp	x29, x30, [sp, #0x10]
	stp	x20, x19, [sp, #0x20]
	add	x29, sp, #0x10
	sub	sp, sp, #0x2d0
	/* x19 = lex_out (x5) — survive into_c */
	mov	x19, x5
	/* stack chk */
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	stur	x8, [x29, #-0x18]
	str	x2, [sp, #0x50]
	str	x3, [sp, #0x58]
	str	x0, [sp, #0x48]
	str	x1, [sp, #0x40]
	str	x4, [sp, #0x38]
	str	x19, [sp, #0x30]
	cbz	x19, 9f
	ldr	x8, [sp, #0x38]
	cbz	x8, 9f
	add	x0, sp, #0x1a0
	str	x0, [sp, #0x8]
	mov	x1, #0x128
	bl	_bzero
	ldr	x0, [sp, #0x8]
	bl	_ast_pool_onefunc_reset
	add	x0, sp, #0x160
	str	x0, [sp, #0x10]
	mov	x2, #0x40
	mov	w1, #0
	str	w1, [sp, #0x4]
	bl	_memset
	ldr	w1, [sp, #0x4]
	add	x0, sp, #0x60
	str	x0, [sp, #0x18]
	mov	x2, #0x100
	bl	_memset
	ldr	x4, [sp, #0x8]
	ldr	x5, [sp, #0x10]
	ldr	x6, [sp, #0x18]
	ldr	q0, [sp, #0x50]
	add	x0, sp, #0x20
	str	q0, [sp, #0x20]
	ldr	x1, [sp, #0x38]
	ldr	x2, [sp, #0x48]
	ldr	x3, [sp, #0x40]
	bl	_parser_asm_parse_one_extern_and_add_into_c
	/* write lex back via x19, NOT reloaded stack slot */
	ldr	q0, [sp, #0x20]
	str	q0, [x19]
9:
	ldur	x9, [x29, #-0x18]
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	8f
	add	sp, sp, #0x2d0
	ldp	x20, x19, [sp, #0x20]
	ldp	x29, x30, [sp, #0x10]
	ldp	x28, x27, [sp], #0x30
	ret
8:
	bl	___stack_chk_fail
