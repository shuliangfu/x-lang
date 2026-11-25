/* Cap tip typeck_check_expr_try_propagate hard-fail soft (knife256/10.2).
 * Cap tip typeck_x body X-codegen-hollows Result `?` (always ok).
 * Soft: require op NAMED Result_* and enclosing return equal; else T001-path
 * via driver_diagnostic_typeck_try_propagate_bad_enclosing.
 * Retarget: demote Cap tip T → __demoted; this .o first-wins live T.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _typeck_check_expr_try_propagate
	.p2align 2
_typeck_check_expr_try_propagate:
	stp	x29, x30, [sp, #-0x90]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	stp	x25, x26, [sp, #0x40]
	str	x27, [sp, #0x50]
	/* x0=module x1=arena w2=expr_ref w3=return_type_ref x4=ctx */
	mov	x19, x0
	mov	x20, x1
	mov	w21, w2
	mov	w22, w3
	mov	x23, x4
	cbz	x19, Lret0
	cbz	x20, Lret0
	cmp	w21, #0
	b.le	Lret0
	/* op_ref = unary_operand(arena, expr) */
	mov	x0, x20
	mov	w1, w21
	bl	_pipeline_expr_unary_operand_ref_at
	mov	w24, w0
	/* line, col */
	mov	x0, x20
	mov	w1, w21
	bl	_pipeline_expr_line_at
	mov	w25, w0
	mov	x0, x20
	mov	w1, w21
	bl	_pipeline_expr_col_at
	mov	w26, w0
	/* typeck_check_expr(module, arena, op_ref, return_type_ref, ctx) */
	mov	x0, x19
	mov	x1, x20
	mov	w2, w24
	mov	w3, w22
	mov	x4, x23
	bl	_typeck_check_expr
	cmp	w0, #0
	b.ne	Lretm1
	/* op_ty */
	mov	x0, x20
	mov	w1, w24
	bl	_pipeline_expr_resolved_type_ref
	mov	w24, w0			/* reuse w24 as op_ty */
	/* enclosing = return_type_ref; maybe from ctx func */
	mov	w22, w22		/* enclosing already in w22 */
	cbz	x23, Lencl_done
	mov	x0, x23
	bl	_pipeline_dep_ctx_current_func_index
	mov	w27, w0			/* func_ix */
	cmp	w27, #0
	b.lt	Lencl_done
	mov	x0, x19
	bl	_pipeline_module_num_funcs
	cmp	w27, w0
	b.ge	Lencl_done
	mov	x0, x19
	mov	w1, w27
	bl	_pipeline_module_func_return_type_at
	cmp	w0, #0
	b.le	Lencl_done
	mov	w22, w0			/* enclosing = func_ret */
Lencl_done:
	/* op_ty > 0 && kind == 8 (NAMED) */
	cmp	w24, #0
	b.le	Lbad
	mov	x0, x20
	mov	w1, w24
	bl	_pipeline_type_kind_ord_at
	cmp	w0, #8
	b.ne	Lbad
	/* name into stack buf at sp+0x50 (48 bytes enough for Result_*) */
	add	x2, sp, #0x58
	mov	x0, x20
	mov	w1, w24
	bl	_pipeline_type_named_name_into
	mov	w1, w0			/* rlen */
	cmp	w1, #7
	b.lt	Lbad
	add	x0, sp, #0x58
	ldrb	w2, [x0]
	cmp	w2, #82			/* 'R' */
	b.ne	Lbad
	ldrb	w2, [x0, #1]
	cmp	w2, #101		/* 'e' */
	b.ne	Lbad
	ldrb	w2, [x0, #2]
	cmp	w2, #115		/* 's' */
	b.ne	Lbad
	ldrb	w2, [x0, #3]
	cmp	w2, #117		/* 'u' */
	b.ne	Lbad
	ldrb	w2, [x0, #4]
	cmp	w2, #108		/* 'l' */
	b.ne	Lbad
	ldrb	w2, [x0, #5]
	cmp	w2, #116		/* 't' */
	b.ne	Lbad
	ldrb	w2, [x0, #6]
	cmp	w2, #95			/* '_' */
	b.ne	Lbad
	mov	w27, w1			/* save op name len */
	/* enclosing must be NAMED Result_* with same name as op.
	 * Cap tip type_refs_equal_c greens i32 vs Result; identity fails when
	 * Result_i32 is interned under distinct refs — compare names. */
	cmp	w22, #0
	b.le	Lbad
	mov	x0, x20
	mov	w1, w22
	bl	_pipeline_type_kind_ord_at
	cmp	w0, #8
	b.ne	Lbad
	add	x2, sp, #0x68
	mov	x0, x20
	mov	w1, w22
	bl	_pipeline_type_named_name_into
	cmp	w0, w27
	b.ne	Lbad
	cmp	w27, #0
	b.le	Lbad
	/* memcmp sp+0x58 vs sp+0x68 for w27 bytes */
	add	x0, sp, #0x58
	add	x1, sp, #0x68
	mov	w2, w27
Lcmp:
	ldrb	w3, [x0], #1
	ldrb	w4, [x1], #1
	cmp	w3, w4
	b.ne	Lbad
	subs	w2, w2, #1
	b.ne	Lcmp
	/* payload: Result_i32 → kind 0; Result_u8 → kind 2 */
	add	x0, sp, #0x58
	ldrb	w1, [x0, #7]
	ldrb	w2, [x0, #8]
	ldrb	w3, [x0, #9]
	mov	w4, #-1			/* payload kind sentinel */
	/* i32: 'i','3','2' */
	cmp	w1, #105
	b.ne	1f
	cmp	w2, #51
	b.ne	1f
	cmp	w3, #50
	b.ne	1f
	mov	w4, #0
	b	2f
1:	/* u8: 'u','8' */
	cmp	w1, #117
	b.ne	2f
	cmp	w2, #56
	b.ne	2f
	mov	w4, #2
2:	cmp	w4, #0
	b.lt	Lret0			/* unknown payload suffix: still ok match */
	mov	x0, x20
	mov	w1, w4
	bl	_pipeline_type_ensure_by_kind_ord
	cmp	w0, #0
	b.le	Lret0
	mov	x1, x20
	mov	w2, w21
	mov	w3, w0
	mov	x0, x1
	mov	w1, w2
	mov	w2, w3
	bl	_pipeline_expr_set_resolved_type_ref
	b	Lret0
Lbad:
	mov	w0, w25
	mov	w1, w26
	bl	_driver_diagnostic_typeck_try_propagate_bad_enclosing
Lretm1:
	mov	w0, #-1
	b	Ldone
Lret0:
	mov	w0, #0
Ldone:
	ldr	x27, [sp, #0x50]
	ldp	x25, x26, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x90
	ret
