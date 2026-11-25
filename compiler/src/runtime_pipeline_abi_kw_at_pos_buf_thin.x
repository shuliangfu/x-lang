// Docs-only twin of compiler/src/runtime_pipeline_abi_kw_at_pos_buf_thin.c.
// typool parser_asm_kw_at_pos_buf_c typool-wrongs data[next_pos] as scale-8
// through &data and typool-wrongs kw[0] as a pointer compare, so a real
// `if` at fmt_bool_to_buf byte 5204 returns 0. typool source unchanged.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
