/* Host-gcc twin of backend_call_dispatch_try_emit_raw_syscall_call_elf_c
 * (try_emit_raw_syscall_call_elf_c in backend_call_dispatch.x, HEAD).
 * typool first-wins T 0x140424514 compiled `let name: u8[256] = []` as
 * lea rbp-0x48 and passed that dest to pipeline_expr_var_name_into (and
 * the field/method name_into siblings). name_into writes 256 bytes; only
 * 0x48 bytes sit before saved rbp/retaddr, so typool-rebuild of
 * runtime_asm_io_stubs.x execute-at-0 on std_io_write_fd (name length 12
 * takes the name_into path; std_io_read length 11 returns first). Same
 * class as typool glue_block_let_init_lit_c u8[256] shallow-lea smash.
 * This C keeps a real 256-byte name slot. Do not idx8 the documentation
 * .x twin. */
#include <stdint.h>

extern int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *elf_ctx);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_name_len(uint8_t *arena, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_method_call_num_args_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_name_len(uint8_t *arena, int32_t callee_ref);
extern void pipeline_expr_field_access_name_into(uint8_t *arena, int32_t callee_ref, uint8_t *out);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t callee_ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t callee_ref, uint8_t *out);
extern int32_t pipeline_expr_call_num_args_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_method_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_call_arg_ref(uint8_t *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_asm_emit_expr_elf_for_call_args(uint8_t *arena, uint8_t *elf_ctx,
                                                      int32_t arg_ref, uint8_t *ctx, int32_t ta);
extern int32_t backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(uint8_t *elf_ctx, uint8_t *ctx, int32_t ta,
                                                  int32_t nunit);
extern int32_t backend_enc_load_rbp_to_rax_arch(uint8_t *elf_ctx, int32_t off, int32_t ta);
extern int32_t arch_x86_64_enc_enc_mov_rax_to_r10(uint8_t *elf_ctx);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(uint8_t *elf_ctx, int32_t k, int32_t ta);
extern int32_t arch_x86_64_enc_enc_syscall(uint8_t *elf_ctx);
extern int32_t arch_arm64_enc_enc_mov_rax_to_x8(uint8_t *elf_ctx);
extern int32_t arch_arm64_enc_enc_svc(uint8_t *elf_ctx);

int32_t backend_call_dispatch_try_emit_raw_syscall_call_elf_c(uint8_t *arena, uint8_t *elf_ctx,
                                                              int32_t expr_ref, uint8_t *ctx,
                                                              int32_t ta) {
  int32_t ko, nlen, n_args, is_method, arity, i, j, k, callee_ref, cko, arg_ref;
  uint8_t name[256];
  uint8_t pfx[11];
  int32_t off[8];

  if (arena == 0 || elf_ctx == 0 || ctx == 0 || expr_ref <= 0)
    return 0;
  /* x86_64, or Linux ELF aarch64. Darwin Mach-O falls through. */
  if (ta != 0) {
    if (ta != 1)
      return 0;
    if (pipeline_elf_ctx_macho_leading_underscore(elf_ctx) != 0)
      return 0;
  }
  for (i = 0; i < 256; i++)
    name[i] = 0;
  for (i = 0; i < 8; i++)
    off[i] = 0;
  nlen = 0;
  n_args = 0;
  is_method = 0;
  arity = 0 - 1;
  pfx[0] = 114;
  pfx[1] = 97;
  pfx[2] = 119;
  pfx[3] = 95;
  pfx[4] = 115;
  pfx[5] = 121;
  pfx[6] = 115;
  pfx[7] = 99;
  pfx[8] = 97;
  pfx[9] = 108;
  pfx[10] = 108;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 49) {
    nlen = pipeline_expr_method_call_name_len(arena, expr_ref);
    if (nlen != 12)
      return 0;
    pipeline_expr_method_call_name_into(arena, expr_ref, &name[0]);
    n_args = pipeline_expr_method_call_num_args_at(arena, expr_ref);
    is_method = 1;
  } else if (ko == 48) {
    callee_ref = pipeline_expr_call_callee_ref_at(arena, expr_ref);
    cko = 0;
    if (callee_ref <= 0)
      return 0;
    cko = pipeline_expr_kind_ord_at(arena, callee_ref);
    if (cko == 44) {
      nlen = pipeline_expr_field_access_name_len(arena, callee_ref);
      if (nlen != 12)
        return 0;
      pipeline_expr_field_access_name_into(arena, callee_ref, &name[0]);
    } else if (cko == 3) {
      nlen = pipeline_expr_var_name_len(arena, callee_ref);
      if (nlen != 12)
        return 0;
      pipeline_expr_var_name_into(arena, callee_ref, &name[0]);
    } else {
      return 0;
    }
    n_args = pipeline_expr_call_num_args_at(arena, expr_ref);
  } else {
    return 0;
  }
  i = 0;
  while (i < 11) {
    if (name[i] != pfx[i])
      return 0;
    i = i + 1;
  }
  arity = (int32_t)name[11] - 48;
  if (arity < 0 || arity > 6)
    return 0;
  if (n_args != arity + 1)
    return 0;
  i = 0;
  while (i < n_args) {
    if (is_method != 0)
      arg_ref = pipeline_expr_method_call_arg_ref(arena, expr_ref, i);
    else
      arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, i);
    if (arg_ref == 0)
      return 0 - 1;
    if (pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, arg_ref, ctx, ta) != 0)
      return 0 - 1;
    off[i] = backend_call_dispatch_glue_sysv_spill_rax_rdx_to_frame_c(elf_ctx, ctx, ta, 1);
    if (off[i] < 0)
      return 0 - 1;
    i = i + 1;
  }
  if (ta == 0) {
    j = 1;
    while (j < n_args) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off[j], ta) != 0)
        return 0 - 1;
      if (j == 1)
        k = 0;
      else if (j == 2)
        k = 1;
      else if (j == 3)
        k = 2;
      else if (j == 4)
        k = 0 - 1;
      else if (j == 5)
        k = 4;
      else
        k = 5;
      if (k == 0 - 1) {
        if (arch_x86_64_enc_enc_mov_rax_to_r10(elf_ctx) != 0)
          return 0 - 1;
      } else {
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, k, ta) != 0)
          return 0 - 1;
      }
      j = j + 1;
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off[0], ta) != 0)
      return 0 - 1;
    if (arch_x86_64_enc_enc_syscall(elf_ctx) != 0)
      return 0 - 1;
  } else {
    j = 2;
    while (j < n_args) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off[j], ta) != 0)
        return 0 - 1;
      if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, j - 1, ta) != 0)
        return 0 - 1;
      j = j + 1;
    }
    if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off[0], ta) != 0)
      return 0 - 1;
    if (arch_arm64_enc_enc_mov_rax_to_x8(elf_ctx) != 0)
      return 0 - 1;
    if (n_args > 1) {
      if (backend_enc_load_rbp_to_rax_arch(elf_ctx, off[1], ta) != 0)
        return 0 - 1;
    }
    if (arch_arm64_enc_enc_svc(elf_ctx) != 0)
      return 0 - 1;
  }
  return 1;
}
