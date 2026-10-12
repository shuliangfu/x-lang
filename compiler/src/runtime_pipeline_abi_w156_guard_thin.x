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
// The egg still defines this name as a strong T, so the ensure inject
// returns without compiling. Linux g05 rebuilds w156_guard.o on every
// self-host relink (PREFER=1) and weakens that T only on the build_asm
// pabi copy. Darwin rebuilds w156_guard_a64.o and Windows rebuilds
// w156_guard_win.o on every relink. The thin does not divide.
// PLATFORM: SHARED source; LINUX, MACOS|DARWIN, and WINDOWS sidecars.

/**
 * wave156 INDEX assign-addr cache hit — disabled (always miss).
 * @param arena *u8 - ASTArena* (unused)
 * @param ctx *u8 - AsmFuncCtx* (unused)
 * @param base_ref i32 - INDEX base (unused)
 * @param idx_ref i32 - INDEX index (unused)
 * @param esz i32 - element size (unused)
 * @return i32 - always 0 (miss)
 * w1483 pure. The egg T is the old cache body, so the ensure inject
 * does not replace it. Linux g05 links this body ahead of that copy.
 * PLATFORM: SHARED source; LINUX, MACOS|DARWIN, and WINDOWS sidecars.
 */
#[no_mangle]
export function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32 {
  return 0;
}
