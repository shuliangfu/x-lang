// Documentation twin of runtime_pipeline_abi_lexer_try_keyword_b_thin.c
// (host-gcc of typool lexer_try_keyword_b).
// typool first-wins T 0x140018010 (fromsrc_s93) matches "import"
// (match returns 1) but copies out.kind from slot -0x550 while kind=53
// lives at -0x710. Writer RIP typool 0x140019868. Live: MATCH_IMP_RET
// eax=1; WRONG_STORE writing_eax=0 slot710.kind=53 slot550.kind=0 →
// TOKEN_IDENT instead of TOKEN_IMPORT. Host-gcc twin writes through out
// via a small frame. Falls through to typool lexer_try_keyword_c.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
