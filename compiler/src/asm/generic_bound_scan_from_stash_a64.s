/* Cap tip: expose g_lex_src for generic_bound soft (tip scan_c SEGV).
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _xlang_cap_tip_lex_src_data
	.p2align 2
_xlang_cap_tip_lex_src_data:
	adrp	x0, _g_lex_src_data@PAGE
	add	x0, x0, _g_lex_src_data@PAGEOFF
	ldr	x0, [x0]
	ret
	.globl _xlang_cap_tip_lex_src_len
	.p2align 2
_xlang_cap_tip_lex_src_len:
	adrp	x0, _g_lex_src_len@PAGE
	add	x0, x0, _g_lex_src_len@PAGEOFF
	ldr	x0, [x0]
	ret
