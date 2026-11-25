// Documentation twin of runtime_pipeline_abi_primary_string_thin.c.
// The fold vehicle is the host-gcc .c (idx8 of a thin with calls AVs in typool
// try_emit_va_cap_builtin_call). Do not idx8 this file for the PE fold.
// Body matches parser_asm_primary_string_x_into_c in pthin_expr_primary.x.
// typool compiled the adjacent-string `if (kind != TOKEN_STRING) break`
// as break-as-continue (jmp loop-head at +957). Do not fold typool
// parser_asm_lex_bridge_fill — it was only the hot peek callee.
// PLATFORM: WINDOWS PE fold; keep proven hooks, including the s50
// string_lit_append_byte JMP.
