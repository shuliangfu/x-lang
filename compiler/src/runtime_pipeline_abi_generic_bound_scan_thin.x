// Documentation twin of runtime_pipeline_abi_generic_bound_scan_thin.c
// (host-gcc of typool parser_asm_generic_bound_scan_into_c).
// typool compiles the outer `if (kind == TOKEN_EOF) break` as jmp-to-head
// (writer RIP typool 0x1404be702), so after main is collected the scan
// hangs at EOF (hello lexpos 232). Host-gcc twin keeps the break.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
