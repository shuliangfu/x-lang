// Documentation twin of runtime_pipeline_abi_stretch_skip_ws_and_comments_thin.c
// (host-gcc of typool parser_asm_stretch_skip_ws_and_comments_c).
// typool compiles the inner `if (not ws) break;` as jmp-to-head (writer RIP
// typool 0x1404a6702) on hello.x byte 0 = 47 ('/'); skip_comment is never
// reached. The same typool body typool-wrongs the outer moved==0 break
// (typool 0x1404a677f / 0x1404a678e), not reached on this hang. Host-gcc
// twin keeps both breaks in a small frame. Do not idx8.
// Do not JMP typool rec T 0x140087de4.
