// Thin pure: wave156 INDEX assign-addr cache guard (w1483).
// Bug: after `a[i] = v` the base pabi remembers "rbx holds &a[i]"
// (g_w156_ia_valid) and a later `a[i]` read reuses rbx via
// glue_index_load_from_cached_assign_addr_elf_c (`mov %rbx,%rax`).
// Cmp / binop paths reload rbx (backend_enc_mov_rax_to_rbx_arch,
// binop var-slot rbx cache) without dropping that cache, so the read
// dereferences a stale value -> x86_64 product SEGV (Ubuntu tip
// parser_asm_primary_suffix_loop_x_into_c; min repro 16 lines).
// Base cache bodies live in HARD BAN pabi overlays (emit_index /
// binop_var_slot_cache / enc_dispatch), so the guard overrides only
// the hit predicate: never reuse rbx. Always correct (full address
// recompute); costs a few bytes per repeated INDEX.
// PRODUCT: LINUX (x86_64 ELF) PREFER. Darwin arm64 unaffected.
// PLATFORM: LINUX.

/**
 * wave156 INDEX assign-addr cache hit — disabled (always miss).
 * @param arena *u8 - ASTArena* (unused)
 * @param ctx *u8 - AsmFuncCtx* (unused)
 * @param base_ref i32 - INDEX base (unused)
 * @param idx_ref i32 - INDEX index (unused)
 * @param esz i32 - element size (unused)
 * @return i32 - always 0 (miss)
 * w1483 pure. PLATFORM: LINUX.
 */
#[no_mangle]
export function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  return 0;
}
