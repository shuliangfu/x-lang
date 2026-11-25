// Documentation twin of runtime_pipeline_abi_lexer_emit_string_token_thin.c
// (host-gcc of typool lexer_emit_string_token).
// typool body_into never calls begin_number_span at the opening quote and
// inlines the STRING finish with wrong huge-frame start/slen slots
// (writer RIP typool 0x14003133c ident_len=172 from end_pos-0; park writes
// token_start=0). Surviving open locals start=165/line=3/col=20. Host-gcc
// twin takes those as args; DIG close-quote redirect calls it then jumps
// to body epilogue. Do not idx8. Do not JMP typool rec T 0x140087de4.
