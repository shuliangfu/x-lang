/*
 * w1497: Windows strong overlay for pipeline_asm_emit_param_home_elf_c.
 *
 * Root: the Windows egg (frozen src/runtime_pipeline_abi.o, copied to
 * pabi_weak.o) carries two bodies. mega_body calls the same-TU local copy,
 * which is the leftover-PE variant (seeds/runtime_pipeline_abi.from_x.c
 * `#if !FROM_X || WIN_LEFTOVER_GROW_VEC`). It homes each GP formal with a
 * plain 64-bit move and never canonicalizes narrow scalars. A C caller that
 * passes an i32 on the stack writes only the low 32 bits (`movl`), so the
 * home slot keeps stale upper bits; the first 64-bit use (`ti*stride` imul,
 * pointer add) then reads garbage. Linux/Darwin tip bodies call
 * glue_enc_canonicalize_param_in_rax_elf_c (cltq / zero-extend) after the
 * load; this overlay does the same on Windows. Symptom: struct/bound tests
 * exit 0xC0000005 in p12g_load_i32 under
 * xlang_skip_trait_check_param_shape_x_into_c; stack-garbage dependent, so
 * it also shows up as intermittent import-program crashes (10.17).
 *
 * Egg T is weakened in pabi_weak; post-link win_patch_body_sync_jmp
 * patches the egg W entry and the same-TU local (t) copy to jmp here.
 *
 * PLATFORM: WINDOWS ONLY (host-cc sidecar; Darwin/Linux keep tip bodies).
 */
#include <stdint.h>

#if defined(_WIN32) || defined(__MINGW32__) || defined(__MINGW64__)

extern int32_t pipeline_asm_emit_ctx_sret_active_get(void);
extern int32_t pipeline_asm_emit_ctx_sret_home_off_get(void);
extern int32_t pipeline_asm_module_func_num_params_at(void *mod, int32_t func_index);
extern void *pipeline_asm_emit_ctx_arena_get(void);
extern int32_t glue_func_param_home_width_c(void *arena, void *mod, int32_t func_index, int32_t param_index);
extern int32_t glue_asm_call_reg_max(int32_t ta);
extern int32_t backend_enc_mov_arg_reg_to_rax_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t glue_enc_canonicalize_param_in_rax_elf_c(void *elf_ctx, void *arena, void *mod,
                                                        int32_t func_index, int32_t param_index,
                                                        int32_t ta);

/**
 * Home every GP formal of func_index into its rbp slot (Windows x86_64).
 * Same slot layout as the egg leftover-PE body; adds narrow-scalar
 * canonicalization (i32 sign-extend, u32/u8/bool zero-extend) for 1-slot
 * formals so stack-passed i32 upper bits are never trusted.
 * @param elf_ctx ELF ctx, @param ctx asm ctx (unused), @param mod module
 * @param func_index function index, @param ta target arch (0 = x86_64)
 * @return int32_t — 0 ok, -1 encode error
 * PLATFORM: WINDOWS.
 */
int32_t pipeline_asm_emit_param_home_elf_c(void *elf_ctx, void *ctx, void *mod, int32_t func_index,
                                           int32_t ta) {
  int32_t np;
  int32_t i;
  int32_t home;
  int32_t sret_act;
  int32_t sret_off;
  int32_t gp;
  int32_t reg_max;
  (void)ctx;
  if (!elf_ctx || !mod || func_index < 0)
    return -1;
  if (ta != 0)
    return 0;
  sret_act = pipeline_asm_emit_ctx_sret_active_get();
  sret_off = pipeline_asm_emit_ctx_sret_home_off_get();
  if (sret_act != 0 && sret_off >= 0) {
    if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, 0, ta) != 0)
      return -1;
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, sret_off, ta) != 0)
      return -1;
  }
  np = pipeline_asm_module_func_num_params_at(mod, func_index);
  if (np <= 0)
    return 0;
  gp = (sret_act != 0) ? 1 : 0;
  home = 16;
  reg_max = glue_asm_call_reg_max(ta);
  if (reg_max < 1)
    reg_max = 6;
  for (i = 0; i < np && gp < reg_max; i++) {
    int32_t w;
    int32_t wide_home;
    void *arena_ph;
    arena_ph = pipeline_asm_emit_ctx_arena_get();
    w = glue_func_param_home_width_c(arena_ph, mod, func_index, i);
    if (w <= 0)
      w = 8;
    if (w > 8 && w <= 16) {
      wide_home = home + w;
      if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, wide_home, ta) != 0)
        return -1;
      gp = gp + 1;
      if (gp >= reg_max)
        return -1;
      if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, wide_home - 8, ta) != 0)
        return -1;
      gp = gp + 1;
      home = wide_home + 8;
    } else {
      if (backend_enc_mov_arg_reg_to_rax_arch(elf_ctx, gp, ta) != 0)
        return -1;
      if (arena_ph &&
          glue_enc_canonicalize_param_in_rax_elf_c(elf_ctx, arena_ph, mod, func_index, i, ta) != 0)
        return -1;
      if (backend_enc_store_rax_to_rbp_arch(elf_ctx, home, ta) != 0)
        return -1;
      gp = gp + 1;
      home = home + 8;
    }
  }
  return 0;
}

#endif /* _WIN32 */
