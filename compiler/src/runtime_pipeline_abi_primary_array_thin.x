// Documentation twin of runtime_pipeline_abi_primary_array_thin.c.
// The fold vehicle is the host-gcc .c (idx8 of a thin with calls AVs in typool
// try_emit_va_cap_builtin_call). Do not idx8 this file for the PE fold.
// Body matches parser_asm_primary_array_x_into_c in pthin_expr_primary.x.
// typool compiled both element-while breaks (`if (kind == COMMA) { if
// (kind == RBRACKET) break; } else break;`) as jmp loop-head.
// Empty `[]` does not take those breaks and already works.
// PLATFORM: WINDOWS PE fold; keep proven hooks, including the s50
// string_lit_append_byte and s51 primary_string JMPs.
