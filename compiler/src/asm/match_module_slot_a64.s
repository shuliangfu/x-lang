/* Cap tip: pipeline_match_module_bytes X-codegen returns stack pad, so
 * set_match_module never sticks → Color.Green match arms keep var_idx=-1
 * ("enum has no variant"). Own BSS + get/set. PLATFORM: MACOS|ARM64. */
	.section __DATA,__data
	.align 3
_g_cap_tip_match_module:
	.quad	0

	.section __TEXT,__text,regular,pure_instructions
	.globl	_pipeline_match_module_bytes
	.p2align	2
_pipeline_match_module_bytes:
	adrp	x0, _g_cap_tip_match_module@PAGE
	add	x0, x0, _g_cap_tip_match_module@PAGEOFF
	ret

	.globl	_pipeline_parser_set_match_module
	.p2align	2
_pipeline_parser_set_match_module:
	adrp	x1, _g_cap_tip_match_module@PAGE
	str	x0, [x1, _g_cap_tip_match_module@PAGEOFF]
	ret

	.globl	_pipeline_parser_get_match_module
	.p2align	2
_pipeline_parser_get_match_module:
	adrp	x0, _g_cap_tip_match_module@PAGE
	ldr	x0, [x0, _g_cap_tip_match_module@PAGEOFF]
	ret
