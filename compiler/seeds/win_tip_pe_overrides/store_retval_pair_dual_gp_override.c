/**
 * PLATFORM: WINDOWS tip PE only — tip.x-faithful 9–16B dual-GP store.
 *
 * Soft Cap mega glue_store_retval_pair drops rdx for named size 9..16.
 * This override handles only that band (rax@slot + rdx@slot-8 on x86);
 * all other sizes trampoline to Soft Cap mega. Ban Soft Cap Prefer body copy.
 */
#include <stdint.h>

extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t glue_sysv_dual_gp_byte_size_c(void *arena, int32_t ty_ref);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c__orig(void *m, void *arena, void *elf_ctx,
                                                        int32_t ty_ref, int32_t slot_off,
                                                        int32_t ta, int32_t init_ref, void *ctx);

int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                            int32_t slot_off, int32_t ta, int32_t init_ref,
                                            void *ctx) {
  int32_t sz;
  int32_t nsz;
  int32_t half2;
  int32_t rc;
  if (elf_ctx == 0) {
    return -1;
  }
  sz = glue_type_size_simple(m, arena, ty_ref, 0);
  if (sz <= 16 && arena != 0 && ty_ref > 0) {
    nsz = glue_sysv_dual_gp_byte_size_c(arena, ty_ref);
    if (nsz > sz) {
      sz = nsz;
    }
  }
  if (!(sz > 8 && sz <= 16) || ta != 0) {
    return glue_store_retval_pair_to_rbp_elf_c__orig(m, arena, elf_ctx, ty_ref, slot_off, ta,
                                                     init_ref, ctx);
  }
  rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta);
  if (rc != 0) {
    return -1;
  }
  half2 = slot_off - 8;
  rc = backend_enc_store_rdx_to_rbp_arch(elf_ctx, half2, ta);
  if (rc != 0) {
    return -1;
  }
  return 0;
}
