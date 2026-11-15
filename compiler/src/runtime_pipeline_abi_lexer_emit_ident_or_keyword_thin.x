// Documentation twin of runtime_pipeline_abi_lexer_emit_ident_or_keyword_thin.c
// (host-gcc of typool lexer_emit_ident_or_keyword).
// typool lexer_next_body_into inits Token at -0xdd0 but passes -0x280 to
// try_keyword; on miss, stale CONST/garbage at -0x280 is write_tok_into'd
// (writer RIP typool 0x1400312d7) → false P014 on fmt. Host-gcc twin keeps
// tok in one small frame. DIG body_into finish redirects here. Do not idx8.
// Do not JMP typool rec T 0x140087de4.
