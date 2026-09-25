/* PLATFORM: WINDOWS leftover-PE — real glue_emit_assign_var_elf_c.
 * windows_link_stubs.c still has return -1 stubs; windows_e assign_emit
 * dispatches VAR lhs here. Without this, `c = 7` / `c = res.value` CG002.
 * Link FIRST with -Wl,--allow-multiple-definition over the stub.
 * Authority twin: runtime_pipeline_abi_assign_var_*.x finish+store path.
 */
#include <stdint.h>

extern int32_t glue_var_expr_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                           int32_t ta);
extern int32_t backend_enc_store_rax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_eax_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t backend_enc_store_rdx_to_rbp_arch(void *elf_ctx, int32_t slot_off, int32_t ta);
extern int32_t glue_slice_dual_gp_length_off_c(int32_t data_home, int32_t ta);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref,
                                                    int32_t slot_off, int32_t ta, int32_t init_ref,
                                                    void *ctx);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_asm_modlet_name_is_shared(uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_modlet_store_from_rax_elf_c(void *elf_ctx, uint8_t *name, int32_t name_len,
                                                       int32_t ta);

static int32_t win_assign_rhs_to_rax(void *arena, void *elf_ctx, int32_t assign_expr_ref, int32_t right_ref,
                                    void *ctx, int32_t ta) {
  int32_t ako;
  if (!arena || !elf_ctx || !ctx || right_ref <= 0)
    return -1;
  ako = pipeline_expr_kind_ord_at(arena, assign_expr_ref);
  /* Plain ASSIGN only in this leftover knife (si / if-assign). */
  if (ako != 28)
    return -1;
  return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta);
}

int32_t glue_emit_assign_var_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, int32_t left_ref,
                                  int32_t right_ref, void *ctx, int32_t ta) {
  int32_t off;
  int32_t ltr;
  int32_t ltk;

  if (!arena || !elf_ctx || !ctx || left_ref <= 0 || right_ref <= 0)
    return -1;
  off = glue_var_expr_stack_off_elf_c(arena, ctx, left_ref);
  if (off < 0) {
    /* PLATFORM: WINDOWS — a file-scope scalar has no frame slot.
     * name_is_shared reads the egg table prepare filled. The egg store
     * leas that cell and writes 8 bytes from rax. Same face as
     * runtime_pipeline_abi_assign_thin.x. Locals stay on the rbp path. */
    uint8_t vname[256];
    int32_t vlen = pipeline_expr_var_name_len(arena, left_ref);
    if (vlen <= 0 || vlen > 255)
      return -1;
    pipeline_expr_var_name_into(arena, left_ref, vname);
    if (!pipeline_asm_modlet_name_is_shared(vname, vlen))
      return -1;
    if (win_assign_rhs_to_rax(arena, elf_ctx, expr_ref, right_ref, ctx, ta) != 0)
      return -1;
    return pipeline_asm_modlet_store_from_rax_elf_c(elf_ctx, vname, vlen, ta);
  }
  if (win_assign_rhs_to_rax(arena, elf_ctx, expr_ref, right_ref, ctx, ta) != 0)
    return -1;

  ltr = glue_var_decl_type_ref_elf_c(arena, ctx, left_ref);
  ltk = (ltr > 0) ? pipeline_type_kind_ord_at(arena, ltr) : 0;
  if (ltk == 11) {
    if (backend_enc_store_rax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
    if (backend_enc_store_rdx_to_rbp_arch(elf_ctx, glue_slice_dual_gp_length_off_c(off, ta), ta) != 0)
      return -1;
  } else if (ltr > 0 && ltk == 14) {
    if (backend_enc_store_eax_to_rbp_arch(elf_ctx, off, ta) != 0)
      return -1;
  } else if (glue_store_retval_pair_to_rbp_elf_c(glue_emit_module_from_ctx(ctx), arena, elf_ctx, ltr, off, ta,
                                                right_ref, ctx) != 0) {
    return -1;
  }
  return 0;
}
