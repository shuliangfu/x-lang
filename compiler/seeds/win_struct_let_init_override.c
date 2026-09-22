/* PLATFORM: WINDOWS leftover-PE — real pipeline_asm_emit_struct_let_init_elf_c.
 * windows_link_stubs historically returned -1; Class U forwards to
 * pipeline_asm_emit_struct_lit_fields_elf_c (already live on PE).
 * Link FIRST with -Wl,--allow-multiple-definition over leftover stub in pabi.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref,
                                                        void *ctx, int32_t ta, int32_t stack_slot_off);

int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref,
                                               void *ctx, int32_t ta, int32_t stack_slot_off) {
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 45)
    return -1;
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}
