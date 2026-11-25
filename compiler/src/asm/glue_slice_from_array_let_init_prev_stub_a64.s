/* Cap tip / no-egg link: slice_modlet calls _prev for non-STRUCT_LIT arms.
 * When runtime_pipeline_abi.o is not linked, provide CG002-equivalent (-1). */
	.globl	_glue_emit_slice_from_array_let_init_elf_c_prev
	.p2align	2
_glue_emit_slice_from_array_let_init_elf_c_prev:
	mov	w0, #-1
	ret
