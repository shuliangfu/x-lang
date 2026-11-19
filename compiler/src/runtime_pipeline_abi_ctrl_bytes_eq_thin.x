// Docs-only twin of compiler/src/runtime_pipeline_abi_ctrl_bytes_eq_thin.c.
// typool parser_asm_ctrl_bytes_eq typool-wrongs data[i+j] / kw[j] as
// scale-8 through &data / &kw, so a real `if` at fmt_bool_to_buf byte
// 5204 compares unequal. typool source unchanged. Do not idx8. Do not
// JMP typool rec T 0x140087de4.
