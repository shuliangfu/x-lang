// Address of the pabi modlet BSS table.
// The table symbol is local in pabi until the link step globalizes it.
// PLATFORM: MACOS|ARM64.

.globl _pipe_modlet_table_base
.p2align 2
_pipe_modlet_table_base:
	adrp x0, _g_pipeline_asm_modlet@PAGE
	add x0, x0, _g_pipeline_asm_modlet@PAGEOFF
	ret
