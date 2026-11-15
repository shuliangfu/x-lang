/* Host-gcc twin of w1545_pend_rcx_emit (backend_call_dispatch.x).
 * typool first-wins T 0x1403f5960 compiles `let b: u8[8] = []` with
 * scale-8 qword stores. b[3] = (du & 255) lands at [rbp-0x10] and
 * overwrites the saved elf_ctx; later append_bytes / pipe_load_i32_le
 * then SIGSEGV with rcx = that smashed byte (0x90 on the result
 * typool-rebuild CALL ok path). Writer RIP typool 0x1403f5a45.
 * Same class as already-folded w1545_win_epi_prefix u8[8] scale-8.
 * Do not idx8. Bind typool pend BSS VAs directly (Mingw .refptr
 * unresolved by pe_fold_append_last). */
#include <stdint.h>

extern int32_t backend_call_dispatch_w1545_pend_is(int32_t expr_ref);
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *elf_ctx, uint8_t *b, int32_t n);

#define W1545_PEND_EXPR (*(int32_t *)(uintptr_t)0x1404f0720ULL)
#define W1545_PEND_OFF  (*(int32_t *)(uintptr_t)0x1404f0724ULL)
#define W1545_PEND_USED (*(int32_t *)(uintptr_t)0x1404f0728ULL)

int32_t backend_call_dispatch_w1545_pend_rcx_emit(uint8_t *elf_ctx, int32_t expr_ref) {
  uint8_t b[8];
  int32_t d, rc;
  uint32_t du;

  if (backend_call_dispatch_w1545_pend_is(expr_ref) == 0)
    return 0;
  d = 0 - W1545_PEND_OFF;
  du = (uint32_t)d;
  b[0] = 72;
  b[1] = 141;
  b[2] = 141;
  b[3] = (uint8_t)(du & 255u);
  b[4] = (uint8_t)((du >> 8) & 255u);
  b[5] = (uint8_t)((du >> 16) & 255u);
  b[6] = (uint8_t)((du >> 24) & 255u);
  rc = pipeline_elf_ctx_append_bytes(elf_ctx, &b[0], 7);
  if (rc != 0)
    return -1;
  W1545_PEND_USED = 1;
  W1545_PEND_EXPR = 0;
  return 0;
}
