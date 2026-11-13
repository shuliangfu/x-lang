/*
 * Host-gcc twin of glue_asm_emit_call_with_cleanup
 * (language in compiler/src/asm/backend_call_dispatch.x).
 *
 * Root (s58 typool compile of takes_ptr(&nl[0], 1) after typool
 *   call_dispatch_load_ptr_le fold): typool first-wins T
 *   glue_asm_emit_call_with_cleanup 0x14041050c is called from typool
 *   w1521_emit_call_body at 0x140435265 after typool build_call_export_sym
 *   returns a real symbol. typool of
 *   `let sub_rsp: u8[4] = [72, 131, 236, 32]` (`sub rsp, 32`) uses typool
 *   huge-lea `lea 0x6b3196e0(%rbp),%rax` then stores 0x48 at typool writer
 *   RIP 0x1404105c3 (`mov %rax,0x0(%rbx)`), typool element stride 0x2d0d,
 *   ER C0000005 write info1=0x7b7017e0. typool emit_call_args /
 *   typool one_call_arg never entered (they are the next language steps
 *   after the Windows shadow reserve).
 *
 * Intended: append 4 bytes 48 83 EC 20 then emit_call_args + call + cleanup.
 * Actual: typool huge-lea / typool u8[4] literal-init smash.
 * Class: typool huge-lea / typool u8[N] literal-init smash (own class,
 *   gdb-proven live residual of this compile; not the `&arr[0]` call-arg
 *   lea-of-slot face). Same typool huge-lea fingerprint as typool va_cap
 *   (`lea 0x6b3196e0(%rbp)`), different face.
 * Fold allowlist: glue_asm_emit_call_with_cleanup only. Do not idx8.
 * Do not fold typool emit_call_args, typool one_call_arg, typool try_emit,
 *   typool win_fwd_ret_call, typool pipe_load, typool vtable name_into,
 *   or typool pend BSS.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks including
 *   typool va_cap 0x140425f4c → 0x14a3e3c00 and typool
 *   call_dispatch_load_ptr_le 0x1403f4604 → 0x14a3e4c00.
 */
#include <stdint.h>

int32_t link_abi_host_is_windows(void);
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx, const uint8_t *buf, int32_t n);
int32_t pipeline_asm_emit_call_args_elf_c(uint8_t *arena, uint8_t *elf_ctx,
                                          int32_t expr_ref, uint8_t *ctx,
                                          int32_t ta, int32_t nargs);
int32_t glue_asm_enc_call_redirected(uint8_t *elf_ctx, uint8_t *name,
                                     int32_t name_len, int32_t ta);
int32_t glue_sysv_x86_call_n_stack_c(uint8_t *arena, int32_t expr_ref, int32_t nargs);
int32_t backend_call_dispatch_glue_aapcs64_call_n_stack_c(uint8_t *arena, uint8_t *ctx, int32_t expr_ref,
                                    int32_t nargs);
int32_t glue_asm_call_stack_cleanup_bytes(int32_t ta, int32_t nargs);
int32_t backend_enc_call_stack_cleanup_arch(uint8_t *elf_ctx, int32_t cleanup,
                                            int32_t ta);
int32_t glue_asm_harvest_call_ret_to_gpr_c(uint8_t *arena, uint8_t *elf_ctx,
                                           int32_t expr_ref, int32_t ta);

int32_t glue_asm_emit_call_with_cleanup(uint8_t *arena, uint8_t *elf_ctx,
                                        int32_t expr_ref, uint8_t *ctx,
                                        int32_t ta, int32_t nargs,
                                        uint8_t *cname, int32_t clen) {
  int32_t cleanup;
  int32_t hr;
  int32_t win_shadow;
  int32_t nw_c;
  uint8_t sub_rsp[4];

  cleanup = 0;
  hr = 0;
  win_shadow = 0;

  /* PLATFORM: WINDOWS x86_64. 48 83 EC 20 is sub rsp, 32. Must precede
   * emit_call_args. */
  if (ta == 0) {
    if (link_abi_host_is_windows() != 0) {
      win_shadow = 32;
      sub_rsp[0] = 72;
      sub_rsp[1] = 131;
      sub_rsp[2] = 236;
      sub_rsp[3] = 32;
      if (pipeline_elf_ctx_append_bytes(elf_ctx, &sub_rsp[0], 4) != 0) {
        return 0 - 1;
      }
    }
  }
  if (pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, nargs) != 0) {
    return 0 - 1;
  }
  if (glue_asm_enc_call_redirected(elf_ctx, cname, clen, ta) != 0) {
    return 0 - 1;
  }
  if (ta == 0) {
    nw_c = glue_sysv_x86_call_n_stack_c(arena, expr_ref, nargs);
    cleanup = nw_c * 8;
    if (nw_c > 0) {
      if ((nw_c & 1) != 0) {
        cleanup = cleanup + 8;
      }
    }
  } else if (ta == 1) {
    nw_c = backend_call_dispatch_glue_aapcs64_call_n_stack_c(arena, ctx, expr_ref, nargs);
    cleanup = nw_c * 8;
    if (cleanup > 0) {
      cleanup = (cleanup + 15) & (0 - 16);
    }
  } else {
    cleanup = glue_asm_call_stack_cleanup_bytes(ta, nargs);
  }
  if (cleanup < 0) {
    return 0 - 1;
  }
  if (backend_enc_call_stack_cleanup_arch(elf_ctx, cleanup, ta) != 0) {
    return 0 - 1;
  }
  hr = glue_asm_harvest_call_ret_to_gpr_c(arena, elf_ctx, expr_ref, ta);
  if (hr != 0) {
    return 0 - 1;
  }
  if (win_shadow != 0) {
    if (backend_enc_call_stack_cleanup_arch(elf_ctx, win_shadow, ta) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}
