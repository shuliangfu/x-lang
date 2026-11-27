/* Source-faithful uasb_sym_at / uasb_sym_name_ptr twin
 * (compiler/src/asm/user_asm_seed_bridge.x).
 *
 * DIG s255 Soft Cap (PLATFORM: SHARED host-cc; PE fold WINDOWS):
 * After Soft Cap uasb_rd32 (s254) kept full-width p+off, Win ASLR still
 * SEGV in Soft Cap rd32 with a truncated sym pointer. GDB: tipU
 * user_asm_seed_bridge_uasb_sym_at does `add %ebx,%eax` (32-bit) when
 * forming ctx+UASB_SYMS+i*SYM_SIZE — high heap bits of ctx are lost.
 * sym_name_ptr has the same 32-bit add for ctx+UASB_SYM_NAME_DATA+off.
 * Host-cc uses 64-bit pointer arithmetic. Fold into uasb_notes.o;
 * win_patch dual-T folds same-TU tipU. docs-only .x.
 */
#include <stdint.h>

enum {
  UASB_SYMS = 37093392,
  UASB_SYM_SIZE = 268,
  UASB_SYM_NAME_LEN = 256,
  UASB_NUM_SYMS = 41484304,
  UASB_SYM_NAME_DATA = 51249200
};

extern int32_t uasb_rd32(uint8_t *p, int32_t off);

/**
 * Address of syms[i] within ElfCodegenCtx.
 * @param ctx elf codegen ctx (full 64-bit)
 * @param i symbol index
 * @return pointer to sym record
 */
uint8_t *user_asm_seed_bridge_uasb_sym_at(uint8_t *ctx, int32_t i) {
  return ctx + (int64_t)UASB_SYMS + (int64_t)i * (int64_t)UASB_SYM_SIZE;
}

/**
 * Packed name bytes for sym idx in sym_name_data.
 * @param ctx elf codegen ctx
 * @param idx symbol index
 * @return pointer into name pool, or null
 */
uint8_t *user_asm_seed_bridge_uasb_sym_name_ptr(uint8_t *ctx, int32_t idx) {
  int32_t nsyms;
  int32_t off;
  int32_t i;
  int32_t nl;

  if (idx < 0 || ctx == 0) {
    return 0;
  }
  nsyms = uasb_rd32(ctx, UASB_NUM_SYMS);
  off = 0;
  i = 0;
  while (i < idx && i < nsyms) {
    nl = uasb_rd32(user_asm_seed_bridge_uasb_sym_at(ctx, i), UASB_SYM_NAME_LEN);
    off = off + nl;
    i = i + 1;
  }
  if (off < 0 || off >= 131072) {
    return 0;
  }
  return ctx + (int64_t)UASB_SYM_NAME_DATA + (int64_t)off;
}
