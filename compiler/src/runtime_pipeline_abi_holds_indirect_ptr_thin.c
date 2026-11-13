/*
 * Host-gcc twin of runtime_pipeline_abi_holds_indirect_ptr_thin.x.
 * Root (s40): typool folded asm_local_var_slot_holds_indirect_ptr hangs
 *   inside glue_type_ref_is_named_struct_layout →
 *   pipeline_module_struct_layout_name_byte_at / pipe_load_ptr_slot
 *   when a by-value TYPE_NAMED (8) Option local is an import-method arg
 *   (unwrap_or_i32(none_opt)). idx8 PREFER_ASM of the .x thin AVs in
 *   typool backend_call_dispatch_try_emit_va_cap_builtin_call_elf_c
 *   (huge lea 0x6b3196e0(%rbp)). Windows host-cc (-c -O2) is the fold
 *   vehicle. TYPE_NAMED=8 returns before the typool layout walk;
 *   TYPE_PTR=9 still returns 1; sidecar widen is unchanged.
 * PLATFORM: WINDOWS — PE fold first-wins; LINUX/MACOS use the .x thin.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t *asm_ctx);
extern int32_t pipeline_block_resolve_var_type_ref(uint8_t *arena, int32_t br, uint8_t *vname, int32_t vlen);
extern int32_t pipeline_expr_resolved_type_ref(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_asm_var_is_emit_func_param_ptr_c(uint8_t *arena, uint8_t *mod, uint8_t *asm_ctx, int32_t expr_ref);
extern int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(uint8_t *arena, uint8_t *mod, int32_t expr_ref);
extern int32_t glue_type_ref_is_named_struct_layout(uint8_t *arena, uint8_t *mod, int32_t ty_ref);
extern int32_t pipeline_type_kind_ord_at(uint8_t *arena, int32_t type_ref);
extern uint8_t *arena_sidecar_get(uint8_t *key, int32_t create);
extern uint8_t *grow_vec_at(uint8_t *v, int32_t index);
extern int32_t pipe_load_i32_le(uint8_t *base, int32_t off);

static int32_t widen_type_kind_ord(uint8_t *arena, int32_t type_ref) {
  int32_t kind;
  uint8_t *sc;
  int32_t n;
  uint8_t *slot;
  if (arena == 0 || type_ref <= 0) {
    return -1;
  }
  kind = pipeline_type_kind_ord_at(arena, type_ref);
  if (kind >= 0) {
    return kind;
  }
  sc = arena_sidecar_get(arena, 0);
  if (sc == 0) {
    return -1;
  }
  n = pipe_load_i32_le(sc + 16, 12);
  if (type_ref > n) {
    return -1;
  }
  slot = grow_vec_at(sc + 16, type_ref - 1);
  if (slot == 0) {
    return -1;
  }
  return pipe_load_i32_le(slot, 0);
}

int32_t asm_local_var_slot_holds_indirect_ptr(uint8_t *arena, int32_t expr_ref, uint8_t *mod, uint8_t *asm_ctx) {
  int32_t has_block_decl;
  int32_t decl_ty;
  int32_t ko;
  int32_t vlen;
  int32_t scope_br;
  int32_t kind;
  int32_t tr;
  int32_t kind2;
  int32_t named2;
  uint8_t vname[256];
  has_block_decl = 0;
  decl_ty = 0;
  if (arena == 0) {
    return 0;
  }
  if (expr_ref <= 0) {
    return 0;
  }
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (asm_ctx != 0) {
    if (ko == 3) {
      vlen = pipeline_expr_var_name_len(arena, expr_ref);
      if (vlen > 0 && vlen <= 63) {
        pipeline_expr_var_name_into(arena, expr_ref, vname);
        scope_br = asm_ctx_scope_block_ref_at(asm_ctx);
        if (scope_br > 0) {
          decl_ty = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
          if (decl_ty > 0) {
            has_block_decl = 1;
          }
        }
      }
    }
  }
  if (has_block_decl != 0) {
    kind = widen_type_kind_ord(arena, decl_ty);
    if (kind == 9) {
      return 1;
    }
    /* TYPE_NAMED=8 and every other kind in this branch return 0.
     * Skip typool glue_type_ref_is_named_struct_layout (hangs). */
    return 0;
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0) {
    if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) {
      return 1;
    }
    if (mod != 0) {
      if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
        return 1;
      }
    }
    return 0;
  }
  kind2 = widen_type_kind_ord(arena, tr);
  if (kind2 == 9) {
    return 1;
  }
  /* TYPE_NAMED=8: same as the named-layout hit path after the
   * indirect-struct check — skip typool layout name walk (hangs). */
  if (kind2 == 8) {
    if (mod != 0) {
      if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
        return 1;
      }
    }
    return 0;
  }
  named2 = glue_type_ref_is_named_struct_layout(arena, mod, tr);
  if (named2 != 0) {
    if (mod != 0) {
      if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, expr_ref) != 0) {
        return 1;
      }
    }
    return 0;
  }
  if (pipeline_asm_var_is_emit_func_param_ptr_c(arena, mod, asm_ctx, expr_ref) != 0) {
    return 1;
  }
  return 0;
}
