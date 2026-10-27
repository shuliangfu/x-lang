/* 10.46: PE link stubs for faces Linux tip-peel provides but Win leftover
 * egg / provider thins leave U. No host-cc .c. PLATFORM: WINDOWS. */
	.text
	.globl	pipeline_asm_emit_return_elf_impl_prev
	.def	pipeline_asm_emit_return_elf_impl_prev;	.scl	2;	.type	32;	.endef
	.def	pipeline_asm_emit_return_elf_impl;	.scl	2;	.type	32;	.endef
pipeline_asm_emit_return_elf_impl_prev:
	jmp	pipeline_asm_emit_return_elf_impl

	.globl	glue_lane_f32_lit_dest_set
	.def	glue_lane_f32_lit_dest_set;	.scl	2;	.type	32;	.endef
glue_lane_f32_lit_dest_set:
	/* Win64: rcx = value */
	movq	%rcx, .L_lane_dest(%rip)
	ret

	.globl	glue_lane_f32_lit_dest_get
	.def	glue_lane_f32_lit_dest_get;	.scl	2;	.type	32;	.endef
glue_lane_f32_lit_dest_get:
	movq	.L_lane_dest(%rip), %rax
	ret

	.globl	pipe_modlet_float_expr_trunc_i32
	.def	pipe_modlet_float_expr_trunc_i32;	.scl	2;	.type	32;	.endef
pipe_modlet_float_expr_trunc_i32:
	xorl	%eax, %eax
	ret

	.globl	pipe_modlet_fold_f64_elem_bits
	.def	pipe_modlet_fold_f64_elem_bits;	.scl	2;	.type	32;	.endef
pipe_modlet_fold_f64_elem_bits:
	xorl	%eax, %eax
	ret

	.globl	pipeline_lane_shr_is_arith
	.def	pipeline_lane_shr_is_arith;	.scl	2;	.type	32;	.endef
pipeline_lane_shr_is_arith:
	xorl	%eax, %eax
	ret

	.data
	.align	8
.L_lane_dest:
	.quad	0
