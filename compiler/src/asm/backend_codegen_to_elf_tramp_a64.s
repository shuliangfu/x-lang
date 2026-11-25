// note743y.6.23: Cap tip-equivalent thin tramp for tip-cold to_elf entries.
// tip XLANG emits fat to_elf seed_mega (0x880) that never calls pipeline_.
// Match Cap: frame 0x90, bl pipeline_, sxtw w0→x0, epilogue.
// Do NOT tramp _backend_asm_codegen_ast here — Cap routes that through
// seed_mega (0x3d0) setup; bl pipeline_ directly SEGVs on option.
// PLATFORM: MACOS|LINUX arm64 tip cold.
	.text
	.align	2

	.globl	_backend_asm_codegen_ast_to_elf_seed_mega
_backend_asm_codegen_ast_to_elf_seed_mega:
	sub	sp, sp, #0x90
	stp	x29, x30, [sp]
	mov	x29, sp
	str	x19, [sp, #0x80]
	bl	_pipeline_backend_asm_codegen_ast_to_elf_c
	sxtw	x0, w0
	mov	sp, x29
	ldr	x19, [sp, #0x80]
	ldp	x29, x30, [sp]
	add	sp, sp, #0x90
	ret

	.globl	_backend_asm_codegen_ast_to_elf
_backend_asm_codegen_ast_to_elf:
	sub	sp, sp, #0x90
	stp	x29, x30, [sp]
	mov	x29, sp
	str	x19, [sp, #0x80]
	bl	_pipeline_backend_asm_codegen_ast_to_elf_c
	sxtw	x0, w0
	mov	sp, x29
	ldr	x19, [sp, #0x80]
	ldp	x29, x30, [sp]
	add	sp, sp, #0x90
	ret
