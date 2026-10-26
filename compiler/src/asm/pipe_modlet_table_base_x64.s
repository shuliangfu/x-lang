/* Address of the pabi modlet BSS table (Linux x86_64).
 * The table symbol is local until the link step globalizes it.
 * PLATFORM: LINUX|X86_64.
 */
	.globl pipe_modlet_table_base
	.type pipe_modlet_table_base, @function
	.p2align 4
pipe_modlet_table_base:
	leaq g_pipeline_asm_modlet(%rip), %rax
	ret
	.size pipe_modlet_table_base, .-pipe_modlet_table_base
