// Documentation twin of runtime_pipeline_abi_as_suffix_into_slice_thin.c
// (host-gcc of typool parser_asm_parse_as_suffix_into_slice_c).
// fromsrc_s114 residual: typool slice tramp left cur unfilled, so
// as_suffix_x never saw TOKEN_AS at `(one_u << 63) as i64` (fmt_i64_to_buf).
// Host-gcc twin memcpy's out+8 <-> cur around the leftover x_into body.
// typool source unchanged. Do not idx8. Do not JMP typool rec T 0x140087de4.
