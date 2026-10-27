/* Address of the pabi modlet BSS table (Windows PE x86_64).
 * The table symbol is local until the link step globalizes it.
 * PLATFORM: WINDOWS|X86_64 · 10.46.
 */
	.globl pipe_modlet_table_base
	.def pipe_modlet_table_base; .scl 2; .type 32; .endef
	.p2align 4
pipe_modlet_table_base:
	leaq g_pipeline_asm_modlet(%rip), %rax
	ret
