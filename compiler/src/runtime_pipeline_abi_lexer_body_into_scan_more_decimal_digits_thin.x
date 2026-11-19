// Docs-only twin of compiler/src/runtime_pipeline_abi_lexer_body_into_scan_more_decimal_digits_thin.c.
// Do not idx8. typool lexer_next_body_into inlined decimal take_byte stores
// data[l.pos] into the data fat slot (-0x30), then the next length check
// treats ASCII '0' as a pointer (SEGV at typool +18640, rax=0x38).
