/**
 * PLATFORM: WINDOWS tip PE only — EXPR_VAR dual-GP load via tip.x path (WIP).
 *
 * Soft Cap mega emit_expr leaves Option VAR return as rax-only. tip.x routes
 * VAR through glue_load_var_as_value_to_rax_rdx. Ban Soft Cap Prefer body copy.
 * NOTE: return of params may bypass emit_expr — validate before inject.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t glue_call_arg_resolve_var_stack_off_elf_c(void *arena, void *ctx,
                                                        int32_t var_expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_type_size_simple(void *mod, void *arena, int32_t ty_ref, int32_t depth);
extern int32_t glue_sysv_dual_gp_byte_size_c(void *arena, int32_t ty_ref);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c__orig(void *arena, void *elf_ctx, int32_t expr_ref,
                                                 void *ctx, int32_t ta);

int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                    int32_t ta) {
  int32_t ko;
  int32_t off;
  int32_t tr;
  int32_t sz;
  int32_t nsz;
  void *mod;
  int32_t rc;
  if (arena == 0 || elf_ctx == 0 || expr_ref <= 0) {
    return pipeline_asm_emit_expr_elf_c__orig(arena, elf_ctx, expr_ref, ctx, ta);
  }
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 3 && ctx != 0 && ta == 0) {
    off = glue_call_arg_resolve_var_stack_off_elf_c(arena, ctx, expr_ref);
    if (off >= 0) {
      tr = glue_var_decl_type_ref_elf_c(arena, ctx, expr_ref);
      if (tr <= 0) {
        tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
      }
      mod = pipeline_asm_emit_module_ref_c();
      sz = glue_type_size_simple(mod, arena, tr, 0);
      if (sz <= 16 && tr > 0) {
        nsz = glue_sysv_dual_gp_byte_size_c(arena, tr);
        if (nsz > sz) {
          sz = nsz;
        }
      }
      if (sz > 8 && sz <= 16) {
        rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta);
        if (rc != 0) {
          return -1;
        }
        rc = backend_enc_load_rbp_to_rdx_arch(elf_ctx, off - 8, ta);
        if (rc != 0) {
          return -1;
        }
        return 0;
      }
    }
  }
  return pipeline_asm_emit_expr_elf_c__orig(arena, elf_ctx, expr_ref, ctx, ta);
}
