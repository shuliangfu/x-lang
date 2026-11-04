/**
 * PLATFORM: WINDOWS tip PE only — tip.x-faithful VAR→rax:rdx dual-GP load.
 *
 * Soft Cap glue_load_var_as_value_to_rax_rdx_elf_c returns Option as rax-only.
 * Callee `return o` drops value@+8; .c79srvp caller store is already dual-GP.
 * Ban Soft Cap Prefer body copy. Win product ta==0 path.
 */
#include <stdint.h>

extern int32_t glue_local_var_slot_needs_ptr_load_elf_c(void *arena, int32_t var_expr_ref,
                                                       int32_t off, void *ctx);
extern int32_t backend_enc_load_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t glue_type_size_simple(void *mod, void *arena, int32_t ty_ref, int32_t depth);
extern int32_t glue_sysv_dual_gp_byte_size_c(void *arena, int32_t ty_ref);
extern int32_t pipeline_asm_deref_struct16_rax_ptr_elf_c(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_rbp_to_rdx_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t off, int32_t ta);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ty_ref);
extern int32_t glue_enc_sxt_i32_result_to_rax_elf_c(void *elf_ctx, int32_t ta);
extern int32_t glue_enc_zxt_u32_result_to_rax_elf_c(void *elf_ctx, int32_t ta);
extern int32_t glue_enc_zxt_u8_result_to_rax_elf_c(void *elf_ctx, int32_t ta);

int32_t glue_load_var_as_value_to_rax_rdx_elf_c(void *elf_ctx, void *arena, void *ctx,
                                               int32_t var_expr_ref, int32_t off, int32_t ta) {
  int32_t tr;
  int32_t sz;
  int32_t nsz;
  void *mod;
  int32_t rc;
  int32_t kind_ord;
  int32_t needs_ptr;
  if (elf_ctx == 0 || off < 0) {
    return -1;
  }
  needs_ptr = glue_local_var_slot_needs_ptr_load_elf_c(arena, var_expr_ref, off, ctx);
  if (needs_ptr != 0) {
    rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta);
    if (rc != 0) {
      return -1;
    }
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, var_expr_ref);
    if (tr <= 0) {
      tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
    }
    mod = pipeline_asm_emit_module_ref_c();
    sz = glue_type_size_simple(mod, arena, tr, 0);
    if (sz <= 16 && tr > 0) {
      nsz = glue_sysv_dual_gp_byte_size_c(arena, tr);
      if (nsz > sz) {
        sz = nsz;
      }
    }
    if (sz > 8 && sz <= 16 && ta == 0) {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
    return 0;
  }
  tr = glue_var_decl_type_ref_elf_c(arena, ctx, var_expr_ref);
  if (tr <= 0) {
    tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
  }
  mod = pipeline_asm_emit_module_ref_c();
  sz = glue_type_size_simple(mod, arena, tr, 0);
  if (sz <= 16 && tr > 0) {
    nsz = glue_sysv_dual_gp_byte_size_c(arena, tr);
    if (nsz > sz) {
      sz = nsz;
    }
  }
  if (sz > 8 && sz <= 16 && arena != 0 && ctx != 0) {
    /* Soft Cap Win PE ta==0: low→rax, high→rdx (low-end contiguous off+8). */
    if (ta == 0) {
      rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta);
      if (rc != 0) {
        return -1;
      }
      rc = backend_enc_load_rbp_to_rdx_arch(elf_ctx, off + 8, ta);
      if (rc != 0) {
        return -1;
      }
      return 0;
    }
  }
  if (sz > 16) {
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, off, ta);
    if (rc != 0) {
      return -1;
    }
    return 0;
  }
  rc = backend_enc_load_rbp_to_rax_arch(elf_ctx, off, ta);
  if (rc != 0) {
    return -1;
  }
  if (arena != 0 && tr > 0) {
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
    if (kind_ord == 0) {
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    }
    if (kind_ord == 3) {
      return glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx, ta);
    }
    if (kind_ord == 1 || kind_ord == 2) {
      return glue_enc_zxt_u8_result_to_rax_elf_c(elf_ctx, ta);
    }
  }
  return 0;
}
