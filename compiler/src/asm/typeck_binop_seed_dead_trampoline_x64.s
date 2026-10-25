/* 10.37: seed_dead → live overlay trampoline. PLATFORM: LINUX tip-cold. */
	.text
	.globl	typeck_check_expr_binop__seed_dead
	.type	typeck_check_expr_binop__seed_dead, @function
	.p2align	4
typeck_check_expr_binop__seed_dead:
	jmp	typeck_check_expr_binop

	.globl	typeck_check_expr_binop_cmp__seed_dead
	.type	typeck_check_expr_binop_cmp__seed_dead, @function
	.p2align	4
typeck_check_expr_binop_cmp__seed_dead:
	jmp	typeck_check_expr_binop_cmp
