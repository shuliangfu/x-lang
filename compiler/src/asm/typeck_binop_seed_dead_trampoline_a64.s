/* 10.37: after redefine-sym binop→seed_dead, typeck_check_expr_impl_mega
 * still bls to seed_dead (same .o reloc rewrite). Strong trampoline + weakened
 * peel seed_dead routes those calls to Cap tip overlays.
 * PLATFORM: MACOS Cap tip.
 */
	.section __TEXT,__text,regular,pure_instructions
	.globl	_typeck_check_expr_binop__seed_dead
	.p2align	2
_typeck_check_expr_binop__seed_dead:
	b	_typeck_check_expr_binop

	.globl	_typeck_check_expr_binop_cmp__seed_dead
	.p2align	2
_typeck_check_expr_binop_cmp__seed_dead:
	b	_typeck_check_expr_binop_cmp
