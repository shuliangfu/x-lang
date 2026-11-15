// Documentation twin of runtime_pipeline_abi_primary_suffix_loop_thin.c
// (host-gcc of typool parser_asm_primary_suffix_loop_x_into_c).
// typool compiles pending_refs[pi]=0 as scale-8 through the local slot
// address (writer RIP typool 0x140478172), smashing saved lex/source/out_ok
// so peek_kind sees null and hello `fmt.println` never takes the DOT arm.
// Host-gcc twin keeps scale-4 through the pointer value and null-checks.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
