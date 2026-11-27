/* Source-faithful user_asm_seed_bridge_uasb_coff_machine_ok twin
 * (compiler/src/asm/user_asm_seed_bridge.x WINDOWS arm).
 *
 * DIG s253 Soft Cap (PLATFORM: WINDOWS host-cc; PE fold):
 * After Soft Cap uasb_zero (s252), Win bare under ASLR SEGV in tipU
 * uasb_rd32 from coff_machine_ok with off=UASB_E_MACHINE (41484312).
 * Source WINDOWS intent: if e_machine != EM_X86_64, accept non-empty
 * code_len (drifted field). tipU still performs the 41MB-offset read
 * first; when elf_ctx is not backed that far under ASLR the load
 * faults before the code_len fallback. Soft Cap skips the unsafe
 * e_machine load and only checks code_len@0 — same accept rule for
 * the drifted-Windows path. docs-only .x, do not idx8.
 */
#include <stdint.h>

/**
 * Read little-endian i32 at byte offset 0 of ctx (UASB_CODE_LEN).
 * @param ctx elf codegen ctx pointer
 * @return code_len field
 */
static int32_t uasb_rd32_code_len(uint8_t *ctx) {
  int32_t b0;
  int32_t b1;
  int32_t b2;
  int32_t b3;

  b0 = ((int32_t)ctx[0]) & 255;
  b1 = ((int32_t)ctx[1]) & 255;
  b2 = ((int32_t)ctx[2]) & 255;
  b3 = ((int32_t)ctx[3]) & 255;
  return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
}

/**
 * WINDOWS COFF machine gate: accept when text is non-empty.
 * Contract: ctx non-null (caller checked). Returns 1 ok / 0 reject.
 * @param ctx elf codegen ctx
 * @return 1 if code_len > 0, else 0
 */
int32_t user_asm_seed_bridge_uasb_coff_machine_ok(uint8_t *ctx) {
  int32_t cl;

  if (ctx == 0) {
    return 0;
  }
  cl = uasb_rd32_code_len(ctx);
  if (cl <= 0) {
    return 0;
  }
  return 1;
}
