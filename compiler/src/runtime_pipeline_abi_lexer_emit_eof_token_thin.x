// Documentation twin of runtime_pipeline_abi_lexer_emit_eof_token_thin.c
// (host-gcc of typool lexer_next_impl EOF Token emit).
// typool EOF arm builds Token at -0xe0 but write_tok_into copies from
// wrong slot -0x70 (store RIP typool 0x14003e268; wrong lea typool
// 0x14003e330; write_tok call typool 0x14003e3c1), leaving r.tok.kind as
// pointer garbage so strict parse_skip fires after main at byte 232.
// Host-gcc twin writes TOKEN_EOF from out.next_lex in one small frame.
// DIG redirect of the pos>=len EOF arm is required. Do not idx8.
// Do not JMP typool rec T 0x140087de4.
