/* PLATFORM: WINDOWS leftover-PE — real glue_copy_large_struct_from_rax_ptr_elf_c.
 * Twin of FROM_X seed body (memcpy via arg_reg; Win64 enc → rcx/rdx/r8).
 * Link FIRST with -Wl,--allow-multiple-definition over leftover stub in pabi.
 */
#include <stdint.h>

extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *sym, int32_t sym_len, int32_t ta);
extern int32_t backend_enc_mov_rbx_to_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t glue_arm64_mov_x19_to_x0_elf_c(void *elf_ctx);

int32_t glue_copy_large_struct_from_rax_ptr_elf_c(void *elf_ctx, int32_t slot_off, int32_t sz, int32_t ta) {
  uint8_t memcpy_sym[8];
  memcpy_sym[0] = 109;
  memcpy_sym[1] = 101;
  memcpy_sym[2] = 109;
  memcpy_sym[3] = 99;
  memcpy_sym[4] = 112;
  memcpy_sym[5] = 121;
  memcpy_sym[6] = 0;
  if (!elf_ctx || (ta != 0 && ta != 1) || sz < 8)
    return -1;
  if (sz <= 16 && slot_off != -3)
    return -1;
  if (slot_off == -3) {
    if (ta == 1) {
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
        return -1;
      if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
        return -1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
        return -1;
      if (glue_arm64_mov_x19_to_x0_elf_c(elf_ctx) != 0)
        return -1;
      return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
    }
    if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rbx_to_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (ta == 1) {
    if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
      return -1;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
      return -1;
    if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
      return -1;
    if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
      return -1;
    return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
  }
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, slot_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_pop_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, sz, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, memcpy_sym, 6, ta);
}
