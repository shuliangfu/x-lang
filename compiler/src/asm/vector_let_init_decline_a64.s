/* glue_emit_vector_type_let_init_elf_c moved to
 * vector_let_init_array_lit_a64.x. This file must not define the symbol:
 * a hollow `mov w0, #0` short-circuits VAR try_let, and a blanket -3
 * drops ARRAY_LIT lane bytes. PLATFORM: MACOS|ARM64. */
