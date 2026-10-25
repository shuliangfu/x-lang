/* Cap tip / tip soft: expose g_lex_src for generic_bound soft.
 * PLATFORM: LINUX|x86_64 tip (and Cap tip when present). */
	.text
	.globl xlang_cap_tip_lex_src_data
	.type xlang_cap_tip_lex_src_data, @function
	.p2align 4
xlang_cap_tip_lex_src_data:
	movq g_lex_src_data(%rip), %rax
	ret
	.size xlang_cap_tip_lex_src_data, .-xlang_cap_tip_lex_src_data

	.globl xlang_cap_tip_lex_src_len
	.type xlang_cap_tip_lex_src_len, @function
	.p2align 4
xlang_cap_tip_lex_src_len:
	movq g_lex_src_len(%rip), %rax
	ret
	.size xlang_cap_tip_lex_src_len, .-xlang_cap_tip_lex_src_len
