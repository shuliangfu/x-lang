/* Host-gcc twin of glue_emit_one_call_arg_elf_c (backend_call_dispatch.x).
 * typool first-wins T 0x1403fe0b0 retaddr-smashes (Rip=0) on stubs typool-rebuild
 * after modlet_prepare returns 0. Do not idx8. */
#include <stdint.h>

extern int32_t glue_call_param_type_ref_at(uint8_t *arena, int32_t call_expr_ref, int32_t arg_index);
extern int32_t glue_sysv_arg_byte_size_c(uint8_t *arena, uint8_t *ctx, int32_t pty, int32_t arg_ref);
extern int32_t backend_call_dispatch_w1521_win_mem_byref_sz(int32_t sz);
extern int32_t backend_call_dispatch_w1521_win_mem_arg_addr_to_rax_c(
    uint8_t *arena, uint8_t *elf_ctx, uint8_t *ctx, int32_t arg_ref, int32_t sz, int32_t ta);
extern void pipeline_asm_emit_set_call_param_type_ref(int32_t pty);
extern void pipeline_asm_emit_call_arg_begin_c(void);
extern void pipeline_asm_emit_call_arg_end_c(void);
extern int32_t pipeline_asm_emit_expr_elf_for_call_args(
    uint8_t *arena, uint8_t *elf_ctx, int32_t arg_ref, uint8_t *ctx, int32_t ta);
extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t glue_call_return_byte_size_c(uint8_t *arena, int32_t arg_ref);
extern int32_t pipeline_asm_call_struct16_ret_needs_rax_deref_c(uint8_t *arena, int32_t arg_ref);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(uint8_t *elf_ctx, int32_t ta);
extern int32_t glue_spill_struct16_call_arg_to_lea_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, uint8_t *ctx, int32_t pty, int32_t ta);

int32_t glue_emit_one_call_arg_elf_c(
    uint8_t *arena, uint8_t *elf_ctx, int32_t call_expr_ref, int32_t arg_ref,
    int32_t arg_index, uint8_t *ctx, int32_t ta) {
  int32_t pty0, sz_w, pty, ret_sz;

  if (arena == 0)
    return 0;
  if (elf_ctx == 0)
    return 0;
  if (ctx == 0)
    return 0;
  if (arg_ref == 0)
    return 0;

  pty0 = glue_call_param_type_ref_at(arena, call_expr_ref, arg_index);
  if (ta == 0) {
    sz_w = glue_sysv_arg_byte_size_c(arena, ctx, pty0, arg_ref);
    if (backend_call_dispatch_w1521_win_mem_byref_sz(sz_w) != 0) {
      return backend_call_dispatch_w1521_win_mem_arg_addr_to_rax_c(
          arena, elf_ctx, ctx, arg_ref, sz_w, ta);
    }
  }
  pipeline_asm_emit_set_call_param_type_ref(pty0);
  pipeline_asm_emit_call_arg_begin_c();
  if (pipeline_asm_emit_expr_elf_for_call_args(arena, elf_ctx, arg_ref, ctx, ta) != 0) {
    pipeline_asm_emit_call_arg_end_c();
    pipeline_asm_emit_set_call_param_type_ref(0);
    return -1;
  }
  pty = glue_call_param_type_ref_at(arena, call_expr_ref, arg_index);
  if (pipeline_expr_kind_ord_at(arena, arg_ref) == 48) {
    ret_sz = glue_call_return_byte_size_c(arena, arg_ref);
    if (ret_sz > 8 || ret_sz < 0) {
      if (pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, arg_ref) != 0) {
        if (pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta) != 0) {
          pipeline_asm_emit_call_arg_end_c();
          pipeline_asm_emit_set_call_param_type_ref(0);
          return -1;
        }
      }
    }
    if (glue_spill_struct16_call_arg_to_lea_elf_c(arena, elf_ctx, ctx, pty, ta) != 0) {
      pipeline_asm_emit_call_arg_end_c();
      pipeline_asm_emit_set_call_param_type_ref(0);
      return -1;
    }
  }
  pipeline_asm_emit_call_arg_end_c();
  pipeline_asm_emit_set_call_param_type_ref(0);
  return 0;
}
