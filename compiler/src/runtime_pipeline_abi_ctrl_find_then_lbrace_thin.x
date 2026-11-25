// Docs-only twin of compiler/src/runtime_pipeline_abi_ctrl_find_then_lbrace_thin.c.
// typool parser_asm_ctrl_find_then_lbrace typool-wrongs the `{` && par==0
// break as jmp-to-loop-head, hanging at core.fmt byte 1238. typool source
// unchanged. Do not idx8. Do not JMP typool rec T 0x140087de4.
