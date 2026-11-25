// Documentation twin of runtime_pipeline_abi_collect_imports_consume_path_thin.c
// (host-gcc of typool parser_asm_collect_imports_consume_path_into_c).
// typool compiles `path_len[0] = finalized` (and the earlier path_len[0]=0 /
// path_len[0]=n stores) as lea of the local that holds the path_len pointer
// (writer RIP typool 0x1404a9e45 on fromsrc_s101), so the real out-param stays
// 0 while path_buf correctly holds "std.fmt". That empty length becomes
// IMP001 `_tmpdig/.x`. Host-gcc twin stores through the real path_len pointer.
// Do not idx8. Do not JMP typool rec T 0x140087de4.
