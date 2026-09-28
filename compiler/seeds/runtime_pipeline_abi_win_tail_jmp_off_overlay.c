/*
 * w1487: Windows strong overlay for w499_mega_try_tail_jmp (forwarder jmp stub off).
 *
 * Root: the Windows egg (frozen src/runtime_pipeline_abi.o, copied to
 * pabi_weak.o) carries the pre-w1483 w1048 tail-jmp peer. It has no
 * single-statement gate: it picks the first CALL anywhere in the body whose
 * args look like the formals and replaces the WHOLE function with `jmp
 * callee`. Tip src/asm/pthin_expr_primary.x lost five bodies this way
 * (primary_ident / paren / array / lbrace became `jmp suffix_loop`,
 * ident_pre_dispatch_try_asm became `jmp parse_asm_bang`), and suffix_loop
 * then ran with lex_inout / source swapped (Win tip relink L2 2/5 SEGV in
 * lexer_skip_whitespace_and_comments). Darwin/Linux inject the fixed tip
 * .x peer (w1483 single-stmt gate); the Windows egg cannot be re-injected.
 *
 * Fix: return 0 ("not applicable") so every function takes the normal
 * frame/prologue path. That is always correct; the only cost is that a
 * pure param forwarder keeps a full frame instead of a 5-byte jmp.
 * Egg T is weakened in pabi_weak; post-link win_patch_body_sync_jmp
 * patches the same-TU egg entry (W) to jmp here.
 *
 * PLATFORM: WINDOWS ONLY (host-cc sidecar; Darwin/Linux keep tip .x peer).
 */
#include <stdint.h>

/**
 * Forwarder tail-jmp peer, disabled on Windows.
 * @param m module, @param a arena, @param elf_ctx ELF ctx, @param bctx backend ctx
 * @param ta target arch, @param i function index, @param body_ref body block
 * @return int32_t — always 0 (not applicable; caller emits the full body)
 * PLATFORM: WINDOWS.
 */
int32_t w499_mega_try_tail_jmp(void *m, void *a, void *elf_ctx, void *bctx, int32_t ta, int32_t i,
                               int32_t body_ref) {
  (void)m;
  (void)a;
  (void)elf_ctx;
  (void)bctx;
  (void)ta;
  (void)i;
  (void)body_ref;
  return 0;
}
