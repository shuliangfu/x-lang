// Documentation twin of runtime_pipeline_abi_stretch_import_path_normalize_thin.c
// (host-gcc of typool parser_asm_stretch_import_path_normalize_c).
// typool compiles `if (last != 46) break;` as jmp-to-head (writer RIP typool
// 0x1404a5fe5) after a correct copy of "std.fmt" (out_len=7, last='t').
// Host-gcc twin keeps the trim break in a small frame. Do not idx8.
// Do not JMP typool rec T 0x140087de4.
