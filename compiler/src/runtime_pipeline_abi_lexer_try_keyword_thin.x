// Documentation twin of runtime_pipeline_abi_lexer_try_keyword_thin.c
// (host-gcc of typool lexer_try_keyword).
// typool first-wins T 0x1400157dc (fromsrc_s91) matches "const" (match
// returns 1) but copies out.kind from slot -0x160 while kind=3 lives at
// -0x710. Writer RIP typool 0x140015d82. Caller return RIP typool
// lexer_next_body_into at typool 0x140030bd2. Live: MATCH_RET eax=1;
// WRONG_STORE writing_eax=0 slot710.kind=3 slot160.kind=0 → TOKEN_IDENT
// instead of TOKEN_CONST. Host-gcc twin writes through out via a small
// frame. Falls through to typool lexer_try_keyword_b. Do not idx8.
// Do not JMP typool rec T 0x140087de4.
