// note743y.6.23: tip-cold seed_mega trampoline. tip XLANG emits a fat
// backend_seed_mega_fallback body (frame 0x880) that never calls
// pipeline_backend_asm_codegen_ast_to_elf_c; Cap tip / this tramp is thin.
// PLATFORM: MACOS|LINUX arm64 tip cold.
	.text
	.align	2
	.globl	_backend_asm_codegen_ast_to_elf_seed_mega
_backend_asm_codegen_ast_to_elf_seed_mega:
	b	_pipeline_backend_asm_codegen_ast_to_elf_c
	.globl	_backend_asm_codegen_ast_to_elf
_backend_asm_codegen_ast_to_elf:
	b	_pipeline_backend_asm_codegen_ast_to_elf_c
