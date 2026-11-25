/*
 * DIG s223: host-cc ret0 stubs for arr_struct_lit asl_* when tip-asm
 * emits ELF Machine=None (EM:0). Real thin bodies query then return 0;
 * product -E (C emit) does not need the asm emit side path. Keep ABI
 * arity so leftover U on glue_struct_lit_*_elf_c resolves. PLATFORM:
 * LINUX gold g05 bag — Soft Cap HOLD; not a Soft Cap of the thins.
 */
#include <stdint.h>

/** Always-0 tip twin for glue_struct_lit_call_bulk_elf_c (10 args). */
int32_t glue_struct_lit_call_bulk_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t src, uint8_t *ctx, int32_t ta,
    int32_t sret_direct, int32_t field_mag, int32_t foff, int32_t n_arr, int32_t esz) {
  (void)arena; (void)elf_ctx; (void)src; (void)ctx; (void)ta;
  (void)sret_direct; (void)field_mag; (void)foff; (void)n_arr; (void)esz;
  return 0;
}

/** Always-0 tip twin for glue_struct_lit_call_elems_elf_c (10 args). */
int32_t glue_struct_lit_call_elems_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t src, uint8_t *ctx, int32_t ta,
    int32_t sret_direct, int32_t field_mag, int32_t foff, int32_t n_arr, int32_t esz) {
  (void)arena; (void)elf_ctx; (void)src; (void)ctx; (void)ta;
  (void)sret_direct; (void)field_mag; (void)foff; (void)n_arr; (void)esz;
  return 0;
}

/** Always-0 tip twin for glue_struct_lit_copy_bulk_elf_c (9 args). */
int32_t glue_struct_lit_copy_bulk_elf_c(
    uint8_t *elf_ctx, uint8_t *ctx, int32_t ta, int32_t sret_direct,
    int32_t field_mag, int32_t foff, int32_t n_arr, int32_t esz, int32_t src_off) {
  (void)elf_ctx; (void)ctx; (void)ta; (void)sret_direct;
  (void)field_mag; (void)foff; (void)n_arr; (void)esz; (void)src_off;
  return 0;
}

/** Always-0 tip twin for glue_struct_lit_copy_elems_elf_c (8 args). */
int32_t glue_struct_lit_copy_elems_elf_c(
    uint8_t *elf_ctx, int32_t ta, int32_t sret_direct, int32_t field_mag,
    int32_t foff, int32_t n_arr, int32_t esz, int32_t src_off) {
  (void)elf_ctx; (void)ta; (void)sret_direct; (void)field_mag;
  (void)foff; (void)n_arr; (void)esz; (void)src_off;
  return 0;
}
