/* Win64 park for lexer source buffer (rt_run_asm_backend U).
 * SysV twin uses different arg regs; PE uses rcx/rdx.
 * PLATFORM: WINDOWS|X86_64 · 10.46.
 */
	.globl g_lex_src_data
	.bss
	.align 8
g_lex_src_data:
	.zero 8
	.globl g_lex_src_len
g_lex_src_len:
	.zero 8
	.text
	.globl lexer_src_park
	.def lexer_src_park; .scl 2; .type 32; .endef
	.p2align 4
lexer_src_park:
	movq %rcx, g_lex_src_data(%rip)
	movslq %edx, %rax
	movq %rax, g_lex_src_len(%rip)
	ret
	.globl lexer_src_data_store
	.def lexer_src_data_store; .scl 2; .type 32; .endef
lexer_src_data_store:
	movq g_lex_src_data(%rip), %rax
	ret
	.globl lexer_src_len_store
	.def lexer_src_len_store; .scl 2; .type 32; .endef
lexer_src_len_store:
	movq g_lex_src_len(%rip), %rax
	ret
