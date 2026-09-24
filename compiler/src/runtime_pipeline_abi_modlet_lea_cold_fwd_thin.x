// Darwin and Windows pabi call pipe_modlet_lea_named_binding_addr_to_rax_cold
// for a module INDEX store. That gcc body misses the live modlet table,
// then faults in glue_module_func_index_by_name_c. This file is only the
// cold entry. The live function remains the one authority.
// PLATFORM: MACOS|DARWIN / WINDOWS. Do not PREFER this into
// runtime_pipeline_abi.o. Do not modify that object in place.

export extern function pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx: *u8, m: *u8, name: *u8, name_len: i32, ta: i32): i32;

/**
 * Forward a stale cold lea entry to the live modlet resolver.
 * Zero logic of its own: the callee owns the table and the function-symbol
 * fallback. A null elf_ctx or name is rejected there.
 * @param elf_ctx *u8 — code buffer; null is rejected by the callee
 * @param m *u8 — module pointer; null is forwarded
 * @param name *u8 — binding name bytes; null is rejected by the callee
 * @param name_len i32 — byte count of name
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when the address is in rax, -1 otherwise
 * PLATFORM: MACOS|DARWIN / WINDOWS — linked ahead of the gcc cold body.
 */
#[no_mangle]
export function pipe_modlet_lea_named_binding_addr_to_rax_cold(elf_ctx: *u8, m: *u8, name: *u8, name_len: i32, ta: i32): i32 {
  unsafe {
    return pipe_modlet_lea_named_binding_addr_to_rax(elf_ctx, m, name, name_len, ta);
  }
}
