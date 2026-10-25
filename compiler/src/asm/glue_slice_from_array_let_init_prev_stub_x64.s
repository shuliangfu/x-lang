/* Linux tip when egg demote missed: slice_modlet _prev → -1 (CG002). */
	.globl	glue_emit_slice_from_array_let_init_elf_c_prev
	.p2align	4
glue_emit_slice_from_array_let_init_elf_c_prev:
	movl	$-1, %eax
	ret
