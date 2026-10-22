/* knife256/10.2: Cap tip lex_source_data — never prefer sticky park.
 * Sticky park from entry poisons dep prerun → empty type names →
 * mid length_ → U _std_string_length_. Match parser_asm_lex_step_bridge.x.
 * PLATFORM: MACOS arm64.
 */
	.text
	.align 2
	.globl _parser_asm_lex_source_data_c
_parser_asm_lex_source_data_c:
	// x0 = source fat *; return source->data (offset 0)
	cbz	x0, 1f
	ldr	x0, [x0]
	ret
1:
	mov	x0, xzr
	ret

	.globl _parser_asm_lex_source_length_c
_parser_asm_lex_source_length_c:
	// x0 = source fat *; return source->len as usize (offset 8 on LP64)
	cbz	x0, 2f
	ldr	x0, [x0, #8]
	ret
2:
	mov	x0, xzr
	ret
