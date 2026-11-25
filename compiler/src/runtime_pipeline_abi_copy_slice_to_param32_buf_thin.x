// Docs-only twin of compiler/src/runtime_pipeline_abi_copy_slice_to_param32_buf_thin.c.
// Do not idx8. typool parser_asm_copy_slice_to_param32_buf_c typool-wrongs
// the 256-byte row fill as scale-8 through the local slots &source / &out,
// smashing the return address to 0 on fmt_i32's param copy.
