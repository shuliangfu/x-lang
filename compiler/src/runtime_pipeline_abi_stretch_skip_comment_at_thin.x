// Documentation twin of runtime_pipeline_abi_stretch_skip_comment_at_thin.c
// (host-gcc of typool parser_asm_stretch_skip_comment_at_c).
// typool compiles the line-comment `if (data[i] == 10 || data[i] == 13)
// break;` as jmp-to-head (writer RIP typool 0x1404a6414) so i sticks on
// hello.x's first newline (i=63, c=10). Host-gcc twin keeps the break in
// a small frame. Do not idx8. Do not JMP typool rec T 0x140087de4.
