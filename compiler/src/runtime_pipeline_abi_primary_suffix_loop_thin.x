// Documentation twin of runtime_pipeline_abi_primary_suffix_loop_thin.c
// (host-gcc of typool parser_asm_primary_suffix_loop_x_into_c).
// typool compiles pending_refs[pi]=0 as scale-8 through the local slot
// address (writer RIP typool 0x140478172), smashing saved lex/source/out_ok
// so peek_kind sees null and hello `fmt.println` never takes the DOT arm.
// Host-gcc twin keeps scale-4 through the pointer value and null-checks.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
// fromsrc_s113 residual: deferred LBRACKET left lex at `buf[` (kind=86)
// after typool leftover assign of `buf[k] = s[k]` (pos=1439, core.fmt
// fmt_i32_to_buf). Host-gcc twin now hosts the typool INDEX arm
// (pthin_expr_primary.x 1140-1168). LT / LBRACE stay deferred.
// typool source unchanged. Do not idx8. Do not JMP typool rec T 0x140087de4.
