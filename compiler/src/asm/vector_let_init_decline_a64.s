/* Cap tip: m8 hollow glue_emit_vector_type_let_init returned 0 and
 * short-circuited VAR try_let (scalar i=i+1 / while body empty).
 * Decline with -3 (not-handled) so finish+store runs. PLATFORM: MACOS|ARM64. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _glue_emit_vector_type_let_init_elf_c
	.p2align 2
_glue_emit_vector_type_let_init_elf_c:
	mov	w0, #-3
	ret
