// Documentation twin of runtime_pipeline_abi_lexer_try_keyword_c_thin.c
// (host-gcc of typool lexer_try_keyword_c).
// typool first-wins T 0x14001cbf8 (fromsrc_s105_noaslr) is entered for
// "export" (start=804, nlen=6) from host-cc lexer_try_keyword_b at
// return RIP 0x140003eb2, but out.kind stays the entry stack pointer
// 0x103f2328 instead of TOKEN_EXPORT=131; typool lexer_try_keyword_d
// is not reached. Host-gcc twin writes through out via a small frame
// and falls through to typool lexer_try_keyword_d.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
