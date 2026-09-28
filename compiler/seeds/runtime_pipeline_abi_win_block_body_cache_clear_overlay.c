/*
 * w1486: Windows strong overlay for backend_emit_block_body_sync_elf.
 *
 * Root: the Windows egg (frozen src/runtime_pipeline_abi.o) forwards
 * backend_emit_block_body_sync_elf straight to pipeline_asm_emit_block_body_sync_elf
 * without clearing the binop VAR-slot register cache (g_var_cache_*). The
 * mega body reuses one AsmFuncCtx buffer for every function, so the cache
 * key (ctx pointer) still matches in the next function. When that function's
 * first compare loads the same stack slot (e.g. param at -0x10), hit_rbx
 * reports a stale hit and the `mov -0x10(%rbp),%rbx` load is skipped; the
 * compare then reads garbage %ebx (repro: two functions `if (kind == K)`).
 * This miscompiled every tip .x object that g05 built on Windows (pthin
 * fragments, builtin_kind_ord, ...), so tip relinks went L2 0/5.
 *
 * The tip .x body_sync (Darwin/Linux) already clears the cache at block
 * entry; this overlay restores the same semantics on Windows: clear, then
 * forward. Egg T is weakened in pabi_weak; post-link win_patch_body_sync_jmp
 * patches the same-TU egg entry (W) to jmp here, and folds the egg's static
 * wave210 cache copies (t) onto the global T copies so there is one cache.
 *
 * PLATFORM: WINDOWS ONLY (host-cc sidecar; Darwin/Linux keep tip .x).
 */
#include <stdint.h>

extern void glue_binop_var_slot_cache_clear(void);
extern int32_t pipeline_asm_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref,
                                                     void *ctx, int32_t ta);

/**
 * Block body entry: drop VAR-slot register cache, then emit the body.
 * @return pipeline_asm_emit_block_body_sync_elf rc
 * PLATFORM: WINDOWS.
 */
int32_t backend_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx,
                                         int32_t ta) {
  glue_binop_var_slot_cache_clear();
  return pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, block_ref, ctx, ta);
}
