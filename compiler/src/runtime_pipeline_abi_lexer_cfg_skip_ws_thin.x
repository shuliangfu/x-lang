// Documentation twin of runtime_pipeline_abi_lexer_cfg_skip_ws_thin.c
// (host-gcc of typool lexer_cfg_skip_ws). typool compiles
// `if (is_ws == 0) break;` as jmp-to-head (writer RIP typool 0x14037e186)
// on a non-whitespace byte ('t' at p=0), so lexer_cfg_eval_expr_range never
// returns. Host-gcc twin keeps the break. Do not idx8.
// Do not JMP typool rec T 0x140087de4.
